#!/usr/bin/env python

import os
import sys

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
