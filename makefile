
ARMGNU = aarch64-linux-gnu-
CC = $(ARMGNU)gcc
LDFLAGS = -T linker.ld -nostdlib
SDCARD ?= /dev/sdb
HEADER := $(wildcard *.h)
SRC := $(wildcard *.c)
OBJECTS := $(patsubst %.c,%.o,$(SRC))
ASM := $(wildcard *.S)
CFLAGS = -fPIC -fno-stack-protector -nostdlib -nostartfiles -ffreestanding

.PHONY: all clean qemu debug indent

all: kernel8.img 

$(wildcard */*.o): $(SRC) $(HEADER)

kernel8.elf: $(ASM) $(OBJECTS) user_program
#	$(CC) $(LDFLAGS) -o $@ $(ASM) $(OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $(ASM) $(OBJECTS) user_program

kernel8.img: kernel8.elf 
	$(ARMGNU)objcopy -O binary kernel8.elf kernel8.img

send_kernel:
	sudo python load_images.py --port "/dev/ttyUSB0" --kernel "kernel8.img"

clean:
	rm -f kernel8.elf kernel8.img $(patsubst %,%~*,$(SRC) $(HEADER)) $(OBJECTS)
	rm -f code_test/*.o user_program


run:
	qemu-system-aarch64 -M raspi3 -kernel kernel8.img -serial stdio -display none

run-detail:
	qemu-system-aarch64 -M raspi3 -kernel kernel8.img -serial null -serial stdio

run-mini-uart:
	qemu-system-aarch64 -M raspi3 -kernel kernel8.img -serial null -serial pty

run-uart0:
	qemu-system-aarch64 -M raspi3 -kernel kernel8.img -serial pty

run-script:
	sudo python script.py

connect:
	sudo screen /dev/ttyUSB0 115200

check-elf:
	aarch64-linux-gnu-readelf -s kernel8.elf

code_test/test.o: code_test/test.c code_test/lib.o
	 $(ARMGNU)gcc $(COPS) -fno-zero-initialized-in-bss -nostdlib -g -c code_test/test.c -o code_test/test.o -fPIC

code_test/lib.o: code_test/lib.S
	$(ARMGNU)gcc $(COPS) -g -c  code_test/lib.S -o code_test/lib.o -fPIC

code_test/lib_c.o: code_test/lib.c
	$(ARMGNU)gcc $(COPS) -g -c  code_test/lib.c -o code_test/lib_c.o -fno-stack-protector -nostdlib -fPIC


user_program: code_test/test.o code_test/lib.o code_test/lib_c.o
	$(ARMGNU)ld -T code_test/linker.ld -o test.elf code_test/test.o  code_test/lib.o code_test/lib_c.o
	$(ARMGNU)objcopy test.elf -O binary test.img
	$(ARMGNU)ld -r -b binary test.img -o user_program

