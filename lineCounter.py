#!/usr/bin/env python

import csv
import copy
import os
import sys
import glob
import xlsxwriter
import fileinput


def insert_line(file_name, line_num, text):
    lines = open(file_name,'r').readlines()
    lines[line_num] = lines[line_num]+text
    out = open(file_name,'w')
    out.writelines(lines)
    out.close()

def replace_line(file_name, line_num, text):
    lines = open(file_name,'r').readlines()
    lines[line_num] = text
    out = open(file_name,'w')
    out.writelines(lines)
    out.close()

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
                    fileDict[keyName] = sum(1 for line in f if line.strip() and not line.lstrip().startswith('%'))
                    f.close()
                    # The following should be done much nicer by reading
                    # in lines one by one using import fileinput.
                    # The difficulty was found in working the file.close().
                    if writeFile[1]: # we'll be writing to line Nr. writeFile[1] if some condition is met
                        comment = "% Code lines - "+str(fileDict[keyName])+"\n" 
                        commentPosition = 1
                        counter = 0
                        f = open(fileFullName)
                        for line in f:
                            if line[:8] == "classdef":
                                comment = "    "+comment # Sphinx cannot parse signatures of classdefs without indentation
                            if line[-4:-1] == "..." and line.lstrip()[0]!="%":
                                commentPosition += 1
                                continue
                            if counter == commentPosition and line.lstrip()[:12] == "% Code lines": # Remove previous count.
                                f.close()
                                replace_line(fileFullName,commentPosition-1,comment)
                                print("FINALYYYYYYYYY")
                                break
                            elif counter == commentPosition and line.lstrip()[:12] != "% Code lines":
                                f.close()
                                insert_line(fileFullName,commentPosition-1,comment)
                                break
                            else:
                                counter += 1

                    if f is not None:
                        f.close()

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

debug = 0


if not debug:
    writeFile = os.path.join(os.getcwd(),'./listDirectories.xlsx')
    startpath = os.path.join(os.getcwd(),'../tempClassifierTools2')
    list_files_with_lines(startpath,writeFile,1)


if debug:
    file = "C:\\GitRepositories\\tempClassifierTools2\\2_FeatureCalculation\\FormFeatureCellSounds.m"
    # f = open(file)
    # counter = 0
    # for line in f:
    #     print counter
    #     if line.lstrip()[1:12] == "% Code lines":
    #         print("Option1")
    #     if line.lstrip()[:12] == "% Code lines":
    #         print("Option2")
    #     if line.lstrip()[0:12] == "% Code lines":
    #         print("Option3")
    #     if line.lstrip()[0:11] == "% Code lines":
    #         print("Option4")
    #     if line.lstrip()[:11] == "% Code lines":
    #         print("Option5")
    #     if line.lstrip()[1:13] == "% Code lines":
    #         print("Option6")
    #     if line.lstrip()[0:13] == "% Code lines":
    #         print("Option7")
    #     if line.lstrip()[:13] == "% Code lines":
    #         print("Option8")
    #     if line.lstrip()[1:11] == "% Code lines":
    #         print("Option9")
    #     counter += 1

    replace_line(file,1,'bla2\n')

    # # test line endings and starts python
    # counter = 0
    # for line in f:
    #     if counter == 5:
    #         f.close()
    #         break
    #     else:
    #         print line[:7]
    #         if line[:5] == "% Code":
    #             print("Starts at 0!")
    #         if line[:6] == "% Code":
    #             print("Starts at 1!")
    #         if line.lstrip()[:5] == "% Code":
    #             print("Lstrp at 0!")
    #         if line.lstrip()[:6] == "% Code":
    #             print("Lstrp at 1!")
    #         counter += 1


    # #parses through files and saves to a dict
    # names = {}
    # for fn in glob.glob('*.sh'):
    #     with open(fn) as f:
    #         names[fn] = sum(1 for line in f if line.strip() and not line.startswith('%')) 

    # print names

    # #save the dictionary with key/val pairs to a csv
    # with open('matlabLineCounter.csv', 'w') as writeFile: 
    #     writer = csv.writer(writeFile)
    #     for key,value in names.items():
    #         writer.writerow([key[:-2],value])
