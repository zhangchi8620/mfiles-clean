clc; clear;

mode = {'batch','indiv'};
nbStates = {5, 10,20};
DR = {0, 1};
numFrame = 200;

%% labeling
trainData = [];
testData = [];

for m = 2 : length(mode)
    txtFileName = ['results/', mode{m}];
    
    for n = 2 : 2%length(nbStates)
        for d = 1 : 1%length(DR)
            
            foldername = ['results/', mode{m}, '_', int2str(nbStates{n}), 'GMM_',int2str(DR{d}),'DR']
            trainFileName = [foldername, '/train.mat'];
            load(trainFileName);
            if ~isempty(trainData)                
                file = file(:,2:end);
            end
            
            trainData = [trainData, file];
                     
            testFileName = [foldername, '/test.mat'];
            load(testFileName);
             if ~isempty(testData)                
                file = file(:,2:end);
            end
            testData = [testData, file];
            
            txtFileName = [txtFileName,int2str(nbStates{n}),'-',int2str(DR{d}),'-']
        end
    end
end

addLabel(trainData,'train');
addLabel(testData, 'test');

% movefile('*.txt', txtFileName);