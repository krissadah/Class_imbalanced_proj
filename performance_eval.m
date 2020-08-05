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

function [acc, sens, spec] = performance_eval( actual_labels, predicted_labels )

TP = 0;   % actual = +1 | predicted = +1
FN = 0;   % actual = +1 | predicted = -1
TN = 0;   % actual = -1 | predicted = -1
FP = 0;   % actual = -1 | predicted = +1

nsample = length(actual_labels);   %(TP + FN + TN + FP)

for i = 1:nsample
    if(     (actual_labels(i) ==  1) && (predicted_labels(i) ==  1) )
        TP = TP+1;
    elseif( (actual_labels(i) ==  1) && (predicted_labels(i) == -1) )
        FN = FN+1;
    elseif( (actual_labels(i) == -1) && (predicted_labels(i) == -1) )
        TN = TN+1;
    else %( (actual_labels(i) == -1) && (predicted_labels(i) ==  1) )
        FP = FP+1;
    end
    
    TP_rate = TP / (TP + FN);
    % TNrate = Percentage of negative instances correctly classify
    TN_rate = TN / (FP + TN);
    % FPrate = Percentage of negative instances  misclassified
    FP_rate = FP / (FP + TN);
    % FNrate = Percentage of negative instances  misclassified
    FN_rate = FN / (TP + FN);
    
end

acc  = (TP + TN) / nsample;
sens = (TP) / (TP + FN);
spec = (TN) / (TN + FP);

end