function [nodeArch, clusterNode] = saddle(clusterModel, clusterFunParam)
% Create the new node architecture using leach algorithm in beginning 
%  of each rond. This function is called by newCluster function.
%   
%   Input:
%       clusterModel        Cluster model by newCluster function
%       clusterFunParam     Parameters for the cluster function



    
    nodeArch = clusterModel.nodeArch;
    netArch  = clusterModel.netArch;
    r = clusterFunParam; % round number
    
%     p = clusterModel.p; %cluster size prob
    
    
%     % Checking if there is a dead node
%     locAlive = find(~nodeArch.dead); % find the nodes that are alive
%     for i = locAlive
%         if nodeArch.node(i).energy <= 0
%             nodeArch.node(i).type = 'D';
%             nodeArch.dead(i) = 1;
%         else
%             nodeArch.node(i).type = 'N';
%         end
%     end
%     nodeArch.numDead = sum(nodeArch.dead);
%     
%     % Checking if there are disconnect node
%     locAlive = find(~nodeArch.disconnect); % find the nodes that are alive
%     for i = locAlive
%         if nodeArch.node(i).prob <= 0.02
%             nodeArch.node(i).type = 'C';
%             nodeArch.disconnect(i) = 1;
%         else
%             nodeArch.node(i).type = 'N';
%         end
%     end
%     nodeArch.numDisconnect = sum(nodeArch.disconnect);

    % define the cluster head
    % define cluster structure
    clusterNode     = struct();
    clusterNode.countCHs = nodeArch.numCluster; %no of clusterhead
    %for all cluster head distance and location
    xLoc1 = netArch.Clusterhead1.x; % x location of CH1
    yLoc1 = netArch.Clusterhead1.y; % y location of CH1
    
    xLoc2 = netArch.Clusterhead2.x; % x location of CH2
    yLoc2 = netArch.Clusterhead2.y; % y location of CH2

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
    nodeArch.sumdistance = 0;
    % Calculate distance between CHs and CMs
    locAlive = find(~nodeArch.dead); % find the nodes that are alive
    for i = locAlive
        locNode = [nodeArch.node(i).x, nodeArch.node(i).y];
        countCH = nodeArch.numCluster; % Number of CHs
        % calculate distance to each CH and find smallest distance
        [minDis, loc] = min(sqrt(sum((repmat(locNode, countCH, 1) - clusterNode.loc)' .^ 2)));
        nodeArch.sumdistance = nodeArch.sumenergy+ minDis;
    end
    nodeArch.numDead = sum(nodeArch.dead);


    % implementation of saddle
    addpath function\
    Saddle2(clusterModel, clusterFunParam)
    
end