import os
import sys, getopt
import random
import json

def main(argv):
    copy_back = False
    inFile = None
    outFile = None
    kernel_name = ''
    try:
        opts, args = getopt.getopt(argv,"hi:o:n:",[""])
    except getopt.GetoptError:
        print("add_mem_ckpt_param.py -i <input file path> ")
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print("add_mem_ckpt_param.py -i <input file path> ")
            sys.exit()
        elif opt in ("-i"):
            inFile = arg
            print("Input file is ", inFile)
        
    if inFile == None:
        print("Error: An input file must be specified")
        sys.exit()

    outFile = "/tmp/kernel.cpp"
    ifile = open(inFile, 'r')
    ofile = open(outFile, 'w')
    
    last_fct_signature = ""
    while(1):
        #parse input file
        line = ifile.readline()
        
        if (len(line) == 0):
            break

        if "void" in line:
            last_fct_signature = line
        elif "#pragma HLS INTERFACE" in line:
            break

    ifile.seek(0, 0)

    pragma_num = 0
    pragma_added = False
    while(1):
        #parse input file
        line = ifile.readline()
        
        if (len(line) == 0):
            break

        if last_fct_signature in line:
            if "ckpt_mem" not in line:
                modified_line = str(line[:-2]+", float* ckpt_mem)")
                ofile.write(modified_line)
            else:
                ofile.write(line)
                pragma_added = True
        elif "#pragma HLS INTERFACE" in line:
            pragma_num += 1
            ofile.write(line)
        elif pragma_num > 0 and not pragma_added:
            modified_line = "#pragma HLS INTERFACE m_axi port=ckpt_mem offset=slave bundle=gmem\n" + "#pragma HLS INTERFACE s_axilite port=ckpt_mem bundle=control\n" + line
            ofile.write(modified_line)
            pragma_added = True
        else:
            ofile.write(line)

    ifile.close()
    ofile.close()

if __name__ == "__main__":
    ret = main(sys.argv[1:])
