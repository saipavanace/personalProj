
# importing the relevant packages...
# -------------------------------------------------------------------------------------------------------------------
import io
import os
import re
import sys
import json
import math
import time
import shutil
import random
import pprint
import smtplib
import getpass
import requests
import argparse
import datetime
import subprocess
import unicodedata
import multiprocessing

# color codes for prints
# -------------------------------------------------------------------------------------------------------------------
class colors:
  HIGHLIGHT_YELLOW = '\033[1;43m'
  HIGHLIGHT_PINK   = '\033[1;45m'
  HIGHLIGHT_CYAN   = '\033[1;46m'
  HIGHLIGHT_RED    = '\033[1;41m'

  YELLOW_TXT       = '\033[1;33m'
  GREEN_TXT        = '\033[1;32m'
  PINK_TXT         = '\033[1;35m'
  RED_TXT          = '\033[1;31m'

  HEADER           = '\033[1;32m'
  FAIL             = '\033[1;31m'
  ENDC             = '\033[1;0m'
  MSG              = '\033[1;36m'

# global vars
# -------------------------------------------------------------------------------------------------------------------
comment_line     = 180
script_header    = "SCRIPT"
script_indent    = ''
script_verbosity = 0

# setup header
# -------------------------------------------------------------------------------------------------------------------
def setup_script(header, verbosity=0):
  global script_header
  global script_indent
  global script_verbosity
  header           = header.split('/')
  script_header    = re.sub('\.py', '', header[-1]).upper()
  script_indent    = ' '*(len(script_header)+6)
  script_verbosity = verbosity

# print_info
# -------------------------------------------------------------------------------------------------------------------
def print_info(msg, verbosity=0, no_color=0, insert_timestamp=0):
  if(verbosity <= script_verbosity):
    if(insert_timestamp == 1):
      header = script_header + ' (%s)' %(get_time())
    else:
      header = script_header

    if(no_color == 0):
      print(colors.HEADER + '[%s] ' %(header) + colors.MSG + '%s' %(msg) + colors.ENDC)
    else:
      print('[%s] ' %(header) + '%s' %(msg))

# print_warn
# -------------------------------------------------------------------------------------------------------------------
def print_warn(msg, no_color=0):
  if(no_color == 0):
    print(colors.HEADER + '[%s] ' %(script_header) + colors.HIGHLIGHT_RED + '%s' %(msg) + colors.ENDC)
  else:
    print('[%s] ' %(script_header) + '%s' %(msg))

# print_error
# -------------------------------------------------------------------------------------------------------------------
def print_error(msg, exit=1, no_color=0):
  if(no_color == 0):
    print(colors.FAIL + '[%s] [ERROR] %s\n' %(script_header, msg) + colors.ENDC)
  else:
    print('[%s] [ERROR] %s\n' %(script_header, msg))

  if(exit):
    sys.exit(1)

# get_time
# -------------------------------------------------------------------------------------------------------------------
def get_time():
  current_time = datetime.datetime.now()
  current_time = current_time.strftime("%H:%M:%S")
  return(current_time)

# get_date_time
# -------------------------------------------------------------------------------------------------------------------
def get_date_time():
  current_time = datetime.datetime.now()
  current_time = current_time.strftime("%m/%d [%H:%M]")
  return(current_time)

# erase_prev_std_print
# -------------------------------------------------------------------------------------------------------------------
def erase_prev_std_print(count):
  for i in range(0, count):
    sys.stdout.write("\033[F") #back to previous line 
    sys.stdout.write("\033[K") 

# do_percentage_div
# -------------------------------------------------------------------------------------------------------------------
def do_percentage_div(numerator, denominator):
  if(denominator == 0):
    return('---')
  else:
    return('%0.2f' %(100*numerator/denominator))

