asm: 5.asm
	fasm 5.asm

link: asm 5.o 
	ld 5.o -lc -lncurses -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o useme

run: link useme
	./useme

clean:
	rm -f *.o