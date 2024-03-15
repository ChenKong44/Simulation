clc;
clear;

%     fprintf('theta is: %d\n',theta(index));

max_clustersize = 30;
density1=0.6;
density2 = 0.8;

xmin=0.05;  %minimum moisture lv
xmax=0.25;   %max moisture lv
n=20;
x=xmin+rand(1,n)*(xmax-xmin);
theta = x(randi([1,n]));


Energy_transfer = 50*0.00000001;
Energy_receive = 50*0.00000001;
energy_system = 50*0.00000001;

br_max = 5.468.*1e3;

ctrPacketLength = 51.*8;
packetLength = 51.*8;

Energy_init = 0.5;


x=1:1:300;
z=1:1:299;

sym x
% L_expect(x) = (0.4.*x-6).^2+8;
br = (x ./ (1 + 1.* (x - 1))) .* (125 ./ (2.^7)) .* (4 ./ (4 + 4./5));
energycost(x) = ( ( (x) ) .*(Energy_receive+Energy_transfer+energy_system).* ctrPacketLength ./ br(x)+...
    packetLength.*(Energy_transfer+energy_system)./ ( br_max ));
L_expect(x) = (Energy_init) ./ energycost(x);
L_expectdiff = diff(energycost(x));

h_expect(x) = 1./( 6.4 +20.*log(3.*sqrt(x./4./density1)./2 )+20.*log(theta)+13.035.*sqrt(x./4./density1) );
h_expectdiff = diff(h_expect(x));
% L_gradient1 = subs(L_expectdiff,x,z);

subplot(2,1,1);
plot(z,h_expectdiff);
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
ylabel('main function','FontWeight','bold','FontSize',11,...
    'FontName','Cambria');

% Create title
title('main function','FontWeight','bold','FontSize',12,...
    'FontName','Cambria');
