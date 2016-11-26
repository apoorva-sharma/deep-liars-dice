classdef Environment < handle
    %ENVIRONMENT Provides a playing environment for players and bots
    %   Detailed explanation goes here
    
    properties
        num_players = -1;
        num_bots = -1;
        bots = [];
        coins_per_player = -1;
        lc_game = -1;
    end
    
    methods
        function obj = Environment(np,cpp,nb)
            % Inputs: num_players, coins_per_player, num_bots
            obj.num_players = np;
            obj.num_bots = nb;
            obj.coins_per_player = cpp;
            
            obj.lc_game = LiarsCoins(np,nc);
            % TODO: Assign NaiveAgents to nb hands
            
            
        end
    end
    
end

