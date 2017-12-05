#!/usr/bin/env python

import os
import sys
import lineFunctions
import fileinput


def remove_lines_in(startpath):
    comment = "%\n"
    for root, dirs, files in os.walk(startpath):
        for file in files:
            if file.endswith(".m"):
                fileFullName = os.path.join(root,os.path.relpath(file))
                file = fileinput.FileInput(fileFullName,inplace=1)
                for line in file:
                    stripped = line.lstrip()
                    if stripped[:2] == "%*" or stripped[:4] == "\%\% *" or stripped[:4] == "\%\%*" or stripped[:4] == "% **":
                        line = comment
                    print line, # replaces whole line with comment
                file.close()
                # f = open(fileFullName)
                # for line in f:
                #     if line.lstrip()[:2] == "%*":
                #         replace_line(fileFullName,line,comment)

startpath = os.path.join(os.getcwd(),'../tempClassifierTools2')
remove_lines_in(startpath)
