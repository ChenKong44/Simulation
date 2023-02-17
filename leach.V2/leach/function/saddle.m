function saddle()
    z = [15 21 18 13];
    z_spare = [];
    z_spare2 = [];
    z_spare3 = [];
    z_spare4 = [];
    lamda = zeros(4,4);
    theta = [0 0 0 0];
    iteration= 100;

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

    target = [2,1,3,4];
%     index = 1;
%     iteration=2;
    for t = 1:iteration
        [z, lamda, target, theta] = some_function(1, target, t, z, lamda, theta);
        [z, lamda, target, theta] = some_function(2, target, t, z, lamda, theta);
        [z, lamda, target, theta] = some_function(3, target, t, z, lamda, theta);
        [z, lamda, target, theta] = some_function(4, target, t, z, lamda, theta);
%         fprintf('target: %d %d %d %d\n',target(1), target(2), target(3), target(4));
        fprintf('z: %d %d %d %d\n',round(z(1)), round(z(2)), round(z(3)), round(z(4)));
        z_spare=[z_spare,round(z(1))];
        z_spare2=[z_spare2,round(z(2))];
        z_spare3=[z_spare3,round(z(3))];
        z_spare4=[z_spare4,round(z(4))];
    end
        subplot(4,1,1);
        x=1:1:iteration;
        
        % Create plot
        plot(x,z_spare);
        
        % Create xlabel
        xlabel('Round','FontWeight','bold','FontSize',11,'FontName','Cambria');
        
        % Create ylabel
        ylabel('Cluster size','FontWeight','bold','FontSize',11,...
            'FontName','Cambria');
        
        % Create title
        title('Number of cluster members vs. round','FontWeight','bold','FontSize',12,...
            'FontName','Cambria');
        subplot(4,1,2);
        plot(x,z_spare2);
        subplot(4,1,3);
        plot(x,z_spare3);
        subplot(4,1,4);
        plot(x,z_spare4);
    end