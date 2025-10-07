# importing required modules
# -------------------------------------------------------------------------------------------------------------------
from py_common import *

# function that flattens out everything into uvm_test map
# -------------------------------------------------------------------------------------------------------------------
def generate_uvm_test_map(tlist_dict, verbosity=0):
    tests   = list(tlist_dict['testlist'].keys())
    tests.sort()
    
    test_cnt        =  0
    uvm_test_map    = {}
    orig_total_cnt  =  0
    orig_utest_cnt  = {}
    orig_label_cnt  = {}
    orig_config_cnt = {}
    
    for test in tests:
        test_cnt   = test_cnt + 1
        utest_name = tlist_dict['testlist'][test]['name']
    
        # gathering labels, plusargs, iter values from test
        # ---------------------------------------------------------------------------------------------------------------
        utest_labels = ['__%s__' %(test)]
        if('label' in tlist_dict['testlist'][test]):
            utest_labels.append(tlist_dict['testlist'][test]['label'])
    
        utest_plusargs = {}
        if('plusargs' in tlist_dict['testlist'][test]):
            utest_plusargs = tlist_dict['testlist'][test]['plusargs']
    
        utest_iter = 1
        if('iter' in tlist_dict['testlist'][test]):
            if(tlist_dict['testlist'][test]['iter']):
                utest_iter = tlist_dict['testlist'][test]['iter']
    
        # extracting flavor details
        # ---------------------------------------------------------------------------------------------------------------
        utest_flv = {}
        if('flavors' in tlist_dict['testlist'][test]):
            if(tlist_dict['testlist'][test]['flavors']):
                for flv in tlist_dict['testlist'][test]['flavors'].keys():
                    utest_flv[flv]         = {}
                    utest_flv[flv]['iter'] = utest_iter
                    if('iter' in tlist_dict['testlist'][test]['flavors'][flv]):
                        if(tlist_dict['testlist'][test]['flavors'][flv]['iter']):
                            utest_flv[flv]['iter'] = tlist_dict['testlist'][test]['flavors'][flv]['iter']
    
                    utest_flv[flv]['label'] = []
                    if('label' in tlist_dict['testlist'][test]['flavors'][flv]):
                        if(tlist_dict['testlist'][test]['flavors'][flv]['label']):
                            utest_flv[flv]['label'] = tlist_dict['testlist'][test]['flavors'][flv]['label']
    
                    utest_flv[flv]['config'] = {}
                    if('config' in tlist_dict['testlist'][test]['flavors'][flv]):
                        if(tlist_dict['testlist'][test]['flavors'][flv]['config']):
                            utest_flv[flv]['config'] = tlist_dict['testlist'][test]['flavors'][flv]['config']
    
                    utest_flv[flv]['plusargs'] = {}
                    if('plusargs' in tlist_dict['testlist'][test]['flavors'][flv]):
                        if(tlist_dict['testlist'][test]['flavors'][flv]['plusargs']):
                            utest_flv[flv]['plusargs'] = tlist_dict['testlist'][test]['flavors'][flv]['plusargs']
        else:
            utest_flv['default']             = {}
            utest_flv['default']['iter'    ] = utest_iter
            utest_flv['default']['label'   ] = {}
            utest_flv['default']['config'  ] = {}
            utest_flv['default']['plusargs'] = utest_plusargs
    
        # extracting labels, plusargs, iter values from config and config-flavor space
        # ---------------------------------------------------------------------------------------------------------------
        utest_cfgs         = []
        utest_cfg_iter     = {}
        utest_cfg_plusargs = {}
        if('config' in tlist_dict['testlist'][test]):
            if(type(tlist_dict['testlist'][test]['config']) is dict):
                utest_cfgs = list(tlist_dict['testlist'][test]['config'].keys())
    
                for cfg in utest_cfgs:
                    utest_cfg_iter[cfg]     = {}
                    utest_cfg_plusargs[cfg] = {}
    
                    for flv in utest_flv.keys():
                        test_flv = '%s :: %s' %(test, flv)
                        utest_labels.append(utest_flv[flv]['label'])
    
                        # populating the local config for that flavor
                        # -----------------------------------------------------------------------------------------------
                        for fcfg in utest_flv[flv]['config']:
                            utest_cfg_plusargs[fcfg][test_flv] = utest_flv[flv]['plusargs']
                            utest_cfg_iter[fcfg][test_flv]     = utest_flv[flv]['iter']
    
                        # populating the common config definition with flavors
                        # -----------------------------------------------------------------------------------------------
                        utest_cfg_plusargs[cfg][test_flv] = utest_flv[flv]['plusargs']
                        if('plusargs' in tlist_dict['testlist'][test]['config'][cfg]):
                            if(tlist_dict['testlist'][test]['config'][cfg]['plusargs']):
                                for arg in tlist_dict['testlist'][test]['config'][cfg]['plusargs'].keys():
                                    utest_cfg_plusargs[cfg][test_flv][arg] = tlist_dict['testlist'][test]['config'][cfg]['plusargs'][arg]
    
                        if('iter' in tlist_dict['testlist'][test]['config'][cfg]):
                            if(tlist_dict['testlist'][test]['config'][cfg]['iter']):
                                utest_cfg_iter[cfg][test_flv] = tlist_dict['testlist'][test]['config'][cfg]['iter']
                            else:
                                utest_cfg_iter[cfg][test_flv] = utest_flv[flv]['iter']
                        else:
                            utest_cfg_iter[cfg][test_flv] = utest_flv[flv]['iter']
    
                        if('label' in tlist_dict['testlist'][test]['config'][cfg]):
                            utest_labels.append(tlist_dict['testlist'][test]['config'][cfg]['label'])
    
                    if('flavors' in tlist_dict['testlist'][test]['config'][cfg]):
                        if(tlist_dict['testlist'][test]['config'][cfg]['flavors']):
                            for flv in tlist_dict['testlist'][test]['config'][cfg]['flavors'].keys():
                                test_flv = '%s >> %s' %(test, flv)
                                if('iter' in tlist_dict['testlist'][test]['config'][cfg]['flavors'][flv]):
                                    if(tlist_dict['testlist'][test]['config'][cfg]['flavors'][flv]['iter']):
                                        utest_cfg_iter[cfg][test_flv] = tlist_dict['testlist'][test]['config'][cfg]['flavors'][flv]['iter']
                                    elif(not flv in utest_flv): 
                                        utest_cfg_iter[cfg][test_flv] = utest_iter
                                elif(not flv in utest_flv): 
                                    utest_cfg_iter[cfg][test_flv] = utest_iter
    
                                if('label' in tlist_dict['testlist'][test]['config'][cfg]['flavors'][flv]):
                                    if(tlist_dict['testlist'][test]['config'][cfg]['flavors'][flv])['label']:
                                        utest_labels.append(tlist_dict['testlist'][test]['config'][cfg]['flavors'][flv]['label'])
    
                                if('plusargs' in tlist_dict['testlist'][test]['config'][cfg]['flavors'][flv]):
                                    if(tlist_dict['testlist'][test]['config'][cfg]['flavors'][flv])['plusargs']:
                                        utest_cfg_plusargs[cfg][test_flv] = tlist_dict['testlist'][test]['config'][cfg]['flavors'][flv]['plusargs']
            else:
                utest_cfgs = tlist_dict['testlist'][test]['config']
                for cfg in utest_cfgs:
                    utest_cfg_iter[cfg]     = {}
                    utest_cfg_plusargs[cfg] = {}
                    for flv in utest_flv.keys():
                        test_flv = '%s :: %s' %(test, flv)
                        utest_labels.append(utest_flv[flv]['label'])
    
                        # populating the local config for that flavor
                        # -----------------------------------------------------------------------------------------------
                        for fcfg in utest_flv[flv]['config']:
                            utest_cfg_plusargs[fcfg][test_flv] = utest_flv[flv]['plusargs']
                            utest_cfg_iter[fcfg][test_flv]     = utest_flv[flv]['iter']
    
                        # populating the common config definition with flavors
                        # -----------------------------------------------------------------------------------------------
                        utest_cfg_plusargs[cfg][test_flv] = utest_flv[flv]['plusargs']
                        utest_cfg_iter[cfg][test_flv]     = utest_flv[flv]['iter']
    
        print_info('[%4d / %4d] processing test/uvm_test pair: [%70s : %50s] (#cfgs: %4d)...' %(test_cnt, len(tests), test, utest_name, len(utest_cfgs)), verbosity=0)
    
        # printing out structure for debug (if enabled via --verbose switch)
        # ---------------------------------------------------------------------------------------------------------------
        if(utest_cfgs):
            indent  = ' '*20
            log     = '%s- [uvm_test] : %s\n' %(indent, utest_name)
    
            all_cfgs = utest_cfg_plusargs.keys()
            all_cfgs.sort()
            for cfg in all_cfgs:
                all_flvs = utest_cfg_plusargs[cfg].keys()
                all_flvs.sort()
    
                log = '%s%s- [config  ] : %s (#flvs: %4d)\n' %(log, indent, cfg, len(all_flvs))
                for flv in all_flvs:
                    plusargs = utest_cfg_plusargs[cfg][flv].keys()
                    plusargs.sort()
    
                    log = '%s%s%s- {flavor: %s} [#iter: %d]\n' %(log, indent, indent, flv, utest_cfg_iter[cfg][flv]) 
                    for arg in plusargs:
                        if(utest_cfg_plusargs[cfg][flv][arg]):
                            if(type(utest_cfg_plusargs[cfg][flv][arg]) == int):
                                log = '%s%s%s%s> %30s = %d\n' %(log, indent, indent, indent, arg, utest_cfg_plusargs[cfg][flv][arg])
                            else:
                                log = '%s%s%s%s> %30s = %s\n' %(log, indent, indent, indent, arg, utest_cfg_plusargs[cfg][flv][arg])
                        else:
                            log = '%s%s%s%s> %30s\n' %(log, indent, indent, indent, arg)
    
                
            if(verbosity):
                print(log)
    
        if(args.debug):
            stdin = raw_input('{DEBUG MODE} <HIT ENTER> to proceed...')
            erase_prev_std_print(1)
    
        # populating the uvm_test_map
        # ---------------------------------------------------------------------------------------------------------------
        if(not utest_cfgs):
            print_warn('test [%s -> %s] with no config!' %(test, utest_name))
        else:
            for cfg in utest_cfg_plusargs.keys():
                if(not cfg in uvm_test_map):
                    uvm_test_map[cfg] = {}

                for flv in utest_cfg_plusargs[cfg].keys():
                    if(flv in uvm_test_map[cfg]):
                        print_error('something wrong with parsing! noticing duplicate flavor entries for flave (%s)' %(flv))
                    else:
                        uvm_test_map[cfg][flv] = {}
                        uvm_test_map[cfg][flv]['iter']     = utest_cfg_iter[cfg][flv]
                        uvm_test_map[cfg][flv]['plusargs'] = utest_cfg_plusargs[cfg][flv]

    return(uvm_test_map)

