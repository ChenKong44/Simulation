clc;
clear;
xmin=0.05;  %minimum moisture lv
xmax=0.25;   %max moisture lv
n=20;
x=xmin+rand(1,n)*(xmax-xmin);
%     fprintf('theta is: %d\n',theta(index));

max_clustersize = 30;
density1=0.6;
density2 = 0.8;


Energy_transfer = 50*0.000000001;
Energy_receive = 50*0.000000001;
energy_system = 50*0.0000001;

br = 5.468;
ctrPacketLength = 200;
packetLength = 700;

Energy_init = 0.5;


x=1:1:30;
z=1:1:29;

sym x
% L_expect(x) = (0.4.*x-6).^2+8;
L_expect(x) = Energy_init ./ ( ( (x-1)./ x ) .*(Energy_receive+Energy_transfer).* packetLength ./ br+...
    ctrPacketLength.*Energy_transfer./ ( x.* br ) );
L_expectdiff = diff(L_expect(x));
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
plot(x,L_expect)
xlabel('cluster size','FontWeight','bold','FontSize',11,'FontName','Cambria');
        
% Create ylabel
ylabel('Expect lifetime','FontWeight','bold','FontSize',11,...
    'FontName','Cambria');

% Create title
title('Expectlifetime','FontWeight','bold','FontSize',12,...
    'FontName','Cambria');
