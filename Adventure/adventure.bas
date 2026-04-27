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
CONST CHR_GEM as ubyte = 151

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
CONST attGold as ubyte = YELLOW + BLACK * 8
CONST attEnergy as ubyte = CYAN + BLACK * 8
CONST attBook as ubyte = BLUE + BLACK * 8
CONST attDiamond as ubyte = RED + BLACK * 8


const scrH as ubyte = (SCREEN_HEIGHT - 2) * 8
const scrW as ubyte = (SCREEN_WIDTH - 1) * 8

DIM field(SCREEN_WIDTH - 1, SCREEN_HEIGHT - 1) as ubyte

CONST ch_speed as ubyte = 1

DIM ch_posY as ubyte = 2*8
DIM ch_posX as ubyte = 2*8
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

DIM GOLD as uinteger = 0
DIM gold as ubyte = 0
DIM energy as byte = 100


DIM moveCount as ubyte = 0

DIM books(2) as ubyte = {1,2,3}
DIM bookCount as ubyte = 0

DIM gems as ubyte = 0
DIM gemFound as BOOLEAN = FALSE

DIM chestsFound as ubyte = 0
DIM chestsTotal as ubyte = 0
DIM spidersFound as ubyte = 0
DIM spidersTotal as ubyte = 0
DIM diamondsFound as ubyte = 0
DIM diamondsTotal as ubyte = 0
DIM booksFound as ubyte = 0
DIM booksTotal as ubyte = 0

DIM inventory as ubyte = 0

SUB Init()
    DIM x as ubyte
    DIM y as ubyte
    FOR y = 0 TO SCREEN_HEIGHT - 1
        FOR x = 0 TO SCREEN_WIDTH - 1
            field(x,y) = 0
        NEXT x
    NEXT y

    spidersTotal = INT(RND * 10) + 15
    spidersFound = 0
    PlaceItems(3, spidersTotal) 'Spiderwebs

    chestsTotal = INT(RND * 5) + 5
    chestsFound = 0
    PlaceItems(4, chestsTotal) 'Chests

    diamondsTotal = INT(RND * 3) + 5
    diamondsFound = 0
    PlaceItems(5, diamondsTotal) 'Diamonds

    if gems < 3 then
        y = INT(RND * 100)
        if y > 60 then PlaceItems(7, 1)
    end if

    booksTotal = INT(RND * 4)
    booksFound = 0
    if booksTotal > 0 then PlaceItems(6, booksTotal) 'Books

    PlaceItems(1, 1) 'Door
    PlaceItems(2, 1) 'Key

    ShuffleBooks()

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
            'if itemType > 10 then DrawItem(rx,ry)
            placed = placed + 1
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

FUNCTION DrawGem(x as ubyte, y as ubyte) as BOOLEAN

    if field(x,y) = 17 THEN
        DIM c as ubyte = RED
        if gems = 0 c = RED
        if gems = 1 c = BLUE
        if gems = 2 c = CYAN
        print at y,x; paper WHITE; ink c; CHR(CHR_GEM)
        RETURN TRUE
    END IF
    RETURN FALSE
END FUNCTION

'SUB DrawField()
''    DIM x as ubyte
''    DIM y as ubyte
''    FOR y = 0 TO SCREEN_HEIGHT - 1
''        FOR x = 0 TO SCREEN_WIDTH - 1
''            DrawItem(x,y)
''        NEXT x
''    NEXT y
'END SUB

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
    if DrawGem(x,y) THEN RETURN
END SUB

SUB UseBook(bookType as ubyte)
    DIM xx as ubyte
    DIM yy as ubyte
    
    FOR yy = 0 TO SCREEN_HEIGHT - 1
        FOR xx = 0 TO SCREEN_WIDTH - 1
            if bookType = 1 AND field(xx,yy) = 4 THEN field(xx,yy) = 14: DrawItem(xx,yy) 
            if bookType = 2 AND field(xx,yy) = 5 THEN field(xx,yy) = 15: DrawItem(xx,yy)
            if bookType = 3 AND field(xx,yy) = 3 THEN field(xx,yy) = 13: DrawItem(xx,yy)
        NEXT xx
    NEXT yy

    if bookType = 1 THEN DrawHint("Magic book! Open all chests!")
    if bookType = 2 THEN DrawHint("Magic book! Open all diamonds!")
    if bookType = 3 THEN DrawHint("Magic book! Open all spiders!")

END SUB

