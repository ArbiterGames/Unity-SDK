"""
    Borrowed from: http://tuohuang.info/unity-automate-post-process/#.U6i3_I1dVaR
"""

import os
from sys import argv
from mod_pbxproj import XcodeProject

path = argv[1]
fileToAddPath = argv[2]
print('ArbiterPostprocessor.py xcode build path --> ' + path)
print('ArbiterPostprocessor.py third party files path --> ' + fileToAddPath)

project = XcodeProject.Load(path + '/Unity-iPhone.xcodeproj/project.pbxproj')

# Add required libraries
############################
project.add_file('System/Library/Frameworks/Security.framework', tree='SDKROOT')

# Add all files in /Assets/Editor/Arbiter/
files_in_dir = os.listdir(fileToAddPath)
for f in files_in_dir:
    if not f.startswith('.'):  # exclude .DS_STORE on mac
        print f
        pathname = os.path.join(fileToAddPath, f)
        fileName, fileExtension = os.path.splitext(pathname)
        if not fileExtension == '.meta':  # skip .meta file
            if os.path.isfile(pathname):
                print "is file : " + pathname
                project.add_file(pathname)
            if os.path.isdir(pathname):
                print "is dir : " + pathname
                project.add_folder(pathname, excludes=["^.*\.meta$"])

# Change build settings
############################
project.add_other_buildsetting('GCC_ENABLE_OBJC_EXCEPTIONS', 'YES')

# TODO: Remove this line before deploying
project.add_other_buildsetting('DEBUG_INFORMATION_FORMAT', 'dwarf')


# Add ARC compiler flag for Stripe and PaymentKit files
########################################################
for key in project.get_ids():
    obj = project.get_obj(key)

    name = obj.get('name')
    isa = obj.get('isa')
    path = obj.get('path')
    fileref = obj.get('fileRef')

    print '**********'
    print path

    try:
        if 'Stripe' in path:
            print 'YES'
            build_files = project.get_build_files(key)
            if build_files is not None:
                for build_file in build_files:
                    # add the ARC compiler flag to the adjust file if doesn't exist
                    build_file.add_compiler_flag('-fobjc-arc')
                    print 'ADDED FLAG'
        else:
            print 'NO'
    except Exception as err:
        print 'ERROR'
        print err
    print '**********'
    print '\n'
    print '\n'
    print '\n'
    print '\n'

# Now save
############################
if project.modified:
    project.backup()
    project.save()
