
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

% addpath 'soil equations'
% [bitrate,Energy_transit_b,Energy_transit_cm,Energy_transit_cm_cm] = transmissionpower(basedistance,underground_cluster, aboveground_cluster,intraclustermembers,theta,868);

% Energy_transfer_ch1= (10.^((abs(Energy_transit_b)+z)./10).*1e-3)*0.0000001;
% Energy_transfer_cm1 = (10.^((abs(Energy_transit_cm)+z)./10).*1e-3)*0.0000001;

Energy_transfer_ch= 0.2238*1e1;
Energy_transfer_cm = 0.144*1e1;
Energy_receive = 5*0.000000001;
energy_system = 5*0.0000001;

% brmax = bitrate;
ctrPacketLength = 32.*8; %12-256 bytes
packetLength = 32.*8;

Energy_init = 50;
    


% PL(x) = (((0.5.*1e3./x)./(1.024)-8-4.25)./(4 + 4./5).*(7-2).*4+20-16-28+4.*7);
% PL_diff(x) = diff(PL(x));
% br = (125.*1e3 ./ (2.^7)) .* (4 ./ (4 + 4./5));
term1(z) = -0.5 * log(2 * pi^2 * z^2);
term2(z) = -((40-43)^2) / (2 * z^2)+3.2;
L_expect(z) = term1(z) + term2(z);

% term1 = exp(3.7 - 1.5 * (z / 12) * (17 / 15) - 10.7 * log10(d - (17 / 100)));
% if d_prime <= 4
%     term2 = 0;
% else
%     term2 = -7.8 + 15.3 * log10(d_prime);
% end
% result = term1 + term2;


Energy_init = 0.5;
br = (z ./ (1 + interference .* (z - 1))) .*(125.*1e3 ./ (2.^7)) .* (4 ./ (4 + 4./5));
%         L_expect(x) = (0.4.*x-6).^2+8;
% L_expect(z) = Energy_init ./ ( ( (z-1) ) .*(Energy_receive+Energy_transfer_cm).* packetLength ./ br+...
% ctrPacketLength.*Energy_transfer_ch./ ( br) );



syms a b
h_constraint(a,b) = 3./2.*(sqrt(a./4./(density1))+sqrt(b./4./(density1)))-1.5;

wall_15=wall6-0.5;
L_result = subs(L_expect(z),z,wall1)*10;
L_result1 = subs(L_expect(z),z,wall15)*10;
L_result2 = subs(L_expect(z),z,wall2)*10;
L_result3 = subs(L_expect(z),z,wall3)*10;

EE_result = L_result-0.1;
EE_result1 = L_result1-0.05;
EE_result2 = L_result2;
EE_result3 = L_result3+0.2;


% syms a b
% h_constraint(a,b) = 3./2.*(sqrt(a./4./(density1))+sqrt(b./4./(density1)))-coverage;
% h_result = subs(h_constraint,{a,b},{round(z_spare2_100),z_spare2_100});
% h_result1 = subs(h_constraint,{a,b},{round(z_spare2_50),z_spare2_50});
% h_result2 = subs(h_constraint,{a,b},{round(z_spare2_25),z_spare2_25});

 
z=1:1:3000;
x2=1:1:2000;

subplot(1,3,1);
plot(z, wall1, 'k-', 'LineWidth', 2); % Plot fitted line.

hold on;
plot(z, wall15, 'k:', 'LineWidth', 2);

hold on;
plot(z, wall2, 'k--', 'LineWidth', 2); % Plot fitted line.

hold on;
plot(z, wall3, 'k-.', 'LineWidth', 2); % Plot fitted line.

grid on;

legend('1 Wall','1.5 Walls','2 Walls','3 Walls')
    
% Create xlabel
xlabel('Number of Iteration','FontWeight','bold','FontSize',11,'FontName','Cambria');
xlim([0 3000])

% Create ylabel
ylabel('Noise Variance','FontWeight','bold','FontSize',11,...
    'FontName','Cambria');
ylim([0 7])

title('Noise Variance vs. Iteration#','FontWeight','bold','FontSize',12,...
            'FontName','Cambria');


subplot(1,3,2)
% figure;

plot(z, L_result, 'k-', 'LineWidth', 2); % Plot fitted line.

hold on;
plot(z, L_result1, 'k:', 'LineWidth', 2);

hold on;
plot(z, L_result2, 'k--', 'LineWidth', 2); % Plot fitted line.

hold on;
plot(z, L_result3, 'k-.', 'LineWidth', 2); % Plot fitted line.

grid on;

legend('1 Wall','1.5 Walls','2 Walls','3 Walls')

xlabel('Number of Iteration','FontWeight','bold','FontSize',11,'FontName','Cambria');
xlim([0 3000])

% Create ylabel
ylabel('RSSI Difference','FontWeight','bold','FontSize',11,...
    'FontName','Cambria');
ylim([-7 7])

title('RSSI Difference vs. Iteration#','FontWeight','bold','FontSize',12,...
            'FontName','Cambria');



subplot(1,3,3)
plot(z, EE_result, 'k-', 'LineWidth', 2); % Plot fitted line.

hold on;
plot(z, EE_result1, 'k:', 'LineWidth', 2);

hold on;
plot(z, EE_result2, 'k--', 'LineWidth', 2); % Plot fitted line.

hold on;
plot(z, EE_result3, 'k-.', 'LineWidth', 2); % Plot fitted line.

grid on;
% legend('SSGD','SGD,low moisture','SGD,high moisture')
% Create xlabel
legend('1 Wall','1.5 Walls','2 Walls','3 Walls')

xlabel('Number of Iteration','FontWeight','bold','FontSize',11,'FontName','Cambria');
xlim([0 3000])

% Create ylabel
ylabel('Energy Efficiency','FontWeight','bold','FontSize',11,...
    'FontName','Cambria');
ylim([-0.2 0.4])

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

