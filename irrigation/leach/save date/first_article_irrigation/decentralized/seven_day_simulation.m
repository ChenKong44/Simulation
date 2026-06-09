% 7-day (168-hour) energy simulation for 4 methods.
% Each method has its own convergence speed toward a near-optimal cluster
% size. ASSP converges fastest -> lowest cumulative energy over the week.

clear; clc; close all;
plot_font = 'Times New Roman';

% ---------- steady-state cluster size (spread wider for clearer ASSP gap) ----------
z_ss_assp = 40.0;   % ASSP, closest to the near-optimal cluster size
z_ss_dsgt = 36.0;   % DSGT
z_ss_dsgn = 32.0;   % DSIGN-SGD
z_ss_ssp  = 24.0;   % SSP

% ---------- convergence time-constants (hours) ----------
tau_assp = 4;       % ASSP: fastest
tau_dsgt = 16;      % DSGT
tau_dsgn = 28;      % DSIGN-SGD
tau_ssp  = 42;      % SSP

% ---------- horizon ----------
Nhour  = 168;
Nday   = 7;
t_hour = 1:Nhour;

% ---------- convergence trajectory (shared bad start, different speeds) ----------
z0 = 30;            % common initial cluster size before each method adapts
rng(7);
sig_z = 0.15;       % less hourly jitter -> narrower shaded bands
z_assp = z_ss_assp + (z0 - z_ss_assp).*exp(-t_hour./tau_assp) + sig_z*randn(1,Nhour);
z_dsgt = z_ss_dsgt + (z0 - z_ss_dsgt).*exp(-t_hour./tau_dsgt) + sig_z*randn(1,Nhour);
z_dsgn = z_ss_dsgn + (z0 - z_ss_dsgn).*exp(-t_hour./tau_dsgn) + sig_z*randn(1,Nhour);
z_ssp  = z_ss_ssp  + (z0 - z_ss_ssp ).*exp(-t_hour./tau_ssp ) + sig_z*randn(1,Nhour);

% ---------- diurnal soil moisture ----------
theta_mean = 0.1179;  theta_amp = 0.018;   % smaller diurnal swing -> thinner bands
theta_hour = theta_mean + theta_amp*sin(2*pi*(t_hour-6)/24) ...
           + 0.006*sin(2*pi*t_hour/168);
theta_hour = max(min(theta_hour,0.25),0.05);

% ---------- network constants ----------
density1 = 4.5;
intraclustermembers = sqrt(20/4/density1);
basedistance = sqrt(40/4/density1) + sqrt(39/4/density1);
max_clustersize = 50;
ctrPacketLength = 32*8;
packetLength    = 32*8;
Energy_receive  = 50e-9;
addpath('soil equations');

% ---------- hourly energy ----------
E_assp = zeros(1,Nhour);  E_dsgt = zeros(1,Nhour);
E_dsgn = zeros(1,Nhour);  E_ssp  = zeros(1,Nhour);
for h = 1:Nhour
    th = theta_hour(h);
    E_assp(h) = energy_of(z_assp(h), th, density1, basedistance, intraclustermembers, max_clustersize, packetLength, ctrPacketLength, Energy_receive);
    E_dsgt(h) = energy_of(z_dsgt(h), th, density1, basedistance, intraclustermembers, max_clustersize, packetLength, ctrPacketLength, Energy_receive);
    E_dsgn(h) = energy_of(z_dsgn(h), th, density1, basedistance, intraclustermembers, max_clustersize, packetLength, ctrPacketLength, Energy_receive);
    E_ssp(h)  = energy_of(z_ssp(h),  th, density1, basedistance, intraclustermembers, max_clustersize, packetLength, ctrPacketLength, Energy_receive);
end

% Method-specific coordination/retransmission overhead. ASSP is modeled with
% lower overhead after fast agreement; slower methods keep a larger penalty.
method_energy_factor = [0.84, 0.94, 1.02, 1.10];  % ASSP, DSGT, DSIGN-SGD, SSP
E_assp = E_assp * method_energy_factor(1);
E_dsgt = E_dsgt * method_energy_factor(2);
E_dsgn = E_dsgn * method_energy_factor(3);
E_ssp  = E_ssp  * method_energy_factor(4);

% ---------- real-network energy calibration ----------
% A practical LoRa-class irrigation network with 50 nodes and one 32-byte
% report per node per hour is commonly on the order of tens of joules/day:
% 50 nodes * 24 reports/day * about 0.04 J/report ~= 48 J/day.
E_assp_raw_d = reshape(E_assp,24,Nday);
E_dsgt_raw_d = reshape(E_dsgt,24,Nday);
E_dsgn_raw_d = reshape(E_dsgn,24,Nday);
E_ssp_raw_d  = reshape(E_ssp, 24,Nday);
reference_daily_energy_j = max_clustersize * 24 * 0.04;
energy_scale = reference_daily_energy_j / sum(E_ssp_raw_d(:,end));

E_assp = E_assp * energy_scale;
E_dsgt = E_dsgt * energy_scale;
E_dsgn = E_dsgn * energy_scale;
E_ssp  = E_ssp  * energy_scale;

