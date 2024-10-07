% Clear workspace and command window
clear; clc;

% Define known positions of the receivers (x, y coordinates)
receivers = [
    0, 0;   % Receiver 1
    10, 0;  % Receiver 2
    5, 10;  % Receiver 3
];

% True position of the transmitter (unknown in real scenario)
true_position = [4, 6];

% Path loss exponent (typically ranges from 2 to 4)
n = 2;

% Received signal strength at each receiver (in dBm)
% Using a simple path loss model: RSS = P0 - 10*n*log10(d/d0)
% Where P0 is the received power at a reference distance d0
P0 = -30; % Reference power in dBm
d0 = 1;   % Reference distance in meters

% Number of simulations
num_simulations = 100;

% Standard deviation of the noise
noise_std = 1; % Standard deviation of the noise

% Arrays to store errors and estimated positions
errors = zeros(num_simulations, 1);
estimated_positions = zeros(num_simulations, 2);

% Run multiple simulations
figure;
hold on;
grid on;

% Plot receivers
plot(receivers(:, 1), receivers(:, 2), 'ro', 'MarkerSize', 10, 'DisplayName', 'Receivers');

% Plot true position
plot(true_position(1), true_position(2), 'g*', 'MarkerSize', 10, 'DisplayName', 'True Position');

for i = 1:num_simulations
    % Calculate distances from true position to each receiver
    distances = sqrt(sum((receivers - true_position).^2, 2));
    
    % Calculate RSS values at each receiver
    RSS = P0 - 10 * n * log10(distances / d0);
    
    % Add noise to the RSS measurements to simulate real conditions
    RSS_noisy = RSS + noise_std * randn(size(RSS));
    
    % Function to estimate distance from RSS
    estimate_distance = @(rss) d0 * 10.^((P0 - rss) / (10 * n));
    
    % Estimated distances from noisy RSS values
    estimated_distances = estimate_distance(RSS_noisy);
    
    % Trilateration to find the estimated position
    % Using non-linear least squares optimization
    
    % Objective function to minimize
    objective_function = @(position) sum((sqrt(sum((receivers - position).^2, 2)) - estimated_distances).^2);
    
    % Initial guess for the position (e.g., center of receivers)
    initial_guess = mean(receivers);
    
    % Use MATLAB's fminsearch function to minimize the objective function
    estimated_position = fminsearch(objective_function, initial_guess);
    
    % Store estimated position
    estimated_positions(i, :) = estimated_position;
    
    % Calculate error in meters
    error = sqrt(sum((true_position - estimated_position).^2));
    
    % Store error
    errors(i) = error;
end

% Calculate average error
average_error = mean(errors);

% Display results
disp('True Position:');
disp(true_position);
disp('Average Error in meters:');
disp(average_error);

% Plot estimated positions
plot(estimated_positions(:, 1), estimated_positions(:, 2), 'bx', 'MarkerSize', 10, 'DisplayName', 'Estimated Positions');

legend show;
xlabel('X Coordinate');
ylabel('Y Coordinate');
title('RSS Trilateration Simulation with Multiple Tests');

hold off;

% Plot errors
figure;
bar(errors);
title('Positioning Errors in Multiple Simulations');
xlabel('Simulation Index');
ylabel('Error (meters)');

% Plot average error
figure;
plot(1:num_simulations, errors, 'b-', 'LineWidth', 1.5);
hold on;
plot(1:num_simulations, average_error * ones(num_simulations, 1), 'r--', 'LineWidth', 2);
title('Positioning Errors with Average Error');
xlabel('Simulation Index');
ylabel('Error (meters)');
legend('Error per Simulation', 'Average Error');
hold off;
