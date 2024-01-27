  PROGRAM BWCOL;

  /*COMMAND SET:
   SWITCHES:       FUN   -         FUNCTION SWITCH, ACTIVATES FUNCTION INDICATED
   BY TRACKBALL SELECTION
   RED   -         SELECTS THE NEXT LEVEL OF RED
   GRN   -         SELECTS THE NEXT LEVEL OF GREEN
   BLU   -         SELECTS THE NEXT LEVEL OF BLUE

   FOR B/W USE THE RED,BLU, OR GRN SWITCH

   FUNCTIONS       GROUP -         MO 0,MO 1,MO 2,MO 3 ARE FOR MOTION OBJECTS
   SETS 0-3. A MOTION OBJECT CAN ONLY BE MADE UP OF
   FOUR COLORS, BUT THERE CAN BE SETS OF OTHER CO COLORS.
   THESE CAN BE USED BY DIFFERENT SETS OF OBJECTS.

   MA 0-3  IS FOR MOVING ALFA-NUMERICS. 16 LEVELS(4 GROUPS OF 4 COLORS).

   FX IS FOR FIXED ALFA-NUMERICS. 2 LEVELS.

   LEVEL -         SELECTS THE NEXT LEVEL TO BE ACTED UPON FOR THE
   CURRENT GROUP.

   STORE -         ASSIGNS CURRENT COLOR TO CURRENT LEVEL FOR CURRENT
   GROUP.

   FILE -  TO CONVERT ".SKH" TYPE FILES TO ".CSK" TYPE.  A COLOR
   TRANSLATION SET WILL BE PUT ON THE OUTPUT FILE FOR THE FILES
   SET OF PICTURES.  IN ADDITION, THE COLOR SETS FOR FX,MA & MO
   WILL ALSO BE ON THE OUTPUT FILE.

   TERMINATE -     OUTPUTS COLOR SETS TO FILE AND TERMINATES
   PROGRAM.                                */

TYPE
  MINT=0..65535;
  FNAME=ARRAY[1..20] OF CHAR;
  OB=RECORD
       HP,VP:MINT;
     END;
  OBP=RECORD
	GW:MINT;
	VHOFF,LADDR:CHAR;
      END;
  FSET=RECORD
	 ON,OFF:INTEGER;
       END;
  AM16=ARRAY[0..15] OF INTEGER;
  AM2=ARRAY[0..1] OF MINT;
  SW4=RECORD
	GRN,BLU,REDD,FUN:BOOLEAN;
      END;
  AC7=ARRAY[0..6] OF CHAR;

