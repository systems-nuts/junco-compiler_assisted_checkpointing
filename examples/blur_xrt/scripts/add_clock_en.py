import os
import sys, getopt
import random

def main(argv):
    copy_back = False
    inFile = None
    outFile = None
    kernel_name = ''
    try:
        opts, args = getopt.getopt(argv,"hi:o:n:",[""])
    except getopt.GetoptError:
        print("add_clock_en.py -i <input file path> -o <input file path> -n <kernel name>")
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print("add_clock_en.py -i <input file path> -o <input file path> -n <kernel name>")
            sys.exit()
        elif opt in ("-i"):
            inFile = arg
            print("Input file is ", inFile)
        elif opt in ("-o"):
            outFile = arg
            print("Input file is ", outFile)
        elif opt in ("-n"):
            kernel_name = arg
            print("kernel name is ", kernel_name)

    if inFile == None:
        print("Error: An input file must be specified")
        sys.exit()
    elif outFile == None:
        print("Warning: No ouput file mentioned. The input file will be rewritten!")
        outFile = inFile+".tmp"
        copy_back = True
            
    ifile = open(inFile, 'r')
    ofile = open(outFile, 'w')
    
    body_module = False
    first_wire = True
    first_assign = True
    checkpoint_def = False
    ap_start_name = ''
    while(1):
            #parse input file
            line = ifile.readline()

            if (len(line) == 0):
                break

            if "initial begin" in line :
                body_module = True
                ofile.write(line)
            elif first_wire and "wire" in line:
                first_wire = False
                ofile.write(line)
                ofile.write("wire    clken;\n")
                ofile.write("wire    clken_n;\n")
            elif body_module and kernel_name+"_checkpoint" in line:
                checkpoint_def = True
                ofile.write(line)
            elif checkpoint_def and ");" in line:
                checkpoint_def = False
                ofile.write(line)
            elif checkpoint_def and "ap_start" in line:
                fields = line.split("(")
                subfields = fields[1].split(")")
                ap_start_name = subfields[0]
                ofile.write(line)
            elif checkpoint_def and (body_module == True) and ("(ap_clk)" in line):
                fields = line.split("(")
                subfields = fields[1].split(")")
                new_line =  fields[0] + "(ap_clk & clken_n)" + subfields[1]
                ofile.write(new_line)
            elif (body_module == True) and ("(ap_clk)" in line):
                fields = line.split("(")
                subfields = fields[1].split(")")
                new_line =  fields[0] + "(ap_clk & clken)" + subfields[1]
                ofile.write(new_line)
            #elif (body_module == True) and ("(posedge ap_clk)" in line):
            #    fields = line.split("posedge")
            #    subfields = fields[1].split(")")
            #    new_line =  fields[0] + "posedge ap_clk & clken)" + subfields[1]
            #    ofile.write(new_line)
            elif first_assign and "assign" in line:
                first_assign = False
                ofile.write(line)
                ofile.write("assign clken_n = " + ap_start_name +";\n")
                ofile.write("assign clken = ~(clken_n);\n")
            else:
                ofile.write(line)

    ifile.close()
    ofile.close()
    if(copy_back):
        os.rename(outFile, inFile)

if __name__ == "__main__":
    main(sys.argv[1:])
