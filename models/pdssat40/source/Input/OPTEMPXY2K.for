C=======================================================================
C  OPTEMPX, Subroutine
C  Writes out "gray" file with only one treatment in FILEX format, after
C  reading in a standard FILEX
C-----------------------------------------------------------------------
C  Revision history
C
C  01/01/1990 GH  Written
C  05/28/1993 PWW Header revision and minor changes
C  04/20/2002 GH  Updated
C  07/16/2002 CHP Increased number of applications to 200 (NAPPL)
C  05/02/2003 GH  Increased the max. number of treatments/levels to 999
C-----------------------------------------------------------------------
C  INPUT  : YRIC,PRCROP,WRESR,WRESND,EFINOC,EFNFIX,SWINIT,INH4,INO3,
C           NYRS,VARNO,VRNAME,CROP,PATHMO,FROP,NREP,FILEIO
C
C  LOCAL  :
C
C  OUTPUT :
C-----------------------------------------------------------------------
C  Called : INPUT
C
C  Calls  : ERROR
C-----------------------------------------------------------------------
C                         DEFINITIONS
C
C=======================================================================

      SUBROUTINE OPTEMPXY2K(YRIC,PRCROP,WRESR,WRESND,EFINOC,EFNFIX,
     &           SWINIT,INH4,INO3,NYRS,VARNO,VRNAME,CROP,
     &           FILEIO,FROP,MODEL,ECONO,
     &           LNSIM,LNCU,LNHAR,LNENV,LNTIL,LNCHE,
     &           LNFLD,LNSA,LNIC,LNPLT,LNIR,LNFER,LNRES,
     &           NFORC,PLTFOR,PMTYPE,NDOF,CHEXTR)

      USE ModuleDefs
      IMPLICIT NONE

      INCLUDE 'COMIBS.BLK'
      INCLUDE 'COMSOI.BLK'
      INCLUDE 'COMSWI.BLK'
      INCLUDE 'COMGEN.BLK'

      CHARACTER* 2 CROP,PRCROP,LABL
      CHARACTER* 6 VARNO, ECONO
	CHARACTER* 7 ERRKEY
      CHARACTER*12 MODEL
      CHARACTER*16 VRNAME
	CHARACTER*30 FILEIO,FILEIOH
	CHARACTER*42 CHEXTR(NAPPL)

      INTEGER NYRS,I,LUNIO,ERRNUM,FROP,YRIC
	INTEGER LNSIM,LNCU,LNHAR,LNENV,LNTIL,LNCHE
	INTEGER LNFLD,LNSA,LNIC,LNPLT,LNIR,LNFER,LNRES
	INTEGER NFORC,NDOF,PMTYPE
	INTEGER LN

      REAL    SWINIT(NL),WRESR,WRESND,EFINOC,EFNFIX,INO3(NL),INH4(NL)
	REAL    PLTFOR 

      PARAMETER (LUNIO = 21)
      PARAMETER (ERRKEY = 'OPTEMPX')

      LN = LEN(TRIM(FILEIO))
	FILEIOH = FILEIO
	WRITE(FILEIOH(LN:LN),'(A1)') 'H'
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      OPEN (LUNIO, FILE = FILEIOH,STATUS = 'UNKNOWN',IOSTAT=ERRNUM)
      IF (ERRNUM .NE. 0) CALL ERROR (ERRKEY,ERRNUM,FILEIOH,0)
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE (LUNIO,50,IOSTAT=ERRNUM) EXPER,CG,ENAME
   50 FORMAT ('*EXP.DETAILS: ',A8,A2,1X,A60)
