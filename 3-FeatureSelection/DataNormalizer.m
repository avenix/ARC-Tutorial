classdef DataNormalizer < handle
    
    properties
        means;
        stds;
    end
    
    methods
        function obj = DataNormalizer()
        end
        
        function fit(obj,table)
            data = table2array(table(:,1:end-1));
            obj.fitData(data);
        end
        
        function table = normalize(obj,table)
            data = table2array(table(:,1:end-1));
            normalizedData = obj.normalizeData(data);
            table(:,1:end-1) = array2table(normalizedData);
        end
        
        function fitData(obj,data)
            obj.means = mean(data);
            obj.stds = std(data,0,1);
        end
        
        function normalizedData = normalizeData(obj,data)
            N = length(data(:,1));
            normalizedData = data - repmat(obj.means,N,1);
            normalizedData = normalizedData ./ repmat(obj.stds,N,1);
        end
    end
end