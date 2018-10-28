classdef FeatureSelector < handle
    properties
    end
    
    methods (Access = public)
        
        function obj = FeatureSelector()
        end

        function table = selectFeatures(~,table,featureIdxs)
            table = table(:,[featureIdxs width(table)]);
        end
        
        function featureIdxs = findBestFeatures(obj, table, maxNFeatures)
            
            nFeatures = size(table,2)-1;
            predictors = table2array(table(:,1:nFeatures));
            predictors = obj.discretizedPredictors(predictors);
            responses = table.label-1;
            
            featureIdxs = mrmr_mid_d(predictors, responses, maxNFeatures);
        end

    end
    
    methods (Access = private)
        
        
        %discretize predictors into categories
        function predictors = discretizedPredictors(~,predictors)
            alpha = 1;
            for i = 1 : size(predictors,2)
                m = mean(predictors(:,i));
                dev = std(predictors(:,i));
                firstEdge = min(predictors(:,i));
                lastEdge = max(predictors(:,i));
                edges = [firstEdge,m-alpha*dev, m+alpha*dev,lastEdge];
                edges = sort(edges);
                predictors(:,i) = discretize(predictors(:,i),edges);
            end
        end
        
        function labels = makeLabelsContinuous(~, labels)
            m = containers.Map('KeyType','int32','ValueType','int32');
            
            labelCount = 0;
            
            for i = 1 : length(labels)
                currentLabel = labels(i);
                if ~isKey(m,currentLabel)
                    m(currentLabel) = labelCount;
                    labelCount = labelCount + 1;
                end
            end
            
            for i = 1 : length(labels)
                currentLabel = labels(i);
                labels(i) = m(currentLabel);
            end
            
        end
        
    end
end
