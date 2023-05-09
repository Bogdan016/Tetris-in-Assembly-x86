.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern printf: proc

includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Tetris",0
area_width EQU 640
area_height EQU 490
area DD 0

stanga DD 0
sus DD 0
val DD 0
format DB "%d",13,10,0

matrice DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2
		DD  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
		
		
		
square_size EQU 20
matrix_width EQU 12 * 4
matrix_height EQU 22 * 4

margin_top EQU 30
margin_left EQU 50
margin_right EQU 250
margin_bot EQU 450

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
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
; include playgroud2.inc

symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc

.code
; procedura make_text afiseaza o litera sau o cifra la coordonatele date
; arg1 - simbolul de afisat (litera sau cifra)
; arg2 - pointer la vectorul de pixeli
; arg3 - pos_x
; arg4 - pos_y
make_text proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1] ; citim simbolul de afisat
	cmp eax, 'A'
	jl make_digit
	cmp eax, 'Z'
	jg make_digit
	sub eax, 'A'
	lea esi, letters
	jmp draw_text
make_digit:
	cmp eax, '0'
	jl make_space
	cmp eax, '9'
	jg make_space
	sub eax, '0'
	lea esi, digits
	jmp draw_text
make_space:	
	mov eax, 26 ; de la 0 pana la 25 sunt litere, 26 e space
	lea esi, letters
	
draw_text:
	mov ebx, symbol_width
	mul ebx
	mov ebx, symbol_height
	mul ebx
	add esi, eax
	mov ecx, symbol_height
bucla_simbol_linii:
	mov edi, [ebp+arg2] ; pointer la matricea de pixeli
	mov eax, [ebp+arg4] ; pointer la coord y
	add eax, symbol_height
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg3] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, symbol_width
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_alb
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_alb:
	mov dword ptr [edi], 0FFFFFFh
simbol_pixel_next:
	inc esi
	add edi, 4
	loop bucla_simbol_coloane
	pop ecx
	loop bucla_simbol_linii
	popa
	mov esp, ebp
	pop ebp
	ret
make_text endp

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm


								;PROCEDURA PENTRU DESENAREA IMAGINII
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

; simple macro to call the procedure easier																	MACRO-UL PENTRU DESENAREA IMAGINII
make_image_macro macro drawArea, x, y, nr_img
	push nr_img
	push y
	push x
	push drawArea
	call make_image
	add esp, 16
endm

																	;MACRO PENTRU REPREZENTAREA UNEI LINII ORIZONTALE ( FOLOSIT PENTRU CREAREA TABLEI DE JOC )
orizontala macro x, y, lungime, culoare
local bucla1

	mov EAX, y				;EAX = y
	mov EBX, area_width
	mul EBX					;EAX = y * area_width
	add EAX, x				;EAX = y * area_width + x
	lea EAX, [EAX*4]		;inmultim cu 4 deci EAX = ( y * area_width + x ) * 4
	add EAX, area
	mov ECX, lungime
bucla1: 
	mov dword ptr [EAX], culoare
	add EAX, 4
	loop bucla1
endm 
																			;MACRO PENTRU REPREZENTAREA UNEI LINII VERTICALE ( FOLOSIT PENTRU CREAREA TABLEI DE JOC )
verticala macro x, y, lungime, culoare
local bucla1

	mov EAX, y				;EAX = y
	mov EBX, area_width
	mul EBX					;EAX = y * area_width
	add EAX, x				;EAX = y * area_width + x
	lea EAX, [EAX*4]		;inmultim cu 4 deci EAX = ( y * area_width + x ) * 4
	add EAX, area
	mov ECX, lungime
bucla1: 
	mov dword ptr [EAX], culoare
	add EAX, 4 * area_width
	loop bucla1
endm 
																	
															;MACRO PENTRU REPREZENTAREA UNUI PATRAT, PRIMESTE COORDONATELE X, Y MARIMEA PATRATULUI SI CULOAREA LUI
