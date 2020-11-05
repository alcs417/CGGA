close all;
clear;
clc;
addpath(genpath('./'));

params.filtVar = 1;
params.norm = 1;
params.log2 = 1;

algorithmName = 'CGGA';

dataDir = 'D:/RProjects/cancer_subtyping/matlab/mat_data';
outDir = 'D:/RProjects/cancer_subtyping/matlab/res';

subDir = sprintf('filtVar_%d_norm_%d_log2_%d', params.filtVar, params.norm, params.log2);
outDir = sprintf('%s/%s/%s', outDir, algorithmName, subDir);
dataDir = sprintf('%s/%s', dataDir, subDir);

if ~exist(outDir, 'dir') 
    mkdir(outDir);
end

files = dir(fullfile(dataDir, '*.mat'));
files = {files.name}';
for i = 1 : numel(files)
    fname = fullfile(dataDir, files{i});
    dataStr = strsplit(files{i}, '.');
%     dataStr = strsplit(dataStr{1}, '_'); 
    load(fname);
    data{1} = struct2array(exp);
    data{2} = struct2array(methy);
    data{3} = struct2array(mirna);
%     fprintf('for test only');
    [idx_eg, idx_rc] = CGGA(data);
    sampleNames = fieldnames(exp);
%     res_eg = conStruct(sampleNames', num2cell(idx_eg));
%     res_rc = conStruct(sampleNames', num2cell(idx_rc));
    outFile = sprintf('%s/%s.mat', outDir, dataStr{1});
    save(outFile, 'sampleNames', 'idx_eg', 'idx_rc');
end