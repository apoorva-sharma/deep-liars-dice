%% Basic Test of Gameplay Mechanics
% Create an environment with 3 naive agents
player1 = NaiveAgent(0.5);
player2 = NaiveAgent(0.5);
player3 = NaiveAgent(0.5);

coins_per_player = 5;

losses = [0,0,0];

niter = 100;
for iter = 1:ntier
    env = Environment([player1 player2, player3], 5, true);
    loser = env.playGame();
    losses(loser) = losses(loser) + 1;
end

bar(losses);
title('Number of losses of each player');
