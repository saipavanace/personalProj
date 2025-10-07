# Parameter Coverage (WIP)

UPDATED: 2024-08-09, param_cov.js version 0.2.4

Location: $WORK_TOP/dv/scripts/param_cov (note: Ncore 3.7 and above)

This script is intended to perform coverage analysis of the generated configuration parameters from Maestro.  It generally expects the format of the top.level.dv.json file but it may work with other formats that are similar.

(you will need to ```npm install xlsx``` manually until Balaji makes it part of the 3.7 environment)

## Files and subdirectories:

| Name                              | Description                               |
|-----------------------------------|-------------------------------------------|
| param_cov.js                      | the main script, see below                |
| README.md                         | this files                                |
| utils/                            | directory for additional files            |
| utils/reference_parameters.json   | all allowed parameter values              |
| utils/template.html               | template for html output                  |
| tests/                            | local dir for test inputs (not in gitlab) |
| old/                              | temporary dir for pre 3.7 version         |

## Usage

```bash
./param_cov.js -h

  Usage: param_cov [options]

  Options:

    -b, --json_file <string>         specify a base filename with configuration data, default is top.level.dv.json
    -c, --csv                        create a csv output file, default name coverage_results.csv
    -d, --debug                      specify this to print helpful debug information
    -f, --params_list_file <string>  file containing a list of Json files
    -j, --json                       create a Json output file named coverage_results.json
    -l, --params_list <items>        comma separated string of json files
    -m, --merge <string>             merge new results into existing results, provide the <path/>filename.ext to merge with
    -p, --params_path <string>       path to look for ALL Json files (be careful, use -b if needed)
    -o, --out_file_name <string>     override the output file name, default is coverage_results
    -r, --ref_file_name <string>     specify a reference Json file, default is $WORK_TOP/dv/scripts/param_cov/utils/reference_parameters.json
    -t, --todo                       list remaining work to do
    -w, --web                        create an html output file (and Json), default name coverage_results.html
    -x, --xlsx                       create an Excel file, default name is coverage_results.xlsx
    -V, --version                    output the version number
    -h, --help                       output usage information
```

**NOTE:** the `reference_parameters.json` file contains the data expected to be covered.  You can change this as needed.  For example, if a range like [ "0:8192" ] is too large, you can break it up as in [ "0:12", "8180:8192" ].  This would make sure that all values between 0 through 12 and 8180 through 8192 (26 total values) are covered.  The trade-off is that (valid) values outside these ranges would be listed as invalid.

## Examples

(all assume running from `$WORK_TOP/dv/scripts/param_cov`)

### Example 1

```bash
./param_cov.js -l tests/top.level.dv.json -w -o test_output
```

This will read the configuration data in `tests/top.level.dv.json`, score it against the allowable values in `utils/reference_parameters.json` and create `test_output.html` and `test_output.json` files.  The `test_output.html` file can be used to view and interact with the data.  These two files can be moved anywhere convenient but they must be in the same directory and that directory must be accessible to the web server.

### Example 2

```bash
./param_cov.js -f tests/my_random_json.lst -w -o many_configs
```

This will read the configuration data from the list of files specified in `tests/my_random_json.list` and create `many_configs.html` and `many_configs.json` files.  As above, these two files can be moved.

### Example 3

```bash
./param_cov.js -p /scratch/spavan/randomizer_config_database -b dv*.json -x -o dir_excel
```

This will read the configuration data from any Json file named `dv*.json` that appears in `/scratch/spavan/randomizer_config_database` or below and creates an Excel file named `dir_excel.xls` with the aggregate results.  This is particularly useful for use with the parameter randomizer as those config files are named `dv_${seed}.json`

***Note***: using -p without -b will cause the script to use ANY Json file it finds in that tree.  Thus it is wise to use -b since it is highly likely that there will be other Json files that are not formatted as expected.  In the example for instance, the tree provided with -p includes files named `params_${seed}.json` that have a completely different format.  Including them may cause erroneous results.

### Example 4

```bash
./param_cov.js -l tests/top.level.dv.json -j -o base_cov
./param_cov.js -f tests/cust3.7.lst -m base_cov -w
```

This will create a base json file of results (`base_cov`) from a single file of parameters (`tests/top.level.dv.json`) and then merge the results from a list of files (`tests/cust3.7.lst`) into that and create a (combined) html output with default output names (`coverage_results.html` and `coverage_results.json`).

### Debugging

```bash
./param_cov.js -l tests/top.level.dv.json -d
```

This will print a few informative messages and then print the coverage structure to the console.  This is not useful in most cases.

## To Do

This is available using the script:

```bash
./param_cov.js -t
```

This will print the to-do list and exit.  Other options are ignored.  Current output below: 

- populate proper reference values (WIP)
- add merging two existing coverage Jsons
- add cross-coverage
- discuss excluions, implement -- esp invalid values that aren't really invalid
- consider counting number of times a value is seen
- discuss need for per-instance coverage
