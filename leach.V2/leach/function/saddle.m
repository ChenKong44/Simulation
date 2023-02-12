function saddle()
    z = [1 1 1];
    lamda = zeros(3,3);
    theta = [0 0 0];

%     z1 = [0 0 0];
%     lamda1 = zeros(3,3);
%     theta1 = [0 0 0];
% 
%     z2 = [0 0 0];
%     lamda2 = zeros(3,3);
%     theta2 = [0 0 0];
% 
%     z3 = [0 0 0];
%     lamda3 = zeros(3,3);
%     theta3 = [0 0 0];

    target = [2,1,0];
    for t = 1:100
        [z, lamda, theta] = some_function(1, target, t, z, lamda, theta);
        [z, lamda, theta] = some_function(2, target, t, z, lamda, theta);
        [z, lamda, theta] = some_function(3, target, t, z, lamda, theta);
    end

    end