% Plots sorted versions of both percent awakened and individual arousal
% probabilities

%% Sort individual arousal probabilities

% Sort
[~,sorted_at_prob_means] = sort(nanmean(arousal_probabilities_array));
sorted_genos1 = genotypes(sorted_at_prob_means);

% Plot it
notBoxPlot2(arousal_probabilities_array(:,sorted_at_prob_means));
hold on; line([0 num_genos+5], [at_prob_mean at_prob_mean], 'Color', 'k');
line([0 num_genos+5], [at_prob_mean+at_prob_sd at_prob_mean+at_prob_sd], 'Color', [0.8 0.8 0.8]);
line([0 num_genos+5], [at_prob_mean-at_prob_sd at_prob_mean-at_prob_sd], 'Color', [0.8 0.8 0.8]);
line([0 num_genos+5], [at_prob_mean+2*at_prob_sd at_prob_mean+2*at_prob_sd], 'Color', [0.6 0.6 0.6]); 
line([0 num_genos+5], [at_prob_mean-2*at_prob_sd at_prob_mean-2*at_prob_sd], 'Color', [0.6 0.6 0.6]); 
title('Arousal probabilities (individual flies)','fontweight','bold');
set(gca,'XTick',1:length(sorted_genos1));
set(gca,'XTickLabel',sorted_genos1);
ylabel('Probability of arousal');
rotateticklabel(gca,45);

%% Sort percent awakened

% Sort
[~, sorted_at_percents] = sort(nanmean(normed_percents));
sorted_genos2 = genotypes(sorted_at_percents);

% Plot it
notBoxPlot2(normed_percents(:,sorted_at_percents));
hold on; line([0 num_genos+5], [tot_mean tot_mean], 'Color', 'k');
line([0 num_genos+5], [tot_mean+normed_std tot_mean+normed_std], 'Color', [0.8 0.8 0.8]);
line([0 num_genos+5], [tot_mean-normed_std tot_mean-normed_std], 'Color', [0.8 0.8 0.8]);
line([0 num_genos+5], [tot_mean+2*normed_std tot_mean+2*normed_std], 'Color', [0.6 0.6 0.6]); 
line([0 num_genos+5], [tot_mean-2*normed_std tot_mean-2*normed_std], 'Color', [0.6 0.6 0.6]); 
title('Arousability','fontweight','bold');
set(gca,'XTick',1:length(sorted_genos2));
set(gca,'XTickLabel',sorted_genos2);
ylabel('Percent Awakened');
rotateticklabel(gca,45);



