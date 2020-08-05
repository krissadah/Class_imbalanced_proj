% Correct class imbalance by selected method
%
% Input:
%    samples -- matrix of samples (rows) by features (columns)
%    labels  -- a vector of the same length as the number of samples.
%               labels(i) is the actual class label of samples(i,:),
%               where labels(i) is {-1,+1}
%    method  -- a string that represent a method to correct class imbalance
%               'UnderSampling'
%               'OverSampling'
%               'Hybrid'
%
% Output:
%    new_samples -- new samples after the correction
%    new_labels  -- the corresponding labels

function [new_samples, new_labels] = correct_class_imbalance( samples, labels, method )

[nsample, nfeature] = size(samples);

minor_class_pos = find( labels ==  1 );   % row of sample that is in class +1
MAJOR_class_pos = find( labels == -1 );   % row of sample that is in class -1
    
minor_class_no = length(minor_class_pos);   % number of samples of minor class
MAJOR_class_no = length(MAJOR_class_pos);   % number of samples of MAJOR class

minor_label =  1;
MAJOR_label = -1;


%--------------------------------- SMOTE ---------------------------------%
if strcmpi(method,'SMOTE')
    [sm_new_labels, n_sample_P1, n_sample_M1] = find_minor_and_MAJOR ( labels );
    ratio = FindRatio(n_sample_P1, n_sample_M1);
    [sm_new_samples, sm_new_labels] = SLSMOTE(samples, sm_new_labels);
    
    while ratio < 1
        [sm_new_samples, sm_new_labels] = SLSMOTE(sm_new_samples, sm_new_labels);
        [sm_new_labels, n_sample_P1, n_sample_M1, pos_sample_P1, pos_sample_M1] = find_minor_and_MAJOR ( sm_new_labels );
        ratio = FindRatio(n_sample_P1, n_sample_M1);
    end
        
    if ratio > 1
        
    % Initialize selected data
    index = randperm(n_sample_P1, n_sample_M1);
    selected_row = pos_sample_P1(index);

    % Initialize Output
    new_nsample = 2 * n_sample_M1; % number of new samples
    new_samples = zeros(new_nsample, nfeature);
    new_labels  = zeros(new_nsample, 1);
    
    n = 0; i = 0;
    for row = 1:new_nsample
        % Insert: all minor class samples
        if (sm_new_labels(row) == minor_label)
            n = n + 1;
            new_samples(n, :) = sm_new_samples(row, :);
            new_labels(n)     = sm_new_labels(row);
                        
        % Insert: some of MAJOR class samples
        elseif i ~= length(selected_row)
            n = n + 1;
            i = i + 1;
            new_samples(n, :) = sm_new_samples(selected_row(i), :);
            new_labels(n)     = MAJOR_label;
        end
    end
    elseif ratio == 1
        new_labels = sm_new_labels;
        new_samples = sm_new_samples;
    end

%-------------------------------- ADASYN ---------------------------------%
elseif strcmpi(method,'ADASYN')
    adasyn_beta                     = [];       %let ADASYN choose default
    adasyn_kDensity                 = [];       %let ADASYN choose default
    adasyn_kSMOTE                   = [];       %let ADASYN choose default
    adasyn_featuresAreNormalized    = false;    %false lets ADASYN handle normalization
    [syn_samples, syn_labels] = ADASYN(samples, labels, adasyn_beta, adasyn_kDensity, adasyn_kSMOTE, adasyn_featuresAreNormalized);
    
    syn_class_pos = find( syn_labels == minor_label );   % row of sample that is in synthetic class  
    syn_class_no = length(syn_class_pos);   % number of samples of synthetic class
    
    extend_class_no = MAJOR_class_no - minor_class_no;

    over_index = 0;
    % When number of MAJOR class > 2 times number of synthetic class
    if extend_class_no > syn_class_no
        over_index = cast((extend_class_no / syn_class_no),'int8');
        extend_class_no = rem(extend_class_no, syn_class_no);
    end
    
    % Initialize selected data
    index = randperm(syn_class_no, extend_class_no);
    selected_row = syn_class_pos(index);
    
    % Initialize Output
    new_nsample = 2 * MAJOR_class_no; % number of new samples
    new_samples = zeros(new_nsample, nfeature);
    new_labels  = zeros(new_nsample, 1);
    
    n = 0; i = 0;
    for row = 1:new_nsample
        % Insert: all samples
        if row <= nsample
            new_samples(row, :) = samples(row, :);
            new_labels(row)     = labels(row);
                        
        % Insert: all synthetic class samples n times (when over index occur)
        elseif over_index ~= 0
            n = n + 1;
            new_samples(row, :) = syn_samples(syn_class_pos(n), :);
            new_labels(row)     = minor_label;
            if n == syn_class_no
                n = 0;
                over_index = over_index - 1;
            end
            
        % Insert: some of synthetic class samples
        else
            i = i + 1;
            new_samples(row, :) = syn_samples(selected_row(i), :);
            new_labels(row)     = minor_label;
        end
    end
    
