"""
    Borrowed then modified from: http://tuohuang.info/unity-automate-post-process/#.U6i3_I1dVaR
"""

import os
from sys import argv
from mod_pbxproj import XcodeProject

path = argv[1]
fileToAddPath = argv[2]
project = XcodeProject.Load(path + '/Unity-iPhone.xcodeproj/project.pbxproj')

# Add required libraries
############################
project.add_file('System/Library/Frameworks/Security.framework', tree='SDKROOT')

# Add all files in /Assets/Editor/Arbiter/
files_in_dir = os.listdir(fileToAddPath)
for f in files_in_dir:
    if not f.startswith('.'):  # exclude .DS_STORE on mac
        pathname = os.path.join(fileToAddPath, f)
        fileName, fileExtension = os.path.splitext(pathname)
        if not fileExtension == '.meta':  # skip .meta file
            if os.path.isfile(pathname):
                project.add_file(pathname)
            if os.path.isdir(pathname):
                project.add_folder(pathname, excludes=["^.*\.meta$"])

# Change build settings
############################
project.add_other_buildsetting('GCC_ENABLE_OBJC_EXCEPTIONS', 'YES')


# Add ARC compiler flag for Stripe and PaymentKit files
########################################################
for key in project.get_ids():
    obj = project.get_obj(key)

    name = obj.get('name')
    isa = obj.get('isa')
    path = obj.get('path')
    fileref = obj.get('fileRef')

    try:
        if 'Stripe' in path:
            build_files = project.get_build_files(key)
            if build_files is not None:
                for build_file in build_files:
                    build_file.add_compiler_flag('-fobjc-arc')
    except Exception as err:
        pass

# Now save
############################
if project.modified:
    project.backup()
    project.save()
