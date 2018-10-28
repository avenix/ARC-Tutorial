function result = aav(signal)

result = 0;

for i = 1 : length(signal)-1
    result = result + double(abs(signal(i+1) - signal(i)));
end
result = result / length(signal);

end