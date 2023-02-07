function [nodeArch, clusterNode] = saddle(clusterModel, clusterFunParam)
% Create the new node architecture using leach algorithm in beginning 
%  of each rond. This function is called by newCluster function.
%   
%   Input:
%       clusterModel        Cluster model by newCluster function
%       clusterFunParam     Parameters for the cluster function



    
    nodeArch = clusterModel.nodeArch;
    netArch  = clusterModel.netArch;
    r = clusterFunParam(1); % round number
    
    p = clusterModel.p; %cluster size prob
    
    
    % Checking if there is a dead node
    locAlive = find(~nodeArch.dead); % find the nodes that are alive
    for i = locAlive
        if nodeArch.node(i).energy <= 0
            nodeArch.node(i).type = 'D';
            nodeArch.dead(i) = 1;
        else
            nodeArch.node(i).type = 'N';
        end
    end
    nodeArch.numDead = sum(nodeArch.dead);
    
    % Checking if there are disconnect node
    locAlive = find(~nodeArch.disconnect); % find the nodes that are alive
    for i = locAlive
        if nodeArch.node(i).prob <= 0.02
            nodeArch.node(i).type = 'C';
            nodeArch.disconnect(i) = 1;
        else
            nodeArch.node(i).type = 'N';
        end
    end
    nodeArch.numDisconnect = sum(nodeArch.disconnect);

    % define the cluster head
    % define cluster structure
    clusterNode     = struct();
    clusterNode.countCHs = nodeArch.numCluster; %no of clusterhead
    %for all cluster head distance and location
    xLoc1 = netArch.Clusterhead1.x; % x location of CH
    yLoc1 = netArch.Clusterhead1.y; % y location of CH
    
    xLoc2 = netArch.Clusterhead2.x; % x location of CH
    yLoc2 = netArch.Clusterhead2.y; % y location of CH

    clusterNode.loc(1, 1)   = xLoc1;
    clusterNode.loc(1, 2)   = yLoc1;
    clusterNode.loc(2, 1)   = xLoc2;
    clusterNode.loc(2, 2)   = yLoc2;
    % Calculate distance of CHs from BS
    clusterNode.distance(1) = sqrt((xLoc1 - netArch.Sink.x)^2 + ...
                                          (yLoc1 - netArch.Sink.y)^2);
    clusterNode.distance(2) = sqrt((xLoc1 - netArch.Sink.x)^2 + ...
                                          (yLoc1 - netArch.Sink.y)^2);
    % Calculate distance between 2 CHs
    clusterNode.distance(3) = sqrt((xLoc1 - xLoc2)^2 + ...
                                          (yLoc1 - yLoc2)^2);

    % implementation of saddle
    addpath soil equations
    L_expectdiff = expectlifetime(clusterNode.distance(1),clusterNode.distance(3), initEnergy, transEnergy, recEnergy,r);
    clusterNode.lifetime = L_expectdiff;
    
end