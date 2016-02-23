% Combine #gap# instances and feed it into GMM
% Move by one instance after each GMM encoding. At the end, come back to
% the beginning.
% gap = 1, no rotation.

function output = assemble(a1, a2, s1, s2, e1, e2, path, assembleMode, numFrame)
    disp('Assembling...');
    
    output = [];
    numRow = 1;
    idxAct = 1;
    for action = a1 : a2
        video = [];
        indexOfVideos = 1;
        
        for subject = s1 : s2
            for instance = e1 : e2;
                data = readSkt(action, subject, instance, path);    
%                 drawskt_rawData(data, 'all', 0);
                if (~isempty(data))
                    video(indexOfVideos).action = action;
                    video(indexOfVideos).subject = subject;
                    video(indexOfVideos).instance = instance;
                    video(indexOfVideos).rawData = data;
                                  
                    % Compute nao joint
                    theta = naoJoint(video(indexOfVideos).rawData);
                    video(indexOfVideos).data = theta;

                    indexOfVideos = indexOfVideos + 1;  
                end
            end  
        end      
        
        
        numInstance = size(video,2);
        if numInstance ~= 0
            fprintf('\n\t Action %d, total instance number %d. ', action, numInstance);            
            switch assembleMode
                case 'batch'
                        subArray = extractfield(video,'subject');
                        for j = min(subArray) : max(subArray)
                            t = find(subArray==j);
                            videosFromOneSubject = video(t(1):t(end));
                            
                            inData = align_2D(videosFromOneSubject, numFrame); 

                            output(idxAct).action = action;
                            output(idxAct).data = inData;
                            
                            idxAct = idxAct + 1;
                        end                    
                        
                case 'indiv' % DTW
                        fprintf('instance');                         
                        for i = 1 : numInstance 
                            fprintf(' %d  ', i);     
                            %reference by the first instance of each subject
                            if video(i).instance == 1
                                video(i).alignedData = alignByReference(video(i), video(i), numFrame);    
                                referenceVideo = video(i);
                            end
                            video(i).alignedData = alignByReference(referenceVideo, video(i), numFrame);                            
                        end
                        [tmp(1:numel(video)).action] = video.action;
                        [tmp(1:numel(video)).data] = video.alignedData;
                        output = [output,tmp];
                case 'resizeOnly' %only resize, no alignment
                    fprintf('\t resize only. instance: ');
                    for i = 1 : numInstance 
                            fprintf('%d   ', i);                           
                            output(idxAct).data = video(i).data;
                            output(idxAct).action = action;                                                    
                            idxAct = idxAct + 1;                        
                    end                        

                 case 'incremental'
                        inData = align_2D(video, numFrame); 
                        output(idxAct).action = action;
                        output(idxAct).data = inData;
                        idxAct = idxAct + 1;                                                                        
            end
        end
    end    
end

function result = centerData(data)
    numJoint = size(data,1);
    torso = data(1,:,:);
    result = data - repmat(torso, [numJoint,1]);
end

function video = normalizeData(video)
    for i = 1 : size(video, 2)
        tmp = video(i).data;
        t = permute(tmp, [1,3,2]);
        for f = 1 : size(t, 3)
            t(:,:,f) = normr(t(:,:,f));
        end
        video(i).data = permute(t, [1,3,2]);
    end    
end

function theta = naoJoint(data)
    X = data(:,:,1);
    Y = data(:,:,2);
    Z = data(:,:,3);
    %RArm
    rshoulder.x = X(5,:);
    rshoulder.y = Y(5,:);
    rshoulder.z = Z(5,:);

    relbow.x = X(6,:);
    relbow.y = Y(6,:);
    relbow.z = Z(6,:);

    rhand.x = X(7,:);
    rhand.y = Y(7,:);
    rhand.z = Z(7,:);

%     non = zeros(1, size(rshoulder.x, 2));

    theta = asin((rshoulder.z - relbow.z) ./ dist(rshoulder, relbow));
    theta =[theta; -asin((rshoulder.x - relbow.x) ./ dist(rshoulder, relbow))];
    theta =[theta; -asin((relbow.x - rhand.x) ./ dist(relbow, rhand))];
    theta =[theta; acos(dist(rshoulder, rhand).^2 - dist(rshoulder, relbow).^2 - dist(relbow,rhand).^2)];
    %triangle - Chi
%     theta =[theta; acos((dist(rshoulder, rhand).^2 - dist(rshoulder, relbow).^2 - dist(relbow,rhand).^2)./ ...
%         (2*dist(rshoulder,relbow).*dist(relbow,rhand)) ...
%         )];

