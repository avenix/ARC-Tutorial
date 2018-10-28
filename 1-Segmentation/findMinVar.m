function idx = findMinVar(signal)
    windowSize = 9;
    idx = 1;
    minVar = 10000;
    for i = 1 : windowSize : length(signal) - windowSize
        window = signal(i : i + windowSize - 1);
        newVar = var(window);
        if newVar < minVar
            minVar = newVar;
            idx = i + floor(windowSize / 2);
        end
    end
end