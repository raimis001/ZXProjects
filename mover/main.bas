
'#include <keys.bas>
#include "gardens.bas"
#include "hrprint.bas"
'Library from https://github.com/raimis001/ZXLib
#include "../helper.bas"
#include "../perlin.bas"

#include <print42.bas>
#include <screen.bas>
''#include <attr.bas>

CONST FIELD_W AS UBYTE = 32
CONST FIELD_H AS UBYTE = 24

CONST LINE_EMPTY AS string = "                               "

CONST UP AS UBYTE = 4
CONST RIGHT AS UBYTE = 1    
CONST DOWN AS UBYTE = 3
CONST LEFT AS UBYTE = 2
CONST ENTER AS UBYTE = 13

CONST DEBUG_MODE as BOOLEAN = TRUE ' Debug flag to control debug output

DIM ch_posY as ubyte = 0*8
DIM ch_posX as ubyte = 0*8
DIM animation as uByte = 0
DIM anim as ubyte = 0

DIM garden(FIELD_H, FIELD_W) as ubyte
DIM money_x as ubyte = 0
DIM money_y as ubyte = 0

DIM MONEY as ubyte = 0
DIM SCORE as ubyte = 0
DIM SCORE_MAX as ubyte = 0
DIM FUEL as Float = 10
const fuel_consumption as float = 0.001

DIM GAME as uByte = 0 '0 - Village, 1 - Garden 2 quest panel

DIM moles(5) as UInteger
DIM mole_frame as uLong = 0
DIM mole_count as uByte = 0

function get_controlls(key as string) as ubyte
    if key = "d" THEN return RIGHT
    if key = "a" THEN return LEFT  
    if key = "s" THEN return DOWN
    if key = "w" THEN return UP
    if key = CHR(13) THEN return ENTER ' Enter key
    return 0
END function

function get_index(posX as UInteger, posY as UInteger) as UInteger
    return posY * FIELD_W + posX
end function

function get_posX(index as UInteger) as UInteger
    return index MOD FIELD_W
end function
function get_posY(index as UInteger) as UInteger
    return INT(index / FIELD_W)
end function

function GetCell(posX as ubyte) as ubyte
    return INT(posX / 8)
end function

function is_obsticle(x as ubyte, y as ubyte) as BOOLEAN

    if garden(y, x) > 9 and garden(y, x) < 50 THEN return TRUE

    return FALSE
end function

function check_garden(x as ubyte, y as ubyte) as BOOLEAN

    DIM gx as ubyte = GetCell(x)
    DIM gy as ubyte = GetCell(y)

    if is_obsticle(gx, gy) 
        return FALSE
    end if

    return TRUE
end function

function is_grass(x as ubyte, y as ubyte) as BOOLEAN

    if garden(y, x) > 0 and garden(y, x) < 10 THEN return TRUE

    return FALSE
end function

SUB clear_screen()
    ink WHITE: paper BLUE: border BLACK: bright 0: cls
END SUB

SUB restore_screen()
    ink BLACK: paper WHITE: border WHITE: bright 0: cls
END SUB

SUB draw_ui()
    PrintAt(0, 25, "Money: " + STR(MONEY) + "     ", -1, -1, 0)
    PrintAt(1, 25, "Fuel : " + STR(INT(FUEL)) + "     ", -1, -1, 0)
    PrintAt(2, 25, "Score: " + STR(SCORE) + "/" + STR(SCORE_MAX) + "     ", -1, -1, 0)
END SUB

SUB load_garden(g as ubyte)

    cls
    shufflePerlin()

    IF g = 1 THEN RESTORE garden1

    SCORE_MAX = 0
    mole_count = 2
    for i = 0 to 4
        moles(i) = 0
    next i

    for y = 0 to FIELD_H - 1
        for x = 0 to FIELD_W - 1
            READ garden(y,x)
        next x
    next y

    ' Generate grass and trees
    for y = 5 to FIELD_H - 6
        for x = 5 to FIELD_W - 6
            if garden(y, x) > 2 THEN continue for
            if noise01(x * 8, y * 8, 3, 240) = 1 THEN
                garden(y, x) = 18 ' Tree
                continue for 
            end if
            if noise01(x * 8, y * 8, 20, 200) = 1 THEN
                if RND > 0.7 THEN 
                    garden(y, x) = 2 ' Yellow grass
                else 
                    garden(y, x) = 1 ' Grass
                end if
            end if
        next x
    next y

    ' Draw garden
    for y = 0 to FIELD_H - 1
        for x = 0 to FIELD_W - 1
            if garden(y,x) = 0 THEN continue for

            if is_grass(x,y) THEN draw_grass(x, y): SCORE_MAX = SCORE_MAX + 1: continue for
            if is_obsticle(x,y) THEN draw_obsticle(x, y): continue for
            if garden(y, x) = 99 THEN ch_posX = x * 8: ch_posY = y * 8: continue for
            if garden(y, x) = 50 THEN money_x = x: money_y = y: continue for

        next x
    next y

    mole_recreate()

