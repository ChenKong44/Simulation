

%     theta_old = theta(index);
xmin=0.05;  %minimum moisture lv
xmax=0.25;   %max moisture lv
n=20;
x=xmin+rand(1,n)*(xmax-xmin);

% theta = x(randi([1,n]));
theta = 0.175;

zmin=0.03;  %minimum moisture lv
zmax=0.06;   %max moisture lv
n=20;
z=zmin+rand(1,n)*(zmax-zmin);

underground_prob = z(randi([1,n]));


ymin=0.94;  %minimum moisture lv
ymax=0.97;   %max moisture lv
n=20;
y=ymin+rand(1,n)*(ymax-ymin);

aboveground_prob = 1-underground_prob;

%     fprintf('theta is: %d\n',theta(index));

max_clustersize = 50;
interference = 1;
density1=4.5;
coverage = 4;

syms z

intraclustermembers = sqrt(20./4./(density1));
underground_cluster = sqrt(z./4./(density1)).*0.054;
aboveground_cluster = sqrt(z./4./(density1)).*0.946;
basedistance =  sqrt(42./4./(density1))+sqrt(39./4./(density1)) ;

addpath 'soil equations'
[bitrate,Energy_transit_b,Energy_transit_cm,Energy_transit_cm_cm] = transmissionpower(basedistance,underground_cluster, aboveground_cluster,intraclustermembers,theta,868);

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
x=1:1:50;
L_expect(z) = (  (z-1).*(Energy_receive+Energy_transfer_cm).* packetLength ./ brmax + (max_clustersize-z ) .*(Energy_transfer_intracms).* packetLength ./ brmax+...
        ctrPacketLength.*(Energy_transfer_ch+Energy_receive)./ ( brmax));
L_result1 = double(subs(L_expect(z),z,x));
% L_result2 = double(subs(L_expect(z),z,z_spare22));
% L_result3 = double(subs(L_expect(z),z,z_spare23));

syms a b
h_constraint(a,b) = 3./2.*(sqrt(a./4./(density1))+sqrt(b./4./(density1)))-coverage;
% h_result = subs(h_constraint,{a,b},{round(z_spare2_001),z_spare2_001});
% h_result1 = subs(h_constraint,{a,b},{round(z_spare2_005),z_spare2_005});
% h_result2 = subs(h_constraint,{a,b},{round(z_spare2_01),z_spare2_01});


% z_spare=[];
% L_result=[];

% for t=1:1:3000
%     z_spare(t)=(z_spare2(t)+z_spare22(t)+z_spare23(t))./3;
%     L_result(t)=(L_result3(t)+L_result2(t)+L_result1(t))./3;
% end

plot(x,L_result1,'b-');
% hold on;
% plot(z, L_result, 'k:', 'LineWidth', 2); % Plot fitted line.

% b=1:1:50;
% L_result = subs(L_expect(z),z,b);
% plot(b, L_result, 'g-', 'LineWidth', 2); % Plot fitted line.

% hold on;
% plot(z, h_result1, 'r-', 'LineWidth', 2); % Plot fitted line.
% 
% hold on;
% plot(z, h_result2, 'b-', 'LineWidth', 2);
% % 
% % hold on;
% % plot(x, z_spare2_01, 'k-', 'LineWidth', 2); % Plot fitted line.
% 
% % hold on;
% % plot(x_m3, z_spare3_m3, 'g-', 'LineWidth', 2); % Plot fitted line.
% % % 
% % hold on; % Set hold on so the next plot does not blow away the one we just drew.
% % plot(x, z_spare2_25, 'b-', 'LineWidth', 2); % Plot fitted line.
% grid on;
% 
% legend('Step Size: 0.01','Step Size: 0.05','Step Size: 0.1')
%     
% % Create xlabel
% xlabel('Number of Iteration','FontWeight','bold','FontSize',11,'FontName','Cambria');
% xlim([0 1000])
% 
% % Create ylabel
% ylabel('Energy Cost','FontWeight','bold','FontSize',11,...
%     'FontName','Cambria');
% ylim([-20 20])
