#include <print42.bas>

#DEFINE BLACK 0
#DEFINE BLUE 1
#DEFINE RED 2
#DEFINE PINK 3
#DEFINE GREEN 4
#DEFINE CYAN 5
#DEFINE YELLOW 6
#DEFINE WHITE 7

#DEFINE WIDTH 32
#DEFINE HEIGHT 24
#DEFINE HOLLE 29

#DEFINE EMPTY   "                                "
#DEFINE EMPTY28 "                             "


'FUNCTION Round(n as Float, decimals as UByte = 0) AS Float
''  DIM tmp as Float
''  DIM d10 as Float = 10^decimals
''  IF n >= 0 THEN
''    LET tmp = INT(n * d10 + 0.5)
''  ELSE
''    LET tmp = INT(n * d10 - 0.5)
''  END IF
''  RETURN tmp / d10
'END FUNCTION

SUB PrintCenter(s$ as string, atY as uByte)
    DIM l as uByte = INT((WIDTH - LEN(s$)) / 2)
    PRINT AT atY, 0; EMPTY
    PRINT AT atY, l;s$
END SUB

FUNCTION Fill(s$ as string, c$ as string, lens as uByte) as string
    DIM ret$ = s$
    FOR i = LEN(s$) TO lens
        ret$ = ret$ + c$
    NEXT i
    RETURN ret$
END FUNCTION

POKE (UINTEGER 23675, @graph)

DIM Clubs$(3)
FOR i = 0 TO 2
    READ Clubs$(i)
NEXT i

DIM Prize$(8)
FOR i = 0 TO 7
    READ Prize$(i)
NEXT i


DIM Score as uByte = 0
DIM CD as uByte= 0

DIM Shot as uByte
DIM Distance as uInteger
DIM LeftDistance as Integer
DIM Par as uByte
DIM Power as uByte
DIM SD as uInteger
DIM Club as uByte
DIM ClubName$ as string
DIM Ball as uByte
DIM BallO as uByte

GOSUB LoadScreen

GOSUB Tittle

randomize

DIM H as uByte = 1

NextHolle:
    LET Distance=INT (160 + RND * 300)
    LET Par = INT (Distance / 80)
    LET Shot=1
    LET LeftDistance = Distance
    LET BallO = 0
    LET Ball = 0
    GOSUB HoleInfo

NextShot:
    Power = 1
    Club = 0
    ClubName$ = Clubs$(0)
    GOSUB ShotInfo

    GOSUB DrawClubs
    GOSUB DrawPower       

    GOSUB CalcShot

    GOSUB DoShot
    
    ClearEnter() 
    IF LeftDistance < 4 THEN
        LeftDistance = 0
        GOSUB DrawBall
        ClearLine(9)
        PRINT AT 9,2; PAPER RED; INK CYAN; FLASH 1; " THE BALL IS IN THE HOLE! ";
        
        DIM diff as uByte = Par - Shot + 4
        DIM s$ as string
        IF diff <= 7 THEN s$ = Prize$(diff)
        IF diff > 7 THEN s$ =  STR(diff - 4) + Prize(7)

        Score = Score + Par - Shot
        PrintAt(10,0,s$,RED, CYAN,1)

        ClearLine(14)
        PrintAt(14,0," PRESS ENTER TO NEXT HOLE ", CYAN, -1,1)
        PlayTadaSound()
        WHILE INKEY$ <> CHR(13)
            PAUSE 1
        END WHILE



        H = H + 1
        FOR i = 5 TO 15
            ClearLine(i)
        NEXT i
        GOTO NextHolle
    END IF

    ClearLine(14)
    PrintAt(14,2," PRESS ENTER FOR NEXT SHOT ", CYAN, -1, 1)
    WaitEnter()
    ClearLine(12)
    ClearLine(14)

    LET Shot = Shot + 1

    GOSUB DrawBall
    GOTO NextShot
    
StopGame:
    PAUSE 50
    PAUSE 0
    BORDER WHITE: PAPER WHITE: INK BLACK: CLS
    STOP

LoadScreen:
    BORDER CYAN: PAPER GREEN: INK BLUE: CLS
    LoadTitleScreen()
    ClearTitleScreenData()
    PAUSE 100
    RETURN

Tittle:
    BORDER CYAN: PAPER GREEN: INK BLUE: CLS
    
    PrintAt(0,0,"GOLF 2026", RED, CYAN, 1)
    PrintAt(1,0,"*********", GREEN, BLUE, 1)
    PrintAt(2,0,"PRESS ANY KEY", GREEN, BLUE, 1)

    PAUSE 0
    ClearLine(2)
    PlayTadaSound()
    RETURN

