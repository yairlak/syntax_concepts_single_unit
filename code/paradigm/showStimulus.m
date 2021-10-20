function ttlLog = playStimulus(PTBparams,sentence,ttl,ttlLog);

words = regexp(sentence,'\w*(?=\s|$|\n|\.)','match');