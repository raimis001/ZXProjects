#include "../helper.bas"
#include "../hrprint.bas"
#include "zx0.bas"

CONST CHR_DOOR as ubyte = 144
CONST CHR_KEY as ubyte = 145
CONST CHR_SPIDERWEB as ubyte = 146
CONST CHR_CHEST_CLOSED as ubyte = 147
CONST CHR_CHEST_OPENED as ubyte = 148
CONST CHR_DIAMOND as ubyte = 149
CONST CHR_BOOK as ubyte = 150

DIM ch_posY as ubyte = 2*8
DIM ch_posX as ubyte = 2*8
DIM ch_speed as ubyte = 1

CONST attr as ubyte = BLACK + WHITE * 8
CONST attrBlank as ubyte = WHITE + WHITE * 8
'CONST attr as ubyte = WHITE + BLACK * 8

const scrH as ubyte = (SCREEN_HEIGHT - 2) * 8
const scrW as ubyte = (SCREEN_WIDTH - 1) * 8

DIM field(SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1) as ubyte

DIM moveX as byte = 0
DIM moveY as byte = 0

DIM key as string

DIM hasKey as BOOLEAN = FALSE

DIM gold as ubyte = 0
DIM energy as byte = 100
DIM moveCount as ubyte = 0
DIM bookCount as ubyte = 0

SUB Init()
    DIM x as ubyte
    DIM y as ubyte
    FOR y = 0 TO SCREEN_HEIGHT - 1
        FOR x = 0 TO SCREEN_WIDTH - 1
            field(x,y) = 0
        NEXT x
    NEXT y
    PlaceItems(3, 15) 'Spiderwebs
    PlaceItems(4, 5) 'Chests
    PlaceItems(5, 5) 'Diamonds
    PlaceItems(6, 3) 'Books
    PlaceItems(1, 1) 'Door
    PlaceItems(2, 1) 'Key

    DrawField()
END SUB

SUB PlaceItems(itemType as ubyte, itemCount as ubyte)
    DIM rx as ubyte
    DIM ry as ubyte
    DIM placed as ubyte = 0

    DO
        rx = INT(RND * (SCREEN_WIDTH ) )
        ry = INT(RND * (SCREEN_HEIGHT - 2)) + 1    

        if rx >= 15 AND rx <= 17 AND ry >= 11 AND ry <= 13 THEN CONTINUE DO 'don't place items in the starting area

        IF field(rx, ry) = 0 THEN
            field(rx, ry) = itemType
            placed = placed + 1
            'PrintAt(0, 0, str(itemType) + " " + str(rx) + ":" + str(ry) + " " + str(placed) + "        ", ALIGN_LEFT, -1, -1)
            'DrawItem(rx, ry)
            'Wait(20)
        END IF
    LOOP UNTIL placed = itemCount
END SUB

SUB OpenCell(x as ubyte, y as ubyte)
    if (y > SCREEN_HEIGHT - 2) THEN RETURN
    if (x > SCREEN_WIDTH - 1) THEN RETURN
    if (y < 1) THEN RETURN
    if (x < 0) THEN RETURN
    if (field(x,y) >= 10) THEN RETURN

    field(x,y) = field(x,y) + 10 'mark as opened
    if field(x,y) = 10 THEN print at y,x; paper WHITE; ink BLACK; " "

END SUB


FUNCTION DrawKey(x as ubyte, y as ubyte) as BOOLEAN
    if field(x,y) <> 12 THEN RETURN FALSE
    
    if hasKey THEN RETURN TRUE

    print at y,x; paper WHITE; ink GREEN; CHR(CHR_KEY)
    RETURN TRUE

END FUNCTION

FUNCTION DrawDoor(x as ubyte, y as ubyte) as BOOLEAN
    if field(x,y) <> 11 THEN RETURN FALSE

    dim c as ubyte = RED
    if hasKey THEN c = GREEN        

    print at y,x; paper WHITE; ink c; CHR(CHR_DOOR)

    RETURN TRUE

END FUNCTION

FUNCTION DrawSpiderweb(x as ubyte, y as ubyte) as BOOLEAN
    if field(x,y) = 13 THEN
        print at y,x; paper WHITE; ink CYAN; CHR(CHR_SPIDERWEB)
        RETURN TRUE
    END IF
    RETURN FALSE
