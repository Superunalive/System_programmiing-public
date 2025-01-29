asm: Home.asm
	fasm Home.asm

c: asm Home.c 
	gcc Home.c Home.o -o useme

run: c useme
	./useme

clean:
	rm -f *.o