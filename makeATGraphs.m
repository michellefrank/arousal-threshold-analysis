% makeATGraphs takes info from the wakeResults struct generated in
% ArousalAnalysis and creates summary graphs displaying various relevant
% parameters

%% Plot percent awakened

% Percentages per stim
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
set(gca, 'ActivePositionProperty', 'OuterPosition');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Percent Awakened');
rotateticklabel(gca,45);
set(gcf, 'Position', [100 100 1000 600]);
savefig(gcf, fullfile(save_path, [tag,'percent-awakened.fig']));

%% Plot per-fly arousability

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
set(gcf, 'Position', [100 100 1000 600]);
savefig(gcf, fullfile(save_path, [tag,'arousal-probabilities.fig']))

%% Plot arousal indices

figure('Color', [1 1 1]); plot([wakeResults.arousal_index],'ok','markersize',5,'markerfacecolor',[0.8,0.8,0.8]);
title('Arousability','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Arousal Index');
rotateticklabel(gca,45);
set(gcf, 'Position', [100 100 1000 600]);
savefig(gcf, fullfile(save_path, [tag,'arousal-indices.fig']))

%% Plot activity data (just the second minute)

% Plot awake flies
notBoxPlot2(activity_struct.awake);
title('Responsiveness of awake flies','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Beam crossings/minute');
rotateticklabel(gca,45);
set(gcf, 'Position', [100 100 1000 600]);
savefig(gcf, fullfile(save_path, [tag,'awake-activity.fig']));

% Plot sleeping flies
notBoxPlot2(activity_struct.asleep);
title('Responsiveness of sleeping flies','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Beam crossings/minute');
rotateticklabel(gca,45);
set(gcf, 'Position', [100 100 1000 600]);
savefig(gcf, fullfile(save_path, [tag,'asleep-activity.fig']));

% Plot averages separated by minute
figure('Color',[1 1 1]); plot(avg_asleep_activity(1,:),'o','Color','red','markerfacecolor','red','markersize',4);
hold on; plot(avg_asleep_activity(2,:),'o','Color','blue','markerfacecolor','blue','markersize',4);
plot(avg_asleep_activity(3,:),'o','Color','k','markerfacecolor','k','markersize',4);
legend('First minute', 'Second minute', 'Third minute');
title('Responsiveness of sleeping flies','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Beam crossings/minute');
rotateticklabel(gca,45);
set(gcf, 'Position', [100 100 1000 600]);
savefig(gcf, fullfile(save_path, [tag,'asleep-activity.fig']));

figure('Color',[1 1 1]); plot(avg_awake_activity(1,:),'o','Color','red','markerfacecolor','red','markersize',4);
hold on; plot(avg_awake_activity(2,:),'o','Color','b','markerfacecolor','b','markersize',4);
plot(avg_awake_activity(3,:),'o','Color','k','markerfacecolor','k','markersize',4);
legend('First minute', 'Second minute', 'Third minute');
title('Responsiveness of awake flies','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Beam crossings/minute');
rotateticklabel(gca,45);
set(gcf, 'Position', [100 100 1000 600]);
savefig(gcf, fullfile(save_path, [tag,'awake-activity.fig']));

%% Plot latency
notBoxPlot2(latency_array);
title('Latency to sleep following stimulus','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Minutes');
rotateticklabel(gca,45);
set(gcf, 'Position', [100 100 1000 600]);
savefig(gcf, fullfile(save_path, [tag,'latencies.fig']));

%% Plot average spontaneous arousals

notBoxPlot2([wakeResults.avg_percent_spontaneous]);
title('Mean percent spontaneous arousals','fontweight','bold');
set(gca,'XTick',1:length(genotypes));
set(gca,'XTickLabel',genotypes);
ylabel('Mean percent of flies awakening');
rotateticklabel(gca,45);
set(gcf, 'Position', [100 100 1000 600]);
savefig(gcf, fullfile(save_path, [tag,'avg_spontaneous.fig']));