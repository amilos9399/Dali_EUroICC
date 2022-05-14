	LIST	p=PIC18F13K22
#include <p18f13k22.inc>	


	CONFIG FOSC = IRCCLKOUT, PLLEN = ON, PCLKEN = OFF, FCMEN = OFF, IESO = OFF, PWRTEN = ON, BOREN = SBORDIS, BORV = 22, WDTEN = ON ; WDT is controlled by SWDTEN bit of the WDTCON register
	CONFIG  WDTPS = 1024, MCLRE = OFF, HFOFST = OFF, STVREN = On, LVP = OFF, BBSIZ = OFF, XINST = OFF;, _DEBUG_ON_4L = ON ; Enable Debug Mode
	CONFIG CP0 = ON, CP1 = ON, CPB = ON, WRTD = OFF, CPD = OFF
;	CONFIG4L	_DEBUG_ON_4L	; fosc = IRCCLKOUT

; -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
; definitions
; 	ukoliko je pritisnut prekidac 1a
;	kada dobije 0x80 sledeci bajt se postavlja u adresu DATA 0
;	kada dobije 0x81 sledeci bajt se postavlja u adresu DATA 1

; -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-

; *** PORTS ***

#DEFINE	DaOut				LATC, 4		; RC4 = Dali Out
#DEFINE	DaOutks				LATC, 7		; RC7 = Dali Out baza T za kratki spoj
#DEFINE	DaIn				PORTC, 1	; RC1 = Dali In 
#DEFINE Led_crvena			LATB, 6

#DEFINE Upitaj_All			Flag, 0		; Setuj Pitaj All
#DEFINE Upitaj1				Flag, 1		; Bio Flag8,1 Setuj Upit jednog balasta krenuo
#DEFINE	Zaostao_telegram	Flag, 2		; Zaostao telegram
#DEFINE Pitanje_balastu		Flag, 3		; postavljeno pitanje balastu
#DEFINE Timeout_bal			Flag, 4		; balast ne odgovara timeout
#DEFINE Sledeci_bit			Flag, 5		; Sledeci bit 0 ili 1
#DEFINE Set_postoji			Flag, 6		; Bio Flag6, 1 feedback iz memorije da postoji balast na tek adresi
#DEFINE	U_toku_slanje		Flag, 7 	; slanje u toku
#DEFINE Postoji				Flag1, 0	; Postoji balast informacija iz memorije
#DEFINE Sumnjiv_odg			Flag1, 1	; Sumnjivo za odgovor vise balasta
#DEFINE Setbit				Flag1, 2	; Bio Flag6, 0 setuj da postoji 1 ili ne 0 balast
#DEFINE Odgovor_bal			Flag1, 3	; Postoji odgovor balasta
#DEFINE Jednokratno			Flag1, 4	; Samo pri resetu pokupi balaste posle preskaci
#DEFINE Analiza				Flag1, 5	; Analiza u toku
#DEFINE Zadnji_polubit		Flag1, 6	; Zadnji polubit 1 ili 0
#DEFINE Zategni62			Flag1, 7	; Posle komande i vremena koje drzi Zategni61 posalji upit na balast
										; i cekaj 9ms za odgovor
#DEFINE	Mili750				Flag8, 0	; Proslo X*250 mS
#DEFINE Upisano				Flag8, 1	; Upisana vrednost Milisec -> Mili750
#DEFINE Power_arc			Flag8, 2	; da li je komanda bila Powerarc, ide jos jedna za njom
#DEFINE Posalji232			Flag8, 3	; posalji na 232 All
#DEFINE Overflow			Flag8, 4	; vise od 5 bajtova u poruci
#DEFINE Paket_prvi			Flag8, 5	; proslo 10mS od poslednjeg prijem - prvi bajt paketa
#DEFINE Flag5mS			Flag8, 6	; Pauza u prijemu 232 od 10mS
#DEFINE Paket_kraj			Flag8, 7	; Zavrsen prijem paketa 
#DEFINE Zategni71			Flag5, 0	; Pripremi da krene drugo slanje
#DEFINE Zategni72			Flag5, 1 
#DEFINE Zategni61			Flag5, 2	; Posle komande cekaj vreme 0,75 - 5 sec 
#DEFINE Zategni91			Flag5, 3
;#DEFINE Zategni81			Flag5, 4	; komanda 8 u toku
#DEFINE Zategni92			Flag5, 5
#DEFINE Zategni93			Flag5, 6
#DEFINE Setovan_send232		Flag5, 7
#DEFINE Analiza232			Flag4, 0
#DEFINE Start_poslat		Flag4, 1
#DEFINE I_poslat			Flag4, 2	; Flag 4 se brise komplet ne koristiti za druge stvari
#DEFINE II_poslat			Flag4, 3
#DEFINE III_poslat			Flag4, 4
#DEFINE IV_poslat			Flag4, 5
#DEFINE StopBajti			Flag4, 6	; poslat kraj poruke na 232 0D0A

#DEFINE V_poslat			Flag10, 0

#DEFINE Send232All			Flag6, 0
#DEFINE Poslat_start		Flag6, 1
#DEFINE Send_Stop			Flag6, 2
#DEFINE Sumnjiv_odg2		Flag6, 3	; Sumnjivo za odgovor vise balasta
#DEFINE Kratki_spoj			Flag6, 4
#DEFINE Bafer_pun			Flag6, 5
#DEFINE Obavezan_odgovor	Flag6, 6	; Zategni obavezan odgovor
#DEFINE Zahtev_u_toku		Flag6, 7

#DEFINE PonoviOF			Flag9, 0
#DEFINE Ponovi1C			Flag9, 1
#DEFINE UpitA9				Flag9, 2
#DEFINE EnableDis			Flag9, 3	; Enable disable Sensor pokreta Hevlar
; *** CONSTANTS ***
#DEFINE Vreme1LC	0x00
#DEFINE Vreme1HC	0xff
#DEFINE	BAUD_RATE	0x67
#DEFINE	greska		0x18
#DEFINE Start		0x02  				; startni bajt za 232
#DEFINE Start0E		0x0E

; *** REGISTERS ***
; used by routines

Level0		EQU	0x00
Level1		EQU	0x01
Level2		EQU	0x02
Level3		EQU	0x03
Flag14		EQU	0x04
Level5		EQU	0x05
Level6		EQU	0x06
Level7		EQU	0x07
Level8		EQU	0x08
Level9		EQU	0x09
Level10		EQU	0x0A
Level11		EQU	0x0B
Level12		EQU	0x0C
Level13		EQU	0x0D
Level14		EQU	0x0E
Level15		EQU	0x0F
Level16		EQU	0x10
Level17		EQU	0x11
Level18		EQU	0x12
Level19		EQU	0x13
Level20		EQU	0x14
Level21		EQU	0x15
Level22		EQU	0x16
Level23		EQU	0x17
Level24		EQU	0x18
Level25		EQU	0x19
Level26		EQU	0x1A
Level27		EQU	0x1B
Level28		EQU	0x1C
Level29		EQU	0x1D
Level30		EQU	0x1E
Level31		EQU	0x1F
Level32		EQU	0x20
Level33		EQU	0x21
Level34		EQU	0x22
Level35		EQU	0x23
Level36		EQU	0x24
Level37		EQU	0x25
Level38		EQU	0x26
Level39		EQU	0x27
Level40		EQU	0x28
Level41		EQU	0x29
Level42		EQU	0x2A
Level43		EQU	0x2B
Level44		EQU	0x2C
Level45		EQU	0x2D
Level46		EQU	0x2E
Level47		EQU	0x2F
Level48		EQU	0x30
Level49		EQU	0x31
Level50		EQU	0x32
Level51		EQU	0x33
Level52		EQU	0x34
Level53		EQU	0x35
Level54		EQU	0x36
Level55		EQU	0x37
Level56		EQU	0x38
Level57		EQU	0x39
Level58		EQU	0x3A
Level59		EQU	0x3B
Level60		EQU	0x3C
Level61		EQU	0x3D
Level62		EQU	0x3E
Level63		EQU	0x3F
Mili250		EQU	0x40
Flag		EQU	0x41
DaliH		EQU	0x42
DaliL		EQU	0x43
DaliHt		EQU	0x44
DaliLt		EQU	0x45
Brojac		EQU	0x46		; broj bita za slanje na dali liniji 0 = start bit, 9, 17, 25 stop bit
Temp		EQU 0x47
Flag1		EQU 0x48
RecTime		EQU 0x49
BrojacT		EQU 0x4A		; redni broj bita ili polubita koji se salje
Flag2		EQU 0x4B
DaliHHr		EQU 0x4C
DaliHr		EQU 0x4D		; konacno Dali received H
DaliLr		EQU 0x4E		; Konacno Dali received L
Flag3		EQU 0x4F		; brojac T polovina
Flag4		EQU 0x50
STATUS_COPY	EQU 0x51
W_COPY		EQU 0x52
Timeout		EQU 0x53
Sekund		EQU 0x54
Milisec		EQU 0x55
KSIzlaz		EQU 0x56		; komanda gateway u
DaliH1		EQU 0x57		; Prva rec sa prijema 232 za slanje na Dali
DaliH2		EQU 0x58		; Druga rec za slanje na Dali
DaliH3		EQU 0x59		; Treca rec za slanje na Dali
StatusGW	EQU 0x5A
DaliHHt		EQU 0x5B
DaliHH		EQU 0x5C
Rt1			EQU 0x5D		; prva rec za odgovor
Rt2			EQU 0x5E		; druga rec za odgovor
Pokazivac	EQU 0x5F		; pokazivac reci 
Flag5		EQU 0x60
Brojackom	EQU	0x61		; vreme od slanja do sledeceg slanja
kratkispoj	EQU 0x62
Vreme5mS	EQU 0x63
Flag6		EQU	0x64
Flag7		EQU	0x65
Flag8		EQU 0x66
BrojacAll	EQU 0x67
AdresaAll	EQU 0x68
Temp2		EQU	0x69
MaxAdr		EQU 0x6A
F0do7		EQU 0x6B		; DALI adresa popunjena 1 ili slobodna 0
F8do15		EQU 0x6C		; 8 bajta 64 bita 64 adrese
F16do23		EQU 0x6D
F24do31		EQU 0x6E
F32do39		EQU 0x6F
F40do47		EQU 0x70
F48do55		EQU 0x71
F56do63		EQU 0x72
VrememS		EQU 0x73
BSR_TEMP	EQU 0x74
Brojackom7	EQU	0x75
DaliL1		EQU 0x76
DaliL2		EQU 0x77
DaliL3		EQU 0x78
FSR0L_T		EQU 0x79
Duzina232	EQU	0x7A
Brojac232S	EQU 0x7B
Temp3		EQU 0x7C
DaliHupit	EQU 0x7D
Flag9		EQU 0x7E
Flag10		EQU 0x7F
I			EQU 0x80			; pointer bafer 1 prva
II			EQU 0x81			; pointer prijem sa 232 druga
III			EQU 0x82			; pointer prijem sa 232 treca
IV			EQU	0x83			; pointer prijem sa 232 cetvrta
V			EQU 0x84			; pointer prijem sa 232 peta
Odg_vise_balasta	EQU 0x85	; odgovor vise balasta 0x94 Visak ivica, 0x95 trajanje bita izvan limita
DaliHupit_odg	EQU 0x86

