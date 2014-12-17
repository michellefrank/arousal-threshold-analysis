function [arousal_index, normalized_percents, fly_sleeping_sum] = findWake(fly, expInfo, monitor_dir, norm_offset, sleep_delay, wake_offset, stim_times)
% For each genotype used in a given experiment, imports the monitor
% containing those flies, parses out on the relevant channels,
% calculates the percentage that woke up, and returns that value as a cell.
% fly = the genotype of interest (e.g. 'ED')
% stim_windows = the windows containing a stimulus, calculated in the
% LightAnalysis script
% save_path is the path to which the file should be saved
% norm_offset is the number of bins back to check for spontaneous wakenings.
% If so, normalization computes the spontaneous wakenings from a 10 minute
% period prior to simulus onset.

%% Import the monitor info we're interested in and search it for flies that wake up

%Import monitor info and parse it down to the flies/times we actually care
%about
flies = readMonitor(monitor_dir, expInfo, fly);

%% Calculate indices & windows for relevant times

% Convert stim times to stim indices
stim_indices = zeros(length(stim_times),1);

for k = 1:length(stim_times)
    stim_indices(k) = find(strcmp(flies.textdata(:,2),stim_times{k,1}) & strcmp(flies.textdata(:,3),stim_times{k,2}));
end

% Calculate windows over which to look for sleep/arousal
sleep_windows = {};
arousal_windows = {};
spontaneous_sleep_windows = {};
spontaneous_arousal_windows = {};

for k = 1:length(stim_indices)
    sleep_windows{k} = stim_indices(k)-sleep_delay:stim_indices(k)-1;
    arousal_windows{k} = stim_indices(k):stim_indices(k)+wake_offset;
    spontaneous_sleep_windows{k} = sleep_windows{k} - norm_offset;
    spontaneous_arousal_windows{k} = arousal_windows{k} - norm_offset;
end


%% Calculate which flies were sleeping & which flies woke up

fly_asleep_array = getIsSleeping(flies,sleep_windows);
fly_awake_array = getIsWakes(flies,arousal_windows);
spontaneous_asleep_array = getIsSleeping(flies,spontaneous_sleep_windows);
spontaneous_awake_array = getIsWakes(flies,spontaneous_arousal_windows);

% Find number of flies awakening in response to each stimulus
% (and the number of sleeping flies, used below)

% fly_arousal_array contains the number of flies that woke during the
% period following the stimulus
% spontaneous_arousal_array does the same for flies awakening spontaneously

fly_arousal_array = zeros(length(stim_indices),1);
spontaneous_arousal_array = zeros(length(stim_indices),1);
fly_sleeping_sum = zeros(length(stim_indices),1);
fly_sleeping_spont = zeros(length(stim_indices),1);

for k = 1:length(fly_arousal_array)
    fly_arousal_array(k) = sum(fly_asleep_array{k}==1 & fly_awake_array{k}==1);
    
    spontaneous_arousal_array(k) = sum(spontaneous_asleep_array{k}==1 ...
        & spontaneous_awake_array{k}==1);
    
    fly_sleeping_sum(k) = sum(fly_asleep_array{k});
    fly_sleeping_spont(k) = sum(spontaneous_asleep_array{k});
    
end

    
%% Compute the percent of flies that respond to each stimulus

percent_arousal_array = zeros(1,length(fly_arousal_array));
percent_spontaneous_array = zeros(1,length(fly_arousal_array));

for i=1:length(percent_arousal_array)
    
    percent_arousal_array(i) = fly_arousal_array(i) / sum(fly_asleep_array{i});
    percent_spontaneous_array(i) = spontaneous_arousal_array(i) / sum(spontaneous_asleep_array{i});
    
end

%% Normalization

% Normalize NoI wakenings - (% aroused - % spontaneously awake)/ (100% - % spontaneously awake)
normalized_percents = zeros(length(percent_arousal_array),1);

for i = 1:length(normalized_percents)
    normalized_percents(i) = ( percent_arousal_array(i) - percent_spontaneous_array(i) ) / (1 - percent_spontaneous_array(i) ) * 100;
end


%% Calculate aggregate fraction of responsive flies
% The 'arousal index' is the normalized fraction of flies that responded
% over all of the stimuli, calculated as ( (all flies awakened)/(all flies
% asleep) - (spontaneous awakenings/spontaneous asleep) ) / (1 - spont.
% fraction)

fraction_awakened = sum(fly_arousal_array)/sum(fly_sleeping_sum);
fraction_spontaneous = sum(spontaneous_arousal_array)/sum(fly_sleeping_spont);

arousal_index = (fraction_awakened - fraction_spontaneous) / (1 - fraction_spontaneous);

%% Export the raw sleep array (of flies sleeping vs not sleeping)
%{
LightResponsesRaw = {'Stimulus Number', 'Stim intensity'};

for i = 1:length(flySleepArray(1,:))
    LightResponsesRaw{1,i+2} = '';
end

for i = 1:numStim
    LightResponsesRaw{i+1,1} = i;
    LightResponsesRaw{i+1,2} = intensities(i);
    
    for j = 1:length(flySleepArray(1,:))
        LightResponsesRaw{i+1,j+2} = flySleepArray(i,j);
    end
end
    
fileSaveRaw = [fullfile(root_dir, save_path, 'raw', fly.genotype), '-raw.csv'];
cell2csv(fileSaveRaw, LightResponsesRaw);
%}

