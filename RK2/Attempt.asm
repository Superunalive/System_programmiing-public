format elf64

;comments for me
; 1 - get all commands here
; 2 - get it to print from address
; 3 - read from file
; 4 - put in mmap
; 5 - profit

; next program
; 1 - learn clone
; 2 - create array
; 3 - modify array parallel to each other (clone array?)
; 4 - combine results

;first task in priority, then start Lab 7. This will make second task easier.
	public _start

	extrn initscr
	extrn endwin
	extrn refresh
	extrn stdscr
	extrn getmaxx
	extrn getmaxy
	extrn move
	extrn start_color
	extrn init_pair
	extrn addch
	extrn getch
	extrn timeout
	extrn mydelay
	extrn noecho

	include 'func.asm'

	section '.test' executable

_start:
	