#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Oct 18 19:08:19 2021

@author: yl254115
"""

import argparse
from string import Template


parser = argparse.ArgumentParser()
# CONCEPT 1
parser.add_argument('--concept1', default=[], action='append',
                    help='e.g., Jennifer Aniston')
parser.add_argument('--concept1-gender', default=[], action='append',
                    choices=['feminine', 'masculine'])
parser.add_argument('--concept1-descriptions', default=[], action='append',
                    nargs='*',
                    help='two-words description, e.g., Famous actress')
# CONCEPT 2
parser.add_argument('--concept2', default=[], action='append',
                    help='e.g., Barak Obahama')
parser.add_argument('--concept2-gender', default=[], action='append',
                    choices=['feminine', 'masculine'])
parser.add_argument('--concept2-descriptions', default=[], action='append', 
                    nargs='*',
                    help='e.g., past president')
# VERBS
parser.add_argument('--verbs', default=[], nargs="*")
#                    default=['chasing', 'racing', 'kissing', 'hugging'])
parser.add_argument('--verbs-clause', default=[], nargs="*")
#                    default=['is saying', 'is complaining'])
args = parser.parse_args()

print(args)

# CONCEPT 1
concepts_1 = args.concept1
concept_1_genders = args.concept1_gender
concepts_1_descriptions = args.concept1_descriptions

# CONCEPT 2
concepts_2 = args.concept2
concept_2_genders = args.concept2_gender
concepts_2_descriptions = args.concept2_descriptions


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
            else:
                sentence = sentence + '.'
            sentences.append(sentence)
    return sentences



sentences = []
for i_concept, (concept1, concept2, concept_1_gender, concept_2_gender) in enumerate(zip(concepts_1, concepts_2, concept_1_genders, concept_2_genders)):
    
    sentences.extend(create_sentences_2by2(concept1,
                                           concepts_1_descriptions[i_concept],
                                           concept2,
                                           args.verbs))
    sentences.extend(create_sentences_2by2(concept2,
                                           concepts_2_descriptions[i_concept],
                                           concept1,
                                           args.verbs))
    
    sentences.extend(create_sentences_coref(concept1,
                                            concept2,
                                            concept_1_gender,
                                            args.verbs_clause,
                                            args.verbs))
    sentences.extend(create_sentences_coref(concept2,
                                            concept1,
                                            concept_2_gender,
                                            args.verbs_clause,
                                            args.verbs))
    

[print(s) for s in sentences]
with open('../../stimuli/sentence_stimuli.txt', 'w') as f:
    for i, s in enumerate(sentences):
        f.write(f'{i+1},{s}\n')

print('-' * 80)
print(f'Total number of sentences: {len(sentences)}')
