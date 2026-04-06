#DEFINE BLACK 0
#DEFINE BLUE 1
#DEFINE RED 2
#DEFINE PINK 3
#DEFINE GREEN 4
#DEFINE CYAN 5
#DEFINE YELLOW 6
#DEFINE WHITE 7

#DEFINE boardX 21
#DEFINE boardY 12

#DEFINE boardPX 1
#DEFINE boardPY 11

#DEFINE tokensX 6
#DEFINE tokensY 5


DIM board(boardY,boardX) as Ubyte => { _
    {05,00,00,05,00,00,05,00,00,05,00,00,05,00,00,05,00,00,05,00,00,05},_
    {02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02},_
    {08,00,00,09,00,00,09,00,00,09,00,00,09,00,00,09,00,00,09,00,00,07},_
    {02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02},_
    {08,00,00,09,00,00,09,00,00,09,00,00,09,00,00,09,00,00,09,00,00,07},_
    {02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02},_
    {08,00,00,09,00,00,09,00,00,09,00,00,09,00,00,09,00,00,09,00,00,07},_
    {02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02},_
    {08,00,00,09,00,00,09,00,00,09,00,00,09,00,00,09,00,00,09,00,00,07},_
    {02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02},_
    {08,00,00,09,00,00,09,00,00,09,00,00,09,00,00,09,00,00,09,00,00,07},_
    {02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02,00,00,02},_
    {03,01,01,06,01,01,06,01,01,06,01,01,06,01,01,06,01,01,06,01,01,04}_
}

DIM tokens(tokensY,tokensX) as Ubyte => { _
    {0,0,0,0,0,0,0},_
    {0,0,0,0,0,0,0},_
    {0,0,0,0,0,0,0},_
    {0,0,0,0,0,0,0},_
    {0,0,0,0,0,0,0},_
    {0,0,0,0,0,0,0}_
}
DIM empty$ as string = "                               "

DIM playerC(2) as Ubyte => {WHITE, RED, YELLOW}
DIM playerS$(2) as string 
playerS$(0) = "None": playerS$(1) = "RED": playerS$(2) = "YELLOW"


DIM player as Ubyte = 1
DIM victory as Ubyte = 0

DIM scX as Ubyte = 0
DIM scY as Ubyte = 14

POKE (UINTEGER 23675,@graph)

StartGame:
BORDER GREEN: PAPER BLACK: CLS

DrawScreen()

gameLoop: REM Game loop

a$=INKEY$
'a$ = peek 23560
IF a$ = " " THEN GOTO EndGame

IF a$ = "d" THEN MovePlayer(1): doPause(8)
IF a$ = "a" THEN MovePlayer(-1): doPause(8)
IF a$ = "s" THEN DropToken(): IF victory = 0 THEN doPause(20) ELSE GOTO SubVictory

GOTO gameLoop

SUB MovePlayer(dir as Byte)
    IF dir < 0 AND scX < 1 THEN RETURN
    IF dir > 0 AND scX > 5 THEN RETURN
    ClearCirlce()
    scX = scX + dir
    DrawScreen()
    BeepSound(0)
END SUB

FUNCTION CheckLine(xx as Ubyte, yy as Ubyte, dirY as byte) as Ubyte

    DIM c as Ubyte = 0
    DIM x, y, ix, iy, i as Ubyte
    DIM p as Ubyte = tokens(yy,xx)

    x = xx: y = yy

    FOR i = 0 TO 3
        IF x < 1 OR y < 1 THEN EXIT FOR
        IF x > tokensX OR y > tokensY THEN EXIT FOR
        x = xx - i: y = yy + dirY * i
    NEXT i

    FOR i = 0 TO 6
        ix = x + i: iy = y - dirY * i
        IF ix > tokensX OR iy > tokensY THEN EXIT FOR
        IF ix < 0 OR iy < 0 THEN EXIT FOR
        IF tokens(iy,ix) = p THEN c = c + 1 ELSE c = 0
        IF c > 3 THEN EXIT FOR
    NEXT i

    return c

END FUNCTION

SUB CheckBoard(xx as Ubyte, yy as Ubyte)
    'PRINT AT 2, 0;"                 "

    DIM p as Ubyte = tokens(yy,xx)

    DIM x,y as byte
    DIM ix, iy, i as Ubyte
    DIM c as Ubyte = 0
    DIM t as Ubyte

    'VERTICAL line
    FOR iy = 0 TO 3
        IF yy + iy > tokensY THEN EXIT FOR
        IF tokens(yy + iy,xx) <> p THEN EXIT FOR
        c = c + 1
        IF c > 3 THEN t = 1: EXIT FOR
    NEXT iy

    'HORIZONTAL line
    IF c < 3 THEN
        c = 0
        x = xx - 3: IF x < 0 THEN x = 0
        FOR ix = x TO xx + 3
            IF ix > tokensX THEN EXIT FOR
            IF tokens(yy,ix) = p THEN c = c + 1 ELSE c = 0
            IF c > 3 THEN t = 2: EXIT FOR
        NEXT ix        
    END IF

    'DIOGONAL from left to top righ bottom
    IF c < 3
        c = CheckLine(xx,yy, -1): t = 2
    END IF

    'DIOGONAL from left bottom to righ low
    IF c < 3
        c = CheckLine(xx,yy, 1): t = 3
    END IF

    'PRINT INK WHITE; AT 1,0; c ; " "; p; " "; t
    IF c > 3 THEN victory = p

