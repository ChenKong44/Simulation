clc;
clear;

%     fprintf('theta is: %d\n',theta(index));

max_clustersize = 30;
density1=0.6;
density2 = 0.8;


Energy_transfer = 50*0.00000001;
Energy_receive = 50*0.00000001;
energy_system = 50*0.00000001;

br_max = 5.468.*1e3;

ctrPacketLength = 51.*8;
packetLength = 51.*8;

Energy_init = 0.5;


x=1:1:100;
z=1:1:99;

sym x
% L_expect(x) = (0.4.*x-6).^2+8;
br = (x ./ (1 + 2 .* (x - 1))) .* (125000 ./ (2.^7)) .* (4 ./ (4 + 4./5));
dutycycle = 4844.7./packetLength./br;
energycost(x) = ( ( (x-1)./x ) .*(Energy_receive+Energy_transfer+energy_system).* ctrPacketLength ./ br+...
    packetLength.*(Energy_transfer+energy_system)./ ( br_max ) );
L_expect(x) = (Energy_init.*dutycycle) ./ energycost;
L_expectdiff = diff(energycost(x));
% L_gradient1 = subs(L_expectdiff,x,z);

subplot(2,1,1);
plot(z,L_expectdiff);
xlabel('cluster size','FontWeight','bold','FontSize',11,'FontName','Cambria');
        
% Create ylabel
ylabel('Gradient','FontWeight','bold','FontSize',11,...
    'FontName','Cambria');

% Create title
title('Gradient','FontWeight','bold','FontSize',12,...
    'FontName','Cambria');

subplot(2,1,2)
plot(x,energycost)
xlabel('cluster size','FontWeight','bold','FontSize',11,'FontName','Cambria');
        
% Create ylabel
ylabel('Expect lifetime','FontWeight','bold','FontSize',11,...
    'FontName','Cambria');

% Create title
title('Expectlifetime','FontWeight','bold','FontSize',12,...
    'FontName','Cambria');
