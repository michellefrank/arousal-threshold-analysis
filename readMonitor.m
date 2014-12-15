function flies = readMonitor(monitor_dir, expInfo, fly)
% Given metadata about a particular experiment and a specified fly (i.e. genotype, parses
% data from that night to isolate the channels containing the genotype of
% interest and throws out any dead flies.

%% Read in data files

flies = importdata([monitor_dir, expInfo{fly,1}, '.txt']);

% Trim down file to days and times of interest

% extract date info

% Identify start & end indices (expInfo{1,1} and {2,1} contain the start
% and end date of the experiment.)
date_idx1 = find(strcmp(flies.textdata(:,2), expInfo{1,1}),1,'first');
date_idx2 = find(strcmp(flies.textdata(:,2), expInfo{2,1}),1,'last');

% Slice down the data file
flies.data = flies.data(date_idx1:date_idx2,:);
flies.textdata = flies.textdata(date_idx1:date_idx2,:);

% Cut it down even further so we're only looking at night
nightON = '20:00:00';
nightOFF = '08:00:00';

time_idx1 = find(strcmp(flies.textdata(:,3), nightON),1,'first');
time_idx2 = find(strcmp(flies.textdata(:,3), nightOFF),1,'last');

flies.data = flies.data(time_idx1:time_idx2,:);
flies.textdata = flies.textdata(time_idx1:time_idx2,:);

% Trim down to channels of interest
flies.data = flies.data(:,end-31:end);
    
flies.data = flies.data(:,expInfo{fly,3}); %expInfo{fly,3} contains the channels for that particular genotype


%% Throw out dead flies

% Option #1: automatically filter out dead flies based on some pre-defined
% criteria (Hypnos: no activity over 24 hrs; alternatively, can go for no
% activity after midnight on the last night or whatever else you want)

% deadIndices = [];
%
% for i=1:length(flies.data(1,:))
%     if(flies.data(1921:end,i)==0) %for midnight to end, use 1921:end
%         deadIndices = [deadIndices i];
%     end
% end

% Option #2:
% Enter additional flies to throw out (numbers relative to the channels
% actually included in this particular genotype)

% deadFlies = input('Enter channel numbers of additional flies to discard: ', 's');
% deadFlies = str2num(deadFlies);
% 
% deadIndices = [deadIndices deadFlies];

% Option #3: Read in dead flies from the metadata file (entered manually
% based on looking at the actograms)

%{
dead_flies = str2num(fly.dead_flies);
deadIndices = zeros(1, length(dead_flies));

for i = 1:length(dead_flies)
    deadIndices(i) = find(channels==dead_flies(i));
end

flies.data(:,deadIndices) = [];
%}

