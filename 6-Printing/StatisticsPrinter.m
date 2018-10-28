classdef StatisticsPrinter < handle
    methods (Access = public)
        
        function obj = StatisticsPrinter()
        end
        
        function printTableStatistics(obj,exercisesTable, classNames, shouldSort)

            numOccurences = obj.computeNumOccurences(exercisesTable.label,length(classNames));
            if shouldSort == 1
                [sortedOccurences, sortedOccurenceIdx] = sort(numOccurences,'descend');
            else
                sortedOccurences = numOccurences;
                sortedOccurenceIdx = 1 : length(numOccurences);
            end
            
            for i = 1 : length(sortedOccurences)
                numInstances = sortedOccurences(i);
                classIdx = sortedOccurenceIdx(i);
                classNameCell = classNames(classIdx);
                className = classNameCell{1};
                fprintf('%d%20s: %d\n',classIdx,className,numInstances);
            end
            
            
            nullIdx = contains(classNames,'null');
            
            total = sum(sortedOccurences);
            totalIrrelevant = numOccurences(nullIdx);
            totalRelevant = total - totalIrrelevant;
            
            fprintf('total: %d\n',total);
            fprintf('total relevant: %d\n',totalRelevant);
            fprintf('total irrelevant: %d\n',totalIrrelevant);
            
        end
    end
    
    methods (Access = private)
        function numOccurences = computeNumOccurences(obj, labels, numClasses)
            numOccurences = zeros(1,numClasses);
            
            for class = 1: numClasses
                numOccurences(class) = sum(labels == class);
            end
        end
    end
end