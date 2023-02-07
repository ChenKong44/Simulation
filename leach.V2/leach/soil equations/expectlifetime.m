function L_expectdiff = expectlifetime(basedistance,CHdistance, initEnergy, transEnergy, recEnergy,roundArch)

%   Input:
%       prob      cluster size prob
%       spreadfactor       spreading factor of the lora
%       bandwidth       bandwidth setting
%       coderate       code rate 
%       initEnergy  Initial energy of each node
%       transEnergy Enery for transferring of each bit (ETX)
%       recEnergy   Enery for receiving of each bit (ETX)

    [L_ug, L_ab] = pathloss(20, CHdistance-20);
    L_path_b = L_ab+ L_ug;
    
    [L_ug, L_ab] = pathloss(50, basedistance-50);
    L_path_cm = L_ab+ L_ug;

    antennagain = 15;%antenna gain
    cableloss = 10;%calbe loss
    Noisefactor = 6;%noise factor

    sf = 7;
    bw = 125;
    cr = 4./5;
    snr = -2.5.*(sf-6)-5;

    bitrate = ( sf.*bw.*cr )./ ( 2.^sf );
    Energy.transit_b = 10.* log10(bw) + Noisefactor + snr- 174 - antennagain+ cableloss+ L_path_b;
    Energy.transit_cm = 10.* log10(bw) + Noisefactor + snr- 174 - antennagain+ cableloss+ L_path_cm;


    % Energy Model (all values in Joules)
    % Initial Energy
    if ~exist('initEnergy','var')
        Energy.init = 0.5; 
    else
        Energy.init = initEnergy; 
    end
    
    % Enery for transferring of each bit (ETX)


    if ~exist('transEnergy','var')
        Energy.transfer = 50*0.000000001;
    else
        Energy.transfer = transEnergy; 
    end
    if ~exist('recEnergy','var')
        Energy.receive = 50*0.000000001;
    else
        Energy.receive = recEnergy; 
    end
    syms z
    L_expect(z) = Energy.init ./ ( ( (z-1)./ z ) .*(Energy.receive+Energy.transfer).* roundArch.packetLength ./ bitrate+...
        roundArch.ctrPacketLength.*Energy.transfer./ ( z.* bitrate ) );
    L_expectdiff = diff(L_expect(z));

end