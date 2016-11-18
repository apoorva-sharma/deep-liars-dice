classdef NaiveAgent < Handle
    % NAIVEAGENT Plays a naive strategy when called
    % 
    
    properties
        hand = -1;
        total_coins = -1;
        tot_head_dist = [];
    end
    
    methods
        function obj = NaiveAgent(hand, total_coins, thresh)
            % Inputs: hand = num heads in this agent's hand
            %         total_coins = total coins in game
            %         thresh = probability against which agent
            %           calls a bet or chooses a bet
            obj.hand = hand;
            obj.total_coins = total_coins;
            obj.tot_head_dist = binopdf(...
                0:total_coins - hand, total_coins - hand, 0.5);
            obj.thresh = thresh;
        end
        function next_bet = playStrategy(obj,curr_bet)
            % Check if current bet exceeds thresh
            if(curr_bet > hand)
                if curr_bet
            end
        end
    end
    
end

