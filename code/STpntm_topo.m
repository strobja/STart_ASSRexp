function [data_topo] = STpntm_topo(data_segm,foi,pathSave,name,saveData)
% STpntm_topo - Topographic analysis of data measured on a human head 
% phantom and plotting a topomap.
%
% Syntax:  [data_topo] = STpntm_topo(data_segm,foi,pathSave,name,saveData)
%
%
% Inputs:
%    data_segm - preprocessed and segmented EEG data in a FieldTrip format
%    foi - frequency of interest for topographic map calculation
%    pathSave - path to the folder for saving intermediate results
%    name - name of the analyzed file
%    saveData - the decision of whether or not to store data ('yes'/'no')
%
% Outputs:
%    data_topo - EEG data after topographic analysis in FieldTrip toolbox


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





load('mycmap.mat')
egi_label = strsplit(num2str([1:256]));
egi_label = strcat('E',egi_label)';

cfg = [];
cfg.begsample = find(data_segm.time{1}>.1,1);
cfg.endsample = find(data_segm.time{1}<.35,1,'last');
data_trial = ft_redefinetrial(cfg,data_segm);


%% ITPC
cfg = [];
cfg.foi = 0:2:500;
cfg.taper = 'hanning';
cfg.method = 'mtmfft';
cfg.output = 'fourier';
cfg.keeptrials = 'yes';
cfg.channel = [1:256];
data_topo = ft_freqanalysis(cfg,data_trial);

itpc = data_topo.fourierspctrm;
module = abs(itpc);
itpc = itpc./module;
itpc = abs(mean(itpc,1));
data_topo.ITPC = squeeze(itpc);

cfg = [];
cfg.frequency = foi;
cfg.parameter = 'ITPC';
cfg.avgoverfreq = 'yes';
data_topo = ft_selectdata(cfg,data_topo);


%% topo
data_topo.label = egi_label;
medITPC = median(data_topo.ITPC,'omitnan');
noNaN = ~isnan(data_topo.ITPC);
iqrITPC = iqr(data_topo.ITPC(noNaN));
data_topo.ITPC = (data_topo.ITPC - medITPC)./iqrITPC;

cfg = [];
cfg.parameter = 'ITPC';
cfg.colorbar = 'yes';
cfg.colormap = mycmap;
cfg.layout = 'GSN-HydroCel-256.sfp';
cfg.zlim = [-1 1];
cfg.comment = 'no';
figure;
ft_topoplotER(cfg,data_topo)
title(['Topographic map of normalized ITPC: ' name(1:end-4)], 'Fontsize',20, 'Interpreter','latex')
set(gca,'FontSize',18);
c = colorbar;
pos = get(c,'Position');
c.Label.Position = [pos(1)/2-1.7 pos(2)-1.2];
c.Label.Rotation = 0;
c.Label.String = 'norm-ITPC [-]';
c.Label.FontSize = 18;
c.Label.Interpreter = 'latex';
text(-0.79,-0.6,['Frequency: ' num2str(mean(foi)) ' Hz'],'HorizontalAlignment','left','Interpreter','latex','FontSize', 18)


%% save
if saveData == 'yes'
    if ~exist([pathSave filesep 'topo'], 'dir')
        mkdir([pathSave filesep 'topo'])
    end
    save([pathSave filesep 'topo' filesep name(1:end-4) '.mat'],...
        'data_topo')
elseif saveData ~= 'no'
    error('Wrong set variable "saveData" in function for computing topographic maps, it have to be: "yes" or "no"')
end

fprintf(['Calculated topographic maps: ' name '\n\n\n'])