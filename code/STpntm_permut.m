function [data_perm,data_ITPC,data_ITPCbased] = STpntm_permut(data_segm,eventCmp,pathMarker,pathSave,name,saveData)
% STpntm_permut - Computation of permutation test from ITPC phase-locked  
% to the start of stimulation and random ITPC for data measured on a human 
% head phantom.
%
% Syntax:  [data_perm,data_ITPC,data_ITPCbased] = STpntm_permut(data_raw,eventCmp,pathMarker,pathSave,name,saveData)
%
%
% Inputs:
%    data_segm - preprocessed and segmented EEG data in a FieldTrip format
%    eventCmp - EEG data markers in FieldTrip format
%    pathMarker - path to EEG markers of bad segments stored in .txt
%    pathSave - path to the folder for saving intermediate results
%    name - name of the analyzed file
%    saveData - the decision of whether or not to store data ('yes'/'no')
%
% Outputs:
%    data_perm - EEG data after permutation test of ITPC in FieldTrip form.
%    data_ITPC - EEG data with ITPC calculated from random segments
%    data_ITPCbased - EEG data with ITPC calculated for phase-locked segm.


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





lTrials = 0.5;
trialOffs = 0.0;
nRep = 400;

load('mycmap.mat')
Fs = data_segm.fsample;
%% preproc_adaptation

eventArt = eventCmp(strcmp({eventCmp.value},'New Marker'));
artLeng = readtable(pathMarker);

lSignal = length(data_segm.time{1});
lArtifact = ([eventArt(2:end).sample]'+artLeng.Length);
posArtifact = [eventArt(2:end).sample]';
if eventArt(1).sample <= 1*Fs
    idx = find(lArtifact-[posArtifact(2:end); lSignal] < 0, 1);
    trialStart = trialOffs*Fs+lArtifact(idx);
else
    trialStart = trialOffs*Fs;
    idx = 0;
end
nTrials = length(data_segm.trial);
trialHelp = abs(floor( trialStart+ (rand(nRep,nTrials) *(lSignal-((lTrials*Fs)+trialStart)) )));
posTrials = trialHelp(:,1:1:end);
for a = idx+1:length(posArtifact)
    posCange = find(posTrials > posArtifact(a) & posTrials < lArtifact(a));
    posTrials(posCange) = posTrials(posCange) + artLeng.Length(a)+trialOffs*Fs;
    posCange = [];
end


%% permutation
for j = 1:nRep+1
    if j == 1
        cfg = [];
        cfg.latency = [trialOffs lTrials+trialOffs];
        data_trl = ft_selectdata(cfg, data_segm);
        
        % --------------------compute ITPC-------------------------------------------------
        cfg = [];
        cfg.method = 'mtmfft';
        cfg.output = 'fourier';
        cfg.keeptrials = 'yes';
        cfg.taper = 'hanning';
        cfg.foi = 0:2:500;
        data_ITPCbased = ft_freqanalysis(cfg,data_trl);
        
        coefAll = (data_ITPCbased.fourierspctrm);
        module = abs(coefAll);
        coefNorm = coefAll./module;
        itpcBased = squeeze(abs(mean(coefNorm,1)));
    else
        trl1 = posTrials(j-1,:);
        trl2 = trl1+(lTrials*Fs);
        trl3 = zeros(1,length(trl1));
        
        cfg = [];
        cfg.trl = [trl1' trl2' trl3'];
        data_trl = ft_redefinetrial(cfg,data_segm);
        
        % --------------------compute ITPC-------------------------------------------------
        clear data_ITPC
        
        cfg = [];
        cfg.method = 'mtmfft';
        cfg.output = 'fourier';
        cfg.keeptrials = 'yes';
        cfg.taper = 'hanning';
        cfg.foi = 0:2:500;
        data_ITPC = ft_freqanalysis(cfg,data_trl);
        
        coefAll = (data_ITPC.fourierspctrm);
        module = abs(coefAll);
        coefNorm = coefAll./module;
        itpc(j-1,:,:) = squeeze(abs(mean(coefNorm,1)));
        
        data_ITPCbased.ITPC(j-1,:,:) = itpcBased;
    end
end
data_ITPC.ITPC = itpc;


%% permutation test
data_ITPC.cumtapcnt = ones(nRep,1);
data_ITPCbased.cumtapcnt = ones(nRep,1);

nTrl  = size(data_ITPC.ITPC, 1);
nTrlBase = size(data_ITPCbased.ITPC, 1);

cfg = [];
cfg.parameter = 'ITPC';
cfg.method = 'montecarlo';
cfg.statistic = 'depsamplesT';
cfg.correctm = 'no';
cfg.minnbchan = 2;
cfg.alpha = 0.05;
cfg.tail = 1;
cfg.numrandomization = 750;
cfg.design(1,:) = [1:nTrlBase 1:nTrl];
cfg.design(2,:) = [ones(1,nTrlBase) ones(1,nTrl)*2];
cfg.uvar   = 1;
cfg.ivar   = 2;

data_perm = ft_freqstatistics(cfg,data_ITPCbased,data_ITPC);

%% save
if saveData == 'yes'
    if ~exist([pathSave filesep 'permut'], 'dir')
        mkdir([pathSave filesep 'permut'])
    end
    save([pathSave filesep 'permut' filesep name(1:end-4) '.mat'],...
        'data_perm','data_ITPCbased','data_ITPC','-v7.3')
elseif saveData ~= 'no'
    error('Wrong set variable "saveData" in function for computing permutation test, it have to be: "yes" or "no"')
end

fprintf(['Computing of permutation test: ' name '\n\n\n'])
