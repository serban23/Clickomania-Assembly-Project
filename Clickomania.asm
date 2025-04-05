.586
.model flat, stdcall

includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
extern fopen: proc
extern fclose: proc
extern scanf: proc
extern printf: proc
extern fscanf: proc
extern fprintf: proc
extern fread: proc
extern fwrite: proc

includelib canvas.lib
extern BeginDrawing: proc

public start

.data
include digits.inc
include letters.inc
include albastru.inc
include galben.inc
include portocaliu.inc
include mov.inc
include rosu.inc
include verde.inc
include alb.inc 
window_title DB "Clickomania",0
area_width EQU 340
area_height EQU 550
area DD 0
counter DD 0 ; numara evenimentele de tip timer
ct db 0
dim_patr equ 40
arg1 equ 8
arg2 equ 12
arg3 equ 16
arg4 equ 20
lungime equ 12
latime equ 8
x_patr dd 10
y_patr dd 40
i db 0
symbol_width EQU 10
symbol_height EQU 20
image_size EQU 40
vect_cul dd 03f48cch, 0fff200h, 0ff7f27h, 0a349a4h, 0ed1c24h,022b14ch,0ffffffh
vect_frecv db 6 dup(0)
; mat dd 9 dup (6)
	; dd 9 dup (6)
	; dd 9 dup (6)
	; dd 9 dup (6)
	; dd 9 dup (6)
	; dd 9 dup (6)
	; dd 9 dup (6)
	; dd 9 dup (6)
	; dd 9 dup (6)
	; dd 9 dup (6)
	; dd 9 dup (6)
	; dd 9 dup (6)
	; dd 9 dup (6)
	; dd 9 dup (6)
	; dd 9 dup (6)
scor dd 0
y_nou dd 0
x_nou dd 0
x_culoare dd 0
y_culoare dd 0
button_x equ 160
button_y equ 15
button_size equ 15
filename db "jucatori.txt", 0
mode_r db "r", 0
mode_a db "a", 0
msg db "Introduceti-va numele: ",0
format_nume db "%s", 0
format_scor db "%d",0
nume_jucator db 15 dup(0)
scor_jucator dd 0
format db "%s %d",10 ,0
file_length dd 2

.code
; Make an image at the given coordinates
; arg1 - pointer to the pixel vector
; arg2 - x of drawing start position
; arg3 - y of drawing start position
; arg4 - colour


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
;macro pentru linie orizontala
linie_orizontala macro x, y, len, colour
local bucla_line
	mov eax,y
	mov ebx, area_width
	mul ebx
	add eax,x
	shl eax,2
	add eax,area
	mov ecx, len
bucla_line:
	mov dword ptr[eax], colour
	add eax, 4
	loop bucla_line
endm
;macro pentru linie verticala
linie_verticala macro x, y, len, colour
local bucla_line
	mov eax,y
	mov ebx, area_width
	mul ebx
	add eax,x
	shl eax,2
	add eax,area
	mov ecx, len
bucla_line:
	mov dword ptr[eax], colour
	add eax, area_width*4
	loop bucla_line
endm
;macro pentru ':' si butoane
buton macro x, y, dim, colour
	linie_verticala x,y,dim,colour
	linie_verticala x+dim,y,dim,colour
	linie_orizontala x,y,dim,colour
	linie_orizontala x,y+dim,dim,colour
endm	

make_image proc
	push ebp
	mov ebp, esp
	pusha
;aflam x si y pentru matricea de culori
	; xor edx,edx
	; mov eax,[ebp+arg2] 
	; mov ebx,8
	; div ebx     ;eax<=x/8
	; mov esi,eax
	; xor edx,edx
	; mov eax,[ebp+arg3]
	; mov ebx,12
	; div ebx
	; mov edi,eax
	mov eax, [ebp+arg4]
	;mov mat[esi][edi],eax
;verificam care culoare este
	cmp eax,6
	je alb
	cmp eax,5
	je verde
	cmp eax,4
	je rosu
	cmp eax,3
	je movv
	cmp eax,2
	je portocaliu
	cmp eax,1
	je galben
	cmp eax,0
	je albastru
