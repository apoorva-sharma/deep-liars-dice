classdef PersistentNet < handle
    properties
        net = -1;
    end
    
    methods
        function obj = PersistentNet(net)
            obj.net = net;
        end
        function train(obj,x,y)
            obj.net = train(obj.net,x,y);
        end
        
        function [y] = eval(obj,x)
            y = obj.net(x);
        end
    end
end