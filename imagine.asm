.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc

includelib canvas.lib
extern BeginDrawing: proc

public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
.data
window_title DB "Example project",0
area_width EQU 640
area_height EQU 490
area DD 0

; writing argument offsets as constants for better readability
arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

image_width DD 20
image_height DD 20

include 1rosu.inc
include 1albastru.inc
include 1portocaliu.inc
include 1verde.inc
include 1galben.inc
include 1mov.inc
include 1alb.inc
include pgpt1.inc
; include playgroud2.inc


.code
; Make an image at the given coordinates
; arg1 - pointer to the pixel vector
; arg2 - x of drawing start position
; arg3 - y of drawing start position



make_image proc
	push ebp
	mov ebp, esp
	pusha
								;eax=0 (ROSU are var_0)   eax=1 (ALBASTRU are var_1) eax=2 (PORTOCALIU are var_2) eax=3 (VERDE are var_3) 
								;eax=4 (GALBEN are var_4) eax=5 (MOV are var_5)      eax=6 (ALB are var_6)        eax=7 (PLAYGROUND?????) 
								
	mov eax, [ebp+arg4]			
	cmp eax, 0
	je rosu
	
	cmp eax, 1
	je albastru
	
	cmp eax, 2
	je portocaliu
	
	cmp eax, 3
	je verde

	cmp eax, 4
	je galben
	
	cmp eax, 5
	je moov
	
	cmp eax, 6
	je alb
	
	; cmp eax, 7
	; je playground
	

rosu: 
	lea esi, var_0
	jmp draw_image
	
albastru: 
	 lea esi, var_1
	 jmp draw_image
	 
portocaliu: 
	lea esi, var_2
	jmp draw_image
	
verde: 
	lea esi, var_3
	jmp draw_image

galben: 
	lea esi, var_4
	jmp draw_image

moov: 
	lea esi, var_5
	jmp draw_image	

alb:
	lea esi, var_6
	jmp draw_image	

; playground:
	
	
draw_image:
	mov ecx, image_height
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	
	add eax, image_height 
	sub eax, ecx ; current line to draw (total - ecx)
	
	mov ebx, area_width
	mul ebx	; get to current line
	
	add eax, [ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	
	push ecx
	mov ecx, image_width ; store drawing width for drawing loop
	
loop_draw_columns:

	push eax
	mov eax, dword ptr[esi] 
	mov dword ptr [edi], eax ; take data from variable to canvas
	pop eax
	
	add esi, 4
	add edi, 4 ; next dword (4 Bytes)
	
	loop loop_draw_columns
	
	pop ecx
	loop loop_draw_lines
	popa
	
	mov esp, ebp
	pop ebp
	ret
make_image endp

; simple macro to call the procedure easier
make_image_macro macro drawArea, x, y, nr_img
	push nr_img
	push y
	push x
	push drawArea
	call make_image
	add esp, 16
endm

draw proc
	push ebp
	mov ebp, esp
	pusha

	;initialize window with white pixels
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12


	make_image_macro area, 50,30
	
	make_image_macro area, 50, 30, 0
	make_image_macro area, 70, 30, 0
	make_image_macro area, 90, 30, 1
	make_image_macro area, 110, 30, 1
	make_image_macro area, 130, 30, 2
	make_image_macro area, 150, 30, 2
	make_image_macro area, 170, 30, 3
	make_image_macro area, 190, 30, 3
	make_image_macro area, 210, 30, 4
	make_image_macro area, 230, 30, 4
	make_image_macro area, 250, 30, 5
	make_image_macro area, 270, 30, 5

	make_image_macro area, 20, 40, 0
	make_image_macro area, 40, 40, 0
	make_image_macro area, 60, 40, 1
	make_image_macro area, 80, 40, 1
	make_image_macro area, 100, 40, 2
	make_image_macro area, 120, 40, 2
	make_image_macro area, 140, 40, 3
	make_image_macro area, 160, 40, 3
	make_image_macro area, 180, 40, 4
	make_image_macro area, 200, 40, 4
	make_image_macro area, 220, 40, 5
	make_image_macro area, 240, 40, 5
	
	make_image_macro area, 20, 60, 0
	make_image_macro area, 40, 60, 0
	make_image_macro area, 60, 60, 1
	make_image_macro area, 80, 60, 1
	make_image_macro area, 100, 60, 2
	make_image_macro area, 120, 60, 2
	make_image_macro area, 140, 60, 3
	make_image_macro area, 160, 60, 3
	make_image_macro area, 180, 60, 4
	make_image_macro area, 200, 60, 4
	make_image_macro area, 220, 60, 5
	make_image_macro area, 240, 60, 5
	
	make_image_macro area, 20, 80, 0
	make_image_macro area, 40, 80, 0
	make_image_macro area, 60, 80, 1
	make_image_macro area, 80, 80, 1
	make_image_macro area, 100, 80, 2
	make_image_macro area, 120, 80, 2
	make_image_macro area, 140, 80, 3
	make_image_macro area, 160, 80, 3
	make_image_macro area, 180, 80, 4
	make_image_macro area, 200, 80, 4
	make_image_macro area, 220, 80, 5
	make_image_macro area, 240, 80, 5

	make_image_macro area, 20, 100, 0
	make_image_macro area, 40, 100, 0
	make_image_macro area, 60, 100, 1
	make_image_macro area, 80, 100, 1
	make_image_macro area, 100, 100, 2
	make_image_macro area, 120, 100, 2
	make_image_macro area, 140, 100, 3
	make_image_macro area, 160, 100, 3
	make_image_macro area, 180, 100, 4
	make_image_macro area, 200, 100, 4
	make_image_macro area, 220, 100, 5
	make_image_macro area, 240, 100, 5
	
	make_image_macro area, 20, 120, 0
	make_image_macro area, 40, 120, 0
	make_image_macro area, 60, 120, 1
	make_image_macro area, 80, 120, 1
	make_image_macro area, 100, 120, 2
	make_image_macro area, 120, 120, 2
	make_image_macro area, 140, 120, 3
	make_image_macro area, 160, 120, 3
	make_image_macro area, 180, 120, 4
	make_image_macro area, 200, 120, 4
	make_image_macro area, 220, 120, 5
	make_image_macro area, 240, 120, 5
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	; alloc memory for the drawing zone
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax

	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	push 0
	call exit
end start
