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
area_width EQU 560
area_height EQU 490
area DD 0

include digits.inc
include letters.inc
include 1rosu.inc
include 1albastru.inc
include 1portocaliu.inc
include 1verde.inc
include 1galben.inc
include 1mov.inc
include 1alb.inc
include gri.inc
include playgroud2.inc

stanga DD 0
sus DD 0
val DD 0
format DB "%d",13,10,0
format2 DB "(%d, %d) ",13,10,0
var1 DD 0
var2 DD 0
var3 DD 0

loopcol DD 11
loopline DD 22

matrice DD  0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0
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
		DD  2, 6, 1, 1, 0, 0, 0, 0, 0, 0, 3, 2
		DD  2, 6, 6, 1, 2, 2, 2, 0, 2, 0, 3, 2
		DD  2, 6, 5, 1, 4, 4, 2, 1, 2, 2, 3, 2
		DD  2, 5, 5, 5, 4, 4, 1, 1, 1, 2, 3, 2
		DD  2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2
																		
square_size EQU 20
matrix_width EQU 12 * 4
matrix_height EQU 22 * 4

margin_top EQU 30
margin_left EQU 50
margin_right EQU 270
margin_bot EQU 450

counter DD 0 ; numara evenimentele de tip timer

arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20
arg4 EQU 20

image_width DD 20
image_height DD 20

symbol_width EQU 10
symbol_height EQU 20

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

								;MACRO PENTRU DESENAREA SIMBOLULUI
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
								;eax=0 (ALB are var_0)   eax=1 (ALBASTRU are var_1) eax=2 (PORTOCALIU are var_2) eax=3 (VERDE are var_3) 
								;eax=4 (GALBEN are var_4) eax=5 (MOV are var_5)     eax=6 (ROSU are var_6)       eax=7 (GRI are var_7) 		
	mov eax, [ebp+arg4]			
	cmp eax, 0
	je alb
	
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
	je rosu
	
	cmp eax, 7
	je gri
	
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
gri:
    lea esi, var_7
	jmp draw_image
	
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

										;MACRO-UL PENTRU DESENAREA IMAGINII
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

	mov EAX, y			
	mov EBX, area_width
	mul EBX				
	add EAX, x				
	lea EAX, [EAX*4]		
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

	mov EAX, y				
	mov EBX, area_width
	mul EBX					
	add EAX, x				
	lea EAX, [EAX*4]		
	add EAX, area
	mov ECX, lungime
bucla1: 
	mov dword ptr [EAX], culoare
	add EAX, 4 * area_width
	loop bucla1
endm 							
										;MACRO PENTRU REPREZENTAREA UNUI PATRAT, PRIMESTE COORDONATELE X, Y SI CULOAREA LUI
square macro x, y, color
local loop1, loop2
	mov eax, y          
	mov ebx, area_width 
	mul ebx             
	add eax, x          
	lea eax, [eax*4]    
	add eax, area       

	mov ecx, 10         
loop1:
	push ecx           
	mov ecx, 10       
loop2:
	mov dword ptr [eax], color 
	add eax, 4          
	loop loop2
	pop ecx             
	add eax, (area_width - 10) * 4 ; trecem la urmatorul rand
	loop loop1
endm
		
										;RETURNEAZA VALOAREA DIN MATRICE DE LA COORDONATELE (POZX, POZY)
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
										;CALCULEAZA POZITIA PE ECRAN AL UNUI ELEMENT DIN MATRICE DE LA COORDONATELE (POZX, POZY)
pozitie_element macro pozy, pozx		
	mov ECX, pozy
	mov EAX, square_size
	mul ECX
	mov EBX, EAX
	add EBX, margin_top
	
	mov ECX,pozx
	mov EAX, square_size
	mul ECX
	add EAX,margin_left
endm
										;TRECE PRIN FIECARE ELEMENT DIN MATRICE SI IL AFISEAZA 0-ALB, 1-ALBASTRU, 2-PORTOCALIU, 3-VERDE, 4-GALBEN, 5-MOV, 6-ROSU
afisare_matr macro 
;loop line loop col
local loop_linie,loop_coloane,terminate_loop
mov loopline,21
mov loopcol,11
loop_linie:
	
	loop_coloana:
	
	 pozitie_element loopline,loopcol
	 mov var1,EAX
	 mov var2,EBX
	 
	 element loopline,loopcol
	 mov var3,EAX
	 make_image_macro area,var1,var2,var3
	 dec loopcol
	 cmp loopcol,0
	 jge loop_coloana
	 
	mov loopcol,11
	dec loopline
	
	cmp loopline,0
	jnge terminate_loop
	jmp loop_linie
	
	terminate_loop:
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
	make_text_macro edx, area, 30, 30
	;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 20, 30
	;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 10, 30
	
	;scriem un mesaj
	make_text_macro 'B', area, 480, 430
	make_text_macro 'O', area, 490, 430
	make_text_macro 'G', area, 500, 430
	make_text_macro 'D', area, 510, 430
	make_text_macro 'A', area, 520, 430
	make_text_macro 'N', area, 530, 430
	
	make_text_macro 'I', area, 475, 450
	make_text_macro 'S', area, 485, 450
	make_text_macro 'T', area, 495, 450
	make_text_macro 'R', area, 505, 450
	make_text_macro 'A', area, 515, 450
	make_text_macro 'T', area, 525, 450
	make_text_macro 'E', area, 535, 450
	
	make_text_macro 'S', area, 5, 10
	make_text_macro 'C', area, 15, 10
	make_text_macro 'O', area, 25, 10
	make_text_macro 'R', area, 35, 10
																										;AICI
																										;LUCREZ
																										;ACUM
