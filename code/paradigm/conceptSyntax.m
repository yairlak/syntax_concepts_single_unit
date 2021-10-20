function conceptSyntax(patientNumber,useDAQ,debug,audioFileExtension,nReps)

paradigmFolder = fileparts(which('conceptSyntax.m'));
addpath(paradigmFolder);

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
if ~exist('debugMode','var')||isempty(debugMode)
    debugMode = 0;
end
if ~exist('stimuliExtension','var')||isempty(audioFileExtension)
    audioFileExtension = '.wav';
elseif ~strcmp(audioFileExtension(1),'.')
    audioFileExtension = ['.',audioFileExtension];
end
if ~exist('nReps','var') || isempty(nReps)
    nReps = 1;
end


dataDirectory = fullfile(fileparts(fileparts(paradigmFolder)),'data');
stimuliDirectory = fullfile(strrep(dataDirectory,'data','stimuli'),'audio',...
    sprintf('Pt_%s',patientNumber{1}));
if ~exist(stimuliDirectory,'dir')
    mkdir(stimuliDirectory);
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




%% Start Psych Toolbox
ttlLog = cell(0,3);
[PTBparams,ttlLog] = initializePsychToolBoxForConceptSyntax(useDAQ,ttlLog,debug,patientNumber,0);


%% Load audio stimuli
disp('Loading audio stimuli...')
stims = dir(fullfile(stimuliDirectory,['*',audioFileExtension]));
[loadedItems,textures] = loadAudioFiles(PTBparams,stimuliDirectory,stims);

%% Run the task

ttl = @(message,log)sendTTL_em(message,[],PTBparams.dio,[],toc(PTBparams.timerStart),log);
ttlLog = ttl('Begin Task',ttlLog);

nStims = length(stims);
stimDurations = cellfun(@(x,f)length(x)/f,loadedItems.sounds,arrayfun(@(x)x,loadedItems.frequency,'uniformoutput',0));

try

for rep = 1:nReps
    thisOrder = randperm(nStims)
    for s = thisOrder
        ttlLog = playStimulus(stims(s).name,textures.audioHandles{s},stimDurations(s),ttl,ttlLog);
        ttlLog = showInstructionSlideForDuration(PTBparams,'WAIT....',ttlLog,ttl,1+rand(1)/5);
        [ttlLog pressedEsc] = showInstructionSlideTillClick(PTBparams,'Repeat the sentence',ttlLog,ttl);
        if pressedEsc
            cleanUpAndEndTask(ttlLog,fullfile(ptFolder,sprintf('ttlLog_%s',todaysDateStr)));
            return
        end
    end
end

cleanUpAndEndTask(ttlLog,fullfile(ptFolder,sprintf('ttlLog_%s',todaysDateStr)));

catch exception
    cleanUpAndEndTask(ttlLog,fullfile(ptFolder,sprintf('ttlLog_emergencySave_%s',todaysDateStr)));
    rethrow(exception)
end



