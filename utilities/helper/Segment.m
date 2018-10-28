classdef Segment
    
    properties
        player
        window
        class
        ts
    end
    
    methods
        function obj = Segment(player,window,class,ts)
            if nargin > 1 %enable initialisation with no params
                obj.player = player;
                obj.window = window;
                obj.class = class;
                obj.ts = ts;
            end
        end
        
        function window = getWindiw(obj)
            window = obj.window;
        end
    end
end