# get basic flavor candidates
# -------------------------------------------------------------------------------------------------------------------
def get_test_cfg_key(test, config_map):
    if(type(config_map) is dict):
        configs = config_map.keys()
        configs.sort()
    else:
        configs = config_map
        configs.sort()

    all_cfg = test
    for cfg in configs:
        if(type(config_map) is dict):
            all_cfg = '%s::%s >> %s' %(all_cfg, cfg, process_json_arg(config_map[cfg])) 
        else:
            all_cfg = '%s::%s' %(all_cfg, cfg)
    return(all_cfg)

def get_basic_flavor_candidates(tlist_dict, display_flavor_candidates):
    print_info('generating test cfg pairs wchich can be merged as flavors...')
    tests   = list(tlist_dict['testlist'].keys())
    tests.sort()
    
    # finding the merge candidates
    utest_cfg_map = {}
    for test in tests:
        test_cfg_key = get_test_cfg_key(tlist_dict['testlist'][test]['name'], tlist_dict['testlist'][test]['config']) 
        if('flavors' in tlist_dict['testlist'][test]):
            if(not tlist_dict['testlist'][test]['flavors']):
                if(not test_cfg_key in utest_cfg_map):
                    utest_cfg_map[test_cfg_key] = [test]
                else:
                    utest_cfg_map[test_cfg_key].append(test)
        else:
            if(not test_cfg_key in utest_cfg_map):
                utest_cfg_map[test_cfg_key] = [test]
            else:
                utest_cfg_map[test_cfg_key].append(test)

    # removing non merge candidates
    for cfg in utest_cfg_map.keys():
        if(len(utest_cfg_map[cfg]) == 1):
            utest_cfg_map.pop(cfg)

    # displaying flavor merge candidates
    if(display_flavor_candidates):
        indent   = ' '*10
        cfg_keys = utest_cfg_map.keys()
        cfg_keys.sort()
        print_info('displaying the basic flavor merge candidates:-')
        for cfg in cfg_keys:
            cfg_split = cfg.split('::')
            print_str = '%s - uvm_test: %s\n' %(indent, cfg_split[0])
            for i in range(1, len(cfg_split)):
                print_str = '%s%s%s ~ config: %s\n' %(print_str, indent, indent, cfg_split[i])

            print_str = '%s%s%s > flavor candidates are:-\n' %(print_str, indent, indent)
            for test in utest_cfg_map[cfg]:
                print_str = '%s%s%s%s > %s\n' %(print_str, indent, indent, indent, test)
            print(print_str)
    return(utest_cfg_map)

