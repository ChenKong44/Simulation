function [bitrate,Energy_transit_b,Energy_transit_cm] = transmissionpower(basedistance,underground, aboveground,moisture)

%   Input:
%       prob      cluster size prob
%       spreadfactor       spreading factor of the lora
%       bandwidth       bandwidth setting
%       coderate       code rate 
%       initEnergy  Initial energy of each node
%       transEnergy Enery for transferring of each bit (ETX)
%       recEnergy   Enery for receiving of each bit (ETX)

    [L_ug, L_ab] = pathloss(underground, aboveground,moisture,frequency);
    L_path_cm = L_ab+ L_ug;
    
    [L_ug, L_ab] = pathloss(basedistance.*0.05, basedistance.*0.955,moisture,frequency);
    L_path_b = L_ab+ L_ug;

    antennagain = 15;%antenna gain
    cableloss = 10;%calbe loss
    Noisefactor = 6;%noise factor

    sf = 7;
    bw = 125;
    cr = 4./5;
    snr = -2.5.*(sf-6)-5;

    bitrate = ( sf.*bw.*cr )./ ( 2.^sf );
    Energy_transit_b = 10.* log10(bw) + Noisefactor + snr- 174 - antennagain+ cableloss+ L_path_b;
    Energy_transit_cm = 10.* log10(bw) + Noisefactor + snr- 174 - antennagain+ cableloss+ L_path_cm;

end