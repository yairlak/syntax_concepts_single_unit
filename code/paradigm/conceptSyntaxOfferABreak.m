function [ttlLog,videoCounter] = conceptSyntaxOfferABreak(PTBparams,videoInfo,ttlLog,ttl,videoCounter,nVideos)

ttlLog = ttl('Offering a break...',ttlLog);

if isempty(videoInfo)
ttlLog = showInstructionSlideTillClick(PTBparams,'If you''d like to take a break, please do so now.\n\n\nPress SPACE when you are ready to resume.',ttlLog,ttl);
else
    
    ttlLog = showInstructionSlideForDuration(PTBparams,'Please take a break and enjoy this video clip!',ttlLog,ttl,2,1);

    % show the video...
    Screen('SetMovieTimeIndex',videoInfo.texture,0);
    Screen('PlayMovie', videoInfo.texture, 1, 0, 1);
    ttlLog = ttl(sprintf('Start video: %s',videoInfo.videoName),ttlLog);
    while true
        [tex pts] = Screen('GetMovieImage', PTBparams.w, videoInfo.texture, 1);
        
        % Valid texture returned?
        if tex<0    % NO. This means that the end of this movie is reached.
            
            vbloff=Screen('Flip',PTBparams.w);
            ttlLog = ttl('movie ended',ttlLog);
            break;  % EXIt LOOP HERE
        end
        
        if (tex>0)  % Yes. Draw the new texture immediately to screen:
            Screen('DrawTexture', PTBparams.w, tex);
            Screen('Flip', PTBparams.w); % Update display:
            Screen('Close', tex);                     % Release texture:
        end
    end
    
    % Press space to continue
    ttlLog = showInstructionSlideTillClick(PTBparams,'Please press SPACE when you are ready to resume.',ttlLog,ttl);
    
    if videoCounter == nVideos
        videoCounter = 1;
    else
        videoCounter = videoCounter + 1;
    end
end