% Get coefficients of a line fit through the data.
% coefficients = polyfit(x_ori, z_spare2_ori, 4);
% coefficients2 = polyfit(x2, double(z_spare2), 6);

% Create a new x axis with exactly 1000 points (or whatever you want).
% xFit = linspace(min(x_ori), max(x_ori), 2000);
% xFit2 = linspace(min(x2), max(x2), 2000);

% Get the estimated yFit value for each of those 1000 new x locations.
% yFit = polyval(coefficients , xFit);
% yFit2 = polyval(coefficients2 , xFit2);

% Plot everything.
% plot(x_ori, z_spare2_ori, 'b.', 'MarkerSize', 15); % Plot training data.
% hold on;
plot(x2, double(z_spare2_noav), 'r-', 'LineWidth', 2); % Plot fitted line.
% hold on;
% plot(x2, double(z_spare2), 'y.', 'MarkerSize', 15); % Plot training data.
hold on; % Set hold on so the next plot does not blow away the one we just drew.
plot(x2_av, double(z_spare2), 'b-', 'LineWidth', 2); % Plot fitted line.
grid on;