%----------------------------- UnderSampling -----------------------------%
elseif strcmpi(method,'UnderSampling')
    % Initialize selected data
    index = randperm(MAJOR_class_no, minor_class_no);
    selected_row = MAJOR_class_pos(index);

    % Initialize Output
    new_nsample = 2 * minor_class_no; % number of new samples
    new_samples = zeros(new_nsample, nfeature);
    new_labels  = zeros(new_nsample, 1);
    
    n = 0; i = 0;
    for row = 1:nsample
        % Insert: all minor class samples
        if (labels(row) == minor_label)
            n = n + 1;
            new_samples(n, :) = samples(row, :);
            new_labels(n)     = labels(row);
                        
        % Insert: some of MAJOR class samples
        elseif i ~= length(selected_row)
            n = n + 1;
            i = i + 1;
            new_samples(n, :) = samples(selected_row(i), :);
            new_labels(n)     = MAJOR_label;
        end
    end

%----------------------------- OverSampling ------------------------------%
elseif strcmpi(method,'OverSampling')
    % Prepare index
    index_rand = MAJOR_class_no - minor_class_no;
    
    over_index = 0;
    % When number of MAJOR class > 2 times number of minor class
    if index_rand > minor_class_no
        over_index = cast((index_rand / minor_class_no),'int8');
        index_rand = rem(index_rand, minor_class_no);
    end
    
    % Initialize selected data
    index = randperm(minor_class_no, index_rand);
    selected_row = minor_class_pos(index);
    
    % Initialize output
    new_nsample = 2 * MAJOR_class_no; % number of new samples
    new_samples = zeros(new_nsample, nfeature);
    new_labels  = zeros(new_nsample, 1);
    
    n = 0; i = 0;
    for row = 1:new_nsample
        % Insert: all samples
        if row <= nsample
            new_samples(row, :) = samples(row, :);
            new_labels(row)     = labels(row);
            
        % Insert: all minor class samples n times (when over index occur)
        elseif over_index ~= 0
            n = n + 1;
            new_samples(row, :) = samples(minor_class_pos(n), :);
            new_labels(row)     = minor_label;
            if n == minor_class_no
                n = 0;
                over_index = over_index - 1;
            end
            
        % Insert: some of minor class samples
        else
            i = i + 1;
            new_samples(row, :) = samples(selected_row(i), :);
            new_labels(row)     = minor_label;
        end
    end
elseif strcmpi(method,'DNT')
    new_samples = samples;
    new_labels = labels;


%-------------------------------- Hybrid ---------------------------------%
elseif strcmpi(method,'Hybrid')
    % Prepare index
    index_mid = round( (MAJOR_class_no + minor_class_no) / 2 );
    index_rand = index_mid - minor_class_no;
    
    over_index = 0;
    % When number of middle index > 2 times number of minor class
    if index_rand > minor_class_no
        over_index = cast((index_rand / minor_class_no),'int8');
        index_rand = rem(index_rand, minor_class_no);
    end
    
    % Initialize selected data
    index_overSamp = randperm(minor_class_no, index_rand);
    row_n_overSamp = minor_class_pos(index_overSamp);
    
    index_underSamp = randperm(MAJOR_class_no, index_mid);
    row_n_underSamp = MAJOR_class_pos(index_underSamp);

    % Initialize output
    new_nsample = nsample; % number of new samples
    new_samples = zeros(new_nsample, nfeature);
    new_labels  = zeros(new_nsample, 1);
    
    n = 0; i = 0; j = 0;
    for row = 1:nsample
        % Insert: all minor class samples
        if (labels(row) == minor_label)
            new_samples(row, :) = samples(row, :);
            new_labels(row)     = labels(row);
            
        % Insert: all minor class samples n times (when over index occur)
        elseif over_index ~= 0
            n = n + 1;
            new_samples(row, :) = samples(minor_class_pos(n), :);
            new_labels(row)     = minor_label;
            if n == minor_class_no
                n = 0;
                over_index = over_index - 1;
            end
            
        else
            % Insert: some of minor class samples
            if i ~= length(row_n_overSamp)
                i = i + 1;
                new_samples(row, :) = samples(row_n_overSamp(i), :);
                new_labels(row)     = minor_label;
                
            % Insert: some of MAJOR class samples
            else
                j = j + 1;
                new_samples(row, :) = samples(row_n_underSamp(j), :);
                new_labels(row)     = MAJOR_label;
            end
        end
    end
    
end

end

function ratio = FindRatio(plus_one, minus_one) %minor = 1 major = -1
        ratio = plus_one/minus_one;
end



