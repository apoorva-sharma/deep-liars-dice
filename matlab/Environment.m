classdef Environment < handle
    %ENVIRONMENT Provides a playing environment for players and bots
    %   Detailed explanation goes here
    
    properties
        players = cell(0);
        coins_per_player = -1;
        lc_game = -1;
        silent = false;
        player_hands = [];
        loss_reward = -1;
        % For training the observer
        X = []; % [--last bets--]
        Y = []; % [unknown_num_heads]
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
            total_coins = np*cpp; % total number of coins
            obj.lc_game = LiarsCoins(np,cpp);
            
            % Initalize each player
            obj.player_hands = zeros(1,length(obj.players));
            for i = 1:length(players)
                player_hand = obj.lc_game.viewHand(i);
                players{i}.initGame(player_hand,total_coins,np);
                obj.player_hands(i) = player_hand;
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
                % add data to X,Y
                obj.X = [obj.X;last_bets'];
                obj.Y = [obj.Y;(obj.lc_game.total_heads - obj.lc_game.player_hands(turn))];
                % query bet
                bet = obj.players{turn}.playTurn(last_bets);
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
                    for i = 1:length(obj.players)
                        if loser == i
                            reward = obj.loss_reward;
                        else
                            reward = 0;
                        end
                        obj.players{i}.debrief(reward, obj.lc_game.total_heads, obj.lc_game.viewHand(i));
                    end
                    break
                end
                % update turn
                turn = next_turn;
            end
        end
        function showHands(obj)
            display('Players hands:');
            display(obj.player_hands);
        end
    end
    
end
