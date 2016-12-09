%% Test ConservativeAgent vs NaiveAgents
cons1 = ConservativeAgent();

playerlist = {cons1, naive1 naive2 naive3};

losses_cons = [0,0,0,0];
niter = 15000;
h = waitbar(0,'Please wait...');
for iter = 1:niter
    waitbar(iter/niter);
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    loser = env.playGame();
    losses_cons(ordering(loser)) = losses_cons(ordering(loser)) + 1;
end
close(h)

h=figure();
set(h,'Units','Points');
set(h,'Position',[650,550,350,300]);
pvals = linspace(0,0.5,500);
alpha = losses_cons;
beta = sum(losses_cons) - losses_cons;
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
legend('ConservativeAgent','NaiveAgent','NaiveAgent','NaiveAgent',...
    'Location','best');

xlabel 'Probability of Loss'
ylabel 'Probability Desnity of Estimate'
grid on

%% A ConservativeAgent and three SelfPlayAgents walk into a bar...
% And decide to play Liar's Dice

player1.training = false;
player2.training = false;
player3.training = false;
playerlist = {cons1 player1 player2 player3};

losses_cons_selfplays = [0,0,0,0];
niter = 15000;
h = waitbar(0,'Please wait...');
for iter = 1:niter
    waitbar(iter/niter);
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    loser = env.playGame();
    losses_cons_selfplays(ordering(loser)) = losses_cons_selfplays(ordering(loser)) + 1;
end
close(h)

%%

h=figure();
set(h,'Units','Points');
set(h,'Position',[650,550,350,300]);
pvals = linspace(0,1,500);
alpha = losses_cons_selfplays;
beta = sum(losses_cons_selfplays) - losses_cons_selfplays;
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
legend('ConservativeAgent','SelfPlayAgent','SelfPlayAgent','SelfPlayAgent',...
    'Location','best');

xlabel 'Probability of Loss'
ylabel 'Probability Desnity of Estimate'
grid on

%% A SelfPlayAgent and three ConservativeAgents walk into a bar...
% And decide to play Liar's Dice

player1.training = false;
cons2 = ConservativeAgent();
cons3 = ConservativeAgent();
playerlist =  {player1 cons1 cons2 cons3};

losses_selfplays_cons = [0,0,0,0];
niter = 15000;
h = waitbar(0,'Please wait...');
for iter = 1:niter
    waitbar(iter/niter);
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    loser = env.playGame();
    losses_selfplays_cons(ordering(loser)) = losses_selfplays_cons(ordering(loser)) + 1;
end
close(h)

%%

h=figure();
set(h,'Units','Points');
set(h,'Position',[650,550,350,300]);
pvals = linspace(0,1,500);
alpha = losses_selfplays_cons;
beta = sum(losses_selfplays_cons) - losses_selfplays_cons;
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
legend('SelfPlayAgent','ConservativeAgent','ConservativeAgent','ConservativeAgent',...
    'Location','best');

xlabel 'Probability of Loss'
ylabel 'Probability Desnity of Estimate'
grid on