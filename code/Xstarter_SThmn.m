% This code is the input to the call individual functions calculating the 
% analyses on the HUMAN subjects. The SThmn_itpc function is run for each 
% recording individually and the outputs are stored in variables separated 
% by the type of stimulation (headphones vs. speakers). Other functions are 
% run on the resulting variables containing information from all records. 


% This code runs the STart_ASSRexp pipeline analysis for data measured on 
% the HUMAN subjects.  This is a project analyzing the Simulus 
% Transduction artifact in neuro-psychiatric ASSR experiments. The analyses 
% were created as part of a scientific publication: 
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





clear all
close all
clc

ft_defaults

%% Set parameters
filePathRead = 'data\human\data';
filePathSave = 'data\human';


%% loop
fileHp = dir([filePathRead filesep 'headphone' filesep '*.set']);
fileSp = dir([filePathRead filesep 'speaker' filesep '*.set']);
if length(fileHp) ~= length(fileSp)
    error('The amount of .set files must be the same in the "headphone" folder and in the "speaker" folder (each subject must be measured during stimulation with both speakers and headphones).')
end

for i = 1:length(fileHp)
    %% read data
    if ~strcmp(fileHp(i).name(1:6),fileSp(i).name(1:6))
        error(['Records ' num2str(i) ' does not have the same first letter name in the folders "headphone" and "speaker", there is a risk of comparing records from different subjects!'])
    end
    
    nameHp = fileHp(i).name;
    nameSp = fileSp(i).name;
    pathPreproHp = [filePathRead filesep 'headphone' filesep nameHp]; 
    pathPreproSp = [filePathRead filesep 'speaker' filesep nameSp]; 
    eegEld = [1:90, 92:215 217:256];
    itpcAnal = {'tfr','freq'};
    saveData = {'tfr','freq'}; %or 'yes'/'no'
    
    [tfrHp(i,:,:,:),freqHp(i,:,:)] = SThmn_itpc(pathPreproHp,eegEld,itpcAnal,...
        [filePathSave  filesep 'headphone'],nameHp,saveData); 
    [tfrSp(i,:,:,:),freqSp(i,:,:)] = SThmn_itpc(pathPreproSp,eegEld,itpcAnal,...
        [filePathSave  filesep 'speaker'],nameSp,saveData); 
    
end

save([filePathSave filesep 'Xtfr.mat'], 'tfrHp','tfrSp')
save([filePathSave filesep 'Xfreq.mat'], 'freqHp','freqSp')


%% TFR
%In case You don't want to recalculate each subsection
%     load([filePathSave filesep 'Xtfr.mat']);
%     file = dir([filePathRead filesep 'headphone' filesep '*.set']); nameHp = file(1).name;
    load([filePathSave filesep 'headphone' filesep 'TFR' filesep nameHp(1:end-3) 'mat']);    

SThmn_tfr(data_tfr,tfrHp,tfrSp); 


%% boxplot itpc
%In case You don't want to recalculate each subsection
%     load([filePathSave filesep 'Xtfr.mat']);
%     file = dir([filePathRead filesep 'headphone' filesep '*.set']); nameHp = file(1).name;
%     load([filePathSave filesep 'headphone' filesep 'TFR' filesep nameHp(1:end-3) 'mat']);    

foi = [40 80 120];

SThmn_boxplot(data_tfr,tfrHp,tfrSp,foi)


%% topo
%In case You don't want to recalculate each subsection
%     load([filePathSave filesep 'Xfreq.mat']);
%     file = dir([filePathRead filesep 'headphone' filesep '*.set']); nameHp = file(1).name;
    load([filePathSave filesep 'headphone' filesep 'freq' filesep nameHp(1:end-3) 'mat']);    

foi = [40 120];
boxType = {'freq'}; %or 'stim'
freq = data_freq.freq;

SThmn_topoplot(data_freq,freqHp,freqSp,foi,eegEld)    
[pTopo,hTopo] = SThmn_topobox(freqHp,freqSp,freq,foi,boxType);


%% regression
%In case You don't want to recalculate each subsection
%     load([filePathSave filesep 'Xtfr.mat']);
%     file = dir([filePathRead filesep 'headphone' filesep '*.set']); nameHp = file(1).name;
%     load([filePathSave filesep 'headphone' filesep 'TFR' filesep nameHp(1:end-3) 'mat']);    

foi = [40 80 120]; 
time = data_tfr.time;
freq = data_tfr.freq;
textPos = [0.025 0.24];

SThmn_topobox(tfrHp,tfrSp,foi,freq,time,textPos)


%% frequency correlation
%In case You don't want to recalculate each subsection
%     load([filePathSave filesep 'Xtfr.mat']);
%     file = dir([filePathRead filesep 'headphone' filesep '*.set']); nameHp = file(1).name;
%     load([filePathSave filesep 'headphone' filesep 'TFR' filesep nameHp(1:end-3) 'mat']);    

time = data_tfr.time;
freq = data_tfr.freq;

SThmn_corfreq(tfrHp,tfrSp,freq,time)
