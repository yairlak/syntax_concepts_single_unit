def comparison_list():
    comparisons = {}
    
# ALL WORDS
    comparisons['all_trials'] = {}
    comparisons['all_trials']['queries'] = ['has_CE==1 and has_movement==1 and COREF==0',
                                            'has_CE==1 and has_movement==0 and COREF==0',
                                            'has_CE==0 and has_movement==1 and COREF==0',
                                            'has_CE==0 and has_movement==0 and COREF==0',
                                            'COREF==1']
    comparisons['all_trials']['fixed_constraint'] = 'sentence_onset == 1'
    comparisons['all_trials']['condition_names'] = ['CE-M+',
                                                    'CE-M-',
                                                    'RB-M+',
                                                    'RB-M-',
                                                    'COREF'] 
    comparisons['all_trials']['colors'] = ['r', 'r', 'g', 'g', 'b']
    comparisons['all_trials']['ls'] = ['-', '--', '-', '--', '-']
    comparisons['all_trials']['sort'] = ['sentence_string']
    comparisons['all_trials']['y-tick-step'] = 4
    comparisons['all_trials']['level'] = 'sentence_onset'
    comparisons['all_trials']['tmin_tmax'] = [-0.5, 10]

    
    comparisons['all_end_trials'] = {}
    comparisons['all_end_trials']['queries'] = ['has_CE==1 and has_movement==1 and COREF==0',
                                            'has_CE==1 and has_movement==0 and COREF==0',
                                            'has_CE==0 and has_movement==1 and COREF==0',
                                            'has_CE==0 and has_movement==0 and COREF==0',
                                            'COREF==1']
    comparisons['all_end_trials']['fixed_constraint'] = 'sentence_offset == 1'
    comparisons['all_end_trials']['condition_names'] = ['CE-M+',
                                                    'CE-M-',
                                                    'RB-M+',
                                                    'RB-M-',
                                                    'COREF'] 
    comparisons['all_end_trials']['colors'] = ['r', 'r', 'g', 'g', 'b']
    comparisons['all_end_trials']['ls'] = ['-', '--', '-', '--', '-']
    comparisons['all_end_trials']['sort'] = ['sentence_string']
    comparisons['all_end_trials']['y-tick-step'] = 4
    comparisons['all_end_trials']['level'] = 'sentence_onset'
    comparisons['all_end_trials']['tmin_tmax'] = [-5, 3]

    return comparisons
