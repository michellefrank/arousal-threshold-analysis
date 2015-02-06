% Script for reading in metadata about experiment parameters, importing
% relevant monitor data, and calculating the percentage of flies that wake
% up following a given light stimulus
% V.4 by MMF 14.12.14


%% Set global parameters

% Set monitor directory
monitor_dir = 'D:\Projects\Monitor-Files\AT\';

% Set envMon num
envMon_num = '4';

%% Import experimental metadata and extract parameters for export

% Import metadata
[meta_file, import_path] = uigetfile('D:\Projects\Gal4-Screen\*.xlsx');

expInfo = importdata(fullfile(import_path, meta_file));
genotypes = {expInfo{4:end,2}};

num_genos = length(genotypes);

% Get export path
save_path = uigetdir(import_path);

% Extract file tag for saving
tag_comps = regexp(meta_file,'-','split');
tag = [tag_comps{1},'-',tag_comps{3}(1:end-5), '-'];

% Convert channel info to nums & filter dead flies.
for i = 4:length(expInfo)
   expInfo{i,3} = str2num(expInfo{i,3}); 
   expInfo{i,3}(expInfo{i,3}<0) = [];
end

%% Extract bin width & set offsets

envMon = importdata([monitor_dir, 'Monitor', envMon_num, '.txt']);

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

% Set the number of bins to check after a stimulus for waking (three
% minutes, plus the bin in which the stim occured)
wake_offset = (3 / bin_width) - 1;

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
activities = struct; %create separate array to store aggregated activity data
latencies = struct; %create separate array to store data about sleep delay after stim

fly = 0; %Initialize variable to loop through genotypes

for i = 1:length(expInfo)-3
    
    fly = i+3;
    
    wakeResults(i).genotype = expInfo{fly,2};
    
    [wakeResults(i).arousal_index, wakeResults(i).normalized_percents, ... 
        wakeResults(i).fly_sleeping_sum, wakeResults(i).activity_struct, wakeResults(i).sleep_delays] = ...
        findWake(fly, expInfo, monitor_dir, norm_offset, sleep_delay, wake_offset, stim_times, bin_width);
    
    % Add data to activity struct
    activities(i).genotype = wakeResults(i).genotype;
    [activities(i).hist, activities(i).fract_hist] = activityHist(wakeResults(i).activity_struct);
    activities(i).meanSleeping = mean(wakeResults(i).activity_struct.asleep);
    activities(i).meanAwake = mean(wakeResults(i).activity_struct.awake);
    activities(i).stdSleeping = std(wakeResults(i).activity_struct.asleep);
    activities(i).stdAwake = std(wakeResults(i).activity_struct.awake);
    activities(i).semSleeping = sem(wakeResults(i).activity_struct.asleep);
    activities(i).semAwake = sem(wakeResults(i).activity_struct.awake);
    
    % Add data to latency struct
    latencies(i).genotype = wakeResults(i).genotype;
    latencies(i).mean = mean(wakeResults(i).sleep_delays);
    latencies(i).std = std(wakeResults(i).sleep_delays);
    latencies(i).sem = sem(wakeResults(i).sleep_delays);
    
end

%% Make summary graphs

% Percentages per stim
normed_percents = [];
normed_percents_cell = genotypes;

for i = 1:num_genos
    
    normed_percents = [normed_percents wakeResults(i).normalized_percents];

    for k = 1:length(stim_times)
        normed_percents_cell{k+1,i} = wakeResults(i).normalized_percents(k);
    end
    
end

% Plot it!
figure('Color', [1 1 1]); notBoxPlot(normed_percents);
title('Arousability','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Percent Awakened');
tightfig;
rotateticklabel(gca,45);
savefig(gcf, fullfile(save_path, [tag,'percent-awakened.fig']));

% Arousal indices
arousal_indices = {'Genotype', 'Arousal Index'};
arousal_indices_array = [];

index = 2;

for i = 1:num_genos
   
    arousal_indices{index,1} = wakeResults(i).genotype;
    arousal_indices{index,2} = wakeResults(i).arousal_index;
    arousal_indices_array(i) = wakeResults(i).arousal_index;
    
    index = index+1;
    
end

% plot that
figure('Color', [1 1 1]); plot(arousal_indices_array,'o');
title('Arousability','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Arousal Index');
tightfig;
rotateticklabel(gca,45);
savefig(gcf, fullfile(save_path, [tag,'arousal-indices.fig']))


%% Plot activity & latency data

% Activity
figure('Color',[1 1 1]); plot([activities.meanSleeping],'o','Color','blue');
title('Responsiveness of sleeping flies','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Beam crossings/minute');
tightfig;
rotateticklabel(gca,45);
savefig(gcf, fullfile(save_path, [tag,'asleep-activity.fig']));

figure('Color',[1 1 1]); plot([activities.meanAwake],'o','Color','red');
title('Responsiveness of awake flies','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Beam crossings/minute');
tightfig;
rotateticklabel(gca,45);
savefig(gcf, fullfile(save_path, [tag,'awake-activity.fig']));

% Latency
figure('Color',[1 1 1]); plot([latencies.mean],'o','Color','blue');
title('Mean latency to sleep following stimulus','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
tightfig;
rotateticklabel(gca,45);
savefig(gcf, fullfile(save_path, [tag,'latencies.fig']));
%% Save stuff
% Export that data to a csv  
cell2csv(fullfile(save_path, [tag,'arousal_indices.csv']), arousal_indices);

cell2csv(fullfile(save_path, [tag,'percent_awakened.csv']),normed_percents_cell);

% Save the workspace
save(fullfile(save_path, [tag,'AT-data']));