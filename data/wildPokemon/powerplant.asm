PowerPlantMons:
	db $0A
	db 21,VOLTORB
	db 21,MAGNEMITE
	db 20,PIKACHU
	db 24,PIKACHU
	db 23,MAGNEMITE
	db 23,VOLTORB
	db 32,MAGNETON
	db 35,MAGNETON
	IF DEF(_RED)
		db 33,ELECTABUZZ
		db 36,RAICHU
	ENDC
	IF DEF(_BLUE)
		db 33,RAICHU
		db 36,ELECTABUZZ
	ENDC
	db $00
