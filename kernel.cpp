
#include "types.h"
#include "gdt.h"

void printf(const char* str) {
    static uint16_t* VideoMemory = (uint16_t*)0xb8000;

    static uint8_t x=0,y=0;

    for(int i = 0; str[i] != '\0'; ++i) {
        switch(str[i]) {
            case '\n':
                x = 0;
                y++;
                break;
            default:
                VideoMemory[80*y+x] = (VideoMemory[80*y+x] & 0xFF00) | str[i];
                x++;
                break;
        }

        if(x >= 80) {
            x = 0;
            y++;
        }

        if(y >= 25) {
            for(y = 0; y < 25; y++)
                for(x = 0; x < 80; x++)
                    VideoMemory[80*y+x] = (VideoMemory[80*y+x] & 0xFF00) | ' ';
            x = 0;
            y = 0;
        }
    }
}

typedef void (*constructor)();
extern "C" constructor start_ctors;
extern "C" constructor end_ctors;
extern "C" void callConstructors() {
    for(constructor* i = &start_ctors; i != &end_ctors; i++)
        (*i)();
}

/* 
    We have made it extern “C” so that the compiler will not change the name of the function. 
    So we can call it from the assembly file using the exact same name.

    In the our operating system we still can’t use the C++ libraries. So there is no printf function we can use. 
    We have to implement the printf function by ourselves. The logic behind the printf function is that the monitor 
    will print anything that is inserted into 0xb8000 memory location. So we just have to insert the text into that 
    memory location.
*/
extern "C" void kernelMain(const void* multiboot_structure, uint32_t /*multiboot_magic*/) {
    printf("Hello World!");

    GlobalDescriptorTable gdt;

    while(1);
}
