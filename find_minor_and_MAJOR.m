% Find minority class and majority class
%
% Input:
%    samples -- matrix of samples (rows) by features (columns)
%    labels  -- a vector of the same length as the number of samples.
%               labels(i) is the actual class label of samples(i,:),
%               where labels(i) is {-1,+1}
%
% Output:
%    new_samples -- new samples after the find minority class and majority class
%    new_labels  -- the corresponding labels

function new_labels = find_minor_and_MAJOR( labels )

pos_sample_P1 = find( labels ==  1 );   % row of sample that is in class +1
pos_sample_M1 = find( labels == -1 );   % row of sample that is in class -1
    
n_sample_P1 = length(pos_sample_P1);   % number of samples of class +1
n_sample_M1 = length(pos_sample_M1);   % number of samples of class -1

% find MAJOR and minor class
if n_sample_P1 > n_sample_M1
    new_labels = changem(labels, [-1 1], [1 -1]);
else
    new_labels = labels;
end

end