#!/usr/bin/env python2

import sys
import os
import glob
import shutil
from xml.parsers.expat import ExpatError
from xml.dom import minidom
from PIL import Image

def checkfiles(start_path):
    if not os.path.islink(start_path):
        if os.path.isfile(start_path):
            #print "%s - file" % start_path
            return processImages(os.path.abspath(start_path))
        elif os.path.isdir(start_path):
            #print "%s - directory" % start_path
            start_path=os.path.join(start_path,"*")
            for path in glob.iglob(start_path):
                checkfiles(path)
    else:
       print("links not traversed\n")

def movefile(src,dest,dest_dir):
    try:
        if os.path.isfile(dest):
            if not QUIET: print("not moving %s, file exists in %s" % (src,dest_dir))
        else:
            if not QUIET: print("moving:: %s to %s" % (src,dest))
            shutil.move(src,dest)
            return True
        return False
    except OSError:
        print("Copy failed!")
        sys.exit()

def create_if_not_exists(dest_dir):
    try:
        if os.path.isfile(dest_dir):
            raise OSError("file %s exists" % dest_dir)
        elif not os.path.exists(dest_dir):
            if not QUIET: print("creating directory ... %s" % dest_dir)
            os.makedirs(dest_dir)
    except OSError:
        print("Failed to create directory %s" % dest_dir)
        sys.exit()

def process_xcf(filename):
    global COUNT
    try:
        file=open(filename)
        metadata=file.readline()[0:9]
        if metadata=="gimp xcf ":
            if  DEBUG: print("%s confirmed as xcf file" % filename)
            path_mvdir=os.path.join(DIR,"xcfFiles")
            create_if_not_exists(path_mvdir)
            newfile=os.path.join(path_mvdir, os.path.basename(filename))
            if movefile(filename,newfile,path_mvdir):
                COUNT +=1
            return True
        else:
            return False
    except (IOError,OSError) as error:
        print(error)
        sys.exit()

def process_svg(filename):
    global COUNT
    try:
        svgfile = minidom.parse(filename)
        if svgfile.getElementsByTagName('svg'):
            if DEBUG: print("%s confirmed as svg file" % filename)
            path_mvdir=os.path.join(DIR,"svgFiles")
            create_if_not_exists(path_mvdir)
            newfile=os.path.join(path_mvdir, os.path.basename(filename))
            if movefile(filename,newfile,path_mvdir):
                COUNT +=1
            return True
        else:
            return False
    except ExpatError as error:
        if DEBUG: print(error)
    except OSError as error:
        print(error)
        sys.exit()
    

def processImages(filename):
    global COUNT
    if DEBUG: print(filename)
    try:
        im=Image.open(filename,"r")
        mvdir="%sx%s" % (im.size)
        path_mvdir=os.path.join(DIR,mvdir)
        if DEBUG: print("%s to be moved to %s" % (os.path.basename(filename),path_mvdir))
        create_if_not_exists(path_mvdir)
        newfile=os.path.join(path_mvdir, os.path.basename(filename))
        if movefile(filename,newfile,path_mvdir):
            COUNT +=1
    except IOError:
        if not (process_xcf(filename) or process_svg(filename)):
            if DEBUG: print("%s : Not an image file" % filename)
    except OverflowError:
        if DEBUG: print("%s : Too big to process" % filename)

def main():
    args=sys.argv[1:]
    for arg in args:
        checkfiles(arg)
    print("%d files processed" % COUNT)

if __name__=="__main__":
    COUNT=0
    DEBUG,QUIET=False,True
    DIR="pictures"
    DIR=os.path.join(os.getenv("HOME"),DIR)
    main()

# vim: set foldmethod=indent:
