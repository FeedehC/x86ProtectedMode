all:
	as -g -o main.o main2.S
	ld --oformat binary -o main.img -T link.ld main.o
	qemu-system-i386 -fda main.img -boot a -s -S -monitor stdio
clean:
	rm *.o