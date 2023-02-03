       function conceptSyntax(patientNumber,useDAQ,includeTrainingBlock,debug,audioFileExtension, ...
    nReps,maxStims,audioVisualOrBoth,breakEveryNTrials,pathToVideoForTakingABreak,substitutions)

% syntax: conceptSyntax(patientNumber,useDAQ,includeTrainingBlock,debug,audioFileExtension, ...
%     nReps,maxStims,audioVisualOrBoth,substitutions)
% Except for patientNumber, any argument may be omitted or left empty to
% select its default value
%
% patientNumber should the the ID number of the person completing the task
% useDAQ (default = ask): 0 means no TTLs sent to recording system, 1 means
%                         send TTLs to the recording system. This will
%                         cause an error if the DAQ is not connected.
% includeTrainingBlock (default = 1): 1 means include a training block. It
%                      will play/show a few stimuli to get the patient used
%                      to the task. If you've already done a training block
%                      and have to start the task again for some reason,
%                      you may enter 0 to skip training.
% debug (default = 0): If debug is 1, the paradigm will show on a
%                      transparent screen and you can interact with Matlab
%                      while running the task (e.g. with a dbstop command).
%                      You usually need to restart Matlab to make the
%                      screen opaque again if you want to switch out of
%                      debug mode.
% audioFileExtension (default = 'aiff'): Used for identifying audio files.
%                    When we generate audio files, they are currently saved
%                    as .aiff files, so that's the default. If we change
%                    that method eventually, we may want to change the
%                    default.
% nReps (default = 1): The number of times we will go through the whole set
%                      of stimuli. Since we currently generate 160 stimuli,
%                      one time through is all we take
% maxStims (default = inf): If this is smaller than the number of stimuli
%                           available, it will stop after presenting that
%                           number. (This is mostly useful for debugging,
%                          when you might want to see the task end without
%                          waiting through all of the stimuli. Note that if
%                          nReps > 1, the stimuli chosen for each round is
%                          a random selection from the whole set, rather
%                          than the same set. If you prefer to use the same
%                          subset, you'll have to write those changes
%                          yourself!
% audioVisualOrBoth (default = ask): The task can run either by
%                         flashing the words on the screen in sequence
%                         (visual) or by reading the sentences aloud
%                         (audio). If you choose 'both', it will run the
%                         visual version followed by the audio version.
% breakEveryNTrials (default = 40): This should be a number, N, such that
%                         after every N trials, if there are more than N/2
%                         trials reamaining, it will prompt the user to
%                         take a break.
% pathToVideoForTakingABreak (default = ask): If you would like to show a
%                         short video during the break, please include the
%                         path (or paths if you want to show different ones
%                         at different breaks) here. By default, no path is
%                         included, so the break will just be instructions
%                         to take a break.
% substitutions (default = {}): This is for generating the audio files.
%                         Certain words are hard for the text2audio method
%                         to parse, so you may choose to spell them
%                         differently when passing to text2audio, but you
%                         still want them spelled properly in the written
%                         sentences. You may include pairs of strings
%                         within {}, where the odd entries are the correct
%                         spellings and the even entries are the more
%                         phonetic spellings.
%
% The paradigm expects there already to exist a .txt file of sentence
% stimuli that will be used. It will convert to audio files the first time
% this is run. If you want different audio files, you will have to
% delete/move the ones that already exist.
%
%  THE EASIEST WAY TO CREATE THESE FILES IS TO RUN
%  prepConceptSyntax(pt,exp)
%  BEFORE YOU START

% Paradigm written by Emily Mankin with contributions from Yair Lakretz,
% October 2021

paradigmFolder = fileparts(which('conceptSyntax.m'));
codeFolder = fileparts(paradigmFolder);
addpath(genpath(codeFolder));

%% set default values
if ~exist('patientNumber','var')||isempty(patientNumber)
    patientNumber = inputdlg('Please enter patient  number','Patient',1);
elseif ~iscell(patientNumber)
    patientNumber = {num2str(patientNumber)};
end
if ~exist('useDAQ','var')
    yn = questdlg('Send TTLs (DAQ)?','TTLs','Yes, send!','No, just playing','Yes, send!');
    switch yn
        case 'Yes, send!'
            useDAQ = 1;
        case 'No, just playing'
            useDAQ = 0;
    end
end
if ~exist('includeTrainingBlock','var')||isempty(includeTrainingBlock)
    includeTrainingBlock = 1;
end
if ~exist('debug','var')||isempty(debug)
    debug = 0;
end
if ~exist('audioFileExtension','var')||isempty(audioFileExtension)
    audioFileExtension = '.aiff';
elseif ~strcmp(audioFileExtension(1),'.')
    audioFileExtension = ['.',audioFileExtension];
end
if ~exist('nReps','var') || isempty(nReps)
    nReps = 1;
end
if ~exist('maxStims','var') || isempty(maxStims)
    maxStims = inf;
end

if ~exist('audioVisualOrBoth','var') || isempty(audioVisualOrBoth)
    av = questdlg('Which modalities should we use?','Which modality?',...
        'Audio Only','Visual Only','Both Audio and Visual','Visual Only');
    switch av
        case 'Audio Only'
            audioVisualOrBoth = 'audio';
        case 'Visual Only'
            audioVisualOrBoth = 'visual';
        case 'Both Audio and Visual'
            audioVisualOrBoth = 'both';
    end
end

if ~exist('substitutions','var')
    substitutions = [];
end

if ~exist('breakEveryNTrials','var') || isempty(breakEveryNTrials)
    breakEveryNTrials = 40;
end
if ~exist('pathToVideoForTakingABreak','var') || isempty(pathToVideoForTakingABreak)
    yn = questdlg('Would you like to select a video to show at the breaks?','Breaktime Video?',...
        'Use default video','Select new','No video','Use default video');
    switch yn
        case 'Use default video'
            pathToVideoForTakingABreak = {'/Users/NattyBoo/MYLOCALWORKINGCOPY/PARADIGMS/ConceptSyntax/syntax_concepts_single_unit/stimuli/Pt_558/Tangled_Maximus_Best Moments_comp.mp4'};
        case 'Select new'
            disp('Please select the video you would like to play');
            [a,b] = uigetfile('*.mp4');
            pathToVideoForTakingABreak = {fullfile(b,a)};
        case 'No video'
            pathToVideoForTakingABreak = {};
    end
end
if ischar(pathToVideoForTakingABreak)
    pathToVideoForTakingABreak = {pathToVideoForTakingABreak};
end
videoCounter = 1;

switch audioVisualOrBoth
    case {'audio','auditory'}
        doAudioBlock = 1;
        doVisualBlock = 0;
    case 'visual'
        doAudioBlock = 0;
        doVisualBlock = 1;
    case 'both'
        doAudioBlock = 1;
        doVisualBlock = 1;
end

dataDirectory = fullfile(fileparts(fileparts(paradigmFolder)),'data');
stimuliDirectory = fullfile(strrep(dataDirectory,'data','stimuli'),...
    sprintf('Pt_%s',patientNumber{1}));
trainingStimuliDirectory = fullfile(strrep(dataDirectory,'data','stimuli'),...
    'Training');
if ~exist(stimuliDirectory,'dir')
    mkdir(stimuliDirectory);
end
if isempty(dir(fullfile(stimuliDirectory,'*.txt')))
    disp('Please find the list of sentences to read');
    [d, f] = uigetfile;
    copyfile(fullfile(f,d),fullfile(stimuliDirectory,'sentence_stimuli.txt'));
end
if isempty(dir(fullfile(stimuliDirectory,['*',audioFileExtension])))
    disp('creating stimuli files')
    createAudioAndSentenceFiles(stimuliDirectory,'sentence_stimuli.txt',substitutions)
end


%% Start diary and get parameters for this patient

cd(dataDirectory);
ptFolder = [dataDirectory,filesep,'PatientData',filesep,'Pt_',patientNumber{1}];
if ~exist(ptFolder,'dir')
    mkdir(ptFolder)
end
todaysDate = datestr(now,'yyyy_mm_dd_HH_MM','local');
todaysDateStr = ['conceptSyntaxTask_',todaysDate];
diary([ptFolder,filesep,'diary_',todaysDateStr,'.txt']);
ttlSaveName = fullfile(ptFolder,sprintf('ttlLog_%s',todaysDateStr));



%% Start Psych Toolbox
ttlLog = cell(0,3);
[PTBparams,ttlLog] = initializePsychToolBoxForConceptSyntax(useDAQ,ttlLog,debug,patientNumber,0);
ttl = @(message,log)sendTTL_em(message,[],PTBparams.dio,[],toc(PTBparams.timerStart),log);

%% Run in a loop (once for training if requested, once for "real")

if includeTrainingBlock
    testModes = {'training','testing'};
else
    testModes = {'testing'};
end

for t = 1:length(testModes)
    
    currentMode = testModes{t};
    
    %% Load  stimuli
    switch currentMode
        case 'training'
            loadDir = trainingStimuliDirectory;
        case 'testing'
            loadDir = stimuliDirectory;
    end
    
    sentences = load(fullfile(loadDir,'sentencesToShow.mat'));
    sentences = sentences.sentences;
    
    if doAudioBlock
        disp('Loading audio stimuli...')
        stims = dir(fullfile(loadDir,['*',audioFileExtension]));
        stimNums = arrayfun(@(x)str2double(regexp(x.name,'\d*','match','once')),stims);
        [~,ind] = sort(stimNums);
        stims = stims(ind);
        [loadedItems,textures] = loadAudioFiles(PTBparams,loadDir,stims);
        nStims = length(stims);
        stimDurations = cellfun(@(x,f)length(x)/f,loadedItems.sounds,arrayfun(@(x)x,loadedItems.frequency,'uniformoutput',0));
    else
        nStims = length(sentences);
    end
    
    % Load videos for taking a break, but only if we're in the testing mode
    if strcmp(currentMode,'testing') && ~isempty(pathToVideoForTakingABreak)
        disp('Loading video stimuli...')
        failedVideoLoads = false(1,length(pathToVideoForTakingABreak));
        for vid = length(pathToVideoForTakingABreak):-1:1
            if exist(pathToVideoForTakingABreak{vid},'file')
                try
                    [videoInfo(vid).texture, videoInfo(vid).duration] = Screen('OpenMovie', PTBparams.w, pathToVideoForTakingABreak{vid});
                    videoInfo(vid).videoPath = pathToVideoForTakingABreak{vid};
                    [~,videoInfo(vid).videoName] = fileparts(pathToVideoForTakingABreak{vid});
                catch
                    failedVideoLoads(vid) = 1;
                end
            else
                failedVideoLoads(vid) = 1;
            end
        end
        if exist('videoInfo','var') && ~isempty(videoInfo)
            videoInfo(failedVideoLoads) = [];
        else
            videoInfo = [];
        end
    else
        videoInfo = [];
    end
    
    nStimsToUse = min(nStims,maxStims);
    
    %% Run the task
    
    switch currentMode
        case 'training'
            ttlLog = ttl('Begin Training Block',ttlLog);
        case 'testing'
            ttlLog = ttl('Begin Task',ttlLog);
    end
    
    
    try
        if doVisualBlock
            ttlLog = showInstructionSlideTillClick(PTBparams,instructionText('visual'),ttlLog,ttl,[1 1 1]);
            for rep = 1:nReps
                ttlLog = ttl(sprintf('Beginning Visual Block %d',rep),ttlLog);
                thisOrder = randperm(nStims);
                thisOrder = thisOrder(1:nStimsToUse)
                for j = 1:length(thisOrder)
                    s = thisOrder(j);
                    ttlLog = showInstructionSlideForDuration(PTBparams,'+',ttlLog,ttl,1,0);
                    ttlLog = showStimulus(PTBparams,sentences{s},s,ttl,ttlLog);
                    ttlLog = showInstructionSlideForDuration(PTBparams,'+',ttlLog,ttl,1+rand(1)/5);
                    [ttlLog pressedEsc] = showInstructionSlideTillClick(PTBparams,'*',ttlLog,ttl,[101, 252, 108]/255);
                    save(ttlSaveName,'ttlLog');
                    if pressedEsc
                        cleanUpAndEndTask(ttlLog,ttlSaveName);
                        return
                    end
                    if ~mod(j,breakEveryNTrials)
                        if isempty(videoInfo)
                            [ttlLog, videoCounter] = conceptSyntaxOfferABreak(PTBparams,[],ttlLog,ttl,videoCounter,length(videoInfo));
                        else
                            [ttlLog,videoCounter] = conceptSyntaxOfferABreak(PTBparams,videoInfo(videoCounter),ttlLog,ttl,videoCounter,length(videoInfo));
                        end
                    end
                end
            end
            ttlLog = ttl('End Visual Block',ttlLog);
        end
        
        
        if doAudioBlock
            ttlLog = showInstructionSlideTillClick(PTBparams,instructionText('audio'),ttlLog,ttl,[1 1 1]);
            for rep = 1:nReps
                ttlLog = ttl(sprintf('Beginning Audio Block %d',rep),ttlLog);
                thisOrder = randperm(nStims);
                thisOrder = thisOrder(1:nStimsToUse)
                for s = thisOrder
                    ttlLog = showInstructionSlideForDuration(PTBparams,'+',ttlLog,ttl,1,0);
                    ttlLog = playStimulus(sentences{s},stims(s).name,textures.audioHandles{s},stimDurations(s),ttl,ttlLog);
                    ttlLog = showInstructionSlideForDuration(PTBparams,'+',ttlLog,ttl,1+rand(1)/5);
                    [ttlLog pressedEsc] = showInstructionSlideTillClick(PTBparams,'*',ttlLog,ttl,[101, 252, 108]/255);
                    save(ttlSaveName,'ttlLog');
                    if pressedEsc
                        cleanUpAndEndTask(ttlLog,ttlSaveName);
                        return
                    end
                    if ~mod(s,breakEveryNTrials)
                        if isempty(videoInfo)
                            [ttlLog, videoCounter] = conceptSyntaxOfferABreak(PTBparams,[],ttlLog,ttl,videoCounter,length(videoInfo));
                        else
                            [ttlLog, videoCounter] = conceptSyntaxOfferABreak(PTBparams,videoInfo(videoCounter),ttlLog,ttl,videoCounter,length(videoInfo));
                        end
                    end
                end
            end
            ttlLog = ttl('End Audio Block',ttlLog);
        end
        
        
        
        ttlLog = ttl('End of Task',ttlLog);
        
    catch exception
        cleanUpAndEndTask(ttlLog,fullfile(ptFolder,sprintf('ttlLog_emergencySave_%s',todaysDateStr)));
        rethrow(exception)
    end
    
end

cleanUpAndEndTask(ttlLog,ttlSaveName);