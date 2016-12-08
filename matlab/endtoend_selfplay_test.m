% game parameters
coins_per_player = 5;
total_coins = coins_per_player*4;
oneHotEye = eye(total_coins+1-coins_per_player);

%% Initialize Nets
piNet = initPiNet(total_coins, [20,20]);
QNet = initQNet(total_coins, [20,20]);

pPiNet = PersistentNet(piNet);
pQNet = PersistentNet(QNet);

%% Initialize Memories

pi_buffer_size = 10000;
PiXbuf = ReservoirBuffer(pi_buffer_size,5);

Q_buffer_size = 2000;
QXbuf = CircBuffer([Q_buffer_size, 10]);

%% Initialize Agents
% All the agents use the same brain
player1 = EndToEndDeepAgent(pPiNet, pQNet, PiXbuf, QXbuf);
player2 = EndToEndDeepAgent(pPiNet, pQNet, PiXbuf, QXbuf);
player3 = EndToEndDeepAgent(pPiNet, pQNet, PiXbuf, QXbuf);
player4 = EndToEndDeepAgent(pPiNet, pQNet, PiXbuf, QXbuf);

%% test untrained deep agents against NaiveAgents
player1.training = false;
naive1 = NaiveAgent(0.5);
naive2 = NaiveAgent(0.5);
naive3 = NaiveAgent(0.5);

playerlist = {player1 naive1 naive2 naive3};
losses = [0,0,0,0];

niter = 10000;
h = waitbar(0,'Please wait...');
for iter = 1:niter
    waitbar(iter/niter);
    ordering = randperm(4);
    env = Environment(playerlist(ordering), coins_per_player, true);
    loser = env.playGame();
    losses(ordering(loser)) = losses(ordering(loser)) + 1;
end
close(h)

untrainedlosses = losses(1);
untrainedwins = sum(losses(2:end));

% The above section causes bugs in the remaining sections. Run without this
% section after running this section once.

%% run training and testing to plot a learning curve of sorts
player1.training = true;
nouteriter = 16;
ntrainiter = 3000;

totallosses = zeros(nouteriter,1);
totalwins = zeros(nouteriter,1);

for outeriter = 1:nouteriter
    %% Play against each other, training all nets
    player1.training = true;
    player2.training = true;
    player3.training = true;
    player4.training = true;
    playerlist = {player1 player2 player3 player4};

    tic

    h = waitbar(0,strcat('Iteration ',num2str(outeriter)));
    for iter = 1:ntrainiter
        waitbar(iter/ntrainiter);
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
    niter = 10000;
    h = waitbar(0,'Please wait...');
    for iter = 1:niter
        waitbar(iter/niter);
        ordering = randperm(4);
        env = Environment(playerlist(ordering), coins_per_player, true);
        loser = env.playGame();
        losses(ordering(loser)) = losses(ordering(loser)) + 1;
    end
    close(h)
    
    totallosses(outeriter) = losses(1);
    totalwins(outeriter) = sum(losses(2:end));
end

totallosses = [untrainedlosses; totallosses];
totalwins = [untrainedwins; totalwins];

%% Plot Learning Curve
num_train_iters = [1:nouteriter]*ntrainiter;

loss_rate = totallosses./(totallosses + totalwins);
figure(1)
plot(num_train_iters, loss_rate)
xlabel('Number of Self Play Games Played');
ylabel('Average loss rate against 3 Naive Agents');
title('Training Curve');
grid on;


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


