;------------------------------- DESCRIPTION -------------------------------;
	; khai bao cac bien dung trong bai:	
		thutu_not 	EQU 20h 	; cac not trong ban nhac ;dinh dia chi byte
		truong_do 	EQU 21h 	; tao tr truong do cac not ;dinh dia chi byte

		tso_l 		EQU 22h 	; byte thap chua gia tri se nap cho timer
		tso_h 		EQU 23h 	; chua byte cao

		tam_1 		EQU 24h 	; dey la 2 bien de chua
		tam_2 		EQU 25h 	; tam thoi du lieu cho xu li
		play 		BIT P1.4 	; chan output nhac
		on_off		BIT	P1.0	; cho phep play/playagain
		play_pause	BIT	P3.2	; cho phep play/pause
			
	; play_again EQU 26h ; quan li so lan lap lai cua bai hat
	; qui uoc not_trang = 8 , den = 4 , moc_don = 2	
	
;---------------------------------------------------------------------------;
		ORG 	0000h 				; chon dia chi bat dau o bo nho
		LJMP 	MAIN
		ORG 	000bh 				; dia chi ngat timer 0
		LJMP 	TOISR 				
		ORG 	0003h				; dia chi ngat ngoai 0
		LJMP 	E0ISR;		

;---------------------------------------------------------------------------;
		ORG 	0030h 				; chon dia chi luu chuong trinh chinh
	MAIN: 
		MOV 	IE, #83h 			; cho phep ngat timer 0 va ngat ngoai 0
		MOV 	TMOD, #01h 			; chon timer_0 mod_1: 16 BIT
	WAIT: 
		JB 		on_off, PLAYMUSIC 	; cho nhan nut chay
		JMP 	WAIT 				; cho nhan nut chay
	PLAYMUSIC:
		MOV 	thutu_not, #00h		
	NEXT_M:
		MOV 	A, thutu_not
		MOV 	DPTR, #SHEETNHAC
		MOVC 	A, @A+DPTR
		MOV 	tam_2, A		
		JZ 		END0 				; neu het ban nhac thi EXIT (khi a=0)
		ANL 	A, #0fh 			; and a va #fh
		MOV 	truong_do, A
		MOV 	A, tam_2
		SWAP 	A
		ANL 	A, #0fh
		JNZ 	SING 				; neu a khac 0 thi nhay vao SING
		CLR 	TR0 				; stop bo dinh thoi							
		LJMP 	D1						

;---------------------------------------------------------------------------;
	SING:
		DEC 	A
		RL 		A 					; nhan a cho 2 (a x 2)
		MOV 	tam_1, A
		MOV 	DPTR, #CAODO 		; MOV DPTR=00h (vi tri chon cao do)
		MOVC 	A, @A+DPTR
		MOV 	TH0, A
		MOV 	tso_h, A
		MOV 	A, tam_1
		INC 	A
		MOVC 	A, @A+DPTR
		MOV 	TL0, A
		MOV 	tso_l, A
		SETB 	TR0 				; khoi dong bo dinh thoi		
	D1:
		LCALL 	TRUONGDO
		INC 	thutu_not
		LJMP 	NEXT_M		
	TRUONGDO: 						; dieu chinh truong do									
		MOV 	R7, #01h 			
	D2:
		MOV 	R4, #187 			; t = truong_do x 92752us (12MHZ)
	D3:
		MOV 	R3, #240
		DJNZ 	R3, $
		DJNZ 	R4, D3
		DJNZ 	R7, D2
		DJNZ 	truong_do, TRUONGDO
		RET
		
;---------------------------------------------------------------------------;	
	END0:
		CLR 	TR0 				
		LJMP 	EXIT
		
;---------------------------------------------------------------------------;		
	; cac chuong trinh ngat
	TOISR:
		PUSH 	ACC
		PUSH 	PSW
		MOV 	TL0, tso_l
		MOV 	TH0, tso_h
		CPL 	play
		POP 	PSW
		POP 	ACC
		RETI		
	E0ISR:
		JNB		P3.2, $
		RETI
		
;---------------------------------------------------------------------------;
	; danh sach cac not nhac	
	CAODO:
		; do(1) re(2) mi(3) fa(4) sol(5) la(6) si(7)
		dw 63625,63834,64019,64104,64261,64400,64524
			
		; do'(8) re'(9) mi'(A)
		dw 64580,64685,64778	
			
;---------------------------------------------------------------------------;
	; sheet nhac
	; xep theo tung cau trong loi bai hat:
	SHEETNHAC:	
		;Happy Birthday to you
		DB 12h,12h,24h,14h,44h,38h
		;Happy Birthday to you	
		DB 12h,12h,24h,14h,54h,48h
		;Happy Birthday, Happy Birthday
		DB 12h,12h,84h,64h,42h,42h,34h,28h
		;Happy Birthday to you
		DB 62h,62h,54h,44h,54h,48h
		DB 0
			
;---------------------------------------------------------------------------;
	EXIT:
END