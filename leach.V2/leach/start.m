clc, clear all, close all

numNodes = 100; % number of nodes
p = 1/numNodes;

netArch  = newNetwork(100, 100, 50, 125);
nodeArch = newNodes(netArch, numNodes);
roundArch = newRound();

plot1

par = struct;

for r = 1:roundArch.numRound
    r
    clusterModel = newCluster(netArch, nodeArch, r, p);
    clusterModel = dissEnergyCH(clusterModel, roundArch);
    clusterModel = dissEnergyNonCH(clusterModel, roundArch);
    nodeArch     = clusterModel.nodeArch; % new node architecture after select CHs
    
    par = plotResults(clusterModel, r, par);
    if nodeArch.numDead == nodeArch.numNode
        break
    end
end


