% test function 'classify_and_evaluate' and 'performance_eval'
clear all;
clc
rng(123);
    datasetName = 'colon_svm_';

    load(strcat('Dataset/', datasetName, 'with_rank.mat'));

    load(strcat('Dataset/', datasetName, 'target.mat'));
    
    samples = colon_svm_with_rank(2:end,:); % ignore 1st row, which contains ranking of features
    labels = colon_svm_target; % actual class, 62x1 matrix

    labels = find_minor_and_MAJOR(labels); % correct the minor and major class
    
    label_plus = find(labels==1);               
    label_minus = find(labels==-1);    
    
   [samples, labels] = correct_class_imbalance(samples, labels, 'Hybrid');
   
    label_plus_after_preprocessing = find(labels==1);
    label_minus_after_preprocessing = find(labels==-1);
    
    [predicted_labels, score]  = classify_and_evaluate(samples, labels);
    [acc, sens, spec] = performance_eval(labels, predicted_labels)
    

    %ttest ‡∑ Õ–‰√
    [h,p,ci,stats] = ttest(predicted_labels) %ttest for "sample" not "population" 
    
