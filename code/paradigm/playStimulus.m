function ttlLog = playStimulus(stimName,audioHandle,stimDuration,ttl,ttlLog);

ttlLog = ttl(sprintf('Playing %s for %.3f seconds',stimName,stimDuration),ttlLog);
PsychPortAudio('Start',audioHandle);
WaitSecs(stimDuration)