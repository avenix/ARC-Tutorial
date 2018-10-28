%this class is used to define how a class in the peaks file is mapped to a
%class for the classification. We will test different strategies (grouping all the dives,
%grouping all the throws, etc the  depending on the results we get with the
%classification

classdef ClassLabelingStrategy < handle

    properties (Access = public)
        classNames = {};
        numClasses;
    end
    
    methods (Access = public)
        [label] = labelForClass(obj, class);
        
        function labels = labelsForClasses(obj, classes)
            
            %transform to 0 for irrelevant and 1 to relevant
            labels = zeros(1,length(classes));
            for i = 1 : length(classes)
                
                class = classes(i);
                labels(i) = obj.labelForClass(class);
            end
        end
        
        function result = equals(obj, labelingStrategy)
            result = strcmp(class(obj),class(labelingStrategy));
        end
        
        function labelsStr = labelsToString(obj,labels)
            labelsStr = obj.classNames(labels);
        end
    end

end