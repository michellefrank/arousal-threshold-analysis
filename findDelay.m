function sleep_delay = findDelay(fly_data, bin_size)
% given a particular stimulus index and fly, findDelay finds the time it
% took that particular fly to fall asleep after the stimulus onset.
% fly_data should contain ONLY the sleep data for a *single* fly, beginning
% from the index *after* the onset of a stimulus to the next morning. bin_size is in minutes. Delay is then
% calculated based on the index of the first subsequent sleep bout.

%% Establish parameters

% Identify locations of all 0s
zero_idxs = find(fly_data==0);

% Identify locations of all nonzeros
nonzero_idxs = find(fly_data);

% Identify length of sleep bout (i.e. the number of bins that constitute a sleep bout)
% Round up in case of something > 1.
bout_size = ceil(5/bin_size);

% Initialize sleep_delay to NaN (so in case the fly just never sleeps again
% you can at least have some indication of that)
sleep_delay = NaN;

%% Loop through all of the data

for i = 1:length(zero_idxs)
    % Start with the very first 0 (i.e. zero_idxs(1))

    % Find the index of the next non-zero value
    nonzero = nonzero_idxs(find(nonzero_idxs>zero_idxs(i),1,'first'));

    % Check if the next non-zero is sufficiently far from the current index
    if nonzero - zero_idxs(i) >= bout_size

        % If distance between first zero and first non-zero is > 5 min, 
        % exit and store the index (you've found your sleep bout!)
        
        % Find the actual time to sleep based on the bin size.
        sleep_delay = zero_idxs(i)*bin_size;

        break

    end
    
end