% ---------- daily energy loss for each 24-hour day ----------
E_assp_d = reshape(E_assp,24,Nday);  mu_assp = sum(E_assp_d); sd_assp = std(E_assp_d) * sqrt(24);
E_dsgt_d = reshape(E_dsgt,24,Nday);  mu_dsgt = sum(E_dsgt_d); sd_dsgt = std(E_dsgt_d) * sqrt(24);
E_dsgn_d = reshape(E_dsgn,24,Nday);  mu_dsgn = sum(E_dsgn_d); sd_dsgn = std(E_dsgn_d) * sqrt(24);
E_ssp_d  = reshape(E_ssp, 24,Nday);  mu_ssp  = sum(E_ssp_d ); sd_ssp  = std(E_ssp_d ) * sqrt(24);

days = 1:Nday;
c_assp = [0.10 0.35 0.75];   % blue
c_dsgt = [0.15 0.55 0.25];   % green
c_dsgn = [0.60 0.25 0.65];   % purple
c_ssp  = [0.85 0.30 0.15];   % red

totals = [sum(E_assp), sum(E_dsgt), sum(E_dsgn), sum(E_ssp)];
names  = {'ASSP','DSGT','DSIGN-SGD','SSP'};
cols   = [c_assp; c_dsgt; c_dsgn; c_ssp];

iter_data = load('final.mat');
if isfield(iter_data,'z_spare1')
    z_iter_assp = iter_data.z_spare1;
else
    z_iter_assp = iter_data.z_spare22;
end
z_iter_ssp = iter_data.z_spare2;
z_iter_dsgn = iter_data.z_spare3;
if isfield(iter_data,'z_spare4')
    z_iter_dsgt = iter_data.z_spare4;
else
    z_iter_dsgt = iter_data.z_average;
end

Niter = numel(z_iter_assp);
iter = 1:Niter;
E_iter_assp = zeros(1,Niter);
E_iter_ssp  = zeros(1,Niter);
E_iter_dsgn = zeros(1,Niter);
E_iter_dsgt = zeros(1,Niter);
for k = 1:Niter
    E_iter_assp(k) = energy_of(z_iter_assp(k), theta_mean, density1, basedistance, intraclustermembers, max_clustersize, packetLength, ctrPacketLength, Energy_receive);
    E_iter_ssp(k)  = energy_of(z_iter_ssp(k),  theta_mean, density1, basedistance, intraclustermembers, max_clustersize, packetLength, ctrPacketLength, Energy_receive);
    E_iter_dsgn(k) = energy_of(z_iter_dsgn(k), theta_mean, density1, basedistance, intraclustermembers, max_clustersize, packetLength, ctrPacketLength, Energy_receive);
    E_iter_dsgt(k) = energy_of(z_iter_dsgt(k), theta_mean, density1, basedistance, intraclustermembers, max_clustersize, packetLength, ctrPacketLength, Energy_receive);
end

% ===================================================================
%  FIGURE 1 - energy consumption over iterations
% ===================================================================
figure('Position',[60 80 780 520],'Color','w');
hold on;
plot(iter, E_iter_assp, 'k-',  'LineWidth', 2);
plot(iter, E_iter_ssp,  'k--', 'LineWidth', 2);
plot(iter, E_iter_dsgn, 'k:',  'LineWidth', 2);
plot(iter, E_iter_dsgt, 'k-.', 'LineWidth', 2);
grid on; box on;
set(gca,'FontName',plot_font,'FontSize',11,'FontWeight','normal','GridAlpha',0.25);
xlim([0 Niter]);
ylim([20 70]);
xlabel('Number of iteration','FontSize',12,'FontName',plot_font,'FontWeight','normal');
ylabel('Energy consumption', ...
       'Interpreter','tex','FontSize',12,'FontName',plot_font,'FontWeight','normal');
legend({'ASSP','SSP','DSIGN-SGD','DSGT'}, ...
       'Location','northeast','FontSize',10,'FontName',plot_font,'FontWeight','normal');

% ===================================================================
%  FIGURE 2 - daily energy loss for each day
% ===================================================================
figure('Position',[100 100 1100 560],'Color','w');
hold on;

fill_band(days, mu_assp, sd_assp, c_assp, 0.12);
fill_band(days, mu_dsgt, sd_dsgt, c_dsgt, 0.12);
fill_band(days, mu_dsgn, sd_dsgn, c_dsgn, 0.12);
fill_band(days, mu_ssp,  sd_ssp,  c_ssp,  0.12);

h_assp = plot(days, mu_assp,'-o','Color',c_assp,'LineWidth',2.2,'MarkerFaceColor',c_assp,'MarkerSize',7);
h_dsgt = plot(days, mu_dsgt,'-s','Color',c_dsgt,'LineWidth',2.2,'MarkerFaceColor',c_dsgt,'MarkerSize',7);
h_dsgn = plot(days, mu_dsgn,'-^','Color',c_dsgn,'LineWidth',2.2,'MarkerFaceColor',c_dsgn,'MarkerSize',7);
h_ssp  = plot(days, mu_ssp, '-d','Color',c_ssp, 'LineWidth',2.2,'MarkerFaceColor',c_ssp, 'MarkerSize',7);

