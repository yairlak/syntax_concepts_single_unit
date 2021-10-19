function ttlLog = playStimulus(sentence,stimName,audioHandle,stimDuration,ttl,ttlLog);

ttlLog = ttl(sprintf('Playing %s for %.3f seconds',stimName,stimDuration),ttlLog);
PsychPortAudio('Start',audioHandle);
ttlLog = ttl(sentence,ttlLog);
WaitSecs(stimDuration);