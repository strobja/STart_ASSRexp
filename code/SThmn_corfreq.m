function [] = SThmn_corfreq(tfrHp,tfrSp,freq,time)
% SThmn_corfreq - Cross-frequency correlation of ITPC calculated from time-frequency analysis 
% (TFA) of EEG data from human subjects.
%
% Syntax:  [] = SThmn_corfreq(tfrHp,tfrSp,freq,time)
%
%
% Inputs:
%    tfrHp - ITPC of all subjects stimulated with headphones after TFA
%    tfrSp - ITPC of all subjects stimulated with speakers after TFA
%    freq - frequency axis from time-frequency analysis
%    time - time axis from time-frequency analysis
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

itpcHp = squeeze(mean(mean(tfrHp(:,:,:,time>0.1 & time<0.4),2),4)); 
itpcSp = squeeze(mean(mean(tfrSp(:,:,:,time>0.1 & time<0.4),2),4)); 


%% graphs
[corHp,~] = corrcoef(itpcHp);
figure;
imagesc(freq,freq,corHp)
c=colorbar;
pos = get(c,'Position');
c.Label.Position = [pos(1)/2+2.4 pos(2)-0.13]; 
c.Label.String = 'Correlation. coef. [-]';
c.Label.FontSize = 18;
c.Label.Interpreter = 'latex';
colormap(mycmap)
set(gca,'FontSize',18,'YDir','normal');
ax = gca;
GridColorMode = 'manual';
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.LineWidth = 1;
ax.GridColor ='k';
ax.GridAlpha = 1;
ax.GridLineStyle = '--';
xlabel('Frequency [Hz]', 'Interpreter','latex')
xticks(0:40:250);
ylabel('Frequency [Hz]', 'Interpreter','latex')
yticks(0:40:250);
title('Map of cross-frequency correlation coefficients: headphones', 'FontSize',20, 'Interpreter','latex')
caxis([-0.7 0.7])


[corSp,~] = corrcoef(itpcSp);
figure;
imagesc(freq,freq,corSp)
c=colorbar;
pos = get(c,'Position');
c.Label.Position = [pos(1)/2+2.4 pos(2)-0.13]; 
c.Label.String = 'Correlation coef. [-]';
c.Label.FontSize = 18;
c.Label.Interpreter = 'latex';
colormap(mycmap)
set(gca,'FontSize',18,'YDir','normal');
ax = gca;
GridColorMode = 'manual';
ax.XGrid = 'on';
ax.YGrid = 'on';
ax.LineWidth = 1;
ax.GridColor ='k';
ax.GridAlpha = 1;
ax.GridLineStyle = '--';
xlabel('Frequency [Hz]', 'Interpreter','latex')
xticks(0:40:250);
ylabel('Frequency [Hz]', 'Interpreter','latex')
yticks(0:40:250);
title('Map of cross-frequency correlation coefficients: speakers', 'FontSize',20, 'Interpreter','latex')
caxis([-0.7 0.7])
   
