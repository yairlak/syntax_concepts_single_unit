function ttlLog = showInstructionSlideForDuration(w,instructionText,ttlLog,ttl,waitDuration);

instructionText = [instructionText];

grayscreen = Screen('MakeTexture', w, GrayIndex(w));
Screen('TextSize', w, 28);
Screen('DrawTexture',w,grayscreen);
Screen('Flip',w);
DrawFormattedText(w, instructionText, 'center', 'center', WhiteIndex(w));
if exist('specialCommand','var')&&~isempty(specialCommand)
    eval(specialCommand);
end
[~,messagestart]=Screen('Flip', w);
ttlLog = ttl('Instructions',ttlLog);
ttlLog = ttl(instructionText,ttlLog);
WaitSecs(waitDuration);
ttlLog = ttl(sprintf('Waited %.3f Seconds',waitDuration),ttlLog); 
Screen('DrawTexture',w,grayscreen);
Screen('Flip',w);
ttlLog = ttl('Gray Screen',ttlLog); 
