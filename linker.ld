/*
    The linker file will combine the above two files into a one.
    Every link is controlled by a linker script. This script is written in the linker command language.
    
    It takes a number of compiled object files and merges them into a single program, 
    filling in addresses so that everything is in the right place.

    The output file and each input file are in a special data format known as an object file format. 

    Each file is called an object file. The output file is often called an executable, but for our purposes 
    we will also call it an object file.

    Each object file has, among other things, a list of sections. 
    
    We sometimes refer to a section in an input file as an input section; similarly, a section in the output 
    file is an output section. 

    https://users.informatik.haw-hamburg.de/~krabat/FH-Labor/gnupro/5_GNUPro_Utilities/c_Using_LD/ldLinker_scripts.html#Concepts

    https://docs.huihoo.com/redhat//rhel-4-docs/rhel-ld-en-4/scripts.html

    https://sourceware.org/binutils/docs-2.25/ld/Scripts.html#Scripts
*/

ENTRY(loader)
OUTPUT_FORMAT(elf32-i386)
OUTPUT_ARCH(i386:i386)

SECTIONS
{
  . = 0x0100000;

  .text :
  {
    *(.multiboot)
    *(.text*)
    *(.rodata)
  }

  .data  :
  {
    start_ctors = .;
    KEEP(*( .init_array ));
    KEEP(*(SORT_BY_INIT_PRIORITY( .init_array.* )));
    end_ctors = .;

    *(.data)
  }

  .bss  :
  {
    *(.bss)
  }

  /DISCARD/ : { *(.fini_array*) *(.comment) }
}
