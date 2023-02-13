function [z, lamda, target, theta] = some_function(index, target, iteration, z, lamda, theta)
    step_size = 0.01;
    delta = 1e-1;

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
    if abs(theta(index) - theta(target(index))) < 0.01 %rssi determination
        fprintf('change node')
        if index == 1 || index == 2
            target(1) = 3;
            target(2) = 0;
            target(3) = 1;
        end

%         addpath soil equations
        
        fprintf('%d\n',z(target(index)));

        syms x
        L_expect(x) = Energy_init ./ ( ( (x-1)./ x ) .*(Energy_receive+Energy_transfer).* packetLength ./ bitrate+...
            ctrPacketLength.*Energy_transfer./ ( x.* bitrate ) );
        L_expectdiff = diff(L_expect(x));
        L_gradient1 = subs(L_expectdiff,x,z(index));

        

%         h_constraint(x) = 6.4 +20.*log(3.*sqrt(x./4./density)./2 )+20.*log(theta(index))+13.035.*sqrt(x./4./density);
        syms a b
        h_constraint(a,b) = 3./2.*abs(sqrt(a./4./(z(index)./50))-sqrt(b./4./z(target(index))));
        h_constraintdiff = abs(diff(h_constraint(a,b),a));
        h_gradient = subs(h_constraintdiff,{a,b},{z(index),z(target(index))});
%         y = z(index) + theta(index);        %expect life time
%         grad1 = gradient(y);                % check gradient function 
%         g = z(index) + z(target(index)) + theta(index) + theta(target(index));
%         grad2 = 0.7;                % check gradient function 
%         laplase = grad1 + (lamda(index,target(index)) + lamda(target(index),index)) * grad2;


        laplase = L_gradient1 + (lamda(index,target(index)) + lamda(target(index),index)) * h_gradient;
        z_new = z(index) - step_size * laplase;
        z_new = round(min(max(z_new,0),30));
    else
        z_new = double(z(index));
    end
    z_new = 1/iteration * z(index) + (iteration-1)/iteration*z_new;
    
    syms x
    L_expect(x) = Energy_init ./ ( ( (x-1)./ x ) .*(Energy_receive+Energy_transfer).* packetLength ./ bitrate+...
        ctrPacketLength.*Energy_transfer./ ( x.* bitrate ) );
    L_expectdiff = diff(L_expect(x));
    L_gradient1 = subs(L_expectdiff,x,z_new);

    syms a b
    h_constraint(a,b) = 3./2.*abs(sqrt(a./4./(z(index)./50))-sqrt(b./4./z(target(index))));
    h_result = subs(h_constraint,{a,b},{z(index),z(target(index))});
    h_constraintdiff = abs(diff(h_constraint(a,b),a));
    h_gradient = subs(h_constraintdiff,{a,b},{z(index),z(target(index))});


%     y = z_new + theta(index);
%     grad1 = gradient(y);                % check gradient function 
%     g = z_new + z(target(index)) + theta(index) + theta(target(index));
%     grad2 = 0.3;                % check gradient function 
    

    laplase = L_gradient1 + (lamda(index,target(index)) + lamda(target(index),index)) * h_gradient;
    z(index) = z_new - step_size * laplase;
    z(index) = round(min(max(z(index),0),30));

    lamda(index, target(index)) = max((1-step_size^2 * delta)*lamda(index, target(index))+step_size * h_result, 0);
end
