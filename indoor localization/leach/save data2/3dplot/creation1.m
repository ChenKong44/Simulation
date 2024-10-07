% Define the grid size
gridSize = 50;
x = linspace(-25, 25, gridSize);
y = linspace(25, -25, gridSize);

% Create a meshgrid
[X, Y] = meshgrid(x, y);

% Calculate the distance d from the origin
D = sqrt(X.^2 + Y.^2);


% Assume a path loss model for RSS
vartheta_w = 10; % Example value
t_w = 20;       % Example value
a_nm = 1.2;     % Example value
d = D;         % Example value
d_prime = 3;    % Example value

% Compute the result
L_nm_p_result = computeLnmP(vartheta_w, t_w, a_nm, d, d_prime);
fprintf('The result is: %f\n', L_nm_p_result);


% Number of random numbers to generate
n = 1;  % Example: Generate 1000 random numbers

% Mean and variance
mu = 0;
sigma = sqrt(4.63^2);  % Standard deviation (square root of the variance)

% Generate random numbers from a normal distribution with specified mean and variance
randomNumbers = mu + sigma * randn(n, 1);


% For simplicity, let's use RSS = -10 * log10(d) with some added noise
RSS = 10+5-20 * log10(D)+L_nm_p_result-randomNumbers;

% Flatten the matrices for scatter3
X_flat = X(:);
Y_flat = Y(:);
RSS_flat = RSS(:);

% Create the scatter3 plot
figure;
scatter3(X_flat, Y_flat, RSS_flat, 15, RSS_flat, 'filled');
colorbar;
xlabel('X');
ylabel('Y');
zlabel('RSS (dB)');
title('Received Signal Strength (RSS) based on (x,y) location');
