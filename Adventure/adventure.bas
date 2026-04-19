#include "../helper.bas"
#include "../hrprint.bas"
#include "../sounds.bas"
#include "zx0.bas"
#include "data.bas"

CONST CHR_DOOR as ubyte = 144
CONST CHR_KEY as ubyte = 145
CONST CHR_SPIDERWEB as ubyte = 146
CONST CHR_CHEST_CLOSED as ubyte = 147
CONST CHR_CHEST_OPENED as ubyte = 148
CONST CHR_DIAMOND as ubyte = 149
CONST CHR_BOOK as ubyte = 150

CONST KEY0 as ubyte = 48
CONST KEY1 as ubyte = 49
CONST KEY2 as ubyte = 50
CONST KEY3 as ubyte = 51
CONST KEY4 as ubyte = 52
CONST KEY5 as ubyte = 53
CONST KEY6 as ubyte = 54
CONST KEY7 as ubyte = 55
CONST KEY8 as ubyte = 56
CONST KEY9 as ubyte = 57

CONST KEYW as ubyte = 119
CONST KEYS as ubyte = 115 bOR 83
CONST KEYA as ubyte = 97 bOR 65
CONST KEYD as ubyte = 100 bOR 68
'119 = w, 115 = s, 97 = a, 100 = d'
'87 = W, 83 = S, 65 = A, 68 = D'

CONST DIR_UP as ubyte = 0
CONST DIR_DOWN as ubyte = 1
CONST DIR_LEFT as ubyte = 2
CONST DIR_RIGHT as ubyte = 3


CONST ttAttr as ubyte = CYAN + BLACK * 8' + 128
CONST attr as ubyte = BLACK + WHITE * 8' + 128
CONST attBlank as ubyte = WHITE + WHITE * 8
CONST attMenu as ubyte = PINK + BLACK * 8
CONST attDef as ubyte = WHITE + BLACK * 8
CONST attBlack as ubyte = BLACK + BLACK * 8

const scrH as ubyte = (SCREEN_HEIGHT - 2) * 8
const scrW as ubyte = (SCREEN_WIDTH - 1) * 8

DIM field(SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1) as ubyte

DIM ch_posY as ubyte = 2*8
DIM ch_posX as ubyte = 2*8
DIM ch_speed as ubyte = 1
DIM oldX as ubyte
DIM oldY as ubyte
DIM cellX as ubyte
DIM cellY as ubyte
DIM moveX as byte = 0
DIM moveY as byte = 0

'DIM key as string
DIM keyb as ubyte = 0
DIM joy as ubyte = 0

DIM hasKey as BOOLEAN = FALSE

DIM GOLD as uinteger = 500
DIM gold as ubyte = 0
DIM energy as byte = 100


DIM moveCount as ubyte = 0

DIM books(2) as ubyte = {1,2,3}
DIM bookCount as ubyte = 0

DIM inventory as ubyte = 0

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

    ShuffleBooks()
    'DrawField()
END SUB

SUB PlaceItems(itemType as ubyte, itemCount as ubyte)
    DIM rx as ubyte
    DIM ry as ubyte
    DIM placed as ubyte = 0

    DO
        rx = INT(RND * (SCREEN_WIDTH ) )
        ry = INT(RND * (SCREEN_HEIGHT - 3)) + 2    

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

SUB ShuffleBooks()
    DIM i as ubyte
    DIM j as ubyte
    DIM tmp as ubyte

    FOR i = 0 TO 2
        j = INT(RND * 3)
        
        tmp = books(i)
        books(i) = books(j)
        books(j) = tmp
    NEXT i

    bookCount = 0
END SUB

SUB OpenCell(x as byte, y as byte, f as byte = 0)

    if (y < 2) THEN RETURN
    if (y > SCREEN_HEIGHT - 2) THEN RETURN

    if (x < 0) THEN RETURN
    if (x > SCREEN_WIDTH - 1) THEN RETURN

    if (field(x,y) >= 10) THEN RETURN

    field(x,y) = field(x,y) + 10 'mark as opened
    if field(x,y) = 10 and f = 0 THEN print at y,x; paper WHITE; ink BLACK; " "

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

SUB DrawItem(x as byte, y as byte)
    if (y < 2) THEN RETURN
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