END SUB

SUB draw_grass(x as ubyte, y as ubyte)
    DIM p as ubyte = GREEN
    if garden(y,x) = 2 THEN p = YELLOW

    DIM idx as ubyte = 0
    if garden(y - 1, x) = 1 or garden(y - 1, x) = 2 THEN idx = 1
    if garden(y, x + 1) = 1 or garden(y, x + 1) = 2 THEN idx = idx + 2
    if garden(y + 1, x) = 1 or garden(y + 1, x) = 2 THEN idx = idx + 4
    if garden(y, x - 1) = 1 or garden(y, x - 1) = 2 THEN idx = idx + 8

    POKE UINTEGER 23675, @Garden
    PRINT AT y, x; INK p; BRIGHT 1; CHR(144 + idx);
END SUB

SUB draw_obsticle(x as ubyte, y as ubyte)
    DIM p as ubyte = BLUE
    DIM i as ubyte = RED

    if garden(y, x) >= 16 and garden(y, x) <= 17 then
        p = YELLOW
    end if
    if garden(y, x) = 18 then
        i = GREEN
        POKE UINTEGER 23675, @Garden
    else
        POKE UINTEGER 23675, @Character
    end if
    PRINT AT y, x; PAPER p;  INK i; BRIGHT 0; CHR(142 + garden(y, x));
END SUB

SUB garden_update()

    DIM gx as ubyte = GetCell(ch_posX+4)
    DIM gy as ubyte = GetCell(ch_posY+4)

    FUEL = FUEL - fuel_consumption

    if (is_grass(gx, gy)) THEN
        PRINT AT gy, gx; PAPER BLUE; " ";
        FUEL = FUEL - fuel_consumption * 100 * garden(gy, gx)
        garden(gy, gx) = 0
        SCORE = SCORE + 1
        for i = 0 to garden(gy, gx)
            beep 0.05, 20
            Wait(1)
        next i
        if SCORE = SCORE_MAX THEN
            PRINT AT money_y, money_x; PAPER BLUE; INK WHITE; BRIGHT 0; CHR(36);
        end if
    else if garden(gy,gx) = 50 THEN
        if SCORE = SCORE_MAX THEN
            MONEY = MONEY + SCORE
            PRINT AT gy, gx; PAPER BLUE; " ";
            garden(gy, gx) = 0
        end if
    else if garden(gy, gx) = 100 THEN
        mole_count = mole_count - 1
        PRINT AT gy, gx; PAPER BLUE; " ";
        FUEL = FUEL - fuel_consumption * 100
        garden(gy, gx) = 0
        for i = 0 to 3
            beep 0.05, 20
            Wait(2)
        next i
    end if

    if mole_count > 0 THEN
        DIM frame as uLong = getFrames()
        if mole_frame <= frame THEN
            mole_frame = frame + 300 + INT(RND * 500)
            mole_recreate()
        end if
    end if
END SUB

SUB mole_recreate()
    DIM mx as ubyte
    DIM my as ubyte

    for i = 0 to mole_count - 1
        if moles(i) > 0 THEN
            mx = get_posX(moles(i))
            my = get_posY(moles(i))
            garden(my, mx) = 0
            PRINT AT my, mx; " ";
        end if
        DO
            mx = 5 + INT(RND * 20)
            my = 6 + INT(RND * 10)
            if garden(my, mx) = 0 THEN
                'print at 0,0; moles(0); " "; get_index(mx, my); " x:"; mx; " y:"; my;"    "
                garden(my, mx) = 100
                moles(i) = get_index(mx, my)
                PRINT AT my, mx; PAPER BLUE; INK RED; BRIGHT 0; CHR(164);
                EXIT DO
            end if
        LOOP UNTIL FALSE
    next i
END SUB

SUB draw_road(x as uByte, y as uByte) 
    DIM p as ubyte = BLUE
    DIM i as ubyte = WHITE
    DIM b as ubyte = 0
    DIM txt as string = " "
    if garden(y,x) = 1
        p = BLACK
        b = 0
    end if
    if garden(y,x) = 2
        p = BLACK
        b = 0
        txt = "-"
    end if

    PRINT AT y, x; PAPER p; INK i; BRIGHT b; txt

END SUB

SUB draw_quest(x as uByte, y as uByte)
    PRINT AT y, x; PAPER BLUE; INK WHITE; BRIGHT 1; CHR(161);
END SUB