FUNCTION ExecuteCell(x as ubyte, y as ubyte) as BOOLEAN

    if field(x,y) = 0 THEN RETURN FALSE
    DIM xx as ubyte
    DIM yy as ubyte

    if field(x,y) = 16 THEN 'magic book'
        booksFound = booksFound + 1
        DrawItem(x,y)
        bookCount = bookCount + 1
        energy = energy + 10
        field(x,y) = 26 'mark as taken

        UseBook(books(bookCount-1))

        PlaySound(@SoundChest)
        Wait(50)

        DrawItem(x,y)
        return TRUE
    END IF

    if field(x,y) = 15 THEN 'diamond'
        diamondsFound = diamondsFound + 1
        DrawItem(x,y)
        gold = gold + 20
        energy = energy + 5
        field(x,y) = 25 'mark as taken
        DrawHint("You found a diamond!")

        PlaySound(@SoundChest)
        Wait(50)

        DrawItem(x,y)
        return TRUE
    END IF

    if field(x,y) = 13 THEN 'spiderweb'
        spidersFound  = spidersFound + 1
        DrawItem(x,y)
        energy = energy - 10
        field(x,y) = 23 'mark as taken
        DrawHint("You got caught in a spiderweb!")

        PlaySound(@SoundSpiderWeb)
        Wait(70)

        DrawItem(x,y)
        return TRUE
    END IF

    if field(x,y) = 14 THEN 'chest'
        chestsFound = chestsFound + 1
        DrawItem(x,y)
        yy = INT(RND * 10)
        gold = gold + 10 + yy
        energy = energy - 1
        field(x,y) = 24 'mark as opened
        DrawHint("You opened a chest!")

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
            VICTORY_SCREEN()
        else
            DrawHint("The door is locked. Find the key!")
        END IF
        return TRUE
    END IF

    if field(x,y) = 12 THEN 'key'
        DrawItem(x,y)
        field(x,y) = 22 'mark as taken
        hasKey = TRUE
        DrawHint("You found the key!")
        for xx = 0 to SCREEN_WIDTH - 1
            for yy = 0 to SCREEN_HEIGHT - 1
                if field(xx,yy) = 11 THEN DrawDoor(xx,yy)
            next yy
        next xx
        PlaySound(@SoundChest)
        Wait(50)
        DrawItem(x,y)
        return TRUE
    END IF

    if field(x,y) = 17 then
        DrawItem(x,y)
        field(x,y) = 27 'mark as taken
        gemFound = TRUE
        gems = gems + 1
        if gems = 1 then DrawHint("You found a ruby!")
        if gems = 2 then DrawHint("You found a sapphire!")
        if gems = 3 then DrawHint("You found a amethyst")
        PlaySound(@SoundChest)
        Wait(50)
        DrawItem(x,y)
        return TRUE

    end if

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

SUB TypeWriteAt(y as ubyte,x as ubyte, til as ubyte)
    DIM tt as string
    DIM i as ubyte
    FOR i = 0 TO til - 1
        READ tt
        TypeWrite(y + i, x, tt, 2, ttAttr)
    NEXT i
END SUB

SUB DrawHint(hint as string)
    'ClearAttrLine(SCREEN_HEIGHT - 1,attBlack)
    'print at SCREEN_HEIGHT - 1, 0; paper BLACK; ink BLACK; "                               "
    PrintAt(SCREEN_HEIGHT - 1 , 0, hint, ALIGN_LEFT ,attGold)
END SUB

SUB DrawUI(isHome as BOOLEAN = FALSE)

    if isHome THEN
        PrintAt(0, 0, "Gold: " + str(GOLD) + "  ", ALIGN_LEFT, attGold)
    else
        PrintAt(0, 0, "Gold: " + str(gold) + "  ", ALIGN_LEFT, attGold)
    END IF

    DIM itemStr as string = str(energy)
    while LEN(itemStr) < 3
        itemStr = " " + itemStr
    END WHILE
    PrintAt(0, SCREEN_WIDTH42 , "  Energy: " + itemStr , ALIGN_RIGHT, attEnergy)
    
    itemStr = "(empty)              "
    if inventory = 1 THEN itemStr = "BoC"
    if inventory = 2 THEN itemStr = "BoD"
    if inventory = 3 THEN itemStr = "BoS"
    if inventory > 0 AND isHome = FALSE THEN itemStr = itemStr + "  (press 1 to use)" 
    PrintAt(1, 0, "Inventory: " + itemStr, ALIGN_LEFT, attDef)
  
    if isHome = FALSE THEN 
        if hasKey THEN 
            PrintAt(1, SCREEN_WIDTH42 , "HAS KEY", ALIGN_RIGHT, attGold)
        else
            PrintAt(1, SCREEN_WIDTH42 , " NO KEY", ALIGN_RIGHT, attDef)
        END IF
    END IF

