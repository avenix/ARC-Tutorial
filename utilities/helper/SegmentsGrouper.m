classdef SegmentsGrouper < handle
        
    methods
        function obj = SegmentsGrouper()
        end
        
        %takes input from ManualSegmentsLoader.loadSegments()
        %returns cell array. In each cell i, contains segments of class i
        function groupedSegments = groupSegments(obj,segments,labelingStrategy)
            nClasses = labelingStrategy.numClasses;
            
            nSegmentsPerClass = obj.countManualSegmentsPerClass(segments,nClasses,labelingStrategy);
            groupedSegments = cell(nClasses,1);
            for i = 1 : labelingStrategy.numClasses
                nSegmentsCurrentClass = nSegmentsPerClass(i);
                %segmentArray(1,nSegmentsCurrentClass) = Segment();
                groupedSegments{i}{nSegmentsCurrentClass} = Segment();
            end
            
            segmentCounterPerClass = zeros(1,nClasses);
            for currentPlayer = 1 : length(segments)
                playerSegments = segments{currentPlayer};
                for i = 1 : length(playerSegments)
                    segment = playerSegments(i);
                    segment.class = labelingStrategy.labelForClass(segment.class);
                    counter = segmentCounterPerClass(segment.class);
                    counter = counter + 1;
                    segmentCounterPerClass(segment.class) = counter;
                    groupedSegments{segment.class}{counter} = segment;
                end
            end
        end
        
        %converts the cell array into an array. Returns the 'cutpoints'
        %between classes
        function [fullData, nSamplesPerClass] = convertToFullData(obj,groupedSegments)
            nSamplesPerClass = obj.countSamples(groupedSegments);
            nSamplesTotal = sum(nSamplesPerClass);
            fullData = zeros(nSamplesTotal,6);
            flatSegmentIdx = 1;
            for i = 1 : length(groupedSegments)
                segmentArray = groupedSegments{i};
                for j = 1 : length(segmentArray)
                    segment = segmentArray{j};
                    data = segment.window;
                    segmentSize = size(data,1);
                    fullData(flatSegmentIdx:flatSegmentIdx + segmentSize - 1,:) = data(:,2:end);
                    flatSegmentIdx = flatSegmentIdx + segmentSize;
                end
            end
        end
        
        function nSegmentsPerClass = countSegmentsPerClass(~, groupedSegments)
            nSegmentsPerClass = zeros(1,length(groupedSegments));
            for i = 1 : length(groupedSegments)
                segmentArray = groupedSegments{i};
                nSegmentsPerClass(i) = length(segmentArray);
            end
        end
        
        function nSamplesPerClass = countSamples(~,groupedSegments)
            nSamplesPerClass = zeros(1,length(groupedSegments));
            for i = 1 : length(groupedSegments)
                segmentArray = groupedSegments{i};
                for j = 1 : length(segmentArray)
                    segment = segmentArray{j};
                    nSamplesPerClass(i) = nSamplesPerClass(i) + length(segment.window);
                end
            end
        end
        
    end
    
    methods (Access = private)
        function nSegmentsPerClass = countManualSegmentsPerClass(~,segments, nClasses, labelingStrategy)
            nSegmentsPerClass = zeros(1,nClasses);
            
            for currentPlayer = 1 : length(segments)
                playerSegments = segments{currentPlayer};
                for i = 1 : length(playerSegments)
                    segment = playerSegments(i);
                    label = labelingStrategy.labelForClass(segment.class);
                    nSegmentsPerClass(label) = nSegmentsPerClass(label) + 1;
                end
            end
        end
        
    end
    
end