import glob
import os
os.chdir( "//scw000101143/RSTRAIN/0.96.8/log/" )

# for file in os.walk('*.log'):
for subdir, dirs, files in os.walk('.'):
#for file in os.listdir('*.log'):
    print(subdir)
    for file in files:
        if file.endswith('log'):
            with open('{}/{}'.format(subdir, file)) as f:
                contents = f.read()
                if 'EVALUATE_STANDARD' in contents:
                    print(file)
        #print('DEBUG: file=>{0}<'.format(file))
    #    if 'userTool was used before. Reuse is not supported' in contents:
    #       print(file)

# os.chdir( "/media/DATA/Dropbox/amiv_coding_we/amiv-admintool" )

# for file in os.walk('*.js'):
#     print 'DEBUG: file=>{0}<'.format(file)
#     with open(file) as f:
#         contents = f.read()
#     if 'userTool' in contents:
#         print file
