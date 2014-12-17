% Script for reading in metadata about experiment parameters, importing
% relevant monitor data, and calculating the percentage of flies that wake
% up following a given light stimulus
% V.4 by MMF 14.12.14

% To-do list
% Add filter for dead flies
% Add ability to self-extract info about bin size
% Once deciding whether to do new analysis or old analysis hard code it in.
    % Or better, just add options to do either.
% Find way to export raw data about responsiveness for each genotype
% Find better way to export *everything*
% Find a smarter way to extract label/filename about data from import file


%% Set global parameters
% NOTE: the size of these bins will change based on the width of the
% recording bin. Default values are based on 30 second recording intervals.

% Set the number of bins to check for sleep before a stimulus
sleep_delay = 5; %5 min

% Set the number of bins to check after a stimulus for waking
wake_offset = 2; %Three minutes from the onset of a thirty-second stim

% Set the offset (in number of bins) to check for normalization; if you
% don't want to normalize, make this zero
norm_offset = 10;

% Set monitor directory
monitor_dir = 'E:\Michelle\Box Sync\Labwork\Monitor Files\';

%% Import experimental metadata

% Import metadata
[meta_file, save_path] = uigetfile('D:\Projects\Gal4-Screen\*.xlsx');

expInfo = importdata(fullfile(save_path, meta_file));
genotypes = {expInfo{4:end,2}};

% Convert channel info to nums & filter dead flies.
for i = 4:length(expInfo)
   expInfo{i,3} = str2num(expInfo{i,3}); 
   expInfo{i,3}(expInfo{i,3}<0) = [];
end

%% Find indices corresponding to stimulus onset

% Pick stimulus file
stim_file = expInfo{3,1};

stim_times = findStim(stim_file);

%% Search through fly monitors for activity for each of the given genotypes
% The findWake function imports the relevant data and parses arousal
% responses.

% Create cell array of structs to house all of the data
wakeResults = {};

fly = 0; %Initialize variable to loop through genotypes

for i = 1:length(expInfo)-3
    
    fly = i+3;
    
    wakeResults{i} = struct;
    wakeResults{i}.genotype = expInfo{fly,2};
    
    [wakeResults{i}.arousal_index, wakeResults{i}.normalized_percents, ... 
        wakeResults{i}.fly_sleeping_sum] = ...
        findWake(fly, expInfo, monitor_dir, norm_offset, sleep_delay, wake_offset, stim_times);
    
end

%% Make summary graphs

% Percentages per stim
plot_data = [];

for i = 1:length(wakeResults)
    
    plot_data = [plot_data wakeResults{i}.normalized_percents];

end

figure; notBoxPlot(plot_data);
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Percent Awakened');
tightfig;

savefig(gcf, [save_path, 'percent-awakened']);

% Arousal indices
arousal_indices = {'Genotype', 'Arousal Index'};
arousal_indices_array = [];

index = 2;

for i = 1:length(wakeResults)
   
    arousal_indices{index,1} = wakeResults{i}.genotype;
    arousal_indices{index,2} = wakeResults{i}.arousal_index;
    arousal_indices_array(i) = wakeResults{i}.arousal_index;
    
    index = index+1;
    
end

% plot that
figure; plot(arousal_indices_array,'o');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Arousal Index');
tightfig;
savefig(gcf, [save_path, 'arousal-indices'])

%% Save stuff
% Export that data to a csv  
cell2csv([save_path, 'arousal_indices.csv'], arousal_indices);

% Save the workspace
save([save_path,'AT-data']);

%% Print aggregate info to a csv
%{
% Create cell to hold all of the aggregate stuff
wakeFinal = {'Genotype', 'Stimulus Number', 'Normalized Percent Awakened'};

index = 2;

for i = 1:length(wakeResults)
    
    for j = 1:numStim
        wakeFinal{index,1} = wakeResults{i}.genotype;
        wakeFinal{index,2} = wakeResults{i}.wakeResults(j,1);
        wakeFinal{index,3} = wakeResults{i}.wakeResults(j,2);
        wakeFinal{index,4} = wakeResults{i}.wakeResults(j,3);
        wakeFinal{index,5} = wakeResults{i}.wakeResults(j,4);
        wakeFinal{index,6} = wakeResults{i}.wakeResults(j,5);
        index = index + 1;
    end
    
end

% Export that data to a csv  
cell2csv([save_path, 'results.csv'], wakeFinal);
%}

%% Do the same for activity computations
%{
activity_wake = {'Genotype', 'Intensity', 'Activity'};
activity_sleep = {'Genotype', 'Intensity', 'Activity'};

index_sleep = 2;
index_wake = 2;

% control activity: export cell of form 'genotype, mean, sem, n'

control_activity = {'Genotype', 'Mean', 'SEM', 'n'};
index_ctl = 2;

for i = 1:length(wakeResults)
    
    control_activity{index_ctl,1} = wakeResults{i}.genotype;
    control_activity{index_ctl,2} = mean(wakeResults{i}.controlActivity);
    control_activity{index_ctl,3} = stderr(wakeResults{i}.controlActivity);
    control_activity{index_ctl,4} = length(wakeResults{i}.controlActivity);
    
    index_ctl = index_ctl + 1;
    
    for j = 1:length(wakeResults{i}.sleepActivity)
        activity_sleep{index_sleep,1} = wakeResults{i}.genotype;
        activity_sleep{index_sleep,2} = wakeResults{i}.sleepActivity(j,1);
        activity_sleep{index_sleep,3} = wakeResults{i}.sleepActivity(j,2);
        index_sleep = index_sleep + 1;
    end
    
    for k = 1:length(wakeResults{i}.wakeActivity)
        activity_wake{index_wake,1} = wakeResults{i}.genotype;
        activity_wake{index_wake,2} = wakeResults{i}.wakeActivity(k,1);
        activity_wake{index_wake,3} = wakeResults{i}.wakeActivity(k,2);
        index_wake = index_wake + 1;
    end
    
end
    
cell2csv([save_path, 'activity_wake.csv'], activity_wake);
cell2csv([save_path, 'activity_sleep.csv'], activity_sleep);
cell2csv([save_path, 'activity_control.csv'], control_activity);
%}