END SUB


SUB NextPlayer() 
    IF player = 1 THEN player = 2 ELSE player = 1
END SUB

SUB DropToken()
    IF tokens(0, scX) > 0 THEN BeepSound(2): RETURN

    DIM y as Ubyte
    FOR y = 0 TO tokensY 
        IF tokens(y+1, scX) > 0 OR y = tokensY  THEN 
            tokens(y, scX) = player
            CheckBoard(scX, y)
            BeepSound(1)
            EXIT FOR
        END IF
    NEXT y    

    NextPlayer()
    DrawScreen()
    
END SUB

SUB DrawScreen()
    'CLS
    PRINT AT 0,0; empty$
    PRINT INK WHITE; AT 0,0; "PLAYER "; playerS$(player); " MOVE"

    DrawBoard()
    DrawTokens()
    
    DrawCircle(scX * 3 + 3, scY, playerC(player))
END SUB

SUB ClearCirlce()
    INK BLACK
    PRINT AT scY - 4, scX * 3 + 2; "  "
    PRINT AT scY - 5, scX * 3 + 2; "  "
END SUB

SUB DrawCircle(xx as Ubyte,yy as Ubyte,color as Ubyte)
    INK color
    FOR n=1 TO 7: CIRCLE xx * 8,yy * 8,n: NEXT n
END SUB

SUB DrawBoard()
    INK BLUE
    
    DIM x,y, cr as Ubyte
    FOR y = 0 TO boardY
        FOR x = 0 TO boardX
            cr = board(y,x)
            IF cr > 0 THEN
                PRINT AT y + boardPY, x + boardPX; CHR$(143 + cr)
            END IF
        NEXT x
    NEXT y
    
END SUB

SUB DrawTokens()
    DIM x,y, t as Ubyte
    FOR y = 0 TO tokensY
        FOR x = 0 TO tokensX
            t = tokens(y,x)
            IF t > 0 THEN
                DrawCircle(boardPX + x*3 + 2, (tokensY - y + 1)*2, playerC(t))
            END IF
        NEXT x
    NEXT y
END SUB

graph:
ASM
	DB 0,0,255,255,0,0,255,255
	DB 102,102,102,102,102,102,102,102
	DB 102,103,99,96,96,112,63,31
	DB 102,230,198,6,6,14,252,248
	DB 24,60,102,102,102,102,102,102
	DB 102,231,195,129,0,0,255,255
	DB 198,134,198,102,102,102,102,102
	DB 99,97,99,102,102,102,102,102
	DB 195,129,195,102,102,102,102,102
	DB 102,102,102,102,102,102,195,255
	DB 102,102,102,102,102,103,99,127
	DB 102,102,102,102,102,230,198,254
END ASM

SUB BeepSound(sound as Ubyte)
    IF sound = 0 THEN BEEP .1,1
    IF sound = 1 THEN BEEP .75,0
    IF sound = 2 THEN BEEP 1,-1: BEEP 1,-2: BEEP 1,-1

END SUB

SUB doPause(frameCount as uByte)
    FOR n=1 to frameCount
        ASM 
        HALT
        END ASM
    NEXT n
END SUB

SUB ClearGame() 
    scX = 0: scY = 14
    DIM x,y as Ubyte
    FOR x = 0 TO tokensX: FOR y = 0 TO tokensY
        tokens(x,y) = 0
    NEXT y: NEXT x
    victory = 0
    player = 1
END SUB

SubVictory:
    BORDER playerC(victory)
    PRINT AT 0,0; empty$
    PRINT AT 1,0; empty$

    PRINT INK WHITE; AT 0,0; "PLAYER: "; playerS$(victory); " WINS!"
    PRINT INK WHITE; AT 1,0; "START AGAIN? (y) OR EXIT (n)"; 
    
    GetKeys:
    
    a$=INKEY$

    IF a$ = "y" THEN ClearGame(): GOTO StartGame
    IF a$ <> "n" THEN GOTO GetKeys

EndGame:
    INK BLACK: PAPER WHITE: BORDER BLUE: CLS: STOP