SUB UseBook(bookType as ubyte)
    DIM xx as ubyte
    DIM yy as ubyte
    
    DIM book as string = "unknown"

    FOR yy = 0 TO SCREEN_HEIGHT - 1
        FOR xx = 0 TO SCREEN_WIDTH - 1
            if bookType = 1 AND field(xx,yy) = 4 THEN field(xx,yy) = 14: DrawItem(xx,yy): book = "chest"
            if bookType = 2 AND field(xx,yy) = 5 THEN field(xx,yy) = 15: DrawItem(xx,yy): book = "diamond"
            if bookType = 3 AND field(xx,yy) = 3 THEN field(xx,yy) = 13: DrawItem(xx,yy): book = "spiderwebs"
        NEXT xx
    NEXT yy
    DrawHint("Magic book! Open all " + book + "! +10 energy.")

END SUB

FUNCTION ExecuteCell(x as ubyte, y as ubyte) as BOOLEAN

    if field(x,y) = 0 THEN RETURN FALSE
    DIM xx as ubyte
    DIM yy as ubyte

    if field(x,y) = 16 THEN 'magic book'
        DrawItem(x,y)
        bookCount = bookCount + 1
        energy = energy + 10
        field(x,y) = 26 'mark as taken

        UseBook(books(bookCount-1))

        'DIM bookType as string = "unknown"
        'FOR yy = 0 TO SCREEN_HEIGHT - 1
        ''    FOR xx = 0 TO SCREEN_WIDTH - 1
        ''        if books(bookCount-1) = 3 AND field(xx,yy) = 3 THEN field(xx,yy) = 13: DrawItem(xx,yy): bookType = "spiderwebs"
        ''        if books(bookCount-1) = 1 AND field(xx,yy) = 4 THEN field(xx,yy) = 14: DrawItem(xx,yy): bookType = "chest"
        ''        if books(bookCount-1) = 2 AND field(xx,yy) = 5 THEN field(xx,yy) = 15: DrawItem(xx,yy): bookType = "diamond"
        ''    NEXT xx
        'NEXT yy
        'DrawHint("Magic book! Open all " + bookType + "! +10 energy.")

        PlaySound(@SoundChest)
        Wait(50)

        DrawItem(x,y)
        return TRUE
    END IF

    if field(x,y) = 15 THEN 'diamond'
        DrawItem(x,y)
        gold = gold + 20
        energy = energy + 5
        field(x,y) = 25 'mark as taken
        DrawHint("You found a diamond! Gold +20, Energy +5.")

        PlaySound(@SoundChest)
        Wait(50)

        DrawItem(x,y)
        return TRUE
    END IF

    if field(x,y) = 13 THEN 'spiderweb'
        DrawItem(x,y)
        energy = energy - 10
        field(x,y) = 23 'mark as taken
        DrawHint("You got caught in a spiderweb! Energy -10.")

        PlaySound(@SoundSpiderWeb)
        Wait(70)

        DrawItem(x,y)
        return TRUE
    END IF

    if field(x,y) = 14 THEN 'chest'
        DrawItem(x,y)
        gold = gold + 10
        energy = energy - 1
        field(x,y) = 24 'mark as opened
        DrawHint("You opened a chest and found 10 gold!")

        PlaySound(@SoundChest)
        Wait(50)

        DrawItem(x,y)
        return TRUE
    END IF

    if field(x,y) = 24 THEN 'opened chest, nothing inside'
        DrawHint("Chest is empty.")
        return FALSE
    END IF

    if field(x,y) = 11 THEN 'door'
        if hasKey THEN
            DrawHint("You used the key to open the door!")
            GOTO VICTORY_SCREEN
        else
            DrawHint("The door is locked. Find the key!")
        END IF
        return TRUE
    END IF

    if field(x,y) = 12 THEN 'key'
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
        return TRUE
    END IF

    return FALSE
END FUNCTION

SUB DrawArea(x as ubyte, y as ubyte)
    DIM i as ubyte
    DIM j as ubyte
    for i = 0 to 2
        for j = 0 to 2
            DrawItem(x + i - 1, y + j - 1)
        next j
    next i
END SUB

SUB TypeWriteAt()
    DIM tt as string
    DIM i as ubyte
    FOR i = 0 TO 5
        READ tt
        TypeWrite(5 + i, 5, tt, 3, ttAttr)
    NEXT i
END SUB

