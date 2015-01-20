function sleep_delays = getDelays(flies,stim_idxs,fly_arousals,bin_size)
% getDelays takes information about a group of flies from a given genotype
% and the time of stimuli, and finds the average delay to sleep onset

%% Create data struct to hold sleep latency data

sleep_delays = zeros(length(find(fly_arousals)),1);

%% Loop through each stimulus

% create counter to keep track of your index in the loop
idx = 1;

for i = 1:length(stim_idxs)
    
    % Extract indices of flies to examine
    wakened_flies = find(fly_arousals(i,:));

    % Within each stimulus, loop through each fly
    for k = 1:length(wakened_flies)
        
        % Calculate the latency
        sleep_delays(idx) = findDelay(flies((stim_idxs(i)+1):end,wakened_flies(k)), bin_size);
        idx = idx + 1;
        
    end
        
end

% Clean up the NaNs
sleep_delays = sleep_delays(~isnan(sleep_delays));