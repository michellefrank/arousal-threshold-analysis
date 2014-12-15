function fly_array = getIsWakes(flies, windows)
% Given an array of flies and some window of interest, tells whether any of
% them are awake during the period of interest.
% fly_array returns a cell array of logicals, containing a 1 if the fly is
% awake during the period of interest and a 0 if it is not.

% Initialize fly array
fly_array = cell(length(windows),1);

% Identify whether the fly was awake for any point during the window
for i = 1:length(windows)
    fly_array{i} = sum(flies.data(windows{i},:)) > 0;
end