matrice_joc:																						

	element 2, 1
	; pozitie_element 1, 0
	; push EAX
	; push EBX
	; push offset format2
	; call printf
	; add ESP, 12
	afisare_matr

			                 								  ;REGIUNEA DE JOC IMPLEMENTATA CU AJUTORUL IMAGINILOR:

;PATRATELE GRI CARE DELIMITEAZA PARTEA DIN STANGA A TERENULUI
	 make_image_macro area, 50, 10, 7
	 make_image_macro area, 50, 30, 7
	 make_image_macro area, 50, 50, 7
	 make_image_macro area, 50, 70, 7
	 make_image_macro area, 50, 90, 7
	 make_image_macro area, 50, 110, 7
	 make_image_macro area, 50, 130, 7
	 make_image_macro area, 50, 150, 7
	 make_image_macro area, 50, 170, 7
	 make_image_macro area, 50, 190, 7
	 make_image_macro area, 50, 210, 7
	 make_image_macro area, 50, 230, 7
	 make_image_macro area, 50, 250, 7
	 make_image_macro area, 50, 270, 7
	 make_image_macro area, 50, 290, 7
	 make_image_macro area, 50, 310, 7
	 make_image_macro area, 50, 330, 7
	 make_image_macro area, 50, 350, 7
	 make_image_macro area, 50, 370, 7
	 make_image_macro area, 50, 390, 7
	 make_image_macro area, 50, 410, 7
	 make_image_macro area, 50, 430, 7
	 make_image_macro area, 50, 450, 7
	 make_image_macro area, 50, 450, 7
	 make_image_macro area, 70, 450, 7
	 make_image_macro area, 90, 450, 7
	 
;PATRATELE GRI CARE DELIMITEAZA PARTEA DE JOS A TERENULUI 
	 make_image_macro area, 110, 450, 7
	 make_image_macro area, 130, 450, 7
	 make_image_macro area, 150, 450, 7
	 make_image_macro area, 170, 450, 7
	 make_image_macro area, 190, 450, 7
	 make_image_macro area, 210, 450, 7
	 make_image_macro area, 230, 450, 7
	 make_image_macro area, 250, 450, 7
	 make_image_macro area, 270, 450, 7
	 
;PATRATELE GRI CARE DELIMITEAZA PARTEA DIN DREAPTA A TERENULUI
	 make_image_macro area, 270, 10, 7
	 make_image_macro area, 270, 30, 7
	 make_image_macro area, 270, 50, 7
	 make_image_macro area, 270, 70, 7
	 make_image_macro area, 270, 90, 7
	 make_image_macro area, 270, 110, 7
	 make_image_macro area, 270, 130, 7
	 make_image_macro area, 270, 150, 7
	 make_image_macro area, 270, 170, 7
	 make_image_macro area, 270, 190, 7
	 make_image_macro area, 270, 210, 7
	 make_image_macro area, 270, 230, 7
	 make_image_macro area, 270, 250, 7
	 make_image_macro area, 270, 270, 7
	 make_image_macro area, 270, 290, 7
	 make_image_macro area, 270, 310, 7
	 make_image_macro area, 270, 330, 7
	 make_image_macro area, 270, 350, 7
	 make_image_macro area, 270, 370, 7
	 make_image_macro area, 270, 390, 7
	 make_image_macro area, 270, 410, 7
	 make_image_macro area, 270, 430, 7
	 make_image_macro area, 270, 450, 7
	 make_image_macro area, 270, 450, 7
	 
;PATRATELE GRI CARE DELIMITEAZA PARTEA DE SUS A TERENULUI
	make_image_macro area, 70, 10, 7
	make_image_macro area, 90, 10, 7
	make_image_macro area, 110, 10, 7
	make_image_macro area, 130, 10, 7
	make_image_macro area, 150, 10, 7
	make_image_macro area, 170, 10, 7
	make_image_macro area, 190, 10, 7
	make_image_macro area, 210, 10, 7
	make_image_macro area, 230, 10, 7
	make_image_macro area, 250, 10, 7
	make_image_macro area, 270, 10, 7
	
