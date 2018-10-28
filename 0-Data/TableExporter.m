classdef TableExporter < handle
    
    methods (Access = public)
        function obj = TableExporter()
        end
        
        function exportTable(~,table,fileName)
            writetable(table,fileName,'Delimiter','\t');
        end
    end
end