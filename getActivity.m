function activity_array = getActivity(flies,windows)
% getActivity calculates the activity of flies following a stimulus onset.
% getActivity returns a cell array containing the activity of each fly
% following the onset of a stimulus

% Initialize activity array
activity_array = cell(length(windows),1);

% Identify whether the fly was awake for any point during the window
for i = 1:length(windows)
    activity_array{i} = sum(flies.data(windows{i},:));
end
