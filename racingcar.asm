.Model Small
.Stack 100h
.Data
Xarray dw 350,495,200
Yarray dw 25,185,345
MYx dw 0
MYy dw 185
prevY dw 185
Xpos dw 400
Ypos dw 25
len dw 100
wid dw 100
gameOver dw 0
point dw 0
temp1 dw ?
lastOutput db 15 dup(0ah),38 dup(" "),"Score:$"

.Code
main Proc 
    mov ax, @data
    mov ds, ax
 
; set CGA 640x480 16 color mode
    MOV Ah, 0
    mov al, 12h
    INT 10h
; draw line pixel by pixel  
    MOV AH, 0CH
    MOV AL, 12
    
    
    LineDraw:
    MOV CX, 0 ; beginning col
    MOV DX, 159 ; beginning row
    
    MOV BX, 3
    L1: 
        MOV CX, 0
        CMP BX, 0
        JLE NEXT
            S1: INT 10h
                INC CX
                CMP CX, 640
                JLE S1
        INC DX
        DEC BX
        JMP L1        
        
        
    NEXT:
    
    MOV CX, 0 ; beginning col
    MOV DX, 320 ; beginning row
    
    MOV BX, 3
    L2: 
        MOV CX, 0
        CMP BX, 0
        JLE NEXT2
            S2: INT 10h
                INC CX
                CMP CX, 640
                JLE S2
        INC DX
        DEC BX
        JMP L2
    
        
    NEXT2:
        cmp gameOver, 1
        ;mov al, 0
        je DrawAllCars
        
        mov al, 15
        
        
        DrawAllCars:
        mov Bx, Xarray
        mov Xpos, BX
        mov bx, Yarray
        mov Ypos, bx
        call drawCar
        
        
        lea si, Xarray
        add si, 2
        mov bx, [si]
        mov Xpos, bx
        lea si, Yarray
        add si, 2
        mov Bx, [si]
        mov Ypos, BX
        call drawCar
        
        mov bx, Xarray+4
        mov Xpos, bx
        mov bx, Yarray+4
        mov Ypos, bx
        call drawCar
        
        cmp gameOver, 1
        je eraseMyCar
               
        
        next3:
        
            mov Bx, Xarray
            mov Xpos, BX
            mov Bx, Yarray
            mov Ypos, BX
            
            dec Xpos
            call moveCar
            mov bx, xpos
            mov Xarray, bx
            
            mov bx, Xarray+2
            mov Xpos, bx
            mov bx, Yarray+2
            mov Ypos, bx
            
            dec Xpos
            call moveCar
            mov bx, Xpos
            mov Xarray+2, bx
            
            mov bx, Xarray+4
            mov Xpos, bx
            mov bx, Yarray+4
            mov Ypos, bx
            
            dec Xpos
            call moveCar
            mov bx, Xpos
            mov Xarray+4, bx
            
            call moveMycar
            
            cmp gameOver, 1
            JE GOver
            jMP NEXT3 
     
            
    GOver:
    MOV AH, 0CH
    MOV AL, 0
    jmp LineDraw
    
    
    eraseMyCar:
        
    mov bx, MYx
    mov Xpos, bx
    mov bx, MYy
    mov Ypos, bx
    call drawCar
    
    
        
        FINISH:
        
        lea dx, lastOutput
        mov ah, 9
        int 21h
        
        mov ah, 2
        mov bx, point
        add bx, '0'
        mov dx, bx
        int 21h
    
            
        MOV AH, 0
        INT 16h
        
        MOV AX, 3
        INT 10h
        
        
        
        MOV AH, 4CH
        INT 21h
main EndP

drawCar proc
    mov ah, 0ch   

    MOV Cx, Xpos ; beginning col
    MOV Dx, Ypos; beginning row
    
    
    mov bx, len
    mov temp1, bx
    add temp1, cx
    MOV Bx, wid
    Line: 
        MOV Cx, Xpos
        CMP BX, 0
        JLE ok
            col:
                INT 10h
                INC CX
                cmp cx, temp1
                JLE col
        INC DX
        DEC BX
        JMP Line 
 
 ok:
 
 
 ret        

drawCar endp

moveCar proc
    mov ah, 0ch
    mov al, 0
    cmp Xpos, 0
    JGE singleLine
    mov cx, 0
    mov dx, Ypos
    f1: int 10h
        cmp cx, len
        jg f2
        inc cx
        jmp f1
    
        
    f2:     
    inc point    
    mov Xpos, 640
    ret
    
    
    
    singleLine:
    
    mov bx, Ypos
    cmp MYy, bx
    jne noCollision
    mov bx, Xpos
    cmp len, bx
    jge collision
    
    noCollision:
    mov al, 0
    mov cx, Xpos
    ;inc cx
    add cx, len
    inc cx
    mov dx, Ypos
    mov bx, wid
    back:
        cmp bx, 0
        jle draw
        int 10h
        inc dx
        dec bx
        jmp back
    
    draw:
    mov al, 15
    
    mov cx, Xpos
    mov dx, Ypos
    mov bx, wid
    forward:
        cmp bx, 0
        jle okk
        int 10h
        inc dx
        dec bx
        jmp forward
        
    okk:
    
    ret
    
    collision:
    mov gameOver, 1
    inc Xpos
    ret
    

moveCar endp

moveMyCar proc   

    mov ah, 06h
    mov dl, 0ffh
    int 21h
    jz exit
    
    mov bx, MYy
    mov prevY, bx
    
    cmp al, 72
    jne down
    cmp MYy, 185
    jne third
    mov MYy, 25
    jmp exit
    
    third:
        cmp MYy, 345
        jne exit
        mov MYy, 185
        jmp exit
        
    down:
        cmp al, 80
        jne exit
        cmp MYy, 25
        jne second
        mov MYy, 185
        jmp exit
        
        
        second:
            mov MYy, 345
            
        
    exit:
    mov bx, MYy
    cmp bx, prevY
    je noNeedToErase
    
    mov bx, MYx
    mov Xpos, bx
    mov bx, prevY
    mov Ypos, bx
    mov ah, 0ch
    mov al, 0
    call drawCar
    
    
    noNeedToErase:
    mov bx, MYx
    mov Xpos, bx
    mov bx, MYy
    mov Ypos, bx
    mov prevY, bx
    mov ah, 0ch
    mov al, 9
    call drawCar
    
    
    mov cx, 0h
    mov dx, 0h
    mov ah, 85h
    int 15h 
    
    ret 
moveMyCar endp



     End main