END FUNCTION


FUNCTION DrawChest(x as ubyte, y as ubyte) as BOOLEAN
    if field(x,y) = 14 THEN
        print at y,x; paper WHITE; ink YELLOW; CHR(CHR_CHEST_CLOSED)
        RETURN TRUE
    END IF
    if field(x,y) = 24 THEN
        print at y,x; paper WHITE; ink BLACK; CHR(CHR_CHEST_OPENED)
        RETURN TRUE
    END IF
    RETURN FALSE
END FUNCTION

FUNCTION DrawDiamond(x as ubyte, y as ubyte) as BOOLEAN
    if field(x,y) = 15 THEN
        print at y,x; paper WHITE; ink PINK; CHR(CHR_DIAMOND)
        RETURN TRUE
    END IF
    RETURN FALSE
END FUNCTION

FUNCTION DrawBook(x as ubyte, y as ubyte) as BOOLEAN
    if field(x,y) = 16 THEN
        print at y,x; paper WHITE; ink BLUE; CHR(CHR_BOOK)
        RETURN TRUE
    END IF
    RETURN FALSE
END FUNCTION


SUB DrawField()
    DIM x as ubyte
    DIM y as ubyte
    FOR y = 0 TO SCREEN_HEIGHT - 1
        FOR x = 0 TO SCREEN_WIDTH - 1
            DrawItem(x,y)
        NEXT x
    NEXT y
END SUB


SUB DrawItem(x as ubyte, y as ubyte)
    if (y < 1) THEN RETURN
    if (y >= SCREEN_HEIGHT - 1) THEN RETURN
    if (x < 0) THEN RETURN
    if (x > SCREEN_WIDTH - 1) THEN RETURN
    
    if field(x,y) = 0 THEN RETURN

    if DrawDoor(x,y) THEN RETURN
    if DrawKey(x,y) THEN RETURN
    if DrawSpiderweb(x,y) THEN RETURN
    if DrawChest(x,y) THEN RETURN
    if DrawDiamond(x,y) THEN RETURN
    if DrawBook(x,y) THEN RETURN
END SUB

FUNCTION CheckKey(dir as string) as BOOLEAN
    if dir = "w" AND (key = "w" OR key = "W" OR key = "7") THEN RETURN TRUE
    if dir = "s" AND (key = "s" OR key = "S" OR key = "6") THEN RETURN TRUE
    if dir = "a" AND (key = "a" OR key = "A" OR key = "5") THEN RETURN TRUE
    if dir = "d" AND (key = "d" OR key = "D" OR key = "8") THEN RETURN TRUE
    RETURN FALSE
END FUNCTION

SUB ExecuteCell(x as ubyte, y as ubyte)

    if field(x,y) = 0 THEN RETURN
    DIM xx as ubyte
    DIM yy as ubyte

    if field(x,y) = 16 THEN
        DrawItem(x,y)
        bookCount = bookCount + 1
        energy = energy + 10
        field(x,y) = 26 'mark as taken
        DrawHint("You found a magic book! Energy +10.")

        FOR yy = 0 TO SCREEN_HEIGHT - 1
            FOR xx = 0 TO SCREEN_WIDTH - 1
                if bookCount = 3 AND field(xx,yy) = 3 THEN field(xx,yy) = 13: DrawItem(xx,yy)
                if bookCount = 1 AND field(xx,yy) = 4 THEN field(xx,yy) = 14: DrawItem(xx,yy)
                if bookCount = 2 AND field(xx,yy) = 5 THEN field(xx,yy) = 15: DrawItem(xx,yy)
            NEXT xx
        NEXT yy

        Wait(50)
        DrawItem(x,y)
        return
    END IF

    if field(x,y) = 15 THEN
        DrawItem(x,y)
        gold = gold + 20
        energy = energy + 5
        field(x,y) = 25 'mark as taken
        DrawHint("You found a diamond! Gold +20, Energy +5.")
        Wait(50)
        DrawItem(x,y)
        return
    END IF

    if field(x,y) = 13 THEN
        DrawItem(x,y)
        energy = energy - 10
        field(x,y) = 23 'mark as taken
        DrawHint("You got caught in a spiderweb! Energy -10.")
        Wait(70)
        DrawItem(x,y)
        return
    END IF

    if field(x,y) = 14 THEN
        DrawItem(x,y)
        gold = gold + 10
        energy = energy - 1
        field(x,y) = 24 'mark as opened
        DrawHint("You opened a chest and found 10 gold!")
        Wait(50)
        DrawItem(x,y)
        return
    END IF

    if field(x,y) = 24 THEN
        DrawHint("Chest is empty.")
        return
    END IF

    if field(x,y) = 11 THEN
        if hasKey THEN
            DrawHint("You used the key to open the door!")
            GOTO VICTORY_SCREEN
        else
            DrawHint("The door is locked. Find the key!")
        END IF
        return
    END IF

    if field(x,y) = 12 THEN
        DrawItem(x,y)
        field(x,y) = 22 'mark as taken
        hasKey = TRUE
        DrawHint("You found the key! Now find the door!")
        for xx = 0 to SCREEN_WIDTH - 1
            for yy = 0 to SCREEN_HEIGHT - 1
                if field(xx,yy) = 11 THEN DrawDoor(xx,yy)
            next yy
        next xx
        Wait(50)
        DrawItem(x,y)
    END IF
