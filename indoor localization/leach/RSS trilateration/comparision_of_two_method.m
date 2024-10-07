% Sample data
room_numbers = [1,2,3,4,5,6,7]; % Room numbers in a specific order
distance_error_rss = [2.5, 3.1, 2.9, 3.4, 2.8, 3.3, 3.0]; % Distance errors for RSS trilateration
distance_error_proposed = [1.8, 2.0, 1.7, 2.2, 1.9, 2.1, 1.8]; % Distance errors for proposed method

room_numbers1 = [1,6,7,4,5,3,2];
distance_error_rss1 = [2.5,2.8,2.9,3.0,3.1,3.3,3.4]; % Distance errors for RSS trilateration
distance_error_proposed1 = [1.8,1.9,1.7,1.8,2.0,2.1,2.2]; % Distance errors for proposed method

subplot(1,2,1);

hold on;
grid on;

% Plot receivers
plot(receivers(:, 1), receivers(:, 2), 'r*', 'MarkerSize', 10, 'DisplayName', 'Receivers');

% Plot true position
plot(true_position(1), true_position(2), 'g.', 'MarkerSize', 10, 'DisplayName', 'True Position');
% Display results
disp('True Position:');
disp(true_position);
disp('Average Error in meters:');
disp(average_error);

% Plot estimated positions
plot(estimated_positions(:, 1), estimated_positions(:, 2), 'bx', 'MarkerSize', 10, 'DisplayName', 'Estimated Positions');

legend show;
xlabel('X Coordinate','FontWeight','bold','FontSize',11,'FontName','Cambria');
ylabel('Y Coordinate','FontWeight','bold','FontSize',11,'FontName','Cambria');
title('(a) RSS Trilateration Simulation with Multiple Tests','FontWeight','bold','FontSize',11,'FontName','Cambria');
ylim([0 11]);
xlim([0 11]);

hold off;

subplot(1,2,2)
% figure;
scatter3(X_flat, Y_flat, RSS_flat, 15, RSS_flat, '*');
colorbar;
hold on;
scatter3(gt_x, gt_y, gt_RSS, 20, 'r', 'filled');
xlabel('X','FontWeight','bold','FontSize',11,'FontName','Cambria');
ylabel('Y','FontWeight','bold','FontSize',11,'FontName','Cambria');
zlabel('RSS (dB)','FontWeight','bold','FontSize',11,'FontName','Cambria');
zlim([-50 0]);
title('(b) Estimated vs Ground Truth RSS','FontWeight','bold','FontSize',11,'FontName','Cambria');
legend('Estimated RSS', 'Ground Truth RSS', 'Location', 'best');

% bar(categorical(room_numbers), [distance_error_rss' distance_error_proposed'], 'grouped');
% 
% % Add labels and title
% xlabel('Room Number');
% ylabel('Distance Error (meters)');
% title('Distance Error (m) vs Room Size');
% legend('RSS Trilateration', 'Proposed Method');
% grid on;
% 
% % Set y-axis range
% ylim([0 5]); % Adjust the range as needed
% 
% % Set x-axis labels with 'Room' prefix
% xticklabels(room_numbers);


% subplot(1,3,3)
% plot(room_numbers, distance_error_rss1, '-o', 'DisplayName', 'RSS Trilateration', 'LineWidth', 2);
% hold on;
% plot(room_numbers, distance_error_proposed1, '-x', 'DisplayName', 'Proposed Method', 'LineWidth', 2);
% hold off;
% 
% % Add labels and title
% xlabel('Room Number');
% ylabel('Distance Error (meters)');
% title('Distance Error (m) vs Room Complexity');
% legend show;
% grid on;
% 
% % Set y-axis range
% ylim([0 5]); % Adjust the range as needed
% 
% 
% % Set x-axis ticks and labels
% xticks(room_numbers);
% xticklabels(room_numbers1);

