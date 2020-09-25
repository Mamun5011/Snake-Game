.Model Small

PUBLIC TIMER_TICK
DRAW_ROW MACRO X
    LOCAL L1
    MOV AH,0CH
    ; MOV AL,3
    MOV CX,10
    MOV DX,X
L1: INT 10H
    INC CX 
    CMP CX,301
    JL L1
    ENDM
DRAW_COLUMN MACRO Y
    LOCAL L2
    MOV AH,0CH
    ;  MOV AL,3
    MOV CX,Y
    MOV DX,10
L2: INT 10H
    INC DX 
    CMP DX,190
    JL L2
    ENDM


.Stack 100h


.DATA
  A DB 0
  v DB 0
  loading db 0
  pause db,0
  welcomemsg db 1 dup(0ah),4 dup("   "),2 dup(" "),"             WELLCOME TO SNAKE GAME           ",2 dup(" "),3 dup("   "),9 dup(" "),'$'
  startmsg db 9 dup(0ah),4 dup(">> "),2 dup(" "),"        press 's' to start the game        ",2 dup(" "),4 dup(">> "),9 dup(" "),'$'
  resumemsg db 1 dup(0ah),4 dup(">> "),2 dup(" "),"        press 'r' to resume the game       ",2 dup(" "),4 dup(">> "),9 dup(" "),'$'
  savemsg db 1 dup(0ah),4 dup(">> "),2 dup(" "),"        press  'l'  to save the game       ",2 dup(" "),4 dup(">> "),9 dup(" "),'$'
  highscoremsg db 1 dup(0ah),4 dup(">> "),2 dup(" "),"        press 'h' to show High score       ",2 dup(" "),4 dup(">> "),9 dup(" "),'$'
  SHOW_GAME_OVER db 14 dup(0ah),27 dup(" "),"      GAME OVER      $" ,36 dup(" "),'$'
  Exitmsg db 1 dup(0ah),6 dup(">> "),2 dup(" "),"       press 'e' to exit             ",2 dup(" "),4 dup(">> "),9 dup(" "),'$'
  okay_msg  db 16 dup(0ah),27 dup(" "),"   press 'o' to continue        $" ,36 dup(" "),'$'
  
  score_5 db 14 dup(0ah),27 dup(" "),"Your Score is :$"
  score_6 db 14 dup(0ah),22 dup(" "),"Your High Score is :$"
  ;point dw 0
  point_2 db ,31 dup(" "),'$'
  point_3 db ,31 dup(" "),'$'
 
 ;himel
NEW_TIMER_VEC DW  ?,?
OLD_TIMER_VEC DW ?,?
TIMER_FLAG    DB  0
HEAD_DX       DW  ?
HEAD_CX       DW  ?
TAIL_DX       DW  ?
TAIL_CX       DW  ?
SPEED_DX      DW 0
SPEED_CX      DW 0
CUR_DIR       DB  4DH
SNAKE_DX      DW 100 DUP(?) 
SNAKE_CX      DW 100 DUP(?)
SC_INT        dw 0
;FOOD_DX       DW ?
;FOOD_CX       DW ?
FOOD_IND      DW 0
FOOD_DX       DW 114,138,162,78,90,102,46,34,86,94,110,134,158,74,86,98,42,30,82,90,'$'
FOOD_CX       DW 168,96,156,108,204,84,180,228,164,92,164,92,152,104,200,80,176,224,160,88,'$'

SNAKE_SIZE    DW 3
STOP          DW ?
SCORE         DB '000000$'
stop_flag db 0  

FILE_SAVEGAME DB "SAVEGAME.TXT",0 
HIGHSCORE_FILE DB "INPUT.TXT",0
HANDLE DW ? 
Z DW ?
  
  
  
.Code



