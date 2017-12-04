#!/usr/bin/env python

import csv
import copy
import os
import sys
import glob
import xlsxwriter

def list_files_with_lines(startpath,*writeFile):
    if not writeFile:
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
        fileDict = {}
        # Building dictionary by parsing all files in current directory, recursively!
        for root, dirs, files in os.walk(startpath):
            if any (file.endswith(".m") for file in files ):
                for file in files:
                    if file.endswith(".m"):
                        fileFullName = os.path.join(root,os.path.relpath(file))
                        with open(fileFullName) as f:
                            fileFullName = fileFullName[:-2]
                            fileDict[fileFullName] = sum(1 for line in f if line.strip() and not line.startswith('%')) 
        with xlsxwriter.Workbook(writeFile) as workbook:
            worksheet = workbook.add_worksheet()
            row = 0
            col = 0
            # Exporting the dictionary to an .xlsx file
            for key,value in fileDict.items():
                row += 1
                worksheet.write(row,col,key)
                # Unfruitful attempt at a multilevel dictionary.
                # if len(fileDict[key])>1:
                #     for item in fileDict[key]:
                #         worksheet.write(row,col+1,item)
                #         worksheet.write(row,col+2,fileDict[key][item][0])
                #         row += 1
                # else:
                worksheet.write(row,col+1,value)


writeFile = os.path.join(os.getcwd(),'./listDirectories.xlsx')
# list_files_with_lines(os.getcwd(),writeFile)
startpath = os.path.join(os.getcwd(),'../ClassifierTools')
# list_files_with_lines(startpath,writeFile)


debug = 1
if debug:
    fileDict = {}
    startpath = os.path.join(os.getcwd(),'../ClassifierTools')
    for root, dirs, files in os.walk(startpath):
        for file in files:
            if file.endswith(".m"):
                fileFullName = os.path.join(root,os.path.relpath(file))
                with open(fileFullName) as f:
                    fileFullName = fileFullName[:-2]
                    fileDict[fileFullName] = sum(1 for line in f if line.strip() and not line.startswith('%')) 

    print fileDict

    with xlsxwriter.Workbook(writeFile) as workbook:
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
