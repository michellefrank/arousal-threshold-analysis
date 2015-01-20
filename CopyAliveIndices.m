% After running the sleep analysis software, CopyAliveIndices will reformat
% the data about which flies are alive and copy it to the clipboard. It can
% then be pasted into a metadata file to be imported into ArousalAnalysis.
% Functionality is based on the standard nomenclature from SXZ's sleep
% analysis software.

%% Extract alive indices into a single cell.

pre_alive_indices = {master_data_struct.alive_fly_indices}';

for i = 1:length(pre_alive_indices)
    pre_alive_indices{i} = find(pre_alive_indices{i})';
end

%% Convert that cell into a matrix, and fill any empty positions w/ -1

% Identify longest set of indices & use that to set the dimenstions of the
% matrix, defaulting each position to -1
max_flies = max([master_data_struct.num_alive_flies]);
alive_indices = ones(length(pre_alive_indices),max_flies) * -1;

% Fill positions w/ index values
for i = 1:length(pre_alive_indices)
    alive_indices(i,1:length(pre_alive_indices{i})) = pre_alive_indices{i};
end

%% Copy to clipboard.

mat2clip(alive_indices,',');