#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jan 15 13:24:59 2021

@author: czacharo
"""
# =============================================================================
# IMPORT MODULES
# =============================================================================
import os
import pandas as pd
# pip install google-cloud-texttospeech
from google.cloud import texttospeech

# =============================================================================
# ADD CREDENTIALS

# =============================================================================
os.environ["GOOGLE_APPLICATION_CREDENTIALS"] = os.path.join(
    os.getcwd(), 'inspiring-ring-329422-d6ac626320e3.json')




# =============================================================================
# SYNTHETIZE AUDIO FROM TEXT
# =============================================================================

def text_to_wav(voice_name, params, text):

    language_code = "-".join(voice_name.split("-")[:2])
    text_input = texttospeech.SynthesisInput(text=text)

    voice_params = texttospeech.VoiceSelectionParams(
        language_code=language_code, name=voice_name,
    )
    audio_config = texttospeech.AudioConfig(
        audio_encoding=texttospeech.AudioEncoding.LINEAR16,
        pitch=params['pitch'],
        speaking_rate=params['speaking_rate'],
        sample_rate_hertz=44100,

    )
    client = texttospeech.TextToSpeechClient()
    response = client.synthesize_speech(
        input=text_input,
        voice=voice_params,
        audio_config=audio_config
    )

    return response

# =============================================================================
# WRAP UP
# =============================================================================
# load stimuli
voice = "en-US-Wavenet-F"  # french: "fr-FR-Wavenet-E"
params = {}
params['pitch'] = 1.2
params['speaking_rate'] = 0.93
block_names = ['LocalGlobal2', 'LocalGlobal4']

sentences = open('../../stimuli/sentence_stimuli.txt', 'r').readlines()
stimulus_numbers = [int(s.split(',')[0]) for s in sentences]
sentences = [s.split(',')[1].strip('\n') for s in sentences]

for s_number, sentence in zip(stimulus_numbers, sentences):
    response = text_to_wav(voice, params, sentence)
    # store the .wav files
    wav_filename = f'../../stimuli/audio/{s_number}.wav'
    with open(wav_filename, "wb") as out:
        out.write(response.audio_content)
        print(f'Audio content written to "{wav_filename}"')