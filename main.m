function main(mode, nbStates, numFrame, DR)


% delete('*.mat');
% delete('*.txt');
% delete('train.mat');
% delete('test.mat');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Step1: Transform human's joint positions (20D) to NAO's joint angles (14D).
% Step2: Encode joint angles in GMM incrementally.
% Step3: SVM classificaiton.
% Step4: GMR regression.

%% Configurations    
% Assemble dataset (within one action): 
%   1) combine instances from one subject
%   2) no combination, treat each instance independently

% Align:  
%   1) Resize; 
%   2) DTW: each dimension VS each joint

% Encode feature
%   1) GMM;    
%   2) GMM-DR
%   3) GMM-incremental
%   4) No encoding (for LL classification)
%   ==> Mu_Train (1~3 Assemble), Mu_Test (1~3 Assemble)
%   ==> Model_Train (1~3 Assemble), Raw_Test (4 Assemble)  

% Classify
%   1) SVM: Mu_Train vs. Mu_Test
%   2) Loglikelihood:  Model_Train vs. Raw_Test

    path = '../dataset_full_modified/';
    write2txt(nbStates, numFrame, DR);   % write configuration to file
    
    filenames = {'train', 'test'};
    for f = 1 : length(filenames);
        filetype = filenames{f};
        disp([filetype, ' data in ', mode, ' mode']);
        assembledDataName = ['assembled_',filetype,'_', mode, '.mat'];
        if (exist(assembledDataName) ~= 0)
            load(assembledDataName);
        else
            if strcmp(filetype, 'test') % if test files, always assemble in resizeOnly
                assembledData = assemble(1,16,7,10,1,2, [path,filetype], 'resizeOnly', numFrame);
            else
                assembledData = assemble(1,16,1,6,1,2, [path,filetype], mode, numFrame);
            end
            save(assembledDataName, 'assembledData');
        end

%         velData = calVel(assembledData);
        file = encode(assembledData, filetype, mode, nbStates, numFrame, DR);         
%         file = encode(velData, filetype, mode, nbStates, numFrame, DR);         

    end

%% Case 1 (Baseline, batch): Combine instances from one sub in Train and Test
    % Assemble 1 (combine instances from one subject) for both Train and Test 
    % Encode with DTW, GMM/GMM-DR ==> Mu_Train, Mu_Test
    % Classify with SVM (Mu_Train vs. Mu_Test)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Case 3 (incremental): Add classified test data to train new models
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%`%%%%%%%%%%%%%%%%%%%%%%%%%
%     disp('incremental');
%     if (exist('trainIncremental.mat') ~= 0)
%         load('trainIncremental.mat');
%     else
%         trainData = assemble(1,16,1,6,1,4, [path,'train'], 'incremental', 0, jointMode);
%         save('trainIncremental.mat', 'trainData');
%     end    
%     file = encode(trainData,'train', 'incremental'); 
%     addLabel(file, 'train');
% 
%     if (exist('testIncremental.mat') ~= 0)
%         load('testIncremental.mat');
%     else
%         testData = assemble(1,16,7,10,1,4, [path,'test'], 'no_comb', 0, jointMode);
%         save('testIncremental.mat', 'testData');
%     end
%     file = encode(testData,'test'); 
%     addLabel(file, 'test');
        
    
%     
%     load('file.mat');
%     rate = 0;
%     for ins = 1 : 128
%     for act = 1 : 16       
%         for row = 1:30
%             for col = 1:2
% %                 fprintf('action %d, feature %d\t, model %d\n',act, row, col);
%                 m = file(act).model(row, col);
%                 time = [1:numFrame];
%                 inData = [time; testData(ins).data(row,:)];
%                 result2(row, col, act) = calLoglik(inData, m.Priors,m.Mu,m.Sigma,m.Pix);                
%             end
%             result(row, act) = max(result2(row, :, act));
%         end              
%     end
%     
%     for i = 1 : 30
%         x=result(i,:);
%         y(i)=find(x==max(x));
%     end
%     if (testData(ins).action == mode(y))
%         rate = rate + 1;
%     end
%     fprintf('truth %d, classification %d\n',testData(ins).action, mode(y));
%     
%     
%     end
%     rate / 40
%     for i = 1 : 5
%         x = result(:,:,i);
%         [v,ind]=max(x(:));
%         [y,x] = ind2sub(size(x),ind);
%         disp(sprintf('The largest element in this matrix is %f at (%d,%d).', v, y, x ));
%         loglik(i) = v;
%     end
%     if (testData(ins).action == (find(loglik==max(loglik))))
%         rate = rate + 1;
%     end
%     fprintf('truth %d, classification %d\n',testData(ins).action,  find(loglik==max(loglik)));
%     end
%     rate / 40
%     maxIdx = find(result == max(result))
%         maxVal = max(result)
%         rr(act) = maxVal;
%         fprintf('action %d, loglik %f, maxIdx %d\n',act, maxVal,maxIdx);  
%         
% find(rr == max(rr))        
%     file = encode(testData, 'test');
%     addLabel(file, 'test');
%     movefile('*.txt', ['result/incremTrain_incremTest/', int2str(idx), '/']);
end