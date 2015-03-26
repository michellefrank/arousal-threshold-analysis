function [fly_array,duration_array] = getIsSleeping(flies, windows, bin_width)
% Given an array of flies over a particular time period, returns which
% flies are sleeping during a given window of interest.
% fly_array defines whether a particular fly was asleep for a particular
% window and how long a sleeping fly had been asleep.
% (0 indicates that fly was awake; a number indicates how long that fly was
% asleep)

% Initialize fly & duration arrays
num_flies = length(flies.data(1,:));
fly_array = zeros(length(windows),num_flies);
duration_array = fly_array;


for i = 1:length(windows)
    
    % Identify whether each fly was asleep
    fly_array(i,:) = sum(flies.data(windows{i},:)) == 0;
    
    % Identify how long they were quiescent
    temp_flies = flies.data(1:windows{i}(end),:);
    
    for k = 1:num_flies
        % In case they never move, return a NaN
        if sum(temp_flies(:,k))==0
            duration_array(i,k) = NaN;
        else
            last_bin = find(temp_flies(:,k),1,'last');
            duration_array(i,k) = (windows{i}(end) - last_bin)*bin_width;
        end
    end
    
end

