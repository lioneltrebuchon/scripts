#!/usr/bin/env python

import csv
import copy
import os
import sys
import glob
import xlsxwriter
import fileinput

def list_files_with_lines(startpath,*writeFile):
    if not writeFile:
        # Printing file structure to command line
        for root, dirs, files in os.walk(startpath):
            flag = False
            if any (file.endswith(".m") for file in files ):
                level = root.replace(startpath,'').count(os.sep)
                indent = ' ' * 4 * (level)
                print('{}{}/'.format(indent, os.path.basename(root)))
                subindent = ' ' * 4 * (level+1)
                flag = True
            elif not files:
                level = root.replace(startpath,'').count(os.sep)
                indent = ' ' * 4 * (level)
                print('{}{}/'.format(indent, os.path.basename(root)))
                subindent = ' ' * 4 * (level+1)
            if flag:
                for file in files:
                    if file.endswith(".m"):
                        file = file[:-2]
                        print('{}{}'.format(subindent,file))
    else:
        extCounter = 0
        print writeFile[1]
        lengthCut = len(startpath)
        fileDict = {}
        # Building dictionary by parsing all files in current directory, recursively!
        for root, dirs, files in os.walk(startpath):
        # if any (file.endswith(".m") for file in files ): #not needed
            for file in files:
                if file.endswith(".m"):
                    fileFullName = os.path.join(root,os.path.relpath(file))
                    f = open(fileFullName)
                    keyName = fileFullName[lengthCut:-2]
                    fileDict[keyName] = sum(1 for line in f if line.strip() and not line.startswith('%'))
                    f.close()

                    if writeFile[1]: # we'll be writing to line Nr. writeFile[1] if some condition is met
                        comment = "%Code lines - "+str(fileDict[keyName])
                        print comment
                        print keyName
                        if extCounter == 1:
                            break
                        extCounter += 1
                        commentPosition = 1
                        counter = 0
                        for line in fileinput.FileInput(fileFullName,inplace=1):
                            print "%d: %s" % (fileinput.filelineno(), line)
                            if line[-3:] == "...":
                                commentPosition += 1
                                continue
                            if counter == commentPosition and line[:12] != "%Code lines -":
                                line=line.replace(line,line+comment)
                                break
                            elif line[:12] == "%Code lines -":
                                line=line.replace(line,comment)
                                break
                            counter += 1

        with xlsxwriter.Workbook(writeFile[0]) as workbook:
            worksheet = workbook.add_worksheet()
            row = 0
            col = 0
            # Exporting the dictionary to an .xlsx file
            for key in fileDict.keys():
                row += 1
                worksheet.write(row,col,key)
                # Unfruitful attempt at a multilevel dictionary.
                # if len(fileDict[key])>1:
                #     for item in fileDict[key]:
                #         worksheet.write(row,col+1,item)
                #         worksheet.write(row,col+2,fileDict[key][item][0])
                #         row += 1
                # else:
                worksheet.write(row,col+1,fileDict[key])


writeFile = os.path.join(os.getcwd(),'./listDirectories.xlsx')
startpath = os.path.join(os.getcwd(),'../temp')
list_files_with_lines(startpath,writeFile,1)


debug = 0
if debug:
    #parses through files and saves to a dict
    names = {}
    for fn in glob.glob('*.sh'):
        with open(fn) as f:
            names[fn] = sum(1 for line in f if line.strip() and not line.startswith('%')) 

    print names

    #save the dictionary with key/val pairs to a csv
    with open('matlabLineCounter.csv', 'w') as writeFile: 
        writer = csv.writer(writeFile)
        for key,value in names.items():
            writer.writerow([key[:-2],value])
