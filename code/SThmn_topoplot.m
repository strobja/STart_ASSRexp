function [] = SThmn_topoplot(data_freq,freqHp,freqSp,foi,eegEld)
% SThmn_topoplot - Spatial analysis of ITPC from from human subjects
% experiments and topographic maps plotting.
%
% Syntax:  [] = SThmn_topoplot(data_freq,freqHp,freqSp,foi,eegEld)
%
%
% Inputs:
%    data_freq - EEG data with ITPC freq. analysis in a FieldTrip (1 subj.)
%    freqHp - ITPC of all subjects stimulated with headphones after FA
%    freqSp - ITPC of all subjects stimulated with speakers after FA
%    foi - frequency of interest in which the topmap will be plotted
%    eegEld - EEG electrode positions in the recording
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





load('mycmap.mat')
egiLabel = strsplit(num2str(eegEld));
egiLabel = strcat('E',egiLabel)';
data_freq.label = egiLabel;

topoScaleMax = [0.155 00.129];
freqHpMean = squeeze(mean(freqHp,1));
freqSpMean = squeeze(mean(freqSp,1));


%% figures
freq=data_freq.freq;
for i=1:length(foi)
    data_freq.freq = foi(i);
    [~,foiPos] = min(abs(freq-(ones(1,length(freq))*foi(i))));
    freqHpFoi = freqHpMean(:,foiPos);
    data_freq.itpcHp(:,i) = (freqHpFoi-median(freqHpFoi))./iqr(freqHpFoi);
    
    cfg = [];
    cfg.parameter = 'itpcHp';
    cfg.xlim = [foi(i) foi(i)];
    cfg.colorbar = 'yes';
    cfg.colormap = mycmap;
    cfg.layout = 'GSN-HydroCel-256.sfp';
    cfg.zlim = [-1 1];
    cfg.comment = 'no';
    
    figure;
    topo1 = ft_topoplotER(cfg,data_freq);
    title('Mean topographic map of normalized ITPC: headphone', 'FontSize',20, 'Interpreter','latex')
    set(gca,'FontSize',18);
    c = colorbar;
    pos = get(c,'Position');
    c.Label.Position = [pos(1)/2-1.7 pos(2)-1.2];
    c.Label.Rotation = 0;
    c.Label.String = 'norm-ITPC [-]';
    c.Label.FontSize = 18;
    c.Label.Interpreter = 'latex';
    text(-0.79,-0.6,['Frequency: ' num2str(foi(i)) ' Hz'],'HorizontalAlignment','left','Interpreter','latex','FontSize', 18)
    
    
    %--------------------SP----------------------
    freqSpFoi = freqSpMean(:,foiPos);
    data_freq.itpcSp(:,i) = (freqSpFoi-median(freqSpFoi))./iqr(freqSpFoi);
    
    cfg = [];
    cfg.parameter = 'itpcSp';
    cfg.xlim = [foi(i) foi(i)];
    cfg.zlim = [0.1 topoScaleMax(i)];
    cfg.colorbar = 'yes';
    cfg.colormap = mycmap;
    cfg.layout = 'GSN-HydroCel-256.sfp';
    cfg.zlim = [-1 1];
    cfg.comment = 'no';
    
    figure;
    topo1 = ft_topoplotER(cfg,data_freq);
    title(['Mean topographic map of normalized ITPC: speaker'], 'FontSize',20, 'Interpreter','latex')
    set(gca,'FontSize',18);
    c = colorbar;
    pos = get(c,'Position');
    c.Label.Position = [pos(1)/2-1.7 pos(2)-1.2];
    c.Label.Rotation = 0;
    c.Label.String = 'norm-ITPC [-]';
    c.Label.FontSize = 18;
    c.Label.Interpreter = 'latex';
    text(-0.79,-0.6,['Frequency: ' num2str(foi(i)) ' Hz'],'HorizontalAlignment','left','Interpreter','latex','FontSize', 18)
end
