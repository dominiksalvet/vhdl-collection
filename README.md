# VHDL Collection

Handy generic VHDL modules that can be used as part of a VHDL project. Every VHDL module has been simulated and works as intended. Test bench files of the simulation are included in the module's appropriate directory as well. A project file is also published with set up all the VHDL modules using and so they can be tested before real use in this prepared sandbox. The modules are not intended to be top-level entities of projects.

## To do list
* use [GHDL](https://github.com/ghdl/ghdl) to build together with makefile
* change this description to reflect the new building system
* *cache.vhd* + *cache_tb.vhd*

## Modules
* [Clock Divider](rtl/clk_divider.vhdl)
* [First In, First Out](rtl/fifo.vhdl)
* [Last In, First Out](rtl/lifo.vhdl)
* [Memory Copier](rtl/mem_copier.vhdl)
* [Parallel In, Serial Out](rtl/piso.vhdl)
* [Pulse-Width Modulation](rtl/pwm.vhdl)
* [Random-Access Memory](rtl/ram.vhdl)
* [Read-Only Memory](rtl/rom.vhdl)
* [Seven-Segment Display Driver](rtl/seg7_driver.vhdl)
* [Serial In, Parallel Out](rtl/sipo.vhdl)
* [Static Clock Divider](rtl/static_clk_divider.vhdl)

## Documentation

The modules are documented inside it's VHDL source files using comment headers and inline comments.

## License

This project is licensed under an Open Source Initiative approved license, the MIT License. See the [*LICENSE.txt*](LICENSE.txt) file for details.

<p align="center">
  <a href="http://opensource.org/">
    <img src="https://opensource.org/files/osi_logo_bold_300X400_90ppi.png" width="100">
  </a>
</p>