# custom table class definition
# -------------------------------------------------------------------------------------------------------------------
class custom_table:
  header    = []
  contents  = []
  col_width = []
  col_color = []

  # init function
  # -----------------------------------------------------------------------------------------------------------------
  def __init__(self):
    self.header    = []
    self.styles    = []
    self.contents  = []
    self.col_width = []
    self.col_color = []

  # add columns
  # -----------------------------------------------------------------------------------------------------------------
  def add_col(self, width, header, color=colors.ENDC):
    self.header   .append(header)
    self.col_width.append(width )
    self.col_color.append(color )

  # add rows
  # -----------------------------------------------------------------------------------------------------------------
  def add_row(self, row, style='color:black'):
    self.styles.append(style)
    self.contents.append(row)

  # printing table
  # -----------------------------------------------------------------------------------------------------------------
  def print_table(self, title, tab=' ', col_separator='|', div_color=colors.YELLOW_TXT):
    div = div_color + tab
    for i in range(0, len(self.col_width)):
      if(i == len(self.col_width)-1):
        div = div + '-'*(abs(self.col_width[i]))
      else:
        div = div + '-'*(abs(self.col_width[i])) + '---'
    div = div + '-'*5 + colors.ENDC

    # printing header
    print('\n%s%s (%s)' %(tab, title, get_time()))
    print(div)
    fprint = tab
    for i in range(0, len(self.col_width)):
      if(i == len(self.col_width)-1):
        fprint = fprint + self.col_color[i] + '%' + '%ds' %(self.col_width[i])
        fprint = fprint %(self.header[i][0])
      else:
        fprint = fprint + self.col_color[i] + '%' + '%ds %s ' %(self.col_width[i], col_separator)
        fprint = fprint %(self.header[i][0])
    print(fprint)
    print(div)

    # printing contents
    for j in range(0, len(self.contents)):
      fprint = tab
      if(self.contents[j][0] == 'insertDiv'):
        print(div)
      else:
        for i in range(0, len(self.col_width)):
          printvar = self.contents[j][i]
          if(isinstance(printvar, int)):
            printvar = str(printvar)
          elif(isinstance(printvar, float)):
            printvar = '%0.2f' %(printvar)

          if(i == len(self.col_width)-1):
            fprint = fprint + self.col_color[i] + '%' + '%ds' %(self.col_width[i])
            fprint = fprint %(printvar)
          else:
            fprint = fprint + self.col_color[i] + '%' + '%ds %s ' %(self.col_width[i], col_separator)
            fprint = fprint %(printvar)
        print(fprint)
    print(div + '\n')

  # creating html table
  # -----------------------------------------------------------------------------------------------------------------
  def create_html_table(self, title):
    html_table = ''

    # printing header
    html_table = html_table + '    <div>\n'
    html_table = html_table + '      <span style="font-size:1.2rem; color:blue"><b>%s</b></span>\n' %(title)
    html_table = html_table + '      <table>\n'
    html_table = html_table + '        <tr style="background-color:#045fb4; color:#ffffff">\n'

    for i in range(0, len(self.col_width)):
      color = ' '*14
      if(self.col_color[i] == colors.RED_TXT):
        color = 'color:#ff4000;'
      elif(self.col_color[i] == colors.GREEN_TXT):
        color = 'color:#31b404;'

      if(self.col_width[i] > 0):
        html_table = html_table + '          <th style="width:%dpx; text-align:right; text-indent:0.5cm"><span style="font-size:1.0rem; %s">%s</span></th>\n' %( 10*self.col_width[i], color, self.header[i][0])
      else:
        html_table = html_table + '          <th style="width:%dpx; text-align:left ; text-indent:0.5cm"><span style="font-size:1.0rem; %s">%s</span></th>\n' %(-10*self.col_width[i], color, self.header[i][0])
    html_table = html_table + '        </tr>\n'

    # printing contents
    for j in range(0, len(self.contents)):
      if(self.contents[j][0] != 'insertDiv'):
        html_table = html_table + '        <tr>\n'
        for i in range(0, len(self.col_width)):
          color = ' '*14
          if(self.col_color[i] == colors.RED_TXT):
            color = 'color:#ff4000;'
          elif(self.col_color[i] == colors.GREEN_TXT):
            color = 'color:#31b404;'

          printvar = self.contents[j][i]
          if(isinstance(printvar, int)):
            printvar = str(printvar)
          elif(isinstance(printvar, float)):
            printvar = '%0.2f' %(printvar)

          if(self.col_width[i] > 0):
            html_table = html_table + '          <td style="%s; text-align:right; text-indent:0.5cm"><span style="font-size:0.8rem; %s">%s</span></td>\n' %(self.styles[j], color, printvar)
          else:
            html_table = html_table + '          <td style="%s; text-align:left ; text-indent:0.5cm"><span style="font-size:0.8rem; %s">%s</span></td>\n' %(self.styles[j], color, printvar)
        html_table = html_table + '        </tr>\n'
    html_table = html_table + '      </table>\n'
    html_table = html_table + '    </div>\n'
    return(html_table)

