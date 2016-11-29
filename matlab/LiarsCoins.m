classdef LiarsCoins < handle
    %LIARSCOINS Class for simulating one game of liar's coins
    %   
    
    properties
        num_players = 0;
        num_coins_per_player = 0;
        player_hands = []; % num_heads per player
        total_heads = 0;
        turn = -1;
        curr_bet = -1;
        loser = -1;
    end
    
    methods
        function obj = LiarsCoins(np, nc)
            % Inputs: num_players, num_coins
            
            obj.num_players = np;
            obj.num_coins_per_player = nc;
            
            % Init game
            obj.player_hands = randi([0,nc],1,np);
            obj.total_heads = sum(obj.player_hands);
            obj.curr_bet = 0;
            obj.turn = 1;
            
            disp('Game initialized...');
            disp('Player 1"s turn');
        end
        function hand = viewHand(obj,player)
            % Returns hand for [player]
            hand = obj.player_hands(player);
        end
        function [loser,next_turn] = playTurn(obj,bet)
            % Plays player [turn]'s bet
            % Inputs: bet (assumes -1 is a call)
            % Outputs: next_turn (-1 if game over), 
            %   loser (-1 if game not over)
            if(bet == -1)
                if obj.curr_bet <= obj.total_heads % curr player loses
                    obj.loser = obj.turn;
                else % last player loses
                    obj.loser = mod(obj.turn - 2,obj.num_players) + 1;
                end 
                obj.turn = -1;
            elseif (bet <= obj.curr_bet)
                error('Bet %d did not exceed last bet %d', bet, obj.curr_bet)
            else
                obj.curr_bet = bet;
                obj.turn = mod(obj.turn,obj.num_players) + 1;
            end
            
            next_turn = obj.turn;
            loser = obj.loser;
            
        end
    end
    
end