END SUB

FUNCTION CheckKey(dir as ubyte) as BOOLEAN
    if dir = DIR_UP AND ((keyb bOR 32) = KEYW OR joy = 16 OR keyb = KEY7) THEN RETURN TRUE
    if dir = DIR_DOWN AND ((keyb bOR 32) = KEYS OR joy = 4 OR keyb = KEY6) THEN RETURN TRUE
    if dir = DIR_LEFT AND ((keyb bOR 32) = KEYA OR joy = 1 OR keyb = KEY5) THEN RETURN TRUE
    if dir = DIR_RIGHT AND ((keyb bOR 32) = KEYD OR joy = 2 OR keyb = KEY8) THEN RETURN TRUE
    RETURN FALSE
END FUNCTION


'================== ==============='
'== PROGRAM START                =='
'================== ==============='

START:
paper BLACK: ink WHITE: border BLACK: cls

dzx0Standard(@title_screen_data, 16384)

PAUSE 50
PrintAt(20, 17, "1. START",ALIGN_LEFT, attMenu)
PrintAt(21, 17, "2. HELP",ALIGN_LEFT, attMenu)
PrintAt(22, 17, "0. EXIT",ALIGN_LEFT, attMenu)

ClearEnter() 
DO
    keyb = CODE INKEY$
    if keyb = KEY0 THEN GOTO END_PROGRAMM
    if keyb = KEY2 THEN HELP_SCREEN()
LOOP UNTIL keyb = KEY1
ClearEnter()

randomize

INTRO_SCREEN()

PROGRAM:
    paper BLACK: ink WHITE: border BLACK: cls
    POKE UINTEGER 23675, @Items

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
    gemFound = FALSE

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

            print at SCREEN_HEIGHT - 1, 0; paper BLACK; ink BLACK; "                               "

            if ExecuteCell(cellX, cellY) <> TRUE THEN
                PlaySound(@SoundStep)
            END IF

            moveCount = moveCount + 1
            if moveCount MOD 5 = 0 THEN energy = energy - 1

            if energy <= 0 then LOSE_SCREEN()
    
            DrawUI()               

            moveX = 0: moveY = 0
        END IF

        HRPrint(oldX, oldY, 32, attBlank ,  0)
        HRPrint(ch_posX, ch_posY, @Character, attr ,  0)

        DrawArea((ch_posX + 4) / 8, (ch_posY + 4) / 8)

    LOOP UNTIL FALSE

SUB LOSE_SCREEN()
    if gemFound then gems = gems - 1
    Wait(70)
    dzx0Standard(@lose_screen_data, 16384)
    PAUSE 60

    PrintAt(20, 16, "  YOU LOSE  ",ALIGN_LEFT, attMenu)
    PrintAt(21, 16, " 1. HOME "   ,ALIGN_LEFT, attMenu)
    PrintAt(22, 16, " 0. EXIT    ",ALIGN_LEFT, attMenu)

    ClearEnter()
    DO
        keyb = CODE INKEY$
        if (keyb = KEY1) THEN HOME_SCREEN()
        if (keyb = KEY0) THEN GOTO END_PROGRAMM
    LOOP UNTIL FALSE
END SUB

SUB VICTORY_SCREEN()
    GOLD = GOLD + gold
    Wait(70)
    paper BLACK: ink WHITE: border BLACK: cls

    PrintAt(3,21,"YOU FOUND THE EXIT", ALIGN_CENTER, attGold)
    PrintAt(5,5,"you spend moves: " + str(moveCount), ALIGN_LEFT, attDef)
    PrintAt(6,5,"chests found: " + str(chestsFound) + "/" + str(chestsTotal), ALIGN_LEFT, attDef)
    PrintAt(7,5,"diamonds found: " + str(diamondsFound) + "/" + str(diamondsTotal), ALIGN_LEFT, attDef)
    PrintAt(8,5,"tangled in webs: " + str(spidersFound) + "/" + str(spidersTotal), ALIGN_LEFT, attDef)

    if gemFound then
        if gems = 1 then restore rubin_text: TypeWriteAt(10, 2, 5)
        if gems = 2 then restore sapphire_text: TypeWriteAt(10, 2, 5)
        if gems = 3 then restore ametist_text: TypeWriteAt(10, 2, 7)        
    end if

    PAUSE 60

    PrintAt(21, 17, "1. CONTINUE",ALIGN_LEFT, attMenu)
    PrintAt(22, 17, "0. EXIT",ALIGN_LEFT, attMenu)

    ClearEnter()
    DO
        keyb = CODE INKEY$
        if keyb = KEY1 THEN 
            if gems < 3 then HOME_SCREEN() else END_SCREEN()
        end if
        if keyb = KEY0 THEN GOTO END_PROGRAMM
    LOOP UNTIL FALSE
