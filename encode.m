function [file, M, loglikelihood] = encode(inData, filename, mode, nbStates, numFrame, DR)
    fprintf('\nEncoding...\n');
    file = [];
%     plotRawData(inData);
    switch mode
        %% Individual & batch modes    
        case {'indiv' , 'batch'}
            for i = 1 : size(inData,2)    
                fprintf('\tAction %d \n', inData(i).action);
                data = inData(i).data;
                [row, M(i), expData] = encodeGMM(data, inData(i).action, nbStates, numFrame, DR);  

%                 tmp = expData(2:end,:);
%                 non = zeros(1, size(tmp, 2));
%                 regData(i).action = inData(i).action;        
%                 regData(i).data = [tmp(1:4,:); [non;non]; tmp(5:8,:); [non;non;non]; tmp(9:11,:);[non;non;non];tmp(12:14,:);[non;non]]';
                row = [inData(i).action, row];
                file = [file; row];
            end
            fprintf('\t>>>Total instances %d\n\t\nSaving... %s.mat\n', size(inData,2), filename);
            save([filename,'.mat'], 'file');
%             save('regData.mat', 'regData');
        %% Incremental        
        %  new version: train each joint angle independently. 
        %  model matrix: numVideos*numFeature(numJoint)
        case 'incremental'
%             for i = 1 : inData(end).action
            for i = 13
                fprintf('\tAction %d \n', i);        
                [gmms, loglik,tmptime, expData] = encodeGMM_incremental(inData(i).data);
                M(i,:) = gmms;   
                loglikelihood(i).data = loglik;
                save(['loglik',int2str(i),'.mat'], 'loglik');
                save('M.mat', 'M');   
                save(['expData', int2str(i)], 'expData');
                runningtime(i).time=tmptime;
                for ins = 1 : size(gmms(1).model,2)
                    row = i;
                    for fea = 1 : size(gmms, 2)
                        tmp=gmms(fea).model(ins).Mu;
                        % if return Mu only, sorted Mu
                        [Y,I]=sort(tmp(1,:));
                        B=tmp(:,I);
                        % remove time stamp
    %                   B = B(2:end, :);
                        tmp2 = reshape(B, [1, numel(B)]);    
                        row = [row, tmp2];
                    end
                    file = [file; row];
                end    
            end
            save('runningtime.mat','runningtime');
        case 'incremental_test'
            for i = 1 : size(inData,2)    
                fprintf('\tAction %d \n', inData(i).action);                
                [gmms, loglik] = encodeGMM_incremental(inData(i).data);
                M(i,:) = gmms;
                loglikelihood(i).data = loglik;
                save(['loglik',int2str(i),'.mat'], 'loglik');
                save('M.mat', 'M');         

                for ins = 1 : size(gmms(1).model,2)
                    row = inData(i).action;
                    for fea = 1 : size(gmms, 2)
                        tmp=gmms(fea).model(ins).Mu;
                        % if return Mu only, sorted Mu
                        [Y,I]=sort(tmp(1,:));
                        B=tmp(:,I);
                        % remove time stamp
    %                   B = B(2:end, :);
                        tmp2 = reshape(B, [1, numel(B)]);    
                        row = [row, tmp2];
                    end
                    file = [file; row];
                end    
            end
    end
   
%     fprintf('\t>>>Total instances %d\n\t\nSaving... %s.mat\n', size(inData,2), filename);
%     save([filename,'.mat'], 'file');
end

