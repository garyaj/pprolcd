# pprolcd

## Papilio Pro + RetroCade LCD display driver

### Prerequisites

* [Papilio Pro](http://www.gadgetfactory.net/papilio-wings) development board for the [Xilinx Spartan 6 LX FPGA](xilinx.com/products/silicon-devices/fpga/spartan-6/index.htm)
* [RetroCade MegaWing](http://www.gadgetfactory.net/papilio-wings) peripheral board for Papilio Pro which contains a 16x2 HD44780 LCD display
* [Xilinx's ISE Design Suite 14.4](http://www.xilinx.com/support/download/index.htm) or later (part of their Vivado Design Suite) to synthesise and implement the design
* [Gadget Factory's Papilio Loader](https://github.com/GadgetFactory/Papilio-Loader) to load the resulting .bit file into the Spartan 6 FPGA.
* [s3e starter kit code](http://www.xilinx.com/products/boards/s3astarter/reference_designs.htm). Modified below
* [PicoBlaze for the Spartan 6](http://www.xilinx.com/products/intellectual-property/picoblaze.htm). The downloadable contains:
	* `kcpsm6.vhd`, a macro file which defines a PicoBlaze 8-bit microcontroller in the S6 FPGA
	* `kcpsm6.exe`, an assembler which compiles assembly code into VHDL code
	* various ROM definitions files and templates
* A PC to run the development environment. I'm using a MacBook Air with Parallels Desktop running Windows 7.


#### Intro

The RetroCade has a 2x16 LCD display on it so I thought I'd like to write a program to use it to display some text.

The idea was to re-write the Spartan-3e code to use the Spartan6 on the Papilio Pro and to change the constraints file to use the pins and display on the RetroCade rather than those on the s3 starter kit board.

The starterkit code for the s3 adds a PicoBlaze 8-bit micro-controller (KCPSM3) to the design which uses less than 5% of the available circuitry. An updated version of the PicoBlaze for the s6 (KCPSM6) uses even less circuitry.

#### Usage
The files in this repository can be used at three different levels.

1. Load the `pprolcd.bit` file into the PPro using the loader and watch the pretty display.
2. Open `pprolcd.xise` with the ISE design suite and compile the design files (modify to taste) then upload as in step 1.
3. Modify the assembly code (`control.psm`) to do different things or display different text. This requires `control.psm` to be compiled (Run `kcpsm6.exe` in Windows and enter 'control.psm' as the filename to assemble.) Then follow step 2 and then step 1.

##### Files

* `pprolcd.xise` the ISE project
* `pprolcd.vhd` the top-level entity declaration
* `kcpsm6.vhd` (supplied by Xilink) defines the PicoBlaze micro-controller in the FPGA circuitry
* `control.psm` an assembly language program which actually runs the PicoBlaze
* `kcpsm6.exe` (supplied by Xilinx) assembler translates `control.psm` into VHDL
* `control.vhd` the output of the assembler for inclusion in the project. This file defines a ROM for the FPGA which contains the instructions for the PicoBlaze.
* `constraints.ucf` maps the pins on the S6 FPGA to the corresponding pins on the RetroCade
* `ROM_form.vhd` (supplied by Xilinx) definitions for assembler (`kcpsm6.exe`)

