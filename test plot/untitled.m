z1 = 28;
z2 = 32;
lamuda1 = 0.08;
lamuda2 = 0.09;

step_size = 0.06;
delta = 1e-1;

Energy_transfer_ch= 0.2238;
Energy_transfer_cm = 0.0244;
Energy_receive = 50*0.000000001;
energy_system = 50*0.0000001;

max_clustersize = 50;
interference = 1;
density1=4.5;



ctrPacketLength = 15.*8; %12-256 bytes
packetLength = 32.*8;

Energy_init = 0.5;
    
syms x
PL(x) = (((0.5.*1e3./x)./(1.024)-8-4.25)./(4 + 4./5).*(7-2).*4+20-16-28+4.*7);
PL_diff(x) = diff(PL(x));
br = (125.*1e3 ./ (2.^7)) .* (4 ./ (4 + 4./5));

L_expect(x) = Energy_init ./ ( ( (x-1) ) .*(Energy_receive+Energy_transfer_cm).* PL(x) ./ br+...
ctrPacketLength.*Energy_transfer_ch./ ( br) );
L_expectdiff(x) = diff(L_expect(x));

x=2:1:50;

plot(x,L_expect(x));

xlabel('Cluster size','FontWeight','bold','FontSize',11,'FontName','Cambria');
        
% Create ylabel
ylabel('Expect lifetime','FontWeight','bold','FontSize',11,...
    'FontName','Cambria');

% Create title
title('Expect lifetime vs. Number of cluster members','FontWeight','bold','FontSize',12,...
    'FontName','Cambria');