# getting stats from the testlist
# -------------------------------------------------------------------------------------------------------------------
def get_stats(tlist_dict):
    tests = tlist_dict['testlist'].keys()
    tests.sort()

    configs = tlist_dict['configlist'].keys()
    configs.sort()

    flavor_map = {}
    flavor_cnt = 0
    for test in tests:
        utest_name = tlist_dict['testlist'][test]['name']

        if(not utest_name in flavor_map):
            flavor_map[utest_name] = 0

        if('flavors' in tlist_dict['testlist'][test]):
            flavor_map[utest_name] = flavor_map[utest_name] + len(tlist_dict['testlist'][test]['flavors'].keys())
            flavor_cnt = flavor_cnt + len(tlist_dict['testlist'][test]['flavors'].keys())
    
    return('%s stats: [#configs: %d] [#test entries: %d] [#uvm_tests: %d] [#flavors: %d]' %(' '*10, len(configs), len(tests), len(flavor_map.keys()), flavor_cnt))

# merge flavors
# -------------------------------------------------------------------------------------------------------------------
def merge_flavor_candidates(tlist_dict, match_length):
    utest_cfg_map = get_basic_flavor_candidates(tlist_dict, display_flavor_candidates=0)

    # finiding the matching tests for flavor
    print_info('merging possible flavor candidates that has matching length [%1d]...' %(match_length))
    cfg_keys = utest_cfg_map.keys()
    cfg_keys.sort()

    match_test_cfg_map = {}
    for cfg in cfg_keys:
        matching_tests          = []
        match_test_cfg_map[cfg] = {}
        for idx0 in range(0, len(utest_cfg_map[cfg])):
            current_matches = []
            for idx1 in range(0, len(utest_cfg_map[cfg])):
                if(utest_cfg_map[cfg][idx0][:match_length] == utest_cfg_map[cfg][idx1][:match_length]):
                    current_matches.append(utest_cfg_map[cfg][idx1])
            if(len(current_matches) > len(matching_tests)):
                matching_tests = current_matches 
        match_test_cfg_map[cfg] = matching_tests

    # printing the match summary
    indent   = ' '*10
    cfg_keys = utest_cfg_map.keys()
    cfg_keys.sort()
    print_info('displaying the flavor match summary:-')
    for cfg in cfg_keys:
        cfg_split = cfg.split('::')
        print_str = '%s - uvm_test: %s (#flavor match: %d)\n' %(indent, cfg_split[0], len(match_test_cfg_map[cfg]))
        for i in range(1, len(cfg_split)):
            print_str = '%s%s%s ~ config: %s\n' %(print_str, indent, indent, cfg_split[i])

        print_str = '%s%s%s > flavor candidates are:-\n' %(print_str, indent, indent)
        for test in utest_cfg_map[cfg]:
            if(test in match_test_cfg_map[cfg]):
                print_str = '%s%s%s%s o %s\n' %(print_str, indent, indent, indent, test)
            else:
                print_str = '%s%s%s%s x %s\n' %(print_str, indent, indent, indent, test)
        print(print_str)

    # merging the flavors
    print_info('stats before merge:\n%s' %(get_stats(tlist_dict)))
    merge_cnt = 0
    for cfg in cfg_keys:
        # creating the flavors
        if(len(match_test_cfg_map[cfg]) > 1):
            merge_cnt = merge_cnt + 1
            merged_test = '__merged_entry_FIXME_%03d' %(merge_cnt)
            print_info('merging following test entries to [%s]...' %(merged_test))
            for test in match_test_cfg_map[cfg]:
                print('%s > %s' %(' '*10, test))

            tlist_dict['testlist'][merged_test] = {}
            tlist_dict['testlist'][merged_test]['name']    = tlist_dict['testlist'][match_test_cfg_map[cfg][0]]['name']
            tlist_dict['testlist'][merged_test]['purpose'] = 'update the purpose %s' %(merged_test)
            tlist_dict['testlist'][merged_test]['config']  = tlist_dict['testlist'][match_test_cfg_map[cfg][0]]['config']
            
            merged_flavors = {}
            for test in match_test_cfg_map[cfg]:
                test_args = {}
                for arg in tlist_dict['testlist'][test].keys():
                    if(not arg in ['name', 'purpose', 'config', 'flavors']):
                        test_args[arg] = tlist_dict['testlist'][test][arg]

                if('flavors' in tlist_dict['testlist'][test]):
                    if(tlist_dict['testlist'][test]['flavors']):
                        for flv in tlist_dict['testlist'][test]['flavors'].keys():
                            flv_args = test_args
                            for arg in tlist_dict['testlist'][test]['flavors'][flv].keys():
                                if(arg == 'label'):
                                    if('label' in flv_args):
                                        flv_args['label'].append(tlist_dict['testlist'][test]['flavors'][flv]['label'])
                                    else:
                                        flv_args['label'] = tlist_dict['testlist'][test]['flavors'][flv]['label']
                                elif(arg == 'plusargs'):
                                    if('plusargs' in flv_args):
                                        for plusarg in tlist_dict['testlist'][test]['flavors'][flv]['plusargs'].keys():
                                            flv_args['plusargs'][plusarg] = tlist_dict['testlist'][test]['flavors'][flv]['plusargs'][plusarg]
                                    else:
                                        flv_args['plusargs'] = tlist_dict['testlist'][test]['flavors'][flv]['plusargs']
                                else:
                                    flv_args[arg] = tlist_dict['testlist'][test]['flavors'][flv][arg]
                            merged_flavors['%s__%s' %(test, flv)] = flv_args
                    else:
                        merged_flavors[test] = test_args
                else:
                    merged_flavors[test] = test_args

                tlist_dict['testlist'][merged_test]['flavors'] = merged_flavors
                tlist_dict['testlist'].pop(test)
    print_info('stats after merge:\n%s' %(get_stats(tlist_dict)))
    return(tlist_dict)