SET_DISP_MODE PROC
    MOV AH,0
    MOV AL,04H
    INT 10H
    MOV AH,0BH
    MOV BH,0
    MOV BL,8
    INT 10H
    MOV BH,1
    MOV BL,1
    INT 10H
    MOV AL ,3
    DRAW_ROW 10
    DRAW_ROW 189
    DRAW_COLUMN 10
    DRAW_COLUMN 300
    RET
    SET_DISP_MODE ENDP

DISPLAY_BALL PROC
    MOV AH, 0CH ; write pixel
    INT 10H
    INC CX      ; pixel on next col
    INT 10H
    INC CX      ; pixel on next col
    INT 10H
    INC CX      ; pixel on next col
    INT 10H
    INC DX      ; down 1 row
    INT 10H
    INC DX      ; down 1 row
    INT 10H
    INC DX      ; down 1 row
    INT 10H
    DEC CX      ; prev col
    INT 10H
    DEC CX      ; prev col
    INT 10H
    DEC CX      ; prev col
    INT 10H
    DEC DX 
    INT 10H    ; restore dx
    DEC DX 
    INT 10H
    DEC DX 
    RET
    DISPLAY_BALL ENDP    
    
CHECK_BOUNDARY PROC 
    MOV CX,HEAD_CX
    MOV DX,HEAD_DX
    CMP CX,15
    JG LP1
     MOV STOP,1 
LP1:
    CMP CX, 294
    JL LP2
    MOV STOP,1
; check row value
LP2:    
    CMP DX, 11
    JG LP3
    MOV STOP,1
LP3:    
    CMP DX, 183
    JL LP4
    MOV STOP,1
LP4:
    MOV BX,2
    ADD CX,SPEED_CX
    ADD DX,SPEED_DX
   CHECK:
    CMP SNAKE_DX[BX],DX
    JNE INCREASE
    CMP SNAKE_CX[BX],CX
    JNE INCREASE
    MOV STOP,1
    JMP DONE
   INCREASE:
    ADD BX,2
    MOV DI,SNAKE_SIZE
    ADD DI,DI
    CMP BX,DI
    JNE CHECK
DONE:
    RET 
    CHECK_BOUNDARY EndP  
    
TIMER_TICK PROC
    PUSH DS
    PUSH AX
    MOV AX,SEG TIMER_FLAG
    MOV DS,AX
    MOV TIMER_FLAG,1
    POP AX
    POP DS
    IRET
    TIMER_TICK ENDP

DRAW_SNAKE PROC ; PARAM LENGH,40
    MOV AL, 1
    MOV BX, 0
    DR_SN:
    MOV DX,SNAKE_DX[BX]
    MOV CX,SNAKE_CX[BX]
    CALL DISPLAY_BALL
    ADD BX,2
    MOV DI,SNAKE_SIZE
    ADD DI,DI
    CMP BX,DI
    JNE DR_SN
    RET
    DRAW_SNAKE ENDP

DRAW_FOOD PROC
    MOV AL,2
    ADD FOOD_IND,2
    CMP FOOD_IND,20*2
    JNE DR
    MOV FOOD_IND,0
  DR:
    MOV BX,FOOD_IND
    MOV DX,FOOD_DX[BX]
    MOV CX,FOOD_CX[BX]
    CALL DISPLAY_BALL
    
    RET
    DRAW_FOOD ENDP
    
SHOW_SCORE PROC
    MOV DX,0
    MOV AX,0
    MOV AX,SC_INT
    MOV BX,5
 SET_SC:
    MOV CX,10
    DIV CX
    MOV SCORE[BX],DL
    ADD SCORE[BX],'0'
    MOV DX,0
    DEC BX
    CMP BX,-1
    JNE SET_SC
    
    MOV AH,2
    XOR BH,BH
    MOV DX,0020H
    INT 10H
    
    MOV AH,09
    MOV DX,OFFSET SCORE
    INT 21H
    
    
    RET
    SHOW_SCORE ENDP
     
