function saddle()
    z = [37 21 25 32];
    z_spare = [];
    z_spare2 = [];
    z_spare3 = [];
    z_spare4 = [];

    L_spare = [];
    L_spare2 = [];

    xmin=0.05;  %minimum moisture lv
    xmax=0.25;   %max moisture lv
    n=20;
    x=xmin+rand(1,n)*(xmax-xmin);
    theta = [x(randi([1,n])) x(randi([1,n])) x(randi([1,n])) x(randi([1,n]))];

    lamda = zeros(4,4);
    L_result = [0 0 0 0];
    iteration= 5000;

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
    iteration_delay = [0 0 0 0];
%     index = 1;
%     iteration=2;
    for t = 1:1:iteration
        [z, lamda, target, theta,L_result,iteration_delay] = some_function(1, target, t, z, lamda, theta,L_result,iteration_delay);
        [z, lamda, target, theta,L_result,iteration_delay] = some_function(2, target, t, z, lamda, theta,L_result,iteration_delay);
        [z, lamda, target, theta,L_result,iteration_delay] = some_function(3, target, t, z, lamda, theta,L_result,iteration_delay);
        [z, lamda, target, theta,L_result,iteration_delay] = some_function(4, target, t, z, lamda, theta,L_result,iteration_delay);
%         fprintf('target: %d %d %d %d\n',target(1), target(2), target(3), target(4));
        fprintf('z: %d %d %d %d\n',z(1), round(z(2)), round(z(3)), round(z(4)));
        fprintf('L_result: %d\n',L_result(1));
        z_spare=[z_spare,round(z(1))];
        z_spare2=[z_spare2,round(z(2))];
%         L_spare=[L_spare,round(L_result(1))];
%         L_spare2=[L_spare2,round(L_result(2))];
        z_spare3=[z_spare3,round(z(3))];
        z_spare4=[z_spare4,round(z(4))];
    end
    fprintf('z: %d %d %d %d\n',iteration_delay(1), iteration_delay(2), iteration_delay(3), iteration_delay(4));

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