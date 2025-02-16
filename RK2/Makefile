asm: task1.asm
	fasm task1.asm

link: asm task1.o 
	ld task1.o -lc -lncurses -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o useme

run: link useme
	./useme file.txt

clean:
	rm -f *.o