albastru:
	lea esi,var_0
	jmp draw_image
galben:
	lea esi,var_1
	jmp draw_image
portocaliu:
	lea esi, var_2
	jmp draw_image
movv:
	lea esi, var_3
	jmp draw_image
rosu:
	lea esi,var_4
	jmp draw_image
verde:
	lea esi, var_5
	jmp draw_image
alb:
	lea esi,var_6
draw_image:
	mov ecx, image_size
loop_draw_lines:
	mov edi, [ebp+arg1] ; pointer to pixel area
	mov eax, [ebp+arg3] ; pointer to coordinate y
	add eax, image_size
	sub eax, ecx ; current line to draw (total - ecx)
	mov ebx, area_width
	mul ebx	; get to current line
	add eax,[ebp+arg2] ; get to coordinate x in current line
	shl eax, 2 ; multiply by 4 (DWORD per pixel)
	add edi, eax
	push ecx
	mov ecx, image_size ; store drawing width for drawing loop
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
make_image_macro macro drawArea, x, y,colour
	push colour
	push y
	push x
	push drawArea
	call make_image
	add esp, 16
endm

copiere proc
	push ebp
	mov ebp,esp
	mov esi,[ebp+12]
	sub esi,40
	mov y_culoare,esi
	
	mov eax,y_culoare
	mov ebx, area_width
	mul ebx
	add eax,[ebp+8]
	shl eax,2
	add eax,area
	mov ecx,[eax]
	cmp ecx,vect_cul[0]
	je albastru2
	cmp ecx,vect_cul[4]
	je galben2
	cmp ecx,vect_cul[8]
	je portocaliu2
	cmp ecx,vect_cul[12]
	je movv2
	cmp ecx,vect_cul[16]
	je rosu2
	cmp ecx,vect_cul[20]
	je verde2
alb2:
	make_image_macro area,[ebp+8],[ebp+12],6
	jmp final2
albastru2:
	make_image_macro area,[ebp+8],[ebp+12],0
	jmp final2
galben2:
	make_image_macro area,[ebp+8],[ebp+12],1
	jmp final2
portocaliu2:
	make_image_macro area,[ebp+8],[ebp+12],2
	jmp final2
movv2:
	make_image_macro area,[ebp+8],[ebp+12],3
	jmp final2
rosu2:
	make_image_macro area,[ebp+8],[ebp+12],4
	jmp final2
verde2:
	make_image_macro area,[ebp+8],[ebp+12],5
	jmp final2
final2: 
	mov esp, ebp
	pop ebp
	ret
copiere endp

; mutare_stanga proc
	;aflam cate elem trebuie mutate: (320-(x-10))/40-1
	; mov eax,0     
	; mov eax,320
	; mov ebx,x_nou
	; sub ebx,10
	; sub eax,ebx
	; mov ebx,40
	; xor edx,edx
	; div ebx
	; sub eax,1
	; mov edi,eax  ;;edi- un fel de ecx provizoriu
	; mov ecx,12
; bucla1: ;;ecx=12
	; push ecx
	; xor edx,edx
	; mov eax,40
	; mul ecx  ;;eax=40*ecx=y
	; mov y_culoare,eax
	; mov edx,x_nou
	; mov ecx,edi
; bucla2: ;;ecx=edi-ul de sus
	; push ecx
	; mov eax,y_culoare
	; mov ebx,area_width
	; mul ebx
	; add eax,x_culoare
	; shl eax,2
	; add eax,area
	; mov ecx,[eax]
	
	; push y_culoare
	; push edx
	; call mutare_stanga
	; add esp,8

	; cmp ecx,vect_cul[0]
	; je albastru3
	; cmp ecx,vect_cul[4]
	; je galben3
	; cmp ecx,vect_cul[8]
	; je portocaliu3
	; cmp ecx,vect_cul[12]
	; je movv3
	; cmp ecx,vect_cul[16]
	; je rosu3
	; cmp ecx,vect_cul[20]
	; je verde3
