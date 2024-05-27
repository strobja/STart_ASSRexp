function [impedance] = STpntm_imped(data_perm,pathImp,pathSave,name,saveData)
% STpntm_imped - Spatial analysis of electrode impedances and plotting
% topomaps
%
% Syntax:  [impedance] = STpntm_imped(data_perm,pathImp,pathSave,name,saveData)
%
%
% Inputs:
%    data_perm - EEG data after permutation test of ITPC in FieldTrip form.
%    pathImp - path to the folder with EEG data containing impedance info.
%    pathSave - path to the folder for saving intermediate results
%    name - name of the analyzed file
%    saveData - the decision of whether or not to store data ('yes'/'no')
%
% Outputs:
%    impedance - data with impedance of electrodes


% This function is part of STart_ASSRexp pipeline for Simulus Transduction
% artifact analysis in neuro-psychiatric ASSR experiments (specifically the
% part using the human head phantom) and was created for publication:
% Unveiling Stimulus Transduction Artifacts in Auditory Steady-State
% Response Experiments: Characterization, Risks, and Mitigation Strategies.
% DOI: 10. (see: htpp )
%
% STart_ASSRexp is a free analysis pipeline: you can redistribute it and/or
% modify it under the terms of the GNU Affero General Public License as
% published by the Free Software Foundation, either version 3 of the
% License, or (at your option) any later version.
%
% STart_ASSRexp is distributed in the hope that it will be useful, but
% WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero
% General Public License for more details.
%
% URL:          https://github.com/strobja/STart_ASSRexp
% DOI:          10.
% Authors:      Jan Strobl
% Copyright:    Copyright (c) 2024, National Institute of Mental Health,
%               Klecany, Czech Republic
% License:      GNU AFFERO GENERAL PUBLIC LICENSE (AGPL) 3.0.
%               For license details see the LICENSE file.
%               For other licensing options including more permissive
%               licenses, please contact the first author (jan.strobl@nudz.cz)





formatSpec = '%*q%f%f%*[^\n\r]'; 
delimiter = {':','<','>','"'};
load([pathImp(1:end-3) 'mat'])
load('mycmap.mat')

dataHeader = ft_read_header(pathImp, 'headerformat', 'egi_mff_v2');
nEEGchan = sum(strcmp(dataHeader.chantype,'eeg'));
startRow = 25 + nEEGchan + 1;
endRow = startRow + nEEGchan;

humanfileID = fopen([pathImp '\info1.xml'],'r'); 
impedanceControl = textscan(humanfileID, formatSpec, endRow-startRow, 'Delimiter', delimiter, 'MultipleDelimsAsOne', true, 'HeaderLines', startRow-1, 'ReturnOnError', false);
fclose(humanfileID);
impedance = impedanceControl{2};

%% topo plot
egi_label = strsplit(num2str([1:256]));
egi_label = strcat('E',egi_label)';

cfg = [];
cfg.avgoverfreq = 'yes';
data_stat = ft_selectdata(cfg,data_perm);

data_stat.impedance = 20*log10(impedance(1:256));
data_stat.impedance(interpol_label) = NaN;
data_stat.label = egi_label;

cfg = [];
cfg.parameter = 'impedance';
cfg.colorbar = 'yes';
cfg.colormap = mycmap;
cfg.comment = 'no';
cfg.layout = 'GSN-HydroCel-256.sfp';
cfg.zlim = [0 61];
cfg.interpolatenan = 'yes';
cfg.interpolation = 'v4';
cfg.interplimits = 'head';
figure;
ft_topoplotER(cfg,data_stat)
title(['Topogr. map of electrodes impedance (log): ' name(1:end-4)], 'Fontsize',20, 'Interpreter','latex')
set(gca,'FontSize',18);
c = colorbar;
pos = get(c,'Position');
c.Label.Position = [pos(1)/2-2.5 pos(2)-2.4];
c.Label.Rotation = 0;
c.Label.String = 'Impedance [k$\Omega$]';
c.Label.FontSize = 18;
c.Label.Interpreter = 'latex';
c.Ticks = [0, 20, 40, 60];
c.TickLabels = {'0', '10', '100', '1000'};


%% save

if saveData == 'yes'
    if ~exist([pathSave filesep 'impedance'], 'dir')
        mkdir([pathSave filesep 'impedance'])
    end
    save([pathSave filesep 'impedance' filesep name(1:end-4) '.mat'],...
        'impedance')
elseif saveData ~= 'no'
    error('Wrong set variable "saveData" in function for computing impedance, it have to be: "yes" or "no"')
end

fprintf(['Calculated impedance: ' name '\n\n\n'])



