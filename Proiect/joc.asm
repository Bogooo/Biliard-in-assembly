.386
.model flat, stdcall
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;includem biblioteci, si declaram ce functii vrem sa importam
includelib msvcrt.lib
extern exit: proc
extern malloc: proc
extern memset: proc
includelib canvas.lib
extern BeginDrawing: proc
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;declaram simbolul start ca public - de acolo incepe executia
public start
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;sectiunile programului, date, respectiv cod
.data
;aici declaram date
window_title DB "Billiard",0
area_width EQU 650
area_height EQU 515
area DD 0

counter DD 0 ; numara evenimentele de tip timer
counters DD 0

;lungime:30   inaltime:17 pozitii
buton_lungime equ 60
buton_inaltime equ 35
butoane_poz_x dd 227,286,348,348,348,286,227,227
butoane_poz_y dd 405,405,405,437,472,472,472,437
check dd 0
button_curent dd 0



culoare_verde equ 009933h
culoare_fundal equ 200
culoare_fundal_carac equ 0c8c8c8h
culoare_scris equ 0ff6600h
culoare_scris_buton equ 0ffffffh
culoare_maro equ 663300h
culoare_maro_contur equ 4d2600h
culoare_butoane equ 0ff8533h
culoare_butoane_contur equ 0cc5200h


arg1 EQU 8
arg2 EQU 12
arg3 EQU 16
arg4 EQU 20

bila_size equ 20
x_bila dd 70
y_bila dd 95
x_directie dd 1
y_directie dd 0
x_inm dd 15
y_inm dd 10


symbol_width EQU 10
symbol_height EQU 20
include digits.inc
include letters.inc
include bila.inc

.code
;linii
line macro x,y,h,lun,color
local bucla_line_v,et
	mov eax,y
	mov ebx,area_width
	mul ebx 
	add eax,x
	shl eax,2
	add eax,area
	
	mov ecx,h
bucla_line_v:
mov esi,ecx
mov ecx,lun
mov ebx,eax
et:
	mov dword ptr[ebx],color
	add ebx,4
loop et
	mov ecx,esi
	add eax,area_width*4
	loop bucla_line_v
endm
;final linii,fill

;verifica daca clickul este pe un button
; arg1-buton de check
; arg2-pos_x
; arg3_pos_y
check_button proc
	push ebp
	mov ebp, esp
	pusha
	mov check,0
	mov ecx,[ebp+arg1]
	shl ecx,2
	
	mov eax,[ebp + arg2]
	mov ebx,butoane_poz_x[ecx]
	cmp eax,ebx
	jl final
	add ebx,buton_lungime
	cmp eax,ebx
	jg final
	
	mov eax,[ebp+arg3]
	mov ebx,butoane_poz_y[ecx]
	cmp eax,ebx
	jl final
	add ebx,buton_inaltime
	cmp eax,ebx
	jg final
	
	mov check,1
	final:
	popa
	mov esp, ebp
	pop ebp
	ret
check_button endp

check_buton_macro macro buton,x,y
	push y
	push x
	push buton
	call check_button
	add esp,12
endm
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
	je simbol_pixel_fundal
	mov dword ptr [edi], culoare_scris
	jmp simbol_pixel_next
simbol_pixel_fundal:
	mov dword ptr [edi], culoare_fundal_carac
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


;text2
make_text2 proc
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
	je simbol_pixel_fundal
	mov dword ptr [edi], culoare_scris_buton
	jmp simbol_pixel_next
simbol_pixel_fundal:
	mov dword ptr [edi], culoare_butoane
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
make_text2 endp


;desen bila
draw_bila proc
	push ebp
	mov ebp, esp
	pusha
	lea esi,bila
	mov ecx, bila_size
bucla_simbol_linii:
	mov edi, [ebp+arg1] ; pointer la matricea de pixeli
	mov eax, [ebp+arg3] ; pointer la coord y
	add eax, bila_size
	sub eax, ecx
	mov ebx, area_width
	mul ebx
	add eax, [ebp+arg2] ; pointer la coord x
	shl eax, 2 ; inmultim cu 4, avem un DWORD per pixel
	add edi, eax
	push ecx
	mov ecx, bila_size
