classdef ReservoirBuffer < handle
    %RESERVOIRBUFFER
    %   Detailed explanation goes here
    
    properties
        reservoir = [];
        k = -1;
        i = -1;
    end
    
    methods
        function obj = ReservoirBuffer(k,w)
            % Inputs: k = length of buffer
            %         w = width of buffer
            obj.reservoir = zeros(k,w);
            obj.i = 0;
            obj.k = k;
        end
        function reservoir = getBuffer(obj)
            % Returns available reservoir
            if(obj.i == 0)
                reservoir = [];
            elseif(obj.i<=obj.k)
                reservoir = obj.reservoir(1:obj.i,:);
            else
                reservoir = obj.reservoir;
            end
        end
        function push(obj,rows)
            % May add each row in rows to buffer
            % Inputs: rows = rows of data to add
            
            for row_i = 1:size(rows,1)
                row = rows(row_i);
                obj.i = obj.i + 1;
                if(obj.i <= obj.k)
                    obj.reservoir(obj.i,:) = row;
                else
                    ind = randi(obj.i);
                    % With prob k/i, replace a row in buffer
                    if(ind<= obj.k)
                        obj.reservoir(ind,:) = row;
                    end
                    % Else ignore
                end
            end
        end
            
    end
    
end

