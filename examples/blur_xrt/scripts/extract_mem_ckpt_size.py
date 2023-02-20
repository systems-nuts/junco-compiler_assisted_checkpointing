import os
import sys, getopt
import random
import json

def main(argv):
    copy_back = False
    inFile = None
    outDirectory = None
    kernel_name = ''
    try:
        opts, args = getopt.getopt(argv,"hi:o:n:",[""])
    except getopt.GetoptError:
        print("extract_mem_ckpt.py -i <input file path> -o <output directory>")
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print("extract_mem_ckpt.py -i <input file path> -o <output directory>")
            sys.exit()
        elif opt in ("-i"):
            inFile = arg
            print("Input file is ", inFile)
        elif opt in ("-o"):
            outDirectory = arg
            print("Output directory is ", outDirectory)
        
    if inFile == None:
        print("Error: An input file must be specified")
        sys.exit()
            
    ifile = open(inFile, 'r')
    data = json.load(ifile)

    max_size = 0
    print("Search for the size of the checkpoint memory segment")
    for l in data:
        for key, value in data[l].items():
            print(key, value)
            if (value > max_size):
                max_size = value
    

    ifile.close()
    f = open(str(outDirectory+"/ckpt_mem_def.h"), "w")
    f.write(str("#define CKPT_MEM_SIZE "+str(max_size)))
    f.close()
    return max_size

if __name__ == "__main__":
    ret = main(sys.argv[1:])
    #sys.exit(ret)
