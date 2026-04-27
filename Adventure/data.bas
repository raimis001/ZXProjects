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
        DB 0,60,102,183,169,86,44,24
    END ASM

Gems:
    ASM
        DB 15,17,34,68,136,240,73,72
	    DB 240,136,68,34,17,15,146,18
	    DB 36,36,18,10,5,2,1,0
	    DB 36,36,72,80,160,64,128,0
    END ASM

'        "                                          "
intro_text:
    DATA "even a tiny drop of dew on"
    DATA "a flower cannot be preserved"
    DATA "(O. Vacietis)"
    DATA ""
    DATA "And still, there is a story"
    DATA "of a stone no one can reach"

rest_text:
     DATA "You rest and recover your energy."
     DATA "Many have walked these paths"
     DATA "and turned back."
     DATA "Not because they failed"
     DATA "but because they understood."

rubin_text:
    DAtA "You have found the ruby."
    DATA "Its fire burns bright in your hands"
    DATA "but the path is far from over."
    DAtA "There is more to seek,"
    DATA "and you must keep moving forward."

sapphire_text:
    DATA "You have found the sapphire."
    DATA "Endless depth whispers of wisdom"
    DATA "yet your journey is not complete."
    DATA "Keep searching,"
    DATA "what you seek still lies ahead."

ametist_text:
    DATA "I have found the amethyst."
    DATA "I have reached my goal,"
    DATA "and I no longer wish to search." 
    DATA "Its quiet glow asks nothing of me."
    DATA ""
    DATA "He who found it has quietly"
    DATA "stepped away from the world."