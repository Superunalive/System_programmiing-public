asm: task_2.asm
	fasm task_2.asm

c: asm task_2.o 
	ld -o useme task_2.o -lc -dynamic-linker /lib64/ld-linux-x86-64.so.2

run: c useme
	./useme

clean:
	rm -f *.o