# include "maze.bas"
#include <print42.bas>

#DEFINE BLACK 0
#DEFINE BLUE 1
#DEFINE RED 2
#DEFINE PINK 3
#DEFINE GREEN 4
#DEFINE CYAN 5
#DEFINE YELLOW 6
#DEFINE WHITE 7

#DEFINE M_SIZE 20
#DEFINE M_OFFSET 1
#DEFINE M_EMPTY "                    "

#DEFINE UI_X 29


'Function distance (x1 as uByte, y1 as uByte, x2 as uByte, y2 as uByte) as uByte
''    dim dx as uByte = x2 - x1
''    dim dy as uByte = y2 - y1
''    dim mn as uByte

''    let mn = dy
''    If dx < dy then let mn = dx

''   Return (dx + dy - (mn >> 1) - (mn >> 2) + (mn >> 4))
'End Function

border BLACK: PAPER BLUE: INK YELLOW: cls

'POKE UINTEGER 23675, @graph
ReadGraph()

DIM playing as uByte = 0
DIM p(20,4) as uByte
DIM startX as uByte = 1
DIM startY as uByte = 19
DIM tick as UINTEGER = 0
DIM lives as uByte = 10

DIM maze(M_SIZE,M_SIZE) as uByte
DIM castle(1,1) as uByte

printat42(0,30)
print42("Start Game")

LoadMaze(0)

pause 0
printat42(0,30)
print42("Play Game ")

DIM maxEnemy as uByte = 5

'PLOT 0, 0: DRAW ink GREEN; 70, 70

while playing = 0
    if tick mod 10 = 0 then CreateEnemy()
    
    MoveAllEnemy()
    PrintUi()
    
    if lives < 1 then goto endGame
    pause 20
    tick = tick + 1
END WHILE

endGame:
    PrintAt(22, 0, "GAME OVER", -1, -1, 1)  
    pause 0
    border BLACK: PAPER BLACK: INK WHITE: cls
    STOP


SUB PrintUi()
    'PRINT AT 0, 21; "12345678901"
    PRINT AT 1, 21; "           "
    PRINT AT 2, 21; "           "
    PrintAt(1, UI_X, "lives", -1, -1, 1)
    PrintAt(2, UI_X, str(lives), -1, -1, 1)
END SUB

SUB CreateEnemy()
    Dim cnt as uByte = 0
    for i = 0 to 19
        if p(i,0) > 0 then let cnt = cnt + 1
    NEXT i

    if cnt > maxEnemy then Return

    for i = 0 to 19
        if p(i,0) > 0 then continue for

        p(i,0) = 1
        p(i,1) = startY
        p(i,2) = startX
        p(i,3) = 0
        Return
    NEXT i
    'LET p(0,3) = 0 '' 0 UP 1 RIGHT 2 DOWN 3 LEFT
    
END SUB

SUB MoveAllEnemy()
    for i = 0 to 19
        if p(i,0) > 0 then MoveEnemy(i)
    NEXT i
END SUB

SUB MoveEnemy(enemy as uByte) 
    PRINT AT p(enemy, 1)+ M_OFFSET,p(enemy, 2)+M_OFFSET;" "

    if p(enemy, 3) = 0 then 'UP
        if maze(p(enemy,1)-1,p(enemy,2)) = 4 then
            p(enemy,0) = 0
            lives = lives - 1
            Return
        END IF
        IF maze(p(enemy,1)- 1,p(enemy,2)) = 0 THEN 'UP 
            p(enemy,1) = p(enemy,1) - 1
        ELSE if maze(p(enemy,1),p(enemy,2)+1) = 0 then 'Right
            p(enemy,3) = 1
            p(enemy,2) = p(enemy,2) + 1
        ELSE if maze(p(enemy,1),p(enemy,2)-1) = 0 then 'Left
            p(enemy,3) = 3
            p(enemy,2) = p(enemy,2) - 1
        END IF

    ELSE if p(enemy, 3) = 1 then 'RIGHT
        if maze(p(enemy,1),p(enemy,2)+1) = 0 then 'Right
            p(enemy,2) = p(enemy,2) + 1
        ELSE if maze(p(enemy,1)-1,p(enemy,2)) = 0 then 'UP
            p(enemy,3) = 0
            p(enemy,1) = p(enemy,1) - 1
        ELSE if maze(p(enemy,1)+1,p(enemy,2)) = 0 then 'Down
            p(enemy,3) = 2
            p(enemy,1) = p(enemy,1) + 1
        END IF

    ELSE IF p(enemy, 3) = 2 then 'DOWN
        if maze(p(enemy,1)+1,p(enemy,2)) = 0 then 'Down
            p(enemy,1) = p(enemy,1) + 1
        ELSE if maze(p(enemy,1),p(enemy,2)-1) = 0 then 'Left
            p(enemy,3) = 3
            p(enemy,2) = p(enemy,2) - 1
        ELSE if maze(p(enemy,1),p(enemy,2)+1) = 0 then 'Right
            p(enemy,3) = 1
            p(enemy,2) = p(enemy,2) + 1
        END IF

    ELSE if p(enemy, 3) = 3 then 'LEFT
        if maze(p(enemy,1),p(enemy,2)-1) = 0 then 'Left
            p(enemy,2) = p(enemy,2) - 1
        ELSE if maze(p(enemy,1)-1,p(enemy,2)) = 0 then 'UP
            p(enemy,3) = 0
            p(enemy,1) = p(enemy,1) - 1
        ELSE if maze(p(enemy,1)+1,p(enemy,2)) = 0 then 'Down
            p(enemy,3) = 2
            p(enemy,1) = p(enemy,1) + 1
        END IF

    END IF

    if p(enemy,1) = castle(0,0) and p(enemy,2) = castle(0,1) then
        p(enemy,0) = 0
        if lives > 0 then
            lives = lives - 1
        END IF
        return
    END IF
    PrintEnemy(enemy)
END SUB

SUB PrintEnemy(enemy as uByte)
    PRINT AT p(enemy, 1)+M_OFFSET,p(enemy, 2)+M_OFFSET;CHR(143+p(enemy,0))
END SUB

SUB LoadMaze(m as uByte)

    if m = 0 then RESTORE maze1
    if m = 1 then RESTORE maze2

    FOR y = 0 TO M_SIZE - 1
        FOR x = 0 TO M_SIZE - 1
            READ maze(y,x)
            if maze(y,x) = 4 then
                castle(0,0) = y
                castle(0,1) = x
                maze(y,x) = 0
            end if
        NEXT x
    NEXT y

    DrawMaze()
END SUB

SUB DrawMaze()
    ClearMaze()
    FOR y = 0 TO M_SIZE - 1
        FOR x = 0 TO M_SIZE - 1
            IF maze(y,x) > 0 THEN PRINT AT M_OFFSET+y,M_OFFSET+x;CHR(151 + maze(y,x))

            if y = castle(0,0) and x = castle(0,1) then
                PRINT INK RED; AT M_OFFSET+y,M_OFFSET+x;CHR(151 + 4)
            end if
            
        NEXT x
    NEXT y

END SUB

SUB ClearMaze()
    FOR y = 0 TO M_SIZE
        PRINT AT M_OFFSET+y,M_OFFSET;M_EMPTY
    NEXT y
END SUB

SUB ReadGraph()
    POKE UINTEGER 23675, @graph
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



graph:
    ASM
    #include "Test.asm"
    END ASM

