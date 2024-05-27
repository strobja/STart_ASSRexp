% This code is the input to the call individual functions calculating the 
% analyses on the human head PHANTOM. Functions are run individually for 
% each record. 


% This code runs the STart_ASSRexp pipeline analysis for data measured on 
% the human head PHANTOM.  This is a project analyzing the Simulus 
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
filePathRead = 'data\phantom\data_segm';
filePathReadCmp = 'data\phantom\data_cmp';
filePathReadImp = 'data\phantom\data_mff';
filePathSave = 'data\phantom';

load('mycmap.mat')


%% loop
fileSet = dir([filePathRead filesep '*.set']);

%In case You don't want to recalculate each subsection
fileSegm = dir([filePathSave filesep 'raw_data' filesep '*sgm.mat']);

for i = 1:length(fileSet)
    %% read data
    name = fileSet(i).name;
    pathSegm = [filePathRead filesep name];
    pathCmp = [filePathReadCmp filesep name(1:end-3) 'edf'];
    
    saveData = 'yes';
    
    [data_segm, ~, eventCmp] = STpntm_readdata(pathSegm,pathCmp,filePathSave,name,saveData); 
    
    %% TFR analysis
    %In case You don't want to recalculate each subsection
%     help = dir([filePathReadImp filesep '*.mff']); name = help(i).name; clear help 
%     load([filePathSave filesep 'raw_data' filesep fileSegm(i).name]);
    
    saveData = 'yes';

    [data_tfr] = STpntm_tfr(data_segm,filePathSave,name,saveData); 
    
    
    %% permutation analysis
    %In case You don't want to recalculate each subsection
%     help = dir([filePathReadImp filesep '*.mff']); name = help(i).name; clear help 
%     load([filePathSave filesep 'raw_data' filesep fileSegm(i).name]);
%     load([filePathSave filesep 'raw_data' filesep fileSegm(i).name(1:end-7) 'cmp.mat']);

    saveData = 'yes';
    pathMarker = [filePathReadCmp filesep name(1:end-3) 'txt'];
    
    [data_perm,data_ITPC,data_ITPCbased] = STpntm_permut(data_segm,eventCmp,pathMarker,filePathSave,name,saveData);
    
    
    %% permutation graphs
    %In case You don't want to recalculate each subsection
%     help = dir([filePathReadImp filesep '*.mff']); name = help(i).name; clear help 
%     load([filePathSave filesep 'permut' filesep fileSegm(i).name(1:end-8) '.mat']);

    rendFigure = {'Tstat' 'hist'};
    foiPerm = [40, 120];
    
    STpntm_permgraphs(data_perm,data_ITPC,data_ITPCbased,name,rendFigure,foiPerm)
    

    %% topo analysis
    %In case You don't want to recalculate each subsection
%     help = dir([filePathReadImp filesep '*.mff']); name = help(i).name; clear help
%     load([filePathSave filesep 'raw_data' filesep fileSegm(i).name]);
%     load([filePathSave filesep 'TFR' filesep fileSegm(i).name]);
    
    saveData = 'yes';
    foiTopo = [159 161];
    pathImp = [filePathReadImp filesep name(1:end-3) 'mff'];
    
    impedance = STpntm_imped(data_perm,pathImp,filePathSave,name,saveData);
    data_topo = STpntm_topo(data_segm,foiTopo,filePathSave,name,saveData);

   
end