square macro x, y, color
local loop1, loop2
	mov eax, y          ; eax = y
	mov ebx, area_width ; ebx = area_width
	mul ebx             ; eax = y * area_width
	add eax, x          ; eax = y * area_width + x
	lea eax, [eax*4]    ; 
	add eax, area       ; eax = &area[y * area_width + x]

	mov ecx, 20         ; ecx = size
loop1:
	push ecx            ; punem contorul pe stiva
	mov ecx, 20       ; si il initializam din nou cu size ( pentru urmatorul rand )
loop2:
	mov dword ptr [eax], color 
	add eax, 4          
	loop loop2
	pop ecx             
	add eax, (area_width - 20) * 4 ; trecem la urmatorul rand
	loop loop1
endm
		

element macro pozy, pozx
	mov EAX, pozy
	mov EBX, matrix_width
	mul EBX
	mov EBX, EAX 
	mov EAX, pozx
	mov ECX,4
	mul ECX
	add EBX, EAX
	lea EAX, matrice
	mov EAX, [EAX+EBX]
endm



; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click, 3 - s-a apasat o tasta)
; arg2 - x (in cazul apasarii unei taste, x contine codul ascii al tastei care a fost apasata)
; arg3 - y
draw proc
	push ebp
	mov ebp, esp
	pusha
	
	mov eax, [ebp+arg1]
	cmp eax, 1
	jz evt_click
	cmp eax, 2
	jz evt_timer ; nu s-a efectuat click pe nimic
	;mai jos e codul care intializeaza fereastra cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
	jmp afisare_litere
	
evt_click:	
	; orizontala [EBP+arg2], [EBP+arg3], 20, 00EBBF3h
	
	jmp afisare_litere
	
evt_timer:
	inc counter
	
	
afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
	;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 30, 10
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 10
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 10
	
	;scriem un mesaj
	make_text_macro 'B', area, 570, 410
	make_text_macro 'O', area, 580, 410
	make_text_macro 'G', area, 590, 410
	make_text_macro 'D', area, 600, 410
	make_text_macro 'A', area, 610, 410
	make_text_macro 'N', area, 620, 410
	
	make_text_macro 'I', area, 560, 430
	make_text_macro 'S', area, 570, 430
	make_text_macro 'T', area, 580, 430
	make_text_macro 'R', area, 590, 430
	make_text_macro 'A', area, 600, 430
	make_text_macro 'T', area, 610, 430
	make_text_macro 'E', area, 620, 430
	
	make_text_macro 'S', area, 570, 30
	make_text_macro 'C', area, 580, 30
	make_text_macro 'O', area, 590, 30
	make_text_macro 'R', area, 600, 30

	make_text_macro 'N', area, 270, 30
	make_text_macro 'E', area, 280, 30
	make_text_macro 'X', area, 290, 30
	make_text_macro 'T', area, 300, 30
																										;AICI
																										;LUCREZ
																										;ACUM
	
matrice_joc:																						

	element 2, 1
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

	
afisare:

	
pune_patrat:
	
	
stop:

	
	
Piese_joc:
    ; T_tetromino_S1 350, 410, 00392cfh
	; T_tetromino_S2 350, 310, 05938C8h
	; T_tetromino_S3 490, 310, 0f9c22eh
	; T_tetromino_S4 350, 210, 00392cfh
	
	; Z_tetromino_S1 410, 310, 07bc043h
	; Z_tetromino_S2 410, 210, 07bc043h
	
	; I_tetromino_S1 450, 370, 0ee4035h
	; I_tetromino_S2 470, 210, 0ee4035h
	
	;O_tetromino 130, 410, 0f37736h


;			x, y, lungime, culoare						   			Aici desenez regiunea de joc, poate la final implementez cu imagine 
regiune_joc:
	 orizontala 50, 30, 200, 0
	 orizontala 50, 31, 200, 0											;linia de sus ( am pus de 3 ori sa fie mai vizibila )
	 orizontala 50, 32, 200, 0
	 
	 orizontala 50, 450, 203, 0
	 orizontala 50, 451, 203, 0
	 orizontala 50, 452, 203, 0
	 
	 verticala 50, 30, 420, 0
	 verticala 51, 30, 420, 0
	 verticala 52, 30, 420, 0
	 
	 verticala 250, 30, 420, 0
	 verticala 251, 30, 420, 0
	 verticala 252, 30, 420, 0

