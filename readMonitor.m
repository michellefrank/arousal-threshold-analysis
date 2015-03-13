function flies = readMonitor(monitor_dir, expInfo, fly)
% Given metadata about a particular experiment and a specified fly (i.e. genotype, parses
% data from that night to isolate the channels containing the genotype of
% interest and throws out any dead flies.

%% Read in data files

flies = importdata(fullfile(monitor_dir, [expInfo{fly,1}, '.txt']));

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

% Automatically identify flies that don't move over the course of the night
% (i.e. NO activity from 8 pm to 8 am) and categorize them as dead.
% Hypnos: categorize dead flies as those with no activity over 24 hrs.
% (Pretty sure that's what Stephen's software does, too.)

deadIndices = [];

for i=1:length(flies.data(1,:))
    if(flies.data(:,i)==0) %for midnight to end, use 1921:end
        deadIndices = [deadIndices i];
    end
end


flies.data(:,deadIndices) = [];

