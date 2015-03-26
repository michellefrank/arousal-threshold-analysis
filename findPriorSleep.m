function prior_sleep = findPriorSleep(fly_data, bin_size)
% given a particular stimulus index and fly, findDelay finds the time it
% took that particular fly to fall asleep after the stimulus onset.
% fly_data should contain ONLY the sleep data for a *single* fly, beginning
% from the index *after* the onset of a stimulus to the next morning. bin_size is in minutes. Delay is then
% calculated based on the index of the first subsequent sleep bout.

%% Establish parameters

% Force fly_data to be a row vector (for loop breaks otherwise)
if iscolumn(fly_data)
    fly_data = fly_data';
end

% Identify locations of all 0s
zero_idxs = find(fly_data==0);

% Identify locations of all nonzeros
nonzero_idxs = find(fly_data);

% Identify length of sleep bout (i.e. the number of bins that constitute a sleep bout)
% Round up in case of something > 1.
bout_size = ceil(5/bin_size);

% Initialize prior_sleep to NaN (so in case the fly just never sleept
% you can at least have some indication of that)
prior_sleep = NaN;

%% Loop through all of the data
% Start with the last 0 before the end

for zero_ix = flip(zero_idxs)
    
    % Find the index of the prior non-zero value
    nonzero = nonzero_idxs(find(nonzero_idxs < zero_ix,1,'last'));

    
    % Check if that non-zero is sufficiently far from the current index
    if zero_ix - nonzero >= bout_size

        % If distance between this zero and previous non-zero is > 5 min, 
        % exit and store the index (you've found your sleep bout!)
        
        % Export the index of the end of the sleep bout
        prior_sleep = zero_ix;

        break

    end
    
end
