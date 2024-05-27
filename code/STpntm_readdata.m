function [data_segm,data_cmp,eventCmp] = STpntm_readdata(pathSegm,pathCmp,pathSave,name,saveData)
% STpntm_readdata - Reading EEG data from human head phantom after 
% preprocessing in BrainVision software (stored in EEGLAB format) and then 
% converting it to FieldTrip format.
%
% Syntax:  [data_segm,data_cmp,eventCmp] = STpntm_readdata(pathSegm,pathCmp,pathSave,name,saveData)
%
%
% Inputs:
%    pathSegm - path to the folder with preprocessed and segmented EEG data
%    pathCmp - path to the folder with same EEG data without segmentation
%    pathSave - path to the folder for saving intermediate results
%    name - name of the analyzed file
%    saveData - the decision of whether or not to store data ('yes'/'no')
%
% Outputs:
%    data_segm - preprocessed and segmented EEG data in a FieldTrip format
%    data_cmp - EEG data without segmentation in a FieldTrip format
%    eventCmp - EEG data markers in FieldTrip format


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





cfg = [];
cfg.dataset = pathSegm;
cfg.channel = [1:256];
data_segm = ft_preprocessing(cfg);


cfg = [];
cfg.dataset = pathCmp;
cfg.channel = [1:256];
eventCmp = ft_read_event(pathCmp);
data_cmp = ft_preprocessing(cfg);

cfg =[];
cfg.begsample = 20000;
cfg.endsample = length(data_cmp.trial{1});
data_cmp = ft_redefinetrial(cfg,data_cmp);

if saveData == 'yes'
    if ~exist([pathSave filesep 'raw_data'], 'dir')
        mkdir([pathSave filesep 'raw_data'])
    end
    save([pathSave filesep 'raw_data' filesep name(1:end-4) '_sgm.mat'],...
        'data_segm')
    save([pathSave filesep 'raw_data' filesep name(1:end-4) '_cmp.mat'],...
        'data_cmp','eventCmp')
elseif saveData ~= 'no'
    error('Wrong set variable "saveData" in function for read data, it have to be: "yes" or "no"')
end

fprintf(['loaded data: ' name '\n\n\n'])

