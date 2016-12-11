%% Barscene

player1.training = false;
br1.training = false;

playerlist = {player1, br1, naive1, cons1};
niter = 30000;

[ losses_barscene,h,confints_barscene ] = simPerformance( playerlist, niter );
legend('SelfPlay', 'SelfPlayBestResponse', 'Naive', 'Conservative');


%% Selfplay vs 3 Best Responses
br2 = DeepAgent(br1.obsNet,br1.piNet,br1.QNet,br1.obsX,br1.obsY,br1.PiX,br1.QX);
br2.training = false;
br3 = DeepAgent(br1.obsNet,br1.piNet,br1.QNet,br1.obsX,br1.obsY,br1.PiX,br1.QX);
br3.training = false;

playerlist = {player1, br1, br2, br3};
niter = 15000;

[ losses_spvsbr,h,confints_spvsbr ] = simPerformance( playerlist, niter );
legend('SelfPlay', 'SelfPlayBestResponse', 'SelfPlayBestResponse', 'SelfPlayBestResponse');

%% Selfplay vs 3 Conservative

playerlist = {player1, cons1, cons2, cons3};
niter = 15000;

[ losses_spvscons,h,confints_spvscons ] = simPerformance( playerlist, niter );
legend('SelfPlay', 'Conservative', 'Conservative', 'Conservative');




