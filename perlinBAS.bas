10 REM === Perlin Noise Demo for ZX BASIC ===
20 DIM p(256): REM permutation table, now 1-based
30 GOSUB 1000: REM Init permutation
40 CLS : PAPER 0: INK 7
50 PRINT AT 0, 0; "Perlin Noise. Press key."
60 PAUSE 0
70 RANDOMIZE PEEK 23672 + 256 * PEEK 23673

80 LET treshold = 125
90 LET scale = 20

100 GOSUB 2000: REM Shuffle permutation
110 GOTO 300

200 REM === Input handling loop ===
210 IF INKEY$ = "" THEN GOTO 210
220 LET k$ = INKEY$
230 IF k$ = "z" THEN GOSUB 2000: GOTO 300
240 IF k$ = "a" THEN LET scale = scale + 1: GOTO 300
250 IF k$ = "d" THEN LET scale = scale - 1: GOTO 300
260 IF k$ = "w" THEN LET treshold = treshold + 5: GOTO 300
270 IF k$ = "s" THEN LET treshold = treshold - 5: GOTO 300
280 PAPER 7: INK 0: CLS: STOP

300 REM === Clamp noise values ===
310 IF scale > 100 THEN LET scale = 100
320 IF scale < 1 THEN LET scale = 1
330 IF treshold > 255 THEN LET treshold = 255
340 IF treshold < 0 THEN LET treshold = 0

350 CLS
360 PRINT AT 0, 0; "Treshold:"; treshold; " Scale:"; scale

400 REM === Draw Perlin noise ===
410 FOR y = 0 TO 175 STEP 4
420   FOR x = 0 TO 255 STEP 4
430     IF FN n(x, y, scale, treshold) > treshold THEN PLOT x, y
440   NEXT x
450 NEXT y

500 REM === End draw, return to input
510 GOTO 200

999 REM === Helpers ===

1000 REM Init permutation array
1010 FOR i = 0 TO 255
1020   LET p(i+1) = i
1030 NEXT i
1040 RETURN

2000 REM Shuffle permutation using Fisher-Yates
2010 FOR i = 255 TO 1 STEP -1
2020   LET j = INT(RND * i)
2030   LET tmp = p(i+1)
2040   LET p(i+1) = p(j+1)
2050   LET p(j+1) = tmp
2060 NEXT i
2070 RETURN

3000 REM Hash function and noise logic
3010 DEF FN h(x,y) = p( (p( (x - INT(x/256)*256) + 1 ) + y) - INT((p( (x - INT(x/256)*256) + 1 ) + y)/256)*256 + 1 )
3020 DEF FN n(x,y,s) = ( FN h( INT(x/s), INT(y/s) ) )