HoleInfo: 
    
    ClearLine(3)
    ClearLine(4)

    PrintAt(3,2, "HOLE " + STR(H) + ". PAR " + STR(Par))
    PrintAt(3,20, "YOUR SCORE", -1, -1, 1)
    PrintAt(4,2, STR(Distance) + " YARDS TO PIN.")
    PrintAt(4,20, STR(Score), -1, -1, 1)

    'FLAG
    ClearLine(HEIGHT - 2)
    PRINT AT HEIGHT - 2,WIDTH - 3; INK BLACK; CHR$(148); INK RED; CHR$(149)

    DIM inkAt as uByte
    FOR i = 0 TO WIDTH - 2
        LET inkAt = BLUE
        IF i > WIDTH - 4 THEN inkAt = BLACK
        PRINT AT HEIGHT - 1, i; INK  inkAt; CHR$(140)
    NEXT i

    
    GOSUB DrawBall
    RETURN

ShotInfo:
    ClearLine(6)
    ClearLine(7)

    PrintAt(6,0, "SHOT " + STR(Shot), -1, RED, 1)
    PrintAt(7,0, "club: " + ClubName$ + " power: " + STR(Power), YELLOW, -1, 1)
    RETURN

DrawClubs:

    ClearLine(9)
    PrintAt(9,0,"PRESS ENTER ACCEPT CLUB:")
    PRINT AT 10, 0;"D  ";"P"
    FOR i = 1 TO 9
        PRINT AT 10,3 + i*3;i;"I"
    NEXT i

    GOSUB DrawChoiceClub
    GOSUB ChoiceClubs

    ClearLine(9)
    ClearLine(10)
    ClearLine(11)

    GOSUB ShotInfo

    RETURN

ChoiceClubs:
    ClearEnter()
    WHILE INKEY <> CHR(13) 
        IF INKEY = CHR(32) THEN GOTO StopGame
        IF Club < 10 AND (INKEY ="D" OR INKEY="d" OR INKEY=CHR(9)) THEN LET CD=1: GOSUB CalcClubs
        IF Club > 0 AND  (INKEY ="A" OR INKEY="a" OR INKEY=CHR(8)) THEN LET CD=-1: GOSUB CalcClubs
    END WHILE
    RETURN

CalcClubs:
    LET Club = Club + CD
    BEEP .5, -5 + Club
    GOSUB DrawChoiceClub
    doPause(20)
    RETURN

DrawChoiceClub:
    IF Club < 2 THEN ClubName$ = Clubs$(Club)
    IF Club > 1 THEN ClubName$=Clubs$(2)+" " + STR(Club - 1)

    PRINT AT 11,0;PAPER BLUE; INK YELLOW; EMPTY
    PRINT AT 11,Club*3;PAPER BLUE; INK YELLOW;CHR$(144)

    PrintAt(9,19, "   " + Fill(ClubName$," ",8),BLUE, YELLOW)
    INK BLUE: PAPER GREEN
    RETURN


DrawPower:
    GOSUB DrawChoicePower
    GOSUB ChoicePower
    
    ClearLine(8)
    ClearLine(9)
    ClearLine(10)

    GOSUB ShotInfo

    'ClearLine(13)
    'PrintAt(13,1, "POWER - ") 
    'PrintAt(13,10, Fill(STR(Power)," ", 21), YELLOW)
    
    RETURN

ChoicePower:
    ClearEnter()
    WHILE INKEY <> CHR(13) 
        IF INKEY = CHR(32) THEN GOTO StopGame
        IF Power < 10 AND (INKEY ="D" OR INKEY="d" OR INKEY=CHR(9)) THEN LET CD=1: GOSUB CalcPower
        IF Power > 0 AND  (INKEY ="A" OR INKEY="a" OR INKEY=CHR(8)) THEN LET CD=-1: GOSUB CalcPower
    END WHILE
    RETURN

CalcPower:
    LET Power = Power + CD
    BEEP .3, -5 + Power
    GOSUB DrawChoicePower
    doPause(20)
    RETURN


DrawChoicePower:
    ClearLine(9)
    ClearLine(10)

    PrintAt(9,0, "ENTER ACCEPT POWER: ")
    PrintAt(9,21,Fill("    " + STR(Power)," ",9), BLUE, YELLOW)

    PRINT AT 10,0;CHR(147)
    PRINT AT 10,13;CHR(146)

    FOR i = 1 TO Power
        PRINT AT 10,1+i;CHR(145)
    NEXT i
    RETURN

DoShot:    
    ClearLine(9)
    PrintAt(9,0, " PRESS ENTER FOR SHOT ", CYAN, BLUE, 1)
    WaitEnter()
    ClearLine(9)
    BEEP 0.3, -10

    ClearLine(12)
    PrintAt(12,0,"YOUR SHOT IS " + STR(SD) + " YEARDS", -1,-1,1)
    doPause(10)

    GOSUB AnimateBall
    GOSUB DrawBall

    RETURN

DrawBall:

    PrintCenter("~ " + STR(LeftDistance) + " YARDS ~", HEIGHT - 4)

    PRINT AT HEIGHT - 2, 0; EMPTY28
    PRINT INK BLACK; AT HEIGHT - 2, Ball; CHR$(145)

    RETURN

