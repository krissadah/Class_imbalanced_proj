% Export dataset to .mat
clear all; close all;

%data = importdata('DataSet/data_banknote_authentication.txt');

load('DataSet/colon_svm_with_rank.mat');
load('DataSet/colon_svm_target.mat');

samples = colon_svm_with_rank(2:end,:);

labels = colon_svm_target;
%labels = changem(labels, -1, 0);

save('DataSet/colon_samples_with_features.mat', 'samples')
save('DataSet/colon_labels.mat', 'labels')