; alb3:
	; make_image_macro area,edx,y_culoare,6
	; jmp final_bucla2
; albastru3:
	; make_image_macro area,edx,y_culoare,0
	; jmp final_bucla2
; galben3:
	; make_image_macro area,edx,y_culoare,1
	; jmp final_bucla2
; portocaliu3:
	; make_image_macro area,edx,y_culoare,2
	; jmp final_bucla2
; movv3:
	; make_image_macro area,edx,y_culoare,3
	; jmp final_bucla2
; rosu3:
	; make_image_macro area,edx,y_culoare,4
	; jmp final_bucla2
; verde3:
	; make_image_macro area,edx,y_culoare,5
	; jmp final_bucla2
; final_bucla2:
	; add edx,40
	; loop bucla2
	; pop ecx
	; loop bucla1
; mutare_stanga endp

; functia de desenare - se apeleaza la fiecare click
; sau la fiecare interval de 200ms in care nu s-a dat click
; arg1 - evt (0 - initializare, 1 - click, 2 - s-a scurs intervalul fara click)
; arg2 - x
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
;intializarea fereastrei cu pixeli albi
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push 255
	push area
	call memset
	add esp, 12
;generarea grid-ului si a butoanelor
	linie_orizontala 6,36, 327,0h
	linie_orizontala 7,37,325,0h
	linie_orizontala 8,38,323,0h
	linie_orizontala 9, 39, 321, 0h
	
	linie_orizontala 6,523, 327,0h
	linie_orizontala 7,522,325,0h
	linie_orizontala 8,521,323,0h
	linie_orizontala 9, 520, 321, 0h
	
	linie_verticala 6,36,487, 0h
	linie_verticala 7,37,485, 0h
	linie_verticala 8,38,483, 0h
	linie_verticala 9,39,481, 0h
	
	linie_verticala 333,37,487, 0h
	linie_verticala 332,38,485, 0h
	linie_verticala 331,39,483, 0h
	linie_verticala 330,40,481, 0h
	buton 60,15,15,0h
	buton 160,15,15,0h
	buton 260,15,15,0h
;generarea patratelor random
	mov ecx,lungime
generare_patrate_coloane:
	push ecx
	mov ecx,latime
generare_patrate_linie:
	rdtsc
	xor edx,edx
	mov ebx,6
	div ebx    ;acum avem in edx rdtsc%6, adica nr de la 0 la 6
	make_image_macro area, x_patr, y_patr, edx
	add x_patr,40
	loop generare_patrate_linie
	mov x_patr,10
	add y_patr,40
	pop ecx
	loop generare_patrate_coloane
	jmp afisare_litere
	
evt_click:
;verificam daca s-a facut click pe butonul de final joc
buton_stop:
	mov eax,[ebp+arg2]
	cmp eax,60
	jl patratele
	cmp eax,60+button_size
	jg buton_top3
	mov eax,[ebp+arg3]
	cmp eax,15
	jl final
	cmp eax,15+button_size
	jg patratele
;deschidem fisierul, citim numele si scriem in fisier nume+scor
;apoi afisam tot ce se afla in fisier
	inc file_length
	push offset mode_a
	push offset filename
	call fopen
	add esp,8
	mov esi,eax
	push offset msg
	push offset format_nume
	call printf
	add esp,8
	push offset nume_jucator
	push offset format_nume
	call scanf
	add esp, 8
	push scor
	push offset nume_jucator
	push offset format
	push esi
	call fprintf
	add esp,16
	push esi
	call fclose
	add esp,4
	push offset mode_r
	push offset filename
	call fopen
	add esp,8
	mov ecx,file_length
bucla_afisare: 
	push ecx
	push offset scor_jucator
	push offset nume_jucator
	push offset format
	push esi
	call fscanf
	add esp, 16
	push scor_jucator
	push offset nume_jucator
	push offset format
	call printf
	add esp,12
	pop ecx
	loop bucla_afisare
	push esi
	call fclose
	add esp, 4
	jmp iesire
