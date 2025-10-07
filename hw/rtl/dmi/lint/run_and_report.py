from os import getcwd, listdir, mkdir
from os.path import join, isdir
from subprocess import call
import sys

# [[reportName, reportFile], ... ]
def getReportFiles():
    path = getcwd()
    files = [f for f in listdir(path) if isdir(join(path, f))]
    lintdir = 'lint.'
    reportData = []
    for file in files:
        if lintdir in file:
            #print file
            reportFile = []
            reportFile.append(file)
            reportFile.append(join(path, file, 'lint', 'consolidated_reports', 'lint_lint_rtl', 'moresimple.rpt'))
            reportData.append(reportFile)
    return reportData

def getErrors(reportData):
    res = ''
    for report in reportData:
        reportName = report[0]
        reportPath = report[1]
        res += "\n\nReport: " + reportName
        res += "\nFile Name: " + reportPath
        res += "\n\n"
        try:
            with open (reportPath) as file:
                errorFlag = 0
                for line in file:
                    if "Error" in line:
                        errorFlag = 1
                        res += line
                if errorFlag == 0:
                    res += 'No Errors\n'
        except IOError, e:
            res += 'Cannot open: ' + reportPath + '\n'
    return res

def write_to_file(file, string):
    print('writing to file: ' + file)
    with open(file, 'w') as write_file:
        write_file.write(string)

def mailto(email_address, subject, file, test):
    command = "cat " + file + " | mail -s \"" + subject + "\" " + email_address
    if test:
        print command
    else:
        call(command, shell=True)

# main
#print(sys.argv)
run = 'run' in sys.argv
report = 'report' in sys.argv

if run:
    call("./run", shell=True)

# print(getReportFiles())
if report:
    newReportPath = join(getcwd(), 'summary.txt')
    reportString = getErrors(getReportFiles())
    write_to_file(newReportPath, reportString)
    mailto("thbj@arteris.com", "Lint Run", newReportPath, 0)