END SUB
    
SUB END_SCREEN()
    dzx0Standard(@victory_screen_data, 16384)
    PAUSE 60
    PrintAt(21, 17, "1. HOME",ALIGN_LEFT, attMenu)
    PrintAt(22, 17, "0. EXIT",ALIGN_LEFT, attMenu)

    ClearEnter()
    DO
        keyb = CODE INKEY$
        if keyb = KEY1 THEN HOME_SCREEN()
        if keyb = KEY0 THEN GOTO END_PROGRAMM
    LOOP UNTIL FALSE
END SUB

SUB HOME_SCREEN()
    dzx0Standard(@inside_screen_data, 16384)
    DrawUI(TRUE)
    
    POKE UINTEGER 23675, @Gems

    DIM c as ubyte = WHITE
    if gems >= 1 then c = RED
    print at 7,17; paper BLACK; ink c; CHR(144)+CHR(145)
    print at 8,17; paper BLACK; ink c; CHR(146)+CHR(147)

    c = WHITE
    if gems >= 2 then c = BLUE
    print at 10,16; paper BLACK; ink c; CHR(144)+CHR(145)
    print at 11,16; paper BLACK; ink c; CHR(146)+CHR(147)

    c = WHITE
    if gems >= 3 then c = CYAN
    print at 12,18; paper BLACK; ink c; CHR(144)+CHR(145)
    print at 13,18; paper BLACK; ink c; CHR(146)+CHR(147)

    PrintAt(4, 18, "1. ADVENTURE",ALIGN_LEFT, attDef)
    PrintAt(19, 3, "2. REST",ALIGN_LEFT, attDef)
    PrintAt(7, 33, "3. SHOP",ALIGN_LEFT, attDef)

    ClearEnter()
    DO
        keyb = CODE INKEY$
        if keyb = KEY1 THEN ClearEnter():GOTO PROGRAM
        if keyb = KEY2 THEN REST_SCREEN()
        if keyb = KEY3 THEN SHOP_SCREEN()
        if keyb = KEY0 THEN GOTO END_PROGRAMM
        
    LOOP UNTIL FALSE 
END SUB

SUB REST_SCREEN()
    energy = 100
    paper BLACK: ink WHITE: border BLACK: cls

    restore rest_text
    TypeWriteAt(5, 5, 5)

    PrintAt(20, 17, "1. CONTINUE",ALIGN_LEFT, attMenu)

    ClearEnter() 
    DO
        keyb = CODE INKEY$
        if keyb = KEY1 THEN HOME_SCREEN()
        if keyb = KEY0 THEN GOTO END_PROGRAMM
    LOOP UNTIL FALSE
END SUB

SUB SellItem()
    if inventory = 0 THEN 
        DrawHint("You have nothing to sell.")
        RETURN
    END IF

    if inventory = 1 THEN 'Book of chests
        GOLD = GOLD + 50
        inventory = 0
        DrawHint("You sold the Book of Chests!")
    END IF

    if inventory = 2 THEN 'Book of diamonds
        GOLD = GOLD + 50
        inventory = 0
        DrawHint("You sold the Book of Diamonds!")
    END IF

    if inventory = 3 THEN 'Book of spiders
        GOLD = GOLD + 100
        inventory = 0
        DrawHint("You sold the Book of Spiders!")
    END IF

END SUB

SUB BuyItem(item as ubyte)
    if inventory <> 0 THEN 
        DrawHint("You can only carry one item.")
        RETURN
    END IF

    if item = KEY2 AND GOLD >= 50 AND inventory = 0 THEN 'Book of chests
        GOLD = GOLD - 50
        inventory = 1
        DrawHint("You bought the Book of Chests!")
    END IF

    if item = KEY3 AND GOLD >= 50 AND inventory = 0 THEN 'Book of diamonds
        GOLD = GOLD - 50
        inventory = 2
        DrawHint("You bought the Book of Diamonds!")
    END IF

    if item = KEY4 AND GOLD >= 100 AND inventory = 0 THEN 'Book of spiders
        GOLD = GOLD - 100
        inventory = 3
        DrawHint("You bought the Book of Spiders!")
    END IF

END SUB

