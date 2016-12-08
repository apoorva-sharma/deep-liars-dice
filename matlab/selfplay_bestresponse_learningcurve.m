%% Load an old dataset with trained SelfPlayAgents

load selfplay_50000trains_dec6_945.mat

%% Init a fresh DeepAgent
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



%% run training and testing to plot a learning curve of sorts
player5.training = true;
player2.training = false;
player3.training = false;
player4.training = false;
nouteriter = 16;
ntrainiter = 3000;

totallosses = zeros(nouteriter,1);
totalwins = zeros(nouteriter,1);


player2.training = false;
player3.training = false;
player4.training = false;

for outeriter = 1:nouteriter
    %% Play against each other, training all nets
    player5.training = true;
    playerlist = {player5 player2 player3 player4};

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
    player5.training = false;

    playerlist = {player5 player2 player3 player4};
    
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
num_train_iters = [0:nouteriter]*ntrainiter;
num_train_iters = [1:nouteriter]*ntrainiter;

loss_rate = totallosses./(totallosses + totalwins);
figure(1)
plot(num_train_iters, loss_rate)
xlabel('Number of Self Play Games Played');
ylabel('Average loss rate against 3 SelfPlayAgents');
title('Training Curve');
grid on;