SUB DrawHint(hint as string)
    'PrintAt(SCREEN_HEIGHT - 1 , 0, LINE_EMPTY42)
    'print at SCREEN_HEIGHT - 1,0; paper BLACK; ink WHITE; LINE_EMPTY
    'ClearLine(SCREEN_HEIGHT - 1)
    ClearAttrLine(SCREEN_HEIGHT - 1,attBlack)
    PrintAt(SCREEN_HEIGHT - 1 , 0, hint,0,-1, YELLOW)
END SUB

SUB DrawUI()
    PrintAt(0, 0, "Gold: " + str(gold) + "  ", ALIGN_LEFT, BLACK, YELLOW)
    DIM e as string = str(energy)
    while LEN(e) < 3
        e = " " + e
    END WHILE
    PrintAt(0, SCREEN_WIDTH42 - 1, "  Energy: " + e + " ", ALIGN_RIGHT, BLACK, CYAN)
    
    DIM itemStr as string = "(empty)"
    if inventory = 1 THEN itemStr = "BoC (1. use)"
    if inventory = 2 THEN itemStr = "BoD (1. use)"
    if inventory = 3 THEN itemStr = "BoS (1. use)"
    if hasKey THEN itemStr = "  KEY"

    'while LEN(itemStr) < 20
    ''    itemStr = itemStr + " "
    'END WHILE


    'ClearLine(1)
    ClearAttrLine(1,attBlack)
    PrintAt(1, 0, "Inventory: " + itemStr, ALIGN_LEFT, BLACK, WHITE)
END SUB

FUNCTION CheckKey(dir as ubyte) as BOOLEAN
    if dir = DIR_UP AND ((keyb bOR 32) = KEYW OR joy = 16) THEN RETURN TRUE
    if dir = DIR_DOWN AND ((keyb bOR 32) = KEYS OR joy = 4) THEN RETURN TRUE
    if dir = DIR_LEFT AND ((keyb bOR 32) = KEYA OR joy = 1) THEN RETURN TRUE
    if dir = DIR_RIGHT AND ((keyb bOR 32) = KEYD OR joy = 2) THEN RETURN TRUE
    RETURN FALSE
END FUNCTION


'================== ==============='
'== PROGRAM START                =='
'================== ==============='

paper BLACK: ink WHITE: border BLACK: cls
POKE UINTEGER 23675, @Items

dzx0Standard(@title_screen_data, 16384)

PAUSE 50
PrintAttr(20, 17, "1. START",ALIGN_LEFT, attMenu)
PrintAttr(21, 17, "0. EXIT",ALIGN_LEFT, attMenu)
ClearEnter() 
DO
    keyb = CODE INKEY$
    if keyb = KEY0 THEN GOTO END_PROGRAMM
LOOP UNTIL keyb = KEY1
ClearEnter()

randomize

GOTO INTRO_SCREEN

PROGRAM:
    paper BLACK: ink WHITE: border BLACK: cls

    Init()

    'energy = 100
    gold = 0
    cellX = 16
    cellY = 12
    ch_posX = cellX * 8
    ch_posY = cellY * 8
    oldX = ch_posX
    oldY = ch_posY
    moveX = 0
    moveY = 0

    hasKey = FALSE
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

        keyb = CODE INKEY$
        if keyb = KEY1 and inventory > 0 THEN
            UseBook(inventory)
            inventory = 0
            DrawUI()
            Wait(70)
            CONTINUE DO
        END IF

        joy = in 31
        if keyb = KEY0 THEN GOTO END_PROGRAMM

        ' =====================================
        ' IF NOT MOVING, CHECK FOR INPUT TO START MOVING
        ' =====================================
        IF moveX = 0 AND moveY = 0 THEN
            'new movement can be started only when character is aligned to grid

            IF CheckKey(DIR_UP) AND ch_posY > 16 THEN moveX = 0: moveY = -1
            IF CheckKey(DIR_DOWN) AND ch_posY <= scrH - 8 THEN moveX = 0: moveY = 1
            IF CheckKey(DIR_LEFT) AND ch_posX >= 8 THEN moveX = -1: moveY = 0
            IF CheckKey(DIR_RIGHT) AND ch_posX <= scrW - 8 THEN moveX = 1: moveY = 0

        END IF
        Wait(2)

        if moveX = 0 AND moveY = 0 THEN CONTINUE DO 'no movement, continue waiting for input

        ' =====================================
        ' IF MOVING, CONTINUE MOVEMENT UNTIL REACHING THE NEXT GRID CELL
        ' =====================================
        oldX = ch_posX
        oldY = ch_posY
        ch_posX = ch_posX + moveX * ch_speed
        ch_posY = ch_posY + moveY * ch_speed

        'Check grid alignment
        IF (ch_posX MOD 8) = 0 AND (ch_posY MOD 8) = 0 THEN 
            cellX = (ch_posX + 4) / 8
            cellY = (ch_posY + 4) / 8

            OpenCell(cellX, cellY, 1)
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

            'ClearLine(SCREEN_HEIGHT - 1)
            ClearAttrLine(SCREEN_HEIGHT - 1,attBlack)
            'PrintAt(SCREEN_HEIGHT - 1 , 0, LINE_EMPTY42)

            if ExecuteCell(cellX, cellY) <> TRUE THEN
                PlaySound(@SoundStep)
            END IF

            moveCount = moveCount + 1
            if moveCount MOD 5 = 0 THEN energy = energy - 1

            if energy <= 0 then goto LOSE_SCREEN
    
            DrawUI()               

            moveX = 0: moveY = 0
        END IF

        HRPrint(oldX, oldY, 32, attBlank ,  0)
        HRPrint(ch_posX, ch_posY, @Character, attr ,  0)

        DrawArea((ch_posX + 4) / 8, (ch_posY + 4) / 8)

    LOOP UNTIL FALSE

