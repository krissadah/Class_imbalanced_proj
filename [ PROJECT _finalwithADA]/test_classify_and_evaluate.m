% test function 'classify_and_evaluate' and 'performance_eval'
clear; close all;
tic;
rng(123)
% rng shuffle;
% cur_rng = rng;
% seed = cur_rng.Seed;

datasetName = ["colon","banknote_authentication","blood_transfusion","contraceptive","heart_disease","ionosphere","breastcancer","diabetes","spine","qsar_oral_toxicity","occupancy"];
% datasetName = "colon"
% datasetName = 'blood_transfusion';
% datasetName = "banknote_authentication";
% datasetName = "contraceptive";
% datasetName = "heart_disease";
% datasetName = "occupancy";


method = ["DNT","UnderSampling", "OverSampling", "Hybrid", "SMOTE","ADASYN"];
% method = "DNT";
% method = "ADASYN";
RESULT = ["Dataset" "Evaluate" method];
for data_count = 1:numel(datasetName)
    RESULT((2+(data_count - 1)*3),1) = datasetName(data_count);
end

%Create matrix 0 >> size = no.of method x 1

acc  = zeros(length(method), 1);
sens = zeros(length(method), 1);
spec = zeros(length(method), 1);
overall = [acc';sens';spec'];

%assign row_count = 1 for loop
row_count = 1;                                                                          

H    = zeros(length(method), 1);
P    = zeros(length(method), 1);
CI_new = zeros(length(method), 2);
STAT_new.tstat = zeros(length(method), 1);
STAT_new.df    = zeros(length(method), 1);
STAT_new.sd    = zeros(length(method), 1);

%loop by dataset
for data_count = 1:numel(datasetName)
    
    %load dataset and labels
    load(strcat('DataSet/', datasetName(data_count), '_samples_with_features.mat'));
    load(strcat('DataSet/', datasetName(data_count), '_labels.mat'));
    
    %loop by number of methods
    for method_count = 1 : length(method)
        
        %find number of Label = 1 and -1
        BFfind_positive{data_count} = find(labels == 1);
        BFfind_negative{data_count} = find(labels == -1);
        
        %assign sample labels method to correct_class_imbalance func
        [new_samples, new_labels] = correct_class_imbalance(samples, labels, method(method_count));
        
        %find number of Label = 1 and -1 after process a
        %correct_class_imbalance function
        AFfind_negative{data_count} = find(new_labels == -1);
        AFfind_positive{data_count} = find(new_labels == 1);
        
        %Train model by classify_and_evaluate
        predicted_labels  = classify_and_evaluate(new_samples, new_labels);
        
        %collect acc sens spec predicted_result_acc predicted_result_sens
        %predicted_result_spec  สำหรับใช้ในการทำ ttest
        [acc(method_count), sens(method_count), spec(method_count), predicted_result_acc, predicted_result_sens, predicted_result_spec] = performance_eval(new_labels, predicted_labels);
        
        %collect predict_result of acc sens spec in
        %matrix type : its size = no.of Dataset x no.of Method
        pre_re_acc{data_count,method_count} = predicted_result_acc;
        pre_re_sens{data_count,method_count} = predicted_result_sens;
        pre_re_spec{data_count,method_count} = predicted_result_spec;
        
        %clear predict_result acc sens spec
        clear predicted_result_acc; clear predicted_result_sens; clear predicted_result_spec;
        
    end
    
    % round to 4 decimal digit
    acc = round(acc,4);
    sens = round(sens,4);
    spec = round(spec,4);
    
    %put acc sens spec into overall array
    overall(row_count,:) = acc';
    overall(row_count+1,:) = sens';
    overall(row_count+2,:) = spec;
    
    %put str acc sens spec into column 2 of RESULT
    RESULT(row_count+1,2) = 'acc';
    RESULT(row_count+2,2) = 'sens';
    RESULT(row_count+3,2) = 'spec';

    row_count = row_count +3; % 3 is acc, sens, spec for each row
end

%add overall into RESULT for each row and column
%rcount mean counting row
for row_count = 1:size(overall,1)
    
    %ccount mean counting column
    for column_count = 1:size(overall,2)
        
        %add overall into RESULT start on row 2 column 3
        RESULT(row_count+1,column_count+2) = overall(row_count,column_count);
    end
end

% % find highest value in each part(acc,sens,spec)
row_result = 1;
for data_count = 1:numel(datasetName)
    highest.acc(data_count) = max(str2double(RESULT(row_result+1,3:size(RESULT,2))));
    highest.sens(data_count) = max(str2double(RESULT(row_result+2,3:size(RESULT,2))));
    highest.spec(data_count) = max(str2double(RESULT(row_result+3,3:size(RESULT,2))));
    row_result = row_result+3;
end

% get highest predict result for acc sens spec
for data_count = 1:numel(datasetName)
    row_dataset = (3*data_count)-1;
    for method_count = 1:numel(method)
        
%         find predict_result with highest acc sens spec in order and put them into pre_highest
        if strcmp(num2str(highest.acc(data_count)),RESULT(row_dataset,method_count+2)) == 1
            pre_highest_acc(data_count) = pre_re_acc(data_count,method_count);
        end
        if strcmp(num2str(highest.sens(data_count)),RESULT(row_dataset+1,method_count+2)) == 1
            pre_highest_sens(data_count) = pre_re_sens(data_count,method_count);
        end
        if strcmp(num2str(highest.spec(data_count)),RESULT(row_dataset+2,method_count+2)) == 1
            pre_highest_spec(data_count) = pre_re_spec(data_count,method_count);
        end
    end
end

%perform ttest
for data_count = 1:numel(datasetName)
    for method_count = 1:numel(method)
        [H_acc(data_count,method_count), P_acc(data_count,method_count)] = ttest2(pre_highest_acc{1,data_count}(:),pre_re_acc{data_count,method_count}(:),'tail','right');
        [H_sens(data_count,method_count), P_sens(data_count,method_count)] = ttest2(pre_highest_sens{1,data_count}(:),pre_re_sens{data_count,method_count}(:),'tail','right');
        [H_spec(data_count,method_count), P_spec(data_count,method_count)] = ttest2(pre_highest_spec{1,data_count}(:),pre_re_spec{data_count,method_count}(:),'tail','right');
    end
end
% 
% 
% Write Data to excel
FileName = 'RESULT_IOT.xlsx';
HandP = {H_acc,H_sens,H_spec,P_acc,P_sens,P_spec};
NameHandP = ["H_acc","H_sens","H_spec","P_acc","P_sens","P_spec"];
for count_HandP = 1:numel(HandP)
    writecell(num2cell(HandP{count_HandP}),FileName,'Sheet',NameHandP(count_HandP),'Range','A1');
end
toc;
% 
% 
% 
writecell(cellstr(RESULT),FileName,'Sheet','RESULT','Range','A1');

