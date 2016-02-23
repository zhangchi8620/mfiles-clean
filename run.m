% mode: batch, indiv
% nbStates: 5, 10, 15, 20
% numFrame: 200
% DR: 0, 1
clc; clear;


%% training
mode = {'batch','indiv'};
nbStates = {5, 10, 20};
DR = {0, 1};
numFrame = 200;

for m = 1 : length(mode)
    for n = 1 : length(nbStates)
        for d = 1 : length(DR)
            newfolder = ['results/', mode{m}, '_', int2str(nbStates{n}), 'GMM_',int2str(DR{d}),'DR'];
%             if (exist(newfolder) == 0)                
                disp(['Creating...    ', newfolder]);
%             end
            mkdir(newfolder);
            main(mode{m}, nbStates{n}, numFrame, DR{d});
            movefile('train.mat', newfolder);    
            movefile('test.mat', newfolder);  
            movefile('*.txt', newfolder);
        end
    end
end


%% labeling
trainData = [];
testData = [];

% m = 2;
%     for n = 1 : 1
%         for d = 1 : length(DR)
%             foldername = ['results/', mode{m}, '_', int2str(nbStates{n}), 'GMM_',int2str(DR{d}),'DR']
%             trainFileName = [foldername, '/train.mat'];
%             load(trainFileName);
%             if ~isempty(trainData)                
%                 file = file(:,2:end);
%             end
%             
%             trainData = [trainData, file];
%                      
%             testFileName = [foldername, '/test.mat'];
%             load(testFileName);
%              if ~isempty(testData)                
%                 file = file(:,2:end);
%             end
%             testData = [testData, file];
%         end
%     end
% 
% addLabel(trainData,'train');
% addLabel(testData, 'test');