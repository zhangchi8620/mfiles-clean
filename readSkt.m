%USAGE: drawskt(1,3,1,4,1,2) --- show actions 1,2,3 performed by subjects 1,2,3,4 with instances 1 and 2.
% data: # joints * # frame * 3
function data=readSkt(a, s, e, path)
    B=[];
    file=sprintf([path, '/a%02i_s%02i_e%02i_skeleton_proj.txt'],a,s,e);
    fp=fopen(file);
    if (fp>0)
       A=fscanf(fp,'%f');
       B=[B; A];
       fclose(fp);
    end
    l=size(B,1)/5;
    B=reshape(B,5,l);
    B=B';
    A=B;
    B=reshape(B,20,l/20,5);

    X=B(:,:,3);
    Z=B(:,:,4);
    Y=B(:,:,5)/4;
    %P=B(:,:,4);
    % B(:,:,5) = B(:,:,5)/4;
    % data = B(:,:,3:5);

    data(:,:,1) = X;
    data(:,:,2) = Y;
    data(:,:,3) = Z;     
end