SUB load_village() 
    RESTORE village
    for y = 0 to FIELD_H - 1
        for x = 0 to FIELD_W - 1
            READ garden(y,x)
            if garden(y,x) = 0 THEN continue for
            if is_grass(x,y) THEN draw_road(x, y): continue for
            if is_obsticle(x,y) THEN draw_obsticle(x, y): continue for
            if garden(y, x) = 50 THEN draw_quest(x, y): continue for
            if garden(y, x) = 99 THEN ch_posX = x * 8: ch_posY = y * 8: continue for
        next x
    next y

    
END SUB

SUB DrawRadar(px AS UInteger, py AS UInteger, r AS UByte)
    ' Pārvērš pikseļu koordinātas uz rakstzīmju koordinātām
    DIM minX AS Integer = (px - r) / 8: IF minX < 0 THEN minX = 0
    DIM maxX AS Integer = (px + r) / 8: IF maxX > 30 THEN maxX = 30
    DIM minY AS Integer = (196 - px - r) / 8: IF minY < 0 THEN minY = 0
    DIM maxY AS Integer = (196 - py + r) / 8: IF maxY > 22 THEN maxY = 22
    
    DIM scr(32, 24) AS STRING
    DIM atr(32, 24) AS UByte
    DIM attr as uByte = PEEK(23693)

    'print at minY+3, minX+3; "H"

    for y = minY to maxY
        for x = minX to maxX
            'STR(PEEK(16384 + y*256 + x))'''
            scr(x, y) = SCREEN$(y, x)
            atr(x, y) = PEEK(22528 + y*32 + x)'' ATTR(y, x)
        next x
    next y

    INK YELLOW: PAPER BLUE

    for i = 1 to 5

        circle px, py, r * i / 5
        for y = minY to maxY
            for x = minX to maxX
                POKE 22528 + y * 32 + x,atr(x,y)
            next x
        next y
        Wait(1)
        for y = minY to maxY
            for x = minX to maxX
                print at y, x; scr(x, y)
                POKE 22528 + y * 32 + x,atr(x,y)
            next x
        next y
    next i

    INK attr & 7: PAPER (attr & 56) / 8
END SUB

SUB wait_for_start()
    ClearEnter()
    PrintAt(FIELD_H-1, 0, "Press any key to start", -1, -1, 1)
    pause 0
    ClearEnter()
    PRINT AT FIELD_H -1, 0; LINE_EMPTY
END SUB

SUB garden_start()

    POKE UINTEGER 23675, @Garden

    load_garden(1)
    HRPrint(ch_posX , ch_posY, @Character, 0, 0)
    draw_ui()
    wait_for_start()

END SUB

SUB garden_loop(key as string)
    garden_update()

    beep 0.01,5
    FUEL = FUEL - fuel_consumption
    draw_ui()
    
END SUB

SUB village_loop(key as string)

    DIM gx as ubyte = GetCell(ch_posX+4)
    DIM gy as ubyte = GetCell(ch_posY+4)

    if garden(gy, gx) = 50 THEN draw_quest_panel()

END SUB

SUB draw_quest_panel()
    GAME = 2
    draw_panel(28, 14)
    PrintAt(6, 0, "Start working?", PINK, BLUE, 1)
    
    PrintAt(16, 15," YES ", BLUE, PINK, 0)
    PrintAt(16, 25," NO  ", PINK, WHITE, 0)
END SUB

DIM quest_answer as ubyte = 0 ' 0 - yes, 1 - no
SUB quest_loop(key as string)

    DIM old as ubyte = quest_answer
    DIM dir as ubyte = get_controlls(key)

    if dir = ENTER THEN 
        clear_screen()
        if quest_answer = 1 THEN GAME = 1: garden_start()
        if quest_answer = 0 THEN GAME = 0: load_village()
        return
    end if

    if dir = LEFT THEN quest_answer = 1
    if dir = RIGHT THEN quest_answer = 0

    if old <> quest_answer THEN
        if quest_answer = 0 THEN
            PrintAt(16, 15," YES ", BLUE, PINK, 0)
            PrintAt(16, 25," NO  ", PINK, WHITE, 0)
        else 
            PrintAt(16, 15," YES ", PINK, WHITE, 0)
            PrintAt(16, 25," NO  ", BLUE, PINK, 0)
        end if
        Wait(7)
    end if

END SUB

