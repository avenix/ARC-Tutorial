classdef ManualSegmentsLoader < handle
    properties (Access = public, Constant)
        fileName = 'segmentedData.mat';
        
        exerciseOffsets = [100, 100;...%dives
            60, 60;...%catches
            90, 90;...%throws
            100, 100;...%sprints
            100, 100;...%jogging
            70,25;...%passes
            100,100;...%null
            ];
        
        %only used to know the offsets
        labelingStrategy = DefaultLabelingStrategy();
    end
    
    properties (Access = private)
        segmentsAllPlayers;
    end
    
    methods (Access = public, Static)
        
        function [a, b] = windowMarginForLabel(label)
            a = ManualSegmentsLoader.exerciseOffsets(label,1);
            b = ManualSegmentsLoader.exerciseOffsets(label,2);
        end
    end
    
    methods
        function obj = ManualSegmentsLoader()
            obj.segmentsAllPlayers = obj.loadOrCreateSegmentsAllPlayers();
        end
        
        %returns a cell array. in each cell i, contains the segments of
        %player i
        function segments = loadSegments(obj, playerIdxs)
            segments = obj.segmentsAllPlayers(playerIdxs);
        end
        
        function segments = loadAllSegments(obj)
            segments = obj.segmentsAllPlayers;
        end
    end
    
    methods (Access = private)
        
        function segments = loadOrCreateSegmentsAllPlayers(obj)
            if exist(obj.fileName,'File') == 2
                segments = load(obj.fileName,'segments');
                segments = segments.segments;
            else
                segments = obj.createSegmentsAllPlayers();
                fullFileName = sprintf('data/precomputed/%s',obj.fileName);
                save(fullFileName,'segments');
            end
        end
        
        function segments = createSegmentsAllPlayers(obj)
            
            fileNames = {'subject1','subject2'};
            segments = cell(length(fileNames),1);
            
            for currentPlayer = 1 : length(fileNames)
                playerFileName = fileNames{currentPlayer};
                segments{currentPlayer} = obj.createSegmentsForPlayer(playerFileName, currentPlayer);
            end
        end
        
        function segments = createSegmentsForPlayer(obj,playerName, playerIdx)
            
            %load the manual annotations, this gives you list of (ts,label)
            
            dataLoader = DataLoader(playerName);
            data = dataLoader.loadData();
            manualPeakData = dataLoader.loadPeaks();
            peaksPlayer = manualPeakData.manualPeakLocations;
            classTypesPlayer = manualPeakData.manualPeakClasses;
            
            
            nExercises = length(peaksPlayer);
            segmentData = zeros(nExercises, 4);
            ts = data(:,1);
            
            %here we create the segmentat based on (ts,label) as (idx-a,idx+b) 
            for i = 1:length(peaksPlayer)
                %if you annotated a timestamp, otherwise just take the index
                peakID = find(ts == peaksPlayer(i));
                label = obj.labelingStrategy.labelForClass(classTypesPlayer(i));
                [a, b] = ManualSegmentsLoader.windowMarginForLabel(label);
                windowStart = max(peakID - a,1);
                windowEnd = min(peakID + b,length(ts));
                segmentData(i,:) = [windowStart,windowEnd,double(classTypesPlayer(i)),peaksPlayer(i)];
            end
            
            segmentData = sortrows(segmentData);
            segments(1,length(segmentData)) = Segment();
            
            %here we transform segmentData into segments (an array of
            %Segment instances)
            for i = 1:length(segments)
                window = data(segmentData(i,1):segmentData(i,2),:);
                classType = segmentData(i,3);
                timestamp = segmentData(i,4);
                segments(i) = Segment(playerIdx,double(window),classType,timestamp);
            end
        end
        
    end
    
end

