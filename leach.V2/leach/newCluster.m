function clusterModel = newCluster(netArch, nodeArch, ...
                        clusterFunParam, p_numnode)
% Create the network architecture with desired parameters
%   
%   Input:
%       clusterFun          Function name for clustering algorithm.
%       clusterFunParam     Parameters for the cluster function
%       numCluster          Number of clusters (CHs)
%       netArch             Network model
%       nodeArch            Nodes model


    % set the parameters 
    if ~exist('clusterFunParam','var')
        clusterFunParam = [];
    end
    clusterModel.clusterFunParam = clusterFunParam;
   
    if ~exist('netArch','var')
        netArch = newNetwork();
    end
    clusterModel.netArch = netArch;
    
    if ~exist('nodeArch','var')
        nodeArch = newNodes();
    end
    clusterModel.nodeArch = nodeArch;
    
    if ~exist('p_numnode','var')
        numnode = 100; 
        p = 1 / numnode;
    else
        p = p_numnode;
    end
    %p = Probability of a cluster size
    clusterModel.p          = p;
    
    % run the clustering algorithm
    addpath Cluster % put the clustering algorithm in the cluster folder
    [nodeArch, clusterNode] = saddle(clusterModel, clusterFunParam); % execute the cluster function
    
    clusterModel.nodeArch = nodeArch;       % new architecture of nodes
    clusterModel.clusterNode = clusterNode; % the CHs
end