function [p,h] = SThmn_topobox(freqHp,freqSp,freq,foi,boxType)
% SThmn_topobox - Boxplots of correlation coefficients after spatial 
% analysis of ITPC for experiments with human subjects.
%
% Syntax:  [p,h] = SThmn_topobox(freqHp,freqSp,freq,foi,boxType)
%
%
% Inputs:
%    freqHp - ITPC of all subjects stimulated with headphones after FA
%    freqSp - ITPC of all subjects stimulated with speakers after FA
%    freq - frequency axis from frequency analysis
%    foi - frequency of interest which are compared by the correlation coef.
%    boxType - decision between what to calculate the corr. ('stim/'freq')
%
% Outputs:
%    p - p-value from paired test of correlation coefficients
%    h - accepting the alternative hypothesis (0/1) from paired tests


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


if length(foi) ~= 2
    error('Spatial comparison of headphone and speaker stimulation is only possible for 2 frequencies in the "foi" variable.')
end
if ~(any(strcmp(boxType,'stim')) || any(strcmp(boxType,'freq'))) || length(boxType)>2
    error('The "boxType" variable can only be "stim" in the case of comparing headphone and speaker stimulation, or "freq" in the case of comparing frequencies of interest!')
end

for i=1:2
    [~,foiPos] = min(abs(freq-(ones(1,length(freq))*foi(i))));
    freqHpFoi(:,:,i) = freqHp(:,:,foiPos)';
    freqSpFoi(:,:,i) = freqSp(:,:,foiPos)';
end

%% correlation HP a SP
if any(strcmp(boxType,'stim'))
    for i=1:2
        [corMatrix,pCorMatrix] = corr(freqHpFoi(:,:,i),freqSpFoi(:,:,i));
        corCoef(:,i) = diag(corMatrix);
        pCor(:,i) = diag(pCorMatrix);
        [hNorm(i),~] = lillietest((corCoef(:,i)),'Alpha',0.05);
    end
    
    figure;
    bp = boxplot(corCoef,'Labels',{num2str(foi(1)) ,num2str(foi(2))});
    set(bp,{'linew'},{2})
    title(['\bf{Boxplots of the topo. correlations: headphones/speakers}'],'FontSize',20, 'Interpreter','latex')
    set(gca,'FontSize',18);
    ylabel('Correlation coefficient [-]','Interpreter','latex')
    xlabel('Frequencies [Hz]','Interpreter','latex')
    
    if sum(hNorm) == 0
        [h_fr,p_fr] = ttest(corCoef(:,1),corCoef(:,2),'Alpha',0.05);
    else
        [p_fr,h_fr] = signrank(corCoef(:,1),corCoef(:,2),'Alpha',0.05);
    end
    p{1} = p_fr;
    h{1} = h_fr;
end

%% correlation 40 a 120 Hz
clear corMatrix pCorMatrix corCoef pCor

if any(strcmp(boxType,'freq'))
    [corMatrix,pCorMatrix] = corr(freqHpFoi(:,:,1),freqHpFoi(:,:,2));
    corCoef(:,1) = diag(corMatrix);
    pCor(:,1) = diag(pCorMatrix);
    [hNorm(1),~] = lillietest((corCoef(:,1)),'Alpha',0.05);
    
    [corMatrix,pCorMatrix] = corr(freqSpFoi(:,:,1),freqSpFoi(:,:,2));
    corCoef(:,2) = diag(corMatrix);
    pCor(:,2) = diag(pCorMatrix);
    [hNorm(2),~] = lillietest((corCoef(:,2)),'Alpha',0.05);
    
    figure;
    bp = boxplot(corCoef,'Labels',{'headphones','speakers'});
    set(bp,{'linew'},{2})
    title(['\bf{Boxplots of the topo. correlations: ' num2str(foi(1)) 'Hz/' num2str(foi(2)) 'Hz}'],'FontSize',20, 'Interpreter','latex')
    set(gca,'FontSize',18);
    ylabel('Correlation coefficient [-]','Interpreter','latex')
    xlabel('Acoustic sources [-]','Interpreter','latex')
    
    if sum(hNorm) == 0
        [h_st,p_st] = ttest(corCoef(:,1),corCoef(:,2),'Alpha',0.05);
    else
        [p_st,h_st] = signrank(corCoef(:,1),corCoef(:,2),'Alpha',0.05);
    end
    p{length(boxType)} = p_st;
    h{length(boxType)} = h_st;
end




