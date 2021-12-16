function prepConceptSyntax(pt)
csLoc = which('conceptSyntax');
csSuperDir = fileparts(fileparts(csLoc));
addpath(genpath(csSuperDir));

stimuliDir = fullfile(strrep(csSuperDir,'code','stimuli'),sprintf('Pt_%d',pt));
createNew = 1;
if ~exist(stimuliDir,'dir')
mkdir(stimuliDir);
else
    if exist(fullfile(stimuliDir,'sentence_stimuli.txt'),'file')
        whatToDo = questdlg('There is already a sentence_stimuli text document in this folder. Do you want to use that or create a new one?',...
            'Overwrite?','Use existing','Create new','Use existing');
        switch whatToDo
            case 'Use existing'
                if ~isempty(dir(fullfile(stimuliDir,'*.aiff')))
                    fprintf('\n\nThere are already audio files in this folder. I assume they are current and am aborting here... If they are not the right files, please delete them and try again!\n\n')
                    return
                else
                    nextLine = cell(200,1); count = 1;
                    fid = fopen(fullfile(stimuliDir,'sentence_stimuli.txt'));
                    while ~feof(fid)
                        nextLine{count} = fgetl(fid);
                        count = count+1;
                    end
                    if count < length(nextLine)
                        nextLine(count:end) = [];
                    end
                    fclose(fid);
                    names = unique(cellfun(@(x)regexp(x,'(?<=\d*\,)(\w|\s)*?(?=\s(who|is))','match','once'),nextLine,'uniformoutput',0));
                    createNew = 0;
                end
            case 'Create new'
                % nothing to do here, because we already set creatNew to
                % true;
        end
    end
end

%% get user input for concepts and create the sentence list
if createNew
nPairs = inputdlg('How many concept pairs would you like to include?','Number of Pairs?',1,{'2'});
nPairs = eval(nPairs{1}); assert(isnumeric(nPairs),'Please enter a number for the number of pairs!');
for p = 1:nPairs
    thesePairs(p) = getPairInfo(p);
    s{p} = generateSentencesFromConceptWords(thesePairs(p));
end
s = cat(1,s{:});
names = [{thesePairs.c1_name},{thesePairs.c2_name}];
end

%% Listen to the names given and determine if any substitutions are necessary
substitutions = getSubstitutions(names);

%% Create the audio files
createAudioAndSentenceFiles(stimuliDir,s,substitutions)







function str = getPairInfo(pairNum)
%%
f = figure('name',sprintf('Pair %d',pairNum));

pvPanel = makePosVecFunction(7,2);
pv = makePosVecFunction(4,1);
pvBG = makePosVecFunction(1,3);
pvFull = makePosVecFunction(1,1);
for p = 1:2
    pan(p) = uipanel(f,'title',sprintf('Concept %d',p),'units','normalized','position',pvPanel(p,1,4,4),'fontsize',14);
    concept_name(p) = uicontrol('parent',pan(p),'units','normalized','position',pv(1,1,1,1),'style','edit','string','Enter Name');
    concept_desc1(p) = uicontrol('parent',pan(p),'units','normalized','position',pv(1,1,2,1),'style','edit','string','First Two-Word Descriptor');
    concept_desc2(p) = uicontrol('parent',pan(p),'units','normalized','position',pv(1,1,3,1),'style','edit','string','Second Two-Word Descriptor');
    concept_gender(p) = uibuttongroup('parent',pan(p),'units','normalized','position',pv(1,1,4,1),'title','gender');
    uicontrol(concept_gender(p),'units','normalized','position',pvBG(1,1,1,1),'style','radiobutton','string','him');
    uicontrol(concept_gender(p),'units','normalized','position',pvBG(2,1,1,1),'style','radiobutton','string','her');
    uicontrol(concept_gender(p),'units','normalized','position',pvBG(3,1,1,1),'style','radiobutton','string','it');
end
vPanel = uipanel(f,'title','Verb List (comma separated)','units','normalized','position',pvPanel(1,2,5,1),'fontsize',14);
vList = uicontrol(vPanel,'units','normalized','position',pvFull(1,1,1,1),'style','edit','string','racing, watching, texting, admiring');
vcPanel = uipanel(f,'title','Verb Clause List (comma separated)','units','normalized','position',pvPanel(1,2,6,1),'fontsize',14);
vcList = uicontrol(vcPanel,'units','normalized','position',pvFull(1,1,1,1),'style','edit','string','is saying, is complaining');

submitButton = uicontrol(f,'units','normalized','position',pvPanel(2.5,.5,7,1),'String','Submit','Callback',@submit);
uiwait(f);
str = struct('c1_name','','c1_gender','','c1_description1','','c1_description2','',...
    'c2_name','','c2_gender','','c2_description1','','c2_description2','',...
    'v1','','v2','','vc1','','vc2','');
str.c1_name = concept_name(1).String;
str.c1_gender = concept_gender(1).SelectedObject.String;
str.c1_description1 = lower(concept_desc1(1).String);
str.c1_description2 = lower(concept_desc2(1).String);
str.c2_name = concept_name(2).String;
str.c2_gender = concept_gender(2).SelectedObject.String;
str.c2_description1 = lower(concept_desc1(2).String);
str.c2_description2 = lower(concept_desc2(2).String);
str.verbs = regexp(vList.String,'\w*','match');
str.verbClauses = regexp(vcList.String,'is \w*','match');

function submit(varargin)
uiresume(varargin{1}.Parent)


function subs = getSubstitutions(names)
%%

nRows = length(names)+2;
nCols = 9;
pv = makePosVecFunction(nRows,nCols);
f = figure;
uicontrol('parent',f,'units','normalized','position',pv(1,nCols,1,1),'style','text',...
    'string','Please listen to the computer audio for each name. If it''s not understandable, try entering alternate spellings in the text box until you find an acceptable pronunciation.');
for n = 1:length(names)
    uicontrol('parent',f,'units','normalized','position',pv(1,4,n+1,1),'style','text','string',names{n});
    subString{n} = uicontrol('parent',f,'units','normalized','position',pv(5,4,n+1,1),'style','edit','string',names{n});
    uicontrol('parent',f,'units','normalized','position',pv(9,1,n+1,1),'style','pushbutton','string','Play','callback',{@sayThis,subString{n}});
end
submitButton = uicontrol(f,'units','normalized','position',pv(8,2,n+2,1),'String','Submit','Callback',@submit);
uiwait(f);

subs = cell(1,2*length(names));
subs(1:2:end) = names;
subs(2:2:end) = cellfun(@(x)x.String,subString,'uniformoutput',0);

for k = length(subs):-2:2
    if strcmp(subs{k},subs{k-1})
        subs(k-1:k) = [];
    end
end
close(f);


function sayThis(dummy1,dummy2,cntrl)
str = cntrl.String;
system(sprintf('say -v Fiona "%s" -r 145',str));