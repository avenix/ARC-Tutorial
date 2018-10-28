close all;
colors = {'red','blue','yellow','magenta','black','green'};
%dives catches throws running jogging passes null
labelingStrategy = DefaultLabelingStrategy();
plotter = Plotter();

%% Load segments
manualSegmentsLoader = ManualSegmentsLoader();
segments = manualSegmentsLoader.loadAllSegments();

segmentsGrouper = SegmentsGrouper();
groupedSegments = segmentsGrouper.groupSegments(segments,labelingStrategy);

%eliminate NULL and jogging class
relevantClassIndices = [1,2,3,4,6];
classNames = labelingStrategy.classNames(relevantClassIndices);
groupedSegments = groupedSegments(relevantClassIndices);

%% compute peaks as ground truth
nSegmentsPerClass = segmentsGrouper.countSegmentsPerClass(groupedSegments);
NSegments = sum(nSegmentsPerClass);
NRelevant = sum(nSegmentsPerClass(1:4));
%NIrrelevant = nSegmentsPerClass(4);
manualPeakPositions = zeros(1,NRelevant);
segmentStart = 1;
manualPeakCounter = 1;
for i = 1 : length(groupedSegments)-1
    segmentArray = groupedSegments{i};
    for j = 1 : nSegmentsPerClass(i)
        [a, b] = ManualSegmentsLoader.windowMarginForLabel(i);
        manualPeakPositions(manualPeakCounter) = segmentStart + a;
        manualPeakCounter = manualPeakCounter + 1;
        segmentStart = segmentStart + a + b + 1;
    end
end


%% Raw data
[fullData, nSamplesPerClass] = segmentsGrouper.convertToFullData(groupedSegments);
fullDataAM = fullData(:,1).^2+fullData(:,2).^2+fullData(:,3).^2;
plotter.plotDataGrouped(fullDataAM,nSamplesPerClass,colors,classNames,'Raw Energy','Time [s]','Energy [g²]');
%plot(manualPeakPositions./100,fullDataAM(manualPeakPositions),'*','Color','green');
%plotter.plotSpectrogram(fullDataAM,'Spectrogram','Time [s]','Frequency [Hz]');


%% High-pass filter
cutoff = 25/100;
[b,a] = butter(1,cutoff,'high');
fullDataAM = abs(filter(b,a,fullDataAM));
plotter.plotDataGrouped(fullDataAM,nSamplesPerClass,colors,classNames,'Filtered Energy','Time [s]','Energy [g²]');


%% Peak detection
minPeakDistance = 100;
minPeakHeight = 7000000;

%startMinPeakHeight = 7000000;
%minPeakHeightIntervals = 1000000;
%endMinPeakHeight = 8000000;
%startMinPeakDistance = 80;
%minPeakDistanceIntervals = 10;
%endMinPeakDistance = 140;
%for minPeakHeight = startMinPeakHeight : minPeakHeightIntervals : endMinPeakHeight
%for minPeakDistance = startMinPeakDistance : minPeakDistanceIntervals : endMinPeakDistance

%peakDetectionResults 
%for peakLeft = 60 : 5 : 150
%    for peakRight = 60 : 5 : 130
        
        [peaks, peakLocs] = findpeaks(fullDataAM,'MinPeakHeight',minPeakHeight,'MinPeakDistance',minPeakDistance);
        plotter.plotDataGrouped(fullDataAM,nSamplesPerClass,colors,classNames,'Peak Detection','Time [s]','Energy [g²]');
        line([1,length(fullDataAM)]/100,[minPeakHeight minPeakHeight],'LineWidth',3,'Color','green');
        plot(peakLocs/100,peaks,'*','Color','green');
        
        %% Segmentation
        segmentStartings = peakLocs - 130;
        segmentEndings = peakLocs + 80;
        
        passStartSample = sum(nSamplesPerClass(1:4));
        TP = SegmentationTestbed.countNumberGoodPeaksFound(segmentStartings, segmentEndings, manualPeakPositions);
        FP = SegmentationTestbed.countNumberBadSegmentsFound(segmentStartings, segmentEndings, manualPeakPositions, [], []);
        FN = NRelevant - TP;
        
        Precision = TP / (TP + FP);
        Recall = TP / (TP + FN);
        F1 = 2 * (Precision * Recall) / (Precision + Recall);
        
        fprintf('%.1f %.1f %.1f\n',Precision*100,Recall*100,F1*100);
        %end
 %   end
%end


segment = Segment();
%segment.window = data(segmentStartings(i),segmentEndings(i)]
%% Dynamic Time Warping
% compute templates 
% compute threshold that maximises the passes under it and other segments
% above it
% use a segment size of 130 around the detected peaks
%segmentStartings = 

%% Plot raw data separately
for i = 1 : length(groupedSegments)
    segmentArray = groupedSegments{i};
    plotter.openDefaultFigure();
    hold on;
    for j = 1 : length(segmentArray)
        segment = segmentArray{j};
        segmentData = segment.window;
        energy = segmentData(:,2).^2 + segmentData(:,3).^2 + segmentData(:,4).^2;
        
        p = plot(energy,'-','LineWidth',0.2,'Color',colors{i});
        p.Color(4) = 0.10;
        plotter.setAxisAndTitle(classNames{i},'Time [s]','Energy [g²]');
    end
    %save as plot
    fileName = sprintf('%s',classNames{i});
    plotter.savePlotAsPNG(fileName);
end

return;

%% Compute features
deviations = zeros(1,NSegments);
featureIdx = 1;
for i = 1 : length(groupedSegments)
    segmentArray = groupedSegments{i};
    for j = 1 : length(segmentArray)
        segment = segmentArray{j};
        data = segment.window;
        aM = sqrt(data(:,2).^2 + data(:,3).^2 + data(:,4).^2);
        deviation = std(aM);
        deviations(featureIdx) = deviation;
        featureIdx = featureIdx + 1;
    end
end

%% Plot features
figure();
hold on;
currentIdx = 1;
nextIdx = 1;
for i = 1 : length(nSegmentsPerClass)
    nSegments = nSegmentsPerClass(i);
    endIdx = currentIdx + nSegments - 1;
    x = currentIdx : endIdx;
    y = deviations(currentIdx:endIdx);
    plot(x,y,'Color',colors{i});
    currentIdx = endIdx;
end
