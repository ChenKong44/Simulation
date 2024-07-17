z1 = 3;
z2 = 3;
lamuda1 = 0.7;
lamuda2 = 0.7;

step_size = 0.06;
delta = 1e-1;

Energy_transfer_ch= 0.2238*1e1;
Energy_transfer_cm = 0.144*1e1;
Energy_receive = 5*0.000000001;
energy_system = 5*0.0000001;

max_clustersize = 50;
interference = 1;
density1=4.5;

ctrPacketLength = 32.*8; %12-256 bytes
packetLength = 32.*8;

Energy_init = 0.5;

syms x
term1(x) = -0.5 * log(2 * pi^2 * x^2);
term2(x) = -((43 - 15)^2) / (2 * x^2);
L_expect(x) = term1(x) + term2(x);
L_expectdiff(x) = diff(L_expect(x));

    
syms x b
h_constraint(x,b) = 1./2.*(sqrt(x./(density1))+sqrt(b./(density1)))-1.5;
h_constraintdiff(x) = abs(diff(h_constraint(x,b),x));
h_gradient(x) = subs(h_constraintdiff,{z1},{z2});

laplase(x) = L_expectdiff(x) + (lamuda1+lamuda2) * h_gradient(x);


x=2:1:100;

subplot(3,1,1);
plot(x,h_constraintdiff(x));
xlabel('Cluster size','FontWeight','bold','FontSize',11,'FontName','Cambria');
        
% Create ylabel
ylabel('Gradient','FontWeight','bold','FontSize',11,...
    'FontName','Cambria');

% Create title
title('Constrain gradient vs. Number of cluster members','FontWeight','bold','FontSize',12,...
    'FontName','Cambria');

subplot(3,1,2);
plot(x,L_expectdiff(x));

xlabel('Cluster size','FontWeight','bold','FontSize',11,'FontName','Cambria');
        
% Create ylabel
ylabel('Gradient of Expect lifetime','FontWeight','bold','FontSize',11,...
    'FontName','Cambria');

% Create title
title('Gradient of Expect lifetime vs. Number of cluster members','FontWeight','bold','FontSize',12,...
    'FontName','Cambria');

subplot(3,1,3);
plot(x,laplase(x));

xlabel('Cluster size','FontWeight','bold','FontSize',11,'FontName','Cambria');
        
% Create ylabel
ylabel('Laplase','FontWeight','bold','FontSize',11,...
    'FontName','Cambria');

% Create title
title('Laplase vs. Number of cluster members','FontWeight','bold','FontSize',12,...
    'FontName','Cambria');
