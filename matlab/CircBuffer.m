classdef CircBuffer < handle
    properties
        data = []
        i = -1;
        total_size = -1;
        current_size = -1;
    end
    
    methods
        function [obj] = CircBuffer(dims)
            % Constructor
            % Inputs: dims: two element tuple (m,n) where m is the number of
            %               vectors to allocate space for and n is the size of
            %               each vector
            obj.data = zeros(dims);
            obj.i = 1;
            obj.total_size = dims(1);
            obj.current_size = 0;
        end
        
        function push(obj, vector)
            % Pushes an object onto the buffer, overwriting the oldest
            % entry if we're out of room
            obj.data(obj.i,:) = vector;
            obj.i = mod(obj.i,obj.total_size) + 1;
            if obj.current_size < obj.total_size
                obj.current_size = obj.current_size + 1;
            end
        end
        
        function [buffer] = getBuffer(obj)
            % Returns the buffer, excluding unfilled rows, if any
            buffer = obj.data(1:obj.current_size,:); 
        end
    end
end