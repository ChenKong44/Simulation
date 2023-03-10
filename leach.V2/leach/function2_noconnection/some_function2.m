function [z, lamda, target, theta,L_result,iteration_delay,z_spare2] = some_function2(index, target, iteration, z, lamda, theta,L_result,iteration_delay,z_spare2)
    step_size = 0.065;
    delta = 1e-1;
    
    if target(index) == 0
        return
    end
    
    
%     theta_old = theta(index);
    xmin=0.05;  %minimum moisture lv
    xmax=0.25;   %max moisture lv
    n=20;
    x=xmin+rand(1,n)*(xmax-xmin);

    if mod(iteration,10)==0
        theta(index) = x(randi([1,n]));
    end
%     abs(theta(index) - theta(target(index))) < 0.035
%     fprintf('theta is: %d\n',theta(index));

    max_clustersize = 50;
    interference = 1;
    density1=4.5;
    
    syms x
    intraclustermembers = sqrt(20./4./(density1));
    underground_cluster = sqrt(z(index)./4./(density1)).*0.05;
    aboveground_cluster = sqrt(z(index)./4./(density1)).*0.95;
    basedistance =  sqrt(z(index)./4./(density1))+sqrt(z(target(index))./4./(density1)) ;

    addpath 'soil equations'
    [bitrate,Energy_transit_b,Energy_transit_cm,Energy_transit_cm_cm] = transmissionpower(basedistance,underground_cluster, aboveground_cluster,intraclustermembers,theta(index),868);


    Energy_transfer_ch= (10.^(Energy_transit_b./10).*1e-3)*0.0000001;
    Energy_transfer_cm = (10.^(Energy_transit_cm./10).*1e-3)*0.0000001;
    Energy_transfer_intracms = (10.^(Energy_transit_cm_cm./10).*1e-3)*0.0000001;
    Energy_receive = 50*0.000000001;
%     energy_system = 50*0.0000001;

    brmax = bitrate;
    ctrPacketLength = 32.*8; %12-256 bytes
    packetLength = 32.*8;
    
    Energy_init = 0.5;

%     for t = 1:1:iteration
%         Energy_init = Energy_init-t.*( ( ((z(index)-1)./ z(index)) .*(Energy_receive+Energy_transfer) ).* packetLength ./ bitrate+...
%             ( ctrPacketLength.*Energy_transfer./ ( z(index).* bitrate ) )+ (energy_system./ z(index)) ); 
%     end    
%     fprintf('%d\n',Energy_init);

    
    if abs(theta(index) - theta(target(index))) < 0.003 %rssi determination
        fprintf('change node1 \n')
        
        if target(index) == 0
            return
        end

        z_tem = z(target(index));

        for t = 1:1:5
            syms x
            br = (x ./ (1 + interference .* (x - 1))) .* (125.*1e3 ./ (2.^7)) .* (4 ./ (4 + 4./5));
    %         L_expect(x) = (0.4.*x-6).^2+8;
            L_expect(x) = (  (x-1).*(Energy_receive+Energy_transfer_cm).* packetLength ./ brmax + (max_clustersize-x ) .*(Energy_transfer_intracms).* packetLength ./ brmax+...
            ctrPacketLength.*(Energy_transfer_ch+Energy_receive)./ ( brmax));
            L_result(index) = subs(L_expect,x,z(index));
            L_expectdiff = diff(L_expect(x));
            L_gradient1 = subs(L_expectdiff,x,z(index));
   
    
            syms a b
            h_constraint(a,b) = 3./2.*(sqrt(a./4./(density1))+sqrt(b./4./(density1)))-5;
            h_constraintdiff = abs(diff(h_constraint(a,b),a));
            h_gradient = subs(h_constraintdiff,{a,b},{z(index),z_tem});
            if h_gradient==0
                h_gradient = 0.0001;
            end
    
    
            laplase = L_gradient1 + (lamda(index,target(index)) + lamda(target(index),index)) * h_gradient;
            z_new = z(index) - step_size * laplase;
            z_new = min(max(z_new,0),max_clustersize);
            z_spare2=[z_spare2,round(z_new)];
        end 
        iteration_delay(index) = iteration_delay(index)+5;
        target = cal_distance(target, index);
        
    else
        z_new = double(z(index));
    end
   z_new = 1/iteration * z(index) + (iteration-1)/iteration*z_new;
    
%     br = (x ./ (1 + interference .* (x - 1))) .* (125.*1e3 ./ (2.^7)) .* (4 ./ (4 + 4./5));
    
    syms x
    L_expect(x) = (  (x-1).*(Energy_receive+Energy_transfer_cm).* packetLength ./ brmax + (max_clustersize-x ) .*(Energy_transfer_intracms).* packetLength ./ brmax+...
        ctrPacketLength.*(Energy_transfer_ch+Energy_receive)./ ( brmax));
    L_result(index) = subs(L_expect,x,z(index));
    L_expectdiff(x) = diff(L_expect(x));
    L_gradient1 = subs(L_expectdiff,x,z_new);
    L_gradient1 = double(L_gradient1);
    fprintf('L_result: %d\n',L_result(index));
    fprintf('L_gradient: %.5f\n',L_gradient1);

%     fprintf('expected lifetime: %d\n',L_result(index));
    

%     h_constraint(x) = 6.4 +20.*log(3.*sqrt(x./4./density1)./2 )+20.*log(theta(index))+13.035.*sqrt(x./4./density1);
%     h_result = subs(h_constraint,x,z(index));
%     h_constraintdiff = diff(h_constraint(x));
%     h_gradient = subs(h_constraintdiff,x,z(index));

    syms a b
    h_constraint(a,b) = 3./2.*(sqrt(a./4./(density1))+sqrt(b./4./(density1)))-4;
    h_result = subs(h_constraint,{a,b},{z(index),z(target(index))});
    H_result(index) = subs(h_constraint,{a,b},{z(index),z(target(index))});
    h_constraintdiff = diff(h_constraint(a,b),a);
    h_gradient = subs(h_constraintdiff,{a,b},{z(index),z(target(index))});

    if h_gradient==0
        h_gradient = 0.0001;
    end
% 
% 
%     fprintf('h_gradient: %.5f\n',h_gradient);
%     fprintf('h_result: %.5f\n',h_result);


%     y = z_new + theta(index);
%     grad1 = gradient(y);                % check gradient function 
%     g = z_new + z(target(index)) + theta(index) + theta(target(index));
%     grad2 = 0.3;                % check gradient function 
    

    laplase = L_gradient1 + (lamda(index,target(index))+lamda(target(index),index)) * h_gradient;
    z(index) = z_new - step_size .* laplase;
    fprintf('laplase: %.5f\n',laplase);
    z(index) = min(max(z(index),1),max_clustersize);

    lamda(index, target(index)) = max( (1-(step_size) .* delta).*lamda(index, target(index))+step_size * h_result, 0);
    fprintf('lamuda: %.5f\n',lamda(index, target(index)));
end
