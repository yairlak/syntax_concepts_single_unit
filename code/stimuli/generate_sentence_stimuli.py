#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 18 19:08:19 2021

@author: yl254115
"""

from string import Template

# CONCEPT 1
concepts_1 = ['Princess Leia', 'Homer Simpson']
concept_1_genders = ['feminine', 'masculine']
concepts_1_hypernyms = [['movie character', 'beautiful warrior'], ['yellow cartoon', 'goofy dad']]

# CONCEPT 2
concepts_2 = ['Yoda', 'Arya Stark']
concept_2_genders = ['masculine', 'feminine']
concepts_2_hypernyms = [['green creature', 'wise master'], ['brave girl', 'skilled fighter']]

# VERBS
verbs = ['chasing', 'racing', 'kissing', 'hugging']
verbs_matrix = ['is saying', 'is complaining']

conditions = {}
conditions['CE-M+'] = Template(f'$concept1 who $concept2 is $verb is a $concept1_hypernym')
conditions['RB-M+'] = Template(f'$concept1 is the $concept1_hypernym who $concept2 is $verb')
conditions['CE-M-'] = Template(f'$concept1 who is $verb $concept2 is a $concept1_hypernym')
conditions['RB-M-'] = Template(f'$concept1 is the $concept1_hypernym who is $verb $concept2')
conditions['COREF'] = Template(f'$concept1 $verb_matrix that $concept2 is $verb him')


def create_sentences_2by2(c1, c1_hypernyms, c2, vs):
    sentences = []
    for verb in vs:
        for c1_hypernym in c1_hypernyms:
            keys = list(conditions.keys())
            keys.remove('COREF')
            for condition in keys:
                sentence = conditions[condition].substitute(concept1=c1,
                                                            concept2=c2,
                                                            concept1_hypernym=c1_hypernym,
                                                            verb=verb)
                sentence = sentence[0].upper() + sentence[1:]
                sentence = sentence + '.'
                sentences.append(sentence)
    return sentences
    

def create_sentences_coref(c1, c2, concept_1_gender, vs_matrix, vs):
    sentences = []
    for verb_matrix in vs_matrix:
        for verb in vs:
            sentence = conditions['COREF'].substitute(concept1=c1,
                                                      concept2=c2,
                                                      verb_matrix=verb_matrix,
                                                      verb=verb)
            sentence = sentence[0].upper() + sentence[1:]
            if concept_1_gender == 'feminine':
                words = sentence.split()
                words[-1] = 'her'
                sentence = ' '.join(words)
                sentence = sentence + '.'

            sentences.append(sentence)
    return sentences



sentences = []
for i_concept, (concept1, concept2, concept_1_gender, concept_2_gender) in enumerate(zip(concepts_1, concepts_2, concept_1_genders, concept_2_genders)):
    
    sentences.extend(create_sentences_2by2(concept1,
                                           concepts_1_hypernyms[i_concept],
                                           concept2,
                                           verbs))
    sentences.extend(create_sentences_2by2(concept2,
                                           concepts_2_hypernyms[i_concept],
                                           concept1,
                                           verbs))
    
    sentences.extend(create_sentences_coref(concept1,
                                            concept2,
                                            concept_1_gender,
                                            verbs_matrix,
                                            verbs))
    sentences.extend(create_sentences_coref(concept2,
                                            concept1,
                                            concept_2_gender,
                                            verbs_matrix,
                                            verbs))
    

[print(s) for s in sentences]
with open('../../stimuli/sentence_stimuli.txt', 'w') as f:
    for i, s in enumerate(sentences):
        f.write(f'{i+1},{s}\n')

            
    
