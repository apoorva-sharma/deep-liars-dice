% game parameters
coins_per_player = 5;
total_coins = coins_per_player*4;
oneHotEye = eye(total_coins+1-coins_per_player);

%% Initialize Nets
obsNet = initObserverNet();
piNet = initPiNet(total_coins, 20);
QNet = initQNet(total_coins, 20);

pObsNet = PersistentNet(obsNet);
pPiNet = PersistentNet(piNet);
pQNet = PersistentNet(QNet);

%% Initialize Memories
obs_buffer_size = 5000;
obsXbuf = ReservoirBuffer(obs_buffer_size, 3);
obsYbuf = ReservoirBuffer(obs_buffer_size, 1);

pi_buffer_size = 10000;
PiXbuf = ReservoirBuffer(pi_buffer_size,23);

Q_buffer_size = 2000;
QXbuf = CircBuffer([Q_buffer_size, 46]);

%% Initialize Agents
% All the agents use the same brain
player1 = DeepAgent(pObsNet, pPiNet, pQNet, obsXbuf, obsYbuf, PiXbuf, QXbuf);
player2 = DeepAgent(pObsNet, pPiNet, pQNet, obsXbuf, obsYbuf, PiXbuf, QXbuf);
player3 = DeepAgent(pObsNet, pPiNet, pQNet, obsXbuf, obsYbuf, PiXbuf, QXbuf);
player4 = DeepAgent(pObsNet, pPiNet, pQNet, obsXbuf, obsYbuf, PiXbuf, QXbuf);

%% Play against each other, training all nets
player1.training = true;
player2.training = true;
player3.training = true;
player4.training = true;
playerlist = {player1 player2 player3 player4};

tic

niter = 50000;
h = waitbar(0,'Please wait...');
for iter = 1:niter
    waitbar(iter/niter);
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    env.playGame();
end
close(h)
toc

%% Play to WIN against Naive Agents
player1.training = false;

naive1 = NaiveAgent(0.5);
naive2 = NaiveAgent(0.5);
naive3 = NaiveAgent(0.5);

playerlist = {player1 naive1 naive2 naive3};
losses = [0,0,0,0];
niter = 15000;
h = waitbar(0,'Please wait...');
for iter = 1:niter
    waitbar(iter/niter);
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    loser = env.playGame();
    losses(ordering(loser)) = losses(ordering(loser)) + 1;
end
close(h)

%% Plot DeepAgent against NaiveAgents
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
legend('SelfPlayAgent','Naive1','Naive2','Naive3');
xlabel 'Probability of Loss'
ylabel 'Probability Desnity of Estimate'
grid on

%% Train a fresh DeepAgent against 3 trained DeepAgents to find performance

% init nets
obsNet5 = initObserverNet();
piNet5 = initPiNet(total_coins, 20);
QNet5 = initQNet(total_coins, 20);

pObsNet5 = PersistentNet(obsNet5);
pPiNet5 = PersistentNet(piNet5);
pQNet5 = PersistentNet(QNet5);

% init buffers
obs_buffer_size = 5000;
obsXbuf5 = ReservoirBuffer(obs_buffer_size, 3);
obsYbuf5 = ReservoirBuffer(obs_buffer_size, 1);

pi_buffer_size = 10000;
PiXbuf5 = ReservoirBuffer(pi_buffer_size,23);

Q_buffer_size = 2000;
QXbuf5 = CircBuffer([Q_buffer_size, 46]);

% init new deep agent
player5 = DeepAgent(pObsNet5, pPiNet5, pQNet5, obsXbuf5, obsYbuf5, PiXbuf5, QXbuf5);

%% train new deep agent
player5.training = true;
player1.training = false;
player2.training = false;
player3.training = false;

playerlist = {player1 player2 player3 player5};
losses = [0,0,0,0];
niter = 20000;
h = waitbar(0,'Please wait...');
for iter = 1:niter
    waitbar(iter/niter);
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    loser = env.playGame();
    losses(ordering(loser)) = losses(ordering(loser)) + 1;
end
close(h)

%% Test player5 against selfplay deepagents

player5.training = false;
player1.training = false;
player2.training = false;
player3.training = false;

playerlist = {player5, player1 player2 player3};

losses_newdeep = [0,0,0,0];
niter = 15000;
h = waitbar(0,'Please wait...');
for iter = 1:niter
    waitbar(iter/niter);
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    loser = env.playGame();
    losses_newdeep(ordering(loser)) = losses_newdeep(ordering(loser)) + 1;
end
close(h)

%% Plot player5 against selfplay deepagents

h=figure();
set(h,'Units','Points');
set(h,'Position',[650,550,350,300]);
pvals = linspace(0,0.5,500);
alpha = losses_newdeep;
beta = sum(losses_newdeep) - losses_newdeep;
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
legend('SelfPlayBestResponse','SelfPlayAgent','SelfPlayAgent','SelfPlayAgent',...
    'Location','best');
xlabel 'Probability of Loss'
ylabel 'Probability Desnity of Estimate'
grid on

%% Test player5 against NaiveAgents

player5.training = false;

playerlist = {player5, naive1 naive2 naive3};

losses_newdeep_naive = [0,0,0,0];
niter = 15000;
h = waitbar(0,'Please wait...');
for iter = 1:niter
    waitbar(iter/niter);
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    loser = env.playGame();
    losses_newdeep_naive(ordering(loser)) = losses_newdeep_naive(ordering(loser)) + 1;
end
close(h)

%% Plot player5 against NaiveAgents

h=figure();
set(h,'Units','Points');
set(h,'Position',[650,550,350,300]);
pvals = linspace(0,0.5,500);
alpha = losses_newdeep_naive;
beta = sum(losses_newdeep_naive) - losses_newdeep_naive;
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
legend('SelfPlayBestResponse','NaiveAgent','NaiveAgent','NaiveAgent',...
    'Location','best');

xlabel 'Probability of Loss'
ylabel 'Probability Desnity of Estimate'
grid on