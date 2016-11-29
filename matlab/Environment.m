classdef Environment < handle
    %ENVIRONMENT Provides a playing environment for players and bots
    %   Detailed explanation goes here
    
    properties
        players = [];
        coins_per_player = -1;
        lc_game = -1;
    end
    
    methods
        function obj = Environment(players, cpp)
            % Inputs: players = array of Players 
            %         cpp = coins_per_player
            obj.players = players;
            obj.coins_per_player = cpp;
            
            % Initialize the LiarsCoins game
            np = length(players);
            nc = np*cpp;
            obj.lc_game = LiarsCoins(np,nc);
            
            % Initalize each player
            for i = 1:length(players)
                players(i).initalize(obj.lc_game.viewHand(i),nc,np);
            end
            
        end
        
        function playGame(obj)
            turn = 1;
            np = length(players);
            while(1)
                % TODO
            end
        end
    end
    
end