bucla_simbol_coloane:
	cmp byte ptr [esi], 0
	je simbol_pixel_fundal
	mov dword ptr [edi], 0
	jmp simbol_pixel_next
simbol_pixel_fundal:
	mov dword ptr [edi], culoare_verde
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
draw_bila endp
;gata bila

draw_bila_macro macro drawArea, x, y
	push y
	push x
	push drawArea
	call draw_bila
	add esp, 12
endm

delete_bila_macro macro x,y
	line x,y,20,20,culoare_verde
endm

; un macro ca sa apelam mai usor desenarea simbolului
make_text_macro macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text
	add esp, 16
endm

make_text_macro2 macro symbol, drawArea, x, y
	push y
	push x
	push drawArea
	push symbol
	call make_text2
	add esp, 16
endm

reset_butons macro
	line 220,400,115,200,culoare_fundal_carac
	line 230,405,100,180,culoare_butoane
	line 230,437,5,180,culoare_butoane_contur
	line 230,472,5,180,culoare_butoane_contur
	line 230,405,5,180,culoare_butoane_contur
	line 230,502,5,185,culoare_butoane_contur
	line 230,405,100,5,culoare_butoane_contur
	line 287,405,100,5,culoare_butoane_contur
	line 348,405,100,5,culoare_butoane_contur
	line 410,405,100,5,culoare_butoane_contur
	make_text_macro2 'Q',area,257,415
	make_text_macro2 'W',area,247,444
	make_text_macro2 'U',area,257,444
	make_text_macro2 'J',area,257,478
	make_text_macro2 'Z',area,316,412
	make_text_macro2 'Y',area,316,479
	make_text_macro2 'K',area,378,415
	make_text_macro2 'X',area,388,444
	make_text_macro2 'V',area,378,444
	make_text_macro2 'H',area,378,478
endm

;viz click
draw_click_button macro x,y,color
	reset_butons
	line x,y,8,buton_lungime,color
	add y,buton_inaltime-4
	line x,y,8,buton_lungime,color
	sub y,buton_inaltime-4
	line x,y,buton_inaltime,8,color
	add x,buton_lungime
	line x,y,buton_inaltime+4,8,color
	sub x,buton_lungime
endm
;fina viz click

;eveniment buton
;arg1 x
;arg2 y
click_button proc
	push ebp
	mov ebp, esp
	pusha
	mov eax, [ebp+arg1]
	mov ebx, [ebp+arg2]
button1:
	mov check,0
	check_buton_macro 0,eax,ebx
	cmp check,1
	jne button2
	draw_click_button butoane_poz_x,butoane_poz_y,culoare_scris_buton
	mov x_directie,-1
	mov y_directie,-1
	jmp final
	
button2:
	mov check,0
	check_buton_macro 1,eax,ebx
	cmp check,1
	jne button3
	draw_click_button butoane_poz_x+4,butoane_poz_y+4,culoare_scris_buton
	mov x_directie,0
	mov y_directie,-1
	jmp final
	
button3:
	mov check,0
	check_buton_macro 2,eax,ebx
	cmp check,1
	jne button4
	draw_click_button butoane_poz_x+8,butoane_poz_y+8,culoare_scris_buton	
	mov x_directie,1
	mov y_directie,-1
	jmp final
button4:	
	mov check,0
	check_buton_macro 3,eax,ebx
	cmp check,1
	jne button5
	draw_click_button butoane_poz_x+12,butoane_poz_y+12,culoare_scris_buton
	mov x_directie,1
	mov y_directie,0
	jmp final
	
button5:	
	mov check,0
	check_buton_macro 4,eax,ebx
	cmp check,1
	jne button6
	draw_click_button butoane_poz_x+16,butoane_poz_y+16,culoare_scris_buton
	mov x_directie,1
	mov y_directie,1
	jmp final
	
