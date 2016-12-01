classdef DeepAgent < Player
    % DEEPAGENT Plays a deep strategy when called
    % 
    
    properties
        hand = -1;
        total_coins = -1;
        num_players = -1;
        obsNet = -1;
        piNet = -1;
        QNet = -1;
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
        end
        function initGame(obj,hand, total_coins, num_players)
            % Inputs: hand = num heads in this agent's hand
            %         total_coins = total coins in game
            %         num_players = number of players in the game
            
            obj.hand = hand;
            obj.total_coins = total_coins;
            obj.num_players = num_players;
            
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
            %            then last_bets = bets of [2,1,5,4]
            % Output: next_bet played by obj
            
            % TODO write the action selection code
            
            % Log the turn
            %  first fill in last row
            if ~isempty(obj.bp_log)
                obj.r_log(end,:) = 0;
                obj.bp_log(end,:) = b;
                obj.lp_log(end,:) = l;
            end
            % now add a new row
            obj.o_log = [obj.o_log; o];
            obj.b_log = [obj.b_log; b];
            obj.l_log = [obj.l_log; l];
            obj.a_log = [obj.a_log; a];
            obj.r_log = [obj.r_log; NaN];
            obj.bp_log = [obj.bp_log; NaN];
            obj.lp_log = [obj.lp_log; NaN];
            obj.unknown_coins_log = [obj.unknown_coins_log; NaN];
        end
        
        function [] = debrief(obj,reward,total_heads,hand)
            % Fill in missing items in logs
            obj.r_log(end,:) = reward;
            obj.unknown_coins_log(:) = total_heads - hand;
            
            % Add logs to replay memories
            % ObsNet
            obj.obsX = [obj.obsX; obj.o_log];
            obj.obsY = [obj.obsY; obj.unknown_coins_log];

            % PiNet
            obj.PiX = [obj.PiX; [obj.b_log obj.l_log obj.a_log]];

            % QNet
            obj.QX = [obj.QX; [obj.b_log obj.l_log obj.a_log obj.r_log...
                                obj.bp_log obj.lp_log]];
        end
    end
    
end

