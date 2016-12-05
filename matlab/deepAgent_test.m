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
obsNet = net;

%% Initialize Pi and Q nets without training
piNet = initPiNet(total_coins, 20);
QNet = initQNet(total_coins, 20);

pObsNet = PersistentNet(obsNet);
pPiNet = PersistentNet(piNet);
pQNet = PersistentNet(QNet);

obs_buffer_size = 100000;
obsXbuf = CircBuffer([obs_buffer_size, 3]);
obsYbuf = CircBuffer([obs_buffer_size, 1]);

pi_buffer_size = 100000;
PiXbuf = ReservoirBuffer(pi_buffer_size,23);

Q_buffer_size = 100000;
QXbuf = CircBuffer([Q_buffer_size, 46]);

%% Initialize agents
player1 = DeepAgent(pObsNet, pPiNet, pQNet, obsXbuf, obsYbuf, PiXbuf, QXbuf);

%%
% one deep agent against 3 naive agents
tic
player1.training = true;
losses = [0,0,0,0];
niter = 50000;
for iter = 1:niter
    playerlist = {player1 player2 player3 player4};
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    loser = env.playGame();
    losses(ordering(loser)) = losses(ordering(loser)) + 1;
end
toc

%% Now, play to WIN
player1.training = false;
losses = [0,0,0,0];
niter = 5000;
for iter = 1:niter
    playerlist = {player1 player2 player3 player4};
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    loser = env.playGame();
    losses(ordering(loser)) = losses(ordering(loser)) + 1;
end

bar(losses./sum(losses));
title('Loss rate of each player');

%% Initialize agents for self play
% All the agents use the same brain
player1 = DeepAgent(pObsNet, pPiNet, pQNet, obsXbuf, obsYbuf, PiXbuf, QXbuf);
player2 = DeepAgent(pObsNet, pPiNet, pQNet, obsXbuf, obsYbuf, PiXbuf, QXbuf);
player3 = DeepAgent(pObsNet, pPiNet, pQNet, obsXbuf, obsYbuf, PiXbuf, QXbuf);
player4 = DeepAgent(pObsNet, pPiNet, pQNet, obsXbuf, obsYbuf, PiXbuf, QXbuf);


%% play to train

player1.training = true;
player2.training = true;
player3.training = true;
player4.training = true;
playerlist = {player1 player2 player3 player4};


niter = 50000;
for iter = 1:niter
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    env.playGame();
end

%% play to WIN against each other
player1.training = false;
player2.training = false;
player3.training = false;
player4.training = false;

playerlist = {player1 player2 player3 player4};
losses = [0,0,0,0];
niter = 5000;
for iter = 1:niter
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    loser = env.playGame();
    losses(ordering(loser)) = losses(ordering(loser)) + 1;
end

bar(losses./sum(losses));
title('Loss rate of each player');

%% play to WIN against each other
player1.training = false;

naive1 = NaiveAgent(0.5);
naive2 = NaiveAgent(0.5);
naive3 = NaiveAgent(0.5);

playerlist = {player1 naive1 naive2 naive3};
losses = [0,0,0,0];
niter = 5000;
for iter = 1:niter
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    loser = env.playGame();
    losses(ordering(loser)) = losses(ordering(loser)) + 1;
end

bar(losses./sum(losses));
title('Loss rate of each player');