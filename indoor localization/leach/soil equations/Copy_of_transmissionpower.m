
%   Input:
%       prob      cluster size prob
%       spreadfactor       spreading factor of the lora
%       bandwidth       bandwidth setting
%       coderate       code rate 
%       initEnergy  Initial energy of each node
%       transEnergy Enery for transferring of each bit (ETX)
%       recEnergy   Enery for receiving of each bit (ETX)

    [L_ug, L_ab] = pathloss(0.0003, 0.7,0.3,923.3);
    L_path_cm = L_ab+ L_ug;

%     [L_ug, L_ab] = pathloss(mean_CMS_distance.*0.158, mean_CMS_distance.*0.9,moisture,frequency);
%     L_path_cm_cm = L_ug;
%     
%     [L_ug, L_ab] = pathloss(basedistance.*0.03, basedistance.*0.97,moisture,frequency);
%     L_path_b = L_ab+ L_ug;

    antennagain = 6;%antenna gain
    cableloss = 10;%calbe loss
    Noisefactor = 6;%noise factor

    sf = 7;
    bw = 125.*1e3;
    cr = 4./5;
    snr = -2.5.*(sf-6)-5;

    bitrate = (bw ./ (2.^sf)) .* (4 ./ (4 + cr));
    RSSI = 26+antennagain-L_path_cm-10;
