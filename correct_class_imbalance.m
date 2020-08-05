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

minor_label =   1;
MAJOR_label =  -1;

%--------- UnderSampling ---------
    if strcmpi(method,'UnderSampling')
        index = randperm(MAJOR_class_no, minor_class_no);
        row_numbers = MAJOR_class_pos( index );

        % Mark selected random MAJOR class sample
        selected = zeros(1, nsample);
        selected(row_numbers) = 1;

        % Initialize Output
        new_nsample = 2 * minor_class_no; % number of new samples
        new_samples = zeros(new_nsample, nfeature);
        new_labels  = zeros(new_nsample, 1);

        % Insert: all minor class samples | some of MAJOR class samples
        new_row = 1;
        for row = 1:nsample
            if (labels(row) == minor_label) || (selected(row) == 1)
                new_samples(new_row, :) = samples(row, :);
                new_labels(new_row)     = labels(row);
                new_row = new_row + 1;
            end
        end
    %----------- OverSampling -----------
    elseif strcmpi(method,'OverSampling')
        over_index = 0;
        index_rand = MAJOR_class_no - minor_class_no;

        % When number of MAJOR class > 2 times number of minor class
        if index_rand > minor_class_no
            over_index = int(index_rand / minor_class_no);
            index_rand = rem(index_rand, minor_class_no);
        end

        index = randperm(minor_class_no, index_rand);
        row_numbers = minor_class_pos( index );

        % Mark selected random minor class sample
        selected = zeros(1, nsample);
        selected(row_numbers) = 1;

        % Initialize Output
        new_nsample = 2 * MAJOR_class_no; % number of new samples
        new_samples = zeros(new_nsample, nfeature);
        new_labels  = zeros(new_nsample, 1);

        i = 0; n = 0; x = 0;
        for row = 1:new_nsample
            % Insert: all samples
            if row <= nsample
                new_samples(row, :) = samples(row, :);
                new_labels(row)     = labels(row);

            % Insert: all minor class samples n times (when over index occur)
            elseif over_index ~= 0
                i = i + 1;
                new_samples(row, :) = samples(minor_class_pos(i), :);
                new_labels(row)     = minor_label;
                if i == minor_class_no
                    i = 1;
                    over_index = over_index - 1;
                end

            % Insert: some of minor class samples
            else
                while x ~= 1
                    if n < numel(selected);
                        n = n + 1;
                        x = selected(n);
                    end
                end
                new_samples(row, :) = samples(n, :);
                new_labels(row)     = minor_label;
                x = 0;
            end
        end
    %----------- Hybrid -----------
    elseif strcmpi(method,'Hybrid')
        index_mid = round( (MAJOR_class_no + minor_class_no) / 2 );

        over_index = 0;
        index_rand = index_mid - minor_class_no;
        % When number of middle index > 2 times number of minor class
        if index_rand > minor_class_no
            over_index = int(index_rand / minor_class_no);
            index_rand = rem(index_rand, minor_class_no);
        end

        index_overSamp = randperm(minor_class_no, index_rand);
        row_n_overSamp = minor_class_pos( index_overSamp );

        index_underSamp = randperm(MAJOR_class_no, index_mid);
        row_n_underSamp = MAJOR_class_pos( index_underSamp );

        % Mark selected random minor and MAJOR class sample
        selected_minor = zeros(1, nsample);
        selected_minor(row_n_overSamp) = 1;

        selected_MAJOR = zeros(1, nsample);
        selected_MAJOR(row_n_underSamp) = 1;

        % Initialize Output
        new_nsample = nsample; % number of new samples
        new_samples = zeros(new_nsample, nfeature);
        new_labels  = zeros(new_nsample, 1);

        i = 0; n = 0; x = 0;
        for row = 1:nsample
            % Insert: all minor class samples | some of MAJOR class samples
            if (labels(row) == minor_label) || (selected_MAJOR(row) == 1)
                new_samples(row, :) = samples(row, :);
                new_labels(row)     = labels(row);

            % Insert: all minor class samples n times (when over index occur)
            elseif over_index ~= 0
                i = i + 1;
                new_samples(row, :) = samples(minor_class_pos(i), :);
                new_labels(row)     = minor_label;
                if i == minor_class_no
                    i = 1;
                    over_index = over_index - 1;
                end

            % Insert: some of minor class samples
            else
                while x ~= 1
                    n = n + 1;
                    x = selected_minor(n);
                end
                new_samples(row, :) = samples(n, :);
                new_labels(row)     = minor_label;
                x = 0;
            end
        end
    else
        msgbox("Do nothing");
        new_samples = samples;
        new_labels = labels;
    end

end