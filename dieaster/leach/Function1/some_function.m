function [z, lamda, target, theta,L_result,H_result] = some_function(index, target, iteration, z, lamda, theta,L_result,H_result,aboveground_prob)
    step_size = 0.8;
    
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


% ---------------------------------------------
%frequency:GHz,temper:℃;distance:Km;humidity:percentage;energy:dbm;power:W
% ---------------------------------------------

    syms x
    intraclustermembers = 2;
    aboveground_cluster = 5;
    basedistance =  30 ;

%     addpath 'soil equations'
    [bitrate,Energy_transit_b,Energy_transit_cm,Energy_transit_cm_cm] = transmissionpower(basedistance, aboveground_cluster,intraclustermembers,theta(index),868.*1e-3,35);

    Energy_transfer_ch= (10.^((Energy_transit_b+x)./10).*1e-3);
    Energy_transfer_cm = (10.^((Energy_transit_cm+x)./10).*1e-3);
%     Energy_transfer_intracms = (10.^((Energy_transit_cm_cm+x)./10).*1e-3);
    Energy_receive = (10.^(20./10).*1e-3);

    brmax = bitrate;
    
    if abs(theta(index) - theta(target(index))) < 0.003 %rssi determination
        fprintf('change node \n')

        target = cal_distance(target, index);

        if target(index) == 0
            return
        end

% -----------------------------------
% time of one transfer: 0.3146
% ------------------------------------

    
        L_expect(x) = (brmax.*31.46)./(9.*(Energy_receive+Energy_transfer_cm).* 31.46 +31.46.*(Energy_transfer_ch+Energy_receive));
        L_expectdiff = diff(L_expect(x));
        L_gradient1 = subs(L_expectdiff,x,z(index));
        L_gradient1 = double(L_gradient1);
        laplase = L_gradient1;
        z_new = z(index) - step_size * laplase;

    else
        z_new = double(z(index));
    end

    
    syms x
    L_expect(x) = (brmax.*31.46)./(9.*(Energy_receive+Energy_transfer_cm).* 31.46 +31.46.*(Energy_transfer_ch+Energy_receive));
    L_result(index) = double(subs(L_expect,x,z(index)));
    L_expectdiff(x) = diff(L_expect(x));
    L_gradient1 = subs(L_expectdiff,x,z_new);
    L_gradient1 = double(L_gradient1);

    

    laplase = L_gradient1;
    z(index) = z_new - step_size .* laplase;

end
