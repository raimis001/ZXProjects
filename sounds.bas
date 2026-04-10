SUB PlaySound(addr AS UINTEGER)
ASM
    ;ld hl, SoundEffect1Data

    ;ld l, (ix+5)
    ;ld h, (ix+6)
    ld d, (IX+5)
    ld (hl), d

NextNote:
    ; tone -> BC
    ld c, (hl)
    inc hl
    ld b, (hl)
    inc hl

    ; length -> DE
    ld e, (hl)
    inc hl
    ld d, (hl)
    inc hl

    ; end marker = 0,0
    ld a, b
    or c
    jr nz, CheckPlay
    ld a, d
    or e
    jr z, Done

CheckPlay:
    push hl

    ; if tone = 0 => pause only
    ld a, b
    or c
    jr z, PauseOnly

    call PlayToneBCDE
    jr AfterPlay

PauseOnly:
    call PauseDE

AfterPlay:
    pop hl
    jr NextNote

Done:
    pop IX ; restore IX to prevent stack imbalance
    ret


PlayToneBCDE:
ToneLoop:
    push de

    ld a, 16
    out (254), a
    call DelayBC

    xor a
    out (254), a
    call DelayBC

    pop de
    dec de
    ld a, d
    or e
    jr nz, ToneLoop
    ret


PauseDE:
PauseLoop:
    push de
    ld bc, 150
PauseInner:
    dec bc
    ld a, b
    or c
    jr nz, PauseInner
    pop de
    dec de
    ld a, d
    or e
    jr nz, PauseLoop
    ret


DelayBC:
    push bc
DelayLoop:
    dec bc
    ld a, b
    or c
    jr nz, DelayLoop
    pop bc
    ret

END ASM
END SUB

SoundStep:
ASM
    defw $400,10
    defw 0,0
END ASM

SoundEffect1Data:
ASM
    defw $300,80
    defw $0,60
    defw $451,180
    defw $0,60
    defw $451,180
    defw $0,60
    defw $451,180
    defw 0,0
END ASM

SoundSpiderWeb:
ASM
    defw $600,30
    defw $0,60
    defw $451,80
    defw 0,0
END ASM

SoundChest:
ASM
    defw $200,30
    defw $0,20
    defw $200,30
    defw $451,50
    defw 0,0
END ASM