# print_trace
# -------------------------------------------------------------------------------------------------------------------
def print_trace(trace, cmd, prefix='trace for the cmd '):
  trace     = trace.split('\n')
  trace_out = colors.ENDC
  for line in trace:
    trace_out = trace_out + '%s >> %s\n' %(script_indent, line)
  print_info('%s' %(prefix) + colors.YELLOW_TXT + '[%s]' %(cmd) + ':-\n%s' %(trace_out))

# adding entry to a dictionary
# -------------------------------------------------------------------------------------------------------------------
def add_dict_entry(my_dict, key, value):
  if(key in my_dict):
      my_dict[key].append(value)
  else:
      my_dict[key] = [value]
  return(my_dict)

# exec_shell_command
# -------------------------------------------------------------------------------------------------------------------
def exec_shell_command(cmd, prefix='executing the cmd...', quite=0, get_output=1, exit_on_err=1):
  print_info(prefix + colors.YELLOW_TXT + ' [%s]' %(cmd))
  if(get_output == 1):
    try:
      cmd_out = subprocess.check_output(cmd, stderr=subprocess.PIPE, shell=True)
      cmd_out = cmd_out.decode("utf-8")
      if(re.search('ERROR|FAIL|error:|Error|Fatal|aborted!', cmd_out)):
        print_error('command ' + colors.YELLOW_TXT + '[%s]' %(cmd) + colors.FAIL + ' failed with below trace!', exit=0)
        print_trace(cmd_out, cmd)
        if(exit_on_err == 1):
          sys.exit(1)
          return("CMD_ERROR")

    except subprocess.CalledProcessError as e:
      print_error('command ' + colors.YELLOW_TXT + '[%s]' %(cmd) + colors.FAIL + ' execution failed with below trace!', exit=0)
      print_trace(str(e), cmd)
      if(exit_on_err == 1):
        sys.exit(1)
        return("CMD_ERROR")

    if(not quite):
      print_trace(cmd_out, cmd)
    return(cmd_out)

  else:
    subproc = subprocess.call(cmd, shell=True)

# Debugger threads need help being killed.  Have each thread identify their pid for later processing

