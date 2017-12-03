import glob
import os

# Change directory.
os.chdir( "/media/DATA/Dropbox/amiv_coding_we/amiv-admintool" )

for file in os.walk('*.js'):
    print 'DEBUG: file=>{0}<'.format(file)
    with open(file) as f:
        contents = f.read()
    if 'userTool' in contents:
        print file