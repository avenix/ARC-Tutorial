function [trimmedStepStartings, trimmedStepEndings] = trimSteps(stepStartings, stepEndings, signal)

DEVIATION_THRESHOLD = 0.10;%0.16
SEARCH_DISTANCE = 45;
WINDOW_SIZE = 6;

%{
close all;
hold on;
plot(1:length(signal),signal);
%}

trimmedStepStartings = zeros(1,length(stepStartings));
trimmedStepEndings = zeros(1,length(stepEndings));

N = length(signal);

for i = 1 : length(stepStartings)

for j = 1 : SEARCH_DISTANCE
    windowStart = stepStartings(i) + j;
    windowEnd = windowStart + WINDOW_SIZE;
    if windowEnd > N
        windowEnd = N;
    end
    window = signal(windowStart:windowEnd);
    deviation = std(window);
    if(deviation > DEVIATION_THRESHOLD)
        break;
    end
end

trimmedStepStartings(i) = stepStartings(i) + j;

for j = 1 : SEARCH_DISTANCE
    windowEnd = stepEndings(i) - j;
    windowStart = windowEnd - WINDOW_SIZE;
    if windowStart < 1
        windowStart = 1
    end
    window = signal(windowStart:windowEnd);
    deviation = std(window);
    if(deviation > DEVIATION_THRESHOLD)
        break;
    end
end

trimmedStepEndings(i) = stepEndings(i) - j;


    %line([trimmedStepStartings(i), trimmedStepStartings(i)],[-5 5],'Color',[1,0,0], 'LineStyle','--');
    %line([trimmedStepEndings(i), trimmedStepEndings(i)],[-5 5],'Color',[0,0,0], 'LineStyle','-.');
    
end

%{
hold off;
axis tight
title('Step Trimming');
ylabel('Acceleration');
xlabel('Sample');
axis([0 N -5 5]);
%}

end