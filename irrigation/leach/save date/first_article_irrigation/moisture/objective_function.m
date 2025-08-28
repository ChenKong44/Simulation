

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
coverage = 4.5;

syms z

intraclustermembers = sqrt(20./4./(density1));
underground_cluster = sqrt(z./4./(density1)).*0.05;
aboveground_cluster = sqrt(z./4./(density1)).*0.95;
basedistance =  sqrt(40./4./(density1))+sqrt(39./4./(density1)) ;

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

L_expect(z) = (  (z-1).*(Energy_receive+Energy_transfer_cm).* packetLength ./ brmax + (max_clustersize-z ) .*(Energy_transfer_intracms).* packetLength ./ brmax+...
        ctrPacketLength.*(Energy_transfer_ch+Energy_receive)./ ( brmax));
L_result = subs(L_expect(z),z,z_spare2_ori);
L_result1 = subs(L_expect(z),z,z_spare2_15);
L_result2 = subs(L_expect(z),z,z_spare2_45new);
L_result3 = subs(L_expect(z),z,z_spare2_55);


syms a b
h_constraint(a,b) = 3./2.*(sqrt(a./4./(density1))+sqrt(b./4./(density1)))-coverage;
h_result = subs(h_constraint,{a,b},{z_spare2_ori,z_spare_ori});
h_result1 = subs(h_constraint,{a,b},{z_spare2_15,z_spare_15});
h_result2 = subs(h_constraint,{a,b},{z_spare2_45new,z_spare_45new});
h_result3 = subs(h_constraint,{a,b},{z_spare2_55,z_spare_55});

 
z=1:1:3000;
x = 1:1:2000;

subplot(1,2,1);

plot(z, L_result, 'k-', 'LineWidth', 2); % Plot fitted line.

hold on;
plot(x, L_result1, 'k--', 'LineWidth', 2); % Plot fitted line.

hold on;
plot(z, L_result2, 'k:', 'LineWidth', 2); % Plot fitted line.

hold on;
plot(z, L_result3, 'k-.', 'LineWidth', 2);

grid on;

legend('Moisture range: 0.05-0.25','Moisture range: 0.15-0.35','Moisture range: 0.25-0.45','Moisture range: 0.35-0.55')
    
% Create xlabel
xlabel('Number of Iteration','FontWeight','bold','FontSize',11,'FontName','Cambria');
xlim([0 2000])

% Create ylabel
ylabel('Energy consumption: $E_{ch}(z,m_{v})$','Interpreter','latex');
ylim([0 100])

title('(a) Energy consumption Vs Iteration');

subplot(1,2,2);

plot(z, h_result, 'k-', 'LineWidth', 2); % Plot fitted line.

hold on;
plot(x, h_result1, 'k--', 'LineWidth', 2); % Plot fitted line.

hold on;
plot(z, h_result2, 'k:', 'LineWidth', 2); % Plot fitted line.

hold on;
plot(z, h_result3, 'k-.', 'LineWidth', 2);

grid on;

legend('Moisture range: 0.05-0.25','Moisture range: 0.15-0.35','Moisture range: 0.25-0.45','Moisture range: 0.35-0.55')
    
% Create xlabel
xlabel('Number of Iteration','FontWeight','bold','FontSize',11,'FontName','Cambria');
xlim([0 2000])

% F = g_(ij)*(z_i,z_j);

% Create ylabel
ylabel('Constarint Voilation: $g_{ij}(z^i,z^j)$','Interpreter','latex');
ylim([-2 2])

title('(b) Constraint violation Vs Iteration');
