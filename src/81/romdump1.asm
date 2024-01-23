;----------------------------------------------------------------
; romdump1.asm by tr1p1ea - 14/01/2024 (dd/mm/yyyy)
; TI-81 ROM Dumper for V1.0
;----------------------------------------------------------------
;
; hl = current ROM pointer
;  d = current ROM byte
;  e = bit counter & bit clock flip/flop (bit 0 only)
;  b = port $00 output settings (bits 4:7 set to configure bits 0:3 for output)
;  c = bit clock flip/flop mask (bit 0 only)
;
	.nolist
	.include <ti81.inc>
	.list

	.org equMem + 6 - $2000					; mirrored equMem (V1.0 is offset by 1 byte vs other ROM versions)
	.db tQuote

getByte:
	ld d,(hl)						; next byte
	inc hl							; increase pointer
	set $03,e						; e = $08 - reset bit counter & bit clock flip/flop (bit 0 only)
	ret

init:
	xor a							; a = $00
	ld l,a
	ld h,a							; hl = $0000 - ROM start address
	ld e,a							; gets set to $08 during getByte
	inc a
	ld c,a							; c = 1 - bit clock flip/flop is bit 3 of output
	sub $11							; $01 - $11 = $F0
	ret

	.if $ != $DCDC
	.error "Code misaligned from $DCDC"
	.endif

DCDC:
	call init						; init
	ld b,a							; b = $F0 - port $07 settings (configure bits 0:3 for output)
	call getByte						; get first byte of ROM

mainLoop:
	ld a,e							; use bit 0 as bit toggle
	and c							; mask in bit 0
	sla d							; test bit 7 of current ROM byte
	rla							; rotate in data bit
	add a,a
	add a,a							; shift to bits 2 & 3
	or b							; add port $07 settings
	out ($17),a						; write data to LINK port ($07 is mirrored to $17) - bit 3 = clock, bit 2 = data
	dec e							; decrease bit counter
	call z,getByte						; get next byte and reset counter if zero
	jp mainLoop						; loop

	.db tQuote, tStore, tY2, tEnter
	.db tQuote, tPtOn, tQuote, tStore, tY3T, tEnter
	.db tQuote, tLParen, tChs, t1, tRParen, tPower, tPi, tQuote, tStore, tY1, tEnter
	.db t0, tStore, tX