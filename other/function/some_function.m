function [z, lamda, target] = some_function(index, target, iteration, z, lamda, theta)
    step_size = 1;
    delta = 1;

    if target(index) == 0
        return
    end

%     theta_old = theta(index);
    theta(index) = rand();
    if abs(theta(index) - theta(target(index))) < 0
        if index == 1
            target(1) = 3;
        elseif index == 2
            target(2) = 0;
        else
            target(1) = 2;
            target(2) = 1;
        end
        y = z(index) + theta(index);
        grad1 = gradient(y);                % check gradient function 
        g = z(index) + z(target(index)) + theta(index) + theta(target(index));
        grad2 = gradient(g);                % check gradient function 
        laplase = grad1 + lamda(index,target(index)) * grad2;
        z_new = z(index) - step_size * laplase;
        z_new = min(max(z_new,0),20);
    else
        z_new = z(index);
    end
    z_new = 1/iteration * z(index) + (iteration-1)/iteration*z_new;
    
    y = z_new + theta(index);
    grad1 = gradient(y);                % check gradient function 
    g = z_new + z(target(index)) + theta(index) + theta(target(index));
    grad2 = gradient(g);                % check gradient function 
    laplase = grad1 + (lamda(index,target(index)) + lamda(target(index),index)) * grad2;
    z(index) = z_new - step_size * laplase;

    h = z(index) + z(target(index)) + theta(index) + theta(target(index));
    lamda(index, target(index)) = max((1-step_size^2 * delta)*lamda(index, target(index))+step_size * h, 0);
end
