
load ('data/data1.mat');
newData = [];

T= 200;

app = zeros(3,T);
app(1,:) = [101:100+T];

for ins = 100 : 100: 300
    for row = 2 : 3
        
        slope = mean(gradient(Data(row, ins-10:ins)));

        for i = 1 : T
            app(row,i) = Data(row,ins) + i*slope + (rand*2-1)*slope*0.5;
        end
    
    end
    newData = [newData,Data(:,ins-99:ins), app];

end

save('appData.mat', 'newData');