casute_joc:
	orizontala 50, 50, 200, 0
	orizontala 50, 70, 200, 0
	orizontala 50, 90, 200, 0
	orizontala 50, 110, 200, 0
	orizontala 50, 130, 200, 0
	orizontala 50, 150, 200, 0
	orizontala 50, 170, 200, 0
	orizontala 50, 190, 200, 0
	orizontala 50, 210, 200, 0
	orizontala 50, 230, 200, 0
	orizontala 50, 250, 200, 0
	orizontala 50, 270, 200, 0
	orizontala 50, 290, 200, 0
	orizontala 50, 310, 200, 0
	orizontala 50, 330, 200, 0
	orizontala 50, 350, 200, 0
	orizontala 50, 370, 200, 0
	orizontala 50, 390, 200, 0
	orizontala 50, 410, 200, 0
	orizontala 50, 430, 200, 0

    verticala 70, 30, 420, 0
    verticala 90, 30, 420, 0
    verticala 110, 30, 420, 0
    verticala 130, 30, 420, 0
    verticala 150, 30, 420, 0
    verticala 170, 30, 420, 0
    verticala 190, 30, 420, 0
    verticala 210, 30, 420, 0
    verticala 230, 30, 420, 0
   
paleta_de_culori:
     
	 square 490, 430 , 0f9c22eh
	 square 510, 430 , 00392cfh
	 square 530, 430 , 05938C8h
	
	 square 490, 410 , 07bc043h
	 square 510, 410 , 0ee4035h
	 square 530, 410 , 0f37736h

   

final_draw:
	popa
	mov esp, ebp
	pop ebp
	ret
draw endp

start:
	;alocam memorie pentru zona de desenat
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	call malloc
	add esp, 4
	mov area, eax
	;apelam functia de desenare a ferestrei
	; typedef void (*DrawFunc)(int evt, int x, int y);
	; void __cdecl BeginDrawing(const char *title, int width, int height, unsigned int *area, DrawFunc draw);
	push offset draw
	push area
	push area_height
	push area_width
	push offset window_title
	call BeginDrawing
	add esp, 20
	
	;terminarea programului
	push 0
	call exit
end start



;CULORI: 00392cfh	07bc043h	0ee4035h	0f37736h


 			
		;2 0 0 0 0 0 0 0 0 0 0 2	(50, 30) (70, 30) (90, 30) (110, 30) (130, 30) (150, 30) (170, 30) (190, 30) (210, 30) (230, 30)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50, 50) (70, 50) (90, 50) (110, 50) (130, 50) (150, 50) (170, 50) (190, 50) (210, 50) (230, 50)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50, 70) (70, 70) (90, 70) (110, 70) (130, 70) (150, 70) (170, 70) (190, 70) (210, 70) (230, 70)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50, 90) (70, 90) (90, 90) (110, 90) (130, 90) (150, 90) (170, 90) (190, 90) (210, 90) (230, 90)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50,110) (70,110) (90,110) (110,110) (130,110) (150,110) (170,110) (190,110) (210,110) (230,110)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50,130) (70,130) (90,130) (110,130) (130,130) (150,130) (170,130) (190,130) (210,130) (230,130)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50,150) (70,150) (90,150) (110,150) (130,150) (150,150) (170,150) (190,150) (210,150) (230,150)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50,170) (70,170) (90,170) (110,170) (130,170) (150,170) (170,170) (190,170) (210,170) (230,170)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50,190) (70,190) (90,190) (110,190) (130,190) (150,190) (170,190) (190,190) (210,190) (230,190)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50,210) (70,210) (90,210) (110,210) (130,210) (150,210) (170,210) (190,210) (210,210) (230,210)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50,230) (70,230) (90,230) (110,230) (130,230) (150,230) (170,230) (190,230) (210,230) (230,230)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50,250) (70,250) (90,250) (110,250) (130,250) (150,250) (170,250) (190,250) (210,250) (230,250)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50,270) (70,270) (90,270) (110,270) (130,270) (150,270) (170,270) (190,270) (210,270) (230,270)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50,290) (70,290) (90,290) (110,290) (130,290) (150,290) (170,290) (190,290) (210,290) (230,290)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50,310) (70,310) (90,310) (110,310) (130,310) (150,310) (170,310) (190,310) (210,130) (230,310)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50,330) (70,330) (90,330) (110,330) (130,330) (150,330) (170,330) (190,330) (210,330) (230,330)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50,350) (70,350) (90,350) (110,350) (130,350) (150,350) (170,350) (190,350) (210,350) (230,350)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50,370) (70,370) (90,370) (110,370) (130,370) (150,370) (170,370) (190,370) (210,370) (230,370)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50,390) (70,390) (90,390) (110,390) (130,390) (150,390) (170,390) (190,390) (210,390) (230,390)
		;2 0 0 0 0 0 0 0 0 0 0 2	(50,410) (70,410) (90,410) (110,410) (130,410) (150,410) (170,410) (190,410) (210,410) (230,410)                                                                                                                         
		;2 0 0 0 0 0 0 0 0 0 0 2	(50,430) (70,430) (90,430) (110,430) (130,430) (150,430) (170,430) (190,430) (210,430) (230,430) 
		;2 2 2 2 2 2 2 2 2 2 2 2
		
		
																							MACRO PENTRU REPREZENTAREA UNUI TETROMINO   T   FOLOSIND MACRO-UL SQUARE			
