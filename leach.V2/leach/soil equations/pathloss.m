function [L_ug, L_ab] = pathloss(netArch, numNode)
% Create the node model randomly
%   
%   Input:
%       netArch     Network architecture
%       numNode    Number of Nodes in the field
%   Output:
%       nodeArch    Nodes architecture
%       nodesLoc    Location of Nodes in the field
%   Example:
%       netArch  = createNetwork();
%       nodeArch = createNodes(netArch, 100)
%
% Hossein Dehghan, hd.dehghan@gmail.com
% Ver 1. 2/2013
   d_ug = 1;
   d_ag = 2;

   beta = 0.5;
   alpha = 0.8;
    
   freq = 2.4.*10e8;   

   L_ug = 6.4 + 20.*log10(d_ug) + 20.*log10(beta) + 8.69.*alpha.*d_ug;
   L_ab = -147.6 + 20.*log10(d_ag) + 20.*log10(freq);
   
  
end