function velocity = calVel(assembledData)


    for i = 1 : length(assembledData)
        x = assembledData(i).data;
        y = diff(x');
        velocity(i).data = y';
        velocity(i).action = assembledData(i).action;
    end

end