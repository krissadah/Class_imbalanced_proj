% test function 'classify_and_evaluate' and 'performance_eval'
clear all;
clc
rng(732)
datasetName = 'colon_svm_';

load(strcat('Dataset/', datasetName, 'with_rank.mat'));

load(strcat('Dataset/', datasetName, 'target.mat'));
    
samples = colon_svm_with_rank(2:end,:); % ignore 1st row, which contains ranking of features
labels = colon_svm_target; % actual class, 62x1 matrix

labels = find_minor_and_MAJOR(labels); % correct the minor and major class
    
label_plus = find(labels==1);
label_minus = find(labels==-1);
    
[predicted_labels, score]  = classify_and_evaluate(samples, labels);
[acc, sens, spec] = performance_eval(labels, predicted_labels)