%% First, train a basic observer model from watching naive agents play

player1 = NaiveAgent(0.5);
player2 = NaiveAgent(0.5);
player3 = NaiveAgent(0.5);
player4 = NaiveAgent(0.5);

coins_per_player = 5;
total_coins = coins_per_player*4;
oneHotEye = eye(total_coins+1-coins_per_player);

training_examples = [];
training_labels = [];

tic
niter = 10000;
for iter = 1:niter
    env = Environment({player1 player2 player3 player4}, 5, true);
    env.playGame();
    X = env.X;
    X(isnan(X)) = -10;
    training_examples = [training_examples; X];
    Y = env.Y;
    oneHotY = oneHotEye(Y+1,:);
    training_labels = [training_labels; oneHotY]; 
end

training_examples = training_examples';
training_labels = training_labels';
%%
obsNet = initObserverNet();
[obsNet,tr] = train(obsNet,training_examples, training_labels);

%% Load previously trained ObsNet
load MKObsTest.mat

%% Initialize Pi and Q nets without training
piNet = initPiNet(total_coins, 20);
QNet = initQNet(total_coins, 20);

%% Initialize agents and play
% one deep agent against 3 naive agents
player1 = DeepAgent(obsNet, piNet, QNet);
tic
losses = [0,0,0,0];
niter = 10000;
for iter = 1:niter
    playerlist = {player1 player2 player3 player4};
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    loser = env.playGame();
    losses(ordering(loser)) = losses(ordering(loser)) + 1;
end

bar(losses./sum(losses));
title('Lose rate of each player');

