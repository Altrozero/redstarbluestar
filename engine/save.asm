LoadSAV: ; 735e8 (1c:75e8)
;(if carry -> write
;"the file data is destroyed")
	call ClearScreen
	call LoadFontTilePatterns
	call LoadTextBoxTilePatterns
	call LoadSAVCheckSum
	jr c, .badsum
	call LoadSAVCheckSum1
	jr c, .badsum
	call LoadSAVCheckSum2
	jr c, .badsum
	ld a, $2 ; good checksum
	jr .goodsum
.badsum
	ld hl, $d730
	push hl
	set 6, [hl]
	ld hl, FileDataDestroyedText
	call PrintText
	ld c, $64
	call DelayFrames
	pop hl
	res 6, [hl]
	ld a, $1 ; bad checksum
.goodsum
	ld [$d088], a ; checksum flag
	ret

FileDataDestroyedText: ; 7361e (1c:761e)
	TX_FAR _FileDataDestroyedText
	db "@"

LoadSAVCheckSum: ; 73623 (1c:7623)
	ld a, $a
	ld [$0], a
	ld a, $1
	ld [$6000], a
	ld [$4000], a
	ld hl, $a598 ; hero name located in SRAM
	ld bc, $f8b ; but here checks the full SAV
	call SAVCheckSum
	ld c, a
	ld a, [$b523] ; SAV's checksum
	cp c
	jp z, .Func_73652
	ld hl, $a598
	ld bc, $f8b
	call SAVCheckSum
	ld c, a
	ld a, [$b523] ; SAV's checksum
	cp c
	jp nz, SAVBadCheckSum

.Func_73652 ; 73652 (1c:7652)
	ld hl, $a598
	ld de, W_PLAYERNAME ; $d158
	ld bc, $b
	call CopyData
	ld hl, $a5a3
	ld de, wPokedexOwned ; $d2f7
	ld bc, $789
	call CopyData
	ld hl, W_CURMAPTILESET ; $d367
	set 7, [hl]
	ld hl, $ad2c
	ld de, wSpriteStateData1
	ld bc, $200
	call CopyData
	ld a, [$b522]
	ld [$ffd7], a
	ld hl, $b0c0
	ld de, W_NUMINBOX ; $da80
	ld bc, $462
	call CopyData
	and a
	jp SAVGoodChecksum

LoadSAVCheckSum1: ; 73690 (1c:7690)
	ld a, $a
	ld [$0], a
	ld a, $1
	ld [$6000], a
	ld [$4000], a
	ld hl, $a598 ; hero name located in SRAM
	ld bc, $f8b  ; but here checks the full SAV
	call SAVCheckSum
	ld c, a
	ld a, [$b523] ; SAV's checksum
	cp c
	jr nz, SAVBadCheckSum
	ld hl, $b0c0
	ld de, W_NUMINBOX ; $da80
	ld bc, $462
	call CopyData
	and a
	jp SAVGoodChecksum

LoadSAVCheckSum2: ; 736bd (1c:76bd)
	ld a, $a
	ld [$0], a
	ld a, $1
	ld [$6000], a
	ld [$4000], a
	ld hl, $a598 ; hero name located in SRAM
	ld bc, $f8b  ; but here checks the full SAV
	call SAVCheckSum
	ld c, a
	ld a, [$b523] ; SAV's checksum
	cp c
	jp nz, SAVBadCheckSum
	ld hl, $af2c
	ld de, W_NUMINPARTY ; $d163
	ld bc, $194
	call CopyData
	ld hl, $a5a3
	ld de, wPokedexOwned ; $d2f7
	ld bc, wPokedexSeenEnd - wPokedexOwned
	call CopyData
	and a
	jp SAVGoodChecksum

SAVBadCheckSum: ; 736f7 (1c:76f7)
	scf

SAVGoodChecksum: ; 736f8 (1c:76f8)
	ld a, $0
	ld [$6000], a
	ld [$0], a
	ret

Func_73701: ; 0x73701
	call LoadSAVCheckSum
	call LoadSAVCheckSum1
	jp LoadSAVCheckSum2

SaveSAV: ;$770a
	callba PrintSaveScreenText
	ld hl,WouldYouLikeToSaveText
	call SaveSAVConfirm
	and a   ;|0 = Yes|1 = No|
	ret nz
	ld a,[$d088]
	dec a
	jr z,.save
	call SAVCheckRandomID
	jr z,.save
	ld hl,OlderFileWillBeErasedText
	call SaveSAVConfirm
	and a
	ret nz
