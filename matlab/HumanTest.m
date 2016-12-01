%% Basic Test of Gameplay Mechanics
% Create an environment with 3 naive agents
players = cell(1,2);
player1 = NaiveAgent(0.5);
player2 = HumanAgent('Mark');
% player3 = NaiveAgent(0.5);
% players = [Player()]
coins_per_player = 5;
players{1} = player1;
players{2} = player2;
% losses = [0,0,0];

% niter = 1000;
% for iter = 1:niter
env = Environment(players, 5, false);
loser = env.playGame();
% losses(loser) = losses(loser) + 1;
% end

% bar(losses);
% title('Number of losses of each player');
