classdef EndToEndDeepAgent < Player
    % DEEPAGENT Plays a deep strategy when called
    % 
    
    properties
        hand = -1;
        total_coins = -1;
        num_players = -1;
        coins_per_player = -1;
        
        eta = 0.1; % anticipatory parameter
        epsilon = 0.2; % epsilon for epsilon-greedy Q
        
        useQ = -1; % whether we choose eps-greedy Q instead of Pi
        
        piNet = -1;
        QNet = -1;
        
        training = true;
        gamesSinceLastTrain = -1;
        gamesBetweenTraining = 500;
        
        
        o_log = []; % log of all observations in one game
        op_log = []; % log of next '' 
        a_log = []; % log of all actions '' 
        r_log = []; % log of all rewards '' 
        
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
        
        % QVALUE PRECALCULATION
        % We will pass in all possible last_bets to ObsNet to pre-calculate
        %  the belief states, and pass those in with all possible last_bet
        %  to QNet pre-calculate Qvals as a lookup. This is for speedup
        possible_lastbets = [];
        all_os = [];
    end
    
    methods
        function obj = EndToEndDeepAgent(piNet, QNet,PiXbuf, QXbuf)
            % Constructor for a DeepAgent
            % Inputs: obsNet: neural network mapping last_bets to
            %                 distribution on unknown_heads
            %         piNet: neural network mapping belief over total_heads
            %                and current_bet and an action to a probability
            %         QNet: a neural network mapping belief over
            %               total_heads, current_bet, and action to the 
            %               Q value.
            %         training: bool for whether the nets should be trained
            
            obj.piNet = piNet;
            obj.QNet = QNet;
            
            obj.gamesSinceLastTrain = 0;
            
            % Initialize pi buffers
            obj.PiX = PiXbuf;
            
            % Initialize Q buffers
            obj.QX = QXbuf;
            
            % Initialize all_lastbets
            obj.possible_lastbets = [-10,0:20];
            all_lastbets = zeros(length(obj.possible_lastbets)^3,3);
            itr = 1;
            for i = 1:length(obj.possible_lastbets)
                for j = 1:length(obj.possible_lastbets)
                    for k = 1:length(obj.possible_lastbets)
                        all_lastbets(itr,:) = ...
                            [obj.possible_lastbets(i),...
                            obj.possible_lastbets(j),...
                            obj.possible_lastbets(k)];
                        itr = itr+1;
                    end
                end
            end
            [m,n] = size(all_lastbets);
            obj.all_os = zeros(6*m,4);
            for i = 1:6
                obj.all_os((i-1)*m+1:i*m,1:3) = all_lastbets;
                obj.all_os((i-1)*m+1:i*m,4) = i-1;
            end
        end
            
        
        function initGame(obj,hand, total_coins, num_players)
            % Inputs: hand = num heads in this agent's hand
            %         total_coins = total coins in game
            %         num_players = number of players in the game
            
            obj.hand = hand;
            obj.total_coins = total_coins;
            obj.num_players = num_players;
            obj.coins_per_player = total_coins/num_players;
            
            % determine whether we use esp-greedy Q or pi for this game
            obj.useQ = (rand <= obj.eta) && obj.training;
            
            % reset the current game logs
            obj.o_log = []; % log of all observations in one game
            obj.op_log = []; % log of all last_bets '' 
            obj.a_log = []; % log of all actions '' 
            obj.r_log = []; % log of all rewards ''
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
            
            o(isnan(o)) = -10;
            
            
            % Sample action at from policy
            if obj.useQ
                actions = [-1 l+1:obj.total_coins];
                if (rand > obj.epsilon) && isconfigured(obj.QNet.net)
                    qvals = obj.QNet.precomputedResponses(obj.bet_action2ind(...
                        repmat(o,[1 length(actions)]),...
                        actions,obj.hand*ones(size(actions))));
                    [~,besta_i] = max(qvals);
                    a = actions(besta_i);
                else
                    a = randsample(actions,1);
                end
            else
                actions = [-1:obj.total_coins]';
                probs = ones(size(actions));
                if isconfigured(obj.piNet.net)
                    ind = obj.bet_action2ind(o,-1,obj.hand);
                    probs = obj.piNet.precomputedResponses(ind,:)' + eps*ones(size(actions));
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
            if ~isempty(obj.op_log)
                obj.r_log(end,:) = 0;
                obj.op_log(end,:) = [o',obj.hand];
            end
            % now add a new row
            obj.o_log = [obj.o_log; [o',obj.hand]];
            obj.a_log = [obj.a_log; a];
            obj.r_log = [obj.r_log; NaN];
            obj.op_log = [obj.op_log; NaN*ones(size([o',obj.hand]))];
        end
        
        function [] = debrief(obj,reward,total_heads,hand)
            if isempty(obj.o_log)
                return % no need to do anything if we didn't really play
            end
            % Fill in missing items in logs
            obj.r_log(end,:) = reward;
%             obj.sessionPerformance = [obj.sessionPerformance, reward];
            
            % Add logs to replay memories

            % PiNet
            if obj.useQ
                obj.PiX.push([obj.o_log obj.a_log]);
            end

            % QNet
            if(obj.training)
                obj.QX.push([obj.o_log obj.a_log obj.r_log...
                                obj.op_log]);
            
                            
                % train the nets if necessary
                obj.piNet.time_since_last_train = obj.piNet.time_since_last_train + 1;
                obj.QNet.time_since_last_train = obj.QNet.time_since_last_train + 1;
            end
            
            if (obj.piNet.time_since_last_train >= obj.piNet.iterations_between_training) 
                if(obj.training)
                    obj.trainQNetwork();
                    obj.trainPiNetwork();

                    % Precompute every output of the newly trained system
                    % Precompute pis
                    obj.piNet.precomputedResponses = (obj.piNet.eval(obj.all_os'))';
                    % append on all possible actions
                    actions = [-1,0:obj.total_coins];
                    [m,n] = size(obj.all_os);
                    all_q_inps = zeros(m*length(actions),n+1);
                    for i = 1:length(actions)
                        all_q_inps((i-1)*m+1:i*m,:) = [obj.all_os,...
                            ones(m,1)*actions(i)];
                    end
                    obj.QNet.precomputedResponses = obj.QNet.eval(all_q_inps');
                end
            end
        end
        
        function trainQNetwork(obj)
            % Trains Q net using data in observer buffers
            % Adds performance measure to obj.performance
            
            % Query training data from buffers
            buffer = obj.QX.getBuffer();
            X = buffer(:,1:5); % just observations
            
            % Generate targets using Bellman Equation:
            
            % pick out op which aren't NaN
            non_nan_bps = ~isnan(buffer(:,7));
            inps_non_nan = buffer(non_nan_bps,7:end);
            % Generate mx of [op,ap] for all possible ap
            %  as inputs to the NN
            num_samps = size(inps_non_nan,1);
            actions = [-1:obj.total_coins];
            qx = repmat(inps_non_nan',[1,length(actions)]);
            acts = zeros(1,size(qx,2));
            for i = 1:length(actions)
                acts(num_samps*(i-1) + 1 : num_samps*i) = actions(i);
            end
            qx = [qx;acts];
            illegal_bets = and((qx(1,:)>= acts), (acts ~= -1));
            % Run through NN
            if(isconfigured(obj.QNet.net))
                inds = obj.bet_action2ind(qx(1:3,:),qx(5,:),qx(4,:));
                Qvals = obj.QNet.precomputedResponses(inds);
            else
                Qvals = zeros(1,size(qx,2));
            end
            % Reshape and pick out max_a Q([bp,lp,a])
            Qvals(illegal_bets) = -Inf;
            Qvals = reshape(Qvals,[],length(actions));
            max_Qvals = max(Qvals,[],2);
          
            % Fill results into Y in non-nan spots
            Y = buffer(:,6); % Rewards
            if(~isempty(inps_non_nan))
                Y(non_nan_bps) = Y(non_nan_bps) + max_Qvals;
            end
            
            % Train the net
            X = X';
            Y = Y';
            obj.QNet.train(X,Y);
        end
        
        function trainPiNetwork(obj)
            % Trains Pi net using data in observer buffers
            
            % Query training data from buffers
            buffer = obj.PiX.getBuffer();
            X = buffer(:,1:end-1);
            Y = buffer(:,end);
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
            if(size(b,2) > 1)
                ind = sub2ind(([obj.total_coins+2, obj.total_coins+2, obj.total_coins+2, obj.coins_per_player+1, obj.total_coins+2]),bet2sub(b(3,:)),bet2sub(b(2,:)),bet2sub(b(1,:)),h+1,a2sub(a));
            else
                ind = sub2ind(([obj.total_coins+2, obj.total_coins+2, obj.total_coins+2, obj.coins_per_player+1, obj.total_coins+2]),bet2sub(b(3)),bet2sub(b(2)),bet2sub(b(1)),h+1,a2sub(a));
            end
        end
    end
    
end