LOSE_SCREEN:
    Wait(70)
    dzx0Standard(@lose_screen_data, 16384)
    PAUSE 60

    PrintAttr(20, 16, "  YOU LOSE  ",ALIGN_LEFT, attMenu)
    PrintAttr(21, 16, " 1. HOME ",ALIGN_LEFT, attMenu)
    PrintAttr(22, 16, " 0. EXIT    ",ALIGN_LEFT, attMenu)

    ClearEnter()
    DO
        keyb = CODE INKEY$
        if (keyb = KEY1) THEN GOTO HOME_SCREEN
        if (keyb = KEY0) THEN GOTO END_PROGRAMM
    LOOP UNTIL FALSE

VICTORY_SCREEN:
    GOLD = GOLD + gold
    Wait(70)
    dzx0Standard(@victory_screen_data, 16384)
    PAUSE 60
    PrintAttr(21, 17, "1. HOME",ALIGN_LEFT, attMenu)
    PrintAttr(22, 17, "0. EXIT",ALIGN_LEFT, attMenu)

    ClearEnter()
    DO
        keyb = CODE INKEY$
        if (keyb = KEY1) <> 0 THEN GOTO HOME_SCREEN
        if (keyb = KEY0) <> 0 THEN GOTO END_PROGRAMM
    LOOP UNTIL FALSE
    

HOME_SCREEN:
    dzx0Standard(@inside_screen_data, 16384)
    DrawUI()

    PrintAttr(4, 18, "1. ADVENTURE",ALIGN_LEFT, attDef)
    PrintAttr(19, 3, " 2. REST",ALIGN_LEFT, attDef)
    PrintAttr(7, 33,"3. SHOP",ALIGN_LEFT, attDef)

    ClearEnter()
    DO
        keyb = CODE INKEY$
        if (keyb = 49) THEN GOTO PROGRAM
        if (keyb = 50) THEN GOTO REST_SCREEN
        if (keyb = 51) THEN GOTO SHOP_SCREEN
        if (keyb = 48) THEN GOTO END_PROGRAMM
        
    LOOP UNTIL FALSE 

REST_SCREEN:
    energy = 100
    paper BLACK: ink WHITE: border BLACK: cls

    restore rest_text
    TypeWriteAt()

    PrintAttr(20, 17, "1. CONTINUE",ALIGN_LEFT, attMenu)

    ClearEnter() 
    DO
        keyb = CODE INKEY$
        if (keyb = KEY1) THEN GOTO HOME_SCREEN
        if (keyb = KEY0) THEN GOTO END_PROGRAMM
    LOOP UNTIL FALSE

SUB SellItem()
    if inventory = 0 THEN 
        DrawHint("You have nothing to sell.")
        RETURN
    END IF

    if inventory = 1 THEN 'Book of chests
        GOLD = GOLD + 20
        inventory = 0
        DrawHint("You sold the Book of Chests!")
    END IF

    if inventory = 2 THEN 'Book of diamonds
        GOLD = GOLD + 20
        inventory = 0
        DrawHint("You sold the Book of Diamonds!")
    END IF

    if inventory = 3 THEN 'Book of spiders
        GOLD = GOLD + 50
        inventory = 0
        DrawHint("You sold the Book of Spiders!")
    END IF