%     theta = [theta; [non;non]];

    %LArm
    lshoulder.x = X(9,:);
    lshoulder.y = Y(9,:);
    lshoulder.z = Z(9,:);

    lelbow.x = X(10,:);
    lelbow.y = Y(10,:);
    lelbow.z = Z(10,:);

    lhand.x = X(11,:);
    lhand.y = Y(11,:);
    lhand.z = Z(11,:);

    theta =[theta; asin((lshoulder.z - lelbow.z) ./ dist(lshoulder, lelbow))];
    theta =[theta; -asin((lshoulder.x - lelbow.x) ./ dist(lshoulder, lelbow))];
    theta =[theta; -asin((lelbow.x - lhand.x) ./ dist(lelbow, lhand))];
    theta =[theta; -acos(dist(lshoulder, lhand).^2 - dist(lshoulder, lelbow).^2 - dist(lelbow,lhand).^2)];
%     theta =[theta; acos((dist(lshoulder, lhand).^2 - dist(lshoulder, lelbow).^2 - dist(lelbow,lhand).^2)./ ...
%         (2*dist(lshoulder,lelbow).*dist(lelbow,lhand)) ...
%         )];
    
    
%     theta =[theta; [non;non]];

    %RLeg
    rhip.x = X(13,:);
    rhip.y = Y(13,:);
    rhip.z = Z(13,:);

    rknee.x = X(14,:);
    rknee.y = Y(14,:);
    rknee.z = Z(14,:);

    rfoot.x = X(15,:);
    rfoot.y = Y(15,:);
    rfoot.z = Z(15,:);

%     theta =[theta; non];
    theta =[theta; asin((rhip.y - rknee.y) ./ dist(rhip, rknee))];
    theta =[theta; asin((rhip.x - rknee.x) ./ dist(rhip, rknee))];
    theta =[theta; asin((rknee.x - rfoot.x) ./ dist(rknee, rfoot))];
%     theta =[theta; [non;non]];

    %LLeg
    lhip.x = X(17,:);
    lhip.y = Y(17,:);
    lhip.z = Z(17,:);

    lknee.x = X(18,:);
    lknee.y = Y(18,:);
    lknee.z = Z(18,:);

    lfoot.x = X(19,:);
    lfoot.y = Y(19,:);
    lfoot.z = Z(19,:);

%     theta =[theta; non];
    theta =[theta; asin((lhip.y - lknee.y) ./ dist(lhip, lknee))];
    theta =[theta; asin((lhip.x - lknee.x) ./ dist(lhip, lknee))];
    theta =[theta; asin((lknee.x - lfoot.x) ./ dist(lknee, lfoot))];
%     theta =[theta; [non;non]];
end

function d = dist(p1, p2)
    d = sqrt(((p1.x - p2.x) .^ 2 + (p1.y - p2.y) .^2 + (p1.z - p2.z) .^2));
end

function result = align_2D(videos, numFrame)
     result = [];
     ref = videos(1).data;
     numJoint = size(ref, 1);
     ref = imresize(ref, [numJoint numFrame]);
 
     for e = 2 : size(videos, 2)
         new = [];
         v = videos(e).data;
         for j = 1 : numJoint
                 dim = ref(j,:);
                 tmp = [v(j,:)];
                 [w, n] = DTW(tmp', dim');
 %                         figure;
 %                         plot(n);hold on;plot(dim, 'r'); plot(tmp, 'g');
 %                         new =[new; dim];
                 new = [new; n'];
         end
         result = [result, new];
     end
     result=[ref, result];
 
end


 function result = alignByReference(referenceVideo, inputVideo, numFrame) 
    numJoint = size(referenceVideo.data, 1);        

    if isequal(referenceVideo, inputVideo)
        result = imresize(referenceVideo.data, [numJoint numFrame]);
    else
         referenceData = referenceVideo.alignedData;
         new = [];
         inputVideoData = inputVideo.data;
         for j = 1 : numJoint
                 dim = referenceData(j,:);
                 tmp = [inputVideoData(j,:)];
%                  tmp = imresize(tmp, [1 numFrame]); %??resize then DTW?
                 [w, n] = DTW(tmp', dim');
%                          figure;
%                          plot(n,'*');hold on;plot(dim, 'r'); plot(tmp, 'g');
%                          new =[new; dim];
                 new = [new; n'];
         end
         result = new;         
    end

 end