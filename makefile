
# sudo apt-get install g++ binutils libc6-dev-i386
# sudo apt-get install VirtualBox grub-legacy xorriso

MACHINENAME=MyOS
GCCPARAMS = -m32 -fno-use-cxa-atexit -nostdlib -fno-builtin -fno-rtti -fno-exceptions -fno-leading-underscore
ASPARAMS = --32
LDPARAMS = -melf_i386

objects = loader.o gdt.o port.o kernel.o

%.o: %.cpp
	gcc $(GCCPARAMS) -c -o $@ $<

%.o: %.s
	as $(ASPARAMS) -o $@ $<

mykernel.bin: linker.ld $(objects)
	ld $(LDPARAMS) -T $< -o $@ $(objects)

mykernel.iso: mykernel.bin
	mkdir iso
	mkdir iso/boot
	mkdir iso/boot/grub
	cp mykernel.bin iso/boot/mykernel.bin
	echo 'set timeout=0'                      > iso/boot/grub/grub.cfg
	echo 'set default=0'                     >> iso/boot/grub/grub.cfg
	echo ''                                  >> iso/boot/grub/grub.cfg
	echo 'menuentry "My Operating System" {' >> iso/boot/grub/grub.cfg
	echo '  multiboot /boot/mykernel.bin'    >> iso/boot/grub/grub.cfg
	echo '  boot'                            >> iso/boot/grub/grub.cfg
	echo '}'                                 >> iso/boot/grub/grub.cfg
	grub-mkrescue --output=mykernel.iso iso
	rm -rf iso

run: mykernel.iso
	(killall VirtualBox && sleep 1) || true
	VBoxManage createvm --name $(MACHINENAME) --ostype "Debian_64" --register
	VBoxManage modifyvm $(MACHINENAME) --ioapic on
	VBoxManage modifyvm $(MACHINENAME) --memory 1024 --vram 128
	VBoxManage modifyvm $(MACHINENAME) --nic1 nat

	#Set memory and network
	VBoxManage modifyvm $(MACHINENAME) --ioapic on
	VBoxManage modifyvm $(MACHINENAME) --memory 1024 --vram 128
	VBoxManage modifyvm $(MACHINENAME) --nic1 nat
	#Create Disk and connect mykernel iso
	VBoxManage createhd --filename `pwd`/$(MACHINENAME)/$(MACHINENAME)_DISK.vdi --size 80000 --format VDI
	VBoxManage storagectl $(MACHINENAME) --name "SATA Controller" --add sata --controller IntelAhci
	VBoxManage storageattach $(MACHINENAME) --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium  `pwd`/$(MACHINENAME)/$(MACHINENAME)_DISK.vdi
	VBoxManage storagectl $(MACHINENAME) --name "IDE Controller" --add ide --controller PIIX4
	VBoxManage storageattach $(MACHINENAME) --storagectl "IDE Controller" --port 1 --device 0 --type dvddrive --medium `pwd`/mykernel.iso
	VBoxManage modifyvm $(MACHINENAME) --boot1 dvd --boot2 disk --boot3 none --boot4 none

	#Start the VM
	VBoxHeadless --startvm $(MACHINENAME)

install: mykernel.bin
	sudo cp $< /boot/mykernel.bin

.PHONY: clean
clean:
	rm -f $(objects) mykernel.bin mykernel.iso





