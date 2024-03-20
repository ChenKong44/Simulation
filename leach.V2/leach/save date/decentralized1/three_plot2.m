
%     theta_old = theta(index);
xmin=0.05;  %minimum moisture lv
xmax=0.25;   %max moisture lv
n=20;
x=xmin+rand(1,n)*(xmax-xmin);

% theta = x(randi([1,n]));
theta = 0.1179;

%     fprintf('theta is: %d\n',theta(index));

max_clustersize = 50;
interference = 1;
density1=4.5;
coverage = 4;

syms z

intraclustermembers = sqrt(20./4./(density1));
underground_cluster = sqrt(z./4./(density1)).*0.05;
aboveground_cluster = sqrt(z./4./(density1)).*0.95;
basedistance =  sqrt(40./4./(density1))+sqrt(39./4./(density1)) ;

addpath 'soil equations'
[bitrate,Energy_transit_b,Energy_transit_cm,Energy_transit_cm_cm] = transmissionpower(basedistance,underground_cluster, aboveground_cluster,intraclustermembers,theta,868);

% Energy_transfer_ch1= (10.^((abs(Energy_transit_b)+z)./10).*1e-3)*0.0000001;
% Energy_transfer_cm1 = (10.^((abs(Energy_transit_cm)+z)./10).*1e-3)*0.0000001;

Energy_transfer_ch= (10.^(Energy_transit_b./10).*1e-3)*0.0000001;
Energy_transfer_cm = (10.^(Energy_transit_cm./10).*1e-3)*0.0000001;
Energy_transfer_intracms = (10.^(Energy_transit_cm_cm./10).*1e-3)*0.0000001;
Energy_receive = 50*0.000000001;

brmax = bitrate;
ctrPacketLength = 32.*8; %12-256 bytes
packetLength = 32.*8;

Energy_init = 50;
    


% PL(x) = (((0.5.*1e3./x)./(1.024)-8-4.25)./(4 + 4./5).*(7-2).*4+20-16-28+4.*7);
% PL_diff(x) = diff(PL(x));
% br = (125.*1e3 ./ (2.^7)) .* (4 ./ (4 + 4./5));

L_expect(z) = (  (z-1).*(Energy_receive+Energy_transfer_cm).* packetLength ./ brmax + (max_clustersize-z ) .*(Energy_transfer_intracms).* packetLength ./ brmax+...
        ctrPacketLength.*(Energy_transfer_ch+Energy_receive)./ ( brmax));
% EE_expect1(z) = (brmax.*log(1+(Energy_transfer_cm1./L_path_cm)).*16.*31.46)./(15.*(Energy_receive+Energy_transfer_ch1).* 31.46 +31.46.*(Energy_transfer_cm1+Energy_receive));
% 
% 
% EE_result = subs(EE_expect1(z),z,z_spare2_ori);
% EE_result1 = subs(EE_expect1(z),z,z_spare3);
% EE_result2 = subs(EE_expect1(z),z,z_spare4);

transmission(z) = (z.*brmax.*0.03932)./L_expect(z);

L_result = subs(L_expect(z),z,z_spare2_ori);
L_result1 = subs(L_expect(z),z,z_spare22);
L_result2 = subs(L_expect(z),z,z_spare4);

EE_result = subs(transmission(z),z,z_spare2_ori);
EE_result1 = subs(transmission(z),z,z_spare22);
EE_result2 = subs(transmission(z),z,z_spare4);

% syms a b
% h_constraint(a,b) = 3./2.*(sqrt(a./4./(density1))+sqrt(b./4./(density1)))-coverage;
% h_result = subs(h_constraint,{a,b},{round(z_spare2_100),z_spare2_100});
% h_result1 = subs(h_constraint,{a,b},{round(z_spare2_50),z_spare2_50});
% h_result2 = subs(h_constraint,{a,b},{round(z_spare2_25),z_spare2_25});

 
z=1:1:1000;
x2=1:1:3000;

subplot(1,3,1);
plot(z, z_spare2_ori, 'k-', 'LineWidth', 2); % Plot fitted line.

hold on;
plot(x2, z_spare22, 'k:', 'LineWidth', 2);

hold on;
plot(x3, z_spare3, 'k--', 'LineWidth', 2); % Plot fitted line.

grid on;

legend('ADSGT','SGD','DSGT')
    
% Create xlabel
xlabel('Number of Iteration','FontWeight','bold','FontSize',11,'FontName','Cambria');
xlim([0 800])

% Create ylabel
ylabel('Transmission Power','FontWeight','bold','FontSize',11,...
    'FontName','Cambria');
ylim([15 65])

title('Transmission Power vs. Iteration#','FontWeight','bold','FontSize',12,...
            'FontName','Cambria');


subplot(1,3,2)

plot(z, L_result, 'k-', 'LineWidth', 2); % Plot fitted line.

hold on;
plot(x2, L_result1, 'k:', 'LineWidth', 2);

hold on;
plot(x4, L_result2, 'k--', 'LineWidth', 2); % Plot fitted line.

grid on;

legend('ADSGT','SGD','DSGT')

xlabel('Number of Iteration','FontWeight','bold','FontSize',11,'FontName','Cambria');
xlim([0 800])

% Create ylabel
ylabel('Energy Cost','FontWeight','bold','FontSize',11,...
    'FontName','Cambria');
ylim([0 90])

title('Energy Cost vs. Iteration#','FontWeight','bold','FontSize',12,...
            'FontName','Cambria');



subplot(1,3,3)
plot(z, EE_result, 'k-', 'LineWidth', 2); % Plot fitted line.

hold on;
plot(x2, EE_result1, 'k:', 'LineWidth', 2);

hold on;
plot(x4, EE_result2, 'k--', 'LineWidth', 2); % Plot fitted line.

grid on;
% legend('SSGD','SGD,low moisture','SGD,high moisture')
% Create xlabel
legend('ADSGT','SGD','DSGT')

xlabel('Number of Iteration','FontWeight','bold','FontSize',11,'FontName','Cambria');
xlim([0 800])

% Create ylabel
ylabel('Energy Efficiency','FontWeight','bold','FontSize',11,...
    'FontName','Cambria');
ylim([-30 120])

title('Energy Efficiency vs. Iteration#','FontWeight','bold','FontSize',12,...
            'FontName','Cambria');


% 
% hold on;
% plot(x, z_spare2_01, 'k-', 'LineWidth', 2); % Plot fitted line.

% hold on;
% plot(x_m3, z_spare3_m3, 'g-', 'LineWidth', 2); % Plot fitted line.
% % 
% hold on; % Set hold on so the next plot does not blow away the one we just drew.
% plot(x, z_spare2_25, 'b-', 'LineWidth', 2); % Plot fitted line.

