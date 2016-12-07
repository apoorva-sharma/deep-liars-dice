classdef PersistentNet < handle
    properties
        net = -1;
        precomputedResponses = NaN;
        time_since_last_train = 0;
        iterations_between_training = 1000;
    end
    
    methods
        function obj = PersistentNet(net)
            obj.net = net;
        end
        function train(obj,x,y)
            obj.net = train(obj.net,x,y);
            obj.time_since_last_train = 0;
        end
        
        function [y] = eval(obj,x)
            y = obj.net(x);
        end
    end
end