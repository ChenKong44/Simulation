% clc;
% clear;
% % Define the grid size
% gridSize = 50;
% x = linspace(0, 50, gridSize);
% y = linspace(50,0, gridSize);
% 
% % Create a meshgrid
% [X, Y] = meshgrid(x, y);
% 
% % Calculate the distance d from the origin
% D = sqrt(X.^2 + Y.^2)+2;
% 
% % Assume a path loss model for RSS
% vartheta_w = 10; % Example value
% t_w = 20;       % Example value
% a_nm = 1;     % Example value
% d = D;% Example value
% d_prime = 2;    % Example value
% 
% % Compute the result
% L_nm_p_result = computeLnmP(vartheta_w, t_w, a_nm, d, d_prime);
% L_nm_p_result2 = computeLnmP(vartheta_w, t_w, 2, d, d_prime);
% L_nm_p_result3 = computeLnmP(vartheta_w, t_w, 3, d, d_prime);
% fprintf('The result is: %f\n', L_nm_p_result);
% 
% % Number of random numbers to generate
% n = 1;  % Example: Generate 1000 random numbers
% 
% % Mean and variance
% mu = 0;
% sigma = sqrt(4.63^2);  % Standard deviation (square root of the variance)
% sigma1 = sqrt(4.68^2);
% 
% % Generate random numbers from a normal distribution with specified mean and variance
% randomNumbers = mu + sigma * randn(n, 1);
% randomNumbers1 = mu + sigma1 * randn(n, 1);
% 
% % Assume a path loss model for RSS
% % For simplicity, let's use RSS = -10 * log10(d) with some added noise
% RSS = 10+5-3-20 * log10(D)+(L_nm_p_result-randomNumbers);
% RSS1 = 10+5-3-20 * log10(D)+(L_nm_p_result2-randomNumbers);
% RSS2 = 10+5-3-20 * log10(D)+(L_nm_p_result3-randomNumbers);
% 
% % Define ground truth RSS at certain points
% gt_x = [25, 5, 35, 9, 41, 42, 39, 4, 14, 17];
% gt_y = [5, 20, 31, 22, 30, 31, 27, 3, 43, 45];
% gt_D = sqrt(gt_x.^2 + gt_y.^2);
% d1=gt_D;
% L_nm_p_result1 = computeLnmP(vartheta_w, t_w, a_nm, d1, d_prime);
% gt_RSS = 10+5-3-20 * log10(gt_D)+(L_nm_p_result1-randomNumbers);
% % gt_RSS = [-24.4597372787050,	-30.4059975638306,	-33.0112754515745,	-35.2611935680330,	-35.7989570009950,	-38.4857766191604,	-40.0577253967395];
% 
% 
% % Define indices of the grid points to be excluded
% exclude_x = 1:10;
% exclude_y = 1:10;
% 
% exclude_x1 = 1:10;
% exclude_y1 = 40:50;
% 
% exclude_x2 = 25:40;
% exclude_y2 = 11:13;
% 
% exclude_x3 = 25:40;
% exclude_y3 = 13:30;
% 
% exclude_x4 = 25:40;
% exclude_y4 = 31:33;
% 
% exclude_x5 = 25:40;
% exclude_y5 = 34:42;
% 
% % Adjust RSS calculation behind the plane
% sigma_plane = sqrt(4.83^2);  % Standard deviation behind the plane
% 
% % Calculate distance from the origin for all grid points
% distance_from_origin = sqrt(X.^2 + Y.^2);
% 
% 
% % Exclude certain grid points
% % for i = 1:length(exclude_x)
% %     RSS(X == exclude_x(i) & Y == exclude_y(i)) = NaN;
% % end
% 
% % Exclude certain grid points
% RSS(exclude_x, exclude_y) = NaN;
% RSS(exclude_x1, exclude_y1) = NaN;
% RSS(exclude_x2, exclude_y2) = RSS(exclude_x2, exclude_y2) - sqrt(7^2);
% RSS(exclude_x3, exclude_y3) = RSS1(exclude_x3, exclude_y3);
% RSS(exclude_x4, exclude_y4) = RSS(exclude_x4, exclude_y4) - sqrt(7^2);
% RSS(exclude_x5, exclude_y5) = RSS2(exclude_x5, exclude_y5);
% 
% X_flat = X(:);
% Y_flat = Y(:);
% RSS_flat = RSS(:);

% Create the first figure
figure;
scatter3(X_flat, Y_flat, RSS_flat, 15, RSS_flat, '*');
colorbar;
hold on;
scatter3(gt_x, gt_y, gt_RSS, 20, 'r', 'filled');
xlabel('x');
ylabel('y');
zlabel('RSS (dB)');
zlim([-50 0]);
title('(a)');
legend('Estimated RSS', 'Ground Truth RSS', 'Location', 'best');
% view(50,50)
hold off;

% Create the second figure
% figure;
% mesh(X, Y, RSS);
% hold on;
% scatter3(gt_x, gt_y, gt_RSS, 50, 'b', 'filled');
% xlabel('x');
% ylabel('y');
% zlabel('RSS (dB)');
% title('(b)');
% legend('Estimated RSS', 'Ground Truth RSS', 'Location', 'best');
% hold off;
