% Script for reading in metadata about experiment parameters, importing
% relevant monitor data, and calculating the percentage of flies that wake
% up following a given light stimulus
% V.5 by MMF 03.15


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
disp('Select monitor directory');
split = regexp(import_path,'\');
monitor_dir = uigetdir(import_path(1:split(end-1)));
clear split
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
activities = struct; %create separate array to store aggregated activity data
latencies = struct; %create separate array to store data about sleep delay after stim

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
    
    % Add data to activity struct
    activities(i).genotype = wakeResults(i).genotype;
    [activities(i).hist, activities(i).fract_hist] = activityHist(wakeResults(i).activity_struct(1));
    activities(i).meanSleeping(1,:) = mean(wakeResults(i).activity_struct(1).asleep);
    activities(i).meanAwake(1,:) = mean(wakeResults(i).activity_struct(1).awake);
    activities(i).stdSleeping(1,:) = std(wakeResults(i).activity_struct(1).asleep);
    activities(i).stdAwake(1,:) = std(wakeResults(i).activity_struct(1).awake);
    activities(i).semSleeping(1,:) = sem(wakeResults(i).activity_struct(1).asleep);
    activities(i).semAwake(1,:) = sem(wakeResults(i).activity_struct(1).awake);
    % 2nd minute
    activities(i).meanSleeping(2,:) = mean(wakeResults(i).activity_struct(2).asleep);
    activities(i).meanAwake(2,:) = mean(wakeResults(i).activity_struct(2).awake);
    activities(i).stdSleeping(2,:) = std(wakeResults(i).activity_struct(2).asleep);
    activities(i).stdAwake(2,:) = std(wakeResults(i).activity_struct(2).awake);
    activities(i).semSleeping(2,:) = sem(wakeResults(i).activity_struct(2).asleep);
    activities(i).semAwake(2,:) = sem(wakeResults(i).activity_struct(2).awake);
    % 3rd minute
    activities(i).meanSleeping(3,:) = mean(wakeResults(i).activity_struct(3).asleep);
    activities(i).meanAwake(3,:) = mean(wakeResults(i).activity_struct(3).awake);
    activities(i).stdSleeping(3,:) = std(wakeResults(i).activity_struct(3).asleep);
    activities(i).stdAwake(3,:) = std(wakeResults(i).activity_struct(3).awake);
    activities(i).semSleeping(3,:) = sem(wakeResults(i).activity_struct(3).asleep);
    activities(i).semAwake(3,:) = sem(wakeResults(i).activity_struct(3).awake);
    
    % Add data to latency struct
    latencies(i).genotype = wakeResults(i).genotype;
    latencies(i).mean = mean(wakeResults(i).sleep_delays);
    latencies(i).std = std(wakeResults(i).sleep_delays);
    latencies(i).sem = sem(wakeResults(i).sleep_delays);
    
end

%% Make summary graphs: arousability

% Percentages per stim
normed_percents = [];
normed_percents_cell = genotypes;

for i = 1:num_genos
    
    normed_percents = [normed_percents wakeResults(i).normalized_percents];

    for k = 1:length(stim_times)
        normed_percents_cell{k+1,i} = wakeResults(i).normalized_percents(k);
    end
    
end

normed_means = nanmean(normed_percents);
tot_mean = nanmean(normed_means);
normed_std = nanstd(normed_means);

% Plot it!
notBoxPlot2(normed_percents);
hold on; line([0 num_genos+5], [tot_mean tot_mean], 'Color', 'k');
line([0 num_genos+5], [tot_mean+normed_std tot_mean+normed_std], 'Color', [0.8 0.8 0.8]);
line([0 num_genos+5], [tot_mean-normed_std tot_mean-normed_std], 'Color', [0.8 0.8 0.8]);
line([0 num_genos+5], [tot_mean+2*normed_std tot_mean+2*normed_std], 'Color', [0.6 0.6 0.6]); 
line([0 num_genos+5], [tot_mean-2*normed_std tot_mean-2*normed_std], 'Color', [0.6 0.6 0.6]); 
title('Arousability','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Percent Awakened');
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
figure('Color', [1 1 1]); plot(arousal_indices_array,'ok','markersize',5,'markerfacecolor',[0.8,0.8,0.8]);
title('Arousability','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Arousal Index');
rotateticklabel(gca,45);
savefig(gcf, fullfile(save_path, [tag,'arousal-indices.fig']))


%% Per-fly arousability

% Calculate max number of flies
num_flies = zeros(1,num_genos);
for i = 1:num_genos
    num_flies(i) = length(wakeResults(i).arousal_probabilities);
end

max_num_flies = max(num_flies);

% Initialize array to hold various probabilities
arousal_probabilities_array = zeros(max_num_flies,num_genos);
arousal_probabilities_array(:,:) = NaN;

% Add arousal probabilities for individual flies
for i = 1:num_genos
    arousal_probabilities_array(1:length(wakeResults(i).arousal_probabilities),i) = wakeResults(i).arousal_probabilities';
end

% Find group properties
gp_means = nanmean(arousal_probabilities_array);
at_prob_mean = nanmean(gp_means);
at_prob_sd = nanstd(gp_means);

% Plot the data
notBoxPlot2(arousal_probabilities_array);
title('Arousal probabilities (individual flies)','fontweight','bold');
hold on; line([0 num_genos+5], [at_prob_mean at_prob_mean], 'Color', 'k');
line([0 num_genos+5], [at_prob_mean+at_prob_sd at_prob_mean+at_prob_sd], 'Color', [0.8 0.8 0.8]);
line([0 num_genos+5], [at_prob_mean-at_prob_sd at_prob_mean-at_prob_sd], 'Color', [0.8 0.8 0.8]);
line([0 num_genos+5], [at_prob_mean+2*at_prob_sd at_prob_mean+2*at_prob_sd], 'Color', [0.6 0.6 0.6]); 
line([0 num_genos+5], [at_prob_mean-2*at_prob_sd at_prob_mean-2*at_prob_sd], 'Color', [0.6 0.6 0.6]); 
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Probability of arousal');
rotateticklabel(gca,45);
savefig(gcf, fullfile(save_path, [tag,'arousal-probabilities.fig']))

%% Plot activity data

% Extract deets
meanSleeping = [activities.meanSleeping];
meanAwake = [activities.meanAwake];

% Plot stuff!
figure('Color',[1 1 1]); plot(meanSleeping(1,:),'o','Color','red','markerfacecolor','red','markersize',4);
hold on; plot(meanSleeping(2,:),'o','Color','blue','markerfacecolor','blue','markersize',4);
plot(meanSleeping(3,:),'o','Color','k','markerfacecolor','k','markersize',4);
legend('First minute', 'Second minute', 'Third minute');
title('Responsiveness of sleeping flies','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Beam crossings/minute');
rotateticklabel(gca,45);
savefig(gcf, fullfile(save_path, [tag,'asleep-activity.fig']));

figure('Color',[1 1 1]); plot(meanAwake(1,:),'o','Color','red','markerfacecolor','red','markersize',4);
hold on; plot(meanAwake(2,:),'o','Color','b','markerfacecolor','b','markersize',4);
plot(meanAwake(3,:),'o','Color','k','markerfacecolor','k','markersize',4);
legend('First minute', 'Second minute', 'Third minute');
title('Responsiveness of awake flies','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Beam crossings/minute');
rotateticklabel(gca,45);
savefig(gcf, fullfile(save_path, [tag,'awake-activity.fig']));

%% Plot latency
figure('Color',[1 1 1]); plot([latencies.mean],'o','Color','k', 'MarkerFaceColor',[0.5 0.5 0.5],'MarkerSize',5);
title('Mean latency to sleep following stimulus','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
rotateticklabel(gca,45);
savefig(gcf, fullfile(save_path, [tag,'latencies.fig']));

%% Plot average spontaneous arousals

figure('Color', [1 1 1]); plot([wakeResults.avg_percent_spontaneous], 'ok', 'MarkerFaceColor', 'k', 'MarkerSize', 5);
title('Mean percent spontaneous arousals','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Mean percent of flies awakening');
rotateticklabel(gca,45);
savefig(gcf, fullfile(save_path, [tag,'avg_spontaneous.fig']));

%% Save stuff
% Export that data to a csv  
cell2csv(fullfile(save_path, [tag,'arousal_indices.csv']), arousal_indices);

cell2csv(fullfile(save_path, [tag,'percent_awakened.csv']),normed_percents_cell);

% Save the workspace
save(fullfile(save_path, [tag,'AT-data']));