# run_debugger_shell_command_threads
# -------------------------------------------------------------------------------------------------------------------
def run_debugger_shell_command_threads(cmd, axf, prefix='running debugger_cmd_...', quite=0, log_file='debugger_app.log', lines_to_print=50, timeout=-1):
  if __name__ == 'py_common':
    global script_indent
    print_info('setting up cmd thread... ' + colors.YELLOW_TXT + ' [%s]' %(cmd))

    subprocess.call('rm -f %s' %(log_file), shell=True)
    cmd  = '%s -d > %s 2>&1' %(cmd, log_file)
    proc = multiprocessing.Process(target=exec_shell_command, args=(cmd, prefix, 1, 0,))
    proc.daemon = True
    proc.start()
    time.sleep(2)
    print_info('live log for the command @ %s' %(log_file))
    
    found_port = 0
    # find port number used by simulation
    with open(log_file, 'r') as f:
      for line in f:
        if (found_port == 0):
          port_pattern = re.compile('CADI server started listening to port (\d+)')
          # ports = search('CADI server started listening to port (\d+)', line)
          ports = port_pattern.findall(line)
          if ports:
            found_port = 1

    if (found_port == 0):
      print("Error: failed to extract port number from simulation")
      proc.terminate()
    cmd_alive     = 1
    dbg_alive     = 1
    prev_log_stat = 0
    no_update_cnt = 0
    sleep_time    = 5
    app_run_time  = 2

    # Start debugger
    db_cmd = 'modeldebugger -c %s -a %s.axf -y' %(ports[0], axf)
    print_info('setting up debugger thread... ' + colors.YELLOW_TXT + ' [%s]' %(db_cmd))
    db_proc = multiprocessing.Process(target=exec_shell_command, args=(db_cmd, "running the debugger...", 1, 0,))
    db_proc.daemon = True
    db_proc.start()
    time.sleep(1)
    while (cmd_alive or dbg_alive):
      # print("Cmd Alive: ", cmd_alive, " Dbg_alive: ", dbg_alive)
      log_stat  = subprocess.check_output('wc -l %s' %(log_file), stderr=subprocess.PIPE, shell=True)
      log_stat  = log_stat.decode("utf-8")
      log_stat  = re.sub('\s+.*', '', log_stat)

      log_out   = subprocess.check_output('tail -n %d %s' %(lines_to_print, log_file), stderr=subprocess.PIPE, shell=True)
      log_out   = log_out.decode("utf-8")
      log_out   = log_out.split('\n')
      
      cmd_alive = proc.is_alive()
      dbg_alive = db_proc.is_alive()

      # kill dead debugger if sim has died
      if ((cmd_alive  == 0) and (dbg_alive == 1)):
        #db_proc.terminate()
        db_proc.join()
        db_proc.close()
        
      if ((cmd_alive  == 1) and (dbg_alive == 0)):
        #        proc.terminate()
        proc.join()
        proc.close()

      current_time = datetime.datetime.now()
      current_time = current_time.strftime("%H:%M:%S")
      print('\n')
      if((prev_log_stat == log_stat) and (cmd_alive == 1)):
        no_update_cnt = no_update_cnt + sleep_time
        print('%s ' %(script_indent) + colors.HIGHLIGHT_CYAN + '>> [live log update @ %s] {run time: %d sec}' %(current_time, app_run_time) + colors.ENDC + ' >> ' + colors.HIGHLIGHT_RED + '(no change in the last %d seconds!)' %(no_update_cnt) + colors.ENDC)
      else:
        no_update_cnt = 0
        print('%s ' %(script_indent) + colors.HIGHLIGHT_CYAN + '>> [live log update @ %s] {run time: %d sec}' %(current_time, app_run_time) + colors.ENDC)
      prev_log_stat = log_stat

      log_to_print = []
      for log in log_out:
        log_start = 0
        while(log_start < len(log)):
          if(log_start == 0):
            log_to_print.append('%s >> %s' %(script_indent, log[log_start:log_start+150]))
          else:
            log_to_print.append('%s    %s' %(script_indent, log[log_start:log_start+150]))
          log_start = log_start + 150

      if(len(log_to_print) > lines_to_print):
        start_log = len(log_to_print)-lines_to_print
        end_log   = len(log_to_print)
        line_cnt  = lines_to_print+3
      else:
        start_log = 0
        end_log   = len(log_to_print)
        line_cnt  = len(log_to_print)+3

      for i in range(start_log, end_log):
        print(log_to_print[i])

      if(cmd_alive):
        erase_prev_std_print(line_cnt)
        time.sleep(sleep_time)
      else:
        print('\n')
      app_run_time = app_run_time + sleep_time

    print("Call joins")
    proc.join()
    proc.close()
    db_proc.join()
    db_proc.close()
    print("Joins called")


