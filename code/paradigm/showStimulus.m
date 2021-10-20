function ttlLog = playStimulus(PTBparams,sentence,ttl,ttlLog);

words = regexp(sentence,'\w*(?=\s|$|\n|\.)','match');

word_cnt = 0;
for word = words
    word_cnt = word_cnt + 1;
    % TEXT ON
    DrawFormattedText(PTBparams.w, word{1}, 'center', 'center', [1, 1, 1]);
    text_onset = Screen('Flip', PTBparams.w); % Word ON
    ttlLog = ttl(sprintf('Word ON: %i, %s', word_cnt, word{1}),ttlLog);
    WaitSecs(PTBparams.word_onset_duration);
    % TEXT OFF
    text_offset = Screen('Flip', PTBparams.w); % Word OFF
    ttlLog = ttl(sprintf('Word OFF: %i, %s', word_cnt, word{1}),ttlLog);  
    WaitSecs(PTBparams.word_offset_duration);
end % word


end