button6:	
	mov check,0
	check_buton_macro 5,eax,ebx
	cmp check,1
	jne button7
	draw_click_button butoane_poz_x+20,butoane_poz_y+20,culoare_scris_buton
	mov x_directie,0
	mov y_directie,1
	jmp final
	
button7:	
	mov check,0
	check_buton_macro 6,eax,ebx
	cmp check,1
	jne button8
	draw_click_button butoane_poz_x+24,butoane_poz_y+24,culoare_scris_buton
	mov x_directie,-1
	mov y_directie,1
	jmp final
	
button8:	
	mov check,0
	check_buton_macro 7,eax,ebx
	cmp check,1
	jne final
	draw_click_button butoane_poz_x+28,butoane_poz_y+28,culoare_scris_buton
	mov x_directie,-1
	mov y_directie,0
	
final:
	popa
	mov esp, ebp
	pop ebp
	ret
click_button endp

click_button_macro macro x,y
	push y
	push x
	call click_button
	add esp,8
endm

;verifica/modifica dir daca intra in perete
wall_check macro x,y
local stanga_end,dreapta_end,sus_end,jos_end
	cmp x,70
	jne stanga_end
	cmp x_directie,-1
	jne stanga_end
	mov x_directie,1
	stanga_end:
	
	cmp x,565
	jne dreapta_end
	cmp x_directie,1
	jne dreapta_end
	mov x_directie,-1
	dreapta_end:
	
	cmp y,95
	jne sus_end
	cmp y_directie,-1
	jne sus_end
	mov y_directie,1
	sus_end:
	
	cmp y,355
	jne  jos_end
	cmp y_directie,1
	jne jos_end
	mov y_directie,-1
	jos_end:
endm

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
	
	;intializare
	mov eax, area_width
	mov ebx, area_height
	mul ebx
	shl eax, 2
	push eax
	push culoare_fundal
	push area
	call memset
	add esp, 12
	;masa
	line 50,70,305,20,culoare_maro
	line 585,70,305,20,culoare_maro
	line 70,70,20,515,culoare_maro	
	line 50,375,20,555,culoare_maro
	line 70,90,285,515,culoare_verde
	;contur masa
	line 45,70,325,5,culoare_maro_contur
	line 65,90,285,5,culoare_maro_contur
	line 605,70,325,5,culoare_maro_contur
	line 585,90,285,5,culoare_maro_contur
	line 70,90,5,515,culoare_maro_contur
    line 45,65,5,565,culoare_maro_contur	
	line 45,395,5,565,culoare_maro_contur
	line 65,375,5,525,culoare_maro_contur
	;contur,fundal butoane	
	reset_butons
	draw_bila_macro area,x_bila,y_bila
	;terminare initializare
	jmp afisare_litere
	
evt_click:
	click_button_macro [ebp+arg2],[ebp+arg3]
	jmp afisare_litere
	
evt_timer:
	
	delete_bila_macro x_bila,y_bila
	wall_check x_bila,y_bila
	push eax
	
	mov  eax,x_directie
	mul x_inm
	add eax,x_bila
	mov  x_bila,eax
	
	
	mov  eax,y_directie
	mul y_inm
	add eax,y_bila
	mov  y_bila,eax
	pop eax
	draw_bila_macro area,x_bila,y_bila
	
	inc counter
	cmp counter,5
	jne afisare_litere
	inc counters
	mov counter,0
	
afisare_litere:
	;afisam valoarea counter-ului curent (sute, zeci si unitati)
	mov ebx, 10
	mov eax, counters
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
	make_text_macro 'S', area, 40, 10
	
	;scriem un mesaj
	make_text_macro 'B',area,280,20
	make_text_macro 'I',area,290,20
	make_text_macro 'L',area,300,20
	make_text_macro 'L',area,310,20
	make_text_macro 'I',area,320,20
	make_text_macro 'A',area,330,20
	make_text_macro 'R',area,340,20
	make_text_macro 'D',area,350,20
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



;caract modificate
;Z-sus
;Y-jos
;w-stanga
;x-dreapta
;v-crat_dr
;u-crat_st
;q- st sus
;k- dr sus
;j- sr hos
;h- dr jos