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
        
        function push(obj, newdata)
            % Pushes all rows in newdata onto the buffer, overwriting 
            % the oldest entries if we're out of room
            for j = 1:size(newdata,1);
                obj.data(obj.i,:) = newdata(j,:);
                obj.i = mod(obj.i,obj.total_size) + 1;
                if obj.current_size < obj.total_size
                    obj.current_size = obj.current_size + 1;
                end
            end
        end
        
        function [buffer] = getBuffer(obj)
            % Returns the buffer, excluding unfilled rows, if any
            buffer = obj.data(1:obj.current_size,:); 
        end
    end
end