# formatting the testlist and printing to the file
# -------------------------------------------------------------------------------------------------------------------
def write_file(FILE, indent_level, line):
    indent = ' '*(4*indent_level)
    FILE.write('%s%s\n' %(indent, line))

def process_json_arg(arg):
    if(type(arg) is dict):
        if(arg):
            arg_str  = '{'
            sub_args = arg.keys()
            sub_args.sort()
            for idx in range(0, len(sub_args)):
                if(idx < (len(sub_args)-1)):
                    arg_str = '%s"%s":%s, ' %(arg_str, sub_args[idx], process_json_arg(arg[sub_args[idx]]))
                else:
                    arg_str = '%s"%s":%s' %(arg_str, sub_args[idx], process_json_arg(arg[sub_args[idx]]))
            arg_str  = '%s}' %(arg_str)
        else:
            arg_str  = '{}'
    elif(type(arg) is list):
        if(arg):
            arg.sort()
            arg_str = '['
            for idx in range(0,len(arg)):
                if(idx < (len(arg)-1)):
                    arg_str = '%s"%s", ' %(arg_str, arg[idx])
                else:
                    arg_str = '%s"%s"]' %(arg_str, arg[idx])
        else:
            arg_str = '[]'
    elif(type(arg) is int):
        arg_str = '%d' %(arg)
    else:
        # differentiating between empty string and null entries
        if(not arg):
            arg_str = '%s' %(type(arg))
            if(re.search('NoneType', arg_str)):
                arg_str = 'null'
            else:
                arg_str = '"%s"' %(arg)
        # printing non-null value
        else:
            arg_str = '"%s"' %(arg)
    return(arg_str)

