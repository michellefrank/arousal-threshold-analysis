function [act_hist, act_hist_frac] = activityHist(act_struct)
% activityHist takes a struct of activity data, reformats it, and creates a new
% struct containing histogram information as well as a second struct
% containing the same data but modified to represent a fraction of total
% counts

act_hist = struct;
act_hist.awake = struct;
act_hist.asleep = struct;

[act_hist.asleep.y, act_hist.asleep.x] = hist(act_struct.asleep,max(act_struct.asleep));
[act_hist.awake.y, act_hist.awake.x] = hist(act_struct.awake,max(act_struct.awake));

act_hist.awake.x = act_hist.awake.x';
act_hist.awake.y = act_hist.awake.y';

act_hist.asleep.x = act_hist.asleep.x';
act_hist.asleep.y = act_hist.asleep.y';

%% Creat second histogram struct with fraction data
act_hist_frac = act_hist;
act_hist_frac.asleep.y = act_hist_frac.asleep.y/sum(act_hist.asleep.y);

act_hist_frac.awake.y = act_hist_frac.awake.y/sum(act_hist.awake.y);

%% Plot the data
% figure('Color', [1 1 1]); subplot(1,2,1); 
% hist(act_struct.asleep,max(act_struct.asleep)); title('Asleep flies');
% ylabel('Counts'); xlabel('Beam crossings/minute');
% 
% subplot(1,2,2);
% hist(act_struct.awake,max(act_struct.awake)); title('Awake flies');
% xlabel('Beam crossings/minute');