CHECK_FOOD PROC
    MOV BX,FOOD_IND
    MOV DI,HEAD_DX
    CMP FOOD_DX[BX],DI
    JNE FIN2
    MOV DI,HEAD_CX
    CMP FOOD_CX[BX],DI
    JNE FIN2
    INC SNAKE_SIZE
    ADD SC_INT,5
    CALL DRAW_FOOD
    CALL SHOW_SCORE
FIN2:
    RET
    CHECK_FOOD ENDP

MOVE_ARRAY PROC
    MOV DI,SNAKE_SIZE
    DEC DI
    ADD DI,DI
    MOV BX,DI
    SHIFT:
    MOV DI,SNAKE_DX[BX-2]
    MOV SNAKE_DX[BX],DI
    MOV DI,SNAKE_CX[BX-2]
    MOV SNAKE_CX[BX],DI
    SUB BX,2
    CMP BX,0
    JNE SHIFT
    MOV BX,SNAKE_SIZE
    DEC BX
    ADD BX,BX

    MOV DI,SNAKE_DX[BX]
    MOV TAIL_DX,DI
    MOV DI,SNAKE_CX[BX]
    MOV TAIL_CX,DI
    MOV DI,HEAD_DX
    MOV SNAKE_DX[0],DI
    MOV DI,HEAD_CX
    MOV SNAKE_CX[0],DI
    RET
    MOVE_ARRAY ENDP

GAME_LOOP PROC
    MOV STOP,0
    cmp pause,1
    je FIN3
    CALL CHECK_BOUNDARY
    CALL CHECK_FOOD
    CMP STOP,1
    JE GAME_FINISH
    TEST_TIMER:
    CMP TIMER_FLAG, 1 ;4 TICKS
    JNE TEST_TIMER
    MOV TIMER_FLAG, 0 
    TEST_TIMER_2:
    CMP TIMER_FLAG, 1
    JNE TEST_TIMER_2
    MOV TIMER_FLAG, 0
    ; TEST_TIMER_3:
    ; CMP TIMER_FLAG, 1
    ;JNE TEST_TIMER_3
    ;MOV TIMER_FLAG, 0
    ;TEST_TIMER_4:
    ; CMP TIMER_FLAG, 1
    ;JNE TEST_TIMER_4
    ; MOV TIMER_FLAG, 0
  
    MOV DI,SPEED_CX
    ADD HEAD_CX,DI
    MOV DI,SPEED_DX
    ADD HEAD_DX,DI
    MOV CX,HEAD_CX
    MOV DX,HEAD_DX
    MOV AL, 1
    CALL DISPLAY_BALL
    MOV CX,TAIL_CX
    MOV DX,TAIL_DX
    MOV AL, 0
    CALL DISPLAY_BALL
    CALL MOVE_ARRAY
    JMP FIN3
 

GAME_FINISH:
    
    CALL GAME_OVER 
    CALL SHOW
    CALL START
    
    FIN3:
   RET
    GAME_LOOP ENDP
    
    
MOVE_RIGHT PROC
    MOV SPEED_DX,0
    MOV SPEED_CX,4
    RET
    MOVE_RIGHT ENDP

MOVE_LEFT PROC
    MOV SPEED_DX,0
    MOV SPEED_CX,4
    NEG SPEED_CX
    RET
    MOVE_LEFT ENDP
    
MOVE_UP PROC
    MOV SPEED_DX,4
    MOV SPEED_CX,0
    NEG SPEED_DX
    RET
    MOVE_UP ENDP
    
MOVE_DOWN PROC
    MOV SPEED_DX,4
    MOV SPEED_CX,0
    RET
    MOVE_DOWN ENDP
    
SET_UP_INT PROC
    MOV AH, 35H
    INT 21H
    MOV [DI], BX
    MOV [DI+2], ES
    MOV DX, [SI]
    PUSH DS 
    MOV DS, [SI+2] 
    MOV AH, 25H 
    INT 21H
    POP DS
    RET
    SET_UP_INT ENDP   
 