;LINIILE CARE DELIMITEAZA CASUTELE DE JOC
	orizontala 50,50,220,0
	orizontala 50, 70, 220, 0
	orizontala 50, 90, 220, 0
	orizontala 50, 110, 220, 0
	orizontala 50, 130, 220, 0
	orizontala 50, 150, 220, 0
	orizontala 50, 170, 220, 0
	orizontala 50, 190, 220, 0
	orizontala 50, 210, 220, 0
	orizontala 50, 230, 220, 0
	orizontala 50, 250, 220, 0
	orizontala 50, 270, 220, 0
	orizontala 50, 290, 220, 0
	orizontala 50, 310, 220, 0
	orizontala 50, 330, 220, 0
	orizontala 50, 350, 220, 0
	orizontala 50, 370, 220, 0
	orizontala 50, 390, 220, 0
	orizontala 50, 410, 220, 0
	orizontala 50, 430, 220, 0
    verticala 70, 30, 420, 0
    verticala 90, 30, 420, 0
    verticala 110, 30, 420, 0
    verticala 130, 30, 420, 0
    verticala 150, 30, 420, 0
    verticala 170, 30, 420, 0
    verticala 190, 30, 420, 0
    verticala 210, 30, 420, 0
    verticala 230, 30, 420, 0
    verticala 250, 30, 420, 0
	
;DREPTUNGHIUL CARE INCONJOARA 'TETRIS'
	orizontala 300, 10, 235, 0
	orizontala 300, 50, 235, 0
	verticala 300, 10, 40, 0
	verticala 535, 10, 40, 0
; T 
	square 305,15,00392cfh
	square 315,15,00392cfh
	square 325,15,00392cfh
	square 315,25,00392cfh
	square 315,35,00392cfh
; E
	square 340, 15, 07bc043h
	square 350, 15, 07bc043h
	square 360, 15, 07bc043h
	square 340, 35, 07bc043h
	square 350, 35, 07bc043h
	square 360, 35, 07bc043h
; T
	square 380,15,0f37937h
	square 390,15,0f37937h
	square 400,15,0f37937h
	square 390,25,0f37937h
	square 390,35,0f37937h
; R
	square 420,15,0ef4235h
	square 430,15,0ef4235h
	square 440,15,0ef4235h
	square 420,25,0ef4235h
	square 430,25,0ef4235h
	square 420,35,0ef4235h
	square 440,35,0ef4235h
; I
	square 460,15,06f3198h
	square 470,15,06f3198h
	square 480,15,06f3198h
	square 470,25,06f3198h
	square 460,35,06f3198h
	square 470,35,06f3198h
	square 480,35,06f3198h
; S
	square 500,35,0fef101h
	square 510,35,0fef101h
	square 510,25,0fef101h
	square 520,15,0fef101h
	square 510,15,0fef101h
	
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

;CUBURILE DIN DREAPTA JOS   (PALETA DE CULORI)  
	 ; make_image_macro area, 490, 430, 6
	 ; make_image_macro area, 510, 430, 1
	 ; make_image_macro area, 530, 430, 2
	 ; make_image_macro area, 490, 410, 3
	 ; make_image_macro area, 510, 410, 4
	 ; make_image_macro area, 530, 410, 5
	 
; T_tetromino_S1 macro x, y, color;		   _	
	; square x, y+20, color;		     _|_|_								
    ; square x+20, y+20, color;			|_|_|_|
    ; square x+40, y+20, color;							
    ; square x+20, y, color
; endm
     							   	  
; T_tetromino_S2 macro x, y, color;		  _	
	; square x, y, color;				 |_|_								
    ; square x, y+20, color;    	     |_|_|
    ; square x, y+40, color;             |_|
    ; square x+20, y+20, color
; endm

; T_tetromino_S3 macro x, y, color;			   
	; square x, y, color;			     _ _ _								
    ; square x+20, y,color;	    		|_|_|_|
    ; square x+40, y, color;		      |_|
    ; square x+20, y+20, color
; endm

; T_tetromino_S4 macro x, y, color
    ; square x+20, y,    color;			 	   _
    ; square x,    y+20,  color;			 _|_|
    ; square x+20, y+20,  color;            |_|_|
    ; square x+20, y+40,  color;              |_|
; endm
																							
; Z_tetromino_S1 macro x, y, color
    ; square x, y, color;				      _ _		
    ; square x+20, y, color;			     |_|_|_
    ; square x+20, y+20, color;		           |_|_|
    ; square x+40, y+20, color;
; endm		

; Z_tetromino_S2 macro x, y, color;    	      		
    ; square x+20, y, color;		            _
    ; square x, y+20, color;		   	 	  _|_|
    ; square x+20, y+20, color;	  	   	     |_|_|
    ; square x, y+40, color;				 |_|
; endm									
																						
; I_tetromino_S1 macro x, y, color;           _
    ; square x, y, color;					 |_|
    ; square x, y+20, color;				 |_|	
    ; square x, y+40, color;          	     |_|
    ; square x, y+60, color;          	     |_|
; endm

; I_tetromino_S2 macro x, y, color
    ; square x, y, color;					 _ _ _ _	
    ; square x+20, y, color;				|_|_|_|_|
    ; square x+40, y, color;
    ; square x+60, y, color;
; endm
																			
; O_tetromino macro x, y, color
    ; square x, y, color;					 _ _
    ; square x+20, y, color;				|_|_|
    ; square x, y+20, color;				|_|_|
    ; square x+20, y+20, color
; endm