def format_testlist(tlist_dict, out_file, flatten_config, flatten_plusargs):
    OUT_FILE = open(out_file, 'w')
    if(OUT_FILE):
        print_info('formatting the given testlist to file: %s' %(out_file))
    else:
        print_error('unable to create the formatted testlist file [%s]! please check permissions/path' %(out_file))
    
    # printing default values
    # ---------------------------------------------------------------------------------------------------------------
    write_file(OUT_FILE, indent_level=0, line='{')
    write_file(OUT_FILE, indent_level=1, line='%-30s : "%s",' %('"version"', tlist_dict['version']))
    
    key_list = tlist_dict.keys()
    key_list.sort()
    for key in key_list:
        if(not key in ['version', 'configlist', 'testlist', 'plusargs']):
            write_file(OUT_FILE, indent_level=1, line='%-30s : %s,' %('"%s"' %(key), process_json_arg(tlist_dict[key])))

    if('plusargs' in tlist_dict):
        if(tlist_dict['plusargs']):
            plusargs = tlist_dict['plusargs'].keys()
            plusargs.sort()

            if(flatten_plusargs):
                write_file(OUT_FILE, indent_level=1, line='%-30s : %s,' %('"%s"' %('plusargs'), process_json_arg(tlist_dict['plusargs'])))
            else:
                write_file(OUT_FILE, indent_level=1, line='%-s : {' %('"%s"' %('plusargs')))
                for idx in range(0,len(plusargs)):
                    if(idx < (len(plusargs)-1)):
                        write_file(OUT_FILE, indent_level=2, line='%-s : %s,' %('"%s"' %(plusargs[idx]), process_json_arg(tlist_dict['plusargs'][plusargs[idx]])))
                    else:
                        write_file(OUT_FILE, indent_level=2, line='%-s : %s' %('"%s"' %(plusargs[idx]), process_json_arg(tlist_dict['plusargs'][plusargs[idx]])))
                write_file(OUT_FILE, indent_level=1, line='},')
        else:
            write_file(OUT_FILE, indent_level=1, line='%-30s : {},' %('"%s"' %('plusargs')))

    # printing the config list
    # ---------------------------------------------------------------------------------------------------------------
    configs = tlist_dict['configlist'].keys()
    configs.sort()
    write_file(OUT_FILE, indent_level=1, line='%-30s : {' %('"%s"' %('configlist')))
    for idx0 in range(0, len(configs)):
        write_file(OUT_FILE, indent_level=2, line='"%s" : {' %(configs[idx0]))
        cfg_args = tlist_dict['configlist'][configs[idx0]].keys()
        cfg_args.sort()

        for idx1 in range(0, len(cfg_args)):
            if(idx1 < (len(cfg_args)-1)):
                write_file(OUT_FILE, indent_level=3, line='%-30s : %s,' %('"%s"' %(cfg_args[idx1]), process_json_arg(tlist_dict['configlist'][configs[idx0]][cfg_args[idx1]])))
            else:
                write_file(OUT_FILE, indent_level=3, line='%-30s : %s' %('"%s"' %(cfg_args[idx1]), process_json_arg(tlist_dict['configlist'][configs[idx0]][cfg_args[idx1]])))

        if(idx0 < (len(configs)-1)):
            write_file(OUT_FILE, indent_level=2, line='},')
        else:
            write_file(OUT_FILE, indent_level=2, line='}')
    write_file(OUT_FILE, indent_level=1, line='},')

    # processing the testlist
    # ---------------------------------------------------------------------------------------------------------------
    tests = tlist_dict['testlist'].keys()
    tests.sort()
    write_file(OUT_FILE, indent_level=1, line='%-30s : {' %('"%s"' %('testlist')))
    for idx0 in range(0, len(tests)):
        write_file(OUT_FILE, indent_level=2, line='"%s" : {' %(tests[idx0]))
        write_file(OUT_FILE, indent_level=3, line='%-30s : "%s",' %('"name"', tlist_dict['testlist'][tests[idx0]]['name']))
        write_file(OUT_FILE, indent_level=3, line='%-30s : "%s",' %('"purpose"', tlist_dict['testlist'][tests[idx0]]['purpose']))
        if(type(tlist_dict['testlist'][tests[idx0]]['config']) is list):
            if(tlist_dict['testlist'][tests[idx0]]['config']):
                if(flatten_config):
                    write_file(OUT_FILE, indent_level=3, line='%-30s : %s,' %('"config"', process_json_arg(tlist_dict['testlist'][tests[idx0]]['config'])))
                else:
                    write_file(OUT_FILE, indent_level=3, line='%-30s : [' %('"config"'))
                    cfg_list = tlist_dict['testlist'][tests[idx0]]['config']
                    cfg_list.sort()

                    for idx1 in range(0, len(cfg_list)):
                        if(idx1 < (len(cfg_list)-1)):
                            write_file(OUT_FILE, indent_level=4, line='"%s",' %(cfg_list[idx1]))
                        else:
                            write_file(OUT_FILE, indent_level=4, line='"%s"' %(cfg_list[idx1]))
                    write_file(OUT_FILE, indent_level=3, line='],')
            else:
                write_file(OUT_FILE, indent_level=3, line='%-30s : [],' %('"config"'))
        else:
            if(tlist_dict['testlist'][tests[idx0]]['config']):
                if(flatten_config):
                    write_file(OUT_FILE, indent_level=3, line='%-30s : %s,' %('"config"', process_json_arg(tlist_dict['testlist'][tests[idx0]]['config'])))
                else:
                    write_file(OUT_FILE, indent_level=3, line='%-30s : {' %('"config"'))
                    cfg_list = tlist_dict['testlist'][tests[idx0]]['config'].keys()
                    cfg_list.sort()

                    for idx1 in range(0, len(cfg_list)):
                        if(tlist_dict['testlist'][tests[idx0]]['config'][cfg_list[idx1]]):
                            write_file(OUT_FILE, indent_level=4, line='%s : {' %('"%s"' %(cfg_list[idx1])))
                            cfg_args = tlist_dict['testlist'][tests[idx0]]['config'][cfg_list[idx1]].keys()
                            cfg_args.sort()

                            if('flavors' in cfg_args):
                                cfg_args.remove('flavors')
                                cfg_args.append('flavors')

                            idx2 = -1
                            for idx2 in range(0, len(cfg_args)-1):
                                write_file(OUT_FILE, indent_level=5, line='%-s : %s,' %('"%s"' %(cfg_args[idx2]), process_json_arg(tlist_dict['testlist'][tests[idx0]]['config'][cfg_list[idx1]][cfg_args[idx2]])))

                            if(not 'flavors' in cfg_args):
                                write_file(OUT_FILE, indent_level=5, line='%-s : %s' %('"%s"' %(cfg_args[idx2+1]), process_json_arg(tlist_dict['testlist'][tests[idx0]]['config'][cfg_list[idx1]][cfg_args[idx2+1]])))
                            else:
                                if(tlist_dict['testlist'][tests[idx0]]['config'][cfg_list[idx1]]['flavors']):
                                    write_file(OUT_FILE, indent_level=5, line='%-30s : {' %('"flavors"'))
                                    flv_list = tlist_dict['testlist'][tests[idx0]]['config'][cfg_list[idx1]]['flavors'].keys()
                                    flv_list.sort()

                                    for idx3 in range(0, len(flv_list)):
                                        if(idx3 < (len(flv_list)-1)):
                                            write_file(OUT_FILE, indent_level=6, line='%-20s : %s,' %('"%s"' %(flv_list[idx3]), process_json_arg(tlist_dict['testlist'][tests[idx0]]['config'][cfg_list[idx1]]['flavors'][flv_list[idx3]])))
                                        else:
                                            write_file(OUT_FILE, indent_level=6, line='%-20s : %s' %('"%s"' %(flv_list[idx3]), process_json_arg(tlist_dict['testlist'][tests[idx0]]['config'][cfg_list[idx1]]['flavors'][flv_list[idx3]])))
                                    write_file(OUT_FILE, indent_level=5, line='}')
                                else:
                                    write_file(OUT_FILE, indent_level=5, line='%-30s : {}' %('"flavors"'))

                            if(idx1 < (len(cfg_list)-1)):
                                write_file(OUT_FILE, indent_level=4, line='},')
                            else:
                                write_file(OUT_FILE, indent_level=4, line='}')
                        else:
                            if(idx1 < (len(cfg_list)-1)):
                                write_file(OUT_FILE, indent_level=4, line='%s : {},' %('"%s"' %(cfg_list[idx1])))
                            else:
                                write_file(OUT_FILE, indent_level=4, line='%s : {}' %('"%s"' %(cfg_list[idx1])))

                    write_file(OUT_FILE, indent_level=3, line='},')
            else:
                write_file(OUT_FILE, indent_level=3, line='%-30s : {},' %('"config"'))

        test_args = tlist_dict['testlist'][tests[idx0]].keys()
        test_args.remove('name')
        test_args.remove('purpose')
        test_args.remove('config')
        test_args.sort()

        if('plusargs' in test_args):
            test_args.remove('plusargs')
            test_args.append('plusargs')

        if('flavors' in test_args):
            test_args.remove('flavors')
            test_args.append('flavors')

        for idx1 in range(0, len(test_args)):
            if(test_args[idx1] == 'plusargs'):
                if(tlist_dict['testlist'][tests[idx0]]['plusargs']):
                    plusargs = tlist_dict['testlist'][tests[idx0]]['plusargs'].keys()
                    plusargs.sort()

                    if(flatten_plusargs):
                        if(idx1 < (len(test_args)-1)):
                            write_file(OUT_FILE, indent_level=3, line='%-30s : %s,' %('"%s"' %('plusargs'), process_json_arg(tlist_dict['testlist'][tests[idx0]]['plusargs'])))
                        else:
                            write_file(OUT_FILE, indent_level=3, line='%-30s : %s' %('"%s"' %('plusargs'), process_json_arg(tlist_dict['testlist'][tests[idx0]]['plusargs'])))
                    else:
                        write_file(OUT_FILE, indent_level=3, line='%-30s : {' %('"%s"' %('plusargs')))
                        for idx2 in range(0,len(plusargs)):
                            if(idx2 < (len(plusargs)-1)):
                                write_file(OUT_FILE, indent_level=4, line='%-s : %s,' %('"%s"' %(plusargs[idx2]), process_json_arg(tlist_dict['testlist'][tests[idx0]]['plusargs'][plusargs[idx2]])))
                            else:
                                write_file(OUT_FILE, indent_level=4, line='%-s : %s' %('"%s"' %(plusargs[idx2]), process_json_arg(tlist_dict['testlist'][tests[idx0]]['plusargs'][plusargs[idx2]])))

                        if(idx1 < (len(test_args)-1)):
                            write_file(OUT_FILE, indent_level=3, line='},')
                        else:
                            write_file(OUT_FILE, indent_level=3, line='}')
                else:
                    if(idx1 < (len(test_args)-1)):
                        write_file(OUT_FILE, indent_level=3, line='%-30s : {},' %('"plusargs"'))
                    else:
                        write_file(OUT_FILE, indent_level=3, line='%-30s : {}' %('"plusargs"'))

            elif(test_args[idx1] == 'flavors'):
                # runsim expects atleast an empty label when a flavor is defined
                if(not 'label' in tlist_dict['testlist'][tests[idx0]]):
                    write_file(OUT_FILE, indent_level=3, line='%-30s : [],' %('"%s"' %('label')))

                if(tlist_dict['testlist'][tests[idx0]]['flavors']):
                    write_file(OUT_FILE, indent_level=3, line='%-30s : {' %('"%s"' %('flavors')))

                    flv_list = tlist_dict['testlist'][tests[idx0]]['flavors'].keys()
                    flv_list.sort()

                    for idx3 in range(0, len(flv_list)):
                        if(idx3 < (len(flv_list)-1)):
                            write_file(OUT_FILE, indent_level=4, line='%-30s : %s,' %('"%s"' %(flv_list[idx3]), process_json_arg(tlist_dict['testlist'][tests[idx0]]['flavors'][flv_list[idx3]])))
                        else:
                            write_file(OUT_FILE, indent_level=4, line='%-30s : %s' %('"%s"' %(flv_list[idx3]), process_json_arg(tlist_dict['testlist'][tests[idx0]]['flavors'][flv_list[idx3]])))

                    if(idx1 < (len(test_args)-1)):
                        write_file(OUT_FILE, indent_level=3, line='},')
                    else:
                        write_file(OUT_FILE, indent_level=3, line='}')
                else:
                    if(idx1 < (len(test_args)-1)):
                        write_file(OUT_FILE, indent_level=3, line='%-30s : {},' %('"flavors"'))
                    else:
                        write_file(OUT_FILE, indent_level=3, line='%-30s : {}' %('"flavors"'))

            else:
                if(idx1 < (len(test_args)-1)):
                    write_file(OUT_FILE, indent_level=3, line='%-30s : %s,' %('"%s"' %(test_args[idx1]), process_json_arg(tlist_dict['testlist'][tests[idx0]][test_args[idx1]])))
                else:
                    write_file(OUT_FILE, indent_level=3, line='%-30s : %s' %('"%s"' %(test_args[idx1]), process_json_arg(tlist_dict['testlist'][tests[idx0]][test_args[idx1]])))

        if(idx0 < (len(tests)-1)):
            write_file(OUT_FILE, indent_level=2, line='},')
        else:
            write_file(OUT_FILE, indent_level=2, line='}')

    write_file(OUT_FILE, indent_level=1, line='}')

    # closing comments
    # ---------------------------------------------------------------------------------------------------------------
    write_file(OUT_FILE, indent_level=0, line='}')
    OUT_FILE.close()
    