VAR
  NUMBER:ARRAY[0..15,0..1] OF CHAR;
  ARROW,CLW,BWA:AM16;
  BALL:AM2;
  SW,SW1:SW4;
  GNAM:AC7;
  TERM,HOLD,DONE,BW,CHK:BOOLEAN;
  C:CHAR;
  INF,OUTF,IPIC,OPIC:FNAME;
  INP,OUT,OP:FILE OF MINT;
  IP:TEXT;
  A,B,D:MINT;
  MX:ARRAY[0..15] OF MINT;
  MO,MA:ARRAY[0..15] OF INTEGER;
  MOUT,HPOS,VPOS:ARRAY[0..4] OF MINT;
  FX:FSET;
  XLAT:ARRAY[0..3] OF INTEGER;
  GMAR ORIGIN 167760B:MINT;
  CMAR ORIGIN 167762B:MINT;
  MCON ORIGIN 167752B:MINT;
  COLMEM ORIGIN 167732B:MINT;
  MAJOR ORIGIN 167736B:MINT;
  MINOR ORIGIN 167734B:MINT;
  OBJ ORIGIN 160000B:ARRAY[0..255] OF OB;
  OBPS ORIGIN 162000B:ARRAY[0..255] OF OBP;
  GRP,COUNT,BWC,RED,BLUE,GREEN,MS,LEVEL,I,J,K,L:INTEGER;

  PROCEDURE NITGSS;EXTERNAL;

  PROCEDURE WAITVB;EXTERNAL;

  PROCEDURE CTLLOD(SN,LN,PN,TBN:INTEGER);EXTERNAL;

  PROCEDURE ACCTKB(VAR A:AM2);EXTERNAL;

  PROCEDURE RDSWIT(VAR S:SW4);EXTERNAL;

  PROCEDURE LMGR(VAR A:AM16; OBJ,PIC:INTEGER);EXTERNAL;

  PROCEDURE SOBJMV(OBJ,HP,VP,PIC:INTEGER);EXTERNAL;

  PROCEDURE UPMES(VAR A:AC7; ROW,COL,COUNT:INTEGER);EXTERNAL;

  PROCEDURE FXCHAR(ROW,COL:INTEGER; DIR,KAR:CHAR);EXTERNAL;

  PROCEDURE DISCOL;

  VAR
    I:INTEGER;

   BEGIN
     CMAR:=5;        /*GMAR+2 ON WRITE*/
     GMAR:=482;        /*SET START ADDRESS*/
     FOR I:=0 TO 4 DO
     COLMEM:=MOUT[I];
     GMAR:=992;
     COLMEM:=FX.ON;
     GMAR:=480;
     COLMEM:=FX.OFF;
   END;
  /*DISCOL*/

  PROCEDURE NUMOUT(NUM,R,C,K:INTEGER);
  TYPE
    AC2=ARRAY[0..1] OF CHAR;

  VAR
    TMP:AC2;

    PROCEDURE UPMES(VAR A:AC2; ROW,COL,COUNT:INTEGER);EXTERNAL;

   BEGIN
     TMP:=NUMBER[NUM];
     UPMES(TMP,R,C,K);
   END;
  /*NUMOUT*/

  PROCEDURE DOLEV;
   BEGIN
     MOUT[0]:=MOUT[LEVEL+1];
     BWC:=MOUT[0] AND 17B;
     GREEN:=(MOUT[0] DIV 16) AND 17B;
     BLUE:=(MOUT[0] DIV 256) AND 17B;
     RED:=(MOUT[0] DIV 4096) AND 17B;
     WAITVB;
     DISCOL;
     IF BW
      THEN NUMOUT(BWC,15,15,2)
      ELSE
       BEGIN
	 NUMOUT(RED,18,11,2);
	 NUMOUT(BLUE,18,16,2);
	 NUMOUT(GREEN,18,21,2);
       END;
     FXCHAR(2,15,'U',CHR(LEVEL+60B));
   END;
  /*DOLEV*/

  PROCEDURE GRPOUT(NUM:INTEGER);
  TYPE
    AC4=ARRAY[0..3] OF CHAR;
  VAR
    TEMP:AC4;

    PROCEDURE UPMES(VAR A:AC4; R,C,CNT:INTEGER);EXTERNAL;

   BEGIN
     CASE NUM OF
       0: TEMP:='MO 0';
       1: TEMP:='MO 1';
       2: TEMP:='MO 2';
       3: TEMP:='MO 3';
       4: TEMP:='MA 0';
       5: TEMP:='MA 1';
       6: TEMP:='MA 2';
       7: TEMP:='MA 3';
       8: TEMP:='FX  ';
      END     /*CASE*/;
     WAITVB;
     UPMES(TEMP,2,25,4);
   END     /*GRPOUT*/;

  PROCEDURE INISCN;

  VAR
    TEMP:AC7;
    K:CHAR;

   BEGIN
     WRITE('B/W? ');
     READLN(K);
     IF K='N'
      THEN BW:=FALSE
      ELSE BW:=TRUE;
     IF BW
      THEN TEMP:='SHADE  '
      ELSE TEMP:='COLOR  ';
     UPMES(TEMP,0,8,6);
     UPMES(TEMP,11,14,5);
     TEMP:='SELECTI';
     UPMES(TEMP,0,14,7);
     TEMP:='ON     ';
     UPMES(TEMP,0,21,2);
     TEMP:='CURRENT';
     UPMES(TEMP,2,0,7);
     TEMP:=' LEVEL:';
     UPMES(TEMP,2,7,7);
     TEMP:='LEVELS:';
     UPMES(TEMP,4,1,7);
     TEMP:='GROUP  ';
     UPMES(TEMP,1,24,5);
     TEMP:='STORE  ';
     UPMES(TEMP,4,24,5);
     TEMP:='TERMINA';
     UPMES(TEMP,26,21,7);
     UPMES(TEMP,26,28,2);
     TEMP:='FILE   ';
     UPMES(TEMP,19,27,4);
     FXCHAR(5,2,'U','0');
     FXCHAR(5,6,'U','1');
     FXCHAR(5,10,'U','2');
     FXCHAR(5,14,'U','3');
     IF NOT BW
      THEN
       BEGIN
	 TEMP:='RED    ';
	 UPMES(TEMP,16,11,3);
	 TEMP:='BLUE   ';
	 UPMES(TEMP,16,15,4);
	 TEMP:='GREEN  ';
	 UPMES(TEMP,16,20,5);
       END;
   END;
  /*INISCN*/

  PROCEDURE PREBAL;
  VAR
    I:INTEGER;
    CMEM ORIGIN 167750B:MINT;

   BEGIN
     GMAR:=0;
     CMEM:=200B;     /*SET HOLD FLAG FOR CONTROLS PROCESSOR*/
     FOR I:=0 TO 3 DO;       /*DELAY FOR SYNC*/
     CMAR:=4;        /*GMAR+1 ON WRITE*/
     GMAR:=88;       /*START ADDRESS IN ZERO PAGE OF "CONGSS.MAC" FOR TRKB 0 COUNTERS*/
     CMEM:=BALL[0];      /*HORZ POS START*/
     CMEM:=BALL[0] DIV 256;
     CMEM:=BALL[1];        /*VERT POS START*/
     CMEM:=BALL[1] DIV 256;
     GMAR:=0;
     CMEM:=0;        /*CLEAR HOLD*/
   END;
  /*PREBAL*/

  PROCEDURE FXBHV;
  VAR
    I:INTEGER;
    DID:BOOLEAN;

   BEGIN
     DID:=FALSE;
     FOR I:=0 TO 1 DO
     IF (BALL[I]>32767) OR (BALL[I]>255)
      THEN DID:=TRUE;
     IF BALL[0]>32767
      THEN BALL[0]:=0;
     IF BALL[0]>255
      THEN BALL[0]:=255;
     IF BALL[1]>32767
      THEN BALL[1]:=0;
     IF BALL[1]>232
      THEN BALL[1]:=232;
     BALL[0]:=BALL[0] AND 377B;
     IF DID
      THEN PREBAL;
   END;
  /*FXBHV*/

  /*MAIN*/
 BEGIN
   MCON:=3;        /*M.A. VIDEO OFF*/
   NITGSS;                 /*INITIALIZE M.O. & FXA*/
   FOR I:=1 TO 20 DO
    BEGIN
      INF[I]:=' ';
      OUTF[I]:=' ';
    END;
   /*START CONTROLS OPS*/
   CTLLOD(4,0,0,1);
   /*INIT BW/COLOR, AND CURSOR ARRAYS*/
   K:=0;
   FOR I:=0 TO 15 DO
    BEGIN
      ARROW[I]:=0;
      BWA[I]:=I*3;
      CLW[I]:=K;
      K:=K+10421B;
    END;
   /*INIT SHADE NUMBER*/
   NUMBER[0]:=' 0'; NUMBER[1]:=' 1'; NUMBER[2]:=' 2';
   NUMBER[3]:=' 3'; NUMBER[4]:=' 4'; NUMBER[5]:=' 5';
   NUMBER[6]:=' 6'; NUMBER[7]:=' 7'; NUMBER[8]:=' 8';
   NUMBER[9]:=' 9'; NUMBER[10]:='10'; NUMBER[11]:='11';
   NUMBER[12]:='12'; NUMBER[13]:='13'; NUMBER[14]:='14';
   NUMBER[15]:='15';
   /*INIT CURSOR PICTURE IN ARRAY*/
   ARROW[0]:=14000B;
   ARROW[1]:=36000B;
   ARROW[2]:=77000B;
   ARROW[3]:=177400B;
   ARROW[4]:=177400B;
   ARROW[5]:=77000B;
   ARROW[6]:=36000B;
   ARROW[7]:=14000B;
   /*INIT. H&V FOR MOTION OBJECTS*/
   HPOS[0]:=124;
   VPOS[0]:=104;
   HPOS[1]:=12;
   VPOS[1]:=50;
   HPOS[2]:=44;
   VPOS[2]:=50;
   HPOS[3]:=76;
   VPOS[3]:=50;
   HPOS[4]:=108;
   VPOS[4]:=50;
   CMAR:=5;        /*GMAR+2 ON WRITE*/
   /*SET-UP MAJOR RAM*/
   GMAR:=0;
   FOR I:=0 TO 1023 DO
   MAJOR:=0;
   K:=2;
   FOR I:=1 TO 6 DO
    BEGIN
      GMAR:=NOT K;
      MAJOR:=I;
      K:=K*2;
    END;
   /*CLEAR COLOR RAM*/
   GMAR:=0;
   FOR I:=0 TO 511 DO
   COLMEM:=0;
   /*SET FXA TO ON WHITE*/
   GMAR:=992;
   COLMEM:=-1;
   FX.ON:=-1;
   FX.OFF:=0;
   /*SET CURSOR COLOR TO WHITE*/
   GMAR:=492;
   COLMEM:=-1;
   /*INIT LEVEL DISPLAY*/
   FOR I:=0 TO 4 DO
   MOUT[I]:=0;

   READLN;
   WRITE('DO YOU WANT TO WORK ON AN EXISTING FILE? ');
   READLN(C);
   IF C='Y'
    THEN
     BEGIN
       I:=0;
	REPEAT
	 WRITE('?INPUT FILE(.COL): ');
	 READLN(INF);
	 RESET(INP,INF,'COL',I);
	 IF I=-1
	  THEN WRITELN('INPUT FILE DOES NOT EXIST, TRY AGAIN');
	UNTIL I<>-1;
	 /*LOAD INPUT FILE*/
       FOR I:=0 TO 15 DO
	BEGIN
	  MO[I]:=INP^;
	  GET(INP);
	END;
       FOR I:=0 TO 15 DO
	BEGIN
	  MA[I]:=INP^;
	  GET(INP);
	END;
       FX.ON:=INP^;
       GET(INP);
       FX.OFF:=INP^;
       GET(INP);
       CLOSE(INP);
     END    /*IF C='Y'*/
    ELSE
    /*LOAD DEFAULT SET*/
     BEGIN
       MOUT[0]:=-1;
       DISCOL;
     END;
    /*IF C="Y"...ELSE*/
   WRITE('?OUTPUT FILE(.COL): ');
   READLN(OUTF);
   /*SET-UP SCREEN*/
   INISCN;
   /*INIT MOTION OBJECTS*/
   /*CURSOR*/
   BALL[0]:=160;
   BALL[1]:=12;
   PREBAL;         /*SET START LOCATION OF CURSOR*/
   ACCTKB(BALL);
   FXBHV;           /*ADJUST HORIZONTAL AND VERTICAL*/
   LMGR(ARROW,80,0);       /*LOAD OBJ 80 PICTURE RAM FOR PICTURE 0*/
   SOBJMV(80,BALL[0],BALL[1],0);    /*SET START POSITION*/
   I:=0;
   K:=0;
   FOR J:=0 TO 15 DO
   ARROW[J]:=-1;
   WHILE K<=4 DO
    BEGIN
      LMGR(ARROW,I,0);        /*LOAD PICTURE RAM*/
      SOBJMV(I,HPOS[K],VPOS[K],0);
      K:=K+1;
      I:=I+16;
    END   /*WHILE K<=4*/;
   DONE:=FALSE;
   GRP:=0;
   COUNT:=0;
   HOLD:=FALSE;
   WHILE NOT DONE DO
    BEGIN
      TERM:=FALSE;
      LEVEL:=0;
      CASE GRP OF
	0,1,2,3: FOR I:=0 TO 3 DO
	MOUT[I+1]:=MO[(GRP*4)+I];
	4,5,6,7: FOR I:=0 TO 3 DO
	MOUT[I+1]:=MA[((GRP-4)*4)+I];
	8:
	 BEGIN
	   MOUT[1]:=FX.OFF;
	   MOUT[2]:=FX.ON;
	   MOUT[3]:=0;
	   MOUT[4]:=0;
	 END;
       END       /*CASE*/;
      GRPOUT(GRP);
      DOLEV;  /*OUTPUT NEW LEVEL WITH COUNTS*/
      WHILE NOT TERM DO
       BEGIN
	 RDSWIT(SW1);
	 IF SW1.FUN AND NOT HOLD
	  THEN SW.FUN:=TRUE;
	 IF NOT SW1.FUN
	  THEN HOLD:=FALSE;
	 IF COUNT=0
	  THEN
	   BEGIN
	     SW.REDD:=SW1.REDD;
	     SW.BLU:=SW1.BLU;
	     SW.GRN:=SW1.GRN;
	   END
	  ELSE COUNT:=COUNT-1;
	 ACCTKB(BALL);
	 FXBHV;           /*ADJUST HORIZONTAL AND VERTICAL*/
	 WAITVB;
	 SOBJMV(80,BALL[0],BALL[1],0);
	 WITH SW DO
	 IF REDD OR BLU OR GRN OR FUN
	  THEN COUNT:=25;
	 IF SW.FUN
	  THEN
	   BEGIN
	     SW.FUN:=FALSE;
	     HOLD:=TRUE;
	     /*LEVEL INCR*/
	     IF ((BALL[0]>96) AND (BALL[0]<128)) AND ((BALL[1]>11) AND (BALL[1]<33))
	      THEN
	       BEGIN
		 IF GRP=8
		  THEN LEVEL:=(LEVEL+1) MOD 2
		  ELSE LEVEL:=(LEVEL+1) MOD 4;
		 DOLEV;
	       END
	      ELSE
	      /*STORE COLOR TO CURRENT LEVEL AND INCR LEVEL*/
	      IF (BALL[0]>176) AND ((BALL[1]>31) AND (BALL[1]<49))
	       THEN
		BEGIN
		  MOUT[LEVEL+1]:=MOUT[0];
		  IF GRP=8
		   THEN LEVEL:=(LEVEL+1) MOD 2
		   ELSE LEVEL:=(LEVEL+1) MOD 4;
		  DOLEV;
		END     /*SET COLOR*/
	       ELSE
	       /*CHANGE GROUP OR TERMINATE*/
	       IF (BALL[0]>160) AND ((BALL[1]<21) OR ((BALL[1]>199) AND (BALL[1]<225)))
		THEN
		 BEGIN
		   /*XFER COLORS*/
		   CASE GRP OF
		     0,1,2,3: FOR I:=0 TO 3 DO
		     MO[(GRP*4)+I]:=MOUT[I+1];
		     4,5,6,7: FOR I:=0 TO 3 DO
		     MA[((GRP-4)*4)+I]:=MOUT[I+1];
		     8:
		      BEGIN
			FX.OFF:=MOUT[1];
			FX.ON:=MOUT[2];
		      END      /*CASE 2*/;
		    END    /*CASE*/;
		   GRP:=(GRP+1) MOD 9;
		   TERM:=TRUE;
		   IF BALL[1]>199
		    THEN
		    IF OUTF[1]=' '
		     THEN
		      BEGIN
			WRITE('NO OUTPUT FILE, DO YOU WANT ONE? ');
			READLN(C);
			IF C='Y'
			 THEN
			  BEGIN
			    WRITE('?FILE NAME: ');
			    READLN(OUTF);
			    DONE:=TRUE;
			  END     /*IF C="Y" THEN*/;
		      END     /*IF OUTF[1]=" " THEN...ELSE*/
		     ELSE DONE:=TRUE;
		 END     /*IF CHANGE GROUP OR TERMINATE*/
		ELSE    /*FILE OPS*/
		IF (BALL[0]>199) AND (BALL[0]<232) AND (BALL[1]>151) AND (BALL[1]<161) AND (GRP<8)
		 THEN
		  BEGIN
		    IPIC[1]:='A';
		    WHILE IPIC[1]<>' ' DO
		     BEGIN
		       FOR I:=1 TO 20 DO
			BEGIN
			  IPIC[I]:=' ';
			  OPIC[I]:=' ';
			END     /*FOR I:=1 TO 20 DO*/;
			REPEAT
			 WRITE('GROUP: M');
			 IF GRP<4
			  THEN WRITE('O')
			  ELSE WRITE('A');
			 I:=0;
			 WRITE('   ?INPUT FILE(.SKH): ');
			 READLN(IPIC);
			 IF IPIC[1]<>' '
			  THEN RESET(IP,IPIC,'SKH',I);
			 IF I=-1
			  THEN WRITELN('FILE NOT FOUND');
			UNTIL I<>-1;
		       IF IPIC[1]<>' '
			THEN
			 BEGIN
			   WRITE('?OUTPUT FILE(.CSK): ');
			   READLN(OPIC);
			   IF OPIC[1]<>' '
			    THEN
			     BEGIN
			       REWRITE(OP,OPIC,'CSK');
			       CHK:=TRUE;
			       WHILE CHK DO
				BEGIN
				  WRITE('?COLOR TRANSLATION(LEVELS:0,1,2,3)= ');
				  FOR I:=0 TO 3 DO
				  READ(XLAT[I]);
				  READLN;
				  CHK:=FALSE;
				  FOR I:=0 TO 3 DO
				   BEGIN
				     J:=XLAT[I];
				     IF (J<0) OR (J>15)
				      THEN CHK:=TRUE;
				   END     /*FOR I:=0 TO 3 DO*/;
				END     /*WHILE CHK DO*/;
			       /*OUTPUT FX COLOR SET*/
			       OP^:=FX.OFF;
			       PUT(OP);
			       OP^:=FX.ON;
			       PUT(OP);
			       /*OUTPUT MO COLOR SET*/
			       FOR I:=0 TO 15 DO
				BEGIN
				  OP^:=MO[I];
				  PUT(OP);
				END;
			       /*OUTPUT MA COLOR SET*/
			       FOR I:=0 TO 15 DO
				BEGIN
				  OP^:=MA[I];
				  PUT(OP);
				END;
			       /*SET-UP XLATION SET*/
			       FOR I:=0 TO 15 DO
			       MX[I]:=0;
			       IF GRP<4
				THEN
				FOR I:=0 TO 3 DO
				MX[I]:=XLAT[I];
				/*END OF FOR I:=0 TO 3 DO*/
				/*OUTPUT XTLATION SET*/
			       FOR I:=0 TO 15 DO
				BEGIN
				  OP^:=MX[I];
				  PUT(OP);
				END;
			       /*CONVERT PICTURE DATA FROM .SKH TO .CSK*/
			       FOR I:=1 TO 4096 DO
				BEGIN
				  A:=ORD(IP^)*256;
				  GET(IP);
				  B:=0;
				  FOR J:=1 TO 4 DO
				   BEGIN
				     B:=B*16;
				     D:=(A DIV 4096) AND 14B;
				     IF GRP<4
				      THEN B:=D OR B
				      ELSE B:=B OR XLAT[D DIV 4];
				     A:=A*4;
				   END     /*FOR J:=1 TO 4 DO*/;
				  OP^:=B;
				  PUT(OP);
				END     /*FOR I:=1 TO 4096 DO*/;
			       CLOSE(IP);
			       CLOSE(OP);
			     END     /*IF OPIC[1]<>' ' THEN*/;
			 END     /*IF IPIC[1]<>' ' THEN*/;
		     END     /*WHILE IPIC[1]<>' ' THEN*/;
		  END     /*IF (BALL[0]>199) AND ...THEN*/;
	   END     /*IF SW.FUN*/;
	 WITH SW DO
	 IF REDD OR BLU OR GRN
	  THEN
	   BEGIN
	     BWC:=(BWC+1) MOD 16;
	     IF REDD
	      THEN RED:=(RED+1) MOD 16;
	     IF BLU
	      THEN BLUE:=(BLUE+1) MOD 16;
	     IF GRN
	      THEN GREEN:=(GREEN+1) MOD 16;
	     REDD:=FALSE;
	     BLU:=FALSE;
	     GRN:=FALSE;
	     IF BW
	      THEN MOUT[0]:=CLW[BWC]
	      ELSE
	       BEGIN
		 I:=(RED*4096) OR (BLUE*256) OR (GREEN*16);
		 J:= RED+BLUE+GREEN;
		 K:=16;
		  REPEAT
		   K:=K-1;
		  UNTIL (K=0) OR (BWA[K]<=J);
		 MOUT[0]:=I OR K;
	       END     /*IF BW...ELSE*/;
	     WAITVB;
	     DISCOL;
	     IF BW
	      THEN NUMOUT(BWC,15,15,2)
	      ELSE
	       BEGIN
		 NUMOUT(RED,18,11,2);
		 NUMOUT(BLUE,18,16,2);
		 NUMOUT(GREEN,18,21,2);
	       END;
	   END     /*IF REDD OR BLU OR GRN*/;
       END       /*WHILE NOT TERM*/;
    END   /*WHILE NOT DONE*/;
   /*OUTPUT FILE*/
   IF OUTF[1]<>' '
    THEN
     BEGIN
       REWRITE(OUT,OUTF,'COL');
       FOR I:=0 TO 15 DO
	BEGIN
	  OUT^:=MO[I];
	  PUT(OUT);
	END;
       FOR I:=0 TO 15 DO
	BEGIN
	  OUT^:=MA[I];
	  PUT(OUT);
	END;
       OUT^:=FX.ON;
       PUT(OUT);
       OUT^:=FX.OFF;
       PUT(OUT);
       CLOSE(OUT);
     END     /*IF OUTF[1]<>' ' THEN*/;
   GNAM:='DONE   ';
   UPMES(GNAM,22,10,4);
 END.
                                                                                                                                                                                                                 