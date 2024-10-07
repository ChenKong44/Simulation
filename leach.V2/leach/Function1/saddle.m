% function saddle()
clc;
clear;
    z = [20 20 20 20];
    z_spare = [];
    z_spare2 = [];
    z_spare3 = [];
    z_spare4 = [];

    L_spare = [];
    L_spare2 = [];
    H_spare = [];

    xmin=0.25;  %minimum moisture lv
    xmax=0.45;   %max moisture lv
    n=20;
    x=xmin+rand(1,n)*(xmax-xmin);
    theta = [x(randi([1,n])) x(randi([1,n])) x(randi([1,n])) x(randi([1,n]))];

    tmin=0.045;  %minimum moisture lv
    tmax=0.055;   %max moisture lv
    n=20;
    t=tmin+rand(1,n)*(tmax-tmin);

    underground_prob = t(randi([1,n]));


    ymin=0.945;  %minimum moisture lv
    ymax=0.955;   %max moisture lv
    n=20;
    y=ymin+rand(1,n)*(ymax-ymin);

%     aboveground_prob = y(randi([1,n]));
    aboveground_prob = 1-underground_prob;


    lamda = zeros(4,4);
    L_result = [0 0 0 0];
    H_result = [0 0 0 0];
    iteration= 2000;

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
    for t = 1:1:iteration
        fprintf('iteration #: %d\n',t);
        [z, lamda, target, theta,L_result,H_result] = some_function(1, target, t, z, lamda, theta,L_result,H_result,underground_prob,aboveground_prob);
        [z, lamda, target, theta,L_result,H_result] = some_function(2, target, t, z, lamda, theta,L_result,H_result,underground_prob,aboveground_prob);
        [z, lamda, target, theta,L_result,H_result] = some_function(3, target, t, z, lamda, theta,L_result,H_result,underground_prob,aboveground_prob);
        [z, lamda, target, theta,L_result,H_result] = some_function(4, target, t, z, lamda, theta,L_result,H_result,underground_prob,aboveground_prob);
%         fprintf('target: %d %d %d %d\n',target(1), target(2), target(3), target(4));
        fprintf('z: %d %d %d %d\n',z(1), round(z(2)), round(z(3)), round(z(4)));
%         fprintf('L_result: %d\n',L_result(1));
        z_spare=[z_spare,z(1)];
        z_spare2=[z_spare2,z(2)];
        z_spare3=[z_spare3,z(3)];
        z_spare4=[z_spare4,z(4)];

        L_spare=[L_spare,round(L_result(2))];
        H_spare=[H_spare,H_result(2)];
        L_spare2=[L_spare2,round(L_result(2))];

    end
        subplot(2,1,1);
        x=1:1:iteration;
        
        % Create plot
        plot(x,z_spare2,'b-');
        
        legend('ClusterHead# 1');
    
        % Create xlabel
        xlabel('Number of Iteration','FontWeight','bold','FontSize',11,'FontName','Cambria');
        
        % Create ylabel
        ylabel('Cluster size','FontWeight','bold','FontSize',11,...
            'FontName','Cambria');
        
        % Create title
        title('Function1 vs. Iteration#','FontWeight','bold','FontSize',12,...
            'FontName','Cambria');

        subplot(2,1,2);

        % Create plot
        plot(x,z_spare3,'b-',x,H_spare,'r-');
        
        legend('Objective funcion','Constraint Violation');
    
        % Create xlabel
        xlabel('Number of Iteration','FontWeight','bold','FontSize',11,'FontName','Cambria');
        
        % Create ylabel
        ylabel('Objective function & Constraint violation','FontWeight','bold','FontSize',11,...
            'FontName','Cambria');
        
        % Create title
        title('Objective function & Constraint violation vs. Iteration#','FontWeight','bold','FontSize',12,...
            'FontName','Cambria');
%     end