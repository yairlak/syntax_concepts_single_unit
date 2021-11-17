function s = generateSentencesFromConceptWords(str)
c1_name = str.c1_name;
c1_gender = str.c1_gender;
c1_description1 = str.c1_description1;
c1_description2 = str.c1_description2;
c2_name = str.c2_name;
c2_gender = str.c2_gender;
c2_description1 = str.c2_description1;
c2_description2 = str.c2_description2;
verbs = str.verbs;
verbClauses = str.verbClauses;

% I tried to write this just to call Yair's python script, but it was too
% complicated to figure out, since I couldn't get Matlab to find python3.
% So I just wrote it from scratch below...
%
% commandString = sprintf(['python3 generate_sentence_stimuli.py ',...
%     '--concept1 "%s" --concept1-gender %s --concept1-description "%s" "%s" ',...
%     '--concept2 "%s" --concept2-gender %s --concept2-description "%s" "%s" ',...
%     '--verbs "%s" "%s" --verbs-clause "%s" "%s"'],...
%     c1_name,c1_gender,c1_description1,c1_description2,...
%     c2_name,c2_gender,c2_description1,c2_description2,...
%     v1,v2,vc1,vc2);
% system(commandString)
%
% This was a line suggested in the python3 description, but I didn't know
% what to put in <your script here>...
% cd '' && '/usr/local/bin/python3'  '<your script here>'  && echo Exit status: $? && exit 1


sentenceFormat1 = @(name1,name2,verb,desc)sprintf('%s who %s is %s is a %s',name1,name2,verb,desc);
sentenceFormat2 = @(name1,name2,verb,desc)sprintf('%s is the %s who %s is %s',name1, desc, name2, verb);
sentenceFormat3 = @(name1,name2,verb,desc)sprintf('%s who is %s %s is a %s',name1,verb,name2,desc);
sentenceFormat4 = @(name1,name2,verb,desc)sprintf('%s is the %s who is %s %s',name1,desc,verb,name2);

sentenceFormat5 = @(name1,name2,verb,verbclause,gender1)sprintf('%s %s that %s is %s %s',name1,verbclause,name2,verb,gender1);

% sentenceFormat5 is sufficiently different that we will add it separately
% at the end
generateSentences = @(name1,name2,verb,desc)cellfun(@(x)feval(x,name1,name2,verb,desc),{sentenceFormat1,sentenceFormat2,sentenceFormat3,sentenceFormat4},'uniformoutput',0);

s = cell(200,1);
counter = 0;
for v = 1:length(verbs)
    s(counter+(1:4)) = generateSentences(c1_name,c2_name,verbs{v},c1_description1);
    s(counter+(5:8)) = generateSentences(c1_name,c2_name,verbs{v},c1_description2);
    s(counter+(9:12)) = generateSentences(c2_name,c1_name,verbs{v},c2_description1);
    s(counter+(13:16)) = generateSentences(c2_name,c1_name,verbs{v},c2_description2);
    counter = counter+16;
    for vc = 1:length(verbClauses)
        s{counter+1} = sentenceFormat5(c1_name,c2_name,verbs{v},verbClauses{vc},c1_gender);
        s{counter+2} = sentenceFormat5(c2_name,c1_name,verbs{v},verbClauses{vc},c2_gender);
        counter = counter+2;
    end
end
s(counter+1:end) = [];
