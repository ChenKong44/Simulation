z1 = 3;
z2 = 4;
lamuda1 = 0.5;
lamuda2 = 0.5;

step_size = 0.06;
delta = 1e-1;

Energy_transfer_ch= 0.2238;
Energy_transfer_cm = 0.0244;
Energy_receive = 50*0.000000001;
energy_system = 50*0.0000001;

max_clustersize = 50;
interference = 1;
density1=4.5;

ctrPacketLength = 32.*8; %12-256 bytes
packetLength = 32.*8;

Energy_init = 0.5;
    
syms x b
h_constraint(x,b) = (1./2.*(sqrt(x)+sqrt(b))-sqrt(x))-1.5;
h_constraintdiff(x) = abs(diff(h_constraint(x,b),x));
h_gradient = subs(h_constraintdiff,{b},{z2});

x=2:1:100;

plot(x,h_constraintdiff(x));

xlabel('Cluster size','FontWeight','bold','FontSize',11,'FontName','Cambria');
        
% Create ylabel
ylabel('Gradient','FontWeight','bold','FontSize',11,...
    'FontName','Cambria');

% Create title
title('Constrain gradient vs. Number of cluster members','FontWeight','bold','FontSize',12,...
    'FontName','Cambria');

