function [] = SThmn_boxplot(data_tfr,tfrHp,tfrSp,foi)
% SThmn_boxplot - Boxplots of ITPC calculated from time-frequency analysis 
% (TFA) of EEG data from human subjects.
%
% Syntax:  [] = SThmn_boxplot(data_tfr,tfrHp,tfrSp,foi)
%
%
% Inputs:
%    data_tfr - EEG data with ITPC from TFA in a FieldTrip format (1 subj.)
%    tfrHp - ITPC of all subjects stimulated with headphones after TFA
%    tfrSp - ITPC of all subjects stimulated with speakers after TFA
%    foi - frequency of interest for which the boxplots will be plotted
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





timeStart = 0.1;
timeStop = 0.4;


%% compute
[~,timeStartPos] = min(abs(data_tfr.time-(ones(1,length(data_tfr.time))*timeStart)));
[~,timeStopPos] = min(abs(data_tfr.time-(ones(1,length(data_tfr.time))*timeStop)));

for i = 1:length(foi)
    [~,foiPos] = min(abs(data_tfr.freq-(ones(1,length(data_tfr.freq))*foi(i))));
    
    boxHp(:,i) = squeeze(mean(mean(mean(tfrHp(:,:,foiPos,timeStartPos:timeStopPos),2),4),3));
    boxSp(:,i) = squeeze(mean(mean(mean(tfrSp(:,:,foiPos,timeStartPos:timeStopPos),2),4),3));
    
    label{i} = [num2str(foi(i)) ' Hz'];
end


%% figure
figure;
bp = boxplot(boxHp,'Labels',label,'positions', [1 4 7]);
set(bp,{'linew'},{2})
set(gca,'FontSize',18);
xlabel('Frequency [Hz]','Interpreter','latex')
ylabel('ITPC [-]','Interpreter','latex')
title('\bf{Boxplots of subjects ITPC for different acoustic sources}','FontSize',20, 'Interpreter','latex')

hold on
bp2 = boxplot(boxSp,'Labels',label,'positions', [2 5 8]);
xlim([-.2 9])
ylim([0 .8])
lines = findobj(bp2, 'type', 'line', 'Tag', 'Median');set(lines, 'Color', 'm','linewidth',2); % Adjusting the median line
body = findobj(bp2,'type', 'line', 'tag', 'Box'); set(body, 'Color', 'c','linewidth',2);%Setting the line betwwen percentile 75 and 95
up_adj = findobj(bp2,'type', 'line', 'tag', 'Upper Whisker'); set(up_adj, 'Color', 'k','linewidth',2);% Setting the upper whiskers
low_adj= findobj(bp2, 'type', 'line','tag', 'Lower Whisker'); set(low_adj, 'Color', 'k','linewidth',2);%Setting the lower whiskers
up = findobj(bp2,'type', 'line', 'tag', 'Upper Adjacent Value'); set(up, 'Color', 'k','linewidth',2);%Setting the line betwwen percentile 75 and 95
low= findobj(bp2, 'type', 'line','tag', 'Lower Adjacent Value'); set(low, 'Color', 'k','linewidth',2);%Setting the line betwwen percentile 25 and 5

lg{1} = plot(nan, 'b','LineWidth',2);
lg{2} = plot(nan, 'c','LineWidth',2);
legend([lg{:}], {'Headphone','Speaker'}, 'location', 'best')
