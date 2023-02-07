function nodeArch = newNodes(netArch, numNode,numCluster)


% Create the node model randomly
%   
%   Input:
%       netArch     Network architecture
%       numNode    Number of Nodes in the field
%   Output:
%       nodeArch    Nodes architecture
%       nodesLoc    Location of Nodes in the field


    
    if ~exist('netArch','var')
        netArch = newNetwork();
    end

    if ~exist('numCluster','var')
        numCluster = 2;
    end

    if ~exist('numNode','var')
        numNode = 50;
    end

    %for all cluster node process
    for i = 1:numNode
        % x cordination of node
        nodeArch.node(i).x      =   rand * netArch.Yard.Length;
        nodeArch.nodesLoc(i, 1) =   nodeArch.node(i).x;
        % y cordination of node
        nodeArch.node(i).y      =   rand * netArch.Yard.Width;
        nodeArch.nodesLoc(i, 2) =   nodeArch.node(i).y;

        % the flag which determines the value of the indicator function? Ci(t)
        nodeArch.node(i).G      =   0; 

        % initially there are no cluster heads, only nodes
        nodeArch.node(i).type   =   'N'; % 'N' = node (nun-CH)
        nodeArch.node(i).energy =   netArch.Energy.init;
        
        nodeArch.dead(i)        = 0; % the node is alive

        nodeArch.disconnect(i) = 0; % the node is disconnect
        nodeArch.prob(i) = rand();
    end
           

    nodeArch.numCluster = numCluster;
    nodeArch.numNode = numNode; % Number of Nodes in the field
    nodeArch.numDead = 0; % number of dead nodes
end