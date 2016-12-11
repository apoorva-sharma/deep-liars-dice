clear
close all force
load e2e_oa_comparison;

%% Plot Learning Rates

close all
hc = figure();
set(hc,'Units','Points');
set(hc,'Position',[650,550,350,300]);

hold on
plot(oa_num_train_iters,oa_loss_rate);
plot(e2e_20_num_train_iters, e2e_20_loss_rate);
plot(e2e_2020_num_train_iters, e2e_2020_loss_rate);
plot(e2e_202020_num_train_iters, e2e_202020_loss_rate);
grid on
title 'Training Curves of OA vs EndToEnd Architectures'
xlabel('Number of Self Play Games Played');
ylabel('Average loss rate against 3 Naive Agents');
grid on

legend('Observer-Actor', 'EndToEnd-1x20', 'EndToEnd-2x20', 'EndToEnd-3x20');

%% Test all against eachother

playerlist = {oa_1,e2e_20_1,e2e_2020_1,e2e_202020_1};
niter = 15000;

[ losses_allcomp,h,confints_allcomp ] = simPerformance( playerlist, niter );
legend('Observer-Actor', 'EndToEnd-1x20', 'EndToEnd-2x20', 'EndToEnd-3x20');




