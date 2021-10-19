function [ttlLog pressedEsc] = showInstructionSlideForDuration(PTBparams,instructionText,ttlLog,ttl);

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

[result mouseKeyOrTimeout] = waitForMouseOrKeyClickConceptSyntax(w,1,1);
pressedEsc = 0;
if mouseKeyOrTimeout(2)
    if result.keyboard(PTBparams.EscKey)
        pressedEsc = 1;
        ttlLog = ttl('Pressed Escape',ttlLog);
    else
        ttlLog = ttl(sprintf('Pressed %s',KbName(result.keyboard)),ttlLog);
    end
else
    ttlLog = ttl('Clicked',ttlLog);
end

Screen('DrawTexture',w,grayscreen);
Screen('Flip',w);
ttlLog = ttl('Gray Screen',ttlLog); 
