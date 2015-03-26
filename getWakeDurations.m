function [wake_durations,wake_activities] = getWakeDurations(flies,stim_indices,sleeping_flies,bin_width)
% Identifies the duration and activity of the last wake bout prior
% to stimulus onset.
%
% For each fly, for each stim:
% If applicable, find the beginning of the sleep bout immediately prior to the stimulus
% Identify the sleep bout prior to the one under consideration
% Compute the duration of the intervening wake period
% Compute the activity during the intervening wake period

%% Create data structs to hold wake bout info
wake_durations = zeros(size(sleeping_flies));
wake_activities = zeros(size(sleeping_flies));

num_flies = size(sleeping_flies,2);

%% Loop through each stimulus

for i = 1:length(stim_indices)

    % Make new, temporary array that holds fly data from the beginning of
    % the night up to onset of the current stim
    temp_flies = flies(1:stim_indices(i)-1,:);

    
    % Identify the end idx for each fly (i.e. the point constituting the end of
    % the wake bout - either the stim [for awake flies] or the beginning of the
    % sleep bout)
    end_idxs = zeros(num_flies,1);

    % For awake flies:
    end_idxs(sleeping_flies(i,:)==0) = stim_indices(i)-1;

    % For sleeping flies:
    for k = find(end_idxs==0)'
        % If the fly never moves, input a NaN
        if sum(temp_flies(:,k)) == 0
            end_idxs(k) = NaN;
        else
            end_idxs(k) = find(temp_flies(:,k),1,'last');
        end
    end
    
    % Identify the end of the previous sleep period:
    start_idxs = zeros(num_flies,1);
    for k = 1:num_flies
        if isnan(end_idxs(k))
            start_idxs(k) = NaN; %if the fly never moves, finding the previous sleep bout it moot
        else
            start_idxs(k) = findPriorSleep(temp_flies(1:end_idxs(k),k),bin_width);
        end
    end

    % Extract wake duration
    wake_durations(i,:) = (end_idxs - start_idxs)*bin_width;
    
    % Extract wake activity
    for k = 1:num_flies
        if isnan(start_idxs(k))
            wake_activities(i,k) = NaN;
        else
            wake_activities(i,k) = sum(temp_flies(start_idxs(k):end_idxs(k),k));
        end
    end
            
    
end