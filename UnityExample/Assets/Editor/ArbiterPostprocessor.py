"""
    Borrowed then modified from: http://tuohuang.info/unity-automate-post-process/#.U6i3_I1dVaR
"""

import os
import plistlib
from sys import argv
from mod_pbxproj import XcodeProject

path = argv[1]
fileToAddPath = argv[2]
BASE_PATH = '/Applications/Xcode.app/Contents/Developer/Platforms/iPhoneOS.platform/Developer/SDKs/iPhoneOS.sdk/'
project = XcodeProject.Load(path + '/Unity-iPhone.xcodeproj/project.pbxproj')
frameworks_path = BASE_PATH + 'System/Library/Frameworks/'
lib_path = BASE_PATH + 'usr/lib/'


# Add required libraries
############################
project.add_file(frameworks_path + 'Security.framework', tree='SDKROOT')
project.add_file(frameworks_path + 'PassKit.framework', tree='SDKROOT', weak=True)
project.add_file(lib_path + 'libicucore.dylib', tree='SDKROOT')

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
project.add_other_buildsetting('CLANG_ENABLE_MODULES', 'YES')
project.add_other_buildsetting('IPHONEOS_DEPLOYMENT_TARGET', '7.0')


# Add ARC compiler flag for Stripe and PaymentKit files
########################################################
for key in project.get_ids():
    obj = project.get_obj(key)
    file_path = obj.get('path')
    try:
        if 'Arbiter' in file_path or \
           'PaymentKit' in file_path or \
           'Stripe' in file_path or \
           'Mixpanel' in file_path:
            build_files = project.get_build_files(key)
            if build_files is not None:
                for build_file in build_files:
                    build_file.add_compiler_flag('-fobjc-arc')
    except Exception as err:
        pass

# Add Info.plist keys for location services
########################################################
rootObject = plistlib.readPlist(path + '/Info.plist')
rootObject['NSLocationWhenInUseUsageDescription'] = 'This is required to participate in cash games.'
plistlib.writePlist(rootObject, path + '/Info.plist')


# Now save
############################
if project.modified:
    project.backup()
    project.save()
