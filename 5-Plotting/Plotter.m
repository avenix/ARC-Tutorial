classdef Plotter
    
    properties
        fontSize = 32;
        figureFrame = [500, 500, 700, 700];
    end
    
    methods (Access = public)
        function obj = Plotter()
        end
        
        function plotHandles = plotSegments(~,axis,segmentStartings, segmentEndings,yRange)
            if nargin < 5
                yRange = 20;
            end
            
            hold(axis,'on');
            
            y = [ones(1,length(segmentStartings))*-yRange ; ones(1,length(segmentStartings))*yRange];
            x = [segmentStartings; segmentStartings];
            
            plotHandles = gobjects(2,length(x));
            plotHandles(1,:) = plot(axis,x,y, 'Color','red');
            
            x = [segmentEndings; segmentEndings];
            plotHandles(2,:) = plot(axis,x,y,'Color','black','LineStyle','-.');
        end
        
        function plotHandles = plotSegment(~,axis,segmentStarting, segmentEnding,yRange)
            if nargin < 5
                yRange = 20;
            end
            
            plotHandles = zeros(1,2);
            plotHandles(1) = plot(axis,[segmentStarting segmentStarting],[0 yRange], 'Color','red');
            plotHandles(2) = plot(axis,[segmentEnding segmentEnding],[0 yRange],'Color','black','LineStyle','-.');
        end
        
        function plotLines(~,axis,segments,yRange)
            if nargin < 5
                yRange = 20;
            end
            
            hold(axis,'on');
            
            y = [zeros(1,length(segments)) ; ones(1,length(segments))*yRange];
            x = [segments; segments];
            plot(axis,x,y, 'Color','red');
        end
        
        function plotPeaks(~,ax,peakLocations,peakValues,color)
            if nargin == 4
                color = 'green';
            end
            hold(ax,'on');
            plot(ax, peakLocations,peakValues,'*','Color',color);
        end
        
        function plottedAxis = plotSignal(~,axis,signalX,signalY,color)
            if nargin == 4
                plottedAxis = plot(axis,signalX,signalY);
            elseif nargin == 5
                plottedAxis = plot(axis,signalX,signalY,'Color',color);
            end
        end
        
        function axis = plot2SignalsTogether(~,signal1,signal2)
            x = 1:length(signal1);
            axis = axes();
            plot(axis,x,signal1,'b',x,signal2,'r');
        end
        
        function plots = plot2SignalsSeparated(~,signal1,signal2)
            
            plots(1) = subplot(2,1,1);
            plot(signal1);
            plots(2) = subplot(2,1,2);
            plot(signal2);
            
            linkaxes(plots,'xy');
        end
        
        function ax = plotSignalBig(obj,signal,titleStr,xLabelStr,yLabelStr)
            obj.openDefaultFigure();
            ax = axes();
            hold on;
            x = (1 : length(signal));
            plot(ax,x,signal,'Color', 'blue');
            obj.setAxisAndTitle(titleStr,xLabelStr,yLabelStr);
        end 
        
        %plots a signal in different colors. The segments are indicated in
        %the nSamplesPerGroup (array of the amount of samples per group)
        %colors contains a color per segment and labels a string per segment
        function plotDataGrouped(obj,signal,nSamplesPerGroup,colors,labels,titleStr,xLabelStr,yLabelStr)
            obj.openDefaultFigure();
            
            hold on;
            currentIdx = 1;
            nextIdx = 1;
            for i = 1 : length(nSamplesPerGroup)
                nextIdx = nextIdx + nSamplesPerGroup(i) - 1;
                x = (currentIdx : nextIdx);
                plot(x./100,signal(x),'Color',colors{i});
                currentIdx = nextIdx;
            end
            legend(labels);
            xlabel(xLabelStr,'FontSize', obj.fontSize);
            ylabel(yLabelStr,'FontSize', obj.fontSize);
            title(titleStr,'FontSize', obj.fontSize);
            set(gca,'FontSize',obj.fontSize);
            axis tight;
        end
        
        function plotSpectrogram(obj,signal,titleStr,xLabelStr,yLabelStr)
            obj.openDefaultFigure();
            
            % Parameters
            frequencyLimits = [0 100]/pi; %Normalized frequency (*pi rad/sample)
            leakage = 0.2;
            overlapPercent = 50;
            
            pspectrum(signal, ...
                'spectrogram', ...
                'FrequencyLimits',frequencyLimits, ...
                'Leakage',leakage, ...
                'OverlapPercent',overlapPercent);
            
            obj.setAxisAndTitle(titleStr,xLabelStr,yLabelStr);
        end
        
        function setAxisAndTitle(obj,titleStr,xLabelStr,yLabelStr)
            xlabel(xLabelStr,'FontSize', obj.fontSize);
            ylabel(yLabelStr,'FontSize', obj.fontSize);
            title(titleStr,'FontSize', obj.fontSize);
            set(gca,'FontSize',obj.fontSize);
            axis tight;
        end
        
        function figHandle = openDefaultFigure(obj)
            figHandle = figure('Position',obj.figureFrame);
            obj.setDataCursorModeForFigure(figHandle);
        end
        
        function figHandle = plotConfusionMatrix(obj,confusionMatrix,labels)
            confmatPlotter = ConfusionMatrixPlotter();
            figHandle = obj.openDefaultFigure();
            confmatPlotter.plotConfusionMatrix(confusionMatrix,labels);
        end
    end
    
    methods (Access = private)
        function setDataCursorModeForFigure(obj, figureHandle)
            dataCursorMode = datacursormode(figureHandle);
            dataCursorMode.SnapToDataVertex = 'on';
            %dataCursorMode.DisplayStyle = 'window';
            dataCursorMode.Enable = 'on';
            set(dataCursorMode,'UpdateFcn',@obj.handleUserClick);
        end
        
        function [outputTxt] = handleUserClick(~,src,~)
            pos = get(src,'Position');
            x = pos(1);
            y = pos(2);
            xStr = num2str(x,7);
            yStr = num2str(y,7);
            outputTxt = {['X: ',xStr],['Y: ',yStr]};
            fprintf('%d\n',x);
        end
    end
end