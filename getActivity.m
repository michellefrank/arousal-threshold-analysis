function activity_array = getActivity(flies,windows)
% getActivity calculates the activity of flies following a stimulus onset.
% getActivity returns a cell array containing the activity of each fly
% following the onset of a stimulus

% Initialize activity array
activity_array = cell(1,3);

activity_array{1} = zeros(length(windows), size(flies,2));
activity_array{2} = zeros(length(windows), size(flies,2));
activity_array{3} = zeros(length(windows), size(flies,2));

% Extract activity for the fly during the window
for i = 1:length(windows)
    activity_array{1}(i,:) = sum(flies(windows{i,1},:),1);
    activity_array{2}(i,:) = sum(flies(windows{i,2},:),1);
    activity_array{3}(i,:) = sum(flies(windows{i,3},:),1);
end