READCHAR PROC
    MOV AH, 01H
    INT 16H
    JNZ KEYPRESSED
    RET
 KEYPRESSED:
    CMP AL,'p'
    JNE STILL
    CALL PAUSE_1
STILL:

    CMP AL,'l'  
    JE SAVE    
    JMP GET_DIRECTION
SAVE:
    CALL SAVE_GAME    
    JMP START

GET_DIRECTION:
     
 MOV AH, 00H ;get the key
    INT 16H
    CMP CUR_DIR,48H
    JNE NEXT1
    CMP AH, 50H
    JE SKIP
  NEXT1:
    CMP CUR_DIR,50H
    JNE NEXT2
    CMP AH, 48H
    JE SKIP
  NEXT2:
    CMP CUR_DIR,4BH
    JNE NEXT3
    CMP AH, 4DH
    JE SKIP
  NEXT3:
    CMP CUR_DIR,4DH
    JNE CHANGE
    CMP AH, 4BH
    JE SKIP
CHANGE:
    MOV CUR_DIR,AH
SKIP:
    RET
    READCHAR ENDP      
    
MOVE_SNAKE PROC
    CMP CUR_DIR,48H
    JE UP
    CMP CUR_DIR,4BH
    JE LEFT
    CMP CUR_DIR,4DH
    JE RIGHT
    CMP CUR_DIR,50H
    JE DOWN
    jmp fin
  
  UP:
    CALL MOVE_UP
    JMP FIN
  LEFT:
    CALL MOVE_LEFT
    JMP FIN
  RIGHT:
    CALL MOVE_RIGHT
    JMP FIN
  DOWN:
    CALL MOVE_DOWN
FIN:
    RET
    MOVE_SNAKE ENDP






main Proc
; set VGA 320x200 256 color mode
MOV AX,@DATA
MOV DS,AX
 

start:
; set CGA 640x480 16 color mode
    MOV Ah, 0
    mov al, 12h
    INT 10h
   
   
 ; draw 256 color band   
    MOV AH, 0CH ; write pixel function
    MOV AL,13 ; start pixel color 0
    MOV BH, 0 ; page 0
    MOV DX, 0 ; row
    
         
  OL1:  
        MOV CX, 0 ; col
    
L1:  
        INT 10h
         ; next color
        INC CX  ; next col
        CMP CX, 640
        JL L1
        INC DX; next row
        CMP DX,480  
        JL OL1
    
        lea dx, welcomemsg
        mov ah, 9
        int 21h
        
        lea dx, startmsg
        mov ah, 9
        int 21h
        
       lea dx, resumemsg
        mov ah, 9
        int 21h
        
       lea dx, savemsg
        mov ah, 9
        int 21h
        
        
       lea dx,highscoremsg
        mov ah, 9
        int 21h
        
        lea dx,Exitmsg
        mov ah, 9
        int 21h
   ;here     
        
 check_for_key:

; === check for player commands:

        ;mov     ah, 01h
        ; int     16h
       ; jz      score_1

        MOV AH, 0
        INT 16h
        cmp al,'h'    ; esc - key?
        je score_1 
        cmp al,'s'
        je game_start
        cmp al,'r'
        je load_game
        cmp al,'e'
        je return
        jmp  check_for_key

  score_1:
    call  score_read;show
    jmp  start 
game_start:
           call refresh
           call go_game
           jmp start

load_game:
         call load
         jmp go_game
          jmp start    
     
   
return:    
   ;here  
; getch     
        ;MOV AH, 0 //if itcomments out then e button is needed to press twiceterminate the program
        ;INT 16h  //this too
; return to text mode       
        MOV AX, 3
         INT 10h
; return to DOS
        MOV AH, 4CH
        INT 21h