# setting up scripts
# -------------------------------------------------------------------------------------------------------------------
parser = argparse.ArgumentParser(prog='process_testlist.py', description = 'used to analyze the given testlist')
parser.add_argument('--tlist'                 , required = True,           help='testlist with path')

parser.add_argument('--fmt_tlist'             , default  = None,           help='name of formatted testlist')
parser.add_argument('--flatten_config'        , action   = 'store_true',   help='print configs in one line to make json readable')
parser.add_argument('--flatten_plusargs'      , action   = 'store_true',   help='print plusargs in one line to make json readable')

parser.add_argument('--merge_flavors'         , action   = 'store_true',   help='merge flavor candidates and dumps it into a new testlist with a prefix merged_flavors')
parser.add_argument('--flavor_match_length'   , default  = 3,              help='number of characters to match in testname for flavor match')

parser.add_argument('--get_stats'             , action   = 'store_true',   help='get the stats from the given testlist')
parser.add_argument('--get_flavor_candidates' , action   = 'store_true',   help='get the flavor candidates that can be potentially merged using flavors')
parser.add_argument('--debug'                 , action   = 'store_true',   help='steps through one test at a time and turns on verbose mode')
parser.add_argument('--verbose'               , action   = 'store_true',   help='print debug messages')
args = parser.parse_args();