# run_shell_command_thread
# -------------------------------------------------------------------------------------------------------------------
def run_shell_command_thread(cmd, prefix='running the cmd...', quite=0, log_file='app.log', lines_to_print=50, timeout=-1, exit_on_err=0):
  if __name__ == 'py_common':
    global script_indent
    print_info('setting up cmd thread... ' + colors.YELLOW_TXT + ' [%s]' %(cmd))

    subprocess.call('rm -f %s' %(log_file), shell=True)
    cmd  = '%s > %s 2>&1' %(cmd, log_file)
    proc = multiprocessing.Process(target=exec_shell_command, args=(cmd, prefix, 1, 0,))
    proc.daemon = True
    proc.start()
    time.sleep(2)
    print_info('live log for the command @ %s' %(log_file))

    cmd_alive     = 1
    prev_log_stat = 0
    no_update_cnt = 0
    sleep_time    = 5
    app_run_time  = 2
    while(cmd_alive):
      log_stat  = subprocess.check_output('wc -l %s' %(log_file), stderr=subprocess.PIPE, shell=True)
      log_stat  = log_stat.decode("utf-8")
      log_stat  = re.sub('\s+.*', '', log_stat)

      log_out   = subprocess.check_output('tail -n %d %s' %(lines_to_print, log_file), stderr=subprocess.PIPE, shell=True)
      log_out   = log_out.decode("utf-8")
      log_out   = log_out.split('\n')
      cmd_alive = proc.is_alive()

      current_time = datetime.datetime.now()
      current_time = current_time.strftime("%H:%M:%S")
      print('\n')
      if((prev_log_stat == log_stat) and (cmd_alive == 1)):
        no_update_cnt = no_update_cnt + sleep_time
        print('%s ' %(script_indent) + colors.HIGHLIGHT_CYAN + '>> [live log update @ %s] {run time: %d sec}' %(current_time, app_run_time) + colors.ENDC + ' >> ' + colors.HIGHLIGHT_RED + '(no change in the last %d seconds!)' %(no_update_cnt) + colors.ENDC)
      else:
        no_update_cnt = 0
        print('%s ' %(script_indent) + colors.HIGHLIGHT_CYAN + '>> [live log update @ %s] {run time: %d sec}' %(current_time, app_run_time) + colors.ENDC)
      prev_log_stat = log_stat

      log_to_print = []
      for log in log_out:
        log_start = 0
        while(log_start < len(log)):
          if(log_start == 0):
            log_to_print.append('%s >> %s' %(script_indent, log[log_start:log_start+150]))
          else:
            log_to_print.append('%s    %s' %(script_indent, log[log_start:log_start+150]))
          log_start = log_start + 150

      if(len(log_to_print) > lines_to_print):
        start_log = len(log_to_print)-lines_to_print
        end_log   = len(log_to_print)
        line_cnt  = lines_to_print+3
      else:
        start_log = 0
        end_log   = len(log_to_print)
        line_cnt  = len(log_to_print)+3

      for i in range(start_log, end_log):
        print(log_to_print[i])

      if(cmd_alive):
        erase_prev_std_print(line_cnt)
        time.sleep(sleep_time)
      else:
        print('\n')
      app_run_time = app_run_time + sleep_time

    proc.join()
    try:
      err_out = subprocess.check_output('grep -n "ERROR\|FAIL\|error:\|Error\|Fatal\|aborted" %s' %(log_file), stderr=subprocess.PIPE, shell=True) 
      err_out = err_out.decode("utf-8")
      print_error('following error signatures observed!', exit=0)
      print_trace(err_out, cmd='', prefix='error msg trace')
      app_run_time = -1
      if(exit_on_err == 1):
        sys.exit(1)
    except subprocess.CalledProcessError as e:
      ignore_this = 1
    return(app_run_time)

