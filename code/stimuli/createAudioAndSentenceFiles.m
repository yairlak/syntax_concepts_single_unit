function createAudioAndSentenceFiles(dirName,fileNameOrSentenceList,substitutions)
% substitutions are places where the computer pronounces badly. Should by a
% cell array in which the first of each pair is the correct spelling, and
% the second of each pair is a version the computer pronounces well.
% For example:
% substitutions = {'Arya Stark', 'Aria Stark', 'Princess Leia', 'Princess Laya', 'Hermione Granger', 'Hermyonee Granger'};

if ~exist('substitutions','var')
    substitutions = [];
end

if ischar(fileNameOrSentenceList)
    % then we passed in a file that was created externally of sentences to
    % read.
    fileName = fileNameOrSentenceList;
    readOrWrite = 'read';
else
    % then we passed in a cell array of sentences
    fileName = 'sentence_stimuli.txt';
    sentences = fileNameOrSentenceList;
    readOrWrite = 'write';
end

switch readOrWrite
    case 'read'
        % read the list of sentences
        nextLine = cell(200,1); count = 1;
        fid = fopen(fullfile(dirName,fileName));
        while ~feof(fid)
            nextLine{count} = fgetl(fid);
            count = count+1;
        end
        if count < length(nextLine)
            nextLine(count:end) = [];
        end
        fclose(fid);
        
        sentences = cellfun(@(x)regexprep(x,'^\d*\,',''),nextLine,'uniformoutput',0);
    case 'write'
        fid = fopen(fullfile(dirName,fileName),'w');
        for a = 1:length(sentences)
            fprintf(fid,'%d,%s\n',a,sentences{a});
        end
        fclose(fid);
end
        
% generate sentences with substituted strings that may be pronounced better
% by the computer audio.
subSentences = sentences;

for i = 1:2:length(substitutions)
subSentences = cellfun(@(x)strrep(x,substitutions{i},substitutions{i+1}),subSentences,'uniformoutput',0);
end
    

%% inline functions used to save the audio 
thisPath = @(str,ind)fullfile(dirName,[num2str(ind),'.aiff']);
% saveThis = @(str,ind)system(sprintf('say -v Victoria "%s" -o %s -r 200',str,thisPath(str,ind)));
saveThis = @(str,ind)system(sprintf('say -v Fiona "%s" -o %s -r 145',str,thisPath(str,ind)));

% save the audio files
for i = 1:length(sentences)
saveThis(subSentences{i},i);
end

% save the .mat file
save(fullfile(dirName,'sentencesToShow'),'sentences');


