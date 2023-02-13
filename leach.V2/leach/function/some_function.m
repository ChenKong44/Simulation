function [z, lamda, target] = some_function(index, target, iteration, z, lamda, theta)
    step_size = 0.01;
    delta = 1e-4;

    if target(index) == 0
        return
    end

%     theta_old = theta(index);
    theta(index) = rand();
    Energy_init = 0.5; 
    Energy_transfer = 50*0.000000001;
    Energy_receive = 50*0.000000001;

    bitrate = 6;
    ctrPacketLength = 200;
    packetLength = 500;
    if abs(theta(index) - theta(target(index))) < 0.5 %rssi determination
        if index == 1
            target(1) = 3;
        elseif index == 2
            target(2) = 0;
        else
            target(1) = 2;
            target(2) = 1;
        end

%         addpath soil equations
        


        syms x
        L_expect(x) = Energy_init ./ ( ( (x-1)./ x ) .*(Energy_receive+Energy_transfer).* packetLength ./ bitrate+...
            ctrPacketLength.*Energy_transfer./ ( x.* bitrate ) );
        L_expectdiff = diff(L_expect(x));
        L_gradient1 = subs(L_expectdiff,x,z(index));

%         y = z(index) + theta(index);        %expect life time
%         grad1 = gradient(y);                % check gradient function 
%         g = z(index) + z(target(index)) + theta(index) + theta(target(index));
        grad2 = 0.7;                % check gradient function 
%         laplase = grad1 + (lamda(index,target(index)) + lamda(target(index),index)) * grad2;


        laplase = L_gradient1 + (lamda(index,target(index)) + lamda(target(index),index)) * grad2;
        z_new = z(index) - step_size * laplase;
        z_new = min(max(z_new,0),20);
    else
        z_new = double(z(index));
    end
    z_new = 1/iteration * z(index) + (iteration-1)/iteration*z_new;
    
    syms x
    L_expect(x) = Energy_init ./ ( ( (x-1)./ x ) .*(Energy_receive+Energy_transfer).* packetLength ./ bitrate+...
        ctrPacketLength.*Energy_transfer./ ( x.* bitrate ) );
    L_expectdiff = diff(L_expect(x));
    L_gradient1 = subs(L_expectdiff,x,z_new);
%     y = z_new + theta(index);
%     grad1 = gradient(y);                % check gradient function 
%     g = z_new + z(target(index)) + theta(index) + theta(target(index));
    grad2 = 0.3;                % check gradient function 
    laplase = L_gradient1 + (lamda(index,target(index)) + lamda(target(index),index)) * grad2;
    z(index) = z_new - step_size * laplase;
    z(index) = round(min(max(z(index),0),50));

    h = 0.05;
    lamda(index, target(index)) = max((1-step_size^2 * delta)*lamda(index, target(index))+step_size * h, 0);
end