verbosity = args.debug | args.verbose
setup_script('PROCESS_TLIST', verbosity)

# checking  for the testlist
# -------------------------------------------------------------------------------------------------------------------
if(not os.path.exists(args.tlist)):
    print_error('unable to find the tlist [%s]...' %(args.tlist))

# processing the testlist
# -------------------------------------------------------------------------------------------------------------------
print_info('processing the testlist: [%s]...' %(args.tlist))
tlist_file = open(args.tlist)
tlist_dict = json.load(tlist_file)

# generate stats from the given testlist
# -------------------------------------------------------------------------------------------------------------------
if(args.get_stats):
    print_info('unfortunately there seems to be bug and it needs to be looked at...')
    # generate_uvm_test_map(tlist_dict, verbosity)        

# generate the flavor merge candidates
# -------------------------------------------------------------------------------------------------------------------
if(args.get_flavor_candidates):
    get_basic_flavor_candidates(tlist_dict, display_flavor_candidates=1)

# formatting the json file and print the contents
# -------------------------------------------------------------------------------------------------------------------
if(args.fmt_tlist):
    format_testlist(tlist_dict, args.fmt_tlist, args.flatten_config, args.flatten_plusargs)

# merge flavors
# -------------------------------------------------------------------------------------------------------------------
if(args.merge_flavors):
    merged_tlist = re.sub('.json$', '_merged_flavors.json', args.tlist)
    merged_tlist_dict = merge_flavor_candidates(tlist_dict, args.flavor_match_length)
    format_testlist(tlist_dict, merged_tlist, args.flatten_config, args.flatten_plusargs)
