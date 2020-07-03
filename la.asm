.model smaLL
.stack 64
.data 
cursxchat db 0
cursychat db 3

currxchat db 0
currychat db 16

datatosendflag db 0
VALUEschat db ? 
VALUErchat db ? 
isenterchat db 0
isbackspacechat db 0
lastsxchat db 12 dup(0)
lastrxchat db 12 dup(0)

.code 
initialize proc
;;set 
mov dx,3fbh 			; Line Control Register
mov al,10000000b		;Set Divisor Latch Access Bit
out dx,al				;Out it
;;set LSB
mov dx,3f8h			
mov al,0ch			
out dx,al
;; set msb
mov dx,3f9h
mov al,00h
out dx,al
;;set port
mov dx,3fbh
mov al,00011011b
out dx,al
ret
initialize endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
splitscreenchat proc
mov ax,0600h 
mov bh,00 
mov cx,0 
mov dx,184FH 
int 10h 
;;;;;;;;
mov ah,2     ; set cursor
mov dl,0
mov dh , 12  ; sender
int 10h 
;;;;;;;
mov ah,9          ;Display 
mov bh,0          ;Page 0 
mov al,'-'        ;Letter D 
mov cx,80         ;5 times 
mov bl,0fh ;Green (A) on white(F)
int 10h 
;;;;;;;;;;;;;
mov ah,2     ; set cursor
mov dl,0
mov dh ,0  ; sender
int 10h 
ret
splitscreenchat endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
displayinfirsthalfchat   PROC
cmp isbackspacechat,1
jne v1c 
cmp cursxchat,0
jne co1c
cmp cursychat,0
jne e1c
mov cursxchat,0
jmp f1c
e1c:
dec cursychat
dec di
mov ah,[di]
mov cursxchat,ah
jmp f1c
co1c:
dec cursxchat
f1c:
mov VALUEschat,32
jmp con1c
v1c:
cmp isenterchat,1
jne con1c
ic1c:
inc cursychat
mov ah,cursxchat
mov [di],ah
inc di
mov cursxchat,0
jmp cheaky1c
con1c:
mov AH,2
mov dl ,cursxchat 
mov dh ,cursychat 
Int 10h  ;to set the cursor
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;display;;;;;;;;;;;;;;;;;;;;;
display1c:
mov AH,9  
mov bh,0          ;Page 0:
mov al ,VALUEschat ;Letter 
mov cx,1h         ;5 times 
mov bl,09h ;color
Int 10h      ;to display the character
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmp isbackspacechat,1
je finish1c
inc cursxchat 
cheakx1c:
cmp cursxchat ,80
jne finish1c
normal1c:
jmp ic1c
;mov cursxchat,0
;inc cursy
cheaky1c:
   cmp cursychat,12
   jne finish1c
   mov ah,6        ; function 6
   mov al,1        ; scroll by 1 line    
   mov bh,0     ; normal video attribute         
   mov ch,3        ; upper left Y
   mov cl,0        ; upper left X
   mov dh,11       ; lower right Y
   mov dl,79       ; lower right X 
   int 10h           
   ;Scroll up ;;;;;;;

;;;;;;;;;;;;;;;;
dec cursychat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
finish1c:
mov AH,2
mov dl ,cursxchat 
mov dh ,cursychat 
Int 10h  ;to set the cursor
mov isbackspacechat,0
mov isenterchat,0
mov al,0
mov datatosendflag,0
ret
displayinfirsthalfchat   endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
displayinsecondhalfchat  PROC
cmp isbackspacechat,1
jne v11c 
cmp currxchat,0
jne co11c
cmp currychat,13
jne re1c
jmp f11c
re1c:
dec currychat
dec si
mov ah,[si]
mov currxchat,ah
jmp f11c
co11c:
dec currxchat
f11c:
mov al,32
jmp con11c
v11c:
cmp isenterchat,1
jne con11c
ic11c:
inc currychat
mov ah,currxchat
mov [si],ah
inc si
mov currxchat,0

jmp cheakychat
con11c:
mov AH,2
mov dl ,currxchat 
mov dh ,currychat 
Int 10h  ;to set the cursor
;;;;;;;;;;;;;;display;;;;;;;;;;;;;;;;;;;;;
mov AH,9  
mov bh,0          ;Page 0:al ,Letter 
mov cx,1h         ;1 times 
mov bl,0eh      ; background 
Int 10h      ;to display the character
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmp isbackspacechat,1
je finishsh1c
inc currxchat
cheakxx1c:
cmp currxchat ,80
jne finishsh1c
normall:
jmp ic11c
;mov currx,0
;inc curry
cheakychat:
   cmp currychat,25
   jne finishsh1c
   mov ah,6        ; function 6
   mov al,1        ; scroll by 1 line    
   mov bh,0     ; normal video attribute         
   mov ch,16        ; upper left Y
   mov cl,0        ; upper left X
   mov dh,24       ; lower right Y
   mov dl,79       ; lower right X 
   int 10h           
   ;Scroll up ;;;;;;;

;;;;;;;;;;;;;;;;
dec currychat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
finishsh1c:
mov AH,2
mov dl ,cursxchat 
mov dh ,cursychat 
Int 10h  ;to set the cursor
mov isenterchat,0
mov isbackspacechat,0
mov al,0
ret
displayinsecondhalfchat  endp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
MAIN    PROC FAR
mov ax ,@data
mov ds,ax
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
mov di,offset lastsxchat
mov si,offset lastrxchat

call initialize
call splitscreenchat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cheakreceivechat:
;;;;;;;;;;;;;receive;;;;;;;;;;;;;;;;;;;;;;;;;;
;Check that Data is Ready
	mov dx , 3FDH		; Line Status Register
	in al , dx 
  	test al , 1
  	Jz CHKeychat                                   ;Not Ready
 ;If Ready read the VALUE in Receive data register
  	mov dx , 03F8H
  	in al , dx 
  	mov VALUErchat , al
    mov al , VALUErchat
	cmp al,27
    je exit1c
	cmp al,8
	jne o1c
	mov isbackspacechat,1
    jmp contr1c
o1c:cmp al,13
    jne contr1c
	mov isenterchat,1
contr1c:call displayinsecondhalfchat
jmp cheakreceivechat
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
CHKeychat:
mov al,0
cmp datatosendflag,1
je sendchat
mov AH,01h
Int 16h
cmp al,0
je cheakreceivechat
mov AH,00h;;;read the char and put in al
Int 16h
mov VALUEschat,al ;;;;;;;;;data to send
;;;;;;;;;;;;;;;;;send;;;;;;;;;;;;;;;;;;;;
sendchat:;Check that Transmitter Holding Register is Empty
		mov dx , 3FDH		; Line Status Register
        In al , dx 			;Read Line Status
  		test al , 00100000b
  		JZ cheakreceivechat            ;Not empty;tb lw mlyanh a5od mnh input tany wala lazm astna

;If empty put the VALUE in Transmit data register
  		mov dx , 3F8H		; Transmit data register
  		mov al,VALUEschat
  		out dx , al
		cmp al,27
        je exit1c
		cmp al,8
		jne j1c
		mov isbackspacechat,1
		jmp cont1c
	j1c:	cmp al,13
		jne cont1c
        mov isenterchat,1		
cont1c:call displayinfirsthalfchat
jmp cheakreceivechat

exit1c:
 mov AH,0          
 mov AL,03h
 INT 10h    
    ; return control to operating system
 mov AH , 4ch
 INT 21H 
 ret
MAIN    ENDP
END MAIN