main EndP
    ; End main
     
 show proc
 push ax
 push dx
 
 ; set CGA 640x480 16 color mode
    MOV Ah, 0
    mov al, 12h
    INT 10h
   
   
 ; draw 256 color band   
    MOV AH, 0CH ; write pixel function
    MOV AL,10 ; start pixel color 0
    MOV BH, 0 ; page 0
    MOV DX, 0 ; row
    
         
    OL_1:  
        MOV CX, 0 ; col
    
    L_1:  
        INT 10h
         ; next color
        INC CX  ; next col
        CMP CX, 640
        JL L_1
        INC DX; next row
        CMP DX,480  
        JL OL_1
        
        mov ah,9
        lea dx,score_5
        int 21h
        
        ; mov ah, 2
        ; mov bx, SC_INT
        ;add bx, '0'
        ; mov dx, bx
        ;int 21h
        
        mov ah,9
        lea dx,score
        int 21h
 
        cmp v,1
        je print_score  
        mov ah,9
        lea dx,point_2
        int 21h
        lea dx,okay_msg
        int 21h
        lea dx,point_2
        int 21h
        
        jmp okay
print_score:        
        mov ah,9
        lea dx,point_3
        int 21h
        mov v,0
        
        
         lea dx,okay_msg
         int 21h
         lea dx,point_2
         int 21h
        
  okay:
        MOV AH, 0
        INT 16h
        cmp al,'o'    ; esc - key?
        jne okay 
        
    
    pop dx
    pop ax 
    ret
  show endp
  
  
 go_game PROC near
    ;MOV AX, @DATA
    ;MOV DS, AX
    CALL SET_DISP_MODE
    MOV NEW_TIMER_VEC, OFFSET TIMER_TICK
    MOV NEW_TIMER_VEC+2, CS
    MOV AL, 1CH; 
    LEA DI, OLD_TIMER_VEC
    LEA SI, NEW_TIMER_VEC
    CALL SET_UP_INT
    
    cmp loading,1
    je no_change
    
    MOV CX,152
    MOV DX,98
    MOV BX,0
MAKE_ARRAY:

    
    MOV SNAKE_CX[BX], CX
    MOV SNAKE_DX[BX], DX
    SUB CX,4
    ADD BX,2
    MOV DI,SNAKE_SIZE
    ADD DI,DI
    CMP BX,DI
    JNE MAKE_ARRAY
  NO_CHANGE:  
     mov di,snake_size
     add di,di
     mov bx,di
    MOV DI,SNAKE_DX[0] 
    MOV HEAD_DX,DI
    MOV DI,SNAKE_CX[0]
    MOV HEAD_CX,DI
    MOV DI,SNAKE_DX[BX-2]
    MOV TAIL_DX,DI
    MOV DI,SNAKE_CX[BX-2]
    MOV TAIL_CX,DI

    CALL DRAW_SNAKE
    MOV DI,HEAD_DX

    CALL DRAW_FOOD
    CALL SHOW_SCORE
    
    
     GM:
     cmp pause,1
     je stop_snake
    CALL READCHAR
    CALL MOVE_SNAKE
    CALL GAME_LOOP
    JMP GM
 stop_snake:    
    ret
  go_game ENDP 
  
 GAME_OVER PROC NEAR

 push ax
 push bx
 push dx
 
 ; set CGA 640x480 16 color mode
    MOV Ah, 0
    mov al, 12h
    INT 10h
   
   
 ; draw 256 color band   
    MOV AH, 0CH ; write pixel function
    MOV AL,10 ; start pixel color 0
    MOV BH, 0 ; page 0
    MOV DX, 0 ; row
    
         
    OL_5:  
        MOV CX, 0 ; col
    
        L_5:  
        INT 10h
         ; next color
        INC CX  ; next col
        CMP CX, 640
        JL L_5
        INC DX; next row
        CMP DX,480  
        JL OL_5
        
        mov ah,9
        lea dx,SHOW_GAME_OVER
        int 21h
        
        
        mov ah,9
        lea dx,point_2
        int 21h
        
        lea dx,okay_msg
        int 21h
        lea dx,point_2
        int 21h
        
        ;SAVE HIGHSCORE TO FILE
   
     LEA DX,HIGHSCORE_FILE
        
     MOV AH,3DH
    MOV AL,0
    INT 21H
    MOV HANDLE,AX
    LEA DX,z
    MOV BX,HANDLE
    MOV AH,3FH
    MOV CX,1
    INT 21H
             LEA DX,HIGHSCORE_FILE
         MOV AH,3EH
        mov bx,handle
       INT 21H
     mov bx,z
     cmp bx,SC_INT
     JG HERE
     
       LEA DX,HIGHSCORE_FILE
       MOV AH,3CH
       MOV CX,0   
       INT 21h
       ; JC OPEN_ERROR 
       MOV HANDLE,AX
      ; write to file:
       MOV AH,40H
       MOV BX,HANDLE
       MOV DX, OFFSET SC_INT
       MOV CX,1
       INT 21h
     
       
        
        
        
       ;END OF CODE OF SAVING SCORE
  
         LEA DX,HIGHSCORE_FILE
         MOV AH,3EH
        mov bx,handle
       INT 21H
       
  HERE:        
          
        mov v,1
        okay_1:
        MOV AH, 0
        INT 16h
        cmp al,'o'    ; esc - key?
        jne okay_1 
        
    
    pop dx
    pop bx
    pop ax 
    ret
 
 

