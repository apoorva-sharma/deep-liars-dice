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
oneHotEye = eye(total_coins-coins_per_player+1);

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

net = initObserverNet();
[net,tr] = train(net,training_examples, training_labels);

%%
full_example_i = find(sum((training_examples>=0),1)==3, 1, 'first');
clf
subplot(4,1,1)
bar([0:15],net(training_examples(:,full_example_i-3))/...
    sum(net(training_examples(:,full_example_i-3))))
hold on
stem([0:15],0.2*training_labels(:,full_example_i-3));
subplot(4,1,2)
bar([0:15],net(training_examples(:,full_example_i-2))/...
    sum(net(training_examples(:,full_example_i-2))))
hold on
stem([0:15],0.2*training_labels(:,full_example_i-2));
subplot(4,1,3)
bar([0:15],net(training_examples(:,full_example_i-1))/...
    sum(net(training_examples(:,full_example_i-1))))
hold on
stem([0:15],0.2*training_labels(:,full_example_i-1));
subplot(4,1,4)
bar([0:15],net(training_examples(:,full_example_i))/...
    sum(net(training_examples(:,full_example_i))))
hold on
stem([0:15],0.2*training_labels(:,full_example_i));

toc

