Character:
    ASM
        DB 0,24,60,24,60,90,36,36   ;Character
        ;#include "Graph.asm"
    END ASM
Items:
    ASM
        DB 24,60,110,74,90,90,74,126    ;0 Door
        DB 16,112,80,248,12,6,28,8      ;1 Key
        DB 160,68,34,86,8,149,98,4      ;2 Spiderweb
        DB 0,0,60,90,102,90,66,126      ;3 Chest closed
        DB 0,60,90,66,126,66,66,126     ;4 Chest opened
        DB 0,66,36,192,227,119,54,124   ;5 Diamond
        DB 48,86,137,233,143,185,203,60 ;6 Book
    END ASM

intro_text:
    DATA "even a tiny drop of dew on"
    DATA "a flower cannot be preserved"
    DATA "(O. Vacietis)"
    DATA ""
    DATA "And still, there is a story"
    DATA "of a stone no one can reach"
    DATA "Perhaps it was never meant to be found"  

rest_text:
     DATA "You rest and recover your energy."
     DATA "Many have walked these paths"
     DATA "and turned back."
     DATA "Not because they failed"
     DATA "but because they understood."
