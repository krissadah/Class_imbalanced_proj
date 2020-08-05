% Learn the sample-and-class relationship using SVM and evaluate
% performance of the SVM, using 5-fold cross validation
%
% Input:
%    samples -- matrix of samples (rows) by features (columns)
%    labels  -- a vector of the same length as the number of samples.
%               labels(i) is the actual class label of samples(i,:),
%               where labels(i) is {-1,+1}
%
% Output:
%    predicted_labels -- a vector of the same length as 'labels'.
%                        predicted_labels(i) is the predicted class label
%                        of samples(i,:).

function predicted_labels = classify_and_evaluate( samples, labels )

% Initialize Output
predicted_labels = zeros( size(labels) );

[nsample, ~] = size(samples);
Kfold = 5; % number of folds
stepsize = floor(nsample / Kfold);

for k = 1:Kfold
    % index of the start and stop of the fold
    start = ( (k-1) * stepsize ) + 1;
    stop = k * stepsize;
    if (k == Kfold) % last fold will have more samples
        stop = nsample;
    end
  
    % testing samples
    testSample = samples(start:stop, :);
    
    % training samples
    Index = [ 1:(start-1) (stop+1):nsample ];
    trainSample = samples(Index,:);
    trainLabel = labels(Index);
    
    % SVM
    SVMModel = fitcsvm(trainSample, trainLabel,'Standardize',false);
    predicted_labels(start:stop) = predict(SVMModel, testSample);

end

end