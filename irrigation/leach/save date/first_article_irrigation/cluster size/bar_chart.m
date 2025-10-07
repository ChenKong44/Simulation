% ===========================================
% ASSP Results - Horizontal Subplots (No Gap)
% ===========================================

% 数据
maxCluster = categorical({'25','50','100'}, {'25','50','100'}, 'Ordinal', true);
  % 类别型 → 等距显示
cluster_final = [25 50 100];
Iteration = [112 198 607];
relative_gap = [0.08 0.11 -0.12];

figure('Name','ASSP Results (Horizontal Subplots)','Color','w');

% --- (a) Cluster Size ---
subplot(1,3,1);
bar(maxCluster, cluster_final, 0.4, 'FaceColor','k','EdgeColor','k','LineWidth',1.2);
xlabel('Max Cluster Size','FontWeight','bold','FontSize',11,'FontName','Cambria');
ylabel('Cluster size: $z$','Interpreter','latex');
title('(a) Cluster Size');
grid on; set(gca,'FontSize',12,'LineWidth',1.1);
ylim([-30 150])

% --- (b) Energy Consumption ---
subplot(1,3,2);
bar(maxCluster, energy_final, 0.4, 'FaceColor','k','EdgeColor','k','LineWidth',1.2);
xlabel('Max Cluster Size','FontWeight','bold','FontSize',11,'FontName','Cambria');
ylabel('Number of Iteration: $t$','Interpreter','latex');
title('(b) Number of Iteration');
grid on; set(gca,'FontSize',12,'LineWidth',1.1);
ylim([-30 800])

% --- (c) Relative Energy Gap ---
subplot(1,3,3);
bar(maxCluster, relative_gap, 0.4, 'FaceColor','k','EdgeColor','k','LineWidth',1.2);
xlabel('Max Cluster Size','FontWeight','bold','FontSize',11,'FontName','Cambria');
ylabel('Relative energy consumption gap: $\frac{||(E_{c}(z,m_{v})) - (E_{c}(z^*,m_{v}))||}{||E_{c}(z^*,m_{v})||}$','Interpreter','latex');
title('(c) Relative Energy Gap');
yline(0,'--k','LineWidth',1);
grid on; set(gca,'FontSize',12,'LineWidth',1.1);
ylim([-0.15 0.15])

set(gcf,'Position',[100 100 1200 350]);
