classdef Environment < handle
    %ENVIRONMENT Provides a playing environment for players and bots
    %   Detailed explanation goes here
    
    properties
        players = [];
        coins_per_player = -1;
        lc_game = -1;
        silent = false;
        
    end
    
    methods
        function obj = Environment(players, cpp, silent)
            % Inputs: players = array of Players 
            %         cpp = coins_per_player
            %         silent = bool to specify whether printing is off
            obj.players = players;
            obj.coins_per_player = cpp;
            obj.silent = silent;
            
            % Initialize the LiarsCoins game
            np = length(players);
            nc = np*cpp;
            obj.lc_game = LiarsCoins(np,cpp);
            
            % Initalize each player
            for i = 1:length(players)
                players(i).initialize(obj.lc_game.viewHand(i),nc,np);
            end
            
        end
        
        function loser = playGame(obj)
            turn = 1;
            np = length(obj.players);
            round_bets = NaN*ones(1,np)'; % round_bets is a shift register
             % of players bets
             % NaN if a player hasn't played
            while(1)
                % compute last_bets from round_bets to pass to player
                last_bets = round_bets(1:end-1);
                % query bet
                bet = obj.players(turn).playTurn(last_bets);
                % play turn
                if(~obj.silent)
                    display(sprintf('Player %d bets %d', turn, bet));
                end
                [loser, next_turn] = obj.lc_game.playTurn(bet);
                % update bet histories
                round_bets = circshift(round_bets,[1,0]);
                round_bets(1) = bet;
                if(loser>0) % game was lost
                    if(~obj.silent)
                        obj.showHands();
                        display(sprintf('Game was lost by Player %d',loser));
                    end
                    break
                end
                % update turn
                turn = next_turn;
            end
        end
        function showHands(obj)
            hands = zeros(1,length(obj.players));
            for i = 1:length(obj.players)
                hands(i) = obj.players(i).hand;
            end
            display('Players hands:');
            display(hands);
        end
    end
    
end
