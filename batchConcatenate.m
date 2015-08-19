% batchConcatenate takes data from multiple experiments, identifies shared
% attributes (e.g. sleep latency, percent awakened, etc.) and concatenates
% data for these different attributes for each genotype.

%% Set your directories
[filename, import_path] = uigetfile('D:\Projects\Gal4-Screen\Batched-data\*');
data_dirs = importdata(fullfile(import_path,filename));

export_path = 'D:\Projects\Gal4-Screen\Batched-data';

% Generate graphs?
make_graphs = 0;

%% Import all of the data

% Read in the names of all .csv files from each directory (because we save
% all output files as csvs)

docs = cell(0,2);

for i = 1:length(data_dirs)
    temp_struct = dir(fullfile(data_dirs{i},'*.csv'));
    docs(end+1:end+size(temp_struct,1),2) = {temp_struct.name};
    docs(end+1-size(temp_struct,1):end,1) = data_dirs(i);
end

clear temp_struct

num_files = length(docs);

% Import that data
master_data = cell(num_files, 1);
for i = 1:num_files
    % Import the genotype info
    master_data{i} = importdata(fullfile(docs{i,1}, docs{i,2}));
    % Import the rest of the data in a way that preserves the NaNs
    master_data{i}.data = [];
    master_data{i}.data = csvread(fullfile(docs{i,1}, docs{i,2}), 1,0);
    % Delete the colheaders field if matlab decided to add it this time
    if isfield(master_data{i}, 'colheaders')
        master_data{i} = rmfield(master_data{i}, 'colheaders');
    end
end

% Convert the whole thing to a struct
master_data = [master_data{:}];

%% Sort through the different data types

contents = docs(:,2);

for i = 1:num_files
    comps = regexp(contents{i}, '-', 'split');
    contents{i} = [comps{2} '-' comps{3}(1:end-4)];
end

clear comps

[unique_types, ~, unique_type_idxs] = unique(contents, 'stable');

num_types = length(unique_types);

%% Create even more epic data struct with sorted data

epic_data_struct = struct('DataType', unique_types, 'Genotypes', '', 'Data', []);

% Assign each of the individual files to a spot in the struct
for i = 1:num_types
    
    epic_data_struct(i).Genotypes = [master_data(unique_type_idxs==i).textdata];
    epic_data_struct(i).Data = cell(0,0);
    for k = find(unique_type_idxs==i)'
        epic_data_struct(i).Data = [epic_data_struct(i).Data num2cell(master_data(k).data,1)];
    end
end

clear i k
%% Sort by genotype and concatenate overlapping genotypes

for i = 1:num_types

    % Find unique genotypes
    [~, unique_genos, u_genos_idxs] = unique(epic_data_struct(i).Genotypes, 'stable');

    % Sort genotype labels
    epic_data_struct(i).Genotypes = epic_data_struct(i).Genotypes(unique_genos);

    num_genos = length(unique_genos);

    % Separate out unique data
    temp_cell = cell(1,num_genos);

    % Initialize array to hold data about the size of each genotype
    % (will use to figure out what size array is needed to hold all of the
    % data)
    nums = zeros(1, num_genos);

    for k = 1:num_genos
       temp_cell{k} = vertcat(epic_data_struct(i).Data{:,u_genos_idxs==k})';
       nums(k) = length(temp_cell{k});
    end

    % Create array to hold all of the data; initalize all values to NaNs
    max_size = max(nums);
    full_data = zeros(max_size, num_genos);
    full_data(:) = NaN;
    
    % Loop through all genotypes and add their data to the array
    for k = 1:num_genos
        full_data(1:length(temp_cell{k}),k) = temp_cell{k};
    end
    
    % Replace the mixed data in epic_data_struct with the new, organized
    % array
    epic_data_struct(i).Data = full_data;

end

clear temp_cell num_genos unique_genos u_genos_idxs i k full_data

%% Reformat into single cells (necessary for exporting data)

cell_struct = struct('Name', unique_types, 'Data', []);

for i = 1:num_types
    
    data_size = size(epic_data_struct(i).Data);
    
    % Combine data and titles into a single cell
    cell_struct(i).Data = epic_data_struct(i).Genotypes;
    cell_struct(i).Data(2:data_size(1)+1, 1:data_size(2))...
        = num2cell(epic_data_struct(i).Data(:,:));

end

%% Generate csv files & save

% Save csv files with combined data

for i = 1:num_types

    cell2csv(fullfile(export_path, [cell_struct(i).Name, '-concatenated.csv']), cell_struct(i).Data);
    
end

%% Make additional files filtering out all of the negative numbers

% Filter negative values (set lower limit of data to 0)
epic_NoNeg = epic_data_struct;

for i = 1:num_types
    epic_NoNeg(i).Data(epic_NoNeg(i).Data<0) = 0;
end

% Turn into a cell struct for exporting
cell_struct_NoNeg = struct('Name', unique_types, 'Data', []);

for i = 1:num_types

    data_size = size(epic_NoNeg(i).Data);
    
    % Combine data and titles into a single cell
    cell_struct_NoNeg(i).Data = epic_NoNeg(i).Genotypes;
    cell_struct_NoNeg(i).Data(2:data_size(1)+1, 1:data_size(2))...
        = num2cell(epic_NoNeg(i).Data(:,:));

end

% Save the files
for i = 1:num_types

    cell2csv(fullfile(export_path, [cell_struct_NoNeg(i).Name, '-concatenated-NoNeg.csv']), cell_struct_NoNeg(i).Data);
    
end

% Save workspace
save(fullfile(export_path, 'concatenated_data'));

%% If specified, plot all of the data

if make_graphs == 1
    
    for i = 1:num_types
        
        notBoxPlot2(epic_data_struct(i).Data);
        title(epic_data_struct(i).DataType,'fontweight','bold');
        set(gca, 'ActivePositionProperty', 'OuterPosition');
        set(gca,'XTick',1:length(epic_data_struct(i).Genotypes));
        set(gca,'XTickLabel',epic_data_struct(i).Genotypes);
        rotateticklabel(gca,45);
        set(gcf, 'Position', [100 100 1000 600]);
        savefig(gcf, fullfile(export_path, [epic_data_struct(i).DataType,'.fig']));
        
    end
    
end