END SUB

SUB BuyItem(item as ubyte)
    if inventory <> 0 THEN 
        DrawHint("You can only carry one item.")
        RETURN
    END IF

    if item = KEY2 AND GOLD >= 20 AND inventory = 0 THEN 'Book of chests
        GOLD = GOLD - 20
        inventory = 1
        DrawHint("You bought the Book of Chests!")
    END IF

    if item = KEY3 AND GOLD >= 20 AND inventory = 0 THEN 'Book of diamonds
        GOLD = GOLD - 20
        inventory = 2
        DrawHint("You bought the Book of Diamonds!")
    END IF

    if item = KEY4 AND GOLD >= 50 AND inventory = 0 THEN 'Book of spiders
        GOLD = GOLD - 50
        inventory = 3
        DrawHint("You bought the Book of Spiders!")
    END IF

END SUB

SHOP_SCREEN:
    paper BLACK: ink WHITE: border BLACK: cls
    SHOP_REDRAW:
    PrintAttr(2, 5, "Welcome to the shop!",ALIGN_LEFT, attDef)
    PrintAt(3, 5, "Your gold: " + str(GOLD),ALIGN_LEFT, BLACK, YELLOW)

    PrintAttr(5, 5, "2. Book of chests (BoC)",ALIGN_LEFT, ttAttr)
    PrintAttr(5, 32, "20g",ALIGN_LEFT, ttAttr)

    PrintAttr(6, 5, "3. Book of diamonds (BoD)",ALIGN_LEFT, ttAttr)
    PrintAttr(6, 32, "20g",ALIGN_LEFT, ttAttr)

    PrintAttr(7, 5, "4. Book of spiders (BoS)",ALIGN_LEFT, ttAttr)
    PrintAttr(7, 32, "50g",ALIGN_LEFT, ttAttr)

    PrintAttr(10, 5, "Inventory:",ALIGN_LEFT, ttAttr)
    if inventory = 0 THEN PrintAttr(10, 17, "(empty)",ALIGN_LEFT,ttAttr)

    if inventory = 1 THEN PrintAttr(10, 17, "BoC    ",ALIGN_LEFT,ttAttr)
    if inventory = 2 THEN PrintAttr(10, 17, "BoD    ",ALIGN_LEFT,ttAttr)
    if inventory = 3 THEN PrintAttr(10, 17, "BoS    ",ALIGN_LEFT,ttAttr)

    if inventory <> 0 THEN PrintAttr(12, 5, "9. sell",ALIGN_LEFT, ttAttr) else PrintAttr(12, 5, "           ",ALIGN_LEFT)

    PrintAttr(20, 17, "1. CONTINUE",ALIGN_LEFT, attMenu)
    ClearEnter() 
    DO
        keyb = CODE INKEY$
        if (keyb = KEY1) THEN GOTO HOME_SCREEN
        if (keyb = KEY0) THEN GOTO END_PROGRAMM
        if (keyb >= KEY2 AND keyb <= KEY4) THEN BuyItem(keyb):GOTO SHOP_REDRAW
        if (keyb = KEY9) THEN SellItem():GOTO SHOP_REDRAW
    LOOP UNTIL FALSE


INTRO_SCREEN:
    paper BLACK: ink WHITE: border BLACK: cls

    RESTORE intro_text
    TypeWriteAt()    

    PrintAttr(20, 17, "1. CONTINUE",ALIGN_LEFT, attMenu)

    ClearEnter() 
    DO
        keyb = CODE INKEY$
        if (keyb = KEY1) THEN GOTO HOME_SCREEN
        if (keyb = KEY0) THEN GOTO END_PROGRAMM
    LOOP UNTIL FALSE

END_PROGRAMM:       
    paper WHITE: ink BLACK: border WHITE: cls
    STOP


title_screen_data: 
ASM
    INCBIN "zxTitleScr.scr.zx0"
    db 0,0,0,0
END ASM
lose_screen_data: 
ASM
    INCBIN "zxLose.scr.zx0"
    db 0,0,0,0
END ASM
victory_screen_data:
ASM
    INCBIN "zxVictory.scr.zx0"
    db 0,0,0,0
END ASM
inside_screen_data:
ASM
    INCBIN "zxInside.scr.zx0"
    db 0,0,0,0
END ASM
