function [ losses,h,confints ] = simPerformance( playerlist, niter )
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

coins_per_player = 5;

losses = [0,0,0,0];
h = waitbar(0,'Please wait...');
for iter = 1:niter
    waitbar(iter/niter);
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    loser = env.playGame();
    losses(ordering(loser)) = losses(ordering(loser)) + 1;
end
close(h)

h=figure();
set(h,'Units','Points');
set(h,'Position',[650,550,350,300]);
pvals = linspace(0,0.5,500);
alpha = losses;
beta = sum(losses) - losses;
lossDist1 = betapdf(pvals,alpha(1),beta(1));
lossDist2 = betapdf(pvals,alpha(2),beta(2));
lossDist3 = betapdf(pvals,alpha(3),beta(3));
lossDist4 = betapdf(pvals,alpha(4),beta(4));

title('Distribution of loss rate of each player');
hold on
plot(pvals,lossDist1);
plot(pvals,lossDist2);
plot(pvals,lossDist3);
plot(pvals,lossDist4);
hold off
legend(class(playerlist(1)),class(playerlist(2)),class(playerlist(3)),class(playerlist(4)),...
    'Location','best');

xlabel 'Probability of Loss'
ylabel 'Probability Desnity of Estimate'
grid on

confints = zeros(4,3);

confints(1,:) = lossDistToConfInit(pvals,lossDist1,0.95);
confints(2,:) = lossDistToConfInit(pvals,lossDist2,0.95);
confints(3,:) = lossDistToConfInit(pvals,lossDist3,0.95);
confints(4,:) = lossDistToConfInit(pvals,lossDist4,0.95);


end