.save        ;$772d
	call SaveSAVtoSRAM      ;$7848
	FuncCoord 1,13
	ld hl,Coord
	ld bc,$0412
	call ClearScreenArea ; clear area 4x12 starting at 13,1
	FuncCoord 1,14
	ld hl,Coord
	ld de,NowSavingString
	call PlaceString
	ld c,$78
	call DelayFrames
	ld hl,GameSavedText
	call PrintText
	ld a, (SFX_02_5d - SFX_Headers_02) / 3 ;sound for saved game
	call PlaySoundWaitForCurrent
	call WaitForSoundToFinish
	ld c,$1e
	jp DelayFrames

NowSavingString:
	db "Now saving...@"

SaveSAVConfirm: ; 73768 (1c:7768)
	call PrintText
	FuncCoord 0, 7
	ld hl,Coord
	ld bc,$0801     ;arrow's coordinates |b = Y|c = X|
	ld a,$14        ;one line shifting ($28 = 2 lines)
	ld [$d125],a
	call DisplayTextBoxID      ;handle Yes/No KeyPress
	ld a,[$cc26]
	ret

WouldYouLikeToSaveText: ; 0x7377d
	TX_FAR _WouldYouLikeToSaveText
	db "@"

GameSavedText: ; 73782 (1c:7782)
	TX_FAR _GameSavedText
	db "@"

OlderFileWillBeErasedText: ; 73787 (1c:7787)
	TX_FAR _OlderFileWillBeErasedText
	db "@"

SaveSAVtoSRAM0: ; 7378c (1c:778c)
	ld a, $a
	ld [$0], a
	ld a, $1
	ld [$6000], a
	ld [$4000], a
	ld hl, W_PLAYERNAME ; $d158
	ld de, $a598
	ld bc, $b
	call CopyData
	ld hl, wPokedexOwned ; $d2f7
	ld de, $a5a3
	ld bc, $789
	call CopyData
	ld hl, wSpriteStateData1 ; OAM?
	ld de, $ad2c
	ld bc, $200
	call CopyData
	ld hl, W_NUMINBOX ; $da80
	ld de, $b0c0
	ld bc, $462
	call CopyData
	ld a, [$ffd7]
	ld [$b522], a
	ld hl, $a598
	ld bc, $f8b
	call SAVCheckSum
	ld [$b523], a
	xor a
	ld [$6000], a
	ld [$0], a
	ret

SaveSAVtoSRAM1: ; 737e2 (1c:77e2)
; stored pokémon
	ld a, $a
	ld [$0], a
	ld a, $1
	ld [$6000], a
	ld [$4000], a
	ld hl, W_NUMINBOX ; $da80
	ld de, $b0c0
	ld bc, $462
	call CopyData
	ld hl, $a598
	ld bc, $f8b
	call SAVCheckSum
	ld [$b523], a
	xor a
	ld [$6000], a
	ld [$0], a
	ret

SaveSAVtoSRAM2: ; 7380f (1c:780f)
	ld a, $a
	ld [$0], a
	ld a, $1
	ld [$6000], a
	ld [$4000], a
	ld hl, W_NUMINPARTY ; $d163
	ld de, $af2c
	ld bc, $194
	call CopyData
	ld hl, wPokedexOwned ; pokédex only
	ld de, $a5a3
	ld bc, wPokedexSeenEnd - wPokedexOwned
	call CopyData
	ld hl, $a598
	ld bc, $f8b
	call SAVCheckSum
	ld [$b523], a
	xor a
	ld [$6000], a
	ld [$0], a
	ret

SaveSAVtoSRAM: ; 73848 (1c:7848)
	ld a, $2
	ld [$d088], a
	call SaveSAVtoSRAM0
	call SaveSAVtoSRAM1
	jp SaveSAVtoSRAM2

SAVCheckSum: ; 73856 (1c:7856)
;Check Sum (result[1 byte] is complemented)
	ld d, $0
.loop
	ld a, [hli]
	add d
	ld d, a
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ld a, d
	cpl
	ret

Func_73863: ; 73863 (1c:7863)
	ld hl, $a000
	ld de, $ba4d
	ld b, $6
.asm_7386b
	push bc
	push de
	ld bc, $462
	call SAVCheckSum
	pop de
	ld [de], a
	inc de
	pop bc
	dec b
	jr nz, .asm_7386b
	ret

Func_7387b: ; 7387b (1c:787b)
	ld hl, PointerTable_73895 ; $7895
	ld a, [$d5a0]
	and $7f
	cp $6
	ld b, $2
	jr c, .asm_7388c
	inc b
	sub $6
.asm_7388c
	ld e, a
	ld d, $0
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

PointerTable_73895: ; 73895 (1c:7895)
	dw $A000
	dw $A462
	dw $A8C4
	dw $AD26
	dw $B188
	dw $B5EA

