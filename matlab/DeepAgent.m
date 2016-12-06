classdef DeepAgent < Player
    % DEEPAGENT Plays a deep strategy when called
    % 
    
    properties
        hand = -1;
        total_coins = -1;
        num_players = -1;
        
        eta = 0.1; % anticipatory parameter
        epsilon = 0.2; % epsilon for epsilon-greedy Q
        
        useQ = -1; % whether we choose eps-greedy Q instead of Pi
        
        obsNet = -1;
        piNet = -1;
        QNet = -1;
        
        training = true;
        gamesSinceLastTrain = -1;
        gamesBetweenTraining = 500;
        
        
        o_log = []; % log of all observations in one game
        b_log = []; % log of all beliefs in one game
        l_log = []; % log of all last_bets '' 
        a_log = []; % log of all actions '' 
        r_log = []; % log of all rewards '' 
        bp_log = []; % log of all next beliefs '' 
        lp_log = []; % log of all next last_bets '' 
        unknown_coins_log = []; % log of all unknown_coin amounts 
                                % (total_heads - my hand)
        
        % REPLAY MEMORIES
        % ObsNet
        obsX = []; % [o_log] concatentated for all games
        obsY = []; % [unknown_coins_log]
        
        % PiNet
        PiX = []; % [b_log l_log a_log] TODO: replace with reservoir
        
        % QNet
        QX = []; % [b_log l_log a_log r_log bp_log lp_log] TODO: replace with circ buffer
        
        % PERFORMANCE BUFFER
        performance = []; % loss probability
        sessionPerformance = []; % performance of this session
        
    end
    
    methods
        function obj = DeepAgent(obsNet, piNet, QNet, obsXbuf, obsYbuf, PiXbuf, QXbuf)
            % Constructor for a DeepAgent
            % Inputs: obsNet: neural network mapping last_bets to
            %                 distribution on unknown_heads
            %         piNet: neural network mapping belief over total_heads
            %                and current_bet and an action to a probability
            %         QNet: a neural network mapping belief over
            %               total_heads, current_bet, and action to the 
            %               Q value.
            %         training: bool for whether the nets should be trained
            
            obj.obsNet = obsNet;
            obj.piNet = piNet;
            obj.QNet = QNet;
            
            obj.gamesSinceLastTrain = 0;
            
            % Initialize observer buffers
            obj.obsX = obsXbuf;
            obj.obsY = obsYbuf;
            
            % Initialize pi buffers
            obj.PiX = PiXbuf;
            
            % Initialize Q buffers
            obj.QX = QXbuf;
            
        end
        function initGame(obj,hand, total_coins, num_players)
            % Inputs: hand = num heads in this agent's hand
            %         total_coins = total coins in game
            %         num_players = number of players in the game
            
            obj.hand = hand;
            obj.total_coins = total_coins;
            obj.num_players = num_players;
            
            % determine whether we use esp-greedy Q or pi for this game
            obj.useQ = (rand <= obj.eta) && obj.training;
            
            % reset the current game logs
            obj.o_log = []; % log of all observations in one game
            obj.b_log = []; % log of all beliefs in one game
            obj.l_log = []; % log of all last_bets '' 
            obj.a_log = []; % log of all actions '' 
            obj.r_log = []; % log of all rewards '' 
            obj.bp_log = []; % log of all next beliefs '' 
            obj.lp_log = []; % log of all next last_bets '' 
            obj.unknown_coins_log = []; % log of all unknown_coin amounts 
                                    % (total_heads - my hand)
        end
        
        function next_bet = playTurn(obj,last_bets)
            % Inputs: last_bets = array of bets played by last n-1 players
            %           ordering: if obj is player 3 in a 5 player game
            %            then last_bets = bets of [2;1;5;4]
            % Output: next_bet played by obj
            
            % Based on Heinrich and Silver, 28 Jun 2016
            
            % define given variables
            o = last_bets; % observations are last_bets made by opponents
            l = last_bets(1); % l is the bet immediately before this one.
            l(isnan(l)) = 0;
            % get belief from observer net
            o(isnan(o)) = -10;
            if isconfigured(obj.obsNet.net)
                b = obj.obsNet.eval(o);
            else
                % use a uniform belief
                b = ones(obj.total_coins - obj.total_coins/obj.num_players + 1,1);
                b = b/sum(b);
            end
            b = [zeros(obj.hand,1); b; zeros(obj.total_coins/obj.num_players - obj.hand,1)];
            
            % Sample action at from policy
            if obj.useQ
                actions = [-1 l+1:obj.total_coins];
                if (rand > obj.epsilon) && isconfigured(obj.QNet.net)
                    qx = [repmat([b;l],[1 length(actions)]); actions];
                    qvals = obj.QNet.eval(qx);
                    [~,besta_i] = max(qvals);
                    a = actions(besta_i);
                else
                    a = randsample(actions,1);
                end
            else
                actions = [-1:obj.total_coins]';
                probs = ones(size(actions));
                if isconfigured(obj.piNet.net)
                    probs = obj.piNet.eval([b;l]) + eps*ones(size(actions));
                end
                % prune away illegal actions
                validactions = actions([1,l+3:obj.total_coins]);
                validprobs = probs([1,l+3:obj.total_coins]);
                
                a = randsample(validactions,1,true,validprobs);
            end
            
            % Execute Action
            next_bet = a;
            
            % Log the turn
            %  first fill in last row
            if ~isempty(obj.bp_log)
                obj.r_log(end,:) = 0;
                obj.bp_log(end,:) = b';
                obj.lp_log(end,:) = l;
            end
            % now add a new row
            obj.o_log = [obj.o_log; o'];
            obj.b_log = [obj.b_log; b'];
            obj.l_log = [obj.l_log; l];
            obj.a_log = [obj.a_log; a];
            obj.r_log = [obj.r_log; NaN];
            obj.bp_log = [obj.bp_log; NaN*ones(size(b'))];
            obj.lp_log = [obj.lp_log; NaN];
            obj.unknown_coins_log = [obj.unknown_coins_log; NaN];
        end
        
        function [] = debrief(obj,reward,total_heads,hand)
            if isempty(obj.o_log)
                return % no need to do anything if we didn't really play
            end
            % Fill in missing items in logs
            obj.r_log(end,:) = reward;
            obj.unknown_coins_log(:) = total_heads - hand;
            obj.sessionPerformance = [obj.sessionPerformance, reward];
            
            % Add logs to replay memories
            % ObsNet
            obj.obsX.push(obj.o_log);
            obj.obsY.push(obj.unknown_coins_log);

            % PiNet
            if obj.useQ
                obj.PiX.push([obj.b_log obj.l_log obj.a_log]);
            end

            % QNet
            obj.QX.push([obj.b_log obj.l_log obj.a_log obj.r_log...
                                obj.bp_log obj.lp_log]);
                            
            % decide whether to train
            obj.gamesSinceLastTrain = obj.gamesSinceLastTrain + 1;
            if obj.gamesSinceLastTrain >= obj.gamesBetweenTraining
                if(obj.training)
                    obj.trainObserverNetwork();
                    obj.trainQNetwork();
                    obj.trainPiNetwork();
                end
                obj.gamesSinceLastTrain = 0;
            end
        end
        
        function trainObserverNetwork(obj)
            % Trains observer net using data in observer buffers
            
            % Query training data from buffers
            X = obj.obsX.getBuffer();
            Y = obj.obsY.getBuffer();
            % Replace NaNs with -10
            X(isnan(X)) = -10;
            % Make Y a 1-hot encoding
            I = eye(obj.total_coins + 1 - obj.total_coins/obj.num_players);
            Y = I(Y+1,:);
            % Train the net
            X = X';
            Y = Y';
            obj.obsNet.train(X,Y);            
        end
        
        function trainQNetwork(obj)
            % Trains Q net using data in observer buffers
            % Adds performance measure to obj.performance
            
            % Query training data from buffers
            buffer = obj.QX.getBuffer();
            X = buffer(:,1:obj.total_coins + 3);
            % Add performance to obj.performance
            obj.performance = [obj.performance,...
                sum(obj.sessionPerformance)/length(obj.sessionPerformance)];
            obj.sessionPerformance = [];
            
            % Generate targets using Bellman Equation:
            
            % pick out [bp,lp] which aren't NaN
            non_nan_bps = ~isnan(buffer(:,obj.total_coins+5));
            inps_non_nan = buffer(non_nan_bps,...
                obj.total_coins+5:2*obj.total_coins+6);
            % Generate mx of [bp,lp,a] for all possible a
            %  as inputs to the NN
            num_samps = size(inps_non_nan,1);
            actions = [-1:obj.total_coins];
            qx = repmat(inps_non_nan',[1,length(actions)]);
            acts = zeros(1,size(qx,2));
            for i = 1:length(actions)
                acts(num_samps*(i-1) + 1 : num_samps*i) = actions(i);
            end
            qx = [qx;acts];
            % Run through NN
            if(isconfigured(obj.QNet.net))
                Qvals = obj.QNet.eval(qx);
            else
                Qvals = zeros(1,size(qx,2));
            end
            % Reshape and pick out max_a Q([bp,lp,a])
            Qvals = reshape(Qvals,length(actions),[])';
            max_Qvals = max(Qvals,[],2);
            % Fill results into Y in non-nan spots
            Y = buffer(:,obj.total_coins+4);
            Y(non_nan_bps) = Y(non_nan_bps) + max_Qvals;
            
            % Train the net
            X = X';
            Y = Y';
            obj.QNet.train(X,Y);
        end
        
        function trainPiNetwork(obj)
            % Trains Pi net using data in observer buffers
            
            % Query training data from buffers
            buffer = obj.PiX.getBuffer();
            X = buffer(:,1:obj.total_coins+2);
            Y = buffer(:,obj.total_coins+3);
            Y = Y + 2; % [-1~20] encoded as [1~22] 
            % Make Y a 1-hot encoding
            num_actions = obj.total_coins+2;
            I = eye(num_actions);
            Y = I(Y,:);
            % Train the net
            X = X';
            Y = Y';
            obj.piNet.train(X,Y);
        end
        
        function [ind] = bet_action2ind(obj,b,a,h)
            persistent bet2sub
            persistent a2sub
            bet2sub = @(bet) (bet == -10) + (bet ~= -10).*(bet+2);
            a2sub = @(a) a + 2;
            ind = sub2ind([obj.total_coins+1, obj.total_coins+1, obj.total_coins+1, obj.coins_per_player obj.total_coins+1],bet2sub(b(1)),bet2sub(b(2)),bet2sub(b(3)),h+1,a2sub(a));
        end
    end
    
end