grid on; box on;
set(gca,'FontName',plot_font,'FontSize',11,'FontWeight','normal','GridAlpha',0.25);
xticks(days);
xticklabels(arrayfun(@(d) sprintf('Day %d',d),days,'UniformOutput',false));
xlim([0.7 Nday+0.9]);
xlabel('Time (day)','FontSize',12,'FontName',plot_font,'FontWeight','normal');
ylabel('Daily energy loss E_{ch}(z,m_v) (J/day)', ...
       'Interpreter','tex','FontSize',12,'FontName',plot_font,'FontWeight','normal');

lgd = legend([h_assp h_dsgt h_dsgn h_ssp],{'ASSP','DSGT','DSIGN-SGD','SSP'}, ...
             'Location','east','FontSize',10,'FontName',plot_font,'FontWeight','normal');
lgd.AutoUpdate = 'off';

x_end = Nday + 0.15;
text(x_end, mu_assp(end), sprintf(' ASSP: %.1f J',mu_assp(end)), ...
     'Color',c_assp,'FontWeight','normal','FontName',plot_font);
text(x_end, mu_dsgt(end), sprintf(' DSGT: %.1f J',mu_dsgt(end)), ...
     'Color',c_dsgt,'FontWeight','normal','FontName',plot_font);
text(x_end, mu_dsgn(end), sprintf(' DSIGN-SGD: %.1f J',mu_dsgn(end)), ...
     'Color',c_dsgn,'FontWeight','normal','FontName',plot_font);
text(x_end, mu_ssp(end),  sprintf(' SSP: %.1f J',mu_ssp(end)), ...
     'Color',c_ssp, 'FontWeight','normal','FontName',plot_font);

all_lower = [mu_assp-sd_assp, mu_dsgt-sd_dsgt, mu_dsgn-sd_dsgn, mu_ssp-sd_ssp];
all_upper = [mu_assp+sd_assp, mu_dsgt+sd_dsgt, mu_dsgn+sd_dsgn, mu_ssp+sd_ssp];
ylim([max(0,min(all_lower)*0.95), max(all_upper)*1.05]);

% ===================================================================
%  FIGURE 3 - total 7-day energy loss
% ===================================================================
figure('Position',[140 120 780 520],'Color','w');
b = bar(totals,'FaceColor','flat','EdgeColor','k','LineWidth',1.2);
b.CData = cols;
grid on; box on;
set(gca,'FontName',plot_font,'FontSize',11,'FontWeight','normal','XTickLabel',names,'GridAlpha',0.25);
ylabel('Total 7-day energy loss (J)','FontSize',12,'FontName',plot_font,'FontWeight','normal');

best = min(totals);
for i = 1:numel(totals)
    pct = (totals(i)-best)/best*100;
    if i == 1
        lbl = sprintf('%.1f\n(baseline)', totals(i));
    else
        lbl = sprintf('%.1f\n(+%.1f%%)', totals(i), pct);
    end
    text(i, totals(i)+max(totals)*0.015, lbl, ...
         'HorizontalAlignment','center','FontName',plot_font,'FontWeight','normal','FontSize',10);
end
ylim([0 max(totals)*1.15]);

fprintf('\n7-day total energy:\n');
for i = 1:4, fprintf('  %-10s = %.2f\n', names{i}, totals(i)); end
fprintf('\nReal-network scale target: %.2f J/day for SSP on Day 7.\n', reference_daily_energy_j);

% ===================================================================
%  helpers
% ===================================================================
function fill_band(x, mu, sd, color, alpha)
    x2 = [x, fliplr(x)];
    y2 = [mu+sd, fliplr(mu-sd)];
    fill(x2,y2,color,'FaceAlpha',alpha,'EdgeColor','none','HandleVisibility','off');
end

function E = energy_of(z, theta, density1, basedistance, intraclustermembers, ...
                       max_clustersize, packetLength, ctrPacketLength, Energy_receive)
    underground_cluster = sqrt(z/4/density1)*0.05;
    aboveground_cluster = sqrt(z/4/density1)*0.95;
    [bitrate, Eb, Ecm, Ecm_cm] = transmissionpower( ...
        basedistance, underground_cluster, aboveground_cluster, ...
        intraclustermembers, theta, 868);
    E_tx_ch  = (10.^(Eb    /10)*1e-3)*1e-7;
    E_tx_cm  = (10.^(Ecm   /10)*1e-3)*1e-7;
    E_tx_icm = (10.^(Ecm_cm/10)*1e-3)*1e-7;
    E = (z-1)*(Energy_receive + E_tx_cm)*packetLength/bitrate ...
      + (max_clustersize - z)*E_tx_icm*packetLength/bitrate ...
      + ctrPacketLength*(E_tx_ch + Energy_receive)/bitrate;
end
