function [L_ag] = pathloss(aboveground,moisture,frequency,temperature)
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

%    [alpha, beta] = soilmodel(moisture,frequency);
%    d_ug = underground;
   d_ag = aboveground;

%    a = alpha;
%    b = beta;
    
   freq = frequency;   
   tem = temperature;
   moi = moisture;

%    L_ug = 6.4 + 20.*log10(d_ug.*1e-3) + 20.*log10(b) + 8.69.*a.*d_ug.*1e-3;
   L_ag = 96.7+ 20.*log10(d_ag.*1e-3)-0.366.*freq-0.187.*moi+0.257.*tem;
   
  
end