asm: Attempt.asm
	fasm Attempt.asm

link: asm Attempt.o 
	ld Attempt.o -lc -lncurses -dynamic-linker /lib64/ld-linux-x86-64.so.2 -o useme

run: link useme
	./useme file.txt

clean:
	rm -f *.o