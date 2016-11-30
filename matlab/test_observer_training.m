%% Test of Observer Training
% Create an environment with 3 naive agents
clear
close all
clc


player1 = NaiveAgent(0.5);
player2 = NaiveAgent(0.5);
player3 = NaiveAgent(0.5);
player4 = NaiveAgent(0.5);

coins_per_player = 5;
total_coins = coins_per_player*4;

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
    total_heads = env.lc_game.total_heads;
    one_hot_total_heads = zeros(size(X,1),total_coins+1);
    one_hot_total_heads(:, total_heads+1) = 1;
    training_labels = [training_labels; one_hot_total_heads]; 
end

training_examples = training_examples';
training_labels = training_labels';

%%

net = initObserverNet();
[net,tr] = train(net,training_examples(4,:), training_labels);

clf
bar([0:20],net(training_examples(4,5437))/...
    sum(net(training_examples(4,5437))))
hold on; 
stem([0:20],training_labels(:,5437))

toc

