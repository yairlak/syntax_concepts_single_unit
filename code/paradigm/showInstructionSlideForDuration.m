function ttlLog = showInstructionSlideForDuration(PTBparams,instructionText,ttlLog,ttl,waitDuration);
w = PTBparams.w;
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
ttlLog = ttl(sprintf('Instructions: %s',instructionText),ttlLog);
WaitSecs(waitDuration);
ttlLog = ttl(sprintf('Waited %.3f Seconds',waitDuration),ttlLog); 
Screen('DrawTexture',w,grayscreen);
Screen('Flip',w);
ttlLog = ttl('Gray Screen',ttlLog); 
