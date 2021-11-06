#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Nov  5 11:31:43 2021

@author: yl254115
"""

import os
import argparse
from utils import metadata
from utils.data_manip import get_time0_timeend

abspath = os.path.abspath(__file__)
dname = os.path.dirname(abspath)
os.chdir(dname)

parser = argparse.ArgumentParser()
parser.add_argument('--patient', default='544', help='Patient number')
parser.add_argument('--input-format', choices=['txt', 'mat'], default='mat',
                    help='Format of file with synced time stamps')
parser.add_argument('--modality', choices=['visual', 'auditory'],
                    default='auditory',
                    help='Format of file with synced time stamps')
args = parser.parse_args()
args.patient = 'patient_' + args.patient
print(args)

time0, _ = get_time0_timeend(path2data=f'../../data/{args.patient}/raw/micro')
metadata = metadata.Metadata(args.patient,
                             args.input_format,
                             args.modality,
                             time0)
metadata.create_metadata()

# SAVE
path2mne = f'../../data/{args.patient}/raw/mne'
metadata.metadata.to_csv(os.path.join(path2mne, 'metadata.csv'))

