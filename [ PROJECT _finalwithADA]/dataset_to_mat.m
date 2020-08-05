% Export dataset to .mat
clear; close all;

data = importdata('DataSet/.temp/breast-cancer.data');

% datasetName = 'contraceptive';
% load(strcat('DataSet/', datasetName, '_samples_with_features.mat'));
% load(strcat('DataSet/', datasetName, '_labels.mat'));

samples = samples(88:end,:);

labels = labels(88:end);
% labels = changem(labels, [-1 -1], [2 3]);

datasetName = 'contraceptive';
save(strcat('DataSet/', datasetName, '_samples_with_features.mat'), 'samples')
save(strcat('DataSet/', datasetName, '_labels.mat'), 'labels')