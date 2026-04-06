#include "perlin.bas"
paper 0: ink 7:cls
print at 0, 0; "Perlin Noise. Press any key."
pause 0

randomize
initPerlin()

DIM x,y as UInteger
DIM tresh as UByte = 125
DIM scale AS UByte = 20

newRandom:
'Generate a random permutation table'
shufflePerlin()

newNoise:
if scale > 100 THEN scale = 100
if scale < 1 THEN scale = 1
if tresh > 255 THEN tresh = 255
if tresh < 0 THEN tresh = 0
CLS
print at 0,0; "Treshold: "; tresh;" Scale: "; scale


FOR y = 0 TO 175 STEP 4
    FOR x = 0 TO 255 STEP 4
        IF noise01(x, y, scale, tresh) = 1 THEN
            PLOT x, y
        END IF
    NEXT x
NEXT y

WHILE INKEY=""
END WHILE
if INKEY$ = "z" THEN GOTO newRandom
if INKEY$ = "a" scale = scale + 1: GOTO newNoise
if INKEY$ = "d" scale = scale - 1: GOTO newNoise
if INKEY$ = "w" THEN tresh = tresh + 5: GOTO newNoise
if INKEY$ = "s" THEN tresh = tresh - 5: GOTO newNoise


'pause 0
paper 7: ink 0:cls
STOP