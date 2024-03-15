function saddle()
    z = [0 0 0];
    lamda = zeros(3,3);
    theta = [0 0 0];
    target = [2,1,0];
    for t = 1:100
        [z(1), lamda(1), theta(1)] = some_function(1, target, t, z, lamda, theta);
        [z(2), lamda(2), theta(2)] = some_function(2, target, t, z, lamda, theta);
        [z(3), lamda(3), theta(3)] = some_function(3, target, t, z, lamda, theta);
    end