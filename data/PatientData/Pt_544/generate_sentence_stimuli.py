#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 18 19:08:19 2021

@author: yl254115
"""

from string import Template

# CONCEPT 1
concepts_1 = ['Yoda', 'the leopard']
concepts_1_hypernyms = [['movie character', 'wise master'], ['dangerous animal', 'safari feline']]

# CONCEPT 2
concepts_2 = ['Bart Simpson', 'Tyrion Lannister']
concepts_2_hypernyms = [['TV cartoon', 'famous character'], ['great star', 'smart dwarf']]

# VERBS
verbs = ['chasing', 'racing', 'kissing', 'hugging']
verbs_matrix = ['is saying', 'is complaining']

conditions = {}
conditions['CE-M+'] = Template(f'$concept1 who $concept2 is $verb is a $concept1_hypernym')
conditions['RB-M+'] = Template(f'$concept1 is the $concept1_hypernym who $concept2 is $verb.')
conditions['CE-M-'] = Template(f'$concept1 who is $verb $concept2 is a $concept1_hypernym.')
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
                sentences.append(sentence)
    return sentences
    

def create_sentences_coref(c1, c2, vs_matrix, vs):
    sentences = []
    for verb_matrix in vs_matrix:
        for verb in vs:
            sentence = conditions['COREF'].substitute(concept1=c1,
                                                      concept2=c2,
                                                      verb_matrix=verb_matrix,
                                                      verb=verb)
            sentence = sentence[0].upper() + sentence[1:]
            sentences.append(sentence)
    return sentences



sentences = []
for i_concept, (concept1, concept2) in enumerate(zip(concepts_1, concepts_2)):
    
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
                                            verbs_matrix,
                                            verbs))
    sentences.extend(create_sentences_coref(concept2,
                                            concept1,
                                            verbs_matrix,
                                            verbs))
    

[print(s) for s in sentences]
with open('../../stimuli/sentence_stimuli.txt', 'w') as f:
    for i, s in enumerate(sentences):
        f.write(f'{i+1},{s}\n')

            
    
