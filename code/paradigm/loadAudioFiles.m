function [loadedItems,textures] = loadAudioFiles(PTBparams,soundDirectory,listOfFiles)

DrawFormattedText(PTBparams.w, 'Loading... Please be patient', 'center', PTBparams.wRect(4)-75, WhiteIndex(PTBparams.w));
Screen('Flip', PTBparams.w);


%% load sounds and fill buffers

[sounds,freqs] = arrayfun(@(x)audioread(fullfile(soundDirectory,x.name)),...
    listOfFiles,'uniformoutput',0);
loadedItems.sounds = cellfun(@(x)formatAudioForPsychToolbox(x),sounds,'uniformoutput',0);
loadedItems.frequency = cell2mat(freqs);
clear sounds freqs
textures.audioHandles = arrayfun(@(x)PsychPortAudio('Open',[],[],[],x,2),loadedItems.frequency,'uniformoutput',0);
cellfun(@(x,y)PsychPortAudio('FillBuffer',x,y),textures.audioHandles,loadedItems.sounds);
