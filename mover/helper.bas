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

CONST TRUE  AS BOOLEAN = 1
CONST FALSE AS BOOLEAN = 0

CONST SCREEN_WIDTH  AS UBYTE = 32
CONST SCREEN_WIDTH42 AS UBYTE = 42
CONST SCREEN_HEIGHT  AS UBYTE = 24


function getFrames() as uLong
    return PEEK(23672) + PEEK(23673) * 256 + (PEEK(23674) and 127) * 65536
    'return INT(PEEK (23672))/50 + (256 * PEEK(23673) + 65536 * PEEK (23674))
end function

SUB resetFrames()
    POKE UINTEGER 23672, 0
    POKE UINTEGER 23673, 0
    POKE UINTEGER 23674, 0
END SUB


function CalcYAddress(x AS UByte, y as UBYTE) as UInteger
    DIM offset AS UInteger
    DIM offsetY AS UInteger
	IF y<8 THEN
		offset=0
		offsetY=(y SHL 5)
		
		GOTO calculate
	END IF
	
	IF y<16 THEN
		offset=2048
		offsetY=((y-8) SHL 5)
		
		GOTO calculate
	END IF
	
	offset=4096
	offsetY=((y-16) SHL 5)
	
	calculate:
	return 16384 + offset + offsetY + x
END function

SUB DrawCombinedChar(x AS UByte, y AS UByte, graphDataAddr AS UInteger)
    ' Aprēķina ekrāna atmiņas adresi rakstzīmei (x, y)

    DIM baseAddr AS UInteger = CalcYAddress(x,y)
    DIM screenAddr AS UInteger

    ' Apvieno grafiku 8 rindām (8x8 rakstzīme)
    FOR row = 0 TO 7
        screenAddr = baseAddr + row * 256
        POKE UBYTE screenAddr, (PEEK (UBYTE, (graphDataAddr+row))) bOR (PEEK (UBYTE, screenAddr))
    NEXT row
END SUB

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
SUB PrintAt(y as uByte, x as uByte, strAt$ as string, paperAt as Byte = -1, inkAt as Byte = -1, alignAt as Byte = 0)
    '0 = Left, 1 = Center, 2 = Right'

    DIM attr as uByte = PEEK(23693)
    DIM paperOld as Byte = (attr & 56) / 8
    DIM inkOld as Byte = attr & 7 
    DIM l as uByte = LEN(strAt$)

    if paperAt > -1 THEN PAPER paperAt
    if inkAt > -1 THEN INK inkAt
    
    if alignAt = 1 then'Center
        x = x + (SCREEN_WIDTH42 - x - l) / 2
    else if alignAt = 2 then'Right
        x = x - l
    end if

    printat42(y,x)
    print42(strAt$)

    if paperAt > -1 AND paperOld <> (attr AND 56) / 8 THEN PAPER paperOld
    if inkAt > -1 AND inkOld <> (attr AND 7) THEN INK inkOld

END SUB

SUB Wait(frameCount as uByte)
    FOR n=1 to frameCount
        ASM 
        HALT
        END ASM
    NEXT n
END SUB


'DIM att1 AS UByte = atr(x, y)
'DIM p AS UByte = (att1 / 8) & 7
'DIM f AS UByte = (att1 / 128) & 1 ' Izvelk FLASH (bits 7) no a
'DIM b AS UByte = (att1 / 64) & 1 ' Izvelk BRIGHT (bits 6) no a
'DIM k as UByte = att1 & 7

'DIM n AS UByte = p * 8 + k


'FUNCTION AndUByte(a AS UBYTE, b AS UBYTE) AS UBYTE
''    ASM
''        ld a, l      ; l = a (pirmais parametrs)
''        and h        ; h = b (otrais parametrs)
''        ld l, a      ; rezultāts atpakaļ L reģistrā (funkcijas atgrieztā vērtība)
''    END ASM
'END FUNCTION