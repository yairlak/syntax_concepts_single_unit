function [PTBparams,ttlLog] = initializePsychToolBoxForConceptSyntax(daq,ttlLog,debugMode,ptID,skipInitializingScreen,timerStart)
if ~exist('skipInitializingScreen','var')||isempty(skipInitializingScreen)
    skipInitializingScreen = 0;
end

sca;
PTBparam.ptID = ptID;
PTBparams.daq = daq;
PTBparams.debugMode = debugMode;

KbName('UnifyKeyNames');
PTBparams.EscKey = KbName('q');

%% initialize daq/usb port
if daq
    PTBparams.dio = initializeDAQ;
else
    PTBparams.dio=[];
end
dio = PTBparams.dio;
s = [];

%% Make sure the recording system is ready
    screenOptions = Screen('Screens');
    if length(screenOptions)==1
        sca;
        sca;
    end
    if ~debugMode
        yn = questdlg('Are we recording? Press ok when ready to continue.','Recording?','Ok','Cancel','Ok');
        if ~strcmpi(yn,'ok')
            return
        end
    end
    
    % TTLs
    if daq
        ttlLog = testTTLs('TTL',ttlLog,s,dio);
    end
    
    
    %% Initialize psych toolbox screen
if ~skipInitializingScreen
% Get screen parameters
screenOptions = Screen('Screens');
PTBparams.screenNumber=max(screenOptions);
PTBparams.gray=GrayIndex(PTBparams.screenNumber);
PTBparams.white=WhiteIndex(PTBparams.screenNumber);
PTBparams.black = BlackIndex(PTBparams.screenNumber);

if debugMode
    Screen('Preference','VisualDebugLevel',1);
end% Switch off your screen check
Screen('Preference','SkipSyncTests',1);

if debugMode
    PsychDebugWindowConfiguration;
end

[PTBparams.w, PTBparams.wRect]=Screen('OpenWindow',PTBparams.screenNumber, PTBparams.gray);
Screen('TextSize', PTBparams.w, 28);
if isequal(PTBparams.wRect,[0 0 1920 1080])&&eyetracker
    PTBparams.subRect = [274 0 1920-274 1080];
else
    PTBparams.subRect = [30 0 PTBparams.wRect(3)-30 PTBparams.wRect(4)];
end

priorityLevel=MaxPriority(PTBparams.w);
Priority(priorityLevel);

grayscreenWithBlackEdges = zeros(PTBparams.wRect(4)-PTBparams.wRect(2),PTBparams.wRect(3)-PTBparams.wRect(1));
grayscreenWithBlackEdges(PTBparams.subRect(2)+1:PTBparams.subRect(4),PTBparams.subRect(1)+1:PTBparams.subRect(3)) = PTBparams.gray;
PTBparams.grayscreen = Screen('MakeTexture', PTBparams.w, grayscreenWithBlackEdges);

screenHeight = PTBparams.subRect(4)-PTBparams.subRect(2);
totalScreenWidth = PTBparams.subRect(3)-PTBparams.subRect(1);

PTBparams.screenCenter = [PTBparams.subRect(1)+totalScreenWidth/2 PTBparams.subRect(2)+screenHeight/2];
PTBparams.leftImageRect = [PTBparams.screenCenter(1)-840 PTBparams.screenCenter(2)-400 PTBparams.screenCenter(1)-40 PTBparams.screenCenter(2)+400];
PTBparams.rightImageRect = [PTBparams.screenCenter(1)+40 PTBparams.screenCenter(2)-400 PTBparams.screenCenter(1)+840 PTBparams.screenCenter(2)+400];
PTBparams.centralImageRect = [PTBparams.screenCenter(1)-400 PTBparams.screenCenter(2)-400 PTBparams.screenCenter(1)+400 PTBparams.screenCenter(2)+400];
Screen('TextFont',PTBparams.w ,'Times New Roman');
Screen('TextSize',PTBparams.w,44);
Screen('TextStyle',PTBparams.w,1);
end
% check for Opengl compatibility, abort otherwise:
AssertOpenGL;

%% Perform basic initialization of the sound driver:
InitializePsychSound;

%% Reseed the random-number  generator for each expt.
thisRandomSeed = sum(100*clock);
rand('state',thisRandomSeed);

%% Make sure keyboard mapping is the same on all supported operating systems
KbName('UnifyKeyNames');

PTBparams.LeftKey=KbName('LeftArrow'); %should be 160
PTBparams.RightKey=KbName('RightArrow'); %should be 161
PTBparams.UpKey=KbName('UpArrow'); %should be 82
PTBparams.DownKey=KbName('DownArrow'); %should be 81
PTBparams.EscKey = KbName('Escape');
PTBparams.SpaceKey = KbName('Space');
PTBparams.eKey = KbName('e'); % should be 8


    PTBparams.eyelink = [];
    PTBparams.edfFile = '';
    el = [];

%% get started
if exist('timerStart','var')&&~isempty(timerStart)
    PTBparams.timerStart = timerStart;
else
PTBparams.timerStart = tic;
ttlLog = sendTTL_em('timer_start',s,dio,el,toc(PTBparams.timerStart),ttlLog);
end
