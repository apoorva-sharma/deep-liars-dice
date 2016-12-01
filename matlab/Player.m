classdef (Abstract) Player < handle
    %PLAYER Generic player abstract
    %   Detailed explanation goes here
    
    properties (Abstract)
        hand;
        total_coins;
        num_players;
        
    end
    
    methods (Abstract) 
        initGame(obj, hand, total_coins, num_players);
            % Inputs: hand = num heads in this agent's hand
            %         total_coins = total coins in game
            %         num_players = number of players in the game
        next_bet = playTurn(obj, last_bets);
            % Inputs: last_bets = array of bets played by last n-1 players
            %           ordering: if obj is player 3 in a 5 player game
            %            then last_bets = bets of [2,1,5,4]
            % Output: next_bet played by obj
        debrief(obj, reward, total_heads, hand);
            % Inputs: reward = -1 if player lost game, 0 otherwise
            %         total_heads = number of total heads on the board
            %         hand = number of heads the player had
            % Output: next_bet played by obj
    end
    
end