C   50 FORMAT (A14,A8,A2,1X,A60)
      WRITE (LUNIO,'(/,"*FILES")')
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE (LUNIO,'("@N  EXP.DATA    AFILE",8X,"ADIR")')
      WRITE (LUNIO,2100,IOSTAT=ERRNUM) LNSIM,FILEA
 2100 FORMAT(I3,1X,'EXP         ',A12,1X,A80)
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE (LUNIO,'("@N  SPECIES     SPFILE",7X,"SPDIR")')
      WRITE (LUNIO,2200,IOSTAT=ERRNUM) LNSIM,FILEC,PATHCR
 2200 FORMAT(I3,1X,'SPE         ',A12,1X,A80)
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE (LUNIO,'("@N  ECOTYPE     EFILE",8X,"EDIR")')
      WRITE (LUNIO,2300,IOSTAT=ERRNUM) LNSIM,FILEE,PATHEC
 2300 FORMAT(I3,1X,'ECO         ',A12,1X,A80)
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE (LUNIO,'("@N  CULTIVAR    CFILE",8X,"CDIR")')
      WRITE (LUNIO,2500,IOSTAT=ERRNUM) LNSIM,FILEG,PATHGE
 2500 FORMAT(I3,1X,'CUL         ',A12,1X,A80)
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE (LUNIO,'("@N  SOIL        SFILE",8X,"SDIR")')
      WRITE (LUNIO,2700,IOSTAT=ERRNUM) LNSIM,FILES,PATHSL
 2700 FORMAT(I3,1X,'SOIL        ',A12,1X,A80)
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE (LUNIO,'("@N  WEATHER     WFILE",8X,"WDIR")')
      WRITE (LUNIO,2800,IOSTAT=ERRNUM) LNSIM,FILEW,PATHWT
 2800 FORMAT(I3,1X,'WEATH       ',A12,1X,A80)
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE (LUNIO,'(/,"*SIMULATION CONTROL")')
      LABL = 'GE'
      WRITE(LUNIO,'("@N  GENERAL     NYERS NREPS START   SDATE RSEED",
     &  1X,"SNAME.................... MODEL")')
      WRITE(LUNIO,900,IOSTAT=ERRNUM) LNSIM,LABL,NYRS,NREPSQ,ISIMI,
     &     YRSIM,RSEED1,TITSIM,MODEL(1:5)
 900  FORMAT(I3,1X,A2,9X,1X,I5,1X,I5,5X,A1,1X,I7,1X,I5,1X,A25,1X,A5)
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE(LUNIO,'("@N  OPTIONS     WATER NITRO SYMBI PHOSP POTAS",
     &  1X,"DISES  CHEM  TILL")')
      LABL = 'OP'
      WRITE (LUNIO,910,IOSTAT=ERRNUM) LNSIM,LABL,ISWWAT,ISWNIT,ISWSYM,
     &     ISWPHO,ISWPOT,ISWDIS,ISWCHE,ISWTIL
 910  FORMAT(I3,1X,A2,9X,10(5X,A1))
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      LABL = 'ME'
      WRITE(LUNIO,'("@N  METHODS     WTHER INCON LIGHT EVAPO INFIL",
     & 1X,"PHOTO HYDRO NSWIT SOMDY")')
      WRITE (LUNIO,915,IOSTAT=ERRNUM) LNSIM,LABL,MEWTH,MESIC,
     &      MELI,MEEVP,MEINF,MEPHO,MEHYD,NSWITCH,MESOM
 915  FORMAT(I3,1X,A2,9X,7(5X,A1),1X,I5,5(5X,A1))
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      LABL = 'MA'
      WRITE(LUNIO,'("@N  MANAGEMENT  PLANT IRRIG FERTI RESID HARVS")')
      WRITE(LUNIO,910,IOSTAT=ERRNUM)LNSIM,LABL,IPLTI,IIRRI,IFERI,
     & IRESI,IHARI
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      LABL = 'OU'
      WRITE(LUNIO,'("@N  OUTPUTS     FNAME OVVEW SUMRY FROPT GROUT",
     &      1X,"CAOUT WAOUT NIOUT MIOUT DIOUT  LONG CHOUT OPOUT")')
      WRITE (LUNIO,920,IOSTAT=ERRNUM) LNSIM,LABL,IOX,IDETO,
     &     IDETS,FROP,IDETG,IDETC,IDETW,IDETN,IDETP,IDETD,IDETL,
     &     IDETH,IDETR
 920  FORMAT(I3,1X,A2,9X,3(5X,A1),4X,I2,9(5X,A1))
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE (LUNIO,'(/,"!AUTOMATIC MANAGEM")')
      LABL = 'PL'
      WRITE(LUNIO,'("@N  PLANTING      PFRST   PLAST PH2OL PH2OU PH2OD",
     & 1X,"PSTMX PSTMN")')
      WRITE(LUNIO,930,IOSTAT=ERRNUM) LNSIM,LABL,PWDINF,
     &      PWDINL,SWPLTL,SWPLTH,SWPLTD,PTX,PTTN
 930  FORMAT(I3,1X,A2,9X,2(1X,I7),5(1X,F5.0))
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      LABL = 'IR'
      WRITE(LUNIO,'("@N  IRRIGATION  IMDEP ITHRL ITHRU IROFF",
     & 1X,"IMETH IRAMT IREFF")')
      WRITE(LUNIO,940,IOSTAT=ERRNUM) LNSIM,LABL,DSOIL,THETAC,
     &      IEPT,IOFF,IAME,AIRAMT,EFFIRR
 940  FORMAT(I3,1X,A2,9X,3(1X,F5.0),2(1X,A5),1X,F5.1,1X,F5.3)
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      LABL = 'NI'
      WRITE(LUNIO,'("@N  NITROGEN    NMDEP NMTHR NAMNT NCODE",
     & 1X,"NAOFF")')
      WRITE(LUNIO,940,IOSTAT=ERRNUM)LNSIM,LABL,DSOILN,SOILNC,
     & SOILNX,NCODE,NEND
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      LABL = 'RE'
      WRITE(LUNIO,'("@N  RESIDUES    RIPCN RTIME RIDEP")')
      WRITE (LUNIO,950,IOSTAT=ERRNUM) LNSIM,LABL,RIP,NRESDL,DRESMG
 950  FORMAT(I3,1X,A2,10X,F5.0,1X,I5,1X,F5.0)
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      LABL = 'HA'
      WRITE(LUNIO,'("@N  HARVEST     HFRST   HLAST HPCNP HRCNR")')
      WRITE (LUNIO,960,IOSTAT=ERRNUM) LNSIM,LABL,HDLAY,
     &       HLATE,HPP,HRP
 960  FORMAT(I3,1X,A2,9X,1X,I5,1X,I7,5(1X,F5.0))
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------

