function activity_array = getActivity(flies,windows)
% getActivity calculates the activity of flies following a stimulus onset.
% getActivity returns a cell array containing the activity of each fly
% following the onset of a stimulus

% Initialize activity array
activity_array = cell(length(windows),3);

% Extract activity for the fly during the window
for i = 1:length(windows)
    activity_array{i,1} = sum(flies.data(windows{i,1},:));
    activity_array{i,2} = sum(flies.data(windows{i,2},:));
    activity_array{i,3} = sum(flies.data(windows{i,3},:));
end
