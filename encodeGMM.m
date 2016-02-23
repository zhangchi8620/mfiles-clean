function [feature, M, expData] = encodeGMM(Data, action,nbStates, numFrame, DR)
    addpath('/Users/zhangchi8620/Codes/GMM_GMR_v2.0/GMM-GMR-v2.0/')

    numFrame = size(Data, 2);
    tmp = [1:numFrame];
    time = repmat(tmp, [1, size(Data,2)/numFrame]);
        
    % add time to Data    
%     Data = [time; Data];

    traindata.rightArm = Data(1:4,:);
    traindata.leftArm = Data(5:8,:);
    traindata.rightLeg = Data(9:11,:);
    traindata.leftLeg = Data(12:14,:);
%     traindata.wholebody = Data;
    
    fields = fieldnames(traindata);
    Mu=[];
    
    %         for indexJoint = 1: size(Data, 1)
    for i = 1:numel(fields)
        tmpdata = traindata.(fields{i});
        tmpdata = [time; tmpdata];
        if DR        
            [Priors, MuOneLimb, Sigma, expData, Pix] = GMM_DR(tmpdata, nbStates, numFrame);        
        else
            [Priors, MuOneLimb, Sigma, expData] = GMM(tmpdata, nbStates);
        end
            sortedMuOneJoint = sortByTime(MuOneLimb);
            sortedNoTime = sortedMuOneJoint(2:end,:);
            Mu = [Mu; sortedNoTime];
        
    end
        
%     M.Priors = Priors;
    M.Mu = Mu;
%     M.Sigma = Sigma;
%     M.Pix = Pix;
    
%     save(['data/M',int2str(idx),'.mat'], 'M');
%     [Y,I]=sort(Mu(1,:));
%     B=Mu(:,I);
%     B = B(2:end, :);
%     B = [[1:nbStates];B(2:end,:)];
    B = Mu;
    feature = reshape(B, [1, numel(B)]);
%     drawskt_combineJoints(expData);
%     drawskt_expData(expData, selJoint, refJoint);
%     save(['data/expData_',num2str(action), '_', num2str(subject), '.mat'], 'expData');

end

function sortedData  = sortByTime(Data)
        [Y,I]=sort(Data(1,:));
        sortedData = Data(:,I);
end