C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE (LUNIO,'(/,"*TREATMENTS",/
     & "@N   R O C TNAME....................  CU  FL  SA  IC  MP",
     & 2X,"MI  MF  MR  MC  MT  ME  MH  SM")')
      
      WRITE (LUNIO,55)
     &     TRTNO,ROTNO,ROTOPT,CRPNO,
     &     TITLER,LNCU,LNFLD,LNSA,LNIC,LNPLT,LNIR,LNFER,LNRES,
     &     LNCHE,LNTIL,LNENV,LNHAR,LNSIM
 55   FORMAT (I3,1X,I2,2(1X,I1),1X,A25,14(1X,I3))
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------

	IF (CROP .EQ. 'WH' .OR. CROP .EQ. 'BA') THEN
	  WRITE (LUNIO,'(/,"*CULTIVARS",/,"@C  CR INGENO CNAME...",1X,
     &         "ECO#     P1V   P1D    P5    G1    G2    G3 PHINT")')
	  WRITE (LUNIO,156,IOSTAT=ERRNUM) LNCU,CROP,VARNO,VRNAME(1:8),
     &  ECONO,P1V,P1D,P5,G1,G2,G3,PHINT
156     FORMAT (I3,1X,A2,1X,A6,1X,A8,1X,A6,5(1X,F5.1),1X,F5.2,1X,F5.1)
      ELSE     
	  WRITE (LUNIO,'(/,"*CULTIVARS",/,"@C  CR INGENO CNAME")')
        WRITE (LUNIO,56,IOSTAT=ERRNUM) LNCU,CROP,VARNO,VRNAME
 56     FORMAT(I3,1X,A2,1X,A6,1X,A16)
 
	ENDIF
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE (LUNIO,'(/,"*FIELDS")')
      WRITE(LUNIO,'("@L  ID_FIELD WSTA....  FLSA  FLOB  FLDT  FLDD",
     & 2X,"FLDS  FLST SLTX   SLDP ID_SOIL")')
      WRITE(LUNIO,57,IOSTAT=ERRNUM) LNFLD,FLDNAM,FILEW(1:8),SLOPE,
     &   FLOB, DFDRN,FLDD,SFDRN,FLST,SLTX,SLDP,SLNO
 57   FORMAT(I3,1X,A8,1X,A8,1X,F5.1,1X,F5.0,1X,A5,2(1X,F5.0),
     &       2(1X,A5),1X,F5.0,1X,A10)
	 
	WRITE(LUNIO,'("@L             XCRD            YCRD      ",
     &      "ELEV              AREA  SLEN  FLWR  SLAS")')

      WRITE (LUNIO,58,IOSTAT=ERRNUM) LNFLD,XCRD,YCRD,ELEV,AREA,SLEN,
     &      FLWR,SLAS
      IF (ERRNUM .NE. 0) CALL ERROR (ERRKEY,ERRNUM,FILEIOH,LUNIO)
 58   FORMAT (I3,1X,2(F15.5,1X),F9.2,1X,F17.1,1X,F5.0,2(1X,F5.1))
