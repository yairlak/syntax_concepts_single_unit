function ttlLog = playStimulus(sentence,stimName,audioHandle,stimDuration,ttl,ttlLog);

ttlLog = ttl(sprintf('Playing %s (%s) for %.3f seconds',stimName,sentence,stimDuration),ttlLog);
PsychPortAudio('Start',audioHandle);
WaitSecs(stimDuration);


end