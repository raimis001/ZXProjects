#include <print42.bas>

#DEFINE BLACK 0
#DEFINE BLUE 1
#DEFINE RED 2
#DEFINE PINK 3
#DEFINE GREEN 4
#DEFINE CYAN 5
#DEFINE YELLOW 6
#DEFINE WHITE 7

#DEFINE BOOLEAN UBYTE

#DEFINE ALIGN_LEFT 0
#DEFINE ALIGN_CENTER 1  
#DEFINE ALIGN_RIGHT 2

CONST TRUE  AS BOOLEAN = 1
CONST FALSE AS BOOLEAN = 0

CONST SCREEN_WIDTH  AS UBYTE = 32
CONST SCREEN_WIDTH42 AS UBYTE = 42
CONST SCREEN_HEIGHT  AS UBYTE = 24

CONST LINE_EMPTY AS string = "                                          "


SUB ClearEnter() 
    WHILE INKEY$ <> ""
        PAUSE 1
    END WHILE
END SUB

' Prints a string at a specified position on the screen with optional formatting.
' Parameters:
'   y        - The row position (0-based).
'   x        - The column position (0-based).
'   strAt$   - The string to print.
'   paperAt  - The paper color (default: -1, no change).
'   inkAt    - The ink color (default: -1, no change).
'   alignAt  - The alignment of the string (0 = Left, 1 = Center, 2 = Right).
SUB PrintAt(y as uByte, x as uByte, strAt$ as string, alignAt as Byte = ALIGN_LEFT, paperAt as Byte = -1, inkAt as Byte = -1 )
    '0 = Left, 1 = Center, 2 = Right'

    DIM attr as uByte = PEEK(23693)
    DIM paperOld as Byte = (attr & 56) / 8
    DIM inkOld as Byte = attr & 7 
    'DIM brightOld as Byte = (attr AND 128) / 128

    DIM l as uByte = LEN(strAt$)

    if paperAt > -1 THEN PAPER paperAt
    if inkAt > -1 THEN INK inkAt
    
    if alignAt = ALIGN_CENTER then'Center
        x = x + (SCREEN_WIDTH42 - x - l) / 2
    else if alignAt = ALIGN_RIGHT then'Right
        x = x - l
    end if

    printat42(y,x)
    print42(strAt$)

    if paperAt > -1 AND paperOld <> (attr AND 56) / 8 THEN PAPER paperOld
    if inkAt > -1 AND inkOld <> (attr AND 7) THEN INK inkOld

END SUB

'SUB LoadScreen(addr as uinteger)
''    ASM
''        ld d, (IX+5)
''        ld (hl), d
''        ld de, 16384
''        ld bc, 6912
''        ldir
''    END ASM
'END SUB

'SUB LoadTitleScreen()
''    ASM
''        LD HL, title_screen_data  
''        LD DE, 16384             
''        LD BC, 6912              
''        LDIR                     
''    END ASM
'END SUB

'SUB ClearTitleScreenData()
''    ASM
''        LD HL, title_screen_data
''        LD DE, title_screen_data + 1
''        LD BC, 6911
''        LD (HL), 0
''        LDIR
''    END ASM
'END SUB

'Example of title screen data, to be included in the project that needs it.
'ASM
'    title_screen_data:
'    INCBIN "zxTitleScr.scr"
'END ASM

SUB Wait(frameCount as uByte)
    FOR n=1 to frameCount
        ASM 
        HALT
        END ASM
    NEXT n
END SUB