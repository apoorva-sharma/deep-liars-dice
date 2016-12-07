classdef ConservativeAgent < Player
    % ConservativeAgent Plays a only one more than the previous bet until
    % it reaches the maximum bet, when it calls.
    % 
    
    properties
        hand = -1;
        total_coins = -1;
        num_players = -1;
    end
    
    methods
        function obj = ConservativeAgent()
            % Constructor for a ConservativeAgent
            % Inputs: thresh = probability against which agent
            %           calls a bet or chooses a bet
        end
        function initGame(obj,hand, total_coins, num_players)
            % Inputs: hand = num heads in this agent's hand
            %         total_coins = total coins in game
            %         num_players = number of players in the game
            
            obj.hand = hand;
            obj.total_coins = total_coins;
            obj.num_players = num_players;
        end
        
        function next_bet = playTurn(obj,last_bets)
            % Inputs: last_bets = array of bets played by last n-1 players
            %           ordering: if obj is player 3 in a 5 player game
            %            then last_bets = bets of [2,1,5,4]
            % Output: next_bet played by obj
            
            curr_bet = last_bets(1);
            
            % Check if current bet exceeds thresh
            if(curr_bet >= obj.total_coins)
                next_bet = -1; % call
            else
                next_bet = curr_bet + 1;
            end
        end
        function debrief(obj, reward, total_heads, hand);
            return;
        end
    end
    
end

