function y = formatAudioForPsychToolbox(y)

if size(y,1)>size(y,2)
    y = y';
end
if size(y,1)==1
    y = [y;y];
end