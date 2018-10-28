% author: Juan Haladjian
% contact: haladjia@in.tum.de
% this is a tutorial on activity recognition with wearable
% sensor data. 

% this application classifies the gait of a cow into normal or abnormal.
% the abnormal gait has been collected while the cow walked with a plastic block attached 
% to its hind left leg.
% both data  sets have been collected with a motion sensor attached to the cow's
% left hind left leg.


%Note: remember to add the current directory to Matlab's path using:
%addpath(genpath('./'));
close all;

%% Load Data
importer = TableImporter();
normalDataTable = importer.importTable('data-normal.txt');
normalData = table2array(normalDataTable);
plotter = Plotter();
plotter.plotSignalBig(normalData(:,1),'Normal Cow Gait Data','Sample','Accelerometer-x');

abnormalDataTable = importer.importTable('data-abnormal.txt');
abnormalData = table2array(abnormalDataTable);
plotter.plotSignalBig(abnormalData(:,1),'Abnormal Cow Gait Data','Sample','Accelerometer-x');

%Note: you can save the data in binary Matlab's .m format
%for faster loading next time with the command:

%Note:if the data was saved in binary .m format
%you can load it with:
%data = load('data');
%data = data.data;

%% Explore Frequency Domain
plotter.plotSpectrogram(data(:,1),'Spectrogram','Sample','Frequency [Hz]');

%% ARC
featuresNormalTable = createFeaturesTable(normalData);
featuresAbnormalTable = createFeaturesTable(abnormalData);

featuresNormalData = table2array(featuresNormalTable);
featuresAbnormalData = table2array(featuresAbnormalTable);

nRowsNormalData = size(featuresNormalData,1);
nRowsAbnormalData = size(featuresAbnormalData,1);
nRows = nRowsNormalData + nRowsAbnormalData;
nCols = size(featuresNormalData,2);

%% Labeling
featuresNormalData(:,nCols+1) = 1;%label normal data as 1
featuresAbnormalData(:,nCols+1) = 2;%label abnormal data as 2

featuresData = zeros(nRows,nCols+1);
featuresData(1:nRowsNormalData,:) = featuresNormalData;
featuresData(nRowsNormalData+1:end,:) = featuresAbnormalData;
featuresTable = array2table(featuresData);
featuresTable.Properties.VariableNames = [featuresNormalTable.Properties.VariableNames,'label'];

%% Normalize features
dataNormalizer = DataNormalizer();
dataNormalizer.fit(featuresTable);
featuresTable = dataNormalizer.normalize(featuresTable);

testIdxs = false(1,nRows);
testIdxs(1:100) = true;
testIdxs(end-100:end) = true;
trainTable = featuresTable(~testIdxs,:);
testTable = featuresTable(testIdxs,:);

%% Feature selection
% Note: if you get erros here double check that your features table does
% not contain the same value for every feature in a column
nFeatures = 20;
featureSelector = FeatureSelector();
bestFeatues = featureSelector.findBestFeatures(trainTable,nFeatures);
trainTable = featureSelector.selectFeatures(trainTable,bestFeatues);
testTable = featureSelector.selectFeatures(testTable,bestFeatues);

% Note: usually, more features lead to higher classification accuracies. However, too 
% many features might overfit the classifier and will require more data to ensure the 
% computed accuracy represents how the classifier would behave in real life.
% Furthermore, in a real life system, more than 30 features are
% unpractical, depending on how CPU intensive the features are and
% computational resources (CPU, memory, energy) available on the embedded
% device.

%% Train Classifier
%this classifiers uses a predefined algorithm (SVM) with a polynomial
%kernel. You can use Matlab's Classification Learner App to test further
%algorithms

trainer = Trainer();
trainer.train(trainTable);

%% Test Classifier
labels = trainer.test(testTable);
shouldBeLabels = table2array(testTable(:,end));

%Note: to test other algorithms, open the Classification Learner Tool in the
%Matlab-Toolbox and select the variable 'table'


%% Plot Results
confusionMatrix = confusionmat(shouldBeLabels,labels);
plotter.plotConfusionMatrix(confusionMatrix,["Normal","Abnormal"]);


function featuresTable = createFeaturesTable(data)

plotter = Plotter();

%% Low pass Filter
cutoff = 20/100;
[b,a] = butter(1,cutoff);
data(:,1:3) = filter(b,a,data(:,1:3));
plotter.plotSignalBig(data(:,1),'Filtered','Sample','Acceleration [g]');

%% Energy calculation (e.g. for peak detection)
energy = data(:,1).^2 + data(:,2).^2 + data(:,3).^2;
axis = plotter.plotSignalBig(energy,'Energy','Sample','Acceleration [g2]');

%% Event Detection
[peaks, peakLocations] = findpeaks(energy,'minPeakHeight',5,'minPeakDistance',80);
hold on;
plotter.plotPeaks(axis,peakLocations,peaks,'green')

%% Segmentation
segmentA = 60;
segmentB = 80;
segmentStartIdxs = peakLocations - segmentA;
segmentEndIdxs = peakLocations + segmentB;
nSegments = length(segmentStartIdxs);
%this step generates the start and end indices of the segments

%% Feature Extraction
featureExtractor = FeatureExtractor();
nFeatures = featureExtractor.nFeatures;
featuresTableArray = zeros(nSegments,nFeatures);
for i = 1 : length(segmentStartIdxs)
    startIdx = max(1,segmentStartIdxs(i));
    endIdx = min(length(data),segmentEndIdxs(i));
    segment = data(startIdx:endIdx,1:6);
    featureVector = featureExtractor.extractFeaturesForSegment(segment);
    featuresTableArray(i,:) = featureVector;
end

featuresTable = array2table(featuresTableArray);
featuresTable.Properties.VariableNames = featureExtractor.featureNames;

%Note: here you could save the features using the save command for faster
%loading next time

end