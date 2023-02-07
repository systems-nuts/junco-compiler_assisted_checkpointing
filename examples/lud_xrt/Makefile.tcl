#######################################################################################
.PHONY: help
help:
	@echo "Makefile Usage:"
	@echo "  make all TARGET=<sw_emu/hw_emu/hw> DEVICE=<FPGA platform>"
	@echo "      Command to generate the design for specified Target and Device."
	@echo ""
	@echo "  make exe "
	@echo "      Command to generate host."
	@echo ""
	@echo "  make xclbin "
	@echo "      Command to generate hardware platform files(xo,xclbin)."
	@echo ""
	@echo "  make clean "
	@echo "      Command to remove the generated files."
	@echo ""
#######################################################################################
TARGET := hw
DEVICE := xilinx_u50_gen3x16_xdma_201920_3
EXECUTABLE := host
XO := kernel.xo
XCLBIN := krnl.$(TARGET).$(DEVICE).xclbin
DIR_PRJ = ./proj
SCRIPTS_DIR = ./scripts
VIVADO:=vivado
HDLSRCS= $(DIR_PR)/kernel.xml
kernel_sources = hls_example.cpp

KERN_NAME = krnl_vadd

# Host building global settings
CXXFLAGS := -I$(XILINX_XRT)/include/ -I$(XILINX_VIVADO)/include/ -Wall -O0 -g -std=c++11 -L$(XILINX_XRT)/lib/ -lOpenCL -pthread -lrt -lstdc++
CXXFLAGS2 := -lOpenCL
xrt_LDFLAGS += -L$(XILINX_XRT)/lib -lxrt_coreutil -pthread

# Kernel compiler & linker global settings
CLFLAGS := -t $(TARGET) --platform $(DEVICE) -g
LDCLFLAGS := -t $(TARGET) --platform $(DEVICE) --config run1.cfg

all: $(EXECUTABLE) $(XO) $(XCLBIN) emconfig

exe: $(EXECUTABLE)

xclbin: $(XO) $(XCLBIN)

# Building kernel
$(XO): $(kernel_sources) $(DIR_PRJ)/solution1/impl/vhdl/*.vhd $(DIR_PRJ)/kernel.xml
	vitis_hls $(SCRIPTS_DIR)/c_to_hdl.tcl
	$(VIVADO) -mode batch -source $(SCRIPTS_DIR)/gen_xo.tcl -notrace -tclargs kernel.xo $(KERN_NAME) ${TARGET} ${DEVICE} $(SCRIPTS_DIR)/create_vivado_project.tcl

$(XCLBIN): $(XO) 
	v++ $(LDCLFLAGS) -l -o'$@' $(+)

# Building Host
$(EXECUTABLE): ./user-host.cpp
	g++ $(CXXFLAGS) -o '$@' '$<' $(CXXFLAGS2) $(xrt_LDFLAGS)

.PHONY: emconfig
emconfig:
	emconfigutil --platform $(DEVICE)

.PHONY: run
run: all
ifeq ($(TARGET),$(filter $(TARGET),sw_emu hw_emu))
	XCL_EMULATION_MODE=$(TARGET) ./$(EXECUTABLE) $(XCLBIN)
else
	./$(EXECUTABLE) $(XCLBIN)
endif


# Cleaning stuff
.PHONY: clean

RMDIR = rm -rf

clean:
	-$(RMDIR) $(EXECUTABLE) $(XCLBIN)/{*sw_emu*,*hw_emu*}
	-$(RMDIR) TempConfig system_estimate.xtxt *.rpt
	-$(RMDIR) *.protoinst _v++_* .Xil emconfig.json dltmp* xmltmp* *.log *.jou 

cleanall: clean
	-$(RMDIR) $(XCLBIN) *.xo *.xclbin* *.wcfg *.wdb *.csv *.compile_summary *.run_summary
	-$(RMDIR) _x* .run/
	-$(RMDIR) -R proj packaged_*