C
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      IF(ISWWAT .NE. 'N') THEN
	ICREN  = MAX(ICREN,-9.0)
	ICREP  = MAX(ICREP,-9.0)
	WRITE (LUNIO,'(/,"*INITIAL CONDITIONS")')
      WRITE(LUNIO,'("@C  PCR     ICDAT  ICRT  ICND  ICRN  ICRE",
     & 2X,"ICWD ICRES ICREN ICREP ICRIP ICRID")')
      
	WRITE (LUNIO,61,IOSTAT=ERRNUM) LNIC,PRCROP,YRIC,
     &       WRESR,WRESND,EFINOC,EFNFIX,ICWD,INT(ICRES),ICREN,
     &       ICREP,ICRIP,ICRID

      IF (ERRNUM .NE. 0) CALL ERROR (ERRKEY,ERRNUM,FILEIOH,LUNIO)
   61 FORMAT (I3,1X,A2,4X,I7,2(1X,F5.0),2(1X,F5.2),1X,F5.1,1X,I5,
     &        2(1X,F5.2),2(1X,F5.0))

C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE(LUNIO,'("@C   ICBL  SH2O  SNH4  SNO3")')
      DO I = 1, NLAYR
        WRITE(LUNIO,62,IOSTAT=ERRNUM) LNIC,DS(I),SWINIT(I),
     &        INH4(I),INO3(I)
 62     FORMAT(I3,1X,F5.0,1X,F5.3,2(1X,F5.1))
      ENDDO
      ENDIF
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE (LUNIO,'(/,"*PLANTING DETAILS",/,
     &  "@P    PDATE   EDATE  PPOP  PPOE  PLME  PLDS  PLRS  PLRD
     &  PLDP  PLWT  PAGE  PENV  PLPH  SPRL")')
	      
	IF ((INDEX('PI',CROP)) .GT. 0) THEN
         WRITE (LUNIO,70,IOSTAT=ERRNUM) LNPLT,YRPLT,
     &    IEMRG,PLANTS,
     &    PLTPOP,PLME,PLDS,ROWSPC,AZIR,SDEPTH,SDWTPL,SDAGE,ATEMP,
     &    PLPH,SPRLAP,NFORC,PLTFOR,NDOF,PMTYPE
      ELSE
         WRITE (LUNIO,70,IOSTAT=ERRNUM) LNPLT,YRPLT,
     &    IEMRG,PLANTS,
     &    PLTPOP,PLME,PLDS,ROWSPC,AZIR,SDEPTH,SDWTPL,SDAGE,ATEMP,
     &    PLPH,SPRLAP
      ENDIF
      IF (ERRNUM .NE. 0) CALL ERROR (ERRKEY,ERRNUM,FILEIOH,LUNIO)
 
 70   FORMAT (I3,1X,I7,1X,I7,2(1X,F5.1),2(5X,A1),2(1X,F5.0),
     &  1X,F5.1,2(1X,F5.0),3(1X,F5.1),I6,F6.1,2I6)
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE (LUNIO,'(/,"*IRRIGATION",/,
     &"@I   IEFF  IDEP  ITHR  IEPT  IOFF  IAME  IAMT")')
    
      WRITE(LUNIO,75,IOSTAT=ERRNUM) LNIR,EFFIRX,DSOILX,THETCX,IEPTX,
     &     IOFFX,IAMEX,AIRAMX
 75      FORMAT(I3,1X,F5.3,3(1X,F5.0),2(1X,A5),1X,F5.1)

C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
!      WRITE(LUNIO,'("@I   IDATE  IROP IRVAL  IIRV")')
      WRITE(LUNIO,'("@I    IDATE  IROP IRVAL")')
      DO I = 1,NIRR
         WRITE(LUNIO,76,IOSTAT=ERRNUM) LNIR,IDLAPL(I),
     &         IRRCOD(I),AMT(I)   !,IIRV(I)
!  76      FORMAT(I2,1X,I7 ,1X,A5,1X,F5.1,4X,I2)
  76      FORMAT(I3,1X,I7 ,1X,A5,1X,F5.1)
      ENDDO
 
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE (LUNIO,'(/,"*FERTILIZERS",/,
     & "@F    FDATE  FMCD  FACD  FDEP  FAMN  FAMP  FAMK  FAMC",
     &  2X,"FAMO  FOCD")')
      DO I = 1,NFERT
        WRITE(LUNIO,77,IOSTAT=ERRNUM) LNFER,FDAY(I),
     &        IFTYPE(I),FERCOD(I),DFERT(I),ANFER(I),
     &        APFER(I),AKFER(I),ACFER(I),AOFER(I),FOCOD(I)
 77   FORMAT(I3,1X,I7,2(1X,A5),6(1X,F5.0),1X,A5)
      ENDDO

C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE (LUNIO,'(/,"*RESIDUES",/,
     & "@R    RDATE  RCOD  RAMT  RESN  RESP  RESK  RINP  RDEP  RMET")')
      DO I = 1,NARES
        WRITE(LUNIO,79,IOSTAT=ERRNUM)LNRES,RESDAY(I),
     &        RESCOD(I),INT(RESIDUE(I)),RESN(I),RESP(I),
     &     RESK(I),RINP(I),DEPRES(I),RMET(I)
  79   FORMAT(I3,1X,I7,1X,A5,1X,I5,3(1X,F5.2),2(1X,F5.0),1X,A5)
      ENDDO

C-----------------------------------------------------------------------
C     Chemicals ....
C-----------------------------------------------------------------------
      WRITE (LUNIO,'(/,"*CHEMICALS",/,
     &  "@C    CDATE CHCOD CHAMT  CHME CHDEP   CHT")')
      DO I = 1,NCHEM
         WRITE (LUNIO,80,IOSTAT=ERRNUM) LNCHE,CDATE(I),
     &         CHCOD(I),CHAMT(I),CHMET(I),CHDEP(I),CHT(I),CHEXTR(I)
         IF (ERRNUM .NE. 0) CALL ERROR (ERRKEY,ERRNUM,FILEIOH,LUNIO)
      END DO
  80  FORMAT (I3,1X,I7,1X,A5,1X,F5.2,1X,A5,1X,F5.1,1X,A5,A42)
! 80  FORMAT (I3,1X,I7,1X,A5,1X,F5.2,1X,A5,1X,F5.2,1X,A5,A42)
      
C-----------------------------------------------------------------------
C    Tillage  ....
C-----------------------------------------------------------------------
      WRITE (LUNIO,'(/,"*TILLAGE",/,
     &     "@T    TDATE TIMPL  TDEP")')
      DO I = 1,NTIL
         WRITE (LUNIO,85,IOSTAT=ERRNUM) LNTIL,TDATE(I),
     &         TIMPL(I),TDEP(I)
         IF (ERRNUM .NE. 0) CALL ERROR (ERRKEY,ERRNUM,FILEIOH,LUNIO)
      END DO     
   85 FORMAT (I3,1X,I7,1X,A5,1X,F5.1)
     
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE (LUNIO,'(/,"*ENVIRONMENT",/,
     & "@E    ODATE  EDAY  ERAD  EMAX  EMIN ERAIN  ECO2  EDEW EWIND")')
      DO I = 1,NEV
        WRITE(LUNIO,90,IOSTAT=ERRNUM)
     &     LNENV,WMDATE(I),DAYFAC(I),DAYADJ(I),RADFAC(I),
     &     RADADJ(I),TXFAC(I),TXADJ(I),TMFAC(I),TMADJ(I),
     &     PRCFAC(I),PRCADJ(I),CO2FAC(I),INT(CO2ADJ(I)),
     &     DPTFAC(I),DPTADJ(I),WNDFAC(I),WNDADJ(I)
 90   FORMAT(I3,1X,I7,5(1X,A1,F4.1),1X,A1,I4,2(1X,A1,F4.1))
      ENDDO
      
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
      WRITE (LUNIO,'(/,"*HARVEST",/,
     & "@H    HDATE  HSTG  HCOM HSIZE   HPC  HBPC")')
      DO I = 1,NHAR
      WRITE(LUNIO,100,IOSTAT=ERRNUM) LNHAR,HDATE(I),
     &       HSTG(I),HCOM(I),HSIZ(I),HPC(I),HBPC(I)
  100 FORMAT(I3,1X,I7,3(1X,A5),2(1X,F5.0))
      ENDDO
      
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------
     
C-----------------------------------------------------------------------
C
C-----------------------------------------------------------------------

      CLOSE(LUNIO)
      RETURN
      END SUBROUTINE OPTEMPXY2K
