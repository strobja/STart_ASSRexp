function [] = SThmn_regres(tfrHp,tfrSp,foi,freq,time,textPos)
% SThmn_regres - Linear regression between ITPC of headphones/speakers 
% stimulation calculated from time-frequency analysis(TFA) of EEG data from 
% human subjects.
%
% Syntax:  [] = SThmn_regres(tfrHp,tfrSp,foi,freq,time,textPos)
%
%
% Inputs:
%    tfrHp - ITPC of all subjects stimulated with headphones after TFA
%    tfrSp - ITPC of all subjects stimulated with speakers after TFA
%    foi - frequency of interest for which the regression will be computed
%    freq - frequency axis from time-frequency analysis
%    time - time axis from time-frequency analysis
%    textPos - position of text in figure of linear regression
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





itpcHp = squeeze(mean(mean(tfrHp(:,:,:,time>0.1 & time<0.4),2),4)); 
itpcSp = squeeze(mean(mean(tfrSp(:,:,:,time>0.1 & time<0.4),2),4)); 


%% graph

for f=1:length(foi)
    [~,foiPos] = min(abs(freq-(ones(1,length(freq))*foi(f))));
    
    hp=itpcHp(:,foiPos);
    sp=itpcSp(:,foiPos);
    tbl=table(hp,sp);
    reg = fitlm(tbl);
    p = coefTest(reg);
    slope = reg.Coefficients.Estimate(2);
    
    figure;
    plot(hp,sp,'*r')
    hold on
    plot(reg)
    hold off
    set(gca,'FontSize',18);
    xlim([0 0.8]) 
    ylim([0 0.4]) 
    text(textPos(1),textPos(2)+0.02,['Slope of fit curve is: ' num2str(round(slope,3))], 'HorizontalAlignment','left','Interpreter','latex','FontSize', 18)
    text(textPos(1),textPos(2)-0.02,['P-value of fit curve is: ' num2str(round(p,3))], 'HorizontalAlignment','left','Interpreter','latex','FontSize', 18)
    xlabel('Headphones (ITPC [-])', 'Interpreter','latex')
    ylabel('Speakers (ITPC [-])', 'Interpreter','latex')
    lgd = legend(['ITPC of subject at frequency: ' num2str(foi(f)) ' Hz']);
    title(['\bf{Relationship between different acoustic sources}'],'FontSize',20, 'Interpreter','latex')
        
    tbl = [];
    reg = [];
end

