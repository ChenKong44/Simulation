

%     theta_old = theta(index);
xmin=0.35;  %minimum moisture lv
xmax=0.55;   %max moisture lv
n=20;
x=xmin+rand(1,n)*(xmax-xmin);

theta = x(randi([1,n]));

%     fprintf('theta is: %d\n',theta(index));

max_clustersize = 50;
interference = 1;
density1=4;

syms x

intraclustermembers = sqrt(20./4./(density1));
underground_cluster = sqrt(x./4./(density1)).*0.05;
aboveground_cluster = sqrt(x./4./(density1)).*0.95;
basedistance =  sqrt(21./4./(density1))+sqrt(18./4./(density1)) ;

addpath 'soil equations'
[bitrate,Energy_transit_b,Energy_transit_cm,Energy_transit_cm_cm] = transmissionpower(basedistance,underground_cluster, aboveground_cluster,intraclustermembers,theta,868);

Energy_transfer_ch= (10.^(Energy_transit_b./10).*1e-3)*0.0000001;
Energy_transfer_cm = (10.^(Energy_transit_cm./10).*1e-3)*0.0000001;
Energy_transfer_intracms = (10.^(Energy_transit_cm_cm./10).*1e-3)*0.0000001;
Energy_receive = 50*0.000000001;
energy_system = 50*0.0000001;

brmax = bitrate;
ctrPacketLength = 32.*8; %12-256 bytes
packetLength = 32.*8;

Energy_init = 50;
    


% PL(x) = (((0.5.*1e3./x)./(1.024)-8-4.25)./(4 + 4./5).*(7-2).*4+20-16-28+4.*7);
% PL_diff(x) = diff(PL(x));
% br = (125.*1e3 ./ (2.^7)) .* (4 ./ (4 + 4./5));

L_expect(x) = (  (x-1).*(Energy_receive+Energy_transfer_cm).* packetLength ./ brmax + (max_clustersize-x ) .*(Energy_transfer_intracms).* packetLength ./ brmax+...
        ctrPacketLength.*(Energy_transfer_ch+Energy_receive)./ ( brmax));
L_expectdiff(x) = diff(L_expect(x));

x=2:1:50;

plot(x,L_expect(x),'b-',x,L_expectdiff(x),'r-');

xlabel('Cluster size','FontWeight','bold','FontSize',11,'FontName','Cambria');
        
% Create ylabel
ylabel('Expect lifetime','FontWeight','bold','FontSize',11,...
    'FontName','Cambria');

% Create title
title('Expect lifetime vs. Number of cluster members','FontWeight','bold','FontSize',12,...
    'FontName','Cambria');
