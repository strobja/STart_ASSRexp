function [data_tfr] = STpntm_tfr(data_segm,pathSave,name,saveData)
% STpntm_tfr - Time-Frequency Analysis of ITPC from data measured on a
% human head phantom and TFA plotting.
%
% Syntax:  [data_tfr] = STpntm_tfr(data_segm,pathSave,name,saveData)
%
%
% Inputs:
%    data_segm - preprocessed and segmented EEG data in a FieldTrip format
%    pathsave - path to the folder for saving intermediate results
%    name - name of the analyzed file
%    saveData - the decision of whether or not to store data ('yes'/'no')
%
% Outputs:
%    data_tfr - EEG data after time-frequency analysis in FieldTrip toolbox


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

cfg = [];
cfg.foi = 20:1:250;
cfg.channel = [1:256];
cfg.toi = -0.25:0.05:0.74;
cfg.t_ftimwin = 0.5*ones(1,length(cfg.foi));
cfg.taper = 'hanning';
cfg.method = 'mtmconvol';
cfg.output = 'fourier';
cfg.keeptrials = 'yes';
data_tfr = ft_freqanalysis(cfg,data_segm);


itpc = data_tfr.fourierspctrm;
module = abs(itpc);
itpc = itpc./module;
itpc =abs(mean(itpc,1));

data_tfr.ITPC = squeeze(itpc);
data_tfr.dimord = 'chan_freq_time';

%% plot and save
meamITPC=mean(mean(itpc,3),4);
posITPC = find(meamITPC>quantile(meamITPC,0.95));

cfg = [];
cfg.parameter = 'ITPC';
cfg.latency = [-0.35 0.95];
cfg.channel = posITPC;
cfg.zlim = [-0.25 0.25];
cfg.baseline = [-0.2 -0.02];
cfg.colormap = mycmap;
cfg.baselinetype = 'absolute';
figure();
ft_singleplotTFR(cfg,data_tfr)

ax = gca;
ax.YGrid = 'on';
ax.LineWidth = 1;
GridColorMode = 'manual';
ax.GridColor ='k';
ax.GridAlpha = .3;
ax.GridLineStyle = '--';
c = colorbar;
c.FontSize  = 18;
c = colorbar;
pos = get(c,'Position');
c.Label.Position = [pos(1)/2+1.4 pos(2)-0.38];
c.Label.Rotation = 0;
c.Label.String = 'n-ITPC [-]';
c.Label.FontSize = 18;
c.Label.Interpreter = 'latex';
set(gca,'FontSize',18);
ylabel('Frequency [Hz]','Interpreter', 'latex')
ylim([20 260]);
yticks(40:40:240);
xlabel('Time [s]','Interpreter','latex')
xlim([-0.15 0.55]);
title(['Time-frequency response of norm-ITPC: ' name],'Fontsize',20, 'Interpreter','latex')


if saveData == 'yes'
    if ~exist([pathSave filesep 'TFR'], 'dir')
        mkdir([pathSave filesep 'TFR'])
    end
    save([pathSave filesep 'TFR' filesep name(1:end-4) '.mat'],...
        'data_tfr','itpc','-v7.3')
elseif saveData ~= 'no'
    error('Wrong set variable "saveData" in function for time-frequency analysis, it have to be: "yes" or "no"')
end

fprintf(['TFR analysis: ' name '\n\n\n'])
