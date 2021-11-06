#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Nov  5 11:37:29 2021

@author: yl254115
"""
import os
import glob
import scipy.io as sio
import pandas as pd




class Metadata:
    def __init__(self, patient, input_format, modality, time0):
        assert isinstance(patient, str)
        self.patient = patient
        self.input_format = input_format
        self.time0 = time0
        self.modality = modality
        

    def create_metadata(self, verbose=False):
        if verbose:
            print('Preparing metadata from logs...')
        path2log = os.path.join('..', '..', 'data', self.patient, 'logs')
        
        
        if self.input_format == 'mat':
            fn_log = glob.glob(os.path.join(path2log,
                                            'TTLs_ConceptSyntax*.mat'))
            assert len(fn_log) == 1
            fn_log = fn_log[0]
            log_content = sio.loadmat(fn_log)
            event_time = [t[0][0]-self.time0 for t in log_content['TTLs'][:, 0]]
            event_str = [s[0] for s in log_content['TTLs'][:, 1]]
            metadata = pd.DataFrame({'event_time':event_time,
                                     'event_str':event_str})
            
            metadata.sort_values(by='event_time')
            
            # ADD COLUMNS
            self.metadata = add_columns(metadata, self.modality)
            

def find_center_embedding(row):
        if row['sentence_string']:
            if "is a " in row['sentence_string']:
                return 1
            else:
                return 0
        else:
            return 0
    

def find_movement(row):
    if row['sentence_string']:
        if ' that ' not in row['sentence_string'] and \
            ' who is ' not in row['sentence_string']:
            return 1
        else:
            return 0


def find_coreference(row):
    if row['sentence_string']:
        if " that " in row['sentence_string']:
            return 1
        else:
            return 0
    else:
        return 0
    

def find_sentence_onset(row, modality):
        if modality == 'visual':
            test_str = 'Begin Sentence '
        elif modality == 'auditory':
            test_str = 'Playing'
            
        if row['event_str'].startswith(test_str):
            return 1
        else:
            return 0
    

def find_sentence_offset(row):
        if row['event_str'].startswith('End of Sentence'):
            return 1
        else:
            return 0
    

def find_sentence_offset_auditory(event_str):
    offset, sentence_string = [], []
    for i, curr_str in enumerate(event_str.values):
        if curr_str.startswith('Playing'):
            offset.append(0)
            IX_st = curr_str.find('(') + 1
            IX_ed = curr_str.find(')')
            sentence_string.append(curr_str[IX_st:IX_ed])
        elif curr_str == 'Instructions: +' and \
            event_str[i-1].startswith('Playing'):
                offset.append(1)
                IX_st = event_str[i-1].find('(') + 1
                IX_ed = event_str[i-1].find(')')
                sentence_string.append(event_str[i-1][IX_st:IX_ed])
        else:
            offset.append(0)
            sentence_string.append(None)
    return offset, sentence_string


def find_repeat_cue(row):
    if row['event_str'].startswith('Instructions: *'):
        return 1
    else:
        return 0


def find_sentence_string(row, modality):
    if modality == 'visual':
        if row['event_str'].startswith('Begin Sentence '):
            return row['event_str'].split(":")[1]
        else:
            return None
    elif modality == 'auditory':
        if row['event_str'].startswith('Playing'):
            IX_st = row['event_str'].find('(') + 1
            IX_ed = row['event_str'].find(')')
            return row['event_str'][IX_st:IX_ed]
        else:
            return None
        
    
def add_columns(metadata, modality):
    metadata['sentence_onset'] = metadata.apply(lambda row: 
                                                find_sentence_onset(row,
                                                                    modality),
                                                axis=1)
    metadata['repeat_cue'] = metadata.apply(lambda row: 
                                            find_repeat_cue(row),
                                            axis=1)
        
    if modality == 'visual':
        metadata['sentence_offset'] = metadata.apply(lambda row: 
                                                    find_sentence_offset(row),
                                                    axis=1)
        metadata['sentence_string'] = metadata.apply(lambda row: 
                                                 find_sentence_string(row,
                                                                      modality),
                                                 axis=1)
    
    elif modality == 'auditory':
        metadata['sentence_offset'], metadata['sentence_string'] \
        = find_sentence_offset_auditory(metadata['event_str'])
        

    metadata['has_CE'] = metadata.apply(lambda row: 
                                        find_center_embedding(row),
                                        axis=1)
    metadata['has_movement'] = metadata.apply(lambda row: 
                                              find_movement(row),
                                              axis=1)
    metadata['COREF'] = metadata.apply(lambda row: 
                                       find_coreference(row),
                                       axis=1)
    return metadata