GAME_OVER ENDP 

SAVE_GAME PROC
     PUSH AX
     PUSH BX
     PUSH CX
     PUSH DX
     PUSH SI
     PUSH DI
      mov pause,1
       LEA DX,FILE_SAVEGAME
       MOV AH,3CH
       MOV CX,0   
       INT 21h
       ; JC OPEN_ERROR 
       MOV HANDLE,AX
      ; write to file:
       MOV AH,40H
       MOV BX,HANDLE
       MOV DX, OFFSET CUR_DIR
       MOV CX,1
       INT 21h
       
      
         MOV AH,40H
       LEA DX,SNAKE_DX
       MOV CX,100
        INT 21H
        
         MOV AH,40H
        LEA DX,SNAKE_CX
       MOV CX,100
        INT 21H
        
         MOV AH,40H
         LEA DX,SC_INT
        MOV CX,1
        INT 21H
        
        MOV AH,40H
         LEA DX,FOOD_IND
        MOV CX,1
        INT 21H
        
        
       
        MOV AH,40H
         LEA DX,SNAKE_SIZE
        MOV CX,1
        INT 21H
       
        MOV AH,40H
         LEA DX,STOP 
        MOV CX,1
        INT 21H
        
        MOV AH,40H
             LEA DX,SCORE 
             MOV CX,6
             INT 21H
       

        
 
    MOV AH,3EH
    mov bx,handle
    INT 21H
    

     POP DI
     POP SI
     POP DX
     POP CX 
     POP BX 
     POP AX
    
  RET
SAVE_GAME ENDP


load proc near
    cmp stop,1
    je start_new
    jmp same
start_new:
        call refresh
          call go_game
           jmp start
        
       
same: 
    cmp stop,1 
    je flag    
    mov loading,1