X8A			EQU 0x8A			; prva adresa prijem 232 slede 2.,3.,4,.i 5ti bajt poruke 
X8B			EQU 0x8B
X8C			EQU 0x8C
X8D			EQU 0x8D
X8E			EQU 0x8E

X8F			EQU 0x8F			; druga adresa prijem sa 232
X90			EQU 0x90
X91			EQU 0x91
X92			EQU 0x92
X93			EQU 0x93

X94			EQU 0x94			; treca
X95			EQU 0x95
X96			EQU 0x96
X97			EQU 0x97
X98			EQU 0x98

X99			EQU 0x99			; cetvrta
X9A			EQU 0x9A
X9B			EQU 0x9B
X9C			EQU 0x9C
X9D			EQU 0x9D

X9E			EQU 0x9E			; peta adresa
X9F			EQU 0x9F
XA0			EQU 0xA0
XA1			EQU 0xA1
XA2			EQU 0xA2



RS2321		EQU 0xAA		; bafer 2 pointer 1. adresa
RS2322		EQU 0xAB		; bafer 2 pointer 2. adresa
RS2323		EQU 0xAC		; bafer 2 pointer 3. adresa
RS2324		EQU 0xAD

XB1			EQU 0xB1		; bafer 2 prva adresa
XB2			EQU 0xB2
XB3			EQU 0xB3
XB4			EQU 0xB4
XB5			EQU 0xB5

XB6			EQU 0xB6		; bafer 2 druga adresa
XB7			EQU 0xB7
XB8			EQU 0xB8
XB9			EQU 0xB9
XBA			EQU 0xBA

XBB			EQU 0xBB		; bafer 2 treca adresa
XBC			EQU 0xBC
XBD			EQU 0xBD
XBE			EQU 0xBE
XBF			EQU 0xBF

; 
;;; -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
; T;his is the begin of the main loop code
; -*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-*-
	ORG 0x00000		; reset vector
	goto 	_ini

	org	0x00008	; Interrupt vector high priority
	movff	FSR0L, FSR0L_T
	goto 	_inthigh

	org	0x00018	; Interrupt vector
;	bcf		INTCON, GIEH
	movwf	W_COPY
	movff	STATUS, STATUS_COPY 		; Store Data
  	movff	BSR, BSR_TEMP 				; 
	goto 	_intlow


; ---------------- _ini ----------------------------------------
;
; Initialisation of the I/O ports and several variables that are 
; used throughout the program, also clears ram locations
; postaviti PR2 prilikom receiva i transmita, 104 odnosno 255
; ---------------------------------------------------------------
_ini	
	bcf		OSCCON2, PRI_SD		; Iskljuci primarni osc
	movlw	b'01110000'			; postavi brzinu na 16MHz x 4, 62,5 nsec po instrukciji
	movwf 	OSCCON
_osclock
	btfss	OSCCON, HFIOFS		; Stabilizacija clocka
	goto	_osclock
	clrwdt
	clrf	PORTC	
	clrf	PORTB	
	clrf	PORTA
								;	Banksel LATA	;	Bank4
	clrf 	LATA
	clrf 	LATB
	clrf 	LATC				; Set up I/O ports A & B
								;	clrf	Char00	
	movlw	b'11111010'			; RA0  izlaz za Ref napon, RA2 izlaz komparatora 1
	movwf	TRISA				; set input(1), output(0))
	movlw	b'00101111'
	movwf	TRISB
	movlw	b'01100010'
	movwf	TRISC	
	bcf		DaOutks
	bsf		DaOut			; promenjeno sa bcf zbog nove seme
	movlw	0x0F		; iskljuci AD konverter
	movwf	ADCON1
	
; ====Postavi timere
; Timer0 ===  meri od 0 do 1020 usec, sa interaptom trajanje prijema bita na Daliju
; Prescaler 64,  8 bitni timer 255*4usec High interapt
	movlw	b'11000101'		; ukljuci T0, 8 bit, int clock PSA=1 prescaler 64 (101)
	movwf	T0CON
	bcf		INTCON, TMR0IE		; onemoguci interapt
	bsf		INTCON2, TMR0IP		; high interapt

; Timer1 == meri 1ms Low interapt
	movlw	b'10010101'		; ukljuci T1 i postavi Presc 2 , int clock
	movwf	T1CON
	bsf		PIE1, TMR1IE		; omoguci  Low interapt od timera1
	bcf		IPR1, TMR1IP
	
; Timer2 == meri 416usecmsec od poslednje komande ima interapt
; T2ON, Prescaler 1:16, Postscale 1:2, max vreme 255*2=512usec, PR2 206 za 412
	movlw	b'00001011'				; 
	movwf	T2CON				;===== T2 IMA interapt 
	movlw	d'206'		; 	postavi timer 2 na 412usec
	movwf	PR2
	bsf		PIE1, TMR2IE
	bcf		IPR1, TMR2IP		;low interapt
	
; T3 === meri 10msec od poslednje komande, interapt ukoliko nije poslata Dh Dl (Zaostao_telegram = 1)
	movlw	b'10110101'		; ukljuci T3 i postavi Presc 8 , int clock
	movwf	T3CON
	movlw	0xB1
	movwf	TMR3H
	clrf	TMR3L
	
	clrf	ANSEL
	clrf	ANSELH		; iskljuci analogne funkcije na pinovima
	bsf		ANSEL, ANS5		; UKLJUCI ulaz za komparator
	bsf		ANSEL, ANS0	

	bcf		RCSTA, CREN			; Reset Communications
	movlw	0x90
	movwf	RCSTA
;	movlw	0x34
	movlw	BAUD_RATE			; Load the baud rate 0x34
;	banksel	TXSTA				; ** Select bank 1 **
	movwf	SPBRG	
	movlw	0x20
	movwf	TXSTA			; Setup serial port send	
;	banksel	PORTA				; ** Select bank 0 **

	bcf		RCSTA, CREN			; Reset Communications
	bsf		RCSTA, CREN

	movf	RCREG, W			; Clear FIFO

	clrf	FSR0L		; initialize pointer
	Banksel 0
_brisi	
	clrf	INDF0		; clear indf0 register
	incf	FSR0L, F		; increase pointer
	movlw	0xC0
	cpfseq	FSR0L
	goto	_brisi
;	clrf	INTCON2

	bsf		RCON, IPEN			; enable priority levels	
	clrf	FSR1H
	clrf	INTCON3
	movlw	b'01110000'			; b'01000000' za EURO ICC b'01110000' za komunikaciju sa PC Portom
	movwf	BAUDCON
	bsf		INTCON, GIEH			
	bsf		INTCON, GIEL
	clrf	IOCA
	clrf	IOCB
	movlw	b'10110000'			; 4096 pri 5V PS
;	movlw	b'10100000'			; 2.048V umesto 4.096 zbog napajanja 3.3 V
	movwf	VREFCON0
	movlw	b'11001000'			; 5.ti bit izlaz na RA0 ref napona
	movwf	VREFCON1
;	movlw	b'11111110'			; 30->11111110= 30/32*2.048=1.92V? 
	movlw	b'00011110'			; 30->00010110= 30/32*4.096=3.328 V?  sa 33K 13,4V je granica, 4.71V je pri 19V
	movwf	VREFCON2
	movlw	b'10111101'
	movwf	CM1CON0
	movlw	b'00000000'
	movwf	CM2CON0
	movlw	b'00011100'
	movwf	CM2CON1	
	movf	CM1CON0, W		; Dummy citanje
	bcf		PIR2, C1IF	
	bsf		PIE2, C1IE
	bsf		IPR2, C1IP


	movlw	0x00				; uzmi grupnu ili short adresu iz mem lokacije XX; 
	movwf 	EEADR		 		; 00000011 je grupna adresa 1, a 10000011 je short adresa 1 
	bcf 	EECON1, EEPGD 		; Point to DATA memory
	bcf 	EECON1, CFGS 		; Access EEPROM
	bsf 	EECON1, RD 			; EEPROM Read
	movf 	EEDATA, W 			; W = EEDATA	
	movwf	Flag9

;	clrf	Flag9		; proba sa slanjem ALL!!!!!!!!!!
	clrwdt	
;	clrf	Flag8				; postavi sve adrese slobodne za bafer
	movlw	0xFB
	movwf	TMR1H
	clrf	TMR1L
	
	clrf	TMR0L
	clrwdt
	movlw	0x10
	movwf	StatusGW			; Postavi status.
	movlw	0x04
	movwf	Temp			; Postavi temp poc.	
	bsf		DaOut			; Novo dodato ya novu semu EUROICC podigni DALI liniju u start up u
	movlw	0x08
	movwf	Temp2
	movlw	0x6B
	movwf	FSR0L	
_setovanje					; podigni svih 64 bita na 1 
	setf	INDF0
	incf	FSR0L
	decfsz	Temp2	
	goto	_setovanje
	call	 _pitajAll	
;	movlw	0x0A
	clrf	Vreme5mS			; Postavi temp poc.	





;-------------glavna petlja--------------;



_main			

