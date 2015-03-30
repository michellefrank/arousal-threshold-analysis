function plotArousalProbabilities(arousal_probs, ind_var, var_label)

figure('Color', [1 1 1]);
plot(nanmean(ind_var),arousal_probs, 'ko', 'MarkerFaceColor','k','MarkerSize',4);
ylabel('Probability of arousal'); xlabel(var_label);
