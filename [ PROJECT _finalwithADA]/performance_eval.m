% Evaluate performance of a binary classifier
%
% Input:
%    actual_labels    -- a vector of {+1,-1} for actual labels of samples
%    predicted_labels -- a vector of the same length as 'lables'.
%                        predicited_labels(i) is the predicted class label
%                        of samples(i,:).
%
% Output:
%    acc, sens, spec -- accuracy, sensitivity, and specificity

function [acc, sens, spec, predicted_result_acc, predicted_result_sens, predicted_result_spec] = performance_eval( actual_labels, predicted_labels )

TP = 0;   % actual = +1 | predicted = +1
FN = 0;   % actual = +1 | predicted = -1
TN = 0;   % actual = -1 | predicted = -1
FP = 0;   % actual = -1 | predicted = +1

nsample = length(actual_labels);   %(TP + FN + TN + FP)
sens_count = 1;
spec_count = 1;

for i = 1:nsample
    if(     (actual_labels(i) ==  1) && (predicted_labels(i) ==  1) )
        TP = TP+1;
        predicted_result_acc(i) = 1;
        predicted_result_sens(sens_count) = 1;
        sens_count = sens_count + 1;
        
    elseif(     (actual_labels(i) ==  1) && (predicted_labels(i) == -1) )
        FN = FN+1;
        predicted_result_acc(i) = 0;
        predicted_result_sens(sens_count) = 0;
        sens_count = sens_count + 1;
        
    elseif(      (actual_labels(i) == -1) && (predicted_labels(i) == -1) )
        TN = TN+1;
        predicted_result_acc(i) = 1;
        predicted_result_spec(spec_count) = 1;
        spec_count = spec_count + 1;
        
    else (       (actual_labels(i) == -1) && (predicted_labels(i) ==  1) );
        FP = FP+1;
        predicted_result_acc(i) = 0;
        predicted_result_spec(spec_count) = 0;
        spec_count = spec_count + 1;
    end
end

predicted_result_acc = predicted_result_acc';
predicted_result_sens = predicted_result_sens';
predicted_result_spec = predicted_result_spec';

acc  = (TP + TN) / nsample;
sens = (TP) / (TP + FN);
spec = (TN) / (TN + FP);

end