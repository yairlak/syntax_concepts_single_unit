function [result mouseKeyOrTimeout] = waitForMouseOrKeyClickConceptSyntax(screenHandle,...
    acceptMouse, acceptKey,timeOut,waitForMouseRelease,waitForKeyRelease)

% SYNTAX: [result mouseKeyOrTimeout] = waitForMouseOrKeyClick(screenHandle,...
%     acceptMouse, acceptKey,timeOut,waitForMouseRelease,waitForKeyRelease,...
%     mouseTrackingFileID,mouseTrackingTime)

startTime = GetSecs;

if ~exist('timeOut','var')||isempty(timeOut)
    timeOut = inf;
end
if ~exist('waitForMouseRelease','var')||isempty(waitForMouseRelease)
    waitForMouseRelease = 1;
end
if ~exist('waitForKeyRelease','var')||isempty(waitForKeyRelease)
    waitForKeyRelease = 1;
end
if ~exist('mouseTrackingFileID')||isempty(mouseTrackingFileID)
    trackMouse = 0;
else
    trackMouse = 1;
    if ~exist('mouseTrackingTime','var')||isempty(mouseTrackingTime)
        mouseTrackingTime = startTime;
    end
end

mouseInd = GetMouseIndices;
if waitForMouseRelease
    % For some reason, this line doesn't really work very well, so
    % replacing with more explicit code
    % KbWait(mouseInd,1,startTime+timeOut-GetSecs);
    mouseIsDown = 1;
    while mouseIsDown
        [x,y,buttons] = GetMouse(screenHandle);
        mouseIsDown = any(buttons);
    end
end
if waitForKeyRelease
    keyIsDown = 1;
    while keyIsDown
        keyIsDown = KbCheck();
    end
    % KbWait(-1,1,startTime+timeOut-GetSecs);
end%

% now wait for mouse to be clicked
counter = 1;
buttons = [0 0]; keyIsDown = 0;
mouseKeyOrTimeout = zeros(1,3);

if acceptMouse && ~acceptKey
    criterion = @(m,k)any(m);
elseif acceptMouse
    criterion = @(m,k)any(m)||k;
elseif acceptKey
    criterion = @(m,k)k;
end

assert(logical(exist('criterion','var')));

while ~criterion(buttons,keyIsDown) && GetSecs-startTime < timeOut
    [x,y,buttons] = GetMouse(screenHandle);
    [keyIsDown, ~, keyCode] = KbCheck();
    mouseIsDown = any(buttons);
    
    if trackMouse
        if counter==1
            fprintf(mouseTrackingFileID,'%d  %d  %d\n',...
                GetSecs-mouseTrackingTime,x,y);
        end
        counter = mod(counter+1,10);
    end
    
    if mouseIsDown && acceptMouse
        result.mouse = struct('x',x,'y',y,'buttons',buttons);
        mouseKeyOrTimeout(1) = 1;
    end
    if keyIsDown && acceptKey
        result.keyboard = keyCode;
        mouseKeyOrTimeout(2) = 1;
    end
    WaitSecs(.005);
    
    
end
if ~exist('result','var')
    result.timeOut = 1;
    mouseKeyOrTimeout(3) = 1;
end
result.reactionTime = GetSecs - startTime;
