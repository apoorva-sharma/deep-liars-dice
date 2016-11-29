classdef NaiveAgent < Player
    % NAIVEAGENT Plays a naive strategy when called
    % 
    
    properties
        hand = -1;
        total_coins = -1;
        num_players = -1;
        best_bet = -1;
        thresh = 0.5;
    end
    
    methods
        function obj = NaiveAgent(thresh)
            % Constructor for a NaiveAgent
            % Inputs: thresh = probability against which agent
            %           calls a bet or chooses a bet
            obj.thresh = thresh;
        end
        function initialize(obj,hand, total_coins, num_players)
            % Inputs: hand = num heads in this agent's hand
            %         total_coins = total coins in game
            %         num_players = number of players in the game
            
            obj.hand = hand;
            obj.total_coins = total_coins;
            obj.num_players = num_players;
%             obj.best_bet = hand;
%             for bet = hand:total_coins
%                 prob = binocdf(bet-hand-1, total_coins - hand, 0.5);
%                 if prob <= thresh 
%                     obj.best_bet = hand;
%                 else
%                     break
%                 end
%             end
            
            % compute coins held by other players
            available_coins = round(total_coins*(1 - 1/num_players));
            display(available_coins)
            % compute distribution over probabilities of getting coins
            bincdf = binocdf([0:available_coins],available_coins,0.5);
            % set best bet to largest safe bet, add player's hand
            obj.best_bet = hand + find(bincdf<=obj.thresh,1,'last')-1;
            
        end
        
        function next_bet = playTurn(obj,last_bets)
            % Inputs: last_bets = array of bets played by last n-1 players
            %           ordering: if obj is player 3 in a 5 player game
            %            then last_bets = bets of [2,1,5,4]
            % Output: next_bet played by obj
            
            curr_bet = last_bets(1);
            
            % Check if current bet exceeds thresh
            if(curr_bet >= obj.best_bet)
                next_bet = -1; % call
            else
                next_bet = obj.best_bet;
            end
        end
    end
    
end