END SUB

SUB DrawHint(hint as string)
    PrintAt(SCREEN_HEIGHT - 1 , 0, LINE_EMPTY)
    PrintAt(SCREEN_HEIGHT - 1 , 0, hint,0,-1, YELLOW)
END SUB

SUB DrawUI()
    PrintAt(0, 0, "Gold: " + str(gold) + "  ", ALIGN_LEFT)
    DIM e as string = str(energy)
    while LEN(e) < 3
        e = " " + e
    END WHILE
    PrintAt(0, SCREEN_WIDTH42 - 1, "  Energy: " + e + " ", ALIGN_RIGHT)
END SUB

'================== ==============='
'== PROGRAM START                =='
'================== ==============='

paper BLACK: ink WHITE: border BLACK: cls

dzx0Standard(@title_screen_data, 16384)

PAUSE 60
ClearEnter() 
PrintAt(20, 17, "1. START",ALIGN_LEFT, BLACK, PINK)
PrintAt(21, 17, "2. EXIT",ALIGN_LEFT, BLACK, PINK)
DO
    key = INKEY$
    if key = "2" THEN GOTO END_PROGRAMM
LOOP UNTIL key = "1"
ClearEnter()

randomize

POKE UINTEGER 23675, @Items

DIM oldX as ubyte
DIM oldY as ubyte
DIM cellX as ubyte
DIM cellY as ubyte
DIM oldCellX as ubyte 
DIM oldCellY as ubyte 

