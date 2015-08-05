% Script for reading in metadata about experiment parameters, importing
% relevant monitor data, and calculating the percentage of flies that wake
% up following a given light stimulus
% V.6 by MMF 08.15


%% Set global parameters

% Set envMon num
envMon_num = '4';

%% Import experimental metadata and extract parameters for export

% Import metadata
disp('Select experimental metadata');
[meta_file, import_path] = uigetfile('D:\Projects\Gal4-Screen\*.xlsx');

expInfo = importdata(fullfile(import_path, meta_file));
genotypes = {expInfo{4:end,2}};

num_genos = length(genotypes);

% Get export path
disp('Select output directory');
save_path = uigetdir(import_path);

% Extract file tag for saving
tag_comps = regexp(meta_file,'-','split');
tag = [tag_comps{1},'-',tag_comps{3}(1:end-5), '-'];

% Convert channel info to nums
for i = 4:length(expInfo)
   expInfo{i,3} = str2num(expInfo{i,3}); 
   expInfo{i,3}(expInfo{i,3}<0) = [];
end

% Select monitor directory
% First try to find a folder called 'Monitors' in the parent dir
path_components = regexp(import_path, '\', 'split');
tent_mon_dir = fullfile(path_components{1:end-2}, 'Monitors');
if exist(tent_mon_dir, 'file')
    monitor_dir = tent_mon_dir;
else
    disp('Select monitor directory');
    monitor_dir = uigetdir(fullfile(path_components{1:end-2}));
end
clear tent_mon_dir path_components
%% Extract bin width & set offsets

envMon = importdata(fullfile(monitor_dir, ['Monitor', envMon_num, '.txt']));

% Cut down envMon size to days of experiment
    % Identify start & end indices (expInfo{1,1} and {2,1} contain the start
    % and end date of the experiment.)
date_idx1 = find(strcmp(envMon.textdata(:,2), expInfo{1,1}),1,'first');
date_idx2 = find(strcmp(envMon.textdata(:,2), expInfo{2,1}),1,'last');

% Slice down the data file
envMon.data = envMon.data(date_idx1:date_idx2,:);
envMon.textdata = envMon.textdata(date_idx1:date_idx2,:);

% Assume that the bins between 9 pm and whatever comes next on the first
% day of AT is indicative of the bin width

% Identify that index
timeidx = find(strcmp(envMon.textdata(:,2), expInfo{1,1}) & strcmp(envMon.textdata(:,3), '21:00:00'));

% Extract the time stamps
time1 = envMon.textdata{timeidx,3};
time2 = envMon.textdata{timeidx+1,3};

% Convert to numbers
time1 = str2double(regexp(time1, ':', 'split'));
time2 = str2double(regexp(time2, ':', 'split'));

% Convert to minutes
t1 = time1(1)*60 + time1(2) + time1(3)/60;
t2 = time2(1)*60 + time2(2) + time2(3)/60;

% Identify the bin width
bin_width = t2 - t1;

% Clean up the workspace
clear t1 t2 timeidx time1 time2

% Set the number of bins to check for sleep before a stimulus
sleep_delay = 5 / bin_width; %5 min

% Set the number of bins to check after a stimulus for waking (two
% minutes, plus the bin in which the stim occured)
wake_offset = (2 / bin_width) - 1;

% Set the offset (in number of bins) to check for normalization; if you
% don't want to normalize, make this zero. Default value is 10 min.
norm_offset = 10 / bin_width;

%% Find indices corresponding to stimulus onset

% Pick stimulus file
stim_file = expInfo{3,1};

stim_times = findStim(stim_file, bin_width);

%% Search through fly monitors for activity for each of the given genotypes
% The findWake function imports the relevant data and parses arousal
% responses.

% Create cell array of structs to house all of the data
wakeResults = struct;

fly = 0; %Initialize variable to loop through genotypes

% Initialize wait bar to track progress

h = waitbar(num_genos, 'Processing...');

for i = 1:length(expInfo)-3
    
    fly = i+3;
    
    waitbar(fly/num_genos, h, ['Processing: ', expInfo{fly,2}]);
    
    wakeResults(i).genotype = expInfo{fly,2};
    
    [wakeResults(i).arousal_index, wakeResults(i).normalized_percents, ... 
        wakeResults(i).fly_sleeping_sum, wakeResults(i).activity_struct, wakeResults(i).sleep_delays,...
        wakeResults(i).sleep_durations, wakeResults(i).wake_durations, ...
        wakeResults(i).wake_activities, wakeResults(i).arousal_probabilities, wakeResults(i).avg_percent_spontaneous] = ...
        findWake(fly, expInfo, monitor_dir, norm_offset, sleep_delay, wake_offset, stim_times, bin_width);
    
end

% Get rid of the waitbar
close(h)

%% Parse latency data

% Calculate max number of flies
num_flies = zeros(1,num_genos);
for i = 1:num_genos
    num_flies(i) = length(wakeResults(i).arousal_probabilities);
end

max_num_flies = max(num_flies);

% Initialize array to hold latency data
latency_array = zeros(max_num_flies, num_genos);
latency_array(:,:) = NaN;

for i = 1:num_genos
    latency_array(1:size(wakeResults(i).sleep_delays,2),i)...
        =  nanmean(wakeResults(i).sleep_delays,1)';
end

% Create latency cell to hold data on mean latency to sleep onset for each
% fly of each genotype
latency_cell = genotypes;
latency_cell(2:max_num_flies+1, 1:num_genos) = num2cell(latency_array(:,:));

%% Parse activity data

% Initialize struct to hold activity data
activity_struct = struct;

activity_struct.awake = zeros(max_num_flies, num_genos);
activity_struct.asleep = zeros(max_num_flies, num_genos);

activity_struct.awake(:,:) = NaN;
activity_struct.asleep(:,:) = NaN;

avg_awake_activity = zeros(3, num_genos);
avg_asleep_activity = zeros(3, num_genos);

% Extract activity info for each genotype
for i = 1:num_genos
    activity_struct.awake(1:size(wakeResults(i).activity_struct(2).awake,2),i)...
        = nanmean(wakeResults(i).activity_struct(2).awake,1)';
    
    activity_struct.asleep(1:size(wakeResults(i).activity_struct(2).asleep,2),i)...
        = nanmean(wakeResults(i).activity_struct(2).asleep)';
    
    for k = 1:3
        avg_awake_activity(k, i) = nanmean(nanmean(wakeResults(i).activity_struct(k).awake));
        avg_asleep_activity(k,i) = nanmean(nanmean(wakeResults(i).activity_struct(k).asleep));
    end
    
end

% Create cells to hold activity data
awake_activity_cell = genotypes;
asleep_activity_cell = genotypes;

awake_activity_cell(2:max_num_flies+1, 1:num_genos) ...
    = num2cell(activity_struct.awake(:,:));
asleep_activity_cell(2:max_num_flies+1, 1:num_genos) ...
    = num2cell(activity_struct.asleep(:,:));

%% Extract arousability data

% Percentages per stim
normed_percents = [wakeResults.normalized_percents];
normed_percents_cell = genotypes;

normed_percents_cell(2:length(stim_times)+1, 1:num_genos) = num2cell(normed_percents(:,:));

% Arousal indices
arousal_indices_cell = genotypes;
arousal_indices_cell(2, 1:num_genos) = num2cell([wakeResults.arousal_index]);

% Arousal probabilities
% Initialize array to hold various probabilities
arousal_probabilities_array = zeros(max_num_flies,num_genos);
arousal_probabilities_array(:,:) = NaN;

% Add arousal probabilities for individual flies
for i = 1:num_genos
    arousal_probabilities_array(1:length(wakeResults(i).arousal_probabilities),i)...
        = wakeResults(i).arousal_probabilities';
end

arousal_probabilities_cell = genotypes;
arousal_probabilities_cell(2:max_num_flies+1, 1:num_genos)...
    = num2cell(arousal_probabilities_array(:,:));
%% Plot everything

makeATGraphs

%% Save stuff

% Export data to a csv  
cell2csv(fullfile(save_path, [tag, 'sleep_latency.csv']), latency_cell);
cell2csv(fullfile(save_path, [tag, 'awake_activities.csv']), awake_activity_cell);
cell2csv(fullfile(save_path, [tag, 'asleep_activities.csv']), asleep_activity_cell);
cell2csv(fullfile(save_path, [tag, 'percent_awakened.csv']), normed_percents_cell);
cell2csv(fullfile(save_path, [tag, 'arousal_indices.csv']), arousal_indices_cell);
cell2csv(fullfile(save_path, [tag, 'arousal_probabilities.csv']), arousal_probabilities_cell);

% Save the workspace
save(fullfile(save_path, [tag,'AT-data']));