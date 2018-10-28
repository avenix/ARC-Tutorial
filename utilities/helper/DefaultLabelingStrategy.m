
classdef DefaultLabelingStrategy < ClassLabelingStrategy
    
    methods
        function obj = DefaultLabelingStrategy()
                       
            obj.classNames = {'walking','crutches'};
            obj.numClasses = 2;
        end
        
        function [label] = labelForClass(~, class)
            label = class;
        end
    end
    
end