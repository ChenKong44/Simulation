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
        [z, lamda, target, theta,L_result,iteration_delay,z_spare] = some_function(1, target, t, z, lamda, theta,L_result,iteration_delay,z_spare);
        [z, lamda, target, theta,L_result,iteration_delay,z_spare2] = some_function2(2, target, t, z, lamda, theta,L_result,iteration_delay,z_spare2);
        [z, lamda, target, theta,L_result,iteration_delay,z_spare3] = some_function3(3, target, t, z, lamda, theta,L_result,iteration_delay,z_spare3);
        [z, lamda, target, theta,L_result,iteration_delay,z_spare4] = some_function4(4, target, t, z, lamda, theta,L_result,iteration_delay,z_spare4);
%         fprintf('target: %d %d %d %d\n',target(1), target(2), target(3), target(4));
        fprintf('z: %d %d %d %d\n',z(1), round(z(2)), round(z(3)), round(z(4)));
%         fprintf('L_result: %d\n',L_result(1));
%         z_spare=[z_spare,round(z(1))];
%         z_spare2=[z_spare2,round(z(2))];
%         L_spare=[L_spare,round(L_result(1))];
%         L_spare2=[L_spare2,round(L_result(2))];
%         z_spare3=[z_spare3,round(z(3))];
%         z_spare4=[z_spare4,round(z(4))];
    end
%     fprintf('z: %d %d %d %d\n',iteration_delay(1), iteration_delay(2), iteration_delay(3), iteration_delay(4));

    
        
    % Create plot
    x=1:1:iteration+iteration_delay(1);
    x2=1:1:iteration+iteration_delay(2);
    x3=1:1:iteration+iteration_delay(3);
    x4=1:1:iteration+iteration_delay(4);
    plot(x,z_spare,'b-',x2,z_spare2,'r-',x3,z_spare3,'k-',x4,z_spare4,'m-');

    legend('ClusterHead# 1','ClusterHead# 2','ClusterHead# 3','ClusterHead# 4')
    
    % Create xlabel
    xlabel('Number of Iteration','FontWeight','bold','FontSize',11,'FontName','Cambria');
    
    % Create ylabel
    ylabel('Cluster size','FontWeight','bold','FontSize',11,...
        'FontName','Cambria');
    
    % Create title
    title('Number of cluster members vs. Iteration#','FontWeight','bold','FontSize',12,...
        'FontName','Cambria');


    end