;===============  Prekidac P1, P2 On/OFF  =====================
; Pitanje_balastu	 Poslat zahtev balastu za stanje ili vrednost adrese
; Flag1, 1 proslo 9 mS od zahteva balastu
; Odgovor_bal Odgovor balasta postoji 8 bitni bio Flag1, 2
; Sumnjiv_odg Sumnjivo za odgovor vise balasta odjednom Flag1, 3
; Flag1, 4 Timeout sledeceg bajta sa 232 porta 3mS
; Flag1, 5 Prosla nepoznata komanda zapocni sekvencu upita svih balasta
; Flag1, 6 Prosla komanda na short adresu posalji upit
; Flag1, 7 Prosla jos jedna komanda na short adresu a prethodna nije upitana- upitaj ALL
; TMR1 meri 18 msec za odgovor na pitanje o statusu (max 10ms + 8.4 ms za prijem 8+1+1 bita
; 
; TMR2 meri 412 usec od poslednje komande
; TMR0 meri 0 do 4*255 1020 usec max
; TMR3 meri 10ms usec pri transmitu
;	Vreme za cekanje 9mS tajmaut
; Vreme za cekanje na sledeci bajt za slanje NE TREBA MOZE ODMAH
; Flag, 1 Dali izlaz High moze se testirati da li drugi salju
; Zaostao_telegram Telegram pripremljen za slanje 1, telegram poslat kompletno 0
; Flag, 3 Kolizija na busu
; Flag, 4 PROSLO 10MS
; Flag, 5 proslo 416 usec
; Sledeci_bit zadato stanje DaOut ako je 0 DaOut kada istekne 
; U_toku_slanje Ima jos bita slanje u toku U_toku_slanje
; Flag3  broj poluciklusa

; Zategni62	Vrati se na 61 posle slanja - set
; Flag5, 1 	Kratki spoj u toku
; 
; Flag5mS  Da li je proslo 10mS od prethodnog bajta na 232
; Paket_prvi Poceo prijem paketa bajtova bio Flag5, 4
; Zategni71 Vrati se na 71 posle slanja 7
;
; Paket_kraj Primljen paket moze analiza
; Setbit Setuj 1, resetuj 0 jedan od 64 bita (bio 6, 0)
; Set_postoji Ispitaj: Setovan 1, resetovan 0 jedan od 64 bita bio (6, 1)
; Timeout_bal Time out za odgovor balasta
; Flag6, 3 Setuj pitanje jednom balastu
; Jednokratno Pri ukljucenju zapamti koji balasti postoje, kasnije ne diraj bio Flag6, 4
; Zadnji_polubit Poslednji polubit
; Flag7, 1 Zavrsena kom 6 moze 61 da krene u +20mS
; Zategni72 Zavrsena kom 7 moze 71 da krene u +20mS
; Zategni82 Zavrsena kom 8 moze 81 da krene u +20mS
; Upitaj_All Pitaj All bio 8, 0
; Upitaj1 Setovan upit jednog balasta bio Flag8, 1
; Flag8, 2-6 Slobodno mesto 1-5 za upis sa 232
;=============================================================
; pitanje ima li nesto sa Dali prijema
; ako ima da li je odgovor, posalji na 232
; ima li nesto za slanje na Dali?
; ima li nesto sa 232, ako ima proveri sta treba sa time raditi
	
		call	_prijem
		clrwdt
		btfss	Send_Stop			; Da li su ostali Stop bajti za slanje od Send ALL
		goto	_All				; Nisu, probaj Salji Sve
		btfss	TXSTA, TRMT			; Da jeste, moze li transmit jednog (dva) bajta?
		goto	_Pitanje					; ne jos
		movlw	0x0D				; moze salji 0D 0A
		movwf	TXREG
		movlw	0x0A
		movwf	TXREG
		bcf		Send_Stop
		goto	_Salji232			; zavrseno sa SendAll probaj Salji232
_All
		btfss	Send232All			; Da li je setovan salji sve
		goto	_Salji232				; nije
		btfss	TXSTA, TRMT			; Da jeste, moze li transmit jednog (dva) bajta?
		goto	_Pitanje					; ne jos
		btfss	Poslat_start		; Da li je poslat Start bajt
		goto	_Saljistart			; nije
		call	_salji232All		; jeste salji ostale
		goto	_Pitanje			; preskoci pojed slanje

_Saljistart							; Start bajt za Slanje All
		movlw	Start
		movwf	TXREG
		bsf		Poslat_start
		movlw	Start0E
		movwf	TXREG
		goto	_Pitanje

_Salji232
		movf	RS2321, W			; ima li sta za transmit?
		bz		_Pitanje			; nema
		call	_send232			; ima pozovi PP
	;	goto	_Pitanje

_Pitanje
		btfss	Pitanje_balastu		; Da li je bilo pitanje balastu		
		goto	_nastavi			; ne nije			
									; jeste
									
									
		btfsc	Sumnjiv_odg2		; Da li je bio sumnjiv odgovor
		goto	_sumnjivo2			; jeste
									; nije
		btfss	Timeout_bal			; Da li je bio tajmout za odgovor balasta?
		goto	_nastavi			; nije
									; jeste
;		bcf		Zategni61
;		bcf		Zategni62
		bcf		Pitanje_balastu
		bcf		Timeout_bal
		btfss	Obavezan_odgovor
		goto	_JednokratnoA
		
		call	_odgovor
		goto	_nastavi


_JednokratnoA
	
		movlw	0x80
		cpfslt	DaliHupit
		goto	_sumnjivo2

		movf	DaliHupit, W
		bcf		WREG, 0
		rrncf	WREG, W
		movwf	FSR0L
		setf	INDF0

		btfsc	Jednokratno		; kada zavrsi prvi put pitaj All preskaci resetovanje bita
		goto	_saljiNemaBalasta

		call	_resetujbit		; ostaje kao na prvom kupljenju
		btfss	Upitaj_All
		bsf		Jednokratno		; samo pri start up u prode ovde i više ne
		goto 	_sumnjivo2

_saljiNemaBalasta
		call	_bafer2
		movlw	0x03						; broj bajtova za slanje bez start i stop
		movwf	INDF0
		incf	FSR0L
		movlw	0xFE						; I bajt FE
		movwf	INDF0
		incf	FSR0L
		clrf	INDF0						; II bajt 00
		incf	FSR0L
		
		movf	DaliHupit, W					; III bajt							
		bcf		WREG, 0						; izvuci adresu -1 /2
		rrncf	WREG, W		

		btfsc	UpitA9				
		movf	DaliHupit_odg, W
		movwf	INDF0						; III bajt SA DaliHupit	
		bcf		UpitA9		


_sumnjivo2
		btfss	Timeout_bal			; Da li je bio tajmout za odgovor balasta?
		goto	_nastavi			; nije
		bcf		Timeout_bal
		btfss	Sumnjiv_odg2					; primljeno, da li je sumnjivo
		goto	_nastavi	
		
		call	_bafer2
		movlw	0x03						; broj bajtova za slanje bez start i stop
		movwf	INDF0
		incf	FSR0L
		movlw	0xFE						; I bajt
		movwf	INDF0
		incf	FSR0L
		setf	INDF0						; II bajt FF
		incf	FSR0L
			
		movf	Odg_vise_balasta, W						; III bajt Odg_vise_balasta
								   
		movwf	INDF0		
	 	bcf		Sumnjiv_odg2
		bcf		Sumnjiv_odg
		bcf		Pitanje_balastu			; posto je dobijen sumnjiv odgovor zaboravi pitanje balastu
		bcf		Obavezan_odgovor		; posto je dobijen sumnjiv odgovor zaboravi obavezan odgovor
		
_nastavi
		btfsc	U_toku_slanje				; ima jos bita za slanje na Dali, u toku?	
		goto	_main				; Da slanje u toku u interaptima nema vremena za druge sem prijema sa 232
									; Ne slanje jos nije pocelo ispitaj da li ima sadrzaj za slanje	
		btfss	PIR2, TMR3IF		; salji kad se oslobodi linija + 10ms (interapt T3)
		goto	_nastavi2
	
		btfsc	Zaostao_telegram				; zaostao telegram x bitni?
		call	_saljiDhDl			; salji sa prethodnim podesenjima
	
_nastavi2
								; Da li je bio u toku prijem paketa
		btfss	Paket_prvi			; da li je u toku prijem paketa bajtova							
		goto	_isteklo10mS			; nije
		btfsc	Flag5mS			; Da li je zavrsen prijem paketa, proslo 10mS od preth bajta
		call	_krajpaketa			; jeste

_isteklo10mS
		movlw		0x05
		cpfslt		Vreme5mS
		bsf			Flag5mS

		btfsc	Zaostao_telegram				; zaostao telegram x bitni?
		goto 	_main			; vrati se dok ne posaljes



_probaj91
		btfss	Zategni92			; da li treba da se vrati na 92 posle slanja?
		goto	_probaj92			; ne treba produzi
		movlw	0x0A				; Treba ali jos 10mS
		cpfsgt	Brojackom
		goto	_main			; jos nije proslo 20mS
		movff	DaliH2, DaliH
		movff	DaliL2, DaliL
	
		movlw	0x22				; salji 16 bita -  34 polubita zapravo 35 sa jednim stop
		movwf	Brojac
		call	_saljiDhDl			; primljeno sve posalji na dali i izadji 
;		clrf	Brojackom			; Resetuj Brojackom
		goto	_main

_probaj92
		btfss	Zategni93			; da li treba da se vrati na 93 posle slanja?
		goto	_probaj71			; ne treba produzi
		movlw	0x0A				; Treba ali jos 10mS
		cpfsgt	Brojackom
		goto	_main			; jos nije proslo 10mS
		movff	DaliH3, DaliH
		movff	DaliL3, DaliL
	
		movlw	0x22				; salji 16 bita -  34 polubita zapravo 35 sa jednim stop
		movwf	Brojac
		call	_saljiDhDl			; primljeno sve posalji na dali i izadji 
;		clrf	Brojackom			; Resetuj Brojackom
		bcf		Zategni93
		goto	_main

_probaj71
		btfss	Zategni72			; da li treba da se vrati na 71 posle slanja?
		goto	_probaj81			; ne treba produzi
		movlw	0x14				; Treba ali jos 20mS
		cpfsgt	Brojackom7
		goto	_probaj81			; jos nije proslo 20mS
		call	_kom71				; proslo je idi na 71
		goto	_main

_probaj81
	;	btfss	Zategni82			; da li treba da se vrati na 81 posle slanja?
	;	goto	_pitaj1balast			; ne treba produzi
	;	call	_kom81				; proslo je idi na 81
	
		movf	II, W				; Druga adresa postoji moze analiza na prvoj
		bz		_Krajpaketa		; Druga je 0 proveri da li je zavrsen paket na prvoj
	;	btfss	Analiza				; Analiza u toku?
		call	_analiza			; nije
		goto	_main		; Jeste

_Krajpaketa
		movf	I, W
		bz		_pitaj1balast
		btfss	Paket_kraj			; Da li moze analiza?
		goto	_pitaj1balast		; ne moze
		call	_analiza
		goto	_main
	
_pitaj1balast
		btfss	Zategni61			; postavi pitanje jednom balastu?
		goto	_probajdalje
;________________________________________________________
_Upitajjedan	
		btfsc		U_toku_slanje				; ima jos bita za slanje na Dali, u toku?	
		goto		_main				; Da slanje u toku u interaptima nema vremena za druge sem prijema sa 232
	
	; cekaj 750msekunde			; jeste ali cekaj 750mS
	
		btfsc		Mili750				; Da li je proslo 750ms? 
		goto		_Proslo7501 
	
		btfsc		Upisano			; da li je upisano da je Mili750 prebaceno u VrememS
		goto		_Upisano
		bsf			Upisano
		clrf		Mili250
	
_Upisano
		movlw		0x02
		btfsc		Power_arc		; Da li je poslednja komanda bila dim up ili down na max ili min
		addlw		0x0F

		cpfsgt		Mili250	
		goto		_probajdalje
		bsf			Mili750
	;	goto		_Proslo750

_Proslo7501	
	;	movlw	0x14				; Treba ali jos 20mS
	;	cpfsgt	Brojackom
	;	goto	_main	; jos nije proslo 20mS

		movff		DaliHupit, DaliH
		btfsc		Power_arc
		bsf			DaliH, 0			; s=1 komanda
		bcf			Power_arc	
;		bsf			Upitaj1				; Nije, setuj upit tekuceg (jednog) balasta
		bcf			Zategni61
		bsf			Zategni62			; Setuj Pitanje balastu posle zavrsene komande
		movlw		0xA0
		movwf		DaliL
		movlw		0x22
		movwf		Brojac	
		call		_saljiDhDl
	;	goto		_izadji64
		clrf		Brojackom
		bcf			Upisano
	;	goto	_main
;______________________________________________________	

_probajdalje	

_lokalnakom					
		;btfss	Flag1, 6			; da li je bio telegram ka short adresi u lokalu (sa prekidaca)
		;goto	_UpitajSve	
		;bcf		Flag1, 6
	
		;movlw	0x93				; status
		;movwf	DaliL				; posalji upit statusa za adresu DaliH
		;movff	DaliHr, DaliH
		;movlw	0x22				; postavi duzinu reci za slanje
		;movwf	Brojac
		;call	_saljiDhDl
		;bsf		Pitanje_balastu			; setuj pitanje balastu
		;clrf	Brojackom			; resetuj vreme do odgovora
	

_UpitajSve	
		btfsc		U_toku_slanje				; ima jos bita za slanje na Dali, u toku?	
		goto		_main				; Da slanje u toku u interaptima nema vremena za druge sem prijema sa 232
	
		btfss		Upitaj_All 			; Da li je setovan Pitaj All
		goto		_bafer_nije_pun				; nije probaj dalje
	; cekaj 750msekunde			; jeste ali cekaj 750mS
	
		btfsc		Mili750				; Da li je proslo 750ms? 
		goto		_Proslo750 
	
		btfsc		Upisano			; da li je upisano da je Mili750 prebaceno u VrememS
		goto		_Upisano1
		bsf			Upisano
		clrf		Mili250
	
_Upisano1
		movlw		0x02
		btfsc		Power_arc		; Da li je poslednja komanda bila dim up ili down na max ili min
		addlw		0x0F
	
		cpfsgt		Mili250	
		goto		_main
		bsf			Mili750
	;	goto		_Proslo750


_Proslo750	
		bcf			Power_arc	
		btfsc		Upitaj1			; da li je setovan upit jednog balasta
		goto		_main				; Jeste izadji
									; Nije ali cekaj jos 20ms
					; Da li je bio odgovor ili isteklo vreme na prethodni upit
	
		movlw		0x14				; Treba ali jos 20mS
		cpfsgt		Brojackom
		goto		_main	; jos nije proslo 20mS

_novi_balast
		movf		BrojacAll, W
		bcf			STATUS, C
		rrcf		WREG, F
		call		_Dalijeset
	
		btfss		Set_postoji
		goto		_nemabalasta
		
		bsf			Upitaj1				; Nije, setuj upit tekuceg (jednog) balasta
	
		bsf			Zategni62			; Setuj Pitanje balastu posle zavrsene komande
		movf		BrojacAll, W
		movwf		DaliH
		movwf		DaliHupit
		movlw		0xA0
		movwf		DaliL
		movlw		0x22
		movwf		Brojac	
		call		_saljiDhDl
	;	goto		_izadji64
		clrf		Brojackom
		dcfsnz		BrojacAll
		goto		_izadji64
		dcfsnz		BrojacAll
		goto		_izadji64
		goto		_main

_izadji64	
		bcf			Upitaj_All			; izadji posle 64 adrese
		bcf			Upisano
		bcf			Mili750	
	;	movlw	0x40			; slanje je pozurilo jer zadnji (0) balast nije ni dobio pitanje
	;	movwf	Brojac232S
	;	bsf		Send232All
		goto		_main	

_nemabalasta					; nema balasta probaj sledeci novi_balast
		dcfsnz		BrojacAll
		goto		_izadji64
		decf		BrojacAll	
		goto		_novi_balast
;_______________________________________

_bafer_nije_pun
		btfss	Bafer_pun
		goto	_main
		movf	II, W
		bz		_moze_prijem
		goto	_main
		
_moze_prijem						; bafer ima ponovo 4 slobodna mesta, moze da se nastavi prijem
		call	_bafer2
		movlw	0x01						; broj bajtova za slanje bez start i stop
		movwf	INDF0
		incf	FSR0L
		movlw	0x17						; posalji 17H da se nastavi prijem
		movwf	INDF0
		bcf		Bafer_pun
		goto	_main			


;=============================================================================
; 	POTPROGRAMI
;=============================================================================
	
_prijem
		btfss	RCSTA, OERR		; resetuj overun
		goto	_Prijem1
		bcf		RCSTA, CREN		; resetuj overun
		bsf		RCSTA, CREN
_Prijem1
		btfss 	PIR1, RCIF			; ima li primljenog bajta na 232
		return						; nema vrati se
	
		btfss	RCSTA, FERR			; Ima, Da li je bilo greske u prijemu
		goto	_bezgreske			; Nema greske
		movf	RCREG, W			; Ima greske, ocitaj i izadji i posalji 0x11
		bsf		StatusGW, 0			; postavi status greska u prijemu
		movf	StatusGW, W	

 		call	_Salji_status
		
		clrf	Vreme5mS			; pocni merenje vremena do sledeceg bajta
		bcf		Flag5mS			; resetuj 10mS
		return

	
_bezgreske

	;	bcf		Paket_kraj			; ne moze analiza prijem krenuo
		btfsc	Flag5mS			; Da li je proslo 10mS od prethodnog
		goto	_proslo				; Da proslo je - Prvi bajt npr 06
		btfsc	Overflow			; da li je bio overload, vise od 5 bajtova u poruci?
		return						; jeste vrati se dok ne dodje sledeci paket	
		clrf	Vreme5mS	; nije zategni 10mS i kad istekne setuj Flag5mS
		bcf		Flag5mS			; resetuj 10mS
		dcfsnz	Temp				; pazi de se ne predje u sledeci paket max 5 bajta
		goto	_overload			; prelazi u sledeci paket, greska
		incf	FSR2L				; sve ok upisi u sledecu mem lokaciju
		movlw	0x89
		cpfsgt	FSR2L
		goto	_intgreska		; interna greska izasao izvan granica FSR2L
		movlw	0xA3
		cpfslt	FSR2L
		goto	_intgreska
		movff	RCREG, INDF2
		return

_intgreska
		movlw	greska
		movwf	StatusGW
 		call	_Salji_status
		clrf	Vreme5mS
		bcf		Flag5mS		; resetuj 5mS
_reset_petlja					; sacekaj da se posalje greska 10 mS i izadji resetuj se
		movlw	0x05
		cpfsgt	Vreme5mS
		goto	_reset_petlja
		reset

	;return

_overload	
	;
		movf	RCREG, W		; vise od 5 bajtova u poruci, greska

		call	_bafer2						; posalji odgovor na 232
		movlw	0x01					; duzina 1 bajt za slanje na 232
		movwf	INDF0
		incf	FSR0L
		movlw	0x14			; nema mesta posalji bafer pun
		movwf	INDF0			; 
		incf	Temp			; vrati pokazivac na isti bajt
		clrf	Vreme5mS
		bcf		Flag5mS		; resetuj 10mS
		bsf		Overflow		; greska vise od 5 bajtova
	;
		return		; cekaj da se pojavi novi prvi bajt, sve ostale otkazi
	
_proslo							; proslo 10mS, ovo je prvi bajt poruke	
		bsf		Paket_prvi			; Prvi bajt paketa primljen
		clrf	Vreme5mS
		bcf		Flag5mS			; resetuj 10mS
		movlw	0x04			; postavi Temp na 4 (5 bajta)i pazi da se ne predje
		movwf	Temp
		bcf		Overflow		; izadji iz overflow
		call 	_bafer			; pozovi potprogram za smestaj, vrati se sa FSR2L gde je smesten 1. bajt
	
		return
;===========================================================================
_salji232All
	;	movf	Brojac232S, W	; proveri ima li balasta na adresi Brojac232S
;		movwf	Temp3
		btfss	TXSTA, TRMT			; moze li transmit jednog (dva) bajta?
		return	
		decf	Brojac232S, W				; ne jos
		call	_Dalijeset
		btfss	Set_postoji
		goto	_Nema_ga

		decf	Brojac232S, W
		movwf	TXREG
		movwf	FSR0L
		movff	INDF0, TXREG

		dcfsnz	Brojac232S, F	; Ovde je zadnji balast 1, treba jos za nulu da prodje
		goto	_Kraj232Send

		return

_Nema_ga

	;	decf	Brojac232S, W
	;	movwf	TXREG
	;	movwf	FSR0L
	;	setf	TXREG
		decfsz	Brojac232S, F	; Ovde je zadnji balast 1 , treba jos za nulu da prodje
;		goto	_salji232All

		return

_Kraj232Send
		bcf		Poslat_start
		bcf		Send232All
		bsf		Send_Stop
		return
;=========================================================================
_odgovor
		bcf		Obavezan_odgovor
		call	_bafer2
		movlw	0x03						; broj bajtova za slanje bez start i stop
		movwf	INDF0
		incf	FSR0L
		movlw	0xFE						; I bajt FE
		movwf	INDF0
		incf	FSR0L
		clrf	INDF0						; II bajt 00
		incf	FSR0L		
		movf	DaliHupit, W					; III bajt							
		bcf		WREG, 0						; izvuci adresu -1 /2
		rrncf	WREG, W		
		btfsc	UpitA9				
		movf	DaliHupit_odg, W
		movwf	INDF0						; III bajt SA DaliHupit	
		bcf		UpitA9	
	 
	  
		
			 
	 
		return
;=================================================================================_send232
_send232

		btfss	TXSTA, TRMT			; moze li transmit jednog (dva) bajta?
		return						; ne jos
		movff	RS2321, FSR0L
		btfsc	StopBajti
		goto	_0D1
		btfsc	Start_poslat		; moze, Da li je start poslat?
		goto	_I_bajt				; jeste salji I bajt
		movlw	Start
		movwf 	TXREG		; nije poslat start, salji i postavi duzinu slanja
		bsf		Start_poslat
		movff	INDF0, Duzina232	; prvi bajt je duzina
		return

_I_bajt
		incf	FSR0L
		btfsc	I_poslat
		goto	_II_bajt
		movff	INDF0, TXREG
		bsf		I_poslat
		dcfsnz	Duzina232
		bsf		StopBajti
		return

_II_bajt
		incf	FSR0L
		btfsc	II_poslat
		goto	_III_bajt
		movff	INDF0, TXREG
		bsf		II_poslat
		dcfsnz	Duzina232
		bsf		StopBajti
		return

_III_bajt
		incf	FSR0L
		btfsc	III_poslat
		goto	_IV_bajt
		movff	INDF0, TXREG
		bsf		III_poslat
		dcfsnz	Duzina232
		bsf		StopBajti
		return

_IV_bajt
		incf	FSR0L
		btfsc	IV_poslat
		goto	_0D1
		bsf		StopBajti
		movff	INDF0, TXREG
		bsf		IV_poslat
		return

_0D1
		btfsc	V_poslat
		goto	_0A1
	;	bsf		StopBajti
	
		movlw	0x0D
		movwf	TXREG
		bsf		V_poslat
		return

_0A1
		movlw	0x0A
		movwf	TXREG
		bcf		Start_poslat

		bcf		StopBajti
		movff	RS2321, FSR0L
		
		clrf	INDF0
		incf	FSR0L
		clrf	INDF0
		incf	FSR0L
		clrf	INDF0
		incf	FSR0L
		clrf	INDF0
		incf	FSR0L
		clrf	INDF0
		movff	RS2322, RS2321
		movff	RS2323, RS2322
		clrf	RS2323
		clrf	Flag4			; kraj analize
		bcf		V_poslat

		return

;============================================================================
		
_bafer			; bafer za prijem sa 232

		movf	I, W			; adresa 1. za izvrsenje, u I se nalazi adresa pocetka paketa
		bz		_Prva			; Da li je slobodna prva adresa za smestaj prijema sa 232? 
								; kada se zavrsi izvrsenje sve adrese idu na gore, nula na kraju,
								; prazni adrese i oslobadja ih
		movf	II, W			; adresa 2. za izvrsenje
		bz		_Druga
		movf	III, W			; adresa 3. za izvrsenje
		bz		_Treca	
		movf	IV, W			; adresa 4. za izvrsenje
		bz		_Cetvrta	
; posalji pun bafer i primi paket u mesto broj 5
		call	_bafer2		
		movlw	0x01		; duzina 1 bajt za slanje na 232
		movwf	INDF0
		incf	FSR0L
		movlw	0x19		; Bafer pun
		movwf	INDF0			;
		bsf		Bafer_pun

		movf	V, W			; adresa 5. za izvrsenje
		bz		_Peta	
		; ako i dalje dolaze paketi, nema mesta postavi ih ponovo u polje V
		movwf	FSR2L
		movff	RCREG, INDF2
	
 	
	
		return	


_Prva						; Prva poruka u prijemu
		call	_nadjimesto
		movwf	I	
		movff	RCREG, INDF2
		return
_Druga
		call	_nadjimesto
		movwf	II
		movff	RCREG, INDF2
		return
_Treca
		call	_nadjimesto
		movwf	III
		movff	RCREG, INDF2
		return
_Cetvrta
		call	_nadjimesto
		movwf	IV
		movff	RCREG, INDF2
		return
_Peta
		call	_nadjimesto
		movwf	V
		movff	RCREG, INDF2
		return
	

_nadjimesto
		movf	X8A, W		; odredjuje gde je sl mesto (0), Slobodno mesto 8A	
		bnz		_8F
		movlw	0x8A
		movwf	FSR2L
		return
_8F
		movf	X8F, W
		bnz		_94
		movlw	0x8F
		movwf	FSR2L	
		return	
_94
		movf	X94, W
		bnz		_99	
		movlw	0x94
		movwf	FSR2L	
		return			
_99	
		movf	X99, W
		bnz		_9E	
		movlw	0x99
		movwf	FSR2L
		return		
_9E	
		movf	X9E, W
		bnz		_nemamesta
		movlw	0x9E
		movwf	FSR2L
		return		
	
_nemamesta	
		call	_bafer2						; posalji odgovor na 232
		movlw	0x01					; duzina 1 bajt za slanje na 232
		movwf	INDF0
		incf	FSR0L
		movlw	0x1B			; nema mesta posalji bafer pun i postavi u poslednje mesto
		movwf	INDF0			; 
		movlw	0x9E
		movwf	FSR2L
		return		
		
_krajpaketa
		movlw	0x05
		movwf	Temp
		bsf		Paket_kraj		; moze analiza
		bcf		Paket_prvi		; prvi bajt paketa posle 10mS - greska ovaj flag nije kraj paketa	
		return 					;goto	_main

;======================================================================================

_bafer2			; bafer za slanje na 232

		movf	RS2321, W			; adresa 1. za izvrsenje
		bnz		_Druga2			; Da li je slobodna prva adresa? 
								; kada se zavrsi izvrsenje sve adrese idu na gore, nula ne kraju,
								; prazni adrese i oslobadja ih
		call	_nadjimesto2
		movwf	RS2321	
		return

_Druga2
		movf	RS2322, W			; adresa 2. za izvrsenje
		bnz		_Treca2
		call	_nadjimesto2
		movwf	RS2322	
		return
_Treca2
		movf	RS2323, W			; adresa 3. za izvrsenje
		bnz		_nemamesta2	
		call	_nadjimesto2
		movwf	RS2323
		return	

_nadjimesto2
		movf	XB1, W		; odredjuje gde je sl mesto (0), Slobodno mesto B1	
		bnz		_B6
		movlw	0xB1
		movwf	FSR0L
		return
_B6
		movf	XB6, W
		bnz		_BB
		movlw	0xB6
		movwf	FSR0L	
		return	
_BB
		movf	XBB, W
		bnz		_nemamesta2
		movlw	0xBB
		movwf	FSR0L	
		return	
	
_nemamesta2
		return		
;===================================================================================
_Salji_status
		call	_bafer2						; posalji odgovor na 232
		movlw	0x01					; duzina 1 bajt za slanje na 232
		movwf	INDF0
		incf	FSR0L
		movff	StatusGW, INDF0	
		return
;======================================================================================
_analiza						; sta je primljeno? izvrsenje
		bcf		Paket_kraj
		bsf		Analiza				; krenula Analiza
	; u medjuvremenu proveri da li je nesto stiglo sa Dalija
		
	; u W se nalazi sadrzaj I tj adresa gde je paket
	
		movff	I, FSR1L
		movf	INDF1, W			; u W je prvi bajt komande
	;	movwf	Indf1
		movlw	0x01				; Da li je komanda 0x01
		cpfseq	INDF1
		goto	_kom02				; nije probaj dalje
		movlw	0x10				; jeste resetuj GW i posalji 0x10
		movwf	StatusGW
		
 		call	_Salji_status

		call	_krajanalize
		return						; kraj

_kom02
		movlw	0x02				; da li je 0x02
		cpfseq	INDF1
		goto	_kom03				
		movf	StatusGW, W			; Posalji status GW na 232

 		call	_Salji_status
		
		call	_krajanalize		
		return
	
_kom03
		movlw	0x03				; da li je 0x03
		cpfseq	INDF1
		goto	_kom04				;
		incf	FSR1L, F
		movff	INDF1, DaliH1			; Primi prvu rec
		incf	FSR1L, F
		movff	INDF1, DaliL1			; Primi prvu rec
		movlw	0x03
		movwf	StatusGW
 		call	_Salji_status
		call	_krajanalize
		movlw	0x10
		movwf	StatusGW
		return
	
_kom04
		movlw	0x04				; da li je 0x04
		cpfseq	INDF1
		goto	_kom05				;
		incf	FSR1L, F
		movff	INDF1, DaliH2			; Primi drugu rec
		incf	FSR1L, F
		movff	INDF1, DaliL2			; Primi drugu2 rec						
		movlw	0x04
		movwf	StatusGW
 		call	_Salji_status
		call	_krajanalize
		movlw	0x10
		movwf	StatusGW	
		return
	
_kom05
		movlw	0x05				; da li je 0x05
		cpfseq	INDF1
		goto	_kom06				;
		incf	FSR1L, F
		movff	INDF1, DaliH3			; Primi trecu rec
		incf	FSR1L, F
		movff	INDF1, DaliL3			; Primi drugu2 rec	
		movlw	0x05
		movwf	StatusGW
 		call	_Salji_status
		call	_krajanalize
		movlw	0x10
		movwf	StatusGW		
		return
		

_kom06	
		movlw	0x06
		cpfseq	INDF1
		goto	_kom7
		; pre slanja na Dali treba proveriti da li je vec slanje u toku, a zatim upisati DaliH, DaliL i slati
		btfsc	U_toku_slanje				; Da li je slanje u toku?
		return						; Jeste, izadji, ali nije kraj vrati se kada se zavrsi slanje na Dali
		incf	FSR1L, F
		movff	INDF1, DaliH
		incf	FSR1L, F
		movff	INDF1, DaliL
		movff 	INDF1, DaliHupit_odg	; pri programiranju balasta DALIL je adresa,	DALIH je B1,B3,B5
		movlw	0x22				; salji 16 bita -  34 polubita zapravo 35 sa jednim stop
		movwf	Brojac
		call	_saljiDhDl			; primljeno sve posalji na dali i izadji
	; znaci treba setovati fleg da se vrati na 61 nakon zavrsenog slanja
		btfss	DaliH, 0
		bsf		Power_arc
		movlw	0xFE
		cpfslt	DaliH
		goto	_Broadcast
		movlw	0x7F		; Da li je grupna komanda?
		cpfsgt	DaliH
		goto	_nijegrupna
		;jeste grupna ili A ili B
		movlw	0xA0
		cpfslt	DaliH
		goto	_iznadA0

_Broadcast
		call	_krajanalize	; jeste grupna komanda		
		call	_pitajAll
		return
_nijegrupna
		btfsc	DaliH, 0		; da li je bio Power arc
		goto	_Komanda				; komanda
		bsf		Power_arc		; Power Arc
		goto 	_zategni61	

_Komanda
		movlw	0x20			; nije proveri da li treba upit balasta posle komande
		cpfsgt	DaliL
		goto 	_zategni61		; Treba	upit balasta

		call	_krajanalize	; Ne treba izadji
		return		

_zategni61		
		bsf		Zategni61	; setuj da krene kom61 kada se zavrsi slanje, a zatim 62 u T+X*250mS
		clrf	Brojackom			; Resetuj Brojackom
		call	_krajanalize	
		movff 	DaliH, DaliHupit
		clrf	Mili250
		bcf		Mili750
		btfsc	Zahtev_u_toku
		call	_pitajAll
		bsf		Zahtev_u_toku
		return

_iznadA0

	;	call	_saljiDhDl
		call	_krajanalize	; Ne treba izadji
		return				

_kom7	
		movlw	0x07
		cpfseq	INDF1
		goto	_kom8

		btfsc	U_toku_slanje				; Da li je slanje u toku?
		return						; Jeste, izadji, ali nije kraj vrati se kada se zavrsi slanje na Dali
		incf	FSR1L, F			; Nije slanje u toku
		movff	INDF1, DaliH
		incf	FSR1L, F
		movff	INDF1, DaliL
	
		movlw	0x22				; salji 16 bita -  34 polubita zapravo 35 sa jednim stop
		movwf	Brojac
		call	_saljiDhDl			; primljeno sve posalji na dali i izadji
		bsf		Zategni71			; setuj da krene kom71 kada se zavrsi slanje +20mS
	
		clrf	Brojackom7			; Resetuj Brojackom
		call	_krajanalize	
	
		return

		
_kom71	
		movlw	0x22				; salji 16 bita -  34 polubita zapravo 35 sa jednim stop	
		movwf	Brojac
		call	_saljiDhDl		; Posalji ponovo posle 10mS komandu
		bcf		Zategni71		; gotovo sa kom 7
		return	

_kom8	
		movlw	0x08				
		cpfseq	INDF1
		goto	_kom9
		btfsc	U_toku_slanje				; Da li je slanje u toku?
		return						; Jeste, izadji, ali nije kraj vrati se kada se zavrsi slanje na Dali
		incf	FSR1L, F			; Nije slanje u toku
		movff	INDF1, DaliH
		movlw	0xA9
		cpfseq	DaliH
		goto	_UpitA9
		bsf		UpitA9
_UpitA9		
		incf	FSR1L, F
		movff	INDF1, DaliL
	
		movlw	0x22				; salji 16 bita -  34 polubita zapravo 35 sa jednim stop
		movwf	Brojac
		call	_saljiDhDl			; primljeno sve posalji na dali i izadji
		bsf		Zategni62			; setuj da krene kom81 kada se zavrsi slanje 
		clrf	Brojackom			; Resetuj Brojackom
		call	_krajanalize	
		bsf		Obavezan_odgovor
		return	
	
_kom9
		movlw	0x09				
		cpfseq	INDF1
		goto	_kom0A
		btfsc	U_toku_slanje				; Da li je slanje u toku?
		return						; Jeste, izadji, ali nije kraj vrati se kada se zavrsi slanje na Dali
	;	incf	FSR1L, F			; Nije slanje u toku
		movff	DaliH1, DaliH
	;	incf	FSR1L, F
		movff	DaliL1, DaliL
	
		movlw	0x22				; salji 16 bita -  34 polubita zapravo 35 sa jednim stop
		movwf	Brojac
		call	_saljiDhDl			; primljeno sve posalji na dali i izadji
	;	bsf		Zategni91			; setuj da krene kom91 kada se zavrsi slanje 
		clrf	Brojackom			; Resetuj Brojackom
		call	_krajanalize	
		movlw	0x10
		movwf	StatusGW
 		call	_Salji_status
		bsf		Zategni91
		return	

_kom0A								; bila komanda A0 sada je C0 kao na starom gatewayu
		movlw	0xC0
		cpfseq	INDF1
		goto	_kom0B
		btfsc	U_toku_slanje				; Da li je slanje u toku?
		return						; Jeste, izadji, ali nije kraj vrati se kada se zavrsi slanje na Dali
		incf	FSR1L, F			; Nije slanje u toku
		movff	INDF1, DaliHH
		incf	FSR1L, F			
		movff	INDF1, DaliH
		incf	FSR1L, F
		movff	INDF1, DaliL
	
		movlw	0x32				; salji 24 bita -  48 polubita zapravo 49 sa jednim stop
		movwf	Brojac
		call	_saljiDhDl			; primljeno sve posalji na dali i izadji
		call	_krajanalize	
		call	_bafer2						; posalji odgovor na 232
		movlw	0x01					; duzina 1 bajt za slanje na 232
		movwf	INDF0
		incf	FSR0L
		movlw	0x09
		movwf	INDF0	
		return



_kom0B	
		movlw	0x0B				
		cpfseq	INDF1
		goto	_kom0D
		btfsc	U_toku_slanje				; Da li je slanje u toku?
		return						; Jeste, izadji, ali nije kraj vrati se kada se zavrsi slanje na Dali
		incf	FSR1L, F			; Nije slanje u toku
		movff	INDF1, DaliH
		movlw	0xA0
		movwf	DaliL
	
		movlw	0x22				; salji 16 bita -  34 polubita zapravo 35 sa jednim stop
		movwf	Brojac
		call	_saljiDhDl			; primljeno sve posalji na dali i izadji
		bsf		Zategni62			; setuj da krene kom81 kada se zavrsi slanje 
		clrf	Brojackom			; Resetuj Brojackom
		call	_krajanalize	
		bsf		Obavezan_odgovor
	;	call	_krajanalize	; jeste grupna komanda
		return


_kom0D	
		movlw	0x0D				
		cpfseq	INDF1
		goto	_kom0E
		movlw	0x40
		movwf	Brojac232S

		call	_krajanalize
		
		bsf		Send232All
		return



_kom0E				; iskljucivo za senzor osvetljaja i prisustva Hevlar 
		movlw	0x0E				
		cpfseq	INDF1
		goto	_kom55

		incf	FSR1L, F			; II Postavi broj bita za slanje (17 najcesce)
		movff	INDF1, Brojac
		movlw	0x19
		cpfslt	Brojac
		goto	_nepoznata
		rlncf	Brojac
		incf	Brojac
		incf	Brojac
		
		incf	FSR1L, F			; III Izvuci grupnu adresu 0x8X (X=1, 3, 5 do F)
		movff	INDF1, DaliHH
		movlw	0x80
		cpfsgt	DaliHH
		goto	_nepoznata

		incf	FSR1L, F			; IV  Izvuci komandu za senzor
		movff	INDF1, DaliH
	
		incf	FSR1L, F			; V  Izvuci rep komande (1 do 2 bita)
		movff	INDF1, DaliL

; Primer Disable	0x85 0x8A 0
		call	_saljiDhDl			; primljeno sve posalji na dali i izadji
		call	_krajanalize
		return



_kom55				; komanda salji sve (sve sto prodje na Daliju i sve sto je poslato sa gatewaya)
		movlw	0x55				
		cpfseq	INDF1
		goto	_nepoznata			; nepoznata komanda probane sve poznate ove nema

		incf	FSR1L, F			; Proveri drugu rec da je AA
		movlw	0xAA
		cpfseq	INDF1
		goto	_nepoznata

		incf	FSR1L, F			; Proveri trecu rec da je 0x55
		movlw	0x55				
		cpfseq	INDF1
		goto	_nepoznata

		incf	FSR1L, F			; Cetvrta rec sadrzi setovanje za Ponovi
		movff	INDF1, Flag9

		MOVLW 	0x00 				;
		MOVWF 	EEADR 				; Data Memory Address to write
		movf 	Flag9, W			;
		MOVWF 	EEDATA 				; Data Memory Value to write
		BCF 	EECON1, EEPGD 		; Point to DATA memory
		BCF 	EECON1, CFGS 		; Access EEPROM
		BSF 	EECON1, WREN 		; Enable writes
	
		MOVLW 	55h ;
		MOVWF 	EECON2 		; Write 55h
		MOVLW 	0AAh 		;
		MOVWF 	EECON2 		; Write 0AAh
		BSF 	EECON1, WR 	; Set WR bit to begin write
		BTFSC 	EECON1, WR 	; Wait for write to complete
		goto 	$-2

		call	_krajanalize



		return

		
		
_nepoznata
		movlw	0x15			; nepoznata poruka
		movwf	StatusGW
 		call	_Salji_status
		call	_krajanalize	; jeste grupna komanda
		return

;=================================================================================
_pitajAll
		bsf		Upitaj_All		; postavi pitaj all
		movlw	0x7F			
		movwf	BrojacAll		; postavi brojac 127 i umanjuj za po 2 na 20mS
		clrf	Mili250
		bcf		Mili750
		return
																				   
									
											   
													   
					  
											   
							
												
																				   
									
											   
													   
					  
											   
							
												

		

;===================================================================================


_krajanalize
		btfss	Analiza 		; moze brisanje memorije prijema sa rs232 jednog paketa
		return

		movff	I, FSR1L		; adresa prvog paketa
		
		clrf	INDF1
		incf	FSR1L
		clrf	INDF1
		incf	FSR1L
		clrf	INDF1
		incf	FSR1L
		clrf	INDF1
		incf	FSR1L
		clrf	INDF1
		movff	II, I			; pomeri bafer napred na sledeci paket
		movff	III, II
		movff	IV, III
		movff	V, IV
		clrf	V
		bcf		Analiza			; kraj analize
		return

;===========================================================================

; Novi setuj bit mnogo brzi

_setujbit
		movwf	Temp2
		andlw	0x38
		rrncf	WREG, W
		rrncf	WREG, W
		rrncf	WREG, W
		addlw	0x6B
		movwf	FSR0L	
		movlw	0x07
		andwf	Temp2, F
	
		btfsc	STATUS, Z
		bsf		INDF0, 0
		dcfsnz	Temp2
		bsf		INDF0, 1
		dcfsnz	Temp2
		bsf		INDF0, 2
		dcfsnz	Temp2
		bsf		INDF0, 3
		dcfsnz	Temp2
		bsf		INDF0, 4
		dcfsnz	Temp2
		bsf		INDF0, 5
		dcfsnz	Temp2
		bsf		INDF0, 6
		dcfsnz	Temp2
		bsf		INDF0, 7
		return	
;===========================================================================
_resetujbit
		movwf	Temp2
		andlw	0x38
		rrncf	WREG, W
		rrncf	WREG, W
		rrncf	WREG, W
		addlw	0x6B
		movwf	FSR0L	
		movlw	0x07
		andwf	Temp2, F
	
		btfsc	STATUS, Z
		bcf		INDF0, 0
		dcfsnz	Temp2
		bcf		INDF0, 1
		dcfsnz	Temp2
		bcf		INDF0, 2
		dcfsnz	Temp2
		bcf		INDF0, 3
		dcfsnz	Temp2
		bcf		INDF0, 4
		dcfsnz	Temp2
		bcf		INDF0, 5
		dcfsnz	Temp2
		bcf		INDF0, 6
		dcfsnz	Temp2
		bcf		INDF0, 7
		return	
	
; potprogram za setovanje/resetovanje bita na mestu 0-63 u 8 bajtova
; u W se nalazi mesto 0-63,a u Setbit set 1 ili resetuj 0
; Izlaz je setovan odgovarajuci bit koji pokazuje da li postoji balast na
; adresi 00-63 odnosno da li je bilo odgovora sa te adrese


;========================================================================
; potprogram za test set/reset bita na mestu 0-63 u 8 bajtova
; u W se nalazi mesto 0-63,a u Set_postoji setovan 1 ili resetovan 0	
_Dalijeset

		movwf	Temp2
		andlw	0x38
		rrncf	WREG, W
		rrncf	WREG, W
		rrncf	WREG, W
		addlw	0x6B
		movwf	FSR0L
		bcf		Set_postoji	
		movlw	0x07
		andwf	Temp2, F
	;_kojibit
	;	movf	Temp2, W
		bz		_prvibit1
		decf	Temp2
		bz		_drugibit1
		decf	Temp2
		bz		_trecibit1
		decf	Temp2	
		bz		_cetvrtibit1	
		decf	Temp2
		bz		_petibit1
		decf	Temp2
		bz		_sestibit1
		decf	Temp2
		bz		_sedmibit1
		decf	Temp2
		bz		_osmibit1		
		return	
_prvibit1
		btfsc	INDF0, 0	
		bsf		Set_postoji	
		return
_drugibit1	
		btfsc	INDF0, 1	
		bsf		Set_postoji
		return	
_trecibit1	
		btfsc	INDF0, 2	
		bsf		Set_postoji
		return	
_cetvrtibit1	
		btfsc	INDF0, 3	
		bsf		Set_postoji
		return		
_petibit1	
		btfsc	INDF0, 4	
		bsf		Set_postoji
		return	
_sestibit1	
		btfsc	INDF0, 5	
		bsf		Set_postoji
		return	
_sedmibit1	
		btfsc	INDF0, 6
		bsf		Set_postoji
		return	
_osmibit1	
		btfsc	INDF0, 7	
		bsf		Set_postoji
		return	
	; Izlaz Set_postoji  ako je 1 adresa aktivna - balast odgovara, 0 neaktivna

;===============================================================================

;____ potprogram za slanje dali word-a________________

_saljiDhDl

	;	movwf	Brojac	; u Brojac vrednost broja bita za slanje 10 (16 bitna rec), 18 (24 bitna)
		

		clrf	BrojacT				; brojac za slanje
		bsf		Zaostao_telegram				; telegram jos nije poslat, slanje u toku
		bsf		Sledeci_bit				; prvi bit je start bit, 1
		btfss	PIR2, TMR3IF		; salji kad se oslobodi linija + 10ms (interapt T3)
		return			; Ako je overflow (proslo 10ms) samo prodji, u protivnom vrati se
									; nije poslat telegram cekaj da se pojavi overflow T3
		movlw	0x12
		cpfseq	Brojac				; da li je 8 bita za slanje na Dali
		goto	_16bita
		movff	DaliL, DaliHHt		; salje se samo DaliL
		goto 	_Endsalji
		
_16bita
		movlw	0x22
		cpfseq	Brojac				; da li je 16 bita za slanje na Dali
		goto	_17bita
		movff	DaliH, DaliHHt		; salje se samo DaliL, DaliH		
		movff	DaliL, DaliHt	
		goto	_Endsalji

_17bita	
		movlw	0x24
		cpfseq	Brojac				; da li je 24 bita za slanje na Dali
		goto	_24bita
		movff	DaliHH, DaliHHt	
		movff	DaliH, DaliHt
		movff	DaliL, DaliLt	
_24bita	
		movlw	0x32
		cpfseq	Brojac				; da li je 24 bita za slanje na Dali
		goto	_Endsalji
		movff	DaliHH, DaliHHt	
		movff	DaliH, DaliHt
		movff	DaliL, DaliLt

_Endsalji	
;+++++++++++++++++++++++++++++++++++++++++++++++++++
; Dodato da za svaki telegram na Daliju ponovi i na 232
	
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		btfss	Ponovi1C		; Da li je setovano slanje na 232 1C
		goto	_nastavislanje		; nije

		call	_bafer2
		movlw	0x03			; broj bajtova za slanje bez start i stop
		movwf	INDF0
		incf	FSR0L
		movlw	0x1C						; II bajt kod komande
		movwf	INDF0
		incf	FSR0L

		movf	DaliHHt, W
		bcf		WREG, 0
		rrncf	WREG, W				; adresa 0-63
		movwf	INDF0					; III bajt adresa
		incf	FSR0L
		movff	DaliHt, INDF0				; IV bajt Vrednost DaliL

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
_nastavislanje
		bcf		INTCON, TMR0IE		; zabrani interapt od TMR0
		bcf		PIE2, C1IE			; zabrani od Prijemnog komparatora
		bcf		PIR1, TMR2IF		; Obrisi Overflow T2 pripremi za merenje 416 pri slanju
		bsf		INTCON, GIEL
		bsf		T2CON, TMR2ON		; Ukljuci T2	da meri vreme
		bsf		U_toku_slanje				; nisu poslati svi biti, krenuo brojac		
		return
		
	
;================================================================================

; INTERAPTI
; HIGH
;================================================================================
; Ulaz u interapt zbog timeouta T0 ili ivice na Daliju
_inthigh						; Dali linija int

		movf	TMR0L, W
		movwf	RecTime
	
		clrf	TMR0L				; start brojaca do sledeceg interapta
		clrf	Flag2
	;    btg		LATC, 2
	
		btfsc	PIR2, C1IF
		goto	_OverT0				; interapt zbog ivice ili	
			
	; interapt od TMR0 zbog overflow T0-nema vise impulsa-kraj receiva ili greska u prijemu
		btfss	CM1CON0, C1OUT_CM1CON0	; Da li je izlaz nula na kraju overflowa
		goto 	_sumnjivo				; jeste, nula je sumnja na kratki spoj
	
		bcf		INTCON, TMR0IE		; zabrani ponovni interapt od TMR0 
		goto	_recdata		; sve ok za sada
				
; interapt od ivice na Daliju__________________________	
_OverT0
		clrf	kratkispoj			; resetuj KS - nije u kratkom spoju, cim dobije jednu ivicu
	
		btfss	INTCON, TMR0IF		; Overflow?
		goto	_NOver
		clrf	RecTime				; prva ivica start bita (Overflow)
		bsf		INTCON, TMR0IE		; dozvoli 1 interapt od TMR0
	;	btfsc	Odgovor_bal			; da li je pitanje za gomilu balasta
	;	goto	_sumnjivo			; jeste proveri da li je napon na dole
		clrf	Flag3
		goto 	_zbir
		
_sumnjivo	
		infsnz	kratkispoj			; broj ks do 255mS Svaki put kada izadje iz overflowa sa low
		goto	_kratkispoj		; ulaz u kratki spoj nakon 255 x 1,024Ms

		clrf	Flag3	
		bcf		INTCON, TMR0IF	
		goto 	_neuspelo
	
_NOver							; nije Overflow prijem bita sa dalija
	 ;   bsf		LATC, 5
	    movlw	.20					
		cpfsgt	RecTime				; ako je vreme manje od min 320 uSec
		goto	_TimeOUT			; taiming izvan limita
		movlw	.228				; ako je vreme vece od max 912uSec
		cpfslt	RecTime
		goto	_TimeOUT			; taiming izvan limita
		movlw	.180				; vreme vece od 496uSec
		cpfsgt	RecTime
		goto	_tpola
	
		movlw	.188				; vreme manje od 752uSec
		cpfsgt	RecTime
		goto 	_TimeOUT			; taiming izvan limita
		bsf		Flag2, 1			; vreme 2, T ili 833 uSec
		goto	_zbir


_TimeOUT
		bsf		Sumnjiv_odg			; sumnjivo zategni na svakoj ivici, na kraju receiva setuj Sumnjiv_odg2
	;	movwf	DaliH
		movff	Flag3, Odg_vise_balasta
		movlw	.6						; 2 start bit ~!!!!!!!!!!!!!!!!!!!!!!
		cpfsgt	Flag3					; Da li je > 4!!!!!!!!!!!!!!!!!!!!!!!!!
		bcf		Sumnjiv_odg
		goto	_neuspelo	;_dalje6

_tpola	
		bsf		Flag2, 0			; vreme 1, T/2 ili 416 usec

_zbir			
		movf	Flag2, W			; ukupno 32+2 start bita x T/2 _| |__
		addwf	Flag3, F			; dodaj da se zna na kom je bitu trenutno
		btfss	Flag3, 0			; da li je neparan broj poluciklusa?
		goto 	_neuspelo			; Ne
		btfss	CM1CON0, C1OUT_CM1CON0			; Da, Dali low?	
		goto	_dodaj0
		
_dodaj1
		rlcf	DaliLr				; prvi bajt
		rlcf	DaliHr				; Drugi bajt
		rlcf	DaliHHr				; Treci bajt
		bsf		DaliLr, 0
		goto	_neuspelo

_dodaj0	
		rlcf	DaliLr
		rlcf	DaliHr
		rlcf	DaliHHr	
		bcf		DaliLr, 0
		goto	_neuspelo
	
	
_recdata
		btfsc	Sumnjiv_odg					; primljeno, sumnjivo
		bsf		Sumnjiv_odg2				; setuj na kraju prijema sumnjivo
		bcf		Sumnjiv_odg
		
	
		movlw	.17						; 2 start bit + 14 (7 bita) + 1 od 8. bita
		cpfseq	Flag3					; Da li je 17 ?
		goto	_dalje1					; nije
		goto	_odgovor2			; bajt je - odgovor
		
_dalje1	
		addlw	0x01
		cpfseq	Flag3					; Da li je 18	
		goto 	_dalje2					; nije 
		goto	_odgovor2			; bajt je - odgovor
		
_dalje2	
		movlw	.33						; 2 start bit + 30 (15 bita) + 1 od 16. bita
		cpfseq	Flag3					; Da li je 33 ?
		goto	_dalje3					; nije
		goto	_komanda				; dva bajta je - komanda
	
_dalje3	
		addlw	0x01
		cpfseq	Flag3					; Da li je 34	
		goto 	_dalje4					; nije 
		goto	_komanda				; dva bajta je - komanda
	
_dalje4
		movlw	.49						; 2 start bit + 46 (23 bita) + 1 od 24. bita
		cpfseq	Flag3					; Da li je 49 
		goto	_dalje5					; nije
		goto	_Primaj					; tri bajta je razgovor kontrolera
	
_dalje5	
		addlw	0x01
		cpfseq	Flag3					; Da li je 50	
		goto	_dalje6					; nije
		goto	_Primaj

_dalje6
		bsf		Sumnjiv_odg2
		movff	Flag3, Odg_vise_balasta
		movlw	.6						; 2 start bit 
		cpfsgt	Flag3					; Da li je > 4
										   
		bcf		Sumnjiv_odg

		goto 	_neuspelo				; nije 
	
	;________________________________________________________________
									; analiza primljenih telegrama
									
_odgovor2

		btfss	Pitanje_balastu			; Da li je bio zahtev balastu sa Rs232?
		goto	_neuspelo			; Ne izadji
	
		; da li je bio telegram sa prekidaca na short


		movlw	0x13			; limit je na 10mS + 10 za odgovor =0x14
		cpfslt	Brojackom		; koliko je vremena proslo od kada je zategnut
		goto	_timeover
		clrf	Brojackom
		movlw	0xBA			; 
		cpfslt	DaliHupit		; pri inicijalizaciji DaliH A9 B9
		goto	_neuspelo


		movff	DaliHupit, FSR0L		; da bio je na adresu DaliH
		bcf		FSR0L, 0
		rrncf	FSR0L, F				; adresa 0-63
		movff	FSR0L, Temp3
	 	movff	DaliLr, INDF0		; upisi odgovor balasta u lokaciju
		movf	FSR0L, W			; adresa 0-63
		call	_setujbit	
		clrf	Flag3	 		

		bcf		Pitanje_balastu		; resetuj pitanje stigao odgovor	

		call	_bafer2						; posalji odgovor na 232
		movlw	0x03					; duzina 3 bajta za slanje na 232
		movwf	INDF0
		incf	FSR0L	
		setf	INDF0					; I bajt FF
		incf	FSR0L
		movff	DaliLr, INDF0			; II bajt DaliLr
		incf	FSR0L
		movf	Temp3, W					; III bajt								
 
	 

	  
 
	 

		btfsc	UpitA9				
		movf	DaliHupit_odg, W
		movwf	INDF0						; III bajt SA DaliHupit	
		bcf		UpitA9	
		goto	_neuspelo

_timeover	; ovo je malo verovatno ili neverovatno jer ako je odgovor on je u 18mS
		clrf	Brojackom
		bcf		Pitanje_balastu			; nema odgovora od balasta DaliH
		goto	_neuspelo
								
_Primaj
		call	_bafer2
		movlw	0x04						; broj bajtova za slanje bez start i stop
		movwf	INDF0
		incf	FSR0L
		movlw	0x0C						; II bajt kod komande
		movwf	INDF0
		incf	FSR0L
		movff	DaliHHr, INDF0				; III bajt adresa gatewaya
		incf	FSR0L
		movff	DaliHr, INDF0				; IV bajt Adresa Dali

		incf	FSR0L
		movff	DaliLr, INDF0				; V bajt vrednost
		goto 	_neuspelo

_komanda	
;+++++++++++++++++++++++++++++++++++++++++++++++++++
; Dodato da za svaki telegram na Daliju ponovi i na 232
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
		btfss	PonoviOF		; Da li je setovano slanje na 232 OF
		goto	_propusteni		; nije

		call	_bafer2			; Jeste salji i na 232
		movlw	0x03			; broj bajtova za slanje bez start i stop
		movwf	INDF0
		incf	FSR0L
		movlw	0x0F						; II bajt kod komande
		movwf	INDF0
		incf	FSR0L
		movff	DaliHr, INDF0				; III bajt adresa gatewaya
		incf	FSR0L
		movff	DaliLr, INDF0				; IV bajt Adresa Dali

;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;+++++++++++++++++++++++++++++++++++++++++++++++++++
; ovde se proverava da li je propusten upit jednog ili vise balasta, pa ako jeste treba poceti od pocetka ALL

;	btfss	Flag1, 5			; Da li je vec bilo short komande koju je trebalo obraditi
;	bsf		Flag1, 7			; Jeste
								; Nije
;	btfss	Flag1, 6 			; Da li je vec bilo group komande koje je trebalo obraditi
;	bsf		Flag1, 7			; Jeste
	
;++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
_propusteni
		clrf	Flag3
		movlw	0x7F					; povecano sa 3f na 7f
		cpfsgt	DaliHr					; da li je short adresa?
		goto	_sa						; jeste
		movff	DaliHr, DaliH
		call	_pitajAll			; nije zapocni sekvencu upita
		clrf	Brojackom
		btfss	DaliHr, 0
		bsf		Power_arc
		goto	_neuspelo				
_sa
		btfss	DaliHr, 0
		bsf		Power_arc
		btfss	Zategni61
		goto	_nemaNeobradjene
	;	call	_pitajAll			;  prosla neobradjena komanda, pitaj sve
	;	clrf	Brojackom			;
		goto	_neuspelo
		
_nemaNeobradjene
		bsf		Zategni61			; Setuj Pitanje balastu posle zavrsene komande
		movff	DaliHr, DaliHupit
		clrf	Brojackom		
		movlw	0xA0
		movwf	DaliL

		bcf		Mili750

		goto	_neuspelo		


_kratkispoj					; ulazi u kratki spoj
		btfss	Kratki_spoj
		call	_SaljiKS		; posalji jednom da je u kratkom spoju i na svakih 10 sec
		bsf		Kratki_spoj		
		bsf		Led_crvena
		bcf		DaOut			; bsf,  promenjeno na bcf za semu EUROICC
		incf	KSIzlaz
		movlw	0x28
		cpfslt	KSIzlaz
		call	_resetujks

_neuspelo						;	izvan time limita i kraj 
		movff	FSR0L_T, FSR0L
		movlw	0xB1
		movwf	TMR3H
		clrf	TMR3L
		bcf		PIR2, TMR3IF		; reset overflow 10mS, kreni ponovo
		bcf		INTCON, TMR0IF		; resetuj overflow prijema na Daliju 255*4 uSec
		clrf	TMR0L
		movf	CM1CON0, W			; prvo dummy citanje Porta za reset interapta
		bcf		PIR2, C1IF
	 ;	bcf		LATA, 5
	;    bcf		LATA, 4	
	 ;	bcf		LATC, 5
	 ;   bcf		LATC, 4	

		RETFIE	FAST

_resetujks			; izlaz iz kratkog spoja posle 10 sec (40x0.255sec)
		clrf	KSIzlaz
		clrf	kratkispoj
		bsf		DaOut				; Izlaz iz KS EUROICC
		bcf		Led_crvena
	 	bcf		Sumnjiv_odg2
	 	bcf		Sumnjiv_odg
	;	clrf	Flag3
		bcf		Kratki_spoj
		return

_SaljiKS
		call	_bafer2
		movlw	0x01			; broj bajtova za slanje bez start i stop
		movwf	INDF0
		incf	FSR0L
		movlw	0x12						; II bajt kod komande
		movwf	INDF0
		Return
;=============================================================================
; LOW
;===============================================================================
_intlow				;Salji   TMR1 interapt, 1000uSec x 250 = 250mS x 240 = 60,0sec
; _______________________________________________________________________________
; ulazi u interapt sa bitom 1 ili 0 za izlaz na DaliOut
; ako je bit 0 (izlaz high) sve vreme vrsi ispitivanje i ne izlazi iz interapta dok
; ne dobije novi TMR2.IF
; ako je 1 izlaz low izlazi odmah i ulazi ponovo kada dodje novi interapt 0 
; posle toga radi rlcf

		btfsc	PIR1, TMR1IF				; da li je od TMR1
		goto	_TMR1						; Jeste



_TMR2										; ne od TMR2 je (slanje)
		btfsc	BrojacT, 0		;???? 0?	; da li je paran polubit (druga polovina bita koja se togluje)
		goto	_togluj						; jeste
		btfsc	Sledeci_bit						; da li izlaz treba da bude 0 ili 1 (start bit je 1 potom 0)
		goto	_salji1
	;	goto	_salji0

_salji0							; salji 0 pocetni polubit
		bcf		DaOutks
		bsf		DaOut			; EUROICC
	;	bcf		PIR1, TMR2IF	
		incf	BrojacT
_ispituj	
	;	btfsc	PIR1, TMR2IF
	;	goto	_TMR2	
	;	btfsc	CM1CON0, C1OUT_CM1CON0		; Izlaz je 1 ispitaj, Ako je kolizija izadji
	;	goto	_ispituj					; nije kolizija
	;	goto	_kolizija
		goto	_krajlow
_salji1									; salji 1 prvi polubit
		bcf		DaOut					; EUROICC
		bsf		DaOutks
	;	bcf		PIR1, TMR2IF	
		incf	BrojacT
		goto	_krajlow					; zavrsen polubit idi na sledeci

_togluj									; drugi polubit (toglovan)
		btfsc	Sledeci_bit						; da li izlaz treba da bude 0 ili 1	
		goto	_salji00
	;	goto	_salji11
		btfsc	Zadnji_polubit					; da li je poslednji polubit?.
		goto	_preskoci					; jeste preskoci spustanje linije
_salji11				
		bcf		DaOut						; EUROICC
		bsf		DaOutks
_preskoci
	;	bcf		PIR1, TMR2IF
		bcf		Zadnji_polubit	
		incf	BrojacT
		goto	_sledecibit

_salji00
		bcf		DaOutks
		bsf		DaOut					; EUROICC
	;	bcf		PIR1, TMR2IF	
		incf	BrojacT
_ispitujT	
	;	btfsc	PIR1, TMR2IF
		goto	_sledecibit
	;	btfsc	CM1CON0, C1OUT_CM1CON0		; Izlaz je 1 ispitaj, Ako je kolizija izadji
	;	goto	_ispitujT	
	
_kolizija						
		bcf		Zaostao_telegram		; kolizija kraj slanja  
		bcf		T2CON, TMR2ON			; Iskljuci T2 da meri vreme
		clrf	TMR2
		bcf		U_toku_slanje						; nema vise bita za slanje
		movlw	0xB1						; postavi na 10ms
		movwf	TMR3H
		clrf	TMR3L
		bcf		PIR2, TMR3IF	
		bcf		PIR1, TMR2IF
		movf	W_COPY, W 	
		movff	STATUS_COPY, STATUS			; Restore data	
	;	bsf		INTCON, GIEH				; kraj slanja dozvoli prijem
	; obrisi oba IF a TMR0IF i C1IF????
	
		bsf		INTCON, TMR0IE		; omoguci interapt od TMR0
		bsf		PIE2, C1IE			; omoguci od Prijemnog komparatora
		movf	W_COPY, W 	
		movff	STATUS_COPY, STATUS			; Restore data	
	  	movff	BSR_TEMP, BSR				; 	
		retfie	

_sledecibit	
	;	bcf		PIR1, TMR2IF		; salji sledeci polubit u novom prolazu
		clrf	STATUS
		rlcf	DaliLt, F
		rlcf	DaliHt, F
		rlcf	DaliHHt, F	
		btfss	STATUS, C
		goto	_setujf
		bsf		Sledeci_bit
		goto	_izadjilow
_setujf
		bcf		Sledeci_bit					; salji 1 ili 0	
_izadjilow
		movf	Brojac, W					; da li je zavrseno slanje?
		cpfseq	BrojacT
		goto	_nijezadnjibit
		bsf		Zadnji_polubit					; poslednji polubit
	
_nijezadnjibit
		cpfsgt	BrojacT		
		goto	_krajlow					; nije jos gotovo ima jos bita za slanje
	; ZAVRSENO SLANJE KRAJ
		bcf		Zadnji_polubit					; zavrseno slanje 
		bcf		Zaostao_telegram	
		bcf		DaOutks
		bsf		DaOut						; EUROICC
		bcf		T2CON, TMR2ON		; Iskljuci T2	da meri vreme
	;	movff	DaliL, TXREG
	;	movf	CM1CON0, W		; Dummy citanje
		bcf		U_toku_slanje						; nema vise bita za slanje
		bcf		Upitaj1					; zavrsen jedan u nizu upita
		btfsc	Zategni62				; Da li je bila kom 06 ili zahtev za status balasta
		goto	_idina62				; Jeste idi na 61
		btfsc	Zategni71				; Da li je bila kom 07
		goto	_idina71				; Jeste idi na 71
		btfsc	Zategni72				; Da li je bila kom 71
		goto	_idina72				; Jeste idi na 72

		btfsc	Zategni91
		goto	_idina91

		btfsc	Zategni92
		goto	_idina92	



		btfsc	Zategni71				; Da li je bila kom 071
		goto	_idina72				; Jeste idi na 71
	
		goto	_izlaz

_idina62
		bcf		Zahtev_u_toku
		bcf		Zategni62
		movff	DaliH, DaliHupit
		bsf		Pitanje_balastu			; Startuj brojac 20 mS da krene upit balasta
		goto	_izlaz

_idina71
		bcf		Zategni71
		bsf		Zategni72				; Startuj brojac 20 mS da krene 71
		goto	_izlaz

_idina91
		bcf		Zategni91
		bsf		Zategni92
		goto	_izlaz

_idina92
		bcf		Zategni92
		bsf		Zategni93
		goto	_izlaz


_idina72
		bcf		Zategni72				; Zavrseno sa komandom 7
		goto	_izlaz



_izlaz							; zavrseno slanje na Dali predji u prijem
		movlw	0xB1
		movwf	TMR3H
		clrf	TMR3L

		bcf		PIR2, TMR3IF		; reset overflow 10mS, kreni ponovo
		clrf	Brojackom
		clrf	Brojackom7
		bcf		PIR1, TMR2IF
		bcf		INTCON, TMR0IF
		bcf		PIR2, C1IF
		bcf		INTCON, TMR0IE		; omoguci interapt od TMR0
		bsf		PIE2, C1IE			; omoguci int od Prijemnog komparatora
		movf	W_COPY, W 	
		movff	STATUS_COPY, STATUS			; Restore data
	  	movff	BSR_TEMP, BSR				; 
		retfie
	
_kraj1pbita	
	
	
	
_krajlow					; zavrseno slanje bita ima jos
		bcf		PIR1, TMR2IF
		movf	W_COPY, W 	
		movff	STATUS_COPY, STATUS			; Restore data
	  	movff	BSR_TEMP, BSR				; 
		retfie

_TMR1
		incf	Brojackom, F
		incf	Brojackom7, F
		btfss	Pitanje_balastu				; Da li je bio zahtev balastu
		goto	_milisec				; nije zaboravi

		movlw	0x13					; jeste, postavi na 20mS (10+10mS za odgovor)
		cpfslt	Brojackom				; Da li je proslo
	;	goto	_milisec			; nije jos
		bsf		Timeout_bal			; Time out nema odgovora balasta
	
_milisec	
		incf	Vreme5mS
		incf	Milisec					; meri vreme u mS i u cetvrtinama sekunde
		movlw	0xFA
		cpfslt	Milisec	
		goto	_250mS
		goto	_Restore
	
	;	incf	Time3ms

_250mS	
		incf	Mili250
		clrf	Milisec

_Restore	
		bcf		PIR1, TMR1IF
		movlw	0xE0
		movwf	TMR1H
		movlw	0xBF
		movwf	TMR1L
		movf	W_COPY, W	
		movff	STATUS_COPY, STATUS			; Restore data
	  	movff	BSR_TEMP, BSR				; 
		retfie 

EE_DATA	CODE	0xF00000
	DE 0x00, 0x14, 0x01, 0x00, 0x01, 0x00, 0x00, 0x00	; Flag9 - b0,b1 odredjuju nacin rada 
	DE 0x00, 0x00, 0x07, 0x00, 0x07, 0x00, 0x07, 0x00	; Grupe7,Grupe8, Scene1,2,3,4,5,6
	DE 0x07, 0x00, 0x05, 0x00, 0x06, 0x01, 0x07, 0x03	; Scene7,8, Sceneval 1,2,3,4,5,6
	DE 0x02, 0x00										; Sceneval 7,8
	end											; prvi pripada grupi 0 i 15, drugi grupi 1, 2, 3 i 15		
; Grupe1= 0000 0001 znaci da je pripadnik nulte grupe
; Ukljuci I rele I  i iskljuci II rele I adrese pri DaliHr= 0x81 i DaliLr=0x10 - scena 