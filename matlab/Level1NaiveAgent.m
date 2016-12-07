classdef Level1NaiveAgent < Player
    % LEVEL1NAIVEAGENT Plays a good strategy against NaiveAgent(0.5)
    % 
    
    properties
        hand = -1;
        total_coins = -1;
        num_players = -1;
        best_bet = -1;
    end
    
    methods
        function obj = Level1NaiveAgent()
            % Constructor for a NaiveAgent
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
            
            % compute coins held by other players
            unknown_coins = round(total_coins*(1 - 1/num_players));
            % compute distribution over probabilities of getting coins
            bincdf = binocdf([0:unknown_coins],unknown_coins,0.5);
            % set best bet to largest safe bet, add player's hand
            obj.best_bet = hand + find(bincdf<=0.5,1,'last')-1;
            
        end
        
        function next_bet = playTurn(obj,last_bets)
            % Inputs: last_bets = array of bets played by last n-1 players
            %           ordering: if obj is player 3 in a 5 player game
            %            then last_bets = bets of [2,1,5,4]
            % Output: next_bet played by obj
            
            turn = sum(~isnan(last_bets))+1;
            offset = obj.best_bet - obj.hand; % used to find others' hands
            switch(turn)
                case(1)
                    next_bet = obj.best_bet;
                case(2)
                    known_coins = last_bets(1) - offset + obj.hand;
                    bincdf = binocdf([0:10],10,0.5);
                    next_bet = known_coins + find(bincdf<=0.5,1,'last')-1;
                case(3)
                    known_coins = sum(last_bets(1:2) - offset) + obj.hand;
                    bincdf = binocdf([0:5],5,0.5);
                    next_bet = known_coins + find(bincdf<=0.5,1,'last')-1;
                case(4)
                    known_coins = sum(last_bets - offset) + obj.hand;
                    next_bet = known_coins;
            end
            
            if(next_bet <= last_bets(1))
                next_bet = -1;
            end
            next_bet = min(20,next_bet);
            
        end
        function debrief(obj, reward, total_heads, hand);
            return;
        end
    end
    
end

