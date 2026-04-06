
SUB HRPrint (x AS UBYTE, y AS UBYTE, char AS UInteger, attribute AS UBYTE, overprint AS UBYTE)
'High res Printing, based on code produced, with thanks, by Turkwel over on the WOS boards.
'Brought to ZX Basic by Britlion, June 2010.
 
ASM
      ld a,(IX+13) ; Get overprint value
      AND a ; zero?
      JR Z,HRP_No_Over
      LD a,174 ;XOR(HL) 182 ; OR(HL) code
      ;  JP HRP_Change_Code (unnecessary)
HRP_No_Over:
        ; XOR A ; faster than LD a,0 (unnecessary, since to get here, a=0!)
HRP_Change_Code:     
        LD (HRPOver1),a
        LD (HRPOver2),a
 
        ld b,(IX+7)
       ld c,(IX+5)
 
      push BC ; SAVE our co-ordinates.
 
;print_char:   
        ld  d,(IX+09)
        inc d
        dec d
        jr z, HRPrint_From_Charset
        ld e,(IX+08)
        jp HR_Print
HRPrint_From_Charset:       
        ld  de,(23606)
      ld  h,0
      ld  l,(IX+8) ; character
      add  hl,hl
      add  hl,hl
      add  hl,hl
      add  hl,de
 
HR_Print:
 
      call HRPat   
;convert the Y AND X pixel values TO the correct Screen Address  - Address in DE
      ld a,8
;set counter TO 8 - Bytes of Character Data TO put down
HRPrint0:
       push af
;save off Counter
      ld a,b
      cp 192
      jr c,HRprint1
       pop af
      jp HRPrintEnd
;don't print character if  > 191 - off the bottom of the screen - restore AF and exit Print routine
;[this can be removed IF you are keeping tight control of your Y values]
HRprint1:
       push hl
      push de
      push de
;save off Address of Character Data, Screen Address, Screen Address
      ld a,c
      AND 7
      ld d,a
;get lowest 3 bits of Screen address
      ld e,255
;set up E with the Mask TO use - 11111111b = All On
      ld a,(hl)
      jr z,HRprint3
;get a BYTE of Character Data TO put down - but ignore the following Mask shifting
;if the the X value is on an actual Character boundary i.e. there's no need to shift anything
HRprint2:
       rrca
      srl e
      dec d
      jp nz,HRprint2
;Rotate the Character Data BYTE D times - AND Shift the Mask BYTE AS well, forcing Zeroes into the
;Left hand side. The Mask will be used TO split the Rotated Character Data OVER a Character boundary
HRprint3:
       pop hl
;POP one of the Screen Addresses (formerly in DE) into HL
      ld d,a
      ld a,e
      AND d
HRPOver1:      OR (hl)
      ld (hl),a
;take the Rotated Character Data, mask it with the Mask BYTE AND the OR it with what's already on the Screen,
;this takes care of the first part of the BYTE
;[remove the OR (HL) IF you just want a straight write rather than a merge]
      inc l
      ld a,l
      AND 31
      jr z,HRprint4
;Increment the Screen Address AND check TO see IF it's at the end of a line,
;if so THEN there's no need to put down the second part of the Byte
      ld a,e
      cpl
      AND d
HRPOver2:      OR (hl)
      ld (hl),a
;Similar TO the first BYTE, we need TO Invert the mask with a CPL so we can put down the second part of the BYTE
;in the NEXT Character location
;[again, remove the OR (HL) IF you just want a straight write rather than a merge]
HRprint4:
       pop de
      inc d
      inc b
;get the Screen Address back into DE, increment the MSB so it points the the Address immediately below
;it AND Increment the Y value in B AS well
      ld a,b
      AND 7
      call z,HRPat
;now check IF the Y value has gone OVER a Character Boundary i.e. we will need TO recalculate the Screen
;Address IF we've jumped from one Character Line to another - messy but necessary especially for lines 7 and 15
      pop hl
      inc hl
;get the Address of the Character Data back AND increment it ready FOR the NEXT BYTE of data
      pop af
      dec a
      jp nz,HRPrint0
;get the Counter value back, decrement it AND GO back FOR another write IF we haven't reached the end yet
      jp HRPrintAttributes
 
 
;HRPAT is a subroutine TO convert pixel values into an absolute screen address
;On Entry - B = Y Value C = X Value   On EXIT - DE = Screen Address
HRPat:
      ld a,b
      srl a
      srl a
      srl a
      ld e,a
      AND 24
      OR 64
      ld d,a
      ld a,b
      AND 7
      add a,d
      ld d,a
      ld a,e
      AND  7
      rrca
      rrca
      rrca
      ld e,a
      ld a,c
      srl a
      srl a
       srl a
       add a,e
      ld  e,a
      ret
 
HRPrintAttributes:
        POP BC ; recover our X-Y co-ordinates.
       ld d,0
      ld a,(IX+11) ; attribute
      AND a
      jr z, HRPrintEnd  ; IF attribute=0, THEN we don't do attributes.
      ld e,a ; pass TO e
;transfer Attribute BYTE TO e FOR easier use
      ld a,b
      cp 192
      jr nc, HRPrintEnd
;check Y position AND EXIT IF off bottom of screen
      push bc
;save off Y AND X values FOR later
      AND 248
      ld h,22
      ld l,a
      add hl,hl
      add hl,hl
      srl c
      srl c
      srl c
      ld b,d
      add hl,bc
;calculate the correct Attribute Address FOR the Y\X values
      ld (hl),e
;set the Attribute - this is ALWAYS set no matter what the valid Y\X values used
      pop bc
;get the Y AND X values back into BC
      ;call print_attribute2
;call the subroutine TO see IF an adjacent Horizontal Attribute needs TO be set
print_attributes1:
       ld a,c
      cp 248
      jr nc,endPrintAttributes1
;check TO see IF we are AT Horizontal character 31 - IF so THEN no need TO set adjacent Horizontal Attribute
      AND 7
      jr z, endPrintAttributes1
;and don't set the adjacent Horizontal Attribute if there's no need to
      inc l
      ld (hl),e
      dec l
;increment the Attribute address - set the adjacent horizontal Attribute - THEN set the Attribute Address back
endPrintAttributes1:                             
 
 
;
      ld a,b
      cp 184
      jr nc, HRPrintEnd
;check TO see IF we are AT Vertical character 23 - IF so THEN no need TO set adjacent Vertical Attribute & EXIT routine
      AND 7
      jr z, HRPrintEnd
;and don't set the adjacent Vertical Attribute if there's no need to & Exit routine
      ld a,l
      add a,32
      ld l,a
      ld a,d
      adc a,h
      ld h,a
      ld (hl),e
;set the Attribute address TO the line below  - AND set the adjacent Vertical Attribute
;
;drop through now into adjacent Horizontal Attribute subroutine - all RETs will now EXIT the routine completely
;
HRPrintAttribute2:   ld a,c
      cp 248
      jr nc, HRPrintEnd
;check TO see IF we are AT Horizontal character 31 - IF so THEN no need TO set adjacent Horizontal Attribute
      AND 7
      jr z, HRPrintEnd
;and don't set the adjacent Horizontal Attribute if there's no need to
      inc l
      ld (hl),e
      dec l
;increment the Attribute address - set the adjacent horizontal Attribute - THEN set the Attribute Address back
      ;ret                       
 
HRPrintEnd:
 
END ASM
END SUB