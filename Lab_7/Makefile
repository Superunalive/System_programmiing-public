asm: Sandbox.asm
	fasm Sandbox.asm

link: asm Sandbox.o 
	ld Sandbox.o -o useme

run: link useme
	./useme file.txt

clean:
	rm -f *.o