PROGRAM:
    paper BLACK: ink WHITE: border BLACK: cls

    Init()

    energy = 100
    gold = 0
    ch_posX = 16*8
    ch_posY = 12*8

    hasKey = FALSE

    oldX = ch_posX
    oldY = ch_posY
    cellX = (ch_posX + 4) / 8
    cellY = (ch_posY + 4) / 8
    oldCellX = cellX
    oldCellY = cellY
    moveX = 0
    moveY = 0
    moveCount = 0
    bookCount = 0

    for i = 0 to 2
        for j = 0 to 2
            OpenCell(cellX + i - 1, cellY + j - 1)
            DrawItem(cellX + i - 1, cellY + j - 1)
        next j
    next i

    HRPrint(ch_posX, ch_posY, @Character, attr , 0)   
    DrawUI()

    DO

        key = INKEY$
        if key = " " THEN GOTO END_PROGRAMM

        ' =====================================
        ' IF NOT MOVING, CHECK FOR INPUT TO START MOVING
        ' =====================================
        IF moveX = 0 AND moveY = 0 THEN

            ' atļauj sākt iet tikai tad, ja čars ir uz grida
            IF (ch_posX MOD 8) = 0 AND (ch_posY MOD 8) = 0 THEN

                IF CheckKey("w") AND ch_posY > 8 THEN moveX = 0: moveY = -1
                IF CheckKey("s") AND ch_posY <= scrH - 8 THEN moveX = 0: moveY = 1
                IF CheckKey("a") AND ch_posX >= 8 THEN moveX = -1: moveY = 0
                IF CheckKey("d") AND ch_posX <= scrW - 8 THEN moveX = 1: moveY = 0

            END IF
        END IF

        ' =====================================
        ' IF MOVING, CONTINUE MOVEMENT UNTIL REACHING THE NEXT GRID CELL
        ' =====================================
        IF moveX <> 0 OR moveY <> 0 THEN

            oldX = ch_posX
            oldY = ch_posY
            ch_posX = ch_posX + moveX * ch_speed
            ch_posY = ch_posY + moveY * ch_speed

            ' kad sasniegts nākamais grid punkts, apstājās
            IF (ch_posX MOD 8) = 0 AND (ch_posY MOD 8) = 0 THEN moveX = 0: moveY = 0
        END IF

        Wait(2)        

        if oldX = ch_posX AND oldY = ch_posY THEN CONTINUE DO


        HRPrint(oldX, oldY, 32, attrBlank ,  0)
        HRPrint(ch_posX, ch_posY, @Character, attr ,  0)

        cellX = (ch_posX + 4) / 8
        cellY = (ch_posY + 4) / 8

        OpenCell(cellX, cellY)
        'open adjacent cells X
        if moveX <> 0 THEN
            OpenCell(cellX, cellY + 1)
            OpenCell(cellX, cellY - 1)
        END IF

        'open adjacent cells Y
        if moveY <> 0 THEN
            OpenCell(cellX + 1, cellY)
            OpenCell(cellX - 1, cellY)
        END IF

        if cellX <> oldCellX OR cellY <> oldCellY THEN 
            PrintAt(SCREEN_HEIGHT - 1 , 0, LINE_EMPTY)
            moveCount = moveCount + 1
            if moveCount MOD 5 = 0 THEN energy = energy - 1
    
            ExecuteCell(cellX, cellY)           
        end if


        if energy <= 0 then goto LOSE_SCREEN

        for i = 0 to 2
            for j = 0 to 2
                DrawItem(cellX + i - 1, cellY + j - 1)
            next j
        next i

        oldX = ch_posX
        oldY = ch_posY

        oldCellX = cellX
        oldCellY = cellY

        DrawUI()

    LOOP UNTIL FALSE

title_screen_data: 
ASM
    INCBIN "zxTitleScr.scr.zx0"
END ASM
lose_screen_data: 
ASM
    INCBIN "zxLose.scr.zx0"
END ASM
victory_screen_data:
ASM
    INCBIN "zxVictory.scr.zx0"
END ASM

Character:
    ASM
        DB 0,24,60,24,60,90,36,36   ;Character
        ;#include "Graph.asm"
    END ASM
Items:
    ASM
        DB 24,60,110,74,90,90,74,126    ;0 Door
        DB 16,112,80,248,12,6,28,8      ;1 Key
        DB 160,68,34,86,8,149,98,4      ;2 Spiderweb
        DB 0,0,60,90,102,90,66,126      ;3 Chest closed
        DB 0,60,90,66,126,66,66,126     ;4 Chest opened
        DB 0,66,36,192,227,119,54,124   ;5 Diamond
        DB 48,86,137,233,143,185,203,60 ;6 Book
    END ASM

LOSE_SCREEN:
    Wait(70)
    dzx0Standard(@lose_screen_data, 16384)
    PAUSE 60
    ClearEnter() 
    PrintAt(20, 17, "1. RESTART",ALIGN_LEFT, BLACK, PINK)
    PrintAt(21, 17, "2. EXIT",ALIGN_LEFT, BLACK, PINK)
    DO
        key = INKEY$
        if key = "2" THEN GOTO END_PROGRAMM
    LOOP UNTIL key = "1"
    ClearEnter() 
    GOTO PROGRAM

VICTORY_SCREEN:
    Wait(70)
    dzx0Standard(@victory_screen_data, 16384)
    PAUSE 60
    ClearEnter()
    PrintAt(20, 17, "1. RESTART",ALIGN_LEFT, BLACK, PINK)
    PrintAt(21, 17, "2. EXIT",ALIGN_LEFT, BLACK,PINK)
    DO
        key = INKEY$
        if key = "2" THEN GOTO END_PROGRAMM
    LOOP UNTIL key = "1"
    ClearEnter()
    GOTO PROGRAM

END_PROGRAMM:       
    paper WHITE: ink BLACK: border WHITE: cls
    STOP