Func_738a1:: ; 738a1 (1c:78a1)
	ld hl, WhenYouChangeBoxText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem] ; $cc26
	and a
	ret nz
	ld hl, $d5a0
	bit 7, [hl]
	call z, Func_73a29
	call Func_7393f
	call UpdateSprites
	ld hl, $fff6
	set 1, [hl]
	call HandleMenuInput
	ld hl, $fff6
	res 1, [hl]
	bit 1, a
	ret nz
	call Func_7387b
	ld e, l
	ld d, h
	ld hl, W_NUMINBOX ; $da80
	call Func_7390e
	ld a, [wCurrentMenuItem] ; $cc26
	set 7, a
	ld [$d5a0], a
	call Func_7387b
	ld de, W_NUMINBOX ; $da80
	call Func_7390e
	ld hl, W_MAPTEXTPTR ; $d36c
	ld de, wWhichTrade ; $cd3d
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a
	call Func_3f05
	call SaveSAVtoSRAM
	ld hl, wWhichTrade ; $cd3d
	call Func_3f0f
	ld a, (SFX_02_5d - SFX_Headers_02) / 3
	call PlaySoundWaitForCurrent
	call WaitForSoundToFinish
	ret

WhenYouChangeBoxText: ; 73909 (1c:7909)
	TX_FAR _WhenYouChangeBoxText
	db "@"

Func_7390e: ; 7390e (1c:790e)
	push hl
	ld a, $a
	ld [$0], a
	ld a, $1
	ld [$6000], a
	ld a, b
	ld [$4000], a
	ld bc, $462
	call CopyData
	pop hl
	xor a
	ld [hli], a
	dec a
	ld [hl], a
	ld hl, $a000
	ld bc, $1a4c
	call SAVCheckSum
	ld [$ba4c], a
	call Func_73863
	xor a
	ld [$6000], a
	ld [$0], a
	ret

Func_7393f: ; 7393f (1c:793f)
	xor a
	ld [H_AUTOBGTRANSFERENABLED], a ; $ffba
	ld a, $3
	ld [wMenuWatchedKeys], a ; $cc29
	ld a, $b
	ld [wMaxMenuItem], a ; $cc28
	ld a, $1
	ld [wTopMenuItemY], a ; $cc24
	ld a, $c
	ld [wTopMenuItemX], a ; $cc25
	xor a
	ld [$cc37], a
	ld a, [$d5a0]
	and $7f
	ld [wCurrentMenuItem], a ; $cc26
	ld [wLastMenuItem], a ; $cc2a
	ld hl, wTileMap
	ld b, $2
	ld c, $9
	call TextBoxBorder
	ld hl, ChooseABoxText
	call PrintText
	FuncCoord 11, 0 ; $c3ab
	ld hl, Coord
	ld b, $c
	ld c, $7
	call TextBoxBorder
	ld hl, $fff6
	set 2, [hl]
	ld de, BoxNames ; $79d9
	FuncCoord 13, 1 ; $c3c1
	ld hl, Coord
	call PlaceString
	ld hl, $fff6
	res 2, [hl]
	ld a, [$d5a0]
	and $7f
	cp $9
	jr c, .asm_739a6
	sub $9
	FuncCoord 8, 2 ; $c3d0
	ld hl, Coord
	ld [hl], $f7
	add $f6
	jr .asm_739a8
.asm_739a6
	add $f7
.asm_739a8
	FuncCoord 9, 2 ; $c3d1
	ld [Coord], a
	FuncCoord 1, 2 ; $c3c9
	ld hl, Coord
	ld de, BoxNoText
	call PlaceString
	call Func_73a84
	FuncCoord 18, 1 ; $c3c6
	ld hl, Coord
	ld de, wWhichTrade ; $cd3d
	ld bc, $14
	ld a, $c
.asm_739c2
	push af
	ld a, [de]
	and a
	jr z, .asm_739c9
	ld [hl], $78
.asm_739c9
	add hl, bc
	inc de
	pop af
	dec a
	jr nz, .asm_739c2
	ld a, $1
	ld [H_AUTOBGTRANSFERENABLED], a ; $ffba
	ret

ChooseABoxText: ; 739d4 (1c:79d4)
	TX_FAR _ChooseABoxText
	db "@"

BoxNames: ; 739d9 (1c:79d9)
	db   "BOX 1"
	next "BOX 2"
	next "BOX 3"
	next "BOX 4"
	next "BOX 5"
	next "BOX 6"
	next "BOX 7"
	next "BOX 8"
	next "BOX 9"
	next "BOX10"
	next "BOX11"
	next "BOX12@"