;verificam daca click-ul este pe butonul de afisare_top3
buton_top3:
	mov eax,[ebp+arg2]
	cmp eax,160
	jl patratele
	cmp eax,160+button_size
	jg buton_iesire 
	mov eax,[ebp+arg3]
	cmp eax,15
	jl final
	cmp eax,15+button_size
	jg patratele
;deschidem fisierul daca click-ul este pee buton	
	push offset mode_r
	push offset filename
	call fopen
	add esp,8
	mov esi,eax
	mov ecx, 3
;citim si afisam primii 3 jucatori
afisare_top:
	push ecx
	push offset scor_jucator
	push offset nume_jucator
	push offset format
	push esi
	call fscanf
	add esp,16
	push scor_jucator
	push offset nume_jucator
	push offset format
	call printf
	add esp,12
	pop ecx
	loop afisare_top
	push esi
	call fclose
	jmp iesire
buton_iesire:
	mov eax,[ebp+arg2]
	cmp eax,260
	jl patratele
	cmp eax,260+button_size
	jg patratele
	mov eax,[ebp+arg3]
	cmp eax,15
	jl final
	cmp eax,15+button_size
	jg patratele
	
	jmp iesire
patratele:
;verificam daca click-ul este in zona de joc
	mov eax, [ebp+arg2]
	cmp eax, 9
	jb final
	cmp eax, 330
	ja final
	mov eax,[ebp+arg3]
	cmp eax, 40
	jb final
	cmp eax, 520
	ja final
	inc scor
;aflare x pt desenare (coltul patratelului)
	xor edx,edx
	mov eax,[ebp+arg2]
	sub eax,10
	mov esi,[ebp+arg2]
	mov ebx,40
	div ebx
	sub esi,edx
	mov x_nou,esi
;aflare y pt desenare
	mov eax,[ebp+arg3]
	xor edx,edx
	mov esi,[ebp+arg3]
	mov ebx,40
	div ebx
	sub esi,edx
	mov y_nou,esi
;aflare y patrat deasupra (x este egal)
	sub esi,40
	mov y_culoare,esi
;aflam de cate ori trebuie apelata functia (cate patrate pana sus)
	mov eax,y_nou
	mov ebx,40
	xor edx,edx
	div ebx
	mov ecx,eax
curgere:
	mov edx, y_nou
	mov esi, x_nou
	;copiere x,y
	push ecx
	push edx
	push esi
	call copiere
	add esp, 8
	sub y_nou,40
	pop ecx
	loop curgere
;verificam daca este goala coloana unde s-a spart utimul
;patratel 
;verificare_coloana:
	; xor eax,eax
	; mov eax,485
	; mov ebx, area_width
	; mul ebx
	; add eax,[ebp+arg2]
	; shl eax,2
	; add eax,area
	; mov edx,vect_cul[24]
	; cmp [eax],edx
	; jne final
	
final:
	jmp afisare_litere

incrementare: 
	inc counter
	mov ct,0
	jmp afisare_litere
evt_timer:
	inc ct
	cmp ct,5
	je incrementare
afisare_litere:
;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counter
;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 295, 530
;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 285, 530
;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 275, 530
;afisam valoarea scorului
	mov ebx, 10
	mov eax, scor
;cifra unitatilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 100, 530
;cifra zecilor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 90, 530
;cifra sutelor
	mov edx, 0
	div ebx
	add edx, '0'
	make_text_macro edx, area, 80, 530
;scriem un mesaj
	make_text_macro 'S', area, 30, 530
	make_text_macro 'C', area, 40, 530
	make_text_macro 'O', area, 50, 530
	make_text_macro 'R', area, 60, 530
	buton 70,537,2,0h
	buton 70,544,2,0h
	make_text_macro 'T', area, 230, 530
	make_text_macro 'I', area, 240, 530
	make_text_macro 'M', area, 250, 530
	make_text_macro 'P', area, 260, 530
	buton 270,537,2,0h
	buton 270,544,2,0h
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
iesire:
	push 0
	call exit
end start
