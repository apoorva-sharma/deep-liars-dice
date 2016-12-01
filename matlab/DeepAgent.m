classdef DeepAgent < Player
    % DEEPAGENT Plays a deep strategy when called
    % 
    
    properties
        hand = -1;
        total_coins = -1;
        num_players = -1;
        
        eta = 0.4; % anticipatory parameter
        epsilon = 0.2; % epsilon for epsilon-greedy Q
        
        useQ = -1; % whether we choose eps-greedy Q instead of Pi
        
        obsNet = -1;
        piNet = -1;
        QNet = -1;
        
        gamesSinceLastTrain = -1;
        gamesBetweenTraining = 100;
        
        
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
        
    end
    
    methods
        function obj = DeepAgent(obsNet, piNet, QNet)
            % Constructor for a DeepAgent
            % Inputs: obsNet: neural network mapping last_bets to
            %                 distribution on unknown_heads
            %         piNet: neural network mapping belief over total_heads
            %                and current_bet and an action to a probability
            %         QNet: a neural network mapping belief over
            %               total_heads, current_bet, and action to the 
            %               Q value.
            obj.obsNet = obsNet;
            obj.piNet = piNet;
            obj.QNet = QNet;
            
            obj.gamesSinceLastTrain = 0;

            
            % Initialize observer buffers
            obs_buffer_size = 100000;
            obj.obsX = CircBuffer([obs_buffer_size, 3]);
            obj.obsY = CircBuffer([obs_buffer_size, 1]);
            
            % Initialize pi buffers
            pi_buffer_size = 100000;
            obj.PiX = ReservoirBuffer(pi_buffer_size,23);
            
            % Initialize Q buffers
            Q_buffer_size = 100000;
            obj.QX = CircBuffer([Q_buffer_size, 46]);
            
        end
        function initGame(obj,hand, total_coins, num_players)
            % Inputs: hand = num heads in this agent's hand
            %         total_coins = total coins in game
            %         num_players = number of players in the game
            
            obj.hand = hand;
            obj.total_coins = total_coins;
            obj.num_players = num_players;
            
            % determine whether we use esp-greedy Q or pi for this game
            obj.useQ = rand <= obj.eta;
            
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
            b = obj.obsNet(o);
            b = [zeros(obj.hand,1); b; zeros(obj.total_coins/obj.num_players - obj.hand,1)];
            
            % Sample action at from policy
            if obj.useQ
                actions = [-1 l+1:obj.total_coins];
                qx = [repmat([b;l],[1 length(actions)]); actions];
                qvals = obj.QNet(qx);
                [~,besta_i] = max(qvals);
                if rand > eps
                    a = actions(besta_i);
                else
                    a = randsample(actions,1);
                end
            else
                actions = [-1:obj.total_coins]';
                probs = obj.piNet([b;l]) + eps*ones(size(actions));
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
            % Fill in missing items in logs
            obj.r_log(end,:) = reward;
            obj.unknown_coins_log(:) = total_heads - hand;
            
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
                obj.trainObserverNetwork();
                obj.trainPiNetwork();
                obj.trainQNetwork();
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
            [net,tr] = train(obj.obsNet,X,Y);
            obj.obsNet = net;
            
        end
        
        function trainQNetwork(obj)
            % Trains Q net using data in observer buffers
            
            % Query training data from buffers
            buffer = obj.QX.getBuffer();
            X = buffer(:,1:obj.total_coins + 3);
            % Generate targets using Bellman Equation
            Y = zeros(size(buffer,1),1);
            for i = 1:size(buffer,1)
%                 b = buffer(i,1:obj.total_coins+1);
%                 l = buffer(i,obj.total_coins+2);
%                 a = buffer(i,obj.total_coins+3);
                r = buffer(i,obj.total_coins+4);
                bp = buffer(i,obj.total_coins+5:2*obj.total_coins+5);
                lp = buffer(i,2*obj.total_coins+6);
                if(isnan(bp)) % terminal state
                    Y(i) = r;
                else
                    % get Q(bp,lp,all a)
                    actions = [-1:obj.total_coins];
                    qx = [repmat([bp,lp]',[1 length(actions)]); actions];
                    Qvals = obj.QNet(qx);
%                     num_actions = obj.total_coins + 2;
%                     net_inputs = ones(num_actions,obj.total_coins + 3);
%                     net_inputs(:,1:21) = repmat(bp;
%                     net_inputs(:,22) = lp;
%                     net_inputs(:,23) = (1:num_actions)';
%                     Qvals = obj.QNet(net_inputs');
                    % Update Q(b,l,a) = r + max_ap Q_old(bp,lp,ap)
                    Y(i) = r + max(Qvals);
                end
            end
            
            % Train the net
            X = X';
            Y = Y';
            [net,tr] = train(obj.QNet,X,Y);
            obj.QNet = net;
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
            [net,tr] = train(obj.piNet,X,Y);
            obj.piNet = net;
            
        end
        
    end
    
end

