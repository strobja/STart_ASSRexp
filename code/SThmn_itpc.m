function [itpc_tfr,itpc_freq] = SThmn_itpc(path,eegEld,itpcAnal,pathSave,name,saveData)
% SThmn_itpc - Reading EEG data from human subjects after preprocessing in
% BrainVision software (stored in EEGLAB format), ITPC calculation (for
% frequency or time-frequency analysis), and converting it to FieldTrip.
%
% Syntax:  [itpc_tfr,itpc_freq] = SThmn_itpc(path,eegEld,itpcAnal,pathSave,name,saveData)
%
%
% Inputs:
%    path - path to the folder with preprocessed and segmented EEG data
%    eegEld - EEG electrode positions in the recording
%    itpcAnal - decision over the type of analysis ('tfr'/'freq'/'yes'/'no')
%    pathSave - path to the folder for saving intermediate results
%    name - name of the analyzed file
%    saveData - the decision of whether or not to store data ('yes'/'no')
%
% Outputs:
%    itpc_tfr - EEG data with ITPC from TFA in a FieldTrip format
%    itpc_freq - EEG data with ITPC from freq. analysis in a FieldTrip form.


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


cfg = [];
cfg.dataset = path;
cfg.channel = eegEld;
data_prepro = ft_preprocessing(cfg);

itpc_tfr = [];
itpc_freq = [];

%% compute TFR ITPC
if any(strcmp(itpcAnal,'tfr'))
    cfg = [];
    cfg.foi = 20:1:250;
    cfg.toi = -0.15:0.05:0.59; %-0.25:0.05:0.74;
    cfg.t_ftimwin = 0.5*ones(1,length(cfg.foi));
    cfg.taper = 'hanning';
    cfg.method = 'mtmconvol';
    cfg.output = 'fourier';
    cfg.keeptrials = 'yes';
    data_tfr = ft_freqanalysis(cfg,data_prepro);
    
    itpc_tfr = data_tfr.fourierspctrm./(abs(data_tfr.fourierspctrm));
    itpc_tfr =abs(mean(itpc_tfr,1));
    data_tfr.ITPC = squeeze(itpc_tfr);
    data_tfr.dimord = 'chan_freq_time';
    
    
    %% save
    if any(strcmp(saveData,'tfr')) || any(strcmp(saveData,'yes'))
        if ~exist([pathSave filesep 'TFR'], 'dir')
            mkdir([pathSave filesep 'TFR'])
        end
        save([pathSave filesep 'TFR' filesep name(1:end-4) '.mat'],...
            'data_tfr','data_prepro','-v7.3')
    elseif ~any(strcmp(saveData,'freq')) && ~any(strcmp(saveData,'no'))
        error('Wrong set variable "saveData" in function for time-frequency analysis, it have to be: "yes", "no" or "tfr", "freq"')
    end
    
    fprintf(['compute TFR analysis: ' name '\n\n'])
    
end

%% compute freq ITPC
if any(strcmp(itpcAnal,'freq'))
    cfg = [];
    cfg.begsample = find(data_prepro.time{1}>=0.1,1);
    cfg.endsample = find(data_prepro.time{1}<=0.35,1,'last');
    data_after = ft_redefinetrial(cfg,data_prepro);
    
    cfg = [];
    cfg.foi = 0:2:500;
    cfg.taper = 'hanning';
    cfg.method = 'mtmfft';
    cfg.output = 'fourier';
    cfg.keeptrials = 'yes';
    cfg.channel = 'all';
    data_freq = ft_freqanalysis(cfg,data_after);
    
    itpc_freq = data_freq.fourierspctrm./(abs(data_freq.fourierspctrm)); % computing of the ITPC
    itpc_freq =abs(mean(itpc_freq,1));
    data_freq.ITPC = squeeze(itpc_freq);
    data_freq.dimord = 'chan_freq';
    
    
    %% save
    if any(strcmp(saveData,'freq')) || any(strcmp(saveData,'yes'))
        if ~exist([pathSave filesep 'freq'], 'dir')
            mkdir([pathSave filesep 'freq'])
        end
        save([pathSave filesep 'freq' filesep name(1:end-4) '.mat'],...
            'data_freq','data_after','-v7.3')
    elseif ~any(strcmp(saveData,'tfr')) && ~any(strcmp(saveData,'no'))
        error('Wrong set variable "saveData" in function for frequency analysis, it have to be: "yes", "no" or "tfr", "freq"')
    end
    
    fprintf(['compute Freq analysis: ' name '\n\n'])
    
end