SUB SHOP_SCREEN()
    paper BLACK: ink WHITE: border BLACK: cls
    SHOP_REDRAW:
    PrintAt(2, 5, "Welcome to the shop!",ALIGN_LEFT, attDef)
    PrintAt(3, 5, "Your gold: " + str(GOLD),ALIGN_LEFT, attGold)

    PrintAt(5, 5, "2. Book of chests (BoC)",ALIGN_LEFT, ttAttr)
    PrintAt(5, 32, "50g",ALIGN_LEFT, ttAttr)

    PrintAt(6, 5, "3. Book of diamonds (BoD)",ALIGN_LEFT, ttAttr)
    PrintAt(6, 32, "50g",ALIGN_LEFT, ttAttr)

    PrintAt(7, 5, "4. Book of spiders (BoS)",ALIGN_LEFT, ttAttr)
    PrintAt(7, 32, "100g",ALIGN_LEFT, ttAttr)

    PrintAt(10, 5, "Inventory:",ALIGN_LEFT, ttAttr)

    if inventory = 0 THEN PrintAt(10, 17, "(empty)",ALIGN_LEFT,ttAttr)

    if inventory = 1 THEN PrintAt(10, 17, "BoC    ",ALIGN_LEFT,ttAttr)
    if inventory = 2 THEN PrintAt(10, 17, "BoD    ",ALIGN_LEFT,ttAttr)
    if inventory = 3 THEN PrintAt(10, 17, "BoS    ",ALIGN_LEFT,ttAttr)

    if inventory <> 0 THEN PrintAt(12, 5, "9. sell",ALIGN_LEFT, ttAttr) else PrintAt(12, 5, "           ",ALIGN_LEFT)

    PrintAt(20, 17, "1. CONTINUE",ALIGN_LEFT, attMenu)
    ClearEnter() 
    DO
        keyb = CODE INKEY$
        if (keyb = KEY1) THEN HOME_SCREEN()
        if (keyb = KEY0) THEN GOTO END_PROGRAMM
        if (keyb >= KEY2 AND keyb <= KEY4) THEN BuyItem(keyb):GOTO SHOP_REDRAW
        if (keyb = KEY9) THEN SellItem():GOTO SHOP_REDRAW
    LOOP UNTIL FALSE
END SUB

SUB INTRO_SCREEN()
    paper BLACK: ink WHITE: border BLACK: cls

    RESTORE intro_text
    TypeWriteAt(5, 5, 5)   

    PrintAt(20, 17, "1. CONTINUE",ALIGN_LEFT, attMenu)

    ClearEnter() 
    DO
        keyb = CODE INKEY$
        if keyb = KEY1 THEN HOME_SCREEN()
        if keyb = KEY0 THEN GOTO END_PROGRAMM
    LOOP UNTIL FALSE
END SUB

SUB HELP_SCREEN()
    paper BLACK: ink WHITE: border BLACK: cls
    POKE UINTEGER 23675, @Items

    PrintAt(3,8,"HELP",ALIGN_CENTER, attMenu)
    PrintAt(5,5,"Move character:",ALIGN_LEFT, attDef)
    PrintAt(6,5,"  PC controlls - WASD",ALIGN_LEFT, attDef)
    PrintAt(7,5,"  ZX controlls U(7) D(6) L(5) R(8)",ALIGN_LEFT, attDef)
    PrintAt(8,5,"  KEPMPSTON joystick",ALIGN_LEFT, attDef)
    
    'PrintAttr(9,5,"",ALIGN_LEFT, attDef)

    PrintAt(10,5,chr(CHR_SPIDERWEB),ALIGN_LEFT, attEnergy)
    PrintAt(10,7,"Spider web: -10 energy",ALIGN_LEFT, attDef)
    PrintAt(11,5,chr(CHR_CHEST_CLOSED),ALIGN_LEFT, attGold)
    PrintAt(11,7,"Chest: random gold",ALIGN_LEFT, attDef)
    PrintAt(12,5,chr(CHR_DIAMOND),ALIGN_LEFT, attDiamond)
    PrintAt(12,7,"Diamond: +5 energy",ALIGN_LEFT, attDef)
    PrintAt(13,5,chr(CHR_BOOK),ALIGN_LEFT, attBook)
    PrintAt(13,7,"Book: reval random items",ALIGN_LEFT, attDef)

    PAUSE 60
    PrintAt(21, 17, "1. RETURN",ALIGN_LEFT, attMenu)
    PrintAt(22, 17, "0. EXIT",ALIGN_LEFT, attMenu)

    ClearEnter() 
    DO
        keyb = CODE INKEY$
        if keyb = KEY1 THEN GOTO START
        if keyb = KEY0 THEN GOTO END_PROGRAMM
    LOOP UNTIL FALSE
END SUB

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
