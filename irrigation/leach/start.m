clc, clear all, close all

numNodes = 50; % number of nodes for one cluster
numclusterhead = 2;

netArch  = newNetwork(10, 10);
nodeArch = newNodes(netArch, numNodes,numclusterhead);
roundArch = newRound(1000,32.*8,32.*8);

plot1

par = struct;

clusterModel = newCluster(netArch, nodeArch, 1000);

nodeArch     = clusterModel.nodeArch;
if nodeArch.numDead == nodeArch.numNode
   return
end


% for r = 1:roundArch.numRound
%     r;
%     clusterModel = newCluster(netArch, nodeArch, r);
%     clusterModel = dissEnergyCH(clusterModel, roundArch);
%     clusterModel = dissEnergyNonCH(clusterModel, roundArch);
%     nodeArch     = clusterModel.nodeArch; % new node architecture after select CHs
%     
%     par = plotResults(clusterModel, r, par);
%     if nodeArch.numDead == nodeArch.numNode
%         break
%     end
% end


