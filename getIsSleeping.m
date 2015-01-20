function fly_array = getIsSleeping(flies, windows)
% Given an array of flies over a particular time period, returns which
% flies are sleeping during a given window of interest.
% fly_array is a cell of logical arrays, each of which contains a 1 or a 0
% defining whether that particular fly was asleep for that particular
% window. (1 = asleep; 0 = away)

% Initialize fly array
fly_array = zeros(length(windows),length(flies.data(1,:)));

% Identify whether the fly was sleeping during the window
for i = 1:length(windows)
    fly_array(i,:) = sum(flies.data(windows{i},:)) == 0;
end