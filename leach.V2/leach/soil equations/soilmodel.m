function [alpha, beta] = soilmodel(moisture,frequency)
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


   ep_0 = 8.854.* 1e-11;   %free-space permittivity
   mu_0 = 0.5;              %permeability in vacuum
   mu_r = 1;              %soil relative permeability
    
   freq = frequency.*1e6;    %frequency
   ro_b = 1.07;            %bulk density in grams per cubic centimeter
   ro_s = 2.66;            %specific gravity of the solid soil particles
   m_v = moisture;      %moisture level
   ep_win = 4.9;        %high-frequency limit of DC for water
   ep_w0 = 80.1;        %low-frequency limit of DC for water
   
   S = 51.51./100;         %sand
   C = 13.43./100;         %clay
   
   tau_w = 0.58.* (1e-9)./ (2.*pi);                      %relaxation time for free water
   ep_s = ( 1.01+ 0.44.* ro_s ).^2- 0.062;                 %specific gravity DC
   mue_eff = -1.645+ 1.939.*ro_b - 0.02313.*S + 0.01594.*C;%effective conductivity
   
   ep_fwpr = ep_win + ( ep_w0- ep_win )./ (1+ ( 2.* pi.* freq.* tau_w ).^2);
   %DC of free water
   ep_fwprr = (2.* pi.* freq.* tau_w.* ( ep_w0- ep_win ))./ (1+ ( 2.* pi.* freq.* tau_w ).^2) + ( mue_eff)./ ( 2.*pi .* ep_0.* freq);
   %LF of free water
   
   b_pr = ( 127.48- 0.519.*S- 0.152.*C )./ 100;
   b_prr = ( 1.33797 - 0.603.*S- 0.166.*C )./100;
   
   ep_pr = (1 + ( ro_b./ ro_s ).* (ep_s.^0.65-1)+ ( m_v.^b_pr ).* ( ep_fwpr.^0.65 )- m_v).^(1./0.65);
   ep_prr = (( (m_v.^b_prr).* (ep_fwprr.^0.65) ).^(1./0.65));
   
    

   alpha = 2.*pi.* freq.* sqrt(( (mu_0.* mu_r.* ep_pr.* ep_0).* ( sqrt( 1+(ep_prr./ ep_pr).^2 )-1 ) )./ 2);
   beta = 2.*pi.* freq.* sqrt(( (mu_0.* mu_r.* ep_pr.* ep_0).* ( sqrt( 1+(ep_prr./ ep_pr).^2 )+1 ) )./ 2);
   
  
end