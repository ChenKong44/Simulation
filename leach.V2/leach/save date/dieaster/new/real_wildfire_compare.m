
%     theta_old = theta(index);
% xmin=0.05;  %minimum moisture lv
% xmax=0.25;   %max moisture lv
% n=20;
% x=xmin+rand(1,n)*(xmax-xmin);
% p=[273.45 272.94 271.77 275.3 292.34 290.04 302.2 301.66 304.17 301.85 289.45 280.21];
p = [0.27345 0.27294 0.27177 0.2753 0.29234 0.29004 0.3022 0.30166 0.30417 0.30185 0.28945 0.28021];
m = [0.185 0.165 0.155 0.185 0.1565 0.15325 0.1425 0.112 0.18325 0.149 0.1035 0.184];
% m = [18.5 16.5 15.5 18.5 15.65 15.3325 14.25 11.2 18.325 14.9 10.35 18.4];

energy_spare=[];
energy_spare2=[];
energy_spare3=[];
energy_difference=[];
humidity_spare=[];
temperature_spare=[];
% theta = x(randi([1,n]));theta = 0.185;

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

for t =1:1:12
syms z

intraclustermembers = sqrt(20./4./(density1));
underground_cluster = sqrt(z./4./(density1)).*0.054;
aboveground_cluster = sqrt(z./4./(density1)).*0.946;
basedistance =  sqrt(40./4./(density1))+sqrt(38./4./(density1)) ;

addpath 'soil equations'
[bitrate,Energy_transit_b,Energy_transit_cm,Energy_transit_cm_cm] = transmissionpower(basedistance,underground_cluster, aboveground_cluster,intraclustermembers,m(t),868);

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

    L_result1 = double(subs(L_expect(z),24));
    L_result2 = double(subs(L_expect(z),z,target_spare(t)));
    L_result3 = double(subs(L_expect(z),28));
    energy_spare1=[energy_spare,L_result1 ];
    energy_spare=[energy_spare,L_result1 ];
    energy_spare2=[energy_spare2,L_result2];
    energy_spare3=[energy_spare3,L_result3];
end
    energy_spare = [energy_spare 0];
    energy_spare2 = [energy_spare2 0];
    energy_spare3 = [energy_spare3 0];
for t=1:1:12
    energy_spare(t+1)=energy_spare(t+1)+energy_spare(t);
    energy_spare2(t+1)=energy_spare2(t+1)+energy_spare2(t);
    energy_spare3(t+1)=energy_spare3(t+1)+energy_spare3(t);
end

m = [m 0.2];
for t=1:1:12
    humidity_spare(t)=abs(m(t+1)-m(t));
end

p = [p 0.29];
for t=1:1:12
    temperature_spare(t)=abs(p(t+1)-p(t));
end


energy_spare(13)=[];
energy_spare2(13)=[];
energy_spare3(13)=[];
% humidity_spare(13)=[];

% energy_difference(13)=[];
for t=1:1:12
    energy_difference(t) = abs(energy_spare2(t)-energy_spare(t));
%     energy_difference(t) = log10(energy_difference(t)./0.0000001./1e-3).*10;
end
% L_result2 = double(subs(L_expect(z),z,z_spare22));
% L_result3 = double(subs(L_expect(z),z,z_spare23));

% syms a b
% h_constraint(a,b) = 3./2.*(sqrt(a./4./(density1))+sqrt(b./4./(density1)))-coverage;
% h_result = subs(h_constraint,{a,b},{round(z_spare2_001),z_spare2_001});
% h_result1 = subs(h_constraint,{a,b},{round(z_spare2_005),z_spare2_005});
% h_result2 = subs(h_constraint,{a,b},{round(z_spare2_01),z_spare2_01});


% z_spare=[];
% L_result=[];

% for t=1:1:3000
%     z_spare(t)=(z_spare2(t)+z_spare22(t)+z_spare23(t))./3;
%     L_result(t)=(L_result3(t)+L_result2(t)+L_result1(t))./3;
% end

subplot(1,2,2);
x= [1 2 3 4 5 6 7 8 9 10 11 12];

% Create plot
plot(x,energy_spare2,'-*',x,energy_spare,'-o',x,energy_spare3,'-+');
set(gca, 'XTick',x) 
legend('ADSGT','SGD','DSGT','FontWeight','bold','FontSize',9,'FontName','Cambria')

% Create xlabel
xlabel('Wildfire Rescue Time','FontWeight','bold','FontSize',11,'FontName','Cambria');
xticklabels({'07:09','08:12','09:48','10:52','11:32','12:34','13:08','14:10','15:34','17:38','19:17','21:19','23:57'})

% Create ylabel
ylabel('Cumulative Energy Consumption (J)','FontWeight','bold','FontSize',11,...
'FontName','Cambria');
yticklabels({'0','50','100','150','200','250','300','350','400'})
ylim([0 400])

title('(b) Cumulative Energy Consumption (J) vs. Wildfire Rescue Time','FontWeight','bold','FontSize',12,...
            'FontName','Cambria');
% yyaxis right
% plot(x,energy_spare1,'k--x','LineWidth', 2);
% % bar(x,energy_difference)
% ylabel('Moisture level','FontWeight','bold','FontSize',11,...
% 'FontName','Cambria');
% ax = gca;
% ax.YColor = 'k';
% ylim([0 80])

grid on;





subplot(1,2,1);
x=1:1:12;
y=[humidity_spare;temperature_spare];
bar(x,y)

grid on;
legend('Humidity','Temperature','FontWeight','bold','FontSize',9,'FontName','Cambria')

% Create xlabel
xlabel('Wildfire Rescue Time','FontWeight','bold','FontSize',11,'FontName','Cambria');
xticklabels({'07:09','08:12','09:48','10:52','11:32','12:34','13:08','14:10','15:34','17:38','19:17','21:19','23:57'})
% xlim([0 10])

% Create ylabel
ylabel('Humidity and Temperature','FontWeight','bold','FontSize',11,'FontName','Cambria');
ylim([0 0.15])


title('(a) Wildfire Information vs. Wildfire Rescue Time','FontWeight','bold','FontSize',12,...
            'FontName','Cambria');
yyaxis right
plot(x,energy_spare1,'k--x','LineWidth', 2);
ylabel('Path Loss','FontWeight','bold','FontSize',11,...
'FontName','Cambria');
ax = gca;
ax.YColor = 'k';
ylim([0 80])

% subplot(2,1,2);
% 
% % Create plot
% plot(p,x,'b-');
% 
% legend('Moisture')
% 
% % Create xlabel
% xlabel('Number of Iteration','FontWeight','bold','FontSize',11,'FontName','Cambria');
% 
% % Create ylabel
% ylabel('Moisture Level','FontWeight','bold','FontSize',11,...
% 'FontName','Cambria');