; T_tetromino_S1 macro x, y, color;		   _	
	; square x, y+20, color;				 _|_|_								
    ; square x+20, y+20, color;			|_|_|_|
    ; square x+40, y+20, color;							!!!	IN LOC DE SQUARE POT PUNE IMAGINE
    ; square x+20, y, color
; endm
     							   	  
; T_tetromino_S2 macro x, y, color;		  _	
	; square x, y, color;				     |_|_								
    ; square x, y+20, color;    	    	 |_|_|
    ; square x, y+40, color;               |_|
    ; square x+20, y+20, color
; endm

; T_tetromino_S3 macro x, y, color;			   
	; square x, y, color;			    	 _ _ _								
    ; square x+20, y,color;	    		|_|_|_|
    ; square x+40, y, color;		    	  |_|
    ; square x+20, y+20, color
; endm

; T_tetromino_S4 macro x, y, color
    ; square x+20, y,    color;			 	 _
    ; square x,    y+20,  color;			   _|_|
    ; square x+20, y+20,  color;            |_|_|
    ; square x+20, y+40,  color;              |_|
; endm

																							MACRO PENTRU REPREZENTAREA UNUI TETROMINO   Z   FOLOSIND MACRO-UL SQUARE
; Z_tetromino_S1 macro x, y, color
    ; square x, y, color;				      _ _		
    ; square x+20, y, color;			     |_|_|_
    ; square x+20, y+20, color;		       |_|_|
    ; square x+40, y+20, color;
; endm		

; Z_tetromino_S2 macro x, y, color;    	      		
    ; square x+20, y, color;		            _
    ; square x, y+20, color;		   	 	  _|_|
    ; square x+20, y+20, color;	  	   	 |_|_|
    ; square x, y+40, color;				 |_|
; endm									
																							MACRO PENTRU REPREZENTAREA UNUI TETROMINO   I   FOLOSIND MACRO-UL SQUARE
; I_tetromino_S1 macro x, y, color;         _
    ; square x, y, color;					 |_|
    ; square x, y+20, color;				 |_|	
    ; square x, y+40, color;          	 |_|
    ; square x, y+60, color;          	 |_|
; endm

; I_tetromino_S2 macro x, y, color
    ; square x, y, color;					 _ _ _ _	
    ; square x+20, y, color;				|_|_|_|_|
    ; square x+40, y, color;
    ; square x+60, y, color;
; endm

																							MACRO PENTRU REPREZENTAREA UNUI TETROMINO   O   FOLOSIND MACRO-UL SQUARE
; O_tetromino macro x, y, color
    ; square x, y, color;					 _ _
    ; square x+20, y, color;				|_|_|
    ; square x, y+20, color;				|_|_|
    ; square x+20, y+20, color
; endm
