function [] = SThmn_tfr(data_tfr,tfrHp,tfrSp)
% SThmn_tfr - Time-frequency analysis (TFA) of EEG data from human
% subjects plotting.
%
% Syntax:  [] = SThmn_tfr(data_tfr,tfrHp,tfrSp)
%
%
% Inputs:
%    data_tfr - EEG data with ITPC from TFA in a FieldTrip format (1 subj.)
%    tfrHp - ITPC of all subjects stimulated with headphones after TFA
%    tfrSp - ITPC of all subjects stimulated with speakers after TFA
%
% Outputs:
%


% This function is part of STart_ASSRexp pipeline for Simulus Transduction
% artifact analysis in neuro-psychiatric ASSR experiments (specifically the
% part using the human subjects) and was created for publication:
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





load('mycmap.mat');

data_tfr.ITPC_HP = squeeze(mean(tfrHp,1));
data_tfr.ITPC_SP = squeeze(mean(tfrSp,1));

meanHPitpc=mean(mean(data_tfr.ITPC_HP,3),2);
posHpEld= find(meanHPitpc>quantile(meanHPitpc,0.95));

meanSPitpc=mean(mean(data_tfr.ITPC_SP,3),2);
posSpEld= find(meanSPitpc>quantile(meanSPitpc,0.95));


%% figures
cfg = [];
cfg.parameter = 'ITPC_HP';
cfg.latency = [-0.3 0.95];
cfg.channel = posHpEld;
cfg.zlim = [-0.25 0.25];
cfg.baseline = [-0.2 -0.02];
cfg.colormap = mycmap;
cfg.baselinetype = 'absolute';
figure;
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
set(gca,'FontSize',18);
ylabel('Frequency [Hz]','Interpreter','latex')
ylim([20 260]);
yticks(40:40:240);
xlabel('Time [s]','Interpreter', 'latex')
xlim([-0.15 0.55]);
title(['Time-frequency response of normed-ITPC: headphones'],'Fontsize',20, 'Interpreter','latex')
pos = get(c,'Position');
c.Label.Position = [pos(1)/2+1.4 pos(2)-0.44];
c.Label.Rotation = 0;
c.Label.String = 'n-ITPC [-]';
c.Label.FontSize = 18;
c.Label.Interpreter = 'latex';


cfg = [];
cfg.parameter = 'ITPC_SP';
cfg.latency = [-0.3 0.95];
cfg.channel = posSpEld;
cfg.zlim = [-0.25 0.25];
cfg.baseline = [-0.2 -0.02];
cfg.colormap = mycmap;
cfg.baselinetype = 'absolute';
figure;
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
set(gca,'FontSize',18);
ylabel('Frequency [Hz]','Interpreter','latex')
ylim([20 260]);
yticks(40:40:240);
xlabel('Time [s]','Interpreter', 'latex')
xlim([-0.15 0.55]);
title(['Time-frequency response of norm-ITPC: speakers'],'Fontsize',20, 'Interpreter','latex')
c = colorbar;
c.FontSize  = 18;
pos = get(c,'Position');
c.Label.Position = [pos(1)/2+1.4 pos(2)-0.44];
c.Label.Rotation = 0;
c.Label.String = 'n-ITPC [-]';
c.Label.FontSize = 18;
c.Label.Interpreter = 'latex';


fprintf(['Mean graphs of TFR analysis \n\n\n'])







