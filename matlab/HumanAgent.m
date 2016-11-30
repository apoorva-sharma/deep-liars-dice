classdef HumanAgent < Player
    % NAIVEAGENT Plays a naive strategy when called
    % 
    
    properties
        hand = -1;
        total_coins = -1;
        num_players = -1;
        name = '';
        bets_to_display = 5;
    end
    
    methods
        function obj = HumanAgent(name)
            % Constructor for a NaiveAgent
            % Inputs: thresh = probability against which agent
            %           calls a bet or chooses a bet
            obj.name = name;
        end
        function initialize(obj,hand, total_coins, num_players)
            % Inputs: hand = num heads in this agent's hand
            %         total_coins = total coins in game
            %         num_players = number of players in the game
            
            obj.hand = hand;
            obj.total_coins = total_coins;
            obj.num_players = num_players;
            
            % compute coins held by other players
            unknown_coins = round(total_coins*(1 - 1/num_players));
            display(unknown_coins)
            % compute distribution over probabilities of getting coins
            bincdf = binocdf([0:unknown_coins],unknown_coins,0.5);
            % set best bet to largest safe bet, add player's hand
            obj.best_bet = hand + find(bincdf<=obj.thresh,1,'last')-1;
            
        end
        
        function next_bet = playTurn(obj,last_bets)
            % Inputs: last_bets = array of bets played by last n-1 players
            %           ordering: if obj is player 3 in a 5 player game
            %            then last_bets = bets of [2,1,5,4]
            % Output: next_bet played by obj
            max_bet = last_bets(end);
            % compute coins held by other players
            unknown_coins = round(obj.total_coins*(1 - 1/obj.num_players));
            display(unknown_coins)
            % compute distribution over probabilities of getting coins
            bincdf = binocdf([0:unknown_coins],unknown_coins,0.5);
            sprintf('Previous Bet:\n');
            max_bet_odds = bincdf(max([0 (max_bet - obj.hand)]));
            sprintf('Odds -- %f\n', max_bet_odds);
            sprintf('Possible Bets:\n')
            for i = 1:obj.bets_to_display
                bet_i_odds = bincdf(max([0 (max_bet + i - obj.hand)]));
                sprintf('%d heads -- $f\n',max_bet+i, bet_i_odds);
            end
            no_bet = 1;
            while(no_bet)
                next_bet = input('\nPlease input a bet, or -1 to call the previous player a Liar: ');
                if(next_bet <= max_bet && next_bet ~= -1)
                    sprintf('You must enter a bet higher then the previous players\n');
                elseif(next_bet > obj.total_coins)
                    sprintf('You must enter a bet less than the total number of coins\n');
                else
                    no_bet = 0;
                end
            end
        end
    end
    
end

