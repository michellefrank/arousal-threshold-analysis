function sleep_delays = getDelays(flies,stim_idxs,fly_arousals,bin_size)
% getDelays takes information about a group of flies from a given genotype
% and the time of stimuli, and returns an array containing the latency for
% each fly for each stimulus. NaNs are used in places where flies were not
% sleeping, did not wake up, or never fell asleep again after the stim.

%% Create data struct to hold sleep latency data

sleep_delays = zeros(size(fly_arousals));

% Initialize non-waking flies to NaNs
sleep_delays(fly_arousals==0) = NaN;

%% Loop through each stimulus

for i = 1:length(stim_idxs)

    % Within each stimulus, loop through each fly
    for k = 1:size(flies,2)
        
        % If the fly woke up, calculate its sleep latency
        if ~isnan(sleep_delays(i,k))
            sleep_delays(i,k) = findDelay(flies((stim_idxs(i)+1):end, k), bin_size);
        end
        
    end
        
end
