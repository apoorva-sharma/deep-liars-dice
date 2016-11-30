classdef DeepAgent < Player
    % DEEPAGENT Plays a deep strategy when called
    % 
    
    properties
        hand = -1;
        total_coins = -1;
        num_players = -1;
    end
    
    methods
        function obj = DeepAgent()
            % Constructor for a DeepAgent
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
        end
    end
    
end