sub draw_panel(width as ubyte, height as ubyte, pInk as ubyte = PINK, pPaper as ubyte = BLUE)

    DIM x as ubyte = (FIELD_W - width) / 2
    DIM y as ubyte = (FIELD_H - height) / 2

    for j = 0 to height - 1
        for i = 0 to width - 1

            DIM c as string = " " ' Space character
            if i = 0 THEN c = CHR(138) ' Left border
            if i = width - 1 THEN c = CHR(133) ' Right border

            if j = 0 THEN c = CHR(131) ' Top border
            if j = height - 1 THEN c = CHR(140) ' Bottom border

            PRINT PAPER pPaper; INK pInk; AT y + j, x + i; c;
        next i
    next j


    PRINT PAPER pPaper; INK pInk; AT y, x; CHR(139); ' Top-left corner
    PRINT PAPER pPaper; INK pInk; AT y + height - 1, x; CHR(142); ' Bottom-left corner
    PRINT PAPER pPaper; INK pInk; AT y, x + width - 1; CHR(135); ' Top-right corner
    PRINT PAPER pPaper; INK pInk; AT y + height - 1, x + width - 1; CHR(141); ' Bottom-right corner
END SUB


SUB move(dir as ubyte)

    'DIM old_x as ubyte = ch_posX
    'DIM old_y as ubyte = ch_posY

    IF dir = RIGHT THEN 
        anim = 1 'Right
        if ch_posX < 239 and check_garden(ch_posX + 9, ch_posY) AND check_garden(ch_posX + 9, ch_posY + 7) THEN 
            ch_posX = ch_posX + 1
        end if        
    end if
    IF dir = LEFT THEN 
        anim = 3 'Left
        if ch_posX > 0 and check_garden(ch_posX - 1, ch_posY) AND check_garden(ch_posX - 1, ch_posY + 7) THEN
            ch_posX = ch_posX - 1: 
        end if
    end if
    if dir = DOWN THEN 
        anim = 2 'Down
        if ch_posY < 175 and check_garden(ch_posX, ch_posY + 9) AND check_garden(ch_posX + 7, ch_posY + 9) THEN 
            ch_posY = ch_posY + 1
        end if
    end if
    if dir = UP THEN 
        anim = 0 'Up
        if ch_posY > 0 and check_garden(ch_posX, ch_posY - 1) AND check_garden(ch_posX + 7, ch_posY - 1) THEN
            ch_posY = ch_posY - 1
        end if
    end if

    DIM gx as ubyte = GetCell(ch_posX)
    DIM gy as ubyte = GetCell(ch_posY)
    
    DIM mx as Byte = gx - 1: if mx < 0 THEN mx = 0
    DIM my as Byte = gy - 1: if my < 0 THEN my = 0

    for x = mx to gx + 1
        for y = my to gy + 1

            if x < 0 or y < 0 continue for
            if garden(y, x) = 0 or garden(y, x) = 99 THEN PRINT AT y, x; " "
            if is_obsticle(x, y) THEN draw_obsticle(x, y)
                
            if GAME = 0 THEN
                if is_grass(x, y) THEN draw_road(x, y)
                if garden(y, x) = 50 THEN draw_quest(x, y)
            end if

            if GAME = 1 THEN
                if is_grass(x, y) THEN draw_grass(x, y)
                if is_obsticle(x, y) THEN draw_obsticle(x, y)
            end if

        next y
    next x

    'HRPrint(old_x, old_y, 32, 0, 0)
    'attr = paper + ink * 8
    if GAME = 1 THEN
        HRPrint(ch_posX, ch_posY, @Character + anim * 8 + animation * 32, 0 , 0xAE)   
    else
        HRPrint(ch_posX, ch_posY, @Character + 18 * 8  + animation * 8, 0 , 0xAE)
    end if

END SUB



PROGRAM:
    clear_screen()

    POKE UINTEGER 23675, @Character
    'DrawCombinedChar(4,3, @Character) ' Draw character at (10,10)
    'DrawCombinedChar(4,3, @Character + 18 * 8) ' Draw character at (20,10)

    'draw_panel(20, 10)

    wait_for_start()
    randomize
    initPerlin()
    clear_screen()
    resetFrames()
    load_village() 

    DIM key as string
    DIM dir as ubyte
    DO

        key = INKEY$
        if key = " " THEN GOTO END_PROGRAMM
        if key = "g" then DrawRadar(ch_posY, ch_posX, 20)

        if GAME = 0 OR GAME = 1 THEN
            dir = get_controlls(key)
            if dir > 0 THEN move(dir)
        end if
        
        Wait(2)
        if animation=0 then animation=1 else animation=0

        if GAME = 0 THEN village_loop(key)
        if GAME = 1 THEN garden_loop(key)     
        if GAME = 2 THEN quest_loop(key)

    LOOP UNTIL FALSE
    
END_PROGRAMM:       
    wait_for_start()
    restore_screen()
    STOP



Character:
    ASM
        #include "char.asm"
    END ASM
Garden:
    ASM
        #include "garden.asm"
    END ASM