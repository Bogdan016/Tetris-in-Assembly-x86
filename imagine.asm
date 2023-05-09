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

.code
; Make an image at the given coordinates
; arg1 - pointer to the pixel vector
; arg2 - x of drawing start position
; arg3 - y of drawing start position



make_image proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg4]			;eax=0 (ROSU) eax=1 (ALBASTRU) eax=2 (PORTOCALIU) eax=3 (PORTOCALIU) eax=4 (VERDE) eax=5 (ALB) eax=6 (PLAYGROUND) 
	cmp eax, 0
	je rosu
	
	
rosu: 
	lea esi, var_1
	jmp draw_image
	
; rosu: 
	; lea esi, var_1
	; jmp draw_image
; rosu: 
	; lea esi, var_1
	; jmp draw_image
; rosu: 
	; lea esi, var_1
	; jmp draw_image
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

	make_image_macro area, 20, 20, 0; draw the given image at coordinates (26,26)

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