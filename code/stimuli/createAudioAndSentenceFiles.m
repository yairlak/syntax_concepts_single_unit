function createAudioAndSentenceFiles(dirName,fileName,substitutions)

if ~exist('substitutions','var')
    substitutions = [];
end

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
subSentences = sentences;

for i = 1:2:length(substitutions)
subSentences = cellfun(@(x)strrep(x,substitutions{i},substitutions{i+1}),subSentences,'uniformoutput',0);
end
    

%% inline functions used to save the audio 
thisPath = @(str,ind)fullfile(dirName,[num2str(ind),'.aiff']);
% saveThis = @(str,ind)system(sprintf('say -v Victoria "%s" -o %s -r 200',str,thisPath(str,ind)));
saveThis = @(str,ind)system(sprintf('say -v Fiona "%s" -o %s -r 145',str,thisPath(str,ind)));

for i = 1:length(sentences)
saveThis(subSentences{i},i);
end

save(fullfile(dirName,'sentencesToShow'),'sentences');


