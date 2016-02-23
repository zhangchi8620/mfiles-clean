function addLabel(file, mode)   
%     save([mode,'.mat'], 'file');
    i = 1;
    count = 1;
    fileSize = size(file, 2);
    while count < fileSize
        ins = repmat(count, size(file,1), 1);
        file = [file(:,1:i), ins, file(:,i+1:end)];
        i = i + 2;
        count = count + 1;
    end

    A = file;
    fileID = fopen([mode, '.txt'],'w+');

    for row = 1 : size(A,1)
        for col = 1 : size(A,2)
            if col == 1
               fprintf(fileID,'%d ',A(row, col));
            elseif mod(col,2) == 0
                fprintf(fileID,'%d:',A(row, col));
            else
                if col ~= size(A,2)
                    fprintf(fileID,'%1.6f ',A(row, col));
                else
                    fprintf(fileID,'%1.6f',A(row, col));
                end                
            end
        end
        fprintf(fileID,'\n');
    end
    fclose(fileID);

    fprintf('Saving... %s.txt\n', mode);
end
