function [target] = cal_distance(target, index)
    if (index==1 && target(index)==2) || (index==2 && target(index)==1) || (index==3 && target(index)==4) || (index==4 && target(index)==3)
        target(1) = 3;
        target(3) = 1;
        target(2) = 4;
        target(4) = 2;
    else
        target(1) = 2;
        target(2) = 1;
        target(3) = 4;
        target(4) = 3;
    end
end