BoxNoText: ; 73a21 (1c:7a21)
	db "BOX No.@"

Func_73a29: ; 73a29 (1c:7a29)
	ld a, $a
	ld [$0], a
	ld a, $1
	ld [$6000], a
	ld a, $2
	ld [$4000], a
	call Func_73a4b
	ld a, $3
	ld [$4000], a
	call Func_73a4b
	xor a
	ld [$6000], a
	ld [$0], a
	ret

Func_73a4b: ; 73a4b (1c:7a4b)
	ld hl, $a000
	call Func_73a7f
	ld hl, $a462
	call Func_73a7f
	ld hl, $a8c4
	call Func_73a7f
	ld hl, $ad26
	call Func_73a7f
	ld hl, $b188
	call Func_73a7f
	ld hl, $b5ea
	call Func_73a7f
	ld hl, $a000
	ld bc, $1a4c
	call SAVCheckSum
	ld [$ba4c], a
	call Func_73863
	ret

Func_73a7f: ; 73a7f (1c:7a7f)
	xor a
	ld [hli], a
	dec a
	ld [hl], a
	ret

Func_73a84: ; 73a84 (1c:7a84)
	ld hl, wWhichTrade ; $cd3d
	push hl
	ld a, $a
	ld [$0], a
	ld a, $1
	ld [$6000], a
	ld a, $2
	ld [$4000], a
	call Func_73ab8
	ld a, $3
	ld [$4000], a
	call Func_73ab8
	xor a
	ld [$6000], a
	ld [$0], a
	pop hl
	ld a, [$d5a0]
	and $7f
	ld c, a
	ld b, $0
	add hl, bc
	ld a, [W_NUMINBOX] ; $da80
	ld [hl], a
	ret

Func_73ab8: ; 73ab8 (1c:7ab8)
	ld a, [$a000]
	ld [hli], a
	ld a, [$a462]
	ld [hli], a
	ld a, [$a8c4]
	ld [hli], a
	ld a, [$ad26]
	ld [hli], a
	ld a, [$b188]
	ld [hli], a
	ld a, [$b5ea]
	ld [hli], a
	ret

SAVCheckRandomID: ;$7ad1
;checks if Sav file is the same by checking player's name 1st letter ($a598)
; and the two random numbers generated at game beginning
;(which are stored at $d359-d35a)
	ld a,$0a
	ld [$0000],a
	ld a,$01
	ld [$6000],a
	ld [$4000],a
	ld a,[$a598]
	and a
	jr z,.next
	ld hl,$a598
	ld bc,$0f8b
	call SAVCheckSum
	ld c,a
	ld a,[$b523]
	cp c
	jr nz,.next
	ld hl,$a605
	ld a,[hli]
	ld h,[hl]
	ld l,a
	ld a,[$d359]
	cp l
	jr nz,.next
	ld a,[$d35a]
	cp h
.next
	ld a,$00
	ld [$6000],a
	ld [$0000],a
	ret

Func_73b0d: ; 73b0d (1c:7b0d)
	ld a, [$d5a2]
	dec a
	cp $32
	jr nc, .asm_73b28
	ld hl, $a598
	ld bc, $60
	call AddNTimes
	ld e, l
	ld d, h
	ld hl, $cc5b
	ld bc, $60
	jr CopyToSRAM0
.asm_73b28
	ld hl, $a5f8
	ld de, $a598
	ld bc, $1260
	call CopyToSRAM0
	ld hl, $cc5b
	ld de, $b7f8
	ld bc, $60
	jr CopyToSRAM0

Func_73b3f: ; 73b3f (1c:7b3f)
	ld hl, $a598
	ld bc, $60
	ld a, [wWhichTrade] ; $cd3d
	call AddNTimes
	ld de, $cc5b
	ld bc, $60
	; fallthrough
CopyToSRAM0: ; 73b51 (1c:7b51)
	ld a, $a
	ld [$0], a
	ld a, $1
	ld [$6000], a
	xor a
	ld [$4000], a
	call CopyData
	xor a
	ld [$6000], a
	ld [$0], a
	ret

Func_73b6a: ; 73b6a (1c:7b6a)
	ld a, $a
	ld [$0], a
	ld a, $1
	ld [$6000], a
	xor a
	call PadSRAM_FF
	ld a, $1
	call PadSRAM_FF
	ld a, $2
	call PadSRAM_FF
	ld a, $3
	call PadSRAM_FF
	xor a
	ld [$6000], a
	ld [$0], a
	ret

PadSRAM_FF: ; 73b8f (1c:7b8f)
	ld [$4000], a
	ld hl, $a000
	ld bc, $2000
	ld a, $ff
	jp FillMemory