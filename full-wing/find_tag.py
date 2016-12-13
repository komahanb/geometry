# Import some utilities
import numpy as np
import sys, traceback

# Read the input file
def readInputFile(filename):
    """
    Method to read the input file and return the data as string.
    """
    try:
        inpFile = open(filename, "r")
        content = list(inpFile.readlines())
        inpFile.close()
    except:
        raise IOError
    return content

def loadMesh():
    inputfile = 'wing.bdf'
    bdf       = readInputFile(inputfile)
    tag  = []
    for line in bdf:
        entry = line.split()
        if entry[0] == "CQUAD9":
            print entry[0], entry[1], int(entry[2])
            tag.append(int(entry[2]))
    return tag
        
def remove_duplicates(x):
    a = []
    for i in x:
        if i not in a:
            a.append(i)
    return a

######################################################################
#                    Setup truss
######################################################################

tags = loadMesh()
unid = remove_duplicates(tags)
print unid, len(unid)
