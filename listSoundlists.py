#!/usr/bin/env python
import csv
import copy
import os
import sys
import glob
import xlsxwriter
import fileinput
import re
import shutil

def insert_line(file_name, line_num, text):
    lines = open(file_name,'r').readlines()
    lines[line_num] = text+lines[line_num]
    out = open(file_name,'w')
    out.writelines(lines)
    out.close()

def replace_line(file_name, line_num, text):
    lines = open(file_name,'r').readlines()
    lines[line_num] = text
    out = open(file_name,'w')
    out.writelines(lines)
    out.close()

def remove_duplicates(listIn):
    seen = set()
    listUniq = []
    for x in listIn:
        if x not in seen:
            listUniq.append(x)
            seen.add(x)
    return listUniq

def list_soundlists(startpath,resultpath):
    rowDest = 0
    fileDict = {}
    regex = r"'([^;']*)';"
    listSounds = list()
    for fileOrig in os.listdir(os.getcwd()):
        if fileOrig.endswith(".m"):
            f = open(fileOrig,'r')
            for line in f:
                strippedLine = line.strip()
                if strippedLine and not strippedLine.startswith('%') and not strippedLine.startswith('...'):
                    matches = re.findall(regex,strippedLine)
                    for match in matches:
                        # print(match)
                        listSounds.append(match)
            f.close()
    listSounds = remove_duplicates(listSounds)
    print(listSounds)
    with open(resultpath,'w') as fDest:
        for item in listSounds:
            fDest.write("%s\n" % item)
    return listSounds

def sort_files(source, dest1, dest2, listSource):
    for f in os.listdir(source):
        path = os.path.join(source, f)
        if os.path.isdir(path):
            continue
        if (any(f.rsplit('.', 1)[0]) in listElement for listElement in listSource):
            shutil.copyfile(path, os.path.join(dest1, f))
        else:
            shutil.copyfile(path, os.path.join(dest2, f))


debug = 0

if not debug:
    # Collecting the list
    writeFile = os.path.join(os.getcwd(),'./allCurrentSoundlists.txt')
    startpath = os.path.join('C:\\GitRepositories\\ClassifierTools\\1_ClassdataDefinitions\\current\\set_soundlists_HABS_6classes_Venture.m')
    listSource = list_soundlists(startpath,writeFile)
    # Moving the files
    source = '../../1_Soundlists'
    dest1 = '../../1_Soundlists/current'
    dest2 = '../../1_Soundlists/legacy'
    sort_files(source, dest1, dest2, listSource)

