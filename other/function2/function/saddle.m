function saddle()
    z = [21 8 15];
    z_spare = [];
    z_spare2 = [];
    z_spare3 = [];
    lamda = zeros(3,3);
    theta = [0 0 0];
    iteration=100;

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
%     index = 1;
%     iteration=2;
    for t = 1:iteration
        [z, lamda, target, theta] = some_function(1, target, t, z, lamda, theta);
        [z, lamda, target, theta] = some_function(2, target, t, z, lamda, theta);
        [z, lamda, target, theta] = some_function(3, target, t, z, lamda, theta);
        fprintf('%d %d %d\n',z(1),z(2),z(3));
        z_spare=[z_spare,z(1)];
        z_spare2=[z_spare2,z(2)];
        z_spare3=[z_spare3,z(3)];
    end
        subplot(3,1,1);
        x=1:1:iteration;
        
        % Create plot
        plot(x,z_spare);
        
        % Create xlabel
        xlabel('Round','FontWeight','bold','FontSize',11,'FontName','Cambria');
        
        % Create ylabel
        ylabel('sum of energy','FontWeight','bold','FontSize',11,...
            'FontName','Cambria');
        
        % Create title
        title('Sum of energy of nodes vs. round','FontWeight','bold','FontSize',12,...
            'FontName','Cambria');
        subplot(3,1,2);
        plot(x,z_spare2);
        subplot(3,1,3);
        plot(x,z_spare3);
    end