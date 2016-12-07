%% Test Lvl1Agent vs NaiveAgents
lvl1 = Level1NaiveAgent();

playerlist = {lvl1, naive1 naive2 naive3};

losses_lvl1 = [0,0,0,0];
niter = 15000;
h = waitbar(0,'Please wait...');
for iter = 1:niter
    waitbar(iter/niter);
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    loser = env.playGame();
    losses_lvl1(ordering(loser)) = losses_lvl1(ordering(loser)) + 1;
end
close(h)

h=figure();
set(h,'Units','Points');
set(h,'Position',[650,550,350,300]);
pvals = linspace(0,0.5,500);
alpha = losses_lvl1;
beta = sum(losses_lvl1) - losses_lvl1;
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
legend('Lvl1Naive','NaiveAgent','NaiveAgent','NaiveAgent',...
    'Location','best');

xlabel 'Probability of Loss'
ylabel 'Probability Desnity of Estimate'
grid on

%% A Lvl1Naive, Two Naives, and a SelfPlayAgent walk into a bar...
% And decide to play Liar's Dice

player1.training = false;
playerlist = {player1 lvl1 naive2 naive3};

losses_barscene = [0,0,0,0];
niter = 15000;
h = waitbar(0,'Please wait...');
for iter = 1:niter
    waitbar(iter/niter);
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    loser = env.playGame();
    losses_barscene(ordering(loser)) = losses_barscene(ordering(loser)) + 1;
end
close(h)

h=figure();
set(h,'Units','Points');
set(h,'Position',[650,550,350,300]);
pvals = linspace(0,0.5,500);
alpha = losses_barscene;
beta = sum(losses_barscene) - losses_barscene;
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
legend('SelfPlayAgent','Lvl1Naive','NaiveAgent','NaiveAgent',...
    'Location','best');

xlabel 'Probability of Loss'
ylabel 'Probability Desnity of Estimate'
grid on

%% A Lvl1Naive and three SelfPlayAgents walk into a bar...
% And decide to play Liar's Dice

player1.training = false;
player2.training = false;
player3.training = false;
playerlist = {lvl1 player1 player2 player3};

losses_lvl1_selfplays = [0,0,0,0];
niter = 15000;
h = waitbar(0,'Please wait...');
for iter = 1:niter
    waitbar(iter/niter);
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    loser = env.playGame();
    losses_lvl1_selfplays(ordering(loser)) = losses_lvl1_selfplays(ordering(loser)) + 1;
end
close(h)

%%

h=figure();
set(h,'Units','Points');
set(h,'Position',[650,550,350,300]);
pvals = linspace(0,1,500);
alpha = losses_lvl1_selfplays;
beta = sum(losses_lvl1_selfplays) - losses_lvl1_selfplays;
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
legend('Lvl1Naive','SelfPlayAgent','SelfPlayAgent','SelfPlayAgent',...
    'Location','best');

xlabel 'Probability of Loss'
ylabel 'Probability Desnity of Estimate'
grid on