flag:
    
    mov pause,0
    LEA DX,FILE_SAVEGAME
    MOV AH,3DH
    MOV AL,0
    INT 21H
    MOV HANDLE,AX
    LEA DX,CUR_DIR
    MOV BX,HANDLE
    MOV AH,3FH
    MOV CX,1
    INT 21H
   
    MOV AH,3FH
    LEA DX,SNAKE_DX
    MOV CX,100
    INT 21H
    
    MOV AH,3FH
    LEA DX,SNAKE_CX
    MOV CX,100
    INT 21H
    
        MOV AH,3FH
        LEA DX,SC_INT
        MOV CX,1
        INT 21H
        
        MOV AH,3FH
        LEA DX,FOOD_IND
        MOV CX,1
        INT 21H
       
       
        MOV AH,3FH
         LEA DX,SNAKE_SIZE
        MOV CX,1
        INT 21H
       
        MOV AH,3FH
         LEA DX,STOP 
        MOV CX,1
        INT 21H
        
             MOV AH,3FH
             LEA DX,SCORE 
             MOV CX,6
             INT 21H
           
          MOV AH,3EH
          mov bx,handle
          INT 21H
        

ret
load endp    

refresh proc near
  mov FOOD_IND,0
  mov loading,0
  mov A,0
  mov v,0
  mov pause,0
  mov NEW_TIMER_VEC,0 
  mov NEW_TIMER_VEC+1,0
  mov OLD_TIMER_VEC,0 
  mov OLD_TIMER_VEC+1,0
  MOV TIMER_FLAG,0
  MOV HEAD_DX ,0
  MOV HEAD_CX,0
  MOV TAIL_DX,0
  MOV TAIL_CX,0
  MOV CUR_DIR,4DH ;HERE
  MOV CX,100
  XOR DI,DI
 D1:
   MOV SNAKE_DX[DI],0
   ADD DI,2
   LOOP D1
   MOV CX,100
   XOR DI,DI
D2:
   MOV SNAKE_CX[DI],0
   ADD DI,2
   LOOP D2
   
   MOV SPEED_DX,0
   MOV SPEED_CX,0
   MOV SC_INT,0
   MOV FOOD_DX,0
   MOV FOOD_CX,0
   MOV SNAKE_SIZE,3
   MOV STOP,0
   
  MOV CX,6
  XOR DI,DI
 D3:
    MOV SCORE[DI],0
    INC DI
   LOOP D3 


ret
refresh endp

score_read proc near
   
 push ax
 push dx
 push z
 push SC_INT
 
 ; set CGA 640x480 16 color mode
    MOV Ah, 0
    mov al, 12h
    INT 10h
   
   
 ; draw 256 color band   
    MOV AH, 0CH ; write pixel function
    MOV AL,10 ; start pixel color 0
    MOV BH, 0 ; page 0
    MOV DX, 0 ; row
    
         
    OL_11:  
        MOV CX, 0 ; col
    
        L_11:  
        INT 10h
         ; next color
        INC CX  ; next col
        CMP CX, 640
        JL L_11
        INC DX; next row
        CMP DX,480  
        JL OL_11
        
        
        
    LEA DX,HIGHSCORE_FILE
    MOV AH,3DH
    MOV AL,0
    INT 21H
    MOV HANDLE,AX
    LEA DX,SC_INT
    MOV BX,HANDLE
    MOV AH,3FH
    MOV CX,1
    INT 21H
    
    LEA DX,HIGHSCORE_FILE
    MOV AH,3EH
    mov bx,handle
    INT 21H 
    
    
    call SHOW_SCORE
    

 
    
    
          mov ah,9
          lea dx,score_6
        int 21h
        
        mov ah,9
        lea dx,score
        int 21h
        
        mov ah,9
        lea dx,point_2
        int 21h
   
        
        lea dx,okay_msg
        int 21h
        lea dx,point_2
        int 21h   
    
    
    
        okay1:
        MOV AH, 0
        INT 16h
        cmp al,'o'    ; esc - key?
        jne okay1  
        
        
pop SC_INT        
pop z
pop dx
pop ax        
ret
score_read endp  


PAUSE_1 PROC NEAR

PUSH AX

key_check:

        MOV AH,0
        INT 16h
        cmp al,'p'    ; esc - key?
        jne key_check 
        
 pop ax

RET
PAUSE_1 ENDP

 End main
 
 
 
 
