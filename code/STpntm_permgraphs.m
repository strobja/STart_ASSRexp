function [] = STpntm_permgraphs(data_perm,data_ITPC,data_ITPCbased,name,rendFigure,foi)
% STpntm_permgraphs - Plotting the outputs of the permutation analysis, 
% specifically the T-statistic, the histogram, or both.
%
% Syntax:  [] = STpntm_permgraphs(data_perm,data_ITPC,data_ITPCbased,name,rendFigure,foi)
%
%
% Inputs:
%    data_perm - EEG data after permutation test of ITPC in FieldTrip form.
%    data_ITPC - EEG data with ITPC calculated from random segments
%    data_ITPCbased - EEG data with ITPC calculated for phase-locked segm.
%    name - name of the analyzed file
%    rendFigure - deciding which graphs to plot ('Tstat'/'hist')
%    foi - frequency of interest for plotting histograms
%
% Outputs:
%    


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





if any(strcmp(rendFigure,'Tstat'))
    stat = data_perm;
    stat.stat(data_perm.prob > 0.05) = NaN;
    
    figure;
    surface(data_perm.freq,1:length(data_perm.label),stat.stat)
    ax = gca;
    ax.XGrid = 'on';
    ax.LineWidth = 1;
    GridColorMode = 'manual';
    ax.GridColor ='r';
    ax.GridAlpha = .5;
    ax.GridLineStyle = '-';
    set(gca,'FontSize',18);
    xlim([0 500]);
    xticks(0:40:500);
    xlabel('Frequency [Hz]', 'Interpreter','latex')
    ylabel('Electrodes [-]', 'Interpreter','latex')
    ylim([0 257])
    title(['T-statistic after permutation test: ' name],'Fontsize',20, 'Interpreter','latex')
    fprintf(['T-statistic permutation test plot: ' name '\n\n'])
end
if any(strcmp(rendFigure,'hist'))
    for i=1:length(foi)
        cfg = [];
        cfg.frequency = [foi(i)-1 foi(i)+1];
        cfg.parameter = 'ITPC';
        cfg.avgoverfreq = 'yes';
        meanITPC = ft_selectdata(cfg,data_ITPC);
        meanITPCbased = ft_selectdata(cfg,data_ITPCbased);
        finalITPC= mean(meanITPC.ITPC(:,1:end-1),2);
        finalITPCbased = mean(meanITPCbased.ITPC(:,1:end-1),2);
        
        figure;
        histColumn = histogram(finalITPC,20);
        hold on
        plot([finalITPCbased(1),finalITPCbased(1)],[0,max(histColumn.BinCounts(:))],'r','LineWidth',3)
        hold off
        title(['Random ITPC and ITPC phase-locked to stimul, ' num2str(foi(i)) ' Hz: ' name(1:end-4)],...
            'Fontsize',20, 'Interpreter','latex')
        lgd = legend('random ITPC','phase-locked ITPC', 'Interpreter','latex');
        lgd.FontSize = 18;
        set(gca,'FontSize',18)
        xlabel('ITPC [-]', 'Interpreter','latex')
        ylabel('frequency of ITPC [-]', 'Interpreter','latex')
        
        sortQuant=sort([finalITPC;finalITPCbased(1)]);
        quant = find(sortQuant==finalITPCbased(1))./length(sortQuant);
        text(0.104,35,['Quantile of pl-ITPC: ' num2str(round(quant,2))],'HorizontalAlignment','left','Interpreter','latex','FontSize', 16)
        fprintf(['Permutation test histogram plot for ' num2str(foi(i)) ' Hz : ' name '\n\n'])
    end
end
if ~(any(strcmp(rendFigure,'Tstat')) || any(strcmp(rendFigure,'hist')))
    error('The variable "rendFigure" must be "Tstat" to plot the T-statistic or "hist" to plot histogram of the permutation test!')
end

