DIM permutation(0 TO 255) AS UBYTE

' A simple implementation of Perlin noise using a random permutation table
FUNCTION hashPerm(x as uByte, y as uByte) as uByte
    DIM idx as uByte = x & 255
    idx = permutation(idx) + y
    idx = idx & 255
    return permutation(idx)
END FUNCTION


' Returns 1 for noise, 0 for no noise
'x and y are pixel coordinates, scale is the size of the noise "cells"'
' threshold is the value above which noise is considered present'
FUNCTION noise01(x as uByte, y as uByte, scale as uByte, threshold AS UBYTE = 128) as uByte
    DIM sx as uByte = INT(x / scale)
    DIM sy as uByte = INT(y / scale)
    'RETURN (hashPerm(sx, sy) & 128) / 128

    IF hashPerm(sx, sy) > threshold THEN
        RETURN 1
    END IF
    RETURN 0

END FUNCTION

SUB initPerlin()
    DIM i AS UInteger

    'Fill permutation with values 0-255'
    FOR i = 0 TO 255
        permutation(i) = i
    NEXT i

END SUB

SUB shufflePerlin()
    DIM i AS UInteger
    DIM j AS UInteger
    DIM temp AS UByte

    ' Shuffle the permutation array using Fisher-Yates algorithm'
    FOR i = 255 TO 1 STEP -1
        j = RND * i 
        temp = permutation(i)
        permutation(i) = permutation(j)
        permutation(j) = temp
    NEXT i
END SUB

