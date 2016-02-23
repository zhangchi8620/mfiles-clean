% Align Data to the first instance, by
% 'joint(j1, j2, ...)', 'dimension (x,y,z)'

function  result = align(videos, numFrame, mode) 
    result = [];
    numInstance = size(videos, 2);
    numJoint = size(videos(1).data, 1);
    ref = videos(1).data;
    ref = imresize(ref, [numJoint numFrame]);
    
%     for j = 1 : numJoint
%         tmp = [ref(j,:,1); ref(j,:,2); ref(j,:,3)];
%         result = [result;tmp];
%     end
%     
    switch mode
        case 'dimension'
            for e = 2 : numInstance
                new = [];
                v = videos(e).data;
                for j = 1 : numJoint
                    for i = 1 : 3
                        dim = ref(j,:,i);
                        tmp = [v(j,:,i)];
                        [w, n] = DTW(tmp', dim');
%                         figure;
%                         plot(n);hold on;plot(dim, 'r'); plot(tmp, 'g');
%                         new =[new; dim];
                        new = [new; n'];
                    end
                end
                result = [result, new];
            end
            
        case 'joint'
            for e = 2 : numInstance
                new = [];
                v = videos(e).data;
                for j = 1 : numJoint
                        dim = ref(j,:,:);
                        tmp = [v(j,:,:)];
                        [w, n] = DTW(tmp', dim');                       
                        new = [new; n'];                    
                end
                result = [result, new];
            end
    end
    
end