AnimateBall:
    DIM hh as uByte
    FOR i = BallO TO Ball
        PRINT AT HEIGHT - 2,0; EMPTY28
        ClearLine(HEIGHT - 3)
    
        LET hh = HEIGHT - 3
        IF i = BallO OR i = Ball THEN LET hh = HEIGHT - 2
        PRINT INK BLACK; AT hh, i; CHR$(145)
        BEEP .1, -5 + Power
        doPause(3)
    NEXT i
    
    RETURN

CalcShot:
    IF Club = 0 THEN LET SD = 219: GOSUB RandomizeShot: RETURN
    IF Club = 1 THEN LET SD = 50: GOSUB RandomizeShot: RETURN

    SD = INT((Club - 1) * -10 + 105)

    GOSUB RandomizeShot

    RETURN

RandomizeShot:
    DIM r as UInteger = INT((RND * (SD / 4)) - (RND * (SD / 8)))
  
    LET SD = SD + r
    LET SD = INT(SD * Power / 10)

    LET LeftDistance = ABS(LeftDistance - SD)
    DIM prc as Float= CAST(Float,Distance - LeftDistance) / CAST(Float, Distance)
    LET BallO = Ball
    LET Ball = INT(HOLLE * prc)

    RETURN

SUB ClearLine(y as uByte) 
    PRINT AT y,0;EMPTY
END SUB

SUB doPause(frameCount as uByte)
    FOR n=1 to frameCount
        ASM 
        HALT
        END ASM
    NEXT n
END SUB

SUB ClearEnter() 
    WHILE INKEY$ <> ""
        PAUSE 1
    END WHILE
END SUB

SUB WaitEnter()
    ClearEnter() 
    WHILE INKEY$ <> CHR(13)
        PAUSE 1
    END WHILE
END SUB

SUB PrintAt(y as uByte, x as uByte, strAt$ as string, paperAt as Byte = -1, inkAt as Byte = -1, alignAt as Byte = 0)

    DIM attr as uByte = PEEK(23693)
    DIM inkOld as Byte = -1
    DIM paperOld as Byte = -1 

    if paperAt > -1 THEN paperOld = (attr AND 56) / 8: PAPER paperAt
    if inkAt > -1 THEN inkOld = attr AND 7: INK inkAt

    DIM l as uByte = LEN(strAt$)
    if alignAt = 1 then'Center
        x = x + (42 - x - l) / 2
    end if
    if alignAt = 2 then'Right
        x = x - l
    end if

    printat42(y,x)
    print42(strAt$)

    if paperOld > -1 THEN PAPER paperOld
    if inkOld > -1 THEN INK inkOld

END SUB

SUB PlayTadaSound()
    ' Augšupejošs arpeggio (C4 → E4 → G4 → C5)
    BEEP 0.15, 0   '' C4, 0.15 sekundes
    BEEP 0.15, 4   '' E4
    BEEP 0.15, 7   '' G4
    BEEP 0.15, 12  '' C5
    doPause(3)     '' 0.06 sekundes pauze
    ' Lejupejošs arpeggio (E5 → G4 → E4 → C4)
    BEEP 0.2, 16   '' E5, 0.2 sekundes
    BEEP 0.2, 7    '' G4
    doPause(2)     '' 0.04 sekundes pauze
    BEEP 0.2, 4    '' E4
    BEEP 0.3, 0    '' C4, nedaudz garāks noslēguma tonis
    doPause(3)     '' 0.06 sekundes pauze
    ' Noslēguma akcents (atgādina oriģinālo Tada)
    BEEP 0.2, 7    '' G4
END SUB

'SUB CheckFreeMemory()
''    DIM ramtop AS UINTEGER
''    ramtop = PEEK(23730) + 256 * PEEK(23731)  
''    cls
''    PRINT "Pieejama atmiņa: "; 49152 - ramtop; " baiti"
''    PAUSE 0 
'END SUB

SUB LoadTitleScreen()
    ASM
        LD HL, title_screen_data  
        LD DE, 16384             
        LD BC, 6912              
        LDIR                     
    END ASM
END SUB

SUB ClearTitleScreenData()
    ASM
        LD HL, title_screen_data
        LD DE, title_screen_data + 1
        LD BC, 6911
        LD (HL), 0
        LDIR
    END ASM
END SUB

ASM
    title_screen_data:
    INCBIN "title.scr"
END ASM

graph:
ASM
	DB 24,60,126,219,153,24,24,24       ;144 arrow up
    DB 24,60,255,255,255,255,60,24      ;145 ball
    DB 24,48,96,255,255,96,48,24        ;146 arrow left
    DB 24,12,6,255,255,6,12,24          ;147 arrow right  
    DB 3,3,3,3,3,3,3,3                  ;148 flag stick
	DB 192,224,240,224,192,128,0,0      ;149 flag flag
END ASM

DATA "Driver","Putter","Iron"
DATA "Ace", "Double Eagle", "Eagle","Birdie", "Par","Bogey","Double Bogey","Triple Bogey"
