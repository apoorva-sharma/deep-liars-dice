%% Basic Test of Gameplay Mechanics
% Create an environment with 3 naive agents
player1 = NaiveAgent(0.5);
player2 = NaiveAgent(0.5);
player3 = NaiveAgent(0.5);
player4 = NaiveAgent(0.5);

coins_per_player = 5;

losses = [0,0,0,0];
pos_count = zeros(4);
ordering = [1 2 3 4];
niter = 1000;
for iter = 1:niter
    playerlist = {player1 player2 player3 player4};
    ordering = circshift(ordering, 1, 2);
    for i = 1:4
        pos_count(ordering(i), i) = pos_count(ordering(i),i) + 1;
    end
    env = Environment(playerlist(ordering), 5, true);
    loser = env.playGame();
    losses(ordering(loser)) = losses(ordering(loser)) + 1;
end

bar(losses./sum(losses));
losses
title('Lose rate of each player');
