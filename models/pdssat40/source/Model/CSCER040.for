!=======================================================================
!  Cereal crop growth
!  CROPSIM CEREALS  Developed from Cropsim and generic Ceres 3.5
!  Prepared for the first version of the modular CROPSIM-CERES model
!-----------------------------------------------------------------------
!  Revision history
!  2. Header revision and minor changes           P.W.W.      2-7-93
!  1. Modified from original as MAIZE.FOR+subs    W.D.B      3-25-01
!  2. Modified from MAIZE.FOR+all subroutines     L.A.H     31-07-02
!  3. Modified further at DSSAT workshop,Florida  L.A.H.    20-08-02
!  4. Modified further in Guelph                  L.A.H.    11-09-02
!  5. Modified further in Florida                 L.A.H.    05-11-02
!  6. Changed to use run/seasinit,inserted rootwu L.A.H.    05-01-03
!  7. Changed N routines.                         L.A.H.    10-02-03
!  8. Further changes to all routines for DSSAT4  L.A.H.    24-04-03
!  9. Initialisation changes for DSSAT4           L.A.H.    24-10-03
! 10. Added SAVE statements and case sensitivity for
!       output file names for LINUX portability   L.A.H.    17-12-04
!=======================================================================

!     SUBROUTINE CSCER040 (FILEIOIN, RUN, TN, RN,          !Command line
!    & ISWWAT, ISWNIT, IDETO, IDETG, IDETL, FROP,          !Controls
!    & SN, ON, RUNI, REP, YEAR, DOY, STEP, CN,             !Run+loop
!    & SRAD, TMAX, TMIN, CO2, RAIN, DEWDUR,                !Weather
!    & DAYLT, WINDSP, ST, EO,                              !Weather
!    & NLAYR, DLAYR, DEPMAX, LL, DUL, SAT, BD, SHF,        !Soil states
!    & SNOW, SW, NO3LEFT, NH4LEFT,                         !H2o,N states
!    & YEARPLT,                                            !Pl.date
!    & PARIP, EOP, TRWUP,                                  !Resources
!    & LAI, KCAN, KEP,                                     !States
!    & RLV, NFP, PORMIN, RWUMX, CANHT, LAIL,               !States
!    & UNO3ALG, UNH4ALG, UH2O,                             !Uptake
!    & SENCALG, SENNALG, SENLGALG,                         !Senescence
!    & RESCALG, RESNALG, RESLGALG,                         !Residues
!    & STGDOY,                                             !Stage dates
!    & DYNAMIC)                                            !Control

      ! For CSM
      SUBROUTINE CSCER040 (FILEIOIN, RUN, TN, RN, RNMODE,  !Command line
     & ISWWAT, ISWNIT, IDETO, IDETG, IDETL, FROP,          !Controls
     & SN, ON, RUNI, REP, YEAR, DOY, STEP, CN,             !Run+loop
     & SRAD, TMAX, TMIN, CO2, RAIN,                        !Weather
     & DAYLT, WINDSP, ST, EO,                              !Weather
     & NLAYR, DLAYR, DEPMAX, LL, DUL, SAT, BD, SHF,        !Soil states
     & SNOW, SW, NO3LEFT, NH4LEFT,                         !H2o,N states
     & YEARPLT,                                            !Pl.date
     & EOP, TRWUP,                                         !Resources
     & LAI, KCAN, KEP,                                     !States
     & RLV, NFP, PORMIN, RWUMX, CANHT,                     !States
     & UNO3ALG, UNH4ALG, UH2O,                             !Uptake
     & SENCALG, SENNALG, SENLGALG,                         !Senescence
     & RESCALG, RESNALG, RESLGALG,                         !Residues
     & STGDOY,                                             !Stage dates
     & DYNAMIC)                                            !Control

      ! For incorporation in CSM should:
      !    Change argument above.
      !    Eliminate '!' from SUMVALS call.
      !    Comment out call to Disease module.
      !    Check default version. Currently = 4.03 (Original is 4.00)

      ! Needed!
      ! 1. Leaf # and time to terminal spikelet too great
      !    when leaf # > 15. Need limit. See LAMS
      ! 2. Yield and kernel # from early and late plantings
      !    high. Need stress factor that affects kernel set
      !    See MCCR
      ! 3. Reserves can go to zero during grain fill, then
      !    recover. Need accelerated senescence! See KSAS.

      ! Changes since earlier DSSAT4.0 notes
      ! 1.Competition possibilities introduced
      ! 2.The saturation factor for water uptake (SATFACL)
      !   gave far too great stress for one Australian data
      !   set (CSGR9802). It is now controlled by a switch in
      !   the ecotype file that is currently set to 0 .. hence
      !   no saturation effect.

      ! 3.Kernel growth algorithm changed to account for weight
      !   gain in lag phase. Limit on grain weight introduced
      ! 4.Root depth growth factor changed to ecotype factor (to
      !   allow matching more closely with Jamieson et al 1998 paper)

      ! 5.WFP in grain filling set under control of ecotype factor.
      !   Can be set to 1.0 if WFPGF set equal to 0 (see Jamieson
      !   et al 1998 paper for reasons)

      ! 6.DF in germination phase can be set = 1 in ecotype file

      ! 7.Grain number temperature factor introduced, not implemented

      ! 8.Temperature base for grain filling made an ecotype character

      ! 9.Leaf area potential calculation changed.

      ! Notes
      ! 1.Leaf N loss when leaves senesce currently calculated using
      !   the LSENNF variable ( = (1.0-((LANC-LMNC)/LANC)). The
      !   value of this variable is very important when N is low.
      ! 2.Leaf area loss when tillers senesce is calculated using
      !   LALOSSF. The value assumed for this variable needs to be
      !   checked.

      ! Changes since first CSM 4.0 and initial DSSAT4 release

      ! A.General (No effect on results)
      ! 1.Version number for changes introduced. Read from controls
      !   (using variable heading GENERAL) but if not there, defaults
      !   to 4.0
      ! 2.Screen writes introduced for when program has to stop. These
      !   in CSCER030 as well as in the READS and UTILITIES.
      ! 3.Extra checks introduced in reads. These stop the run if a
      !   variable is not found in any one of the three genotype files,
      !   or write a WARNING message to WORK.OUT if a variable is not
      !   found in the X-file.
      ! 4.Removed ecotype reads for LATFR(1),LSENS,LSEWF,LRETS. These
      !   parameters had been moved to the species file so that the
      !   ecotype reads were redundant.
      ! 5.Restructured subroutine ROOTGR to facilitate change in 4.03
      !   below. Restucturing did not affect outputs for version 4.00
      ! 6.Added output file (LEAVES.OUT) for information on individual
      !   leaf sizes. This information was (and remains) in the
      !   WORK.OUT file, but the new file was needed for easy graphing.
      ! 7.Changed some text in Overview.out and added a description of
      !   how measured values are obtained. This latter is output for
      !   the first run only.

      ! B.Corrections May affect results and only actuated when the
      !   version number is greater than or equal to the change number.
      !   Needed to correct 'bugs',oversights,etc.in the 4.0 version
      !   4.01 Removed ecotype read and added species read for RDGTH.
      !        This parameter had been removed from the ecotype file
      !        but a read had not been added to the species file. The
      !        model was thus not running as intended. Introduction of
      !        the read changes some outputs.
      !   4.02 Added variable SEEDRSAV to ensure that seed reserves not
      !        over-used. Previously, because use for both root and leaf
      !        was limited by SEEDRV, there was a possibility that the
      !        total use (roots+leaves) could exceed what was available.
      !   4.03 Added variable RTDEPTMP and set this to RTDEP+RTDEPG to
      !        allow assignment of weight and hence RLV to new root
      !        depth growth. Previously, new depth growth had no weight
      !        assigned to it so that RLV in the depth growth region
      !        would be less than it should have been.

      ! C.Conceptual May affect results and only actuated when the
      !   version number is greater than or equal to the change number.
      !   Introduced as attempts made to improve the functioning of the
      !   model, with particular attention being given to:
      !
      !   Leaf growth
      !   4.04 Added a variable CARBOLSD to allow seed reserves to be
      !        used up to a maximum rate determined by the seed reserves
      !        available on emergence and the phyllochron interval.
      !        The expression for determining this maximum use is:
      !               SEEDRSUX = SEEDRSAV/(4.0*PHINT)
      !        This expression captures the general impression that
      !        autonomous growth is generally achieved around the 4th
      !        leaf stage.
      !
      !   Water uptake
      !   4.05 Calculate root elongation water deficit factor for layer
      !        1 from water content of layer 2. This done because
      !        elongation most likely at base of layer.
      !   4.06 (Cropsim only) Root water availability calculated using
      !        actual RLV in the zone explored by roots, not an RLV
      !        calculated using the depth of the whole layer (as in
      !        fact in outputs).
      !
      !   Tillering
      !   4.07 Tillering factor adjusted to reach 0 when actual growth
      !        falls to 0.8 of potential, or when reserves concentration
      !        less than 10%.
      !
      !   Parameters
      !   4.08 Set upper water threshold for photosynthesis (WFP) to 1.0
      !        following discussion with KJB. This overrides anything
      !         coming from the ecotype file
      !   4.09 Changed the following root growth and water uptake
      !        parameters following discussion with KJB and JWJ.
      !        RLDGR 120  -> 1000  RLWR 0.98 -> 6.0
      !        RWUMX 0.03 -> 0.04  WFRG 0.25 -> 1.0
      !        These override anything coming from the species file

      !   Following caused too much change!! Temporarily as 9.12 (4.??)
      !   9.12 Added variable CARBOLRS to allow reserves to be used
      !        as fast as necessary to meet potential leaf growth.

      IMPLICIT NONE
      SAVE

      INTEGER       NL            ! Maximum number of soil layers  #
      PARAMETER     (NL = 20)     ! Maximum number of soil layers
      INTEGER       LNUMX         ! Maximum number of leaves       #
      PARAMETER     (LNUMX = 25)  ! Maximum number of leaves

      INTEGER       ADAT          ! Anthesis date (Year+doy)       #
      INTEGER       ADAT10        ! Anthesis date (Year+doy) + 10  #
      INTEGER       ADATEND       ! Anthesis end date (Year+doy)   #
      REAL          AFLF(LNUMX)   ! CH2O factor for leaf,average   #
      CHARACTER*128 ARG           ! Argument component             text
      INTEGER       ARGLEN        ! Argument component length      #
      REAL          ASTAGE        ! Stage,start of anthesis/silk   #
      REAL          ASTAGEND      ! Stage at end of anthesis       #
      REAL          AVGSW         ! Average soil water in SWPLTD   %
      REAL          AWNAI         ! Awn area index                 m2/m2
      REAL          AWNS          ! Awn score,1-10                 #
      CHARACTER*10  BASTGNAM(20)  ! Barley stage names             text
      REAL          BD(20)        ! Bulk density (moist)           g/cm3
      CHARACTER*1   BLANK         ! Blank character                text
      REAL          BLAYER        ! Depth at base of layer         cm
      REAL          CANANC        ! Canopy N concentration         %
      REAL          CANHT         ! Canopy height                  cm
      REAL          CANHTG        ! Canopy height growth           cm
      REAL          CANHTS        ! Canopy height standard         cm
      REAL          CARBOC        ! Carbohydrate assimilated,cum   g/p
      REAL          CARBOLSD      ! CH2O used for leaves from seed g/pdd
      REAL          CARBOPHS      ! Carbohydrate assimilated       g/p
      INTEGER       CCOUNTV       ! Counter for days after max lf# #
      CHARACTER*120 CFGDFILE      ! Configuration directory+file   text
      CHARACTER*1   CFLFAIL       ! Control flag for failure       text
      CHARACTER*1   CFLINIT       ! Control flag for initiation    text
      INTEGER       CH2OLIM       ! Number of days CH2O limited gr #
      REAL          CHFR          ! Chaff fraction of assimilates  #
      REAL          CHRS          ! Chaff reserves weight          g/p
      REAL          CHRSF         ! Chaff fraction of new reserves #
      REAL          CHSTG         ! Chaff growth X-stage           #
      REAL          CHWT          ! Chaff weight                   g/p
      INTEGER       CN            ! Crop component (multicrop)     #
      CHARACTER*10  CNCHAR        ! Crop component (multicrop)     text
      INTEGER       CNI           ! Crop component,initial value   #
      REAL          CO2           ! CO2 concentration in air       vpm
      REAL          CO2FP         ! CO2 factor,photosynthesis 0-1  #
      REAL          CO2FR(10)     ! CO2 factor rel values 0-1      #
      REAL          CO2MAX        ! CO2 conc,maximum during cycle  vpm
      REAL          CO2RF(10)     ! CO2 reference concentration    vpm
      CHARACTER*2   CROP          ! Crop identifier (ie. WH, BA)   text
      CHARACTER*2   CROPP         ! Crop identifier,previous run   text
      INTEGER       CSINCDAT      ! Increment day function output  #
      INTEGER       CSTIMDIF      ! Time difference function       #
      CHARACTER*1   CSWDIS        ! Control switch,disease         code
      INTEGER       CSYEARDOY     ! Cropsim function ouptut        #
      CHARACTER*93  CUDIRFLE      ! Cultivar directory+file        text
      CHARACTER*93  CUDIRFLP      ! Cultivar directory+file,prev   text
      CHARACTER*12  CUFILE        ! Cultivar file                  text
      REAL          CUMDU         ! Cumulative development units   #
      REAL          CUMGEU        ! Cumulative GE units (TDD*WFGE) #
      REAL          CUMSW         ! Soil water in depth SWPLTD     cm
      REAL          CUMTT         ! Cumulative thermal time        C.d
      REAL          CUMTU         ! Cumulative thermal units       #
      REAL          CUMVD         ! Cumulative vernalization days  d
      INTEGER       DAE           ! Days after emergence           #
      INTEGER       DAP           ! Days after planting            #
      INTEGER       DAPM          ! Days after phys.maturity       #
      INTEGER       DAS           ! Days after start of simulation #
      REAL          DAYLT         ! Daylength (6deg below horizon) h
      REAL          DAYLTP        ! Daylength previous day         h
      REAL          DAYSUM        ! Days accumulated in month      #
      REAL          DEADN         ! Dead leaf N retained on plant  g/p
      REAL          DEADWT        ! Dead leaf wt.retained on plant g/p
      REAL          DEPMAX        ! Maximum depth of soil profile  cm
      REAL          DEWDUR        ! Dew duration                   h
      REAL          DF            ! Daylength factor 0-1           #
      REAL          DLAYR(20)     ! Depth of soil layers           cm
      REAL          DLAYRTMP(20)  ! Depth of soil layers with root cm
      REAL          DLEAFN        ! Change in leaf N               g/p
      INTEGER       DOM           ! Day of month                   #
      INTEGER       DOY           ! Day of year                    #
      INTEGER       DRDAT         ! Double ridges date             #
      REAL          DROOTN        ! Change in plant root N         g/p
      REAL          DRSTAGE       ! Double ridges stage            #
      REAL          DRSTAGEF      ! Double ridges stage factor     #
      REAL          DSTEMN        ! Change in stem N               g/p
      REAL          DTRY          ! Effective depth of soil layer  cm
      REAL          DU            ! Developmental units            PVC.d
      REAL          DUL(20)       ! Drained upper limit for soil   #
      INTEGER       DYNAMIC       ! Program control variable       text
      INTEGER       DYNAMICI      ! Module control,internal        code
      CHARACTER*64  ECDIRFLE      ! Ecotype directory+file         text
      CHARACTER*64  ECDIRFLP      ! Ecotype directory+file,prev    text
      CHARACTER*12  ECFILE        ! Ecotype filename               text
      CHARACTER*6   ECONO         ! Ecotype code                   text
      CHARACTER*6   ECONOP        ! Ecotype code,previous          text
      INTEGER       EDATM         ! Emergence date,measured (Afle) #
      CHARACTER*60  ENAME         ! Experiment description         text
      REAL          EO            ! Potential evapotranspiration   mm/d
      REAL          EOP           ! Potential evaporation,plants   mm/d
      CHARACTER*10  EXCODE        ! Experiment code/name           text
      REAL          FAC(20)       ! Factor ((mg/Mg)/(kg/ha))       #
      INTEGER       FDAY(200)     ! Dates of fertilizer applns     #
      LOGICAL       FFLAG         ! Temp file existance indicator  code
      CHARACTER*120 FILEIO        ! Name of input file,after check text
      CHARACTER*120 FILEIOIN      ! Name of input file             text
      CHARACTER*3   FILEIOT       ! Type of input file             text
      INTEGER       FINAL         ! Program control variable (= 6) #
      INTEGER       FNUMTMP       ! File number,temporary file     #
      INTEGER       FNUMLVS       ! File number,leaves             #
      INTEGER       FNUMWRK       ! File number,work file          #
      LOGICAL       FOPEN         ! File open indicator            code
      INTEGER       FROP          ! Frquency of outputs            d
      REAL          G1CWT         ! Cultivar coefficient,grain #   #/g
      REAL          G2            ! Cultivar coefficient,grain gr  mg/du
      REAL          G2KWT         ! Cultivar coefficient,grain wt  mg
      REAL          G3            ! Cultivar coefficient,stem wt   g
      INTEGER       GEDSUM        ! Germ+emergence duration        d
      CHARACTER*8   GENFLCHK      ! Genotype file name for check   text
      REAL          GESTAGE       ! Germination,emergence stage    #
      REAL          GETMEAN       ! Germ+emergence temperature av  C
      REAL          GETSUM        ! Germ+emergence temperature sum C
      REAL          GEU           ! Germination,emergence units    #
      INTEGER       GFDSUM        ! Grain filling duration         d
      REAL          GFTMEAN       ! Grain filling temperature mean C
      REAL          GFTSUM        ! Grain filling temperature sum  C
      REAL          GLIGP         ! Grain lignin content           %
      INTEGER       GMDSUM        ! Grain maturity duration        d
      REAL          GMTMEAN       ! Grain maturity temperature av  C
      REAL          GMTSUM        ! Grain maturity temperature sum C
      REAL          GPLA(10)      ! Green leaf area                cm2/p
      REAL          GRAINANC      ! Grain N concentration          #
      REAL          GRAINN        ! Grain N                        g/p
      REAL          GRAINNG       ! Grain N growth,uptake          g/p
      REAL          GRAINNGL      ! Grain N growth from leaves     g/p
      REAL          GRAINNGR      ! Grain N growth from roots      g/p
      REAL          GRAINNGS      ! Grain N growth from stems      g/p
      REAL          GRAINNTMP     ! Grain N,temporary value        g/p
      REAL          GRNMN         ! Grain N minimum concentration  %
      REAL          GRNMX         ! Grain N,maximum concentration  %
      REAL          GRNS          ! Grain N standard concentration %
      REAL          GRNUM         ! Grains per plant               #/p
      REAL          GRNUMAD       ! Grains per unit area           #/m2
      REAL          GROGR         ! Grain growth,current assim     g/p
      REAL          GROGRADJ      ! Grain growth adj,max reached   g/p
      REAL          GROGRPA       ! Grain growth,possible,assim    g/p
      REAL          GROGRPN       ! Grain growth,possible,N        g/p
      REAL          GROGRST       ! Grain growth from stem ch2o    g/p
      REAL          GROLF         ! Leaf growth rate               g/p
      REAL          GRORS         ! Reserves growth                g/p
      REAL          GRORSPM       ! Reserves growth,post-maturity  g/p
      REAL          GRORSSD       ! Seed reserves used for tops    g/p
      REAL          GROST         ! Stem growth rate               g/p
      REAL          GRORSGR       ! Reserves gr,unused grain assim g/p
      REAL          GRWT          ! Grain weight                   g/p
      REAL          GRWTTMP       ! Grain weight,temporary value   g/p
      REAL          GWGD          ! Grain wt per unit              mg
      REAL          GWUD          ! Grain size                     g
      REAL          H2OA          ! Water available in root zone   mm
      REAL          HARDAYS       ! Accumulated hardening days     #
      REAL          HARDI         ! Hardening index                #
      REAL          HARDILOS      ! Hardening index loss           #
      REAL          HBPC          ! Harvest by-product percentage  %
      INTEGER       HDOYF         ! Earliest doy for harvest       #
      INTEGER       HDOYL         ! Last doy for harvest           #
      REAL          HDUR          ! Hardening duration,days        d
      INTEGER       HFIRST        ! Earliest date for harvest      #
      REAL          HIAD          ! Harvest index,above ground     #
      REAL          HIND          ! Harvest index,N,above ground   #
      INTEGER       HLAST         ! Last date for harvest          #
      REAL          HPC           ! Harvest percentage             %
      REAL          HTFR(10)      ! Canopy ht fraction for lf area #
      INTEGER       HYEARF        ! Earliest year for harvest      #
      INTEGER       HYEARL        ! Last year for harvest          #
      INTEGER       I             ! Loop counter                   #
      INTEGER       ICSDUR        ! Stage (phase) duration         d
      CHARACTER*1   IDETOU        ! Control flag,error op,inputs   code
      CHARACTER*1   IDETG         ! Control flag,growth outputs    code
      CHARACTER*1   IDETL         ! Control switch,detailed output code
      CHARACTER*1   IDETO         ! Control flag,overall outputs   code
      CHARACTER*1   IFERI         ! Fertilizer switch (A,R,D)      code
      CHARACTER*1   IHARI         ! Control flag,harvest           code
      INTEGER       INTEGR        ! Program control variable (=4)  #
      CHARACTER*1   IPLTI         ! Code for planting date method  code
      INTEGER       ISTAGE        ! Developmental stage            #
      INTEGER       ISTAGEP       ! Developmental stage,previous   #
      CHARACTER*1   ISWNIT        ! Soil nitrogen balance switch   code
      CHARACTER*1   ISWWAT        ! Soil water balance switch Y/N  code
      INTEGER       JDAT          ! Jointing date (Year+doy)       #
      REAL          KCAN          ! Extinction coeff for PAR       #
      REAL          KCANI         ! Extinction coeff,PAR,init.val. #
      REAL          KEP           ! Extinction coeff for SRAD      #
      REAL          KEPI          ! Extinction coeff,SRAD,init val #
      INTEGER       L             ! Loop counter                   #
      REAL          LA1S          ! Area of leaf 1,standard        cm2
      REAL          LAVS          ! Area of vegetative leaves,std  cm2
      REAL          LARS          ! Area of reproductive lves,std  cm2
      REAL          LAFR(10)      ! Canopy lf area fraction w ht   #
      REAL          LAGSTAGE      ! Lag phase,grain filling stage  #
      REAL          LAI           ! Leaf area index                #
      REAL          LAIL(30)      ! Leaf area index by layer       m2/m2
      REAL          LAISTG(20)    ! Leaf area index,specific stage #
      REAL          LAIX          ! Leaf area index,maximum        #
      REAL          LALOSSF       ! Leaf area lost if tillers die  fr
      REAL          LANC          ! Leaf N concentration           #
      REAL          LAP(LNUMX)    ! Leaf area at leaf position     cm2/p
      REAL          LAPOT(LNUMX)  ! Leaf area potentials           cm2/l
      REAL          LAPP(LNUMX)   ! Leaf area diseased,leaf posn   cm2/p
      REAL          LAPS(LNUMX)   ! Leaf area senesced,leaf posn   cm2/p
      REAL          LATFR(20)     ! Leaf area of tillers,fr main   #
      REAL          LATL(1,LNUMX) ! Leaf area,tiller1,leaf pos     cm2/l
      REAL          LAWFRMN       ! Leaf area/wt min.,fr.standard  #
      REAL          LAWR2         ! Leaf area/weight ratio,stage2  cm2/g
      REAL          LAWRS         ! Leaf area/wt ratio,standard    cm2/g
      REAL          LCNC          ! Leaf critical N conc           #
      REAL          LCNCG         ! Critical N conc for growth     #
      REAL          LCNCP         ! Critical N conc for phs        #
      REAL          LCNCS(0:9)    ! Leaf critical N conc,stage     #
      REAL          LCNCSEN       ! Critical N conc for senescence #
      REAL          LCNCT         ! Critical N conc for tillering  #
      REAL          LCNF          ! Leaf critical N factor 0-1     #
      INTEGER       LCNUM         ! Leaf cohort number (inc.grow)  #
      REAL          LEAFN         ! Leaf N                         g/p
      INTEGER       LENRNAME      ! Length of run description      #
      INTEGER       LENTNAME      ! Length,treatment description   #
      REAL          LFWT          ! Leaf weight                    g/p
      REAL          LL(20)        ! Lower limit,soil h2o           #
      REAL          LLIGP         ! Leaf lignin percentage         #
      INTEGER       LLIFE         ! Leaf longevity (phyllochrons)  #
      REAL          LMNC          ! Leaf minimum N conc            #
      REAL          LMNCG         ! Minimum N conc for growth      #
      REAL          LMNCP         ! Minimum N conc for phs         #
      REAL          LMNCS(0:9)    ! Leaf minimum N conc,stage      #
      REAL          LMNCT         ! Minimum N conc for tillering   #
      REAL          LNPCA         ! Leaf N % at anthesis           #
      REAL          LNUMF         ! Leaf number factor,first 2 lvs #
      REAL          LNUMSD        ! Leaf number,Haun stage         #
      INTEGER       LNUMSG        ! Growing leaf number            #
      REAL          LNUMSTG(20)   ! Leaf number,specific stage     #
      REAL          LRETS         ! Stage --> dead leaves retained #
      REAL          LSAWS         ! Leaf sheath area/wt ratio,std  cm2/g
      REAL          LSENNF        ! Leaf N loss when senesce,fr    #
      REAL          LSENWF        ! Leaf wt loss when senesce,fr   #
      REAL          LSENS         ! Leaf senescence,start stage    #
      REAL          LSHFR         ! Leaf sheath fraction of total  #
      REAL          LT50H         ! Lethal temp,50%kill,hardened   C
      REAL          LT50S         ! Lethal temp,50%kill,seedling   C
      CHARACTER*1   MODE          ! Mode of model operation        code
      CHARACTER*8   MODEL         ! Name of model                  text
      CHARACTER*8   MODULE        ! Name of module                 text
      CHARACTER*3   MONTH         ! Month                          text
      INTEGER       NFERT         ! Fertilizer applns #            #
      REAL          NFG           ! N factor,growth 0-1            #
      REAL          NFGAV(9)      ! N factor,growth,average,phase  #
      REAL          NFGC          ! N factor,growth,cumulative     #
      REAL          NFGL          ! N factor,gr,lower limit        #
      REAL          NFGU          ! N factor,gr,upper limit        #
      REAL          NFLF(LNUMX)   ! N factor for leaf,average      #
      REAL          NFP           ! N factor,photosynthesis 0-1    #
      REAL          NFPAV(9)      ! N factor,phs,average,phase     #
      REAL          NFPC          ! N factor,phs,cumulative        #
      REAL          NFPL          ! N factor,phs,lower limit       #
      REAL          NFPU          ! N factor,phs,upper limit       #
      REAL          NFRG          ! N factor,root growth 0-1       #
      REAL          NFS           ! N factor,senescence 0-1        #
      REAL          NFSF          ! N factor,fraction lost         #
      REAL          NFSM          ! N factor,sen,maturity trigger  #
      REAL          NFSU          ! N factor,sen,upper limit       #
      REAL          NFTI          ! N factor,tillering 0-1         #
      REAL          NFTIL         ! N factor,tillering,lower limit #
      REAL          NFTIU         ! N factor,tillering,upper limit #
      REAL          NUPR          ! N uptake ratio to demand       #
      REAL          NH4LEFT(20)   ! NH4 concentration in soil      mg/Mg
      REAL          NH4MN         ! NH4 conc minimum for uptake    mg/Mg
      INTEGER       NLAYR         ! Number of layers in soil       #
      INTEGER       NLIMIT        ! Number of days N limited gr gr #
      REAL          NO3LEFT(20)   ! NO3 concentration in soil      mg/Mg
      REAL          NO3MN         ! NO3 conc minimum for uptake    mg/Mg
      INTEGER       NOUTDG        ! Number for growth output file  #
      INTEGER       NOUTDGN       ! Number for growthN output file #
      REAL          NTUPF         ! N top-up fraction              /d
      REAL          NUMAX         ! N uptake rate,max fr N in soil #
      REAL          NUPC          ! N uptake,cumulative            g/p
      REAL          NUPD          ! N uptake                       g/p
      REAL          NUSELIM       ! N limit on N for grain filling #
      INTEGER       ON            ! Option number (sequence runs)  #
      INTEGER       ONI           ! Option number,initial value    #
      CHARACTER*70  OUTHED        ! Output file heading            text
      CHARACTER*12  OUTPG         ! Growth output file code        code
      CHARACTER*12  OUTPN         ! GrowthN output file code       code
      INTEGER       OUTPUT        ! Program control variable (=5)  #
      REAL          P1D           ! Photoperiod sensitivity coeff. %/10h
      REAL          P1DPE         ! Photoperiod factor,pre-emerge  #
      REAL          P1DT          ! Photoperiod threshold          h
      REAL          P1V           ! Vernalization requirement      d
      REAL          P1VT          ! Vernalization threshold,std    d
      REAL          P4SGE         ! Stem growth end,X-stage        #
      REAL          PARAD         ! Photosynthetically active radn MJ/m2
      REAL          PARADFAC      ! PAR conversion factor          MJ/MJ
      REAL          PARI          ! PAR interception fraction      #
      REAL          PARIP         ! PAR interception percentage    %
      REAL          PARIOUT       ! PAR interception for output    #
      REAL          PART          ! PAR transmission fraction      #
      REAL          PARUED        ! PAR utilization effic,actual   g/MJ
      REAL          PARUR         ! PAR utilization effic,reprod   g/MJ
      REAL          PARUV         ! PAR utilization effic,veg      g/MJ
      CHARACTER*80  PATHCR        ! Path to genotype files         text
      INTEGER       PATHL         ! Path length                    #
      REAL          PD(0:10)      ! Phase durations                deg.d
      REAL          PD2(3)        ! Phase 2 sub-durations;1<joint  deg.d
      REAL          PD4(3)        ! Phase 4 sub-durations;1<anthes deg.d
      REAL          PD4FR(3)      ! Phase 4 sub-durations;1<anthes fr
      REAL          PDADJ         ! Phase duration adjustment      deg.d
      INTEGER       PDATE         ! Planting date from X-file      #
      REAL          PECM          ! Phase duration,emergence       Cd/cm
      REAL          PEG           ! Phase duration,germination     deg.d
      REAL          PEGD          ! Phase duration,germ+dormancy   deg.d
      REAL          PHINT         ! Phylochron interval            deg.d
      INTEGER       PHINTCHG      ! Phylochron interval,change lf# #
      REAL          PHINTS        ! Phylochron interval,standard   deg.d
      REAL          PLA           ! Plant leaf area                cm2
      REAL          PLAG(2)       ! Plant leaf area growth,tiller1 cm2/t
      REAL          PLAGT(2)      ! Plant leaf area growth,total   cm2/p
      REAL          PLAS          ! Leaf area senesced,normal      cm2/p
      REAL          PLASC         ! Leaf area senesced,cold        cm2/p
      REAL          PLASF(10)     ! Leaf area senesced,fr in phase #
      REAL          PLASS         ! Leaf area senesced,stress      cm2/p
      REAL          PLAST         ! Leaf area senesced,tiller loss cm2/p
      REAL          PLASTMP       ! Leaf area senesced,temporary   cm2/p
      INTEGER       PLDAY         ! Planting day of year           #
      REAL          PLMAGE        ! Planting material age          d
      REAL          PLTLOSS       ! Plant popn lost through cold   #/m2
      REAL          PLTPOP        ! Plant Population               #/m2
      REAL          PLTPOPP       ! Plant Population planned       #/m2
      INTEGER       PLYEAR        ! Planting year                  #
      REAL          PORMIN        ! Pore space threshold,pl effect #
      REAL          PORMINI       ! Pore space threshold,initial   #
      REAL          PTF           ! Partition fraction to tops     #
      REAL          PTFA(10)      ! Partition fr adjustment coeff. #
      REAL          PTFS(10)      ! Partition fraction by stage    #
      REAL          PTFX          ! Partition fraction,maximum     #
      REAL          PTH(0:10)     ! Phase thresholds               du
      REAL          PTHOLD        ! Phase threshold,previous       du
      REAL          PTTN          ! Minimum soil temperature,plt   C
      REAL          PTX           ! Maximum soil temperature,plt   C
      INTEGER       PWDINF        ! First day of planting window   YYDDD
      INTEGER       PWDINL        ! Last day of planting window    YYDDD
      INTEGER       PWDOYF        ! First doy of planting window   doy
      INTEGER       PWDOYL        ! Last doy of planting window    doy
      INTEGER       PWYEARF       ! First year of planting window  yr
      INTEGER       PWYEARL       ! Last year of planting window   yr
      REAL          RAIN          ! Rainfall                       mm
      REAL          RAINC         ! Rainfall,cumulative            mm
      REAL          RAINCA        ! Rainfall,cumulativ to anthesis mm
      REAL          RANC          ! Roots actual N concentration   #
      INTEGER       RATE          ! Program control variable (=3)  #
      REAL          RCNC          ! Root critical N concentration  #
      REAL          RCNCS(0:9)    ! Roots critical N conc,by stage #
      REAL          RCNF          ! Roots critical N factor 0-1    #
      REAL          RDGS1         ! Root depth growth rate,initial cm/d
      REAL          RDGS2         ! Root depth growth rate,2nd     cm/d
      REAL          RDGTH         ! Rooting depth growth           cm
      INTEGER       REP           ! Number of run repetitions      #
      REAL          RESPC         ! Respiration,total,cumulative   g/p
      REAL          RLDGR         ! Root length/root depth g ratio cm/cm
      REAL          RLFNU         ! Root length factor,N uptake    #
      REAL          RLIGP         ! Root lignin concentration      %
      REAL          RLV(20)       ! Root length volume by layer    /cm2
      REAL          RLWR          ! Root length/weight ratio       m/mg?
      REAL          RMNC          ! Root minimum N conc            g/g
      REAL          RMNCS(0:9)    ! Roots minimum N conc,by stage  #
      INTEGER       RN            ! Treatment replicate            #
      INTEGER       RNI           ! Replicate number,initial value #
      CHARACTER*1   RNMODE        ! Run mode (eg.I=interactive)    #
      REAL          ROOTN         ! Root N                         g/p
      REAL          ROOTNS        ! Root N senesced                g/p
      REAL          ROWSPC        ! Row spacing                    cm
      REAL          RSC           ! Reserves concentration         fr
      REAL          RSCA          ! Reserves concentration,anthess fr
      REAL          RSEN          ! Root senescence fraction       #
      REAL          RSFP          ! Reserves factor,photosynthesis #
      REAL          RSFRS         ! Reserves fraction,standard     #
      REAL          RSN           ! Reserve N                      g/p
      REAL          RSNGL         ! Reserves N growth from leaves  g/p
      REAL          RSNGR         ! Reserves N growth from roots   g/p
      REAL          RSNGS         ! Reserves N growth from stems   g/p
      REAL          RSNUSEG       ! Reserves N use for grain       g/p
      REAL          RSNUSER       ! Reserves N use for root growth g/p
      REAL          RSNUSET       ! Reserves N use for top growth  g/p
      REAL          RSTAGE        ! Reproductive develoment stage  #
      REAL          RSTAGEP       ! Reproductive stage,previous    #
      REAL          RSWT          ! Reserves weight                g/p
      REAL          RSWTPM        ! Reserves weight,post maturity  g/p
      REAL          RTDEP         ! Root depth                     cm
      REAL          RTDEPG        ! Root depth growth              cm/d
      REAL          RTNSL(20)     ! Root N senesced by layer       g/p
      REAL          RTREF         ! Root respiration fraction      #
      REAL          RTRESP        ! Root respiration               g/p
      REAL          RTWT          ! Root weight                    g/p
      REAL          RTWTG         ! Root weight growth             g/p
      REAL          RTWTGL(20)    ! Root weight growth by layer    g/p
      REAL          RTWTGS        ! Root weight growth from seed   g/p
      REAL          RTWTL(20)     ! Root weight by layer           g/p
      REAL          RTWTS         ! Root weight senesced           g/p
      REAL          RTWTSL(20)    ! Root weight senesced by layer  g/p
      INTEGER       RUN           ! Run (from command line) number #
      INTEGER       RUNI          ! Run (internal for sequences)   #
      INTEGER       RUNINIT       ! Program control variable (= 1) #
      CHARACTER*75  RUNNAME       ! Run title                      text
      CHARACTER*8   RUNRUNI       ! Run+internal run number        text
      REAL          RWUMX         ! Root water uptake,maximum      mm2/m
      REAL          RWUMXI        ! Root water uptake,max,init.val mm2/m
      REAL          RWUMXS        ! Root water uptake,maximum,std  mm2/m
      REAL          SAID          ! Stem area index                m2/m2
      REAL          SANC          ! Stem N concentration           #
      REAL          SAT(20)       ! Saturated limit,soil           #
      REAL          SAWS          ! Stem area to wt ratio,standard cm2/g
      REAL          SCNC          ! Stem critical N conc           #
      REAL          SCNCS(0:9)    ! Stem critical N conc,stage     #
      REAL          SCNF          ! Stem critical N factor 0-1     #
      REAL          SDAFR         ! Seed reserves fraction avail   #
      REAL          SDEPTH        ! Sowing depth                   cm
      REAL          SDNPCI        ! Seed N concentration,initial   %
      REAL          SDSZ          ! Seed size                      g
      INTEGER       SEASINIT      ! Program control variable (=2)  #
      REAL          SDNC          ! Seed N concentration           #
      REAL          SDCOAT        ! Non useable material in seed   g
      REAL          SEEDN         ! Seed N                         g/p
      REAL          SEEDNI        ! Seed N,initial                 g/p
      REAL          SDNAP         ! Seed N at planting             kg/ha
      REAL          SEEDNR        ! Seed N used by roots           g/p
      REAL          SEEDNT        ! Seed N used by tops            g/p
      REAL          SEEDRS        ! Seed reserves                  g/p
      REAL          SEEDRSAV      ! Seed reserves available        g/p
      REAL          SEEDRSI       ! Seed reserves,initial          g/p
      REAL          SENCL(0:20)   ! Senesced C,by layer            g/p
      REAL          SENCS         ! Senesced C added to soil       g/p
      REAL          SENLA         ! Senesced leaf area,total       cm2/p
      REAL          SENLFG        ! Senesced leaf                  g/p
      REAL          SENLFGRS      ! Senesced leaf to reserves      g/p
      REAL          SENLGL(0:20)  ! Senesced lignin added,by layer g/p
      REAL          SENLGS        ! Senesced lignin added to soil  g/p
      REAL          SENNL(0:20)   ! Senesced N,by layer            g/p
      REAL          SENNLFG       ! Senesced N from leaves         g/p
      REAL          SENNLFGRS     ! Senesced N from leaves,to rs   g/p
      REAL          SENNS         ! Senesced N added to soil       g/p
      REAL          SENNSTG       ! Senesced N from stems          g/p
      REAL          SENNSTGRS     ! Senesced N to rs from stems    g/p
      REAL          SENSTG        ! Senesced material from stems   g/p
      REAL          SENWL(0:20)   ! Senesced om added by layer     g/p
      REAL          SENWS         ! Senesced weight,soil           g/p
      REAL          SHF(20)       ! Soil hospitality factor 0-1    #
      REAL          SLA           ! Specific leaf area             cm2/g
      REAL          SLIGP         ! Stem lignin concentration      %
      REAL          SMNC          ! Stem minimum N conc            #
      REAL          SMNCS(0:9)    ! Stem minimum N conc,stage      #
      INTEGER       SN            ! Sequence number,crop rotation  #
      INTEGER       SNI           ! Sequence number,as initiated   #
      REAL          SNOW          ! Snow                           cm
      CHARACTER*64  SPDIRFLE      ! Species directory+file         text
      CHARACTER*64  SPDIRFLP      ! Species directory+file,last    text
      CHARACTER*12  SPFILE        ! Species filename               text
      REAL          SRAD          ! Solar radiation                MJ/m2
      REAL          SRAD20        ! Solar radiation av,20 days     MJ/m2
      REAL          SRAD20A       ! Solar radn av,20 days,anthesis MJ/m2
      REAL          SRAD20S       ! Solar radiation sum            MJ/m2
      REAL          SRADC         ! Solar radiation,cumulative     MJ/m2
      REAL          SRADD(20)     ! Solar radiation on specific d  MJ/m2
      REAL          SRADT         ! SRAD transmission fraction     #
      REAL          SSEN          ! Stem senescence fraction       #
      REAL          SSENF         ! Stem N loss when senesce       #
      REAL          SSSTG         ! Stem senescence start stage    #
      REAL          SSTAGE        ! Secondary stage of development #
      REAL          ST(0:NL)      ! Soil temperature in soil layer C
      REAL          STDDAY        ! Standard day                   C.d/d
      REAL          STEMN         ! Stem N                         g/p
      INTEGER       STEP          ! Step number                    #
      INTEGER       STEPNUM       ! Step number per day            #/d
      REAL          STFR(10)      ! Stem fractions of assimilates  #
      INTEGER       STGDOY(20)    ! Stage dates (Year+Doy)         #
      CHARACTER*10  STNAME(20)    ! Stage names                    text
      REAL          STWT          ! Stem weight                    g/p
      REAL          SW(20)        ! Soil water content             #
      REAL          SWPLTD        ! Depth for average soil water   cm
      REAL          SWPLTH        ! Upper limit on soil water,plt  %
      REAL          SWPLTL        ! Lower limit on soil water,plt  %
      REAL          TBGF          ! Temperature base,grain filling C
      REAL          TDAY          ! Temperature during light hours C
      REAL          TFAC4         ! Temperature factor function    #
      REAL          TFG           ! Temperature factor,growth 0-1  #
      REAL          TFGF          ! Temperature factor,gr fill 0-1 #
      REAL          TFGN          ! Temperature factor,grain N 0-1 #
      REAL          TFGNUM        ! Temperature factor,gr # 0-1    #
      REAL          TFH           ! Temperature factor,hardening   #
      REAL          TFOUT         ! Temperature factor,fn output   #
      REAL          TFP           ! Temperature factor,phs 0-1     #
      REAL          TFV           ! Temperature factor,vernalizatn #
      REAL          TI1LF         ! Tiller 1 site (leaf #)         #
      REAL          TILDF         ! Tiller death rate,max fraction #
      REAL          TKILL         ! Temperature for plant death    C
      CHARACTER*10  TL10FROMI     ! Temporary line from integer    text
      INTEGER       TLIMIT        ! Number of days temp limited gr #
      REAL          TMAX          ! Temperature maximum            C
      REAL          TMAXM         ! Temperature maximum,monthly av C
      REAL          TMAXSUM       ! Temperature maximum,summed     C
      REAL          TMAXX         ! Temperature max during season  C
      REAL          TMEAN         ! Temperature mean (TMAX+TMIN/2) C
      REAL          TMEAN20       ! Temperature mean over 20 days  C
      REAL          TMEAN20A      ! Temperature mean,20 d~anthesis C
      REAL          TMEAN20P      ! Temperature mean,20 d>planting C
      REAL          TMEAN20S      ! Temperature sum over 20 days   C
      REAL          TMEAND(20)    ! Temperature mean,specific day  C
      REAL          TMEANNUM      ! Temperature means in sum       #
      REAL          TMEANS        ! Temperature mean under snow    C
      REAL          TMIN          ! Temperature minimum            C
      REAL          TMINM         ! Temperature minimum,monthly av C
      REAL          TMINN         ! Temperature min during season  C
      REAL          TMINSUM       ! Temperature minimum,summed     C
      INTEGER       TN            ! Treatment number               #
      CHARACTER*25  TNAME         ! Treatment name                 text
      REAL          TNIGHT        ! Temperature during night hours C
      INTEGER       TNI           ! Treatment number,initial value #
      REAL          TNUM          ! Tiller (incl.main stem) number #/p
      REAL          TNUMAD        ! Tiller (incl.main stem) number #/m2
      REAL          TNUMD         ! Tiller number death            #/p
      REAL          TNUMG         ! Tiller number growth           #/p
      REAL          TNUML(LNUMX)  ! Tiller # at leaf position      #/p
      REAL          TNUMLOSS      ! Tillers lost through death     #/p
      REAL          TRDV1(4)      ! Temp response,development 1    #
      REAL          TRDV2(4)      ! Temp response,development 2    #
      REAL          TRGFN(4)      ! Temp response,grain fill,N     #
      REAL          TRGFW(4)      ! Temp response,grain fill,d.wt. #
      REAL          TRGNO(4)      ! Temp response,grain number     #
      REAL          TRLFG(4)      ! Temp response,leaf growth      #
      REAL          TRLTH(4)      ! Temp response,lethal tempature #
      REAL          TRPHS(4)      ! Temp response,photosynthesis   #
      CHARACTER*40  TRUNNAME      ! Treatment+run composite name   text
      REAL          TRVRN(4)      ! Temp response,vernalization    #
      REAL          TRWUP         ! Total water uptake,potential   mm
      INTEGER       TSDAT         ! Terminal spkelet date          #
      REAL          TSDEP         ! Average temp in top 10 cm soil C
      REAL          TT            ! Daily thermal time             C.d
      REAL          TT20          ! Thermal time mean over 20 days C
      REAL          TT20S         ! Thermal time sum over 20 days  C
      REAL          TTD(20)       ! Thermal time,specific day      C
      REAL          TTNUM         ! Thermal time means in sum      #
      REAL          TTOUT         ! Thermal units output from func C.d
      REAL          TTTMP         ! Thermal time,temporary value   C
      INTEGER       TVI1          ! Temporary integer variable     #
      INTEGER       TVI2          ! Temporary integer variable     #
      INTEGER       TVI3          ! Temporary integer variable     #
      INTEGER       TVI4          ! Temporary integer variable     #
      INTEGER       TVILENT       ! Temporary integer,function op  #
      REAL          TVR1          ! Temporary real variable        #
      REAL          UH2O(NL)      ! Uptake of water                cm/d
      REAL          VANC          ! Vegetative actual N conc       #
      CHARACTER*6   VARNO         ! Variety identification code    text
      CHARACTER*6   VARNOP        ! Variety identification code    text
      REAL          VDLOST        ! Vernalization lost (de-vern)   d
      REAL          VERSION       ! Version # for internal changes #
      REAL          VERSIOND      ! Version # default              #
      REAL          VF            ! Vernalization factor 0-1       #
      REAL          VF0           ! Vernalization fac,unvernalized #
      CHARACTER*16  VRNAME        ! Variety name or identifier     text
      REAL          WFG           ! Water factor,growth 0-1        #
      REAL          WFGAV(9)      ! Water factor,growth,average    #
      REAL          WFGC          ! Water factor,growth,cumulative #
      REAL          WFGEU         ! Water factor,GE,upper limit    #
      REAL          WFGU          ! Water factor,growth,upper      #
      REAL          WFLF(LNUMX)   ! H2O factor for leaf,average    #
      REAL          WFNUL         ! Water factor,N uptake,lower    #
      REAL          WFNUU         ! Water factor,N uptake,upper    #
      REAL          WFP           ! Water factor,photosynthsis 0-1 #
      REAL          WFPAV(9)      ! Water factor,phs,average 0-1   #
      REAL          WFPC          ! Water factor,phs,cumulative    #
      REAL          WFPGF         ! Water factor,phs,grain filling #
      REAL          WFPU          ! Water factor,phs,upper         #
      REAL          WFRDG         ! Water factor,root depth growth #
      REAL          WFRG          ! Water factor,root growth 0-1   #
      REAL          WFS           ! Water factor,senescence 0-1    #
      REAL          WFSAG         ! Water factor,excess,gen.sens   #
      REAL          WFSF          ! Water factor,fraction senesced #
      REAL          WFSU          ! Water factor,senescence,upper  #
      REAL          WFTI          ! Water factor,tillering 0-1     #
      REAL          WFTIL         ! Water factor,tillering,lower   #
      REAL          WFTIU         ! Water factor,tillering,upper   #
      CHARACTER*10  WHSTGNAM(20)  ! Wheat stage names              text
      REAL          WINDSP        ! Wind speed                     km/d
      REAL          WUPR          ! Water pot.uptake/demand        #
      REAL          WAVR          ! Water available/demand         #
      REAL          XDEP          ! Depth to bottom of layer       cm
      REAL          XDEPL         ! Depth to top of layer          cm
      REAL          XNFS          ! N labile fraction,standard     #
      REAL          XSTAGE        ! Stage of development           #
      INTEGER       YEAR          ! Year                           #
      INTEGER       YEARDOY       ! Year+Doy (7digits)             #
      INTEGER       YEARHARF      ! Harvest year+doy,fixed         #
      INTEGER       YEARPLT       ! Year(or Yr)+Doy,planting date  #
      INTEGER       YEARPLTP      ! Year(or Yr)+Doy,planting trget #
      INTEGER       YEARSIM       ! Year+Doy for simulation start  #
      INTEGER       YRHARF        ! Harvest date,fixed             #
      CHARACTER*1   YRHARFF       ! Year+Doy flag for message      text
      REAL          YVAL1         ! Output from array function     #
      REAL          ZSTAGE        ! Zadoks stage of development    #
      REAL          ZSTAGEP       ! Zadoks stage,previous day      #

      ! Variables expressed on a per hectare basis
      ! Inputs
      REAL          AMTNIT        ! Cumulative amount of N applied kg/ha
      REAL          ANFER(200)    ! N amount in fertilizer appln   kg/ha
      ! Outputs
      REAL          CNAA          ! Canopy N at anthesis           kg/ha
      REAL          CWAA          ! Canopy weight at anthesis      kg/ha
      REAL          CARBOA        ! Carbohydrate assimilated       kg/ha
      REAL          CARBOAC       ! Carbohydrate assimilated,cum   kg/ha
      REAL          CHWAD         ! Chaff weight                   kg/ha
      REAL          CNAD          ! Canopy nitrogen                kg/ha
      REAL          CNADSTG(20)   ! Canopy nitrogen,specific stage kg/ha
      REAL          CWAD          ! Canopy weight                  kg/ha
      REAL          CWADSTG(20)   ! Canopy weight,particular stage kg/ha
      REAL          DNAD          ! Dead N retained on plant       kg/ha
      REAL          DWAD          ! Dead weight retained on plant  kg/ha
      REAL          EWAD          ! Ear weight                     kg/ha
      REAL          GNAD          ! Grain N                        kg/ha
      REAL          GWAD          ! Grain weight                   kg/ha
      REAL          LLNAD         ! Leaf lamina nitrogen           kg/ha
      REAL          LLWAD         ! Leaf lamina weight             kg/ha
      REAL          LSWAD         ! Leaf sheath weight             kg/ha
      REAL          NUAD          ! N uptake,cumulative            kg/ha
      REAL          NUAG          ! N uptake                       kg/ha
      REAL          RESCAL(0:20)  ! Residue C at harvest,by layer  kg/ha
      REAL          RESCALG(0:20) ! Residue C added,by layer       kg/ha
      REAL          RESLGAL(0:20) ! Residue lignin,harvest,bylayer kg/ha
      REAL          RESLGALG(0:20)! Residue lignin added,layer     kg/ha
      REAL          RESNAL(0:20)  ! Residue N at harvest by layer  kg/ha
      REAL          RESNALG(0:20) ! Residue N added,by layer       kg/ha
      REAL          RESPAC        ! Respiration,total,cumulative   kg/ha
      REAL          RESWAL(0:20)  ! Residue om added by layer      kg/ha
      REAL          RESWALG(0:20) ! Residue om at harvest,by layer kg/ha
      REAL          RNAD          ! Root N                         kg/ha
      REAL          RSNAD         ! Reserve N                      kg/ha
      REAL          RSWAA         ! Reserves weight at anthesis    kg/ha
      REAL          RSWAD         ! Reserves weight                kg/ha
      REAL          RSWADPM       ! Reserves weight,post maturity  kg/ha
      REAL          RTWTAL(20)    ! Root weight by layer           kg/ha
      REAL          RWAD          ! Root weight                    kg/ha
      REAL          SDNAD         ! Seed N                         kg/ha
      REAL          SDRATE        ! Seeding 'rate'                 kg/ha
      REAL          SDWAD         ! Seed weight                    kg/ha
      CHARACTER*6   SENC0         ! Senesced C added to surface    kg/ha
      REAL          SENCAL(0:20)  ! Senesced C,by layer            kg/ha
      REAL          SENCALG(0:20) ! Senesced C added,by layer      kg/ha
      REAL          SENCAS        ! Senesced C added to soil       kg/ha
      CHARACTER*6   SENCSTMP      ! Senesced C added to soil       kg/ha
      CHARACTER*6   SENL0         ! Senesced lignin added,litter   kg/ha
      REAL          SENLGAL(0:20) ! Senesced lignin added,by layer kg/ha
      REAL          SENLGALG(0:20)! Senesced lignin added,layer    kg/ha
      REAL          SENLGAS       ! Senesced lignin added to soil  kg/ha
      CHARACTER*6   SENLGSTMP     ! Senesced lignin added to soil  kg/ha
      CHARACTER*6   SENN0         ! Senesced N added to litter     kg/ha
      REAL          SENNAL(0:20)  ! Senesced N,by layer            kg/ha
      REAL          SENNALG(0:20) ! Senesced N added,by layer      kg/ha
      REAL          SENNAS        ! Senesced N added to soil       kg/ha
      CHARACTER*6   SENNSTMP      ! Senesced N added to soil       kg/ha
      CHARACTER*6   SENNT         ! Senesced N,litter+soil         kg/ha
      REAL          SENWAL(0:20)  ! Senesced om added by layer     kg/ha
      REAL          SENWALG(0:20) ! Senesced om added by layer     kg/ha
      REAL          SENWAS        ! Senesced weight,soil           kg/ha
      CHARACTER*6   SENWT         ! Senesced wt,to litter+soil     kg/ha
      REAL          SNAD          ! Stem N (stem+sheath+rs)        kg/ha
      REAL          STWAD         ! Stem (actal) weight            kg/ha
      REAL          STLSRWAD      ! Stem wt (stem+sheath+reserves) kg/ha
      REAL          TNAD          ! Total nitrogen (tops+roots)    kg/ha
      REAL          TWAD          ! Total weight (tops+roots)      kg/ha
      REAL          UNH4ALG(20)   ! Uptake of NH4 N                kg/ha
      REAL          UNO3ALG(20)   ! Uptake of NO3 N                kg/ha
      REAL          VNAD          ! Vegetative canopy nitrogen     kg/ha
      REAL          VWAD          ! Vegetative canopy weight       kg/ha

      !REAL          sradip        ! Srad interception,whole can    %
      !REAL          sradipcn(5)   ! Srad interception,component    %

      PARAMETER     (BLANK = ' ')
      PARAMETER     (RUNINIT = 1)
      PARAMETER     (SEASINIT = 2)
      PARAMETER     (RATE = 3)
      PARAMETER     (INTEGR = 4)
      PARAMETER     (OUTPUT = 5)
      PARAMETER     (FINAL = 6)

      ! Condition at end of phase
      DATA BASTGNAM/'Max Prim  ','End Veg   ','End Ear Gr',
     1              'Bg Gr Fill','End Gr Fil','Harvest   ',
     2              'Sowing    ','Germinate ','Emergence ',
     3              'Failure   ','End Crop  ','          ',
     4              '          ','          ','          ',
     5              '          ','          ','          ',
     6              '          ','          '/

      DATA WHSTGNAM/'Term Spklt','End Veg   ','End Ear Gr',
     1              'Beg Gr Fil','End Gr Fil','Harvest   ',
     2              'Sowing    ','Germinate ','Emergence ',
     3              'Failure   ','End crop  ','          ',
     4              '          ','          ','          ',
     5              '          ','          ','          ',
     6              '          ','          '/

      YEARDOY = YEAR*1000 + DOY

      IF (DYNAMIC.EQ.RUNINIT .OR. DYNAMIC.EQ.SEASINIT) THEN

        ! Following is used because Dssat has seasinit after runinit

        IF (CFLINIT.EQ.'Y') THEN
          TN = TNI
          CN = CNI
          SN = SNI
          ON = ONI
          RN = RNI
          KCAN = KCANI
          KEP = KEPI
          PORMIN = PORMINI
          RWUMX = RWUMXI
          STGDOY = 9999999
          RETURN
        ENDIF


        ! LAH FOR PAUL'S PROBLEM
        IF (FNUMWRK.LE.0.OR.FNUMWRK.GT.1000) 
     &    CALL Getlun ('WORK.OUT',fnumwrk)
        INQUIRE (FILE = 'Work.out',OPENED = fopen)
        IF (.NOT.fopen) OPEN (UNIT = fnumwrk,FILE = 'WORK.OUT')
        
        TVI1 = TVILENT(FILEIOIN)
        IF (FILEIOIN(TVI1-2:TVI1).EQ.'INP') THEN
          FILEIOIN(TVI1:TVI1) = 'H'
          fileiot = 'DS4'
        ELSE
          fileiot = 'XFL'
          RNMODE = ' '      ! For time being not used.
        ENDIF
        FILEIO = ' '
        FILEIO(1:TVI1) = FILEIOIN(1:TVI1)


        IF (DYNAMIC.EQ.RUNINIT) THEN

          MODULE(1:8) = 'CSCER040'
          GENFLCHK(3:8) = 'CER040'

          ! Parameters
          STDDAY = 20.0   ! TT in standard day
          PARADFAC = 0.5  ! PAR in SRAD (fr)
          VERSIOND = 4.03 ! Default version
          STEPNUM = 1     ! Step number per day set to 1

          YEARSIM = YEARDOY


          ! LAH FOR PAUL'S PROBLEM
C         IF (FNUMWRK.LE.0.OR.FNUMWRK.GT.1000) THEN
C           CALL Getlun ('WORK.OUT',fnumwrk)
C           INQUIRE (FILE = 'Work.out',OPENED = fopen)
C           IF (.NOT.fopen) OPEN (UNIT = fnumwrk,FILE = 'WORK.OUT')
C         ENDIF

          CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'GENERAL',version)
          IF (VERSION.LE.0.0) VERSION = VERSIOND

          ! Control switches for error outputs and input echo
          IF (FILEIOT.NE.'DS4') THEN
            CALL XREADC (FILEIO,TN,RN,SN,ON,CN,'OUTPUTS',idetou)
          ENDIF
        ENDIF

        ISTAGE = 7   ! Pre-planting
        XSTAGE = 7.0 ! Pre-planting
        YEARPLT = 9999999
        YEARPLTP = 9999999
        DYNAMICI = DYNAMIC

        IF (RUN.EQ.1.AND.RUNI.LE.1) THEN
          CFGDFILE = ' '
          CUFILE = ' '
          CUDIRFLE = ' '
          CROPP = '  '
        ENDIF

        ! Planting information
        CALL XREADC(FILEIO,TN,RN,SN,ON,CN,'PLANT',iplti)
        IF(IPLTI.EQ.'A')THEN
          CALL XREADI(FILEIO,TN,RN,SN,ON,CN,'PFRST',pwdinf)
          PWDINF = CSYEARDOY(pwdinf)
          CALL CSYR_DOY(PWDINF,PWYEARF,PWDOYF)
          CALL XREADI(FILEIO,TN,RN,SN,ON,CN,'PLAST',pwdinl)
          PWDINL = CSYEARDOY(pwdinl)
          CALL CSYR_DOY(PWDINL,PWYEARL,PWDOYL)
          CALL XREADR(FILEIO,TN,RN,SN,ON,CN,'PH2OL',swpltl)
          CALL XREADR(FILEIO,TN,RN,SN,ON,CN,'PH2OU',swplth)
          CALL XREADR(FILEIO,TN,RN,SN,ON,CN,'PH2OD',swpltd)
          CALL XREADR(FILEIO,TN,RN,SN,ON,CN,'PSTMX',ptx)
          CALL XREADR(FILEIO,TN,RN,SN,ON,CN,'PSTMN',pttn)
          CALL XREADI(FILEIO,TN,RN,SN,ON,CN,'HFRST',hfirst)
          HFIRST = CSYEARDOY(hfirst)
          CALL CSYR_DOY(HFIRST,HYEARF,HDOYF)
          CALL XREADI(FILEIO,TN,RN,SN,ON,CN,'HLAST',hlast)
          HLAST = CSYEARDOY(hlast)
          CALL CSYR_DOY(HLAST,HYEARL,HDOYL)
          WRITE (fnumwrk,*) ' '
          IF (DYNAMIC.EQ.SEASINIT) THEN
            IF (PWDINF.GT.0 .AND. PWDINF.LT.YEARDOY) THEN
              WRITE (fnumwrk,*) 'Automatic planting set: ',yeardoy
              WRITE (fnumwrk,*)'PFIRST,PLAST AS READ  : ',pwdinf,pwdinl
              WRITE (fnumwrk,*)'HFIRST,HLAST AS READ  : ',hfirst,hlast
              TVI1 = INT((YEARDOY-PWDINF)/1000)
              PWDINF = PWDINF + TVI1*1000
              PWDINL = PWDINL + TVI1*1000
              IF (HFIRST.GT.0) HFIRST = HFIRST + TVI1*1000
              HLAST  = HLAST + (TVI1+1)*1000
            ENDIF
            WRITE (fnumwrk,*) 'PFIRST,PLAST AS USED  : ',pwdinf,pwdinl
            WRITE (fnumwrk,*) 'HFIRST,HLAST AS USED  : ',hfirst,hlast
          ENDIF
        ELSE
          CALL XREADI(FILEIO,TN,RN,SN,ON,CN,'PDATE',pdate)
          CALL CSYR_DOY(PDATE,PLYEAR,PLDAY)
          IF (PLDAY.GE.DOY) THEN
            YEARPLTP = YEAR*1000 + PLDAY
          ELSEIF (PLDAY.LT.DOY) THEN
            YEARPLTP = (YEAR+1)*1000 + PLDAY
          ENDIF
          WRITE(fnumwrk,*)' '
        ENDIF

        CALL Getlun ('OUTO',fnumtmp)

        arg = ' '
        arglen = 0
        CALL GETARG (5,ARG)
        IF (arglen.GT.0 .AND. arglen.LT.100) THEN
         mode = arg (1:arglen)
         tvi1 = Tvilent (mode)
         IF (tvi1.EQ.0) mode = ' '
        ELSE
         mode = 'I'
        ENDIF

        arg = ' '
        tvi2 = 0
        tvi3 = 0
        tvi4 = 0
        CALL GETARG (0,arg)
        DO tvi1 = 1,arglen
          IF (arg(tvi1:tvi1).EQ.'\') tvi2=tvi1
          IF (arg(tvi1:tvi1).EQ.'.') tvi3=tvi1
          IF (arg(tvi1:tvi1).EQ.' ' .AND. tvi4.EQ.0) tvi4=tvi1
        ENDDO
        IF (TVI3.EQ.0 .AND. TVI4.GT.0) THEN
          tvi3 = tvi4
        ELSEIF (TVI3.EQ.0 .AND. TVI4.EQ.0) THEN
          tvi3 = arglen+1
        ENDIF
        MODEL = ARG(TVI2+1:TVI3-1)

        WRITE(fnumwrk,*)'RUN OVERVIEW'
        WRITE(fnumwrk,*)' MODEL   ',MODEL
        WRITE(fnumwrk,*)' MODULE  ',MODULE
        WRITE(fnumwrk,'(A10,F8.2)')'  VERSION ',VERSION
        WRITE(fnumwrk,'(A29,I1)')'  CROP COMPONENT             ',CN
        WRITE(fnumwrk,'(A24,A6)')
     &   '  GENOTYPE FILES CODE   ',GENFLCHK(3:8)
        IF (IPLTI.NE.'A')
     &  WRITE(fnumwrk,'(A23,I7)') '  PLANTING DATE TARGET ',YEARPLTP

        ! Create composite run variable
        IF (RUNI.LT.10) THEN
          WRITE (RUNRUNI,'(I3,A1,I1,A3)') RUN,',',RUNI,'   '
        ELSEIF (RUNI.GE.10.AND.RUNI.LT.100) THEN
          WRITE (RUNRUNI,'(I3,A1,I2,A2)') RUN,',',RUNI,'  '
        ELSE
          WRITE (RUNRUNI,'(I3,A1,I3,A1)') RUN,',',RUNI,' '
        ENDIF
        IF (RUN.LT.10) THEN
          RUNRUNI(1:6) = RUNRUNI(3:8)
          RUNRUNI(7:8) = '  '
          ! Below is to give run number only for first run
          IF (RUNI.LE.1) RUNRUNI(2:8) = '       '
        ELSEIF (RUN.GE.10.AND.RUN.LT.100) THEN
          RUNRUNI(1:7) = RUNRUNI(2:8)
          RUNRUNI(8:8) = ' '
          ! Below is to give run number only for first run
          IF (RUNI.LE.1) RUNRUNI(3:8) = '      '
        ENDIF

        CALL XREADC (FILEIO,TN,RN,SN,ON,CN,'CR',crop)
        CALL UCASE (CROP)
        CALL XREADC (FILEIO,TN,RN,SN,ON,CN,'INGENO',varno)
        IF (varno.EQ.'-99   ') THEN
          WRITE(fnumwrk,*)' '
          WRITE(fnumwrk,*)'Cultivar number not found!'
          WRITE(fnumwrk,*)'Maybe an error in the the X-file headings'
          WRITE(fnumwrk,*)'(eg.@-line dots connected to next header)'
          WRITE(fnumwrk,*)'Please check'
          WRITE (*,*) ' Problem reading the X-file'
          WRITE (*,*) ' Cultivar number not found!'
          WRITE (*,*) ' Maybe an error in the the X-file headings'
          WRITE (*,*) ' (eg.@-line dots connected to next header)'
          WRITE (*,*) ' Program will have to stop'
          WRITE (*,*) ' Check WORK.OUT for details of run'
          STOP ' '
        ENDIF
        IF (varno.EQ.'-99   ') THEN
          WRITE(fnumwrk,*)' '
          WRITE(fnumwrk,*)'Cultivar number not found!'
          WRITE(fnumwrk,*)'Maybe an error in the the X-file headings'
          WRITE(fnumwrk,*)'(eg.@-line dots connected to next header)'
          WRITE(fnumwrk,*)'Please check'
          WRITE (*,*) ' Problem reading the X-file'
          WRITE (*,*) ' Cultivar number not found!'
          WRITE (*,*) ' Maybe an error in the the X-file headings'
          WRITE (*,*) ' (eg.@-line dots connected to next header)'
          WRITE (*,*) ' Program will have to stop'
          WRITE (*,*) ' Check WORK.OUT for details of run'
          STOP ' '
        ENDIF
        CALL XREADC (FILEIO,TN,RN,SN,ON,CN,'CNAME',vrname)
        CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'PPOP',pltpopp)
        CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'PLRS',rowspc)
        CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'PLDP',sdepth)
        CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'PLWT',sdrate)
        CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'PLMAG',plmage)
        IF (PLMAGE.LE.-99.0) THEN
          CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'PAGE',plmage)
          IF (PLMAGE.LE.-99.0) PLMAGE = 0.0
        ENDIF

        CALL XREADT (FILEIO,TN,RN,SN,ON,CN,'TNAME',tname)
        CALL XREADT (FILEIO,TN,RN,SN,ON,CN,'SNAME',runname)

        CALL XREADT (FILEIO,TN,RN,SN,ON,CN,'ENAME',ename)
        CALL XREADT (FILEIO,TN,RN,SN,ON,CN,'EXPER',excode)
        CALL UCASE (EXCODE)

        CALL XREADI (FILEIO,TN,RN,SN,ON,CN,'HDATE',yrharf)
        YEARHARF = CSYEARDOY(yrharf)
        CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'HPC',hpc)
        CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'HBPC',hbpc)
        CALL XREADC (FILEIO,TN,RN,SN,ON,CN,'HARVS',ihari)
        IF (hpc .LT. 0.0) hpc = 100.0   ! Harvest %
        IF (hbpc .LT. 0.0) hbpc = 0.0

        ! Read fertilizer info (for calculation of N appln during cycle)
        CALL XREADC(FILEIO,TN,RN,SN,ON,CN,'FERTI',iferi)
        CALL XREADIA(FILEIO,TN,RN,SN,ON,CN,'FDATE','200',fday)
        CALL XREADRA(FILEIO,TN,RN,SN,ON,CN,'FAMN','200',anfer)
        NFERT = 0
        DO I = 1, 200
          IF (anfer(I).LE.0.0) EXIT
          FDAY(I) = CSYEARDOY(fday(i))
          NFERT = NFERT + 1
        ENDDO

        CALL LTRIM (RUNNAME)
        CALL LTRIM (TNAME)
        LENTNAME = MIN(15,LEN(TRIM(TNAME)))
        LENRNAME = MIN(15,LEN(TRIM(RUNNAME)))
        TRUNNAME = TNAME(1:LENTNAME)//' ('//RUNNAME(1:LENRNAME)//')'

        IF (FILEIOT(1:2).EQ.'DS') THEN
          IF (CROP.NE.CROPP .OR. VARNO.NE.VARNOP) THEN
            CALL XREADC (FILEIO,TN,RN,SN,ON,CN,'CFILE',cufile)
            CALL XREADC (FILEIO,TN,RN,SN,ON,CN,'CDIR',pathcr)
            PATHL = INDEX(PATHCR,BLANK)
            IF (PATHL.LE.5.OR.PATHCR(1:3).EQ.'-99') THEN
              CUDIRFLE = CUFILE
            ELSE
              IF (PATHCR(PATHL-1:PATHL-1) .NE. '\') THEN
                CUDIRFLE = PATHCR(1:(PATHL-1)) // '\' // CUFILE
              ELSE
                CUDIRFLE = PATHCR(1:(PATHL-1)) // CUFILE
              ENDIF
            ENDIF
            CALL XREADC (FILEIO,TN,RN,SN,ON,CN,'EFILE',ecfile)
            CALL XREADC (FILEIO,TN,RN,SN,ON,CN,'EDIR',pathcr)
            PATHL = INDEX(PATHCR,BLANK)
            IF (PATHL.LE.5.OR.PATHCR(1:3).EQ.'-99') THEN
              ECDIRFLE = ECFILE
            ELSE
              IF (PATHCR(PATHL-1:PATHL-1) .NE. '\') THEN
                ECDIRFLE = PATHCR(1:(PATHL-1)) // '\' // ECFILE
              ELSE
                ECDIRFLE = PATHCR(1:(PATHL-1)) // ECFILE
              ENDIF
            ENDIF
            CALL XREADC (FILEIO,TN,RN,SN,ON,CN,'SPFILE',spfile)
            CALL XREADC (FILEIO,TN,RN,SN,ON,CN,'SPDIR',pathcr)
            PATHL = INDEX(PATHCR,BLANK)
            IF (PATHL.LE.5.OR.PATHCR(1:3).EQ.'-99') THEN
              SPDIRFLE = SPFILE
            ELSE
              IF (PATHCR(PATHL-1:PATHL-1) .NE. '\') THEN
                SPDIRFLE = PATHCR(1:(PATHL-1)) // '\' // SPFILE
              ELSE
                SPDIRFLE = PATHCR(1:(PATHL-1)) // SPFILE
              ENDIF
            ENDIF
          ENDIF

          CALL XREADC (FILEIO,TN,RN,SN,ON,CN,'ECO#',econo)
          CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'P1V',p1v)
          CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'P1D',p1d)
          CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'P5',pd(5))
          CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'G1',g1cwt)
          CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'G2',g2kwt)
          CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'G3',g3)
          CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'PHINT',phints)

        ELSE

          IF (CUDIRFLE.NE.CUDIRFLP .OR. VARNO.NE.VARNOP) THEN
            arg=' '
            tvi3=0
            CALL GETARG(0,arg)
            DO tvi1 = 1,arglen
              IF(arg(tvi1:tvi1).EQ.'\')tvi2=tvi1
              IF(arg(tvi1:tvi1).EQ.'.')tvi3=tvi1
            ENDDO
            IF(TVI3.EQ.0)then
              tvi3=arglen+1
              ARG(TVI3:TVI3)='.'
            ENDIF
            cfgdfile = ' '
            cfgdfile = ARG(1:TVI3)//'CFG'
            ! Change cfg file name from module specific to general
            DO L = LEN(TRIM(CFGDFILE)),1,-1
              IF (CFGDFILE(L:L).EQ.'\') EXIT
            ENDDO
            IF (L.GT.1) THEN
              cfgdfile = CFGDFILE(1:L-1)//'\'//'CROPSIM.CFG'
            ELSE
              cfgdfile(1:11) = 'CROPSIM.CFG'
            ENDIF
            INQUIRE (FILE = cfgdfile,EXIST = fflag)
            IF (.NOT.fflag) THEN
              WRITE (fnumwrk,*)
     &         'Could not find Cfgdfile: ',cfgdfile(1:60)
              WRITE (*,*) ' Could not find Cfgdfile: ',cfgdfile(1:60)
              WRITE (*,*) ' Program will have to stop'
              WRITE (*,*) ' Check WORK.OUT for details of run'
              STOP ' '
            ELSE
              WRITE (fnumwrk,*) ' Config.file: ',CFGDFILE(1:60)
            ENDIF

            cufile = crop//module(3:8)//'.CUL'
            INQUIRE (FILE = cufile,EXIST = fflag)
            IF (fflag) THEN
              cudirfle = cufile
            ELSE
              CALL Finddir (fnumtmp,cfgdfile,'CRD',cufile,cudirfle)
            ENDIF
            IF (mode.EQ.'G') cufile = cufile(1:7)//'1.CUL'

            ecfile = crop//module(3:8)//'.ECO'
            spfile = crop//module(3:8)//'.SPE'
            INQUIRE (FILE = ecfile,EXIST = fflag)
            IF (fflag) THEN
              ecdirfle = ecfile
              spdirfle = spfile
            ELSE
              CALL Finddir (fnumtmp,cfgdfile,'CRD',ecfile,ecdirfle)
              CALL Finddir (fnumtmp,cfgdfile,'CRD',spfile,spdirfle)
            ENDIF
          ENDIF

        ENDIF     ! End Genotype file names creation

        IF (MODE.EQ.'G') THEN
          cufile = cufile(1:7)//'1.CUL'
          cudirfle = ' '
          cudirfle(1:12) = cufile
        ENDIF

        GENFLCHK = CROP//GENFLCHK(3:8)

        IF (FILEIOT .NE. 'DS4') THEN
          IF (CUDIRFLE.NE.CUDIRFLP .OR. VARNO.NE.VARNOP) THEN
            WRITE (fnumwrk,*) ' '
            ! Check file versions
            CALL FVCHECK(CUDIRFLE,GENFLCHK)
            CALL CUREADC (CUDIRFLE,VARNO,'ECO#',econo)
            CALL CUREADR (CUDIRFLE,VARNO,'P1V',p1v)
            CALL CUREADR (CUDIRFLE,VARNO,'P1D',p1d)
            CALL CUREADR (CUDIRFLE,VARNO,'P5',pd(5))
            CALL CUREADR (CUDIRFLE,VARNO,'G1',g1cwt)
            CALL CUREADR (CUDIRFLE,VARNO,'G2',g2kwt)
            CALL CUREADR (CUDIRFLE,VARNO,'G3',g3)
            CALL CUREADR (CUDIRFLE,VARNO,'PHINT',phints)
            ! The following used when eco vars temporarily in cul
            !CALL CUREADR (CUDIRFLE,VARNO,'P1',PD(1))
            ! Below are 3.5 expressions
            !P1V = P1V*0.0054545 + 0.0003
            !P1D = P1D*0.002
            !PD(5) = 430.0 + PD(5)*20.00
            !IF (CROP.EQ.'BA') PD(5) = 300.0 + PD(5)*40.00
            !IF (G1 .NE. 0.0) G1 = 5.0 + G1* 5.00
            !IF (G2 .NE. 0.0) G2 = 0.65 + G2* 0.35
            !IF (G3 .NE. 0.0) G3 = -0.005 + G3* 0.35
          ENDIF
        ENDIF

        IF (ECDIRFLE.NE.ECDIRFLP .OR. ECONO.NE.ECONOP) THEN
          IF (RNMODE .NE. 'G') CALL FVCHECK(ECDIRFLE,GENFLCHK)
          WRITE (fnumwrk,*)' '
          CALL ECREADR (ECDIRFLE,ECONO,'P1DPE',p1dpe)
          CALL ECREADR (ECDIRFLE,ECONO,'P1',PD(1))
          CALL ECREADR (ECDIRFLE,ECONO,'P2',PD(2))
          CALL ECREADR (ECDIRFLE,ECONO,'P3',PD(3))
          CALL ECREADR (ECDIRFLE,ECONO,'P4',PD(4))
          CALL ECREADR (ECDIRFLE,ECONO,'P4SGE',P4SGE)
          CALL ECREADR (ECDIRFLE,ECONO,'PARUV',paruv)
          CALL ECREADR (ECDIRFLE,ECONO,'PARUR',parur)
          CALL ECREADR (ECDIRFLE,ECONO,'HTSTD',canhts)
          CALL ECREADR (ECDIRFLE,ECONO,'AWNS',awns)
          CALL ECREADR (ECDIRFLE,ECONO,'KCAN',kcan)
          CALL ECREADR (ECDIRFLE,ECONO,'LA1S',la1s)
          CALL ECREADR (ECDIRFLE,ECONO,'LAVS',lavs)
          CALL ECREADR (ECDIRFLE,ECONO,'LARS',lars)
          CALL ECREADR (ECDIRFLE,ECONO,'LAWRS',lawrs)
          CALL ECREADR (ECDIRFLE,ECONO,'LAWR2',lawr2)
          CALL ECREADR (ECDIRFLE,ECONO,'LLIFE',tvr1)
          LLIFE = INT(TVR1)
          CALL ECREADR (ECDIRFLE,ECONO,'RSFRS',rsfrs)
          CALL ECREADR (ECDIRFLE,ECONO,'TI1LF',ti1lf)
          CALL ECREADR (ECDIRFLE,ECONO,'GRNMN',grnmn)
          CALL ECREADR (ECDIRFLE,ECONO,'GRNS',grns)
          CALL ECREADR (ECDIRFLE,ECONO,'WFPU',wfpu)
          CALL ECREADR (ECDIRFLE,ECONO,'WFGU',wfgu)
          CALL ECREADR (ECDIRFLE,ECONO,'NFPU',nfpu)
          CALL ECREADR (ECDIRFLE,ECONO,'NFPL',nfpl)
          CALL ECREADR (ECDIRFLE,ECONO,'NFGU',nfgu)
          CALL ECREADR (ECDIRFLE,ECONO,'NFGL',nfgl)
          CALL ECREADR (ECDIRFLE,ECONO,'WFPGF',wfpgf)
          CALL ECREADR (ECDIRFLE,ECONO,'LT50H',lt50h)
          CALL ECREADR (ECDIRFLE,ECONO,'RDGS1',rdgs1)
          CALL ECREADR (ECDIRFLE,ECONO,'RDGS2',rdgs2)
          CALL ECREADR (ECDIRFLE,ECONO,'TBGF',TBGF)
        ENDIF

        IF (SPDIRFLE.NE.SPDIRFLP) THEN
          CALL FVCHECK(SPDIRFLE,GENFLCHK)
          CALL SPREADR (SPDIRFLE,'PEG',peg)
          CALL SPREADR (SPDIRFLE,'PECM',pecm)
          CALL SPREADR (SPDIRFLE,'P0',PD(0))
          CALL SPREADR (SPDIRFLE,'P1DT',p1dt)
          CALL SPREADR (SPDIRFLE,'P1VT',p1vt)
          CALL SPREADR (SPDIRFLE,'P4(1)',PD4FR(1))
          CALL SPREADR (SPDIRFLE,'P4(2)',PD4FR(2))
          CALL SPREADR (SPDIRFLE,'LATFR',latfr(1))
          LATFR(2) =  LATFR(1)       ! 0.8
          LATFR(3) =  LATFR(1)       ! 0.8
          LATFR(4) =  LATFR(1)       ! 0.8
          LATFR(5) =  0.8 * LATFR(1) ! 0.6
          LATFR(6) =  0.8 * LATFR(1) ! 0.6
          LATFR(7) =  0.6 * LATFR(1) ! 0.4
          LATFR(8) =  0.6 * LATFR(1) ! 0.4
          LATFR(9) =  0.6 * LATFR(1) ! 0.4
          LATFR(10) = 0.4 * LATFR(1) !  0.3
          LATFR(11) = 0.4 * LATFR(1) !  0.3
          LATFR(12) = 0.4 * LATFR(1) !  0.3
          LATFR(13) = 0.4 * LATFR(1) !  0.3
          LATFR(14) = 0.2 * LATFR(1) !  0.2
          LATFR(15) = 0.2 * LATFR(1) !  0.2
          LATFR(16) = 0.2 * LATFR(1) !  0.2
          LATFR(17) = 0.1 * LATFR(1) !  0.1
          LATFR(18) = 0.1 * LATFR(1) !  0.1
          LATFR(19) = 0.1 * LATFR(1) !  0.1
          LATFR(20) = 0.1 * LATFR(1) !  0.1
          CALL SPREADR (SPDIRFLE,'LSENS',lsens)
          CALL SPREADR (SPDIRFLE,'LSEWF',lsenwf)
          CALL SPREADR (SPDIRFLE,'LRETS',lrets)
          CALL SPREADR (SPDIRFLE,'TILDF',tildf)
          CALL SPREADR (SPDIRFLE,'WFSAG',wfsag)

          CALL SPREADRA (SPDIRFLE,'PTFS','10',ptfs)
          CALL SPREADRA (SPDIRFLE,'PTFA','10',ptfa)
          CALL SPREADRA (SPDIRFLE,'STFR','10',stfr)
          CALL SPREADRA (SPDIRFLE,'HTFR','10',htfr)
          CALL SPREADRA (SPDIRFLE,'LAFR','10',lafr)
          CALL SPREADR (SPDIRFLE,'LLIGP',lligp)
          CALL SPREADR (SPDIRFLE,'SLIGP',sligp)
          CALL SPREADR (SPDIRFLE,'RLIGP',rligp)
          CALL SPREADR (SPDIRFLE,'GLIGP',gligp)
          CALL SPREADR (SPDIRFLE,'RLWR',rlwr)
          CALL SPREADR (SPDIRFLE,'WFRDG',wfrdg)
          CALL SPREADR (SPDIRFLE,'RWUMX',rwumxs)
          rwumx = rwumxs
          CALL SPREADR (SPDIRFLE,'WFRG',wfrg)
          CALL SPREADR (SPDIRFLE,'NFRG',nfrg)
          CALL SPREADR (SPDIRFLE,'PORMN',pormin)
          CALL SPREADR (SPDIRFLE,'SDSZ',sdsz)
          CALL SPREADR (SPDIRFLE,'SDNPC',sdnpci)
          CALL SPREADR (SPDIRFLE,'WFGEU',wfgeu)
          CALL SPREADR (SPDIRFLE,'LT50S',lt50s)
          CALL SPREADR (SPDIRFLE,'P2(1)',pd2(1))
          CALL SPREADR (SPDIRFLE,'WFTIU',wftiu)
          CALL SPREADR (SPDIRFLE,'WFTIL',wftil)
          CALL SPREADR (SPDIRFLE,'NFTIU',nftiu)
          CALL SPREADR (SPDIRFLE,'NFTIL',nftil)
          CALL SPREADR (SPDIRFLE,'WFSU',wfsu)
          CALL SPREADR (SPDIRFLE,'WFSF',wfsf)
          CALL SPREADR (SPDIRFLE,'NFSU',nfsu)
          CALL SPREADR (SPDIRFLE,'NFSM',nfsm)
          CALL SPREADR (SPDIRFLE,'NFSF',nfsf)
          CALL SPREADR (SPDIRFLE,'WFNUL',wfnul)
          CALL SPREADR (SPDIRFLE,'WFNUU',wfnuu)
          CALL SPREADR (SPDIRFLE,'NO3MN',no3mn)
          CALL SPREADR (SPDIRFLE,'NH4MN',nh4mn)
          CALL SPREADR (SPDIRFLE,'RLFNU',rlfnu)
          CALL SPREADR (SPDIRFLE,'NUMAX',numax)
          CALL SPREADR (SPDIRFLE,'PDUR6',pd(6))
          CALL SPREADR (SPDIRFLE,'LSHFR',lshfr)
          CALL SPREADR (SPDIRFLE,'LNUMF',lnumf)
          CALL SPREADR (SPDIRFLE,'XNFS',xnfs)
          CALL SPREADR (SPDIRFLE,'GRNMX',grnmx)
          CALL SPREADR (SPDIRFLE,'RSEN',rsen)
          CALL SPREADR (SPDIRFLE,'SSEN',ssen)
          CALL SPREADR (SPDIRFLE,'SSSTG',ssstg)
          CALL SPREADR (SPDIRFLE,'SAWS',saws)
          CALL SPREADR (SPDIRFLE,'LSAWS',lsaws)
          CALL SPREADR (SPDIRFLE,'SDAFR',sdafr)
          CALL SPREADR (SPDIRFLE,'RLDGR',rldgr)
          CALL SPREADR (SPDIRFLE,'PTFX',ptfx)
          CALL SPREADR (SPDIRFLE,'RTREF',rtref)
          CALL SPREADR (SPDIRFLE,'LAWMN',lawfrmn)
          CALL SPREADR (SPDIRFLE,'HDUR',hdur)
          CALL SPREADR (SPDIRFLE,'CHFR',chfr)
          CALL SPREADR (SPDIRFLE,'CHRSF',chrsf)
          CALL SPREADR (SPDIRFLE,'CHSTG',chstg)
          CALL SPREADR (SPDIRFLE,'NTUPF',ntupf)
          IF (VERSION.GE.4.01) CALL SPREADR (SPDIRFLE,'RDGTH',rdgth)

          CALL SPREADRA (SPDIRFLE,'PLASF','10',plasf)

          CALL SPREADRA (SPDIRFLE,'LCNCS','10',lcncs)
          CALL SPREADRA (SPDIRFLE,'SCNCS','10',scncs)
          CALL SPREADRA (SPDIRFLE,'RCNCS','10',rcncs)
          CALL SPREADRA (SPDIRFLE,'LMNCS','10',lmncs)
          CALL SPREADRA (SPDIRFLE,'SMNCS','10',smncs)
          CALL SPREADRA (SPDIRFLE,'RMNCS','10',rmncs)

          CALL SPREADRA (SPDIRFLE,'TRDV1','4',trdv1)
          CALL SPREADRA (SPDIRFLE,'TRDV2','4',trdv2)
          CALL SPREADRA (SPDIRFLE,'TRLFG','4',trlfg)
          CALL SPREADRA (SPDIRFLE,'TRPHS','4',trphs)
          CALL SPREADRA (SPDIRFLE,'TRVRN','4',trvrn)
          CALL SPREADRA (SPDIRFLE,'TRLTH','4',trlth)
          CALL SPREADRA (SPDIRFLE,'TRGFW','4',trgfw)
          CALL SPREADRA (SPDIRFLE,'TRGFN','4',trgfn)
          CALL SPREADRA (SPDIRFLE,'TRGNO','4',trgno)

          CALL SPREADRA (SPDIRFLE,'CO2RF','10',co2rf)
          CALL SPREADRA (SPDIRFLE,'CO2FR','10',co2fr)

          CALL SPREADR (SPDIRFLE,'PART',part)
          CALL SPREADR (SPDIRFLE,'SRADT',sradt)
          KEP = (KCAN/(1.0-PART)) * (1.0-SRADT)

          LALOSSF = 0.2 ! Leaf area lost when tillers die
          PHINTCHG = 2  ! Leaf number for change in PHINT
          IF (VERSION.GE.4.09) THEN
            RLDGR = 1000.0    ! 120
            RLWR = 6.0        ! 0.98
            RWUMX = 0.04      ! 0.03
            WFRG = 1.0        ! 0.25
          ENDIF
        ENDIF

        IF (CROP.NE.CROPP .OR. VARNO.NE.VARNOP) THEN
          WRITE (fnumwrk,*) ' '
          WRITE (fnumwrk,*) 'DERIVED COEFFICIENTS'
          IF (P1VT.GT.0.0) THEN
            VF0 = 1.0 - P1V/P1VT
          ELSE
            VF0 = 1.0
          ENDIF
          PD4(1) = PD4FR(1) * PD(4)
          PD4(2) = PD4FR(2) * PD(4)
          PD4(3) = PD(4) -  PD4(1) - PD4(2)
          IF (PD4(3).LE.0.0) THEN
            Write (fnumwrk,*) 'Lag phase duration <= 0.0!   '
            Write (*,*) 'Lag phase duration <= 0.0!   '
            WRITE (*,*) 'Program will have to stop'
            WRITE (*,*) 'Check WORK.OUT for details of run'
            STOP ' '
          ENDIF
          G2 = G2KWT / (PD(5)+(PD(4)-PD4(1)-PD4(2))*0.50)
          WRITE(FNUMWRK,*)  ' G2 1 ',G2,G2KWT,PD(5),PD(4),PD4(1),PD4(2)
          WRITE (fnumwrk,*) '  Vf0         :  ',vf0
          WRITE (fnumwrk,*) '  Pd4(1)      :  ',pd4(1)
          WRITE (fnumwrk,*) '  Pd4(2)      :  ',pd4(2)
          WRITE (fnumwrk,*) '  Pd4(3)      :  ',pd4(3)
          WRITE (fnumwrk,*) '  G2          :  ',g2

          ! Critical stages
          ASTAGE = 4.0 + PD4(1) / PD(4)
          ASTAGEND = 4.0 + (PD4(1)+PD4(2)) / PD(4)
          WRITE (fnumwrk,*) '  Astage      :  ',astage
          WRITE (fnumwrk,*) '  Astagend    :  ',astagend

          ! Phase thresholds
          DO L = 0,10
            PTH(L) = 0.0
          ENDDO
          PTH(0) = PD(0)
          DO L = 1,10
            PTH(L) = PTH(L-1) + PD(L)
          ENDDO
        ENDIF

        G2 = G2KWT / (PD(5)+(PD(4)-PD4(1)-PD4(2))*0.50)

        WRITE (fnumwrk,*) ' '
        WRITE (fnumwrk,*) 'DERIVED DATA'
        ! Check seedrate and calculate seed reserves
        IF (SDRATE.LE.0.0) SDRATE = SDSZ*PLTPOPP*10.0
        ! Reserves = 80% of seed (42% Ceres3.5)
        SEEDRSI = (SDRATE/(PLTPOPP*10.0))*0.8
        SDCOAT = (SDRATE/(PLTPOPP*10.0))*0.2 ! Non useable material
        ! Seed N calculated from total seed
        SDNAP = (SDNPCI/100.0)*SDRATE
        SEEDNI = (SDNPCI/100.0)*(SDRATE/(PLTPOPP*10.0))
        WRITE (fnumwrk,'(A16,2F7.1,A6)') '   Seedrs,Seedn:',
     &        SEEDRSI*PLTPOPP*10.0,SEEDNI*PLTPOPP*10.0,' kg/ha'

        ! Check dormancy
        IF (PLMAGE.LT.0.0) THEN
          PEGD = PEG - (PLMAGE*STDDAY)
          WRITE (fnumwrk,*)' '
          WRITE (fnumwrk,'(A29,F6.2)')
     &     '  Planting material dormancy ',plmage
          WRITE (fnumwrk,'(A29,F6.2)')
     &     '  Emergence+dormancy degdays ',pegd
        ELSE
          PEGD = PEG
        ENDIF

        CFLFAIL = 'N'
        CFLINIT = 'N'
        CCOUNTV = 0

        AMTNIT = 0.
        AWNAI = 0.0          ! Awns not yet used
        CANHT = 0.0
        CNAA = 0.0
        CWAA = 0.0
        CARBOC = 0.0
        CHRS = 0.0
        CHWT = 0.0
        CH2OLIM = 0
        TLIMIT = 0
        CUMDU = 0.0
        CUMGEU = 0.0
        CUMTT = 0.0
        CUMTU = 0.0
        CUMVD = 0.0
        DAPM = 0
        DEADN = 0.0
        DEADWT = 0.0
        DLEAFN = 0.0
        DROOTN = 0.0
        DSTEMN = 0.0
        DU = 0.0
        GEDSUM = 0.0
        GESTAGE = 0.0
        GETMEAN = 0.0
        GETSUM = 0.0
        GFDSUM = 0.0
        GFTSUM = 0.0
        GMDSUM = 0.0
        GMTSUM = 0.0
        GRAINANC = 0.0
        GRAINN = 0.0
        GRAINNGL = 0.0
        GRAINNGR = 0.0
        GRAINNGS = 0.0
        GRNUM = 0.0
        GROGR = 0.0
        GROGRADJ = 0.0
        GROLF = 0.0
        GRORS = 0.0
        GRORSPM = 0.0
        GROST = 0.0
        GRORSGR = 0.0
        GWUD = 0.0
        GRWT = 0.0
        HARDI = 0.0
        HIAD = 0.0
        HIND = 0.0
        ICSDUR = 0
        LAI = 0.0
        LAIX = 0.0
        LANC = 0.0
        LCNC = 0.0
        LCNF = 0.0
        LEAFN = 0.0
        LNUMSD = 0.0
        LFWT = 0.0
        LNPCA = 0.0
        NFPC = 0.0
        NFGC = 0.0
        NUPR = 0.0
        NLIMIT = 0
        NUPC = 0.0
        NUPD = 0.0
        PARI = 0.0
        PARUED = 0.0
        PLA = 0.0
        PLAGT(1) = 0.0
        PLAGT(2) = 0.0
        PLAST = 0.0
        PTF = 0.0
        RAINC = 0.0
        RAINCA = 0.0
        RANC = 0.0
        RCNC = 0.0
        RCNF = 0.0
        RESPC = 0.0
        RMNC = 0.0
        ROOTN = 0.0
        ROOTNS = 0.0
        RSC = 0.0
        RSCA = 0.0
        RSN = 0.0
        RSNUSEG = 0.0
        RSNUSER = 0.0
        RSNUSET = 0.0
        RSTAGE = 0.0
        RSWT = 0.0
        RSWTPM = 0.0
        RTDEP = 0.0
        RTDEPG = 0.0
        RTWT = 0.0
        RTWTS = 0.0
        SAID = 0.0
        SANC = 0.0
        SCNC = 0.0
        SCNF = 0.0
        SDNC = 0.0
        SEEDNR = 0.0
        SEEDNT = 0.0
        SENCS = 0.0
        SENLA = 0.0
        SENLFG = 0.0
        SENLGS = 0.0
        SENLFGRS = 0.0
        SENNLFG = 0.0
        SENNLFGRS = 0.0
        SENNS = 0.0
        SENNSTG = 0.0
        SENNSTGRS = 0.0
        SENSTG = 0.0
        SENWS = 0.0
        SNOW = 0.0
        SRADC = 0.0
        STEMN = 0.0
        STWT = 0.0
        TNUM = 0.0
        TMEANNUM = 0.0
        TRWUP = 0.0
        TT = 0.0
        TTNUM = 0.0
        VANC = 0.0
        VF = 0.0
        VNAD = 0.0
        VWAD = 0.0
        WFPC = 0.0
        WFGC = 0.0
        ZSTAGE = 0.0
        ZSTAGEP = 0.0
        DO I = 30,1,-1
         LAIL(I)=0.0
        ENDDO
        DO I = 0, 20
          SENNL(I) = 0.0
          SENWL(I) = 0.0
          SENCL(I) = 0.0
          SENLGL(I) = 0.0
          SENNAL(I) = 0.0
          SENWAL(I) = 0.0
          SENCAL(I) = 0.0
          SENLGAL(I) = 0.0
          RESNAL(I) = 0.0
          RESWAL(I) = 0.0
          RESCAL(I) = 0.0
          RESLGAL(I) = 0.0
          RESNALG(I) = 0.0
          RESWALG(I) = 0.0
          RESCALG(I) = 0.0
          RESLGALG(I) = 0.0
        ENDDO
        DO I = 1, 9
          NFGAV(I) = 1.0
          NFPAV(I) = 1.0
          WFGAV(I) = 1.0
          WFPAV(I) = 1.0
        END DO
        DO I = 1, 10
          GPLA(I) = 0.0
        END DO
        DO I = 1, 20
          CWADSTG(I) = 0.0
          CNADSTG(I) = 0.0
          LAISTG(I) = 0.0
          LNUMSTG(I) = 0.0
          RLV(I) = 0.0
          RTWTL(I) = 0.0
          SRADD(I) = 0.0
          STGDOY(I) = 9999999
          TMEAND(I) = 0.0
          TTD(I) = 0.0
          UH2O(I) = 0.0
          ! Define names for growth stages
          STNAME(I) = '          '
          IF (CROP.EQ.'BA') THEN
            STNAME(I) = BASTGNAM (I)
          ELSEIF (CROP.EQ.'WH') THEN
            STNAME(I) = WHSTGNAM (I)
          ENDIF
        END DO
        DO I = 1, LNUMX
          LAP(I) = 0.0
          LAPS(I) = 0.0
          LAPP(I) = 0.0
          LATL(1,I) = 0.0
        ENDDO

        CO2FP = 1.0
        NFG = 1.0
        NFP = 1.0
        NFS = 1.0
        NFTI = 1.0
        RSFP = 1.0
        TFG = 1.0
        TFP = 1.0
        WFG = 1.0
        WFP = 1.0
        WFS = 1.0
        WFTI = 1.0
        WUPR = 1.0

        LNUMSG = 1

        ADAT = -99
        ADAT10 = -99
        ADATEND = -99
        DRDAT = -99
        JDAT = -99
        TSDAT = -99

        DEWDUR = -99.0
        GFTMEAN = -99.0
        GMTMEAN = -99.0
        LAGSTAGE = -99.0
        PARIP = -99.0
        PDADJ = -99.0
        SRAD20A = -99.0
        TMAXM = -99.0
        TMEAN20A = -99.0
        TMINM = 999.0
        TT20 = -99.0

        ! Write-out inputs if required
        IF (IDETOU.EQ.'Y') THEN
          WRITE (fnumwrk,*) ' '
          WRITE (fnumwrk,*) 'EXPERIMENTAL DETAILS'
          WRITE (fnumwrk,*) ' TRUNNAME      ',TRUNNAME
          WRITE (fnumwrk,'(A15,2F7.1)')'   PLTPOP,ROWSPC',PLTPOPP,ROWSPC
          WRITE (fnumwrk,'(A15,2F7.1)')'   SDEPTH,SDRATE',SDEPTH,SDRATE
          WRITE (fnumwrk,'(A15,2F7.1,A6)')'   SEEDRS,SEEDN ',
     &                     SEEDRSI*PLTPOPP*10.0,SEEDNI*PLTPOPP*10.0,
     &                     ' kg/ha'
          WRITE (fnumwrk,'(A15, F7.1)') '   PLMAGE       ',PLMAGE
          WRITE (fnumwrk,'(A15,I7,A7)') '   YRHARF,IHARI ',YRHARF,IHARI
          WRITE (fnumwrk,'(A15,2F7.1)') '   HPC,HBPC     ',HPC,HBPC
          WRITE (fnumwrk,'(A15,2A7  )') '   CROP,VARNO   ',CROP,VARNO

          IF (CUDIRFLE.NE.CUDIRFLP .OR. VARNO.NE.VARNOP) THEN
            WRITE (fnumwrk,*) ' '
            WRITE (fnumwrk,*) 'CULTIVAR DETAILS'
            WRITE (fnumwrk,*) '  Varno,econo :  ',varno,' ',econo
            WRITE (fnumwrk,*) '  P1v,p1d,p5  :  ',p1v,p1d,pd(5)
            WRITE (fnumwrk,*) '  G1,g2kwt,g3 :  ',g1cwt,g2kwt,g3
            WRITE (fnumwrk,*) '  G2 mg/oC.d  :  ',g2
            WRITE (fnumwrk,*) '  Phint       :  ',phints
          ENDIF

          IF (ECDIRFLE.NE.ECDIRFLP .OR. ECONO.NE.ECONOP) THEN
            WRITE (fnumwrk,*) ' '
            WRITE (fnumwrk,*) 'ECOTYPE DETAILS'
            WRITE (fnumwrk,*) '  TI1LF       :  ',ti1lf
            WRITE (fnumwrk,*) '  P1,2,3      :  ',(pd(i),i = 1,3)
            WRITE (fnumwrk,*) '  P4,5,6      :  ',(pd(i),i = 4,6)
            WRITE (fnumwrk,*) '  P4(1),(2)   :  ',pd4(1),pd4(2)         JED
            WRITE (fnumwrk,*) '  PARUV,PARUR :  ',paruv,parur
            WRITE (fnumwrk,*) '  WFGU,WFPU   :  ',wfgu,wfpu
            WRITE (fnumwrk,*) '  NFGU,NFGL   :  ',nfgu,nfgl
            WRITE (fnumwrk,*) '  NFPU,NFPL   :  ',nfpu,nfpl
            WRITE (fnumwrk,*) '  KCAN,KEP    :  ',kcan,kep
            WRITE (fnumwrk,*) '  LA1S,LLIFE  :  ',la1s,llife
            WRITE (fnumwrk,*) '  LAVS,LARS   :  ',lavs,lars
            WRITE (fnumwrk,*) '  AWNS,P4SGE  :  ',awns,p4sge
            WRITE (fnumwrk,*) '  LT50H       :  ',lt50h
            WRITE (fnumwrk,*) '  HTSTD       :  ',canhts
            WRITE (fnumwrk,*) '  LAWRS,LAWR2 :  ',lawrs,lawr2
            WRITE (fnumwrk,*) '  RSFRS       :  ',rsfrs
            WRITE (fnumwrk,*) '  NB.This is the fraction of stem ',
     &                              'assimilates going to reserves'
            WRITE (fnumwrk,*) '     instead of structural material.',
     &                             'Approximate equivalences are:'
            WRITE (fnumwrk,*) '     0.1 -> 10% reserves at anthesis ',
     &                             '0.8 -> 60% reserves at anthesis'
            WRITE (fnumwrk,*) '  LSENS       :  ',lsens
            WRITE (fnumwrk,*) '  WFSAG,WFPGF :  ',wfsag,wfpgf
          ENDIF

          IF (SPDIRFLE.NE.SPDIRFLP) THEN
            WRITE(fnumwrk,*) ' '
            WRITE(fnumwrk,*) 'SPECIES DETAILS'

            WRITE(fnumwrk,*) '  LATFR1      :  ',latfr(1)
            WRITE(fnumwrk,*) '  P1DT        :  ',p1dt
            WRITE(fnumwrk,*) '  P0          :  ',pd(0)
            WRITE(fnumwrk,*) '  TILDF       :  ',tildf
            WRITE(fnumwrk,*) '  LSEWF,LRETS :  ',lsenwf,lrets
            WRITE(fnumwrk,'(A8, 4F7.1)')   ' TRDV1',(trdv1(i),i = 1,4)
            WRITE(fnumwrk,'(A8, 4F7.1)')   ' TRDV2',(trdv2(i),i = 1,4)
            WRITE(fnumwrk,'(A8, 4F7.1)')   ' TRLFG',(trlfg(i),i = 1,4)
            WRITE(fnumwrk,'(A8, 4F7.1)')   ' TRPHS',(trphs(i),i = 1,4)
            WRITE(fnumwrk,'(A8, 4F7.1)')   ' TRVRN',(trvrn(i),i = 1,4)
            WRITE(fnumwrk,'(A8, 4F7.1)')   ' TRLTH',(trlth(i),i = 1,4)
            WRITE(fnumwrk,'(A8, 4F7.1)')   ' TRGFW',(trgfw(i),i = 1,4)
            WRITE(fnumwrk,'(A8, 4F7.1)')   ' TRGFN',(trgfn(i),i = 1,4)
            WRITE(fnumwrk,'(A8, 4F7.1)')   ' TRGNO',(trgno(i),i = 1,4)

            WRITE(fnumwrk,'(A8,10F7.1)')   ' CO2RF',(co2rf(i),i = 1,10)
            WRITE(fnumwrk,'(A8,10F7.1)')   ' CO2FR',(co2fr(i),i = 1,10)
            WRITE(fnumwrk,'(A8,10F7.2)')   ' PTFS ',(ptfs(i),i = 1,10)
            WRITE(fnumwrk,'(A8,10F7.2)')   ' PTFA ',(ptfa(i),i = 1,10)
            WRITE(fnumwrk,'(A8,10F7.2)')   ' STFR ',(stfr(i),i = 1,10)
            WRITE(fnumwrk,'(A8,10F7.2)')   ' PLASF',(plasf(i),i = 1,10)
            WRITE(fnumwrk,'(A8,10F7.2)')   ' HTFR ',(htfr(i),i = 1,10)
            WRITE(fnumwrk,'(A8,10F7.2)')   ' LAFR ',(lafr(i),i = 1,10)
            WRITE(fnumwrk,'(A8, 7F7.4)')   ' LCNCS',(lcncs(i),i = 0,6)
            WRITE(fnumwrk,'(A8, 7F7.4)')   ' SCNCS',(scncs(i),i = 0,6)
            WRITE(fnumwrk,'(A8, 7F7.4)')   ' RCNCS',(rcncs(i),i = 0,6)
            WRITE(fnumwrk,'(A8, 7F7.4)')   ' LMNCS',(lmncs(i),i = 0,6)
            WRITE(fnumwrk,'(A8, 7F7.4)')   ' SMNCS',(smncs(i),i = 0,6)
            WRITE(fnumwrk,'(A8, 7F7.4)')   ' RMNCS',(rmncs(i),i = 0,6)
            WRITE(fnumwrk,'(A17,3F8.2)')   ' L,S,R LIGNIN  ',
     &                                       lligp,sligp,rligp
            WRITE(fnumwrk,'(A17, F8.2)')'   GRAIN LIGNIN  ',gligp
            WRITE(fnumwrk,'(A17,2F8.2)')'   RWUMXS,RWUMX  ',rwumxs,rwumx
            WRITE(fnumwrk,'(A17, F8.2)')'   PORMIN        ',pormin
            WRITE(fnumwrk,'(A17, F8.2)')'   RLWR cm/g     ',rlwr
            WRITE(fnumwrk,'(A17,2F8.2)')'   PEG,PECM      ',peg,pecm
            WRITE(fnumwrk,'(A17,2F8.2)')'   P2(1)adj,PD2  ',pd2(1),pd(2)
            WRITE(fnumwrk,'(A17,2F8.2)')'   PDUR6         ',pd(6)
            WRITE(fnumwrk,'(A17,2F8.4)')'   WFRG,NFRGC    ',wfrg,nfrg
            WRITE(fnumwrk,'(A17,2F8.2)')'   WFGEU,SDAFR   ',wfgeu,sdafr
            WRITE(fnumwrk,'(A17,2F8.4)')'   SDSZ,SDNPCI   ',sdsz,sdnpci
            WRITE(fnumwrk,'(A17,2F8.2)')'   WFRDG,RDGTH   ',wfrdg,rdgth
            WRITE(fnumwrk,'(A17,2F8.2)')'   RDGS1,RDGS2   ',rdgs1,rdgs2
            WRITE(fnumwrk,'(A17,2F8.2)')'   RLDGR,RTREF   ',rldgr,rtref
            WRITE(fnumwrk,'(A17,2F8.2)')'   WFTIU,WFTIL   ',wftiu,wftil
            WRITE(fnumwrk,'(A17,2F8.2)')'   NFTIU,NFTIL   ',nftiu,nftil
            WRITE(fnumwrk,'(A17,2F8.2)')'   WFSU,WFSF     ',wfsu,wfsf
            WRITE(fnumwrk,'(A17,2F8.2)')'   NFSU,NFSF     ',nfsu,nfsf
            WRITE(fnumwrk,'(A17, F8.2)')'   NFSM          ',nfsm
            WRITE(fnumwrk,'(A17,2F8.2)')'   WFNUU,WFNUL   ',wfnuu,wfnul
            WRITE(fnumwrk,'(A17,2F8.2)')'   NO3MN,NH4MN   ',no3mn,nh4mn
            WRITE(fnumwrk,'(A17,2F8.2)')'   RLFNU,NUMAX   ',rlfnu,numax
            WRITE(fnumwrk,'(A17,2F8.2)')'   LT50S,HDUR    ',lt50s,hdur
            WRITE(fnumwrk,'(A17,2F8.2)')'   PTFX          ',ptfx
            WRITE(fnumwrk,'(A17,2F8.2)')'   SSEN,RSEN     ',ssen,rsen
            WRITE(fnumwrk,'(A17,2F8.2)')'   SAWS,LSAWS    ',saws,lsaws
            WRITE(fnumwrk,'(A17,2F8.2)')'   LSHFR,LAWFRMN ',
     &                                                    lshfr,lawfrmn
            WRITE(fnumwrk,'(A17,2F8.2)')'   LNUMF,SSSTG   ',lnumf,ssstg
            WRITE(fnumwrk,'(A17,2F8.2)')'   XNFS,GRNMX    ',xnfs,grnmx
            WRITE(fnumwrk,'(A17,2F8.2)')'   NTUPF,CHRSF   ',ntupf,chrsf
            WRITE(fnumwrk,'(A17,2F8.2)')'   CHFR,CHSTG    ',chfr,chstg
            WRITE(fnumwrk,'(A17,2F8.2)')'   PART,SRADT    ',part,sradt
          ENDIF
        ENDIF

        ! End of initiation flags,etc..
        CFLINIT = 'Y'
        TNI = TN
        CNI = CN
        SNI = SN
        ONI = ON
        RNI = RN
        KEPI = KEP
        KCANI = KCAN
        PORMINI = PORMIN
        RWUMXI = RWUMX

        CROPP = CROP
        VARNOP = ' '
        VARNOP = VARNO
        CUDIRFLP = ' '
        CUDIRFLP = CUDIRFLE
        IF (MODE.EQ.'G') CUDIRFLP = ' '
        ECONOP = ' '
        ECONOP = ECONO
        ECDIRFLP = ' '
        ECDIRFLP = ECDIRFLE
        SPDIRFLP = ' '
        SPDIRFLP = SPDIRFLE

        IF (FILEIOT.EQ.'DS4') WRITE(fnumwrk,*)' '

      ELSEIF (DYNAMIC.EQ.RATE) THEN

        IF (FILEIOT.EQ.'XFL') WRITE(fnumwrk,'(A28,I3,I8,2F6.2)')
     &   ' CN,YEARDOY,XSTAGE1,LEAFNUM ',cn,yeardoy,xstage,lnumsd
        IF (YEARDOY.LT.YEARPLTP)
     &  WRITE(fnumwrk,*) 'YEARPLT,YEARPLTP   ',YEARPLT,YEARPLTP

        CFLINIT = 'N'    ! Reset initiation flag for next run

        IF (YEARPLT.GT.9000000) THEN            ! If before planting
          ! Initialize planting depth temperature and water variables
          TSDEP = 0.0
          CUMSW = 0.0
          AVGSW = 0.0
          IF(YEARPLTP.GT.0 .AND. YEARPLTP.LT.9000000)THEN
            IF(YEARDOY.EQ.YEARPLTP)THEN
              YEARPLT = CSYEARDOY(YEARPLTP)
              PLTPOP = PLTPOPP
              TNUM = 1.0
            ENDIF
          ELSE
            ! Automatic planting
            ! Check window for automatic planting,PWDINF<YEARPLTP<PWDINL
            IF (YEARDOY.GE.PWDINF.AND.YEARDOY.LE.PWDINL) THEN
              ! Within planting window.
              ! Determine if soil temperature and soil moisture ok
              ! Obtain soil temperature, TSDEP, at 10 cm depth
              I = 1
              XDEP = 0.0
              DO WHILE (XDEP .LT. 10.0)
                XDEP = XDEP + DLAYR(I)
                TSDEP = ST(I)
                I = I + 1
              END DO
              ! Compute average soil moisture as percent, AVGSW
              I = 1
              XDEP = 0.0
              CUMSW = 0.0
              DO WHILE (XDEP .LT. SWPLTD)
                XDEPL = XDEP
                XDEP = XDEP + DLAYR(I)
                IF (DLAYR(I) .LE. 0.) THEN
                  !IF SOIL DEPTH IS LOWER THAN SWPLTD -US
                  XDEP = SWPLTD
                  CYCLE
                ENDIF
                DTRY = MIN(DLAYR(I),SWPLTD - XDEPL)
                CUMSW = CUMSW + DTRY *
     &           (MAX(SW(I) - LL(I),0.0)) / (DUL(I) - LL(I))
                I = I + 1
              END DO
              AVGSW = (CUMSW / SWPLTD) * 100.0
              WRITE (fnumwrk,*) 'Date thresholds ',pwdinf,pwdinl
              WRITE (fnumwrk,*) 'Water thresholds ',swpltl,swplth
              WRITE (fnumwrk,*) 'Water ',avgsw
              WRITE (fnumwrk,*) 'Temperature thresholds ',pttn,ptx
              WRITE (fnumwrk,*) 'Temperature ',tsdep
              IF (TSDEP .GE. PTTN .AND. TSDEP .LE. PTX) THEN
                IF (AVGSW .GE. SWPLTL .AND. AVGSW .LE. SWPLTH) THEN
                  YEARPLT = YEARDOY
                  PLTPOP = PLTPOPP
                  CFLFAIL = 'N'
                ENDIF
              ENDIF
            ELSE
              IF (YEARDOY.GT.PWDINL) THEN
                CFLFAIL = 'Y'
                STGDOY(1) = -99
                STGDOY(2) = -99
                STGDOY(3) = -99
                STGDOY(4) = -99
                STGDOY(5) = -99
                STGDOY(6) = -99
                STGDOY(7) = -99
                STGDOY(8) = -99
                STGDOY(9) = -99
                STGDOY(10) = YEARDOY
                STGDOY(11) = YEARDOY
                ISTAGE = 7
                XSTAGE = 7.0
                WRITE (fnumwrk,*) ' '
                WRITE (fnumwrk,*)
     &           'Automatic planting failure on ',yeardoy
              ENDIF
            ENDIF
          ENDIF

          STGDOY(7) = YEARPLT
          SEEDN = SEEDNI
          SEEDRS = SEEDRSI
          SEEDRSAV = SEEDRS

        ENDIF

        IF (YEARDOY.GE.YEARPLT) THEN

          ! Photosynthetically active radiation
          PARAD = PARADFAC*SRAD

          ! Mean temperature
          TMEAN = (TMAX+TMIN)/2.0
          IF (snow.GT.0) THEN
            tmeans = 0.0
          ELSE
            tmeans = tmean
          ENDIF

          ! Day and night temperatures
          TDAY = TMEAN
          TNIGHT = TMEAN
          ! NB.These could be set in various ways. In Ceres 3.5,there
          ! were various modifications for different processes. Work
          ! with G.McMaster, however, showed that (at least for
          ! development) these were no better than using the daily
          ! mean. Hence the day and night temperatures are set equal
          ! to the daily mean. Other simple settings could be:
          ! TDAY = TMAX
          ! TNIGHT = TMIN
          ! TDAY = TMEAN + 0.5*(TMAX-TMEAN)
          ! TNIGHT = TMIN + 0.5*(TMEAN-TMIN)
          ! And more complex settings could involve using the hourly
          ! temperatures, or modifying values depending on the
          ! difference between TMAX and TMIN.
          TMEAN20S = 0.0
          SRAD20S = 0.0
          TMEANNUM = TMEANNUM + 1
          DO L = 20,2,-1
            TMEAND(L) = TMEAND(L-1)
            TMEAN20S = TMEAN20S + TMEAND(L)
            SRADD(L) = SRADD(L-1)
            SRAD20S = SRAD20S + SRADD(L)
          ENDDO
          TMEAND(1) = TMEAN
          TMEAN20S = TMEAN20S + TMEAND(1)
          SRADD(1) = SRAD
          SRAD20S = SRAD20S + SRAD
          IF (TMEANNUM.GE.20.0) THEN
            IF (TMEANNUM.EQ.20.0) TMEAN20P = TMEAN20S/20.0
            TMEAN20 = TMEAN20S/20.0
            SRAD20 = SRAD20S/20.0
          ELSE
            TMEAN20 = 0.0
            SRAD20 = 0.0
          ENDIF
          IF (ADAT.GT.0) THEN
            ADAT10 = CSINCDAT(ADAT,10)
            !IF (YEARDOY.EQ.ADAT10) TMEAN20A = TMEAN20
            !IF (YEARDOY.EQ.ADAT10) SRAD20A = SRAD20
            IF (XSTAGE.GE.ASTAGEND.AND.TMEAN20A.LE.0.0) THEN
              TMEAN20A = TMEAN20
              SRAD20A = SRAD20
            ENDIF
          ENDIF

          ! Thermal time
          IF (ISTAGE.GT.4 .AND. ADAT.GT.0 .AND. ISTAGE.LE.6) THEN
            Tfout = TFAC4(trdv2,tmean,TT)
          ELSE
            Tfout = TFAC4(trdv1,tmeans,TT)
          ENDIF

          ! Thermal time averages for various periods
          IF (ISTAGE.LT.7.AND.ISTAGE.GE.4) THEN
            TT20S = 0.0
            TTNUM = TTNUM + 1
            DO L = 20,2,-1
              TTD(L) = TTD(L-1)
              TT20S = TT20S + TTD(L)
            ENDDO
            TTD(1) = TT
            TT20S = TT20S + TTD(1)
            IF (TTNUM.GE.20.0) THEN
              TT20 = TT20S/20.0
            ELSE
              TT20 = -99.0
            ENDIF
          ENDIF

          ! Temperature factors
          IF (ISTAGE.GE.9 .OR. ISTAGE.LE.2) THEN
            Tfv = TFAC4(trvrn,tmeans,TTOUT)
            Tfh = TFAC4(trlth,tmeans,TTOUT)
          ELSE
            TFV = 0.0
            TFH = 0.0
          ENDIF
          IF (ISTAGE.LE.2) THEN
            Tfg = TFAC4(trlfg,tmean,TTOUT)
          ENDIF
          IF (ISTAGE.LE.6) THEN
            ! The original temperature response for photosynthesis had
            ! a more rapid rise at low temperatures than the 4 cardinal
            ! temperatures response now used. This is shown below in the
            ! original data:
            !TREFS  TFGR  TFPR  TFVR  TFHR TFGFR TFGNR TFGNM
            ! -5.0   -99   -99  0.00  0.00   -99   -99   -99
            !  0.0  0.00  0.00  1.00  1.00  0.00  0.00  0.00
            !  2.0   -99  0.40   -99   -99   -99   -99   -99
            !  5.0   -99   -99   -99  1.00   -99   -99   -99
            !  7.0   -99  0.70  1.00   -99   -99   -99   -99
            ! 10.0  1.00  0.85   -99  0.00   -99   -99   -99
            ! 15.0  1.00  1.00  0.00   -99   -99   -99   -99
            ! 16.0   -99   -99   -99   -99  1.00  1.00  1.00
            ! 20.0  1.00  1.00   -99   -99   -99   -99   -99
            ! 25.0  1.00   -99   -99   -99   -99   -99   -99
            ! 26.0   -99  0.85   -99   -99   -99   -99   -99
            ! 30.0   -99  0.50   -99   -99   -99   -99   -99
            ! 35.0  0.00  0.00   -99   -99  1.00  1.00  1.00
            ! 45.0   -99   -99   -99   -99  1.00  1.00  1.00
            ! The original call to obtain TFP was:
            ! TFP = TFCALC2(TREFS,TFPR,'20',TDAY,TDAY,SNOW)
            Tfp = TFAC4(trphs,tmean,TTOUT)
            ! Ceres35 PRFT = 1.0-0.0025*((0.25*TMIN+0.75*TMAX)-18.0)**2
          ENDIF
          IF (ISTAGE.EQ.4.OR.ISTAGE.EQ.5) THEN
            Tfgf = TFAC4(trgfw,tmean,TTOUT)
            Tfgn = TFAC4(trgfn,tmean,TTOUT)
          ENDIF

          ! Radiation interception (if from competition model)
          IF (PARIP.GE.0.0) THEN
            PARI = PARIP/100.0
            WRITE(fnumwrk,'(A39,F6.2,A11,I2)')
     &       ' PARI from competition model          :',PARI,
     &       ' Component:',CN
            WRITE(fnumwrk,'(A39,F6.2,7X,F6.2)')
     &       ' Leaf area (laminae). Index,Per plant: ',
     &       LAI,PLA-SENLA
          ENDIF

          IF (fileiot(1:2).NE.'DS')
     &     CALL CSTRANS(ISWWAT,                            !Control
     &     TMAX, TMIN, WINDSP, CO2, EO,                    !Weather
     &     CROP, LAI, KEP,                                 !Crop,LAI
     &     eop,                                            !Pot.pl.evap
     &     DYNAMICI)                                       !Control

          IF (fileiot(1:2).NE.'DS')
     &     CALL CSROOTWU(ISWWAT, VERSION,                  !Control
     &     NLAYR, DLAYR, LL, SAT, WFSAG,                   !Soil
     &     EOP,                                            !Pot.evap.
     &     RLV, PORMIN, RWUMX, RTDEP,                      !Crop state
     &     SW,                                             !Soil h2o
     &     uh2o, trwup,                                    !H2o uptake
     &     DYNAMICI)                                       !Control

          ! Water status factors
          WFG = 1.0
          WFP = 1.0
          WFS = 1.0
          WFTI = 1.0
          IF (ISWWAT.EQ.'Y' .AND. ISTAGE.LT.7) THEN
            IF (EOP.GT.0.0) THEN
              WUPR = TRWUP/(EOP*0.1)
              WFG = AMAX1(0.0,AMIN1(1.0,WUPR/WFGU))
              WFP = AMAX1(0.0,AMIN1(1.0,WUPR/WFPU))
              IF (VERSION.GE.4.08)
     &         WFP = AMAX1(0.0,AMIN1(1.0,WUPR/WFPU))
              IF (XSTAGE.GE.4.0) WFP = 1.0-(1.0-WFP)*WFPGF !Grain fill
              WFS = AMAX1(0.0,AMIN1(1.0,WUPR/WFSU))
              WFTI = AMAX1(0.0,AMIN1(1.0,(WUPR-WFTIL)/(WFTIU-WFTIL)))
            ENDIF
          ENDIF

          ! Nitrogen status factors
          NFG = 1.0
          NFP = 1.0
          NFS = 1.0
          NFTI = 1.0
          IF (ISWNIT.EQ.'Y' .AND. ISTAGE.LT.7) THEN
            LMNCG = LMNC + NFGL * (LCNC-LMNC)
            LCNCG = LMNC + NFGU * (LCNC-LMNC)
            LMNCP = LMNC + NFPL * (LCNC-LMNC)
            LCNCP = LMNC + NFPU * (LCNC-LMNC)
            LCNCSEN = LMNC + NFSU * (LCNC-LMNC)
            LMNCT = LMNC + NFTIL * (LCNC-LMNC)
            LCNCT = LMNC + NFTIU * (LCNC-LMNC)
            IF (LFWT.GT.0.0) THEN
              NFG = AMIN1(1.0,AMAX1(0.0,(LANC-LMNCG)/(LCNCG-LMNCG)))
              NFP = AMIN1(1.0,AMAX1(0.0,(LANC-LMNCP)/(LCNCP-LMNCP)))
              NFS = AMIN1(1.0,AMAX1(0.0,LANC/LCNCSEN))
              NFTI = AMIN1(1.0,AMAX1(0.0,(LANC-LMNCT)/(LCNCT-LMNCT)))
            ELSEIF (LFWT.EQ.0.0 .AND. ISTAGE.GE.5) THEN
              NFG = 0.0
              NFP = 0.0
              NFS = 0.0
              NFTI = 0.0
            ENDIF
          ENDIF

          CALL CE_PHENOL(ISWWAT,
     &     DAYLT,SRAD,TT,
     &     NLAYR,DLAYR,LL,DUL,SW,
     &     P1D,P1DT,P1DPE,WFGEU,
     &     PLTPOP,SDEPTH,CROP,ISTAGE,VF,LNUMSD,
     &     df,du,geu)

          CALL CE_GROSUB (STDDAY,VERSION,
     &     SRAD,PARAD,CO2,DU,
     &     PD,G2,G3,PHINT,PHINTS,PHINTCHG,CO2RF,CO2FR,PARUV,PARUR,PTH,
     &     LAWRS,LAWR2,LA1S,LAVS,LARS,LLIFE,LATFR,
     &     PTFS,PTFA,STFR,LSHFR,LSENS,
     &     P4SGE,RSFRS,PLASF,PTFX,RTREF,LAWFRMN,SDAFR,
     &     TI1LF,TILDF,TFP,
     &     CROP,PLTPOP,PARI,ISTAGE,XSTAGE,GRNUM,SSTAGE,LAGSTAGE,
     &     TT,CUMDU,
     &     WFP,WFG,NFP,NFG,LCNF,NFSM,
     &     TFG,TFGF,
     &     SEEDRSAV,LFWT,STWT,RSWT,RSC,GRWT,TNUM,
     &     GPLA,LNUMSD,LNUMSG,LAP,LAPS,PLAG,PLA,SENLA,
     &     tnumloss,pltloss,plagt,tnumg,tnumd,
     &     plas,plass,lapot,
     &     carbophs,rtwtg,grolf,grost,rtresp,grors,grorspm,grogrst,
     &     grogrpa,grorssd,carbolsd,ptf,ch2olim,tlimit,
     &     co2fp,wfti,nfti,rsfp,wflf,nflf,aflf,
     &     DYNAMICI)

          IF (XSTAGE.LT.7) THEN
            IF (XSTAGE.GT.1.0) THEN
              CANHTG =
     &         AMAX1(0.0,(CANHTS*AMIN1(1.0,(XSTAGE-1.0)/4.0)-CANHT))
            ELSEIF (XSTAGE.EQ.1.0 .AND. PLAGT(1).GT.0.0) THEN
              ! Height growth on day of emergence or if no development
              CANHTG = 0.5
            ENDIF
          ENDIF

          CALL CE_ROOTGR (ISWNIT,STDDAY,VERSION,
     &     CUMTT,TT,ISTAGE,DAE,
     &     NO3LEFT,NH4LEFT,NLAYR,DLAYR,SW,LL,DUL,SHF,
     &     RLWR,RSEN,RDGS1,RDGS2,WFRG,NFRG,WFRDG,RDGTH,SDAFR,RLDGR,
     &     PLTPOP,RTDEP,RTWTL,WFP,RTWTG,SEEDRSAV,RANC,RMNC,
     &     rtdepg,rtwts,rtwtgl,rtwtsl,rtnsl,rtwtgs)

          CALL CE_COLD (
     &     DOY,TMIN,TMAX,
     &     ISTAGE,PLTPOPP,PLTPOP,TNUM,PLA,SENLA,
     &     TKILL,CUMVD,HARDI,
     &     cflfail,hardilos,vdlost,tnumloss,pltloss,plasc)

          ! Senescent leaf - NB. N loss has a big effect if low N
          LSENNF = 0.0
          IF (LANC.GT.0.0) LSENNF = (1.0-((LANC-LMNC)/LANC))
          PLASS = 0.0
          PLAST = 0.0
          SENLFG = 0.0
          SENLFGRS = 0.0
          SENNLFG = 0.0
          SENNLFGRS = 0.0
          ! Following is to lose some leaf area when tillers die
          IF (TNUMD.GT.0.0) PLAST = TNUMD * ((PLA-SENLA)/TNUM) * LALOSSF
          PLASS = AMAX1(0.0,AMIN1((PLA-SENLA)-PLAS,
     &            (PLA-SENLA)*((1.0-WFS)*WFSF+(1.0-NFS)*NFSF)))
          IF (PLA-SENLA.GT.0.0) THEN
            SENLFG = AMIN1(LFWT*LSENWF,(AMAX1(0.0,
     &      ((PLAS+PLAST+PLASS+PLASC)*LSENWF)
     &      * (LFWT/(PLA-SENLA)))))
            SENLFGRS = AMIN1(LFWT*(1.0-LSENWF),(AMAX1(0.0,
     &      ((PLAS+PLAST+PLASS+PLASC)*(1.0-LSENWF))
     &       * (LFWT/(PLA-SENLA)))))
            SENNLFG = AMIN1((LEAFN-GRAINNGL)*LSENNF,
     &                (SENLFG+SENLFGRS)*LANC*LSENNF)
            SENNLFGRS = AMIN1((LEAFN-GRAINNGL)*(1.0-LSENNF),
     &                  (SENLFG+SENLFGRS)*LANC*(1.0-LSENNF))
            IF (((SENNLFG+SENNLFGRS)-LEAFN).GT.1.0E-8) THEN
              WRITE(fnumwrk,'(A40,F6.2)')
     &         ' Adjusted N removal from leaves at stage',xstage
              SENNLFGRS = LEAFN-SENNLFG
              IF (SENNLFGRS.LT.0.0) THEN
                SENNLFG = SENNLFG - ABS(SENNLFGRS)
                SENNLFGRS = 0.0
                IF (SENNLFG.LT.0.0) SENNLFG = 0.0
              ENDIF
            ENDIF
          ENDIF

          ! Senescent stem
          SENSTG = 0.0
          SENNSTG = 0.0
          SENNSTGRS = 0.0
          SSENF = 0.0
          IF (XSTAGE.GT.SSSTG .AND. XSTAGE.LT.6.0) THEN
            SENSTG = AMAX1(0.0,STWT*(SSEN/STDDAY)*TT)
            IF (SANC.GT.0.0) SSENF = (1.0-((SANC-SMNC)/SANC))
            SENNSTG = SENSTG*SANC*SSENF
            SENNSTGRS = SENSTG*SANC*(1.0-SSENF)
            IF (SENNSTG+SENNSTGRS.GT.STEMN) THEN
              WRITE(fnumwrk,*)'N removal from stem > stem N'
              SENNSTG = STEMN-SENNSTGRS
            ENDIF
          ENDIF

          ! N use limit during grain fill
          IF (XSTAGE.GE.5.0.AND.XSTAGE.LE.6.0) THEN
            NUSELIM = AMIN1(1.0,DU/((6.0-XSTAGE)*PD(5)))
          ELSEIF (XSTAGE.GE.4.0.AND.XSTAGE.LE.5.0) THEN
            NUSELIM = DU/(((5.0-XSTAGE)*PD(4))+PD(5))
          ENDIF

          CALL CE_NUPTAK (ISWNIT,DU,
     &     SW,NO3LEFT,NH4LEFT,LL,DUL,SAT,DLAYR,BD,NLAYR,SHF,FAC,
     &     NO3MN,NH4MN,RLFNU,NUMAX,NTUPF,WFNUL,WFNUU,
     &     XSTAGE,LAGSTAGE,PLTPOP,RTWT,RLV,LFWT,STWT,
     &     GRNUM,G2,GRNS,GRNMX,TFGN,
     &     SEEDN,RSN,RCNC,RANC,RMNC,LCNC,LANC,LMNC,SCNC,SANC,SMNC,XNFS,
     &     RTWTG,RTWTGS,RTWTS,NUSELIM,
     &     GROLF,SENLFG,SENLFGRS,GROST,SENSTG,GROGRPA,
     &     dleafn,dstemn,drootn,
     &     grainng,grainngr,grainngl,grainngs,
     &     seednr,seednt,rsnuser,rsnuset,rsnuseg,
     &     uno3alg,unh4alg,nupd,nupr)

          ! Minimum grain N control
          GRORSGR = 0.0
          IF (GRNMN.GT.0.0) THEN
            GROGRPN =
     &       (GRAINNG+GRAINNGR+GRAINNGL+GRAINNGS+RSNUSEG)*(100./GRNMN)
            IF (GROGRPN.LT.GROGRPA.AND.GRAINANC*100.0.LE.GRNMN) THEN
              GRORSGR = GROGRPA - GROGRPN
              GROGR = GROGRPN
            ELSE
              GROGR = GROGRPA
              GRWTTMP = GRWT + GROGRPA
              GRAINNTMP = GRAINN +
     &        (GRAINNG+GRAINNGR+GRAINNGL+GRAINNGS+RSNUSEG)
              IF (GRAINNTMP/GRWTTMP*100.0 .LT. GRNMN) THEN
                GRWTTMP = GRAINNTMP*(100.0/GRNMN)
                GROGR = GRWTTMP - GRWT
              ENDIF
            ENDIF
            IF (GROGR.LT.GROGRPA) THEN
              WRITE(fnumwrk,'(A42,F4.2)')
     &         ' N limit on grain growth. N at minimum of ',grnmn
              NLIMIT = NLIMIT + 1
            ENDIF
          ELSE
            GROGR = GROGRPA
          ENDIF

          ! Maximum grain weight control
          ! 02/20/2006 LAH/CHP added initialization, tolerance level 
          GROGRADJ = 0.0
          IF (GRNUM.GT.0.0) THEN
            IF ((GRWT+GROGR)/GRNUM - G2KWT/1000.0 > 1.E-5) THEN
              WRITE(fnumwrk,*)'Maximum kernel wt reached on:',YEARDOY
              GROGRADJ = GROGR - (G2KWT/1000.0-(GRWT/GRNUM))*GRNUM
            ENDIF
          ENDIF

          ! Growth variables expressed on area basis
          ! C assimilation
          CARBOA = CARBOPHS*PLTPOP*10.0
          ! N assimilation
          NUAG = NUPD*PLTPOP*10.0
          ! Above ground senescence
          SENWALG(0) = 0.0
          SENNALG(0) = 0.0
          SENCALG(0) = 0.0
          SENLGALG(0) = 0.0
          IF (XSTAGE.LT.LRETS) THEN
            SENWALG(0) = (SENLFG+SENSTG) * PLTPOP*10.0
            SENNALG(0) = (SENNLFG+SENNSTG) * PLTPOP*10.0
            SENCALG(0) = (SENLFG+SENSTG) * 0.4 * PLTPOP*10.0
            SENLGALG(0) =
     &       (SENLFG*LLIGP/100+SENSTG*SLIGP/100) * PLTPOP*10.0
          ENDIF
          ! Root senescence
          DO L = 1, NLAYR
            SENWALG(L) = RTWTSL(L) * PLTPOP*10.0
            SENNALG(L) = RTNSL(L) * PLTPOP*10.0
            SENCALG(L) = SENWALG(L) * 0.4
            SENLGALG(L) = SENWALG(L) * RLIGP/100.0
          ENDDO

          ! Reset control flag
          DYNAMICI = 0

        ENDIF


      ELSEIF (DYNAMIC.EQ.INTEGR) THEN

        IF (YEARDOY.GE.YEARPLT) THEN

          ! Dry weights
          CARBOC = CARBOC + CARBOPHS
          RESPC = RESPC + RTRESP
          LFWT = LFWT + GROLF - SENLFG - SENLFGRS
          IF (LFWT.LT.0.0) THEN
            IF (LFWT.LT.-1.0E-5) THEN
              WRITE(fnumwrk,*)'Leaf weight less than 0! ',LFWT
            ELSE
              LFWT = 0.0
            ENDIF
          ENDIF
          STWT = STWT + GROST - SENSTG - GROGRST
          GRWT = GRWT + GROGR - GROGRADJ
          RSWT = RSWT + GRORS + GRORSGR + GROGRADJ + SENLFGRS
          IF (XSTAGE.GE.LRETS) THEN
            DEADWT = DEADWT + SENLFG + SENSTG
          ELSE
            SENWL(0) = SENWL(0) + (SENLFG+SENSTG)
            SENCL(0) = SENCL(0) + (SENLFG+SENSTG) * 0.4
            SENLGL(0) = SENLGL(0)+(SENLFG*LLIGP/100+SENSTG*SLIGP/100)
          ENDIF
          RTWT = 0.0
          DO L = 1, NLAYR
            RTWTL(L) = RTWTL(L) + RTWTGL(L) - RTWTSL(L)
            SENWL(L) = SENWL(L) + RTWTSL(L)
            SENCL(L) = SENCL(L) + RTWTSL(L) * 0.4
            SENLGL(L) = SENLGL(L) + RTWTSL(L) * RLIGP/100.0
            ! Totals
            RTWT = RTWT + RTWTL(L)
            SENWS = SENWS + RTWTSL(L)
            SENCS = SENCS + RTWTSL(L) * 0.4
            SENLGS = SENLGS + RTWTSL(L) * RLIGP/100.0
          END DO
          SEEDRS = AMAX1(0.0,SEEDRS+GRORSSD-RTWTGS-CARBOLSD)
          SEEDRSAV = SEEDRS

          IF (ISTAGE.GE.6) RSWTPM = RSWTPM + GRORSPM

          IF (XSTAGE.GT.CHSTG) THEN
            IF (GROST.GT.0.0) CHWT = CHWT + GROST*CHFR
          ENDIF

          IF (GRNUM.GT.0.0) GWUD = GRWT/GRNUM
          GWGD = GWUD*1000.0

          HIAD = 0.0
          IF ((LFWT+STWT+GRWT+RSWT+DEADWT).GT.0.0)
     &     HIAD = GRWT/(LFWT+STWT+GRWT+RSWT+DEADWT)

          ! Reserve concentration and factor
          RSC = 0.0
          IF (LFWT+STWT+RSWT+RTWT.GT.0.0)
     &     RSC = RSWT/(LFWT+STWT+RSWT+RTWT)

          ! Radiation use efficiency
          PARUED = 0.0
          IF (PARAD*PARI.GT.0.0) PARUED = CARBOPHS*PLTPOP/(PARAD*PARI)

          ! Height
          CANHT = CANHT + CANHTG

          ! Leaf areas
          PLA = PLA + PLAGT(1) + PLAGT(2)
          SENLA = SENLA + PLAS + PLASS + PLASC + PLAST
          IF (LNUMSG.GT.0) THEN
            LAP(LNUMSG) = LAP(LNUMSG) + PLAGT(1)
            LATL(1,LNUMSG) = LATL(1,LNUMSG)+PLAG(1)
            IF (PLAG(2).GT.0.0) THEN
              IF (LNUMSG.LT.LNUMX) THEN
                LAP(LNUMSG+1) = LAP(LNUMSG+1) + PLAGT(2)
                LATL(1,LNUMSG+1) = LATL(1,LNUMSG+1)+PLAG(2)
              ELSEIF (LNUMSG.GE.LNUMX) THEN
                LAP(LNUMSG) = LAP(LNUMSG) + PLAGT(2)
                LATL(1,LNUMSG) = LATL(1,LNUMSG)+PLAG(2)
              ENDIF
            ENDIF
          ENDIF

          IF (ISTAGE.GT.0) GPLA(ISTAGE) = AMAX1(0.0,PLA-SENLA)
          LAI = AMAX1 (0.0,(PLA-SENLA)*PLTPOP*0.0001)
          LAIX = AMAX1(LAIX,LAI)

          PLASTMP = PLAS + PLASS + PLASC + PLAST
          ! Distribute senesced leaf over leaf positions
          IF (LNUMSG.GT.0 .AND. PLASTMP.GT.0) THEN
            DO L = 1, LNUMSG
              IF (LAP(L)-LAPS(L).GT.PLASTMP) THEN
                LAPS(L) = LAPS(L) + PLASTMP
                PLASTMP = 0.0
              ELSE
                PLASTMP = PLASTMP - (LAP(L)-LAPS(L))
                LAPS(L) = LAP(L)
              ENDIF
              IF (PLASTMP.LE.0.0) EXIT
            ENDDO
          ENDIF

          IF (LNUMSG.GT.0) CALL Cslayers
     X     (htfr,lafr,                 ! Canopy characteristics
     X     pltpop,lai,canht,           ! Canopy aspects
     X     lnumsg,lap,lap(lnumsg),     ! Leaf cohort number and size
     X     LAIL)                       ! Leaf area indices by layer

          ! PAR interception
          IF (PARIP.LT.0.0.AND.LAI.GT.0.0) THEN
            PARI = (1.0 - EXP(-KCAN*(LAI+AWNAI)))
            !WRITE(fnumwrk,'(A28,F5.3)')
     X      ! '  PARI from one-crop model: ',PARI
            ! For maize, kcan is calculated as:
            ! 1.5 - 0.768*((rowspc*0.01)**2*pltpop)**0.1
            ! eg. 1.5 - 0.768*((75*0.01)**2*6.0)**0.1  =  0.63
          ENDIF

          ! Specific leaf area
          SLA = 0.0
          IF (LFWT.GT.0) SLA = (PLA-SENLA) / (LFWT*(1.0-LSHFR))

          ! Stem area (including leaf sheath)
          SAID = AMAX1 (0.0,(STWT*SAWS+LFWT*LSHFR*LSAWS)*PLTPOP*0.0001)

          ! Tillers (Limited to maximum of 20)
          TNUM = AMIN1(20.0,AMAX1(1.0,TNUM+TNUMG-TNUMD-TNUMLOSS))
          IF (LNUMSG.GT.0) TNUML(LNUMSG) = TNUM

          ! Plants
          PLTPOP = PLTPOP - PLTLOSS

          ! Root depth and length
          IF (SDEPTH.GT.0.0 .AND.RTDEP.LE.0.0) RTDEP = SDEPTH
          RTDEP = AMIN1 (RTDEP+RTDEPG,DEPMAX)
          DO L = 1, NLAYR
            RLV(L)=RTWTL(L)*(RLWR/0.6)*PLTPOP/DLAYR(L)
          END DO
          ! NB. 0.6 above was kept to keep similarity with Ceres,
          ! in which a value of 0.98 for RLWR was applied to GRORT.
          ! This latter was multiplied by a factor of 0.6 to account
          ! for root repiration to get actual root dry weight increase.


          ! Vernalization.  NB. Now starts at germination
          CUMVD = AMAX1(0.0,CUMVD+TFV-VDLOST)
          VF = 1.0
          IF (P1V.GT.1.0) THEN
            IF (ISTAGE.LE.1 .OR. ISTAGE.GE.7) THEN
              VF = AMAX1(0.,VF0+(1.-VF0)*AMAX1(0.,AMIN1(1.,CUMVD/P1V)))
            ENDIF
          ENDIF


          ! Cold hardiness
          HARDAYS = AMAX1(HARDAYS+TFH-HARDILOS,0.0)
          HARDI = AMIN1(1.0,HARDAYS/HDUR)
          TKILL = LT50S + (LT50H-LT50S)*HARDI


          ! Nitrogen
          NUPC = NUPC + NUPD
          LEAFN = LEAFN + DLEAFN + SEEDNT
     &          - GRAINNGL - SENNLFG - SENNLFGRS
          IF (LEAFN.LT.1.0E-10) LEAFN = 0.0
          STEMN = STEMN + DSTEMN
     &          - GRAINNGS - SENNSTG - SENNSTGRS
          IF (STEMN.LT.1.0E-10) STEMN = 0.0
          ROOTNS = 0.0
          DO L = 1, NLAYR
            SENNL(L) = SENNL(L) + RTNSL(L)
            ROOTNS = ROOTNS + RTNSL(L)
            SENNS = SENNS + RTNSL(L)
          END DO
          ROOTN = ROOTN + DROOTN + SEEDNR - GRAINNGR - ROOTNS
          SEEDN = SEEDN - SEEDNR - SEEDNT
          IF (SEEDN.LT.1.0E-6) SEEDN = 0.0
          GRAINN = GRAINN + GRAINNG + GRAINNGL + GRAINNGS + GRAINNGR
     &           + RSNUSEG
          RSN = RSN - RSNUSEG - RSNUSER - RSNUSET
     &        + SENNLFGRS + SENNSTGRS
          IF (XSTAGE.GE.LRETS) THEN
            DEADN = DEADN + SENNLFG + SENNSTG
          ELSE
            SENNL(0) = SENNL(0) + (SENNLFG+SENNSTG)
          ENDIF

          ! Harvest index for N
          HIND = 0.0
          IF ((LEAFN+STEMN+GRAINN+RSN+DEADN).GT.0.0)
     &     HIND = GRAINN/(LEAFN+STEMN+GRAINN+RSN+DEADN)


          ! Variables expressed per unit ground area:living plant
          CARBOAC = CARBOC*PLTPOP*10.0
          RESPAC = RESPC*PLTPOP*10.0

          CHWAD = CHWT*PLTPOP*10.0
          CWAD = (LFWT+STWT+GRWT+RSWT+DEADWT)*PLTPOP*10.0
          DWAD = DEADWT*PLTPOP*10.0
          GWAD = GRWT*PLTPOP*10.0
          LLWAD = LFWT*(1.0-LSHFR)*10.0*PLTPOP
          LSWAD = LFWT*LSHFR*10.0*PLTPOP
          ! NB.No reserves in chaff
          RSWAD = RSWT*PLTPOP*10.0
          RSWADPM = RSWTPM*PLTPOP*10.0
          RWAD = RTWT*PLTPOP*10.0
          SDWAD = (SEEDRS+SDCOAT)*10.0*PLTPOP
          STWAD = (STWT-CHWT)*10.0*PLTPOP
          STLSRWAD = (STWT-CHWT+LFWT*LSHFR+RSWT)*10.0*PLTPOP
          ! NB. Stem weigh here excludes chaff wt.

          SENWAS = SENWS*10.0*PLTPOP
          SENCAS = SENCS*10.0*PLTPOP
          SENLGAS = SENLGS*10.0*PLTPOP
          SENWAL(0) = SENWL(0)*PLTPOP*10.0
          SENCAL(0) = SENCL(0)*PLTPOP*10.0
          SENLGAL(0) = SENLGL(0)*PLTPOP*10.0
          DO L =1,NLAYR
            RTWTAL(L) = RTWTL(L)*PLTPOP*10.0
            SENWAL(L) = SENWL(L)*PLTPOP*10.0
            SENCAL(L) = SENCL(L)*PLTPOP*10.0
            SENLGAL(L) = SENLGL(L)*PLTPOP*10.0
          ENDDO

          TWAD = (SEEDRS+SDCOAT+RTWT+LFWT+STWT+GRWT+RSWT+DEADWT)
     &         * PLTPOP*10.0
          VWAD = (LFWT+STWT+RSWT+DEADWT)*PLTPOP * 10.0
          EWAD = (GRWT+CHWT)*PLTPOP * 10.0

          GRNUMAD = GRNUM*PLTPOP
          TNUMAD = TNUM*PLTPOP

          NUAD = NUPC*PLTPOP*10.0
          CNAD = (LEAFN+STEMN+GRAINN+RSN+DEADN)*PLTPOP*10.0
          DNAD = DEADN*PLTPOP*10.0
          GNAD = GRAINN*PLTPOP*10.0
          LLNAD = LEAFN*(1.0-LSHFR)*PLTPOP*10.0
          RNAD = ROOTN*PLTPOP*10.0
          RSNAD = RSN*PLTPOP*10.0
          SDNAD = SEEDN*PLTPOP*10.0
          SNAD = (STEMN+LEAFN*LSHFR)*PLTPOP*10.0
          TNAD = (ROOTN+LEAFN+STEMN+RSN+GRAINN+SEEDN+DEADN)*PLTPOP*10.0
          VNAD = (LEAFN+STEMN+RSN+DEADN)*PLTPOP*10.0

          SENNAS = SENNS*10.0*PLTPOP
          SENNAL(0) = SENNL(0)*PLTPOP*10.0
          DO L =1,NLAYR
            SENNAL(L) = SENNL(L)*PLTPOP*10.0
          ENDDO

          ! STAGES:Reproductive development (Rstages)
          CUMDU = CUMDU + DU
          IF (GESTAGE.GE.1.0) CUMTU = CUMTU + TT

!CHP 2/6/06   
!         IF (CUMDU.LT.PTH(0)) THEN
          IF (CUMDU.LT.PTH(0) .AND. PD(0) > 0.) THEN
            RSTAGE = CUMDU/PD(0)
          ELSE
            DO L = 6,1,-1
              IF (CUMDU.GE.PTH(L-1)) THEN
                RSTAGE = FLOAT(L) + (CUMDU-PTH(L-1))/PD(L)
                ! Following is necessary because xstages non-sequential
                RSTAGE = AMIN1(6.9,RSTAGE)
                EXIT
              ENDIF
            ENDDO
          ENDIF
          IF (CROP.EQ.'MZ'.AND.PDADJ.LE.-99.0.AND.RSTAGE.GT.2.0) THEN
            PDADJ = (CUMTU-TT-PD(0))/(CUMDU-DU-PD(0))
            WRITE(fnumwrk,'(A26,F6.1)')
     &       ' Phase adjustment         ',(PDADJ-1.0)*PD(2)
            WRITE(fnumwrk,'(A24)')'   PHASE OLD_END NEW_END'
            DO L = 2,10
              PTHOLD = PTH(L)
              PTH(L) = PTH(L) + AMAX1(0.0,PDADJ-1.0)*PD(2)
              WRITE(fnumwrk,'(I8,2F8.1)')L,PTHOLD,PTH(L)
            ENDDO
          ENDIF

          ! STAGES:Germination and emergence (Gstages)
          ! NB 0.5 factor used to equate to Zadoks)
          IF (ISTAGE.GT.7) CUMGEU = CUMGEU + GEU
          IF (CUMGEU.LT.PEGD) THEN
            GESTAGE = AMIN1(1.0,CUMGEU/PEGD*0.5)
          ELSE
            GESTAGE = AMIN1(1.0,0.5+0.5*(CUMGEU-PEGD)/(PECM*SDEPTH))
          ENDIF

          ! STAGES:Leaf numbers
          IF (LNUMSG.GT.0 .AND. ISTAGE.LE.2) THEN
            IF ((TT/PHINT).GT.(FLOAT(LNUMSG)-LNUMSD)) THEN
              IF (LNUMSG.EQ.PHINTCHG) THEN
                TTTMP = TT - PHINT*(FLOAT(LNUMSG)-LNUMSD)
                LNUMSD = LNUMSD+(TT-TTTMP)/PHINT+TTTMP/PHINTS
              ELSE
                LNUMSD = LNUMSD+TT/PHINT
              ENDIF
              LNUMSD = AMIN1(FLOAT(LNUMX-1)+0.9,LNUMSD)
            ELSE
              LNUMSD = AMIN1(FLOAT(LNUMX-1)+0.9,LNUMSD+TT/PHINT)
            ENDIF
          ENDIF
          IF (LNUMSD.GE.FLOAT(LNUMX-1)+0.9) THEN
            IF (CCOUNTV.EQ.0) WRITE (fnumwrk,'(A35,I4)')
     &       ' Maximum leaf number reached on day',DOY
            CCOUNTV = CCOUNTV + 1
            IF (CCOUNTV.EQ.50) THEN
              WRITE (fnumwrk,'(A47,/,A44,/A26)')
     &         ' 50 days after maximum leaf number! Presumably ',
     &         ' vernalization requirement could not be met!',
     &         ' Will assume crop failure.'
              CFLFAIL = 'Y'
            ENDIF
          ENDIF
          LNUMSG = INT(LNUMSD)+1
          LCNUM = INT(LNUMSD)+1

          ! STAGES:Overall development (Istages)      Zadoks  Rstages
          ! 8 - Sowing date                             00      0.0
          ! 9 - Germination                             05      1.0
          ! 1 - Emergence                               10      1.0
          ! 2 - End spikelet production (=t spikelet)   ??      2.0
          ! 3 - End leaf growth                         40      3.0
          ! 4 - End spike growth                        50      4.0
          ! 5 - End lag phase of grain growth           80      5.0
          ! 6 - End grain fill (Physiological maturity) 90      6.0
          ! 7 - Harvest maturity or harvest             92      6.9
          ! More precisely translated as:
          !  Xstage Zstage
          !      .1  1.00
          !     1.0
          !     2.0
          !     2.5 31.00  Jointing after tsp at 2.0+PD2(1)/PD(2)
          !     3.0 40.00
          !     4.0 57.00
          !     5.0 71.37
          !     5.5 80.68
          !     6.0 90.00
          ! Possible new rstages:
          !  Rstnew?               Xstage Zstage
          !       0 Wetted up         1.0     0.0
          !     1.0 End juvenile
          !     2.0 Double ridges
          !     3.0 Terminal spikelet 2.0
          !         Jointing          2.?    31.0
          !     4.0 Last leaf         3.0    39.0
          !     5.0 Spike emergence          50.0
          !         End spike growth  4.0
          !     6.0 Start anthesis           60.0
          !     7.0 End anthesis             70.0
          !     8.0 End lag           5.0    71.4
          !         End milk          5.5    80.7
          !     9.0 End grain fill    6.0    90.0
          !    10.0 Harvest           6.9    92.0

          IF (ISTAGE.EQ.7) THEN                       ! Pre-planting
            ISTAGE = 8
            XSTAGE = 8.0
          ELSEIF (ISTAGE.EQ.8) THEN                   ! Planted
            XSTAGE = FLOAT(ISTAGE) + GESTAGE*2.0
            IF(GESTAGE.GE.0.5) THEN
              ISTAGE = 9
              XSTAGE = FLOAT(ISTAGE) + (GESTAGE-0.5)*2.0
            ENDIF
          ELSEIF (ISTAGE.EQ.9) THEN                   ! Germination
            XSTAGE = FLOAT(ISTAGE) + (GESTAGE-0.5)*2.0
            IF(GESTAGE.GE.1.0) THEN
              ISTAGE = 1
              XSTAGE = 1.0
            ENDIF
          ELSE                                        ! Emergence on
            ISTAGE = INT(RSTAGE)
            XSTAGE = AMIN1(6.9,RSTAGE)                ! < 7 (=pre-plant)
          ENDIF
          ! Secondary stages
          SSTAGE = AMAX1(0.0,AMIN1(1.0,(XSTAGE-AINT(XSTAGE))))

          ! STAGES:Overall development (Zadoks)
          ! 01=begining of seed imbibition (assumed to be at planting)
          ! 05=germination (assumed to be when the radicle emerged)
          ! 09=coleoptile thru soil surface
          ! 10=first leaf emerged from the coleoptile (= emergence)
          ! 11=first leaf fully expanded --> 1n=nth leaf fully expanded
          ! 20=first tiller appeared on some plants --> 2n=nth tiller
          ! 30=f(reproductive stage)

          IF (XSTAGE.GE.8.0 .AND. XSTAGE.LE.9.0) THEN
            ZSTAGE =  ((XSTAGE-8.0)/2.0)*10.0
          ELSEIF (XSTAGE.GT.9.0) THEN
            ZSTAGE = (0.5+((XSTAGE-9.0)/2.0))*10.0
          ELSEIF (XSTAGE.GE.0.0 .AND. XSTAGE.LE.2.3) THEN
            IF (TNUM.LT.2.0) THEN
              ZSTAGE = 10.0 + LNUMSD
            ELSE
              ZSTAGE = AMIN1(30.0,20.0 + (TNUM-1.0))
            ENDIF
            IF (ZSTAGE.LT.ZSTAGEP) ZSTAGE = ZSTAGEP
            ZSTAGEP = ZSTAGE
          ELSEIF (XSTAGE.GT.2.3 .AND. XSTAGE.LE.3.0) THEN
            ZSTAGE = 30.0 + 10.0*(XSTAGE-2.3)/(1.0-0.3)
          ELSEIF (XSTAGE.GT.3.0 .AND. XSTAGE.LE.4.0) THEN
            ZSTAGE = 40.0 + 10.0*(XSTAGE-3.0)
          ELSEIF (XSTAGE.GT.4.0 .AND. XSTAGE.LE.5.0) THEN
            IF (XSTAGE.LT.ASTAGE) THEN
              ZSTAGE = 50.0 + 10.0*((XSTAGE-4.0)/(ASTAGE-4.0))
            ELSEIF (XSTAGE.GE.ASTAGE.AND.XSTAGE.LT.ASTAGEND) THEN
              ZSTAGE = 60.0 + 10.0*((XSTAGE-ASTAGE)/(ASTAGEND-ASTAGE))
            ELSE
              ZSTAGE = 70.0 + 10.0*((XSTAGE-ASTAGEND)/(5.0-ASTAGEND))
            ENDIF
          ELSEIF (XSTAGE.GT.5.0 .AND. XSTAGE.LE.6.0) THEN
            ZSTAGE = 80.0 + 10.0*(XSTAGE-5.0)
          ELSEIF (XSTAGE.GT.6.0 .AND. XSTAGE.LE.7.0) THEN
            ZSTAGE = 90.0 + 10.0*(XSTAGE-6.0)
          ENDIF

          ! Stage dates and characteristics
          ! NB. Characeristics are at end of phase
          IF (ISTAGE.NE.ISTAGEP.AND.ISTAGEP.GT.0) THEN
            STGDOY(ISTAGEP) = YEARDOY
            CWADSTG(ISTAGEP) = CWAD
            LAISTG(ISTAGEP) = LAI
            LNUMSTG(ISTAGEP) = LNUMSD
            CNADSTG(ISTAGEP) = CNAD
          ENDIF
          DAE = MAX(0,CSTIMDIF(STGDOY(9),YEARDOY))
          DAP = MAX(0,CSTIMDIF(STGDOY(7),YEARDOY))
          DAS = MAX(0,CSTIMDIF(YEARSIM,YEARDOY))
          IF (ISTAGE.EQ.6) DAPM = DAPM + 1
          DRSTAGEF = 0.10  ! Double ridge factor .. 'experimental'
          DRSTAGE = AMAX1(1.1,1.9-DRSTAGEF*(LNUMSD-5.0))
          IF (DRDAT.EQ.-99 .AND. RSTAGE.GE.DRSTAGE) THEN
            DRDAT = YEARDOY
            WRITE(fnumwrk,*)'Double ridges. Stage,Leaf#: ',
     &       DRSTAGE,LNUMSD
             ! NB. Experimental. DR occurs at later apical stage when
             !     leaf # less, earlier when leaf # greater (ie.when
             !     early planting of winter type).
          ENDIF
          IF (TSDAT.EQ.-99 .AND. RSTAGE.GE.2.00) TSDAT = YEARDOY
          IF (JDAT.EQ.-99 .AND. RSTAGE.GE.2.0+PD2(1)/PD(2)) THEN
            JDAT = YEARDOY
            WRITE (fnumwrk,*) 'Jointing ocurred on: ',jdat
          ENDIF
          IF (ADAT.LE.0.0 .AND. RSTAGE.GE.4.0+PD4(1)/PD(4)) THEN
            ADAT = YEARDOY
            WRITE (fnumwrk,'(A22,I12)') ' Anthesis ocurred on: ',adat
            RSWAA = RSWAD
            RSCA = RSC
            CWAA = CWAD
            CNAA = CNAD
            LNPCA = LANC*100.0
            ADATEND = -99
          ENDIF
          IF (ADATEND.LE.0.0 .AND.
     &      RSTAGE.GE.4.0+(PD4(1)+PD4(2))/PD(4)) THEN
            ADATEND = YEARDOY
            TMEAN20A = TMEAN20
            SRAD20A = SRAD20
            Tfgnum = TFAC4(trgno,tmean20a,TTOUT)
            ! NB.Temperature factor for grain number not yet implemented
            GRNUM = (LFWT+STWT+RSWT)*G1CWT
            WRITE (fnumwrk,'(A27,I7)')
     &       ' End of anthesis on:        ',adatend
            WRITE (fnumwrk,'(A27,F7.1)')
     &       ' 20d mean temperature       ',tmean20a
            WRITE (fnumwrk,'(A27,F7.2)')
     &       ' Grain # temperature factor ',tfgnum
            WRITE (fnumwrk,*)'Grain #/m2,Nfg ',GRNUM*PLTPOP,NFG
            IF ((GRNUM*PLTPOP).LT.100.0) THEN
              WRITE (fnumwrk,*)'Crop failure - few grains set!'
            ENDIF
          ENDIF
          IF (RSTAGE.GT.ASTAGEND) THEN
            LAGSTAGE = AMAX1(0.0,
     &       AMIN1(1.0,(RSTAGE-ASTAGEND)/(5.0-ASTAGEND)))
          ENDIF


          ! Average nitrogen and water stress
          IF (ISTAGEP.GT.0 .AND. ISTAGEP.LE.6) THEN
            NFPC = NFPC + NFP
            NFGC = NFGC + NFG
            WFPC = WFPC + WFP
            WFGC = WFGC + WFG
            ICSDUR = ICSDUR + 1
            IF (ICSDUR.GT.0) THEN
              NFPAV(ISTAGEP) = NFPC / ICSDUR
              NFGAV(ISTAGEP) = NFGC / ICSDUR
              WFPAV(ISTAGEP) = WFPC / ICSDUR
              WFGAV(ISTAGEP) = WFGC / ICSDUR
            ENDIF
            IF (ISTAGE.NE.ISTAGEP) THEN
              NFPAV(ISTAGE) = 1.0
              NFGAV(ISTAGE) = 1.0
              WFPAV(ISTAGE) = 1.0
              WFGAV(ISTAGE) = 1.0
              NFPC = 0.0
              NFGC = 0.0
              WFPC = 0.0
              WFGC = 0.0
              ICSDUR = 0
            ENDIF
          ENDIF

          ! Phyllochron intervals
          IF (CROP.EQ.'BA'.AND.ISTAGE.NE.ISTAGEP.AND.ISTAGE.EQ.1) THEN
            PHINTS = 77.5 - 232.6*(DAYLT-DAYLTP)
          ENDIF
          IF (LNUMSG.GT.0 .AND. LNUMSG.LT.PHINTCHG) THEN
            PHINT = PHINTS/LNUMF
          ELSE
            PHINT = PHINTS
          ENDIF

          ! Critical and minimum N concentrations
          IF (ISTAGE.LT.7) THEN
            LCNC = YVAL1(LCNCS,'0','9',XSTAGE)
            SCNC = YVAL1(SCNCS,'0','9',XSTAGE)
            RCNC = YVAL1(RCNCS,'0','9',XSTAGE)
            LMNC = YVAL1(LMNCS,'0','9',XSTAGE)
            SMNC = YVAL1(SMNCS,'0','9',XSTAGE)
            RMNC = YVAL1(RMNCS,'0','9',XSTAGE)
          ELSE
            RCNC = RCNCS(0) + (RCNCS(1)-RCNCS(0))*((XSTAGE-8.0)/2.0)
            RMNC = RMNCS(0) + (RCNCS(1)-RCNCS(0))*((XSTAGE-8.0)/2.0)
          ENDIF

          ! N concentrations and adjustments
          ! (Adjustements to account for changes in criticals)
          RANC = 0.0
          LANC = 0.0
          SANC = 0.0
          VANC = 0.0
          IF (RTWT.GT.0.0) RANC = ROOTN / RTWT
          IF (LFWT.GT.0.0) LANC = LEAFN / LFWT
          IF (STWT.GT.0.0) SANC = STEMN / STWT
          IF (VWAD.GT.0.0) VANC = VNAD/VWAD
          RSNGR = AMAX1(0.0,RTWT*(RANC-RCNC))
          RSNGL = AMAX1(0.0,LFWT*(LANC-LCNC))
          RSNGS = AMAX1(0.0,STWT*(SANC-SCNC))
          RSN = RSN + RSNGR + RSNGL + RSNGS
          ROOTN = ROOTN - RSNGR
          LEAFN = LEAFN - RSNGL
          STEMN = STEMN - RSNGS
          IF (RTWT.GT.0.0) RANC = ROOTN/RTWT
          IF (LFWT.GT.0) LANC = LEAFN/LFWT
          IF (STWT.GT.0.0) SANC = STEMN/STWT
          IF (VWAD.GT.0.0) VANC = VNAD/VWAD
          IF (LANC.LT.0.0) THEN
            WRITE(fnumwrk,*)'LANC below 0 with value of ',LANC
            WRITE(fnumwrk,*)'LEAFN,LFWT had values of   ',LEAFN,LFWT
            LANC = AMAX1(0.0,LANC)
          ENDIF

          CANANC = 0.0
          SDNC = 0.0
          GRAINANC = 0.0
          IF ((LFWT+STWT+GRWT+RSWT+DEADWT).GT.0.0)
     &     CANANC = (LEAFN+STEMN+GRAINN+RSN+DEADN)/
     &      (LFWT+STWT+GRWT+RSWT+DEADWT)
          IF (SEEDRS.GT.0.0) SDNC = SEEDN/(SEEDRS+SDCOAT)
          IF (GRWT.GT.0) GRAINANC = GRAINN/GRWT

          LCNF = 0.0
          SCNF = 0.0
          RCNF = 0.0
          IF (LCNC.GT.0.0) LCNF = LANC/LCNC
          IF (LCNF.GT.1.0001 .OR. LCNF.LT.0.0) THEN
            WRITE(fnumwrk,*)'LCNF out of limits with value of ',LCNF
            LCNF = AMAX1(0.0,AMIN1(1.0,LCNF))
          ENDIF
          IF (SCNC.GT.0.0.AND.STWT.GT.1.0E-10) SCNF = SANC/SCNC
          IF (RCNC.GT.0.0.AND.RTWT.GT.0.0) RCNF = RANC/RCNC

          ! Harvesting conditions
          IF (IHARI.EQ.'A' .AND. ISTAGE.EQ.6) THEN
            ! Here need to check out if possible to harvest.
            IF (YEARDOY.GE.HFIRST) THEN
              IF (SW(1).GE.SWPLTL.AND.SW(1).LE.SWPLTH) YEARHARF=YEARDOY
            ENDIF
            ! Check if past earliest date; check if not past latest date
            ! Check soil water
            ! If conditions met set YEARHARF = YEARDOY
            ! (Change YEARHARF to more something more appropriate)
          ENDIF

          ! Harvesting or failure
          IF (DAP.GE.90 .AND. ISTAGE.EQ.8) THEN
            CFLFAIL = 'Y'
            WRITE (FNUMWRK,*)'No germination within 90 days of sowing!'
          ENDIF
          IF (IHARI.NE.'A'.AND.DAPM.GE.90) THEN
            CFLFAIL = 'Y'
            WRITE (FNUMWRK,*)'90 days after physiological maturity!'
            WRITE (FNUMWRK,*)'Harvesting triggered!'
          ENDIF
          IF (IHARI.NE.'A'.AND.ISTAGE.GE.4.AND.ISTAGE.LT.7) THEN
            IF (TT20.NE.-99.0.AND.TT20.LE.0.0) THEN
              CFLFAIL = 'Y'
              WRITE (FNUMWRK,*)'20day thermal time mean = 0!'
              WRITE (FNUMWRK,*)'Harvesting triggered!'
            ENDIF
          ENDIF
          IF (CFLFAIL.EQ.'Y' .OR.
     &     IHARI.EQ.'R'.AND.YEARHARF.GT.-99.AND.YEARHARF.EQ.YEARDOY .OR.
     &     IHARI.EQ.'D'.AND.YEARHARF.GT.-99.AND.YEARHARF.EQ.DAP .OR.
     &     IHARI.EQ.'G'.AND.YEARHARF.GT.-99.AND.YEARHARF.LE.XSTAGE .OR.
     &     IHARI.EQ.'A'.AND.YEARHARF.GT.-99.AND.YEARHARF.EQ.YEARDOY .OR.
     &     IHARI.EQ.'M'.AND.XSTAGE.GE.6.0.AND.XSTAGE.LT.7.0 .OR.
     &     YEARHARF.LE.-99 .AND. XSTAGE.GE.6.9.AND.XSTAGE.LT.7.0) THEN
            IF (CFLFAIL.EQ.'Y') THEN
              STGDOY(10) = YEARDOY
              IF (STGDOY(9).EQ.9999999) STGDOY(9) = -99
              IF (STGDOY(8).EQ.9999999) STGDOY(8) = -99
              IF (STGDOY(5).EQ.9999999) STGDOY(5) = -99
              IF (STGDOY(4).EQ.9999999) STGDOY(4) = -99
              IF (STGDOY(3).EQ.9999999) STGDOY(3) = -99
              IF (STGDOY(2).EQ.9999999) STGDOY(2) = -99
              IF (STGDOY(1).EQ.9999999) STGDOY(1) = -99
              WFPAV(6) = WFPAV(ISTAGE)
              NFPAV(6) = NFPAV(ISTAGE)
            ENDIF
            IF (STGDOY(10).EQ.9999999) STGDOY(10) = -99
            STGDOY(6) = YEARDOY
            STGDOY(11) = YEARDOY
            CWADSTG(6) = CWAD
            LAISTG(6) = LAI
            LNUMSTG(6) = LNUMSD
            CNADSTG(6) = CNAD
            WRITE(fnumwrk,*)' '
            WRITE(fnumwrk,*)'HARVEST REACHED ',YEARDOY
            ! Reset crop stage
            ISTAGE = 7
            XSTAGE = 7.0
          ENDIF

          IF(IHARI.EQ.'R'.AND.YRHARF.GT.-99.AND.YEARDOY.LT.YEARHARF)THEN
            IF (XSTAGE.GT.6.9 .AND. YRHARFF .NE. 'Y') THEN
              ! This loop is necessary because of non-sequential staging
              IF (XSTAGE.LT.7.0) THEN
                WRITE(fnumwrk,*)
     &           'WAITING FOR HARVEST! YEARDOY,YRHAR ',YEARDOY,YRHARF
                YRHARFF = 'Y'
              ENDIF
            ENDIF
          ENDIF

          ! After harvest residues
          IF (STGDOY(11).EQ.YEARDOY) THEN
            ! Surface
            RESWALG(0) = VWAD*(1.0-HBPC/100.0) + GWAD*(1.0-HPC/100.0)
            RESNALG(0) = (LEAFN+STEMN+DEADN)*PLTPOP*10.0*(1.0-HBPC/100.)
     &                 + GNAD*(1.0-HPC/100.0)
            RESCALG(0) = RESWALG(0) * 0.4
            RESLGALG(0) = LLWAD*LLIGP/100.0*(1.0-HBPC/100.0)
     &                  + LSWAD*SLIGP/100.0*(1.0-HBPC/100.0)
     &                  + STWAD*SLIGP/100.0*(1.0-HBPC/100.0)
     &                  + GWAD*GLIGP/100.0*(1.0-HPC/100.0)
            ! Soil
            DO L = 1, NLAYR
              RESWALG(L) = RTWTL(L)*PLTPOP*10.0
              RESNALG(L) = RTWTL(L)*PLTPOP*10.0 * RANC
              RESCALG(L) = RTWTL(L)*PLTPOP*10.0 * 0.4
              RESLGALG(L) = RTWTL(L)*PLTPOP*10.0 * RLIGP/100.0
            ENDDO

            ! Surface
            RESWAL(0) = RESWAL(0) + RESWALG(0)
            RESNAL(0) = RESNAL(0) + RESNALG(0)
            RESCAL(0) = RESCAL(0) + RESCALG(0)
            RESLGAL(0) = RESLGAL(0) + RESLGALG(0)
            ! Soil
            DO L = 1, NLAYR
              RESWAL(L) = RESWAL(L) + RESWALG(L)
              RESNAL(L) = RESNAL(L) + RESNALG(L)
              RESCAL(L) = RESCAL(L) + RESCALG(L)
              RESLGAL(L) = RESLGAL(L) + RESLGALG(L)
            ENDDO
          ENDIF

          ! Weather summary variables
          CUMTT = CUMTT + TT
          TMAXX = AMAX1(TMAXX,TMAX)
          TMINN = AMIN1(TMINN,TMIN)
          CO2MAX = AMAX1(CO2MAX,CO2)
          RAINC = RAINC + RAIN
          IF (ADAT.LT.0) RAINCA = RAINCA + RAIN
          SRADC = SRADC + SRAD
          IF (XSTAGE.GE.5.0 .AND. XSTAGE.LT.6.0) THEN
            GFTSUM = GFTSUM + TMEAN
            GFDSUM = GFDSUM + 1
            GFTMEAN = GFTSUM/GFDSUM
          ENDIF
          IF (XSTAGE.GE.5.7 .AND. XSTAGE.LT.6.0) THEN
            GMTSUM = GMTSUM + TMEAN
            GMDSUM = GMDSUM + 1
            GMTMEAN = GMTSUM/GMDSUM
          ENDIF
          IF (XSTAGE.GE.8.0 .AND. XSTAGE.LT.10.0) THEN
            GETSUM = GETSUM + TMEAN
            GEDSUM = GEDSUM + 1
            GETMEAN = GETSUM/GEDSUM
          ENDIF
          CALL Calendar (year,doy,dom,month)
          IF (DOM.GT.1) THEN
            TMAXSUM = TMAXSUM + TMAX
            TMINSUM = TMINSUM + TMIN
            DAYSUM = DAYSUM + 1.0
          ELSE
            IF (DAYSUM.GT.0) THEN
              IF (TMAXM.LT.TMAXSUM/DAYSUM) TMAXM=TMAXSUM/DAYSUM
              IF (TMINM.GT.TMINSUM/DAYSUM) TMINM=TMINSUM/DAYSUM
            ENDIF
              TMAXSUM = TMAX
              TMINSUM = TMIN
              DAYSUM =  1
          ENDIF

          ! N fertilizer applications
          IF (NFERT.GT.0.AND.IFERI.EQ.'R'.AND.YEARDOY.EQ.YEARPLT) THEN
            DO I = 1, NFERT
              IF (FDAY(I).GT.YEARDOY) EXIT
              IF (FDAY(I).LE.-99) EXIT
              AMTNIT = AMTNIT + ANFER(I)
            END DO
            IF (FILEIOT.EQ.'XFL') WRITE(fnumwrk,*)' '
            WRITE(fnumwrk,'(A24,I4,A6)')
     &       ' FERTILIZER N PRE-PLANT ',NINT(amtnit),' kg/ha'
            IF (FILEIOT.EQ.'DS4') WRITE(fnumwrk,*)' '
          ENDIF
          IF (NFERT.GT.0.AND.IFERI.EQ.'R'.AND.YEARDOY.GT.YEARPLT) THEN
            DO I = 1, NFERT
              IF (FDAY(I).GT.YEARDOY) EXIT
              IF (FDAY(I).EQ.YEARDOY) THEN
                AMTNIT = AMTNIT + ANFER(I)
                WRITE(fnumwrk,'(A14,I4,A10,I7,A13,I4,A6)')
     &          ' Fertilizer N ',NINT(anfer(i)),' kg/ha on ',
     &          YEARDOY,'     To date ',NINT(amtnit),' kg/ha'
              ENDIF
            END DO
          ENDIF

          ! Adjustment of kernel growth rate;set temperature response
          IF (ISTAGE.EQ.5.AND.ISTAGEP.EQ.4) THEN
            WRITE(fnumwrk,*)'Start of linear kernel growth    '
            WRITE(fnumwrk,*)' Original kernel growth rate (G2) ',g2
            G2 = (G2KWT-(GRWT/GRNUM)*1000.0) / (PD(5)*(6.0-XSTAGE))
           WRITE(FNUMWRK,*)' G2 2 ',G2,G2KWT,GRWT,GRNUM,PD(5),XSTAGE
            WRITE(fnumwrk,*)' Adjusted kernel growth rate (G2) ',g2
            ! Replace base temperature,grain filling with ecotype value
            IF (TBGF.GT.-99.0) TRDV2(1) = TBGF
          ENDIF

          ! Stored variables (For use next day or step)
          ISTAGEP = ISTAGE
          ZSTAGEP = ZSTAGE
          RSTAGEP = RSTAGE
          DAYLTP = DAYLT

          ! Soil water aspects
          BLAYER = 0.0
          H2OA = 0.0
          IF (ISWWAT.EQ.'Y') THEN
            DO L = 1, NLAYR
              DLAYRTMP(L) = DLAYR(L)
              BLAYER = BLAYER + DLAYR(L)
              IF (RTDEP.GT.0.0.AND.RTDEP.LT.BLAYER) THEN
                DLAYRTMP(L) = RTDEP-(BLAYER-DLAYR(L))
                IF (DLAYRTMP(L).LE.0.0) EXIT
              ENDIF
              H2OA = H2OA + 10.0*AMAX1(0.0,(SW(L)-LL(L))*DLAYRTMP(L))
            ENDDO
            IF (EOP.GT.0.0) THEN
              WAVR = H2OA/EOP
            ELSE
              WAVR = 99.9
            ENDIF
          ENDIF

        ENDIF


      ELSEIF (DYNAMIC.EQ.OUTPUT) THEN

        IF (YEARDOY.GE.YEARPLT .AND. STEP.EQ.STEPNUM) THEN

          ! General file header
          IF (TN.LT.10) THEN
           WRITE (OUTHED,7104) RUNRUNI(1:5),EXCODE,TN,RN,CN,TRUNNAME
 7104      FORMAT ('*RUN ',A5,A10,' ',I1,',',I1,' C',I1,' ',A40,'  ')
          ELSEIF (TN.GE.10. AND. TN.LT.100) THEN
           WRITE (OUTHED,7105) RUNRUNI,EXCODE,TN,RN,CN,TRUNNAME
 7105      FORMAT ('*RUN ',A5,A10,' ',I2,',',I1,' C',I1,' ',A40,' ')
          ELSEIF (TN.GE.10 .AND. TN.LT.100) THEN
           WRITE (OUTHED,7106) RUNRUNI,EXCODE,TN,RN,CN,TRUNNAME
 7106      FORMAT ('*RUN ',A5,A10,' ',I3,',',I1,' C',I1,' ',A40)
          ENDIF

          ! If seeding day
          IF (YEARDOY.EQ.STGDOY(7)) THEN
            CNCHAR = ' '
            IF (CN.EQ.1) THEN
              OUTPG = 'PlantGro.OUT'
              OUTPN = 'PlantN.OUT  '
              CALL GETLUN ('OUTPG',NOUTDG)
              CALL GETLUN ('OUTPN',NOUTDGN)
            ELSE
              CNCHAR = TL10FROMI(CN)
              OUTPG = 'PlantGro.OU'//CNCHAR(1:1)
              OUTPN = 'PlantN.OU'//CNCHAR(1:1)
              CALL GETLUN (OUTPG,NOUTDG)
              CALL GETLUN (OUTPN,NOUTDGN)
            ENDIF
            ! Open output file(s)
            IF (RUN.EQ.1 .AND. RUNI.LE.1) THEN
              OPEN (UNIT = NOUTDG, FILE = OUTPG)
              WRITE (NOUTDG,'(A27)')
     &        '*GROWTH ASPECTS OUTPUT FILE'
              OPEN (UNIT = NOUTDGN, FILE = OUTPN)
              WRITE (NOUTDGN,'(A35)')
     &        '*PLANT NITROGEN ASPECTS OUTPUT FILE'
              CLOSE (NOUTDG)
              CLOSE (NOUTDGN)
            ENDIF

            IF (IDETG.EQ.'Y') THEN
              OPEN (UNIT = NOUTDG, FILE = OUTPG, STATUS='UNKNOWN',
     &        ACCESS = 'APPEND')
              OPEN (UNIT = NOUTDGN, FILE = OUTPN, STATUS = 'UNKNOWN',
     &        ACCESS = 'APPEND')
              WRITE (NOUTDG,'(/,A70,/)') OUTHED
              WRITE (NOUTDGN,'(/,A70,/)') OUTHED
              WRITE (NOUTDG,103) MODEL
              WRITE (NOUTDGN,103) MODEL
  103         FORMAT (' MODEL            ',A8)
              WRITE (NOUTDG,1031) MODULE
              WRITE (NOUTDGN,1031) MODULE
 1031         FORMAT (' MODULE           ',A8)
              WRITE (NOUTDG,104)
     &         EXCODE(1:8),' ',EXCODE(9:10),'  ',ENAME(1:47)
              WRITE (NOUTDGN,104)
     &         EXCODE(1:8),' ',EXCODE(9:10),'  ',ENAME(1:47)
  104         FORMAT (' EXPERIMENT       ',A8,A1,A2,A2,A47)
              WRITE (NOUTDG,102) TN,TNAME
              WRITE (NOUTDGN,102) TN,TNAME
  102         FORMAT (' TREATMENT',I3,'     ',A25)
              WRITE (NOUTDG,107) CROP,VARNO,VRNAME
              WRITE (NOUTDGN,107) CROP,VARNO,VRNAME
  107         FORMAT (' GENOTYPE         ',A2,A6,'  ',A16)
              CALL Calendar (year,doy,dom,month)
              WRITE (NOUTDG,108) month,dom,NINT(pltpop),NINT(rowspc)
              WRITE (NOUTDGN,108) month,dom,NINT(pltpop),NINT(rowspc)
  108         FORMAT (' ESTABLISHMENT    ',A3,I3,2X,I4,' plants/m2 in ',
     &        I3,' cm rows',/)

              ! Write variable headings
              WRITE (NOUTDG,2201)
 2201           FORMAT ('@YEAR DOY   DAS   DAP',
     &                 '  GSTD  L#SD',
     &                 '  PARI PARUE  AWAG',
     &                 '  LAID  SAID',
     &                 '  TWAD SDWAD  RWAD  CWAD  LWAD',
     &                 '  SWAD CHWAD RSWAD  GWAD  EWAD  DWAD',
     &                 '  RS%D',
     &                 '  G#AD  GWGD',
     &                 '  HIAD  HIND',
     &                 '  T#AD  LAWD  RDPD',
     &                 '  H2OA  WAVR',
     &                 '  WUPR WFTID  WFPD  WFGD  WFSD',
     &                 ' NFTID  NFPD  NFGD  NFSD  NUPR',
     &                 '  TFPD  TFGD',
     &                 '  VRNF DAYLF TKILL',
     &                 '   PTF',
     &                 ' SENWT SENNT      ')
                WRITE (NOUTDGN,2251)
 2251           FORMAT ('@YEAR DOY   DAS   DAP  NUAD',
     &            '  TNAD  RNAD SDNAD  CNAD  LNAD  SNAD  GNAD',
     &            '  RN%D  LN%D  SN%D  GN%D SDN%D  VN%D  SCNF',
     &            '  LCNF  RCNF  NFPD  NFGD NFTID  NFSD  NUPR',
     &            '  RL1D  RL2D  RL3D  RL4D  RL5D  RL6D',
     &            '  RL7D  RL8D  RL9D RL10D  CHTD',
     &            ' SENL0 SENN0 SENC0 SENLS SENNS SENCS',
     &            '  RNUA RSNAD')
            ENDIF
          ENDIF

          IF ((MOD(DAS,FROP).EQ.0)
     &     .OR. (YEARDOY.EQ.STGDOY(7))
     &     .OR. (YEARDOY.EQ.STGDOY(11))) THEN
            IF (IDETG.EQ.'Y') THEN
              CALL Csopline(senwt,(senwl(0)+senws))
              CALL Csopline(sennt,(sennl(0)+senns))
              IF (PARIP.GE.0.0) THEN
                PARIOUT = PARIP/100.0
              ELSE
                PARIOUT = PARI
              ENDIF
              WRITE (NOUTDG,
     &        '(I5,I4,2I6,
     &        2F6.2,
     &        2F6.2,F6.1,
     &        2F6.2,
     &        7I6,
     &        4I6,
     &        F6.1,
     &        2I6,
     &        2F6.2,
     &        2I6,F6.2,
     &        2F6.1,
     &        5F6.2,
     &        4F6.2,F6.1,
     &        2F6.2,
     &        2F6.2,
     &        F6.1,F6.2,
     &        2A6)')
     &        YEAR,DOY,DAS,DAP,
     &        ZSTAGE,LNUMSD,
     &        PARIOUT,PARUED,AMIN1(999.9,CARBOA),
     &        LAI,SAID,
     &        NINT(TWAD),
     &        NINT(SDWAD),
     &        NINT(RWAD),
     &        NINT(CWAD),
     &        NINT(LLWAD),
     &        NINT(STLSRWAD),
     &        NINT(CHWAD),
     &        NINT(RSWAD),
     &        NINT(GWAD),NINT(EWAD),
     &        NINT(DWAD),
     &        RSC*100.0,
     &        NINT(GRNUMAD),NINT(GWGD),
     &        HIAD,HIND,
     &        NINT(TNUMAD),NINT(SLA),RTDEP/100.0,
     &        H2OA,AMIN1(99.9,WAVR),
     &        AMIN1(15.0,WUPR),1.0-WFTI,1.0-WFP,1.0-WFG,1.0-WFS,
     &        1.0-NFTI,1.0-NFP,1.0-NFG,1.0-NFS,AMIN1(2.0,NUPR),
     &        1.0-TFP,1.0-TFG,
     &        VF,DF,
     &        TKILL,PTF,
     &        SENWT,SENNT

              IF (ISWNIT.EQ.'Y') THEN
                CALL Csopline(senl0,senlgalg(0))
                CALL Csopline(senn0,sennalg(0))
                CALL Csopline(senc0,sencalg(0))
                CALL Csopline(senlgstmp,senlgas)
                CALL Csopline(sennstmp,sennas)
                CALL Csopline(sencstmp,sencas)
                WRITE (NOUTDGN,'(
     &           I5,I4,2I6,F6.1,
     &           F6.1,
     &           F6.2,
     &           4F6.1,
     &           1F6.1,6F6.2,F6.1,
     &           2F6.1,
     &           5F6.2,
     &           10F6.2,F6.1,
     &           6A6,
     &           2F6.2)')
     &           YEAR,DOY,DAS,DAP,NUAD,
     &           TNAD,
     &           RNAD,
     &           SDNAD,
     &           CNAD,
     &           LLNAD,
     &           SNAD,
     &           GNAD,
     &           RANC*100.0, LANC*100.0, SANC*100.0,
     &           GRAINANC*100.0,SDNC*100.0, VANC*100.0,
     &           SCNF, LCNF, RCNF,
     &           1.0-NFP, 1.0-NFG, 1.0-NFTI, 1.0-NFS, AMIN1(2.0,NUPR),
     &           (RLV(I),I = 1,10), CANHT,
     &           SENL0,SENN0,SENC0,SENLGSTMP,SENNSTMP,SENCSTMP,
     &           NUAG,RSNAD
              ENDIF  ! ISWNIT = Y
            ENDIF    ! IDETG = Y
          ENDIF      ! MOD(FROP)

          ! Harvest date or failure writes
          IF (STGDOY(11).EQ.YEARDOY) THEN

            WRITE(fnumwrk,*)' '
            WRITE(fnumwrk,'(A17,I2)')' CROP COMPONENT: ',CN
            WRITE(fnumwrk,'(A32,F8.1)')
     &       '  DEAD MATERIAL LEFT ON SURFACE  ',SENWAL(0)
            WRITE(fnumwrk,'(A32,F8.1)')
     &       '  DEAD MATERIAL LEFT IN SOIL     ',SENWAS
            WRITE(fnumwrk,'(A32,F8.1)')
     &       '  ROOT WEIGHT AT HARVEST         ',RWAD

            WRITE (fnumwrk,*) ' '
            WRITE (fnumwrk,'(A20,A10,I3)')
     &       ' ROOTS BY LAYER FOR ',excode,tn
            WRITE (fnumwrk,'(A19)')
     &       '  LAYER  RTWT   RLV'
            DO L=1,NLAYR
              WRITE (fnumwrk,'(I6,F7.1,F6.2)')
     &        L,RTWTAL(L),RLV(L)
            ENDDO

            WRITE (fnumwrk,*) ' '
            WRITE (fnumwrk,'(A15,A10,I3)')' N BALANCE FOR ',excode,tn
            WRITE (fnumwrk,'(A25,F8.4)')'   N UPTAKE + SEED       ',
     &       NUAD+SDNAP
            WRITE (fnumwrk,'(A25,3F8.4)')'   TOTAL N SENESCED      ',
     &       SENNAL(0)+SENNAS,SENNAL(0),SENNAS
            WRITE (fnumwrk,'(A25,F8.4)')'   N IN DEAD MATTER      ',
     &       DNAD
            WRITE (fnumwrk,'(A25,F8.4)')'   TOTAL N IN PLANT      ',
     &       TNAD
            WRITE (fnumwrk,'(A25,F8.4)')'   BALANCE (A-(B+C+D))   ',
     &       NUAD+SDNAP
     &       - (SENNAL(0)+SENNAS)
     &       - TNAD
            IF (TNAD.GT.0.0 .AND.
     &       ABS(NUAD+SDNAP-(SENNAL(0)+SENNAS)-TNAD)/TNAD.GT.0.01)
     &       WRITE(fnumwrk,'(A26,A10,A1,I2)')
     &       '   PROBLEM WITH N BALANCE ',EXCODE,' ',TN

            WRITE (fnumwrk,*) ' '
            WRITE (fnumwrk,'(A18,A10,I3)')' CH2O BALANCE FOR ',excode,tn
            WRITE (fnumwrk,'(A27, F11.4)')'   SEED + CH2O FIXED A     ',
     &       SDRATE+CARBOAC
            WRITE (fnumwrk,'(A27, F11.4)')'   CH2O RESPIRED B         ',
     &       RESPAC
            WRITE (fnumwrk,'(A27,3F11.4)')'   CH2O SENESCED C  Tops,rt',
     &       SENWAL(0)+SENWAS,SENWAL(0),SENWAS
            WRITE (fnumwrk,'(A27, F11.4)')'   CH2O IN LIVE+DEAD D     ',
     &       TWAD
            WRITE (fnumwrk,'(A27, F11.4)')'   CH2O IN DEAD MATTER     ',
     &       DWAD
            WRITE (fnumwrk,'(A27, F11.4)')'   CH2O IN LIVE PLANT      ',
     &       TWAD-DWAD
            WRITE (fnumwrk,'(A27, F11.4)')'   POST MATURITY RESERVES E',
     &       RSWADPM
            WRITE (fnumwrk,'(A27, F11.4)')'   BALANCE (A-(B+C+D+E))   ',
     &         SDRATE+CARBOAC-RESPAC-(SENWAL(0)+SENWAS)
     &       - TWAD-RSWADPM
            IF (TWAD.GT.0.0 .AND.
     &       ABS(SDRATE+CARBOAC-RESPAC-(SENWAL(0)+SENWAS)
     &       - TWAD-RSWADPM)/TWAD .GT. 0.01)
     &       WRITE(fnumwrk,'(A29,A10,A1,I2)')
     &       '   PROBLEM WITH CH2O BALANCE ',EXCODE,' ',TN

            WRITE (fnumwrk,*) ' '
            WRITE (fnumwrk,'(A22,A10,I3)')
     &       ' STAGE CONDITIONS FOR ',excode,tn
            WRITE (fnumwrk,'(A38,F6.1)')
     &       '  Temperature mean,germ+emergence      ',GETMEAN
            WRITE (fnumwrk,'(A38,F6.1)')
     &       '  Temperature mean,first 20 days       ',TMEAN20P
            WRITE (fnumwrk,'(A38,F6.1)')
     &       '  Temperature mean,20d around anthesis ',TMEAN20A
            WRITE (fnumwrk,'(A38,F6.1)')
     &       '  Solar radn. mean,20d around anthesis ',SRAD20A
            WRITE (fnumwrk,'(A38,F6.1)')
     &       '  Temperature mean,grain filling       ',GFTMEAN
            WRITE (fnumwrk,'(A38,F6.1)')
     &       '  Temperature mean,grain maturing      ',GMTMEAN

            WRITE (fnumwrk,*) ' '
            WRITE (fnumwrk,'(A17,A10,I3)')' STAGE DATES FOR ',excode,tn
            WRITE (fnumwrk,'(A26)')
     &       '  STAGE   DATE  STAGE NAME'
            DO I = 1, 11
              WRITE (fnumwrk,'(I7,I8,A1,A10)')
     &               I,STGDOY(I),' ',STNAME(I)
            ENDDO

            WRITE (fnumwrk,*) ' '
            WRITE (fnumwrk,'(A27,A10,I3)')
     &       ' LEAF NUMBER AND SIZES FOR ',excode,tn
            WRITE (fnumwrk,'(A15,F4.1)') '   LEAF NUMBER ',LNUMSD
            WRITE (fnumwrk,'(A55)')
     &       '   LEAF AREAP AREA1 AREAT AREAS TNUML  WFLF  NFLF  AFLF'
            IF (LNUMSG.GT.0) THEN
              DO I = 1, LNUMSG
                WRITE (fnumwrk,'(I7,8F6.1)')
     &           I,LAPOT(I),LATL(1,I),LAP(I),LAPS(I),TNUML(I),
     &            1.0-WFLF(I),1.0-NFLF(I),1.0-AFLF(I)
              ENDDO
            ELSE
              WRITE (fnumwrk,*) ' Leaf number < 1!'
            ENDIF

            IF (CN.EQ.1 .AND. IDETL.EQ.'Y') THEN
              IF (FNUMLVS.LE.0.OR.FNUMLVS.GT.1000) THEN
                CALL Getlun ('LEAVES.OUT',fnumlvs)
              ENDIF
              IF (RUN.EQ.1 .AND. RUNI.EQ.1) THEN
               OPEN(UNIT=FNUMLVS,FILE='LEAVES.OUT',STATUS='UNKNOWN')
               WRITE (FNUMLVS,'(A17)') '$(2004)LEAF SIZES'
               CLOSE(FNUMLVS)
              ENDIF
              OPEN(UNIT=FNUMLVS,FILE='LEAVES.OUT',ACCESS='APPEND')
              WRITE (FNUMLVS,'(/,A70,/)') OUTHED
              WRITE (FNUMLVS,'(A42,A18)')
     &        '@ LNUM AREAP AREA1 AREAT AREAS  T#PL  T#AL',
     &        '  WFLF  NFLF  AFLF'
              IF (LNUMSG.GT.0) THEN
                DO I = 1, LNUMSG
                  WRITE (fnumlvs,'(I6,5F6.1,I6,3F6.1)')
     &             I,LAPOT(I),LATL(1,I),LAP(I),LAPS(I),
     &             TNUML(I),NINT(TNUML(I)*PLTPOP),
     &             1.0-WFLF(I),1.0-NFLF(I),1.0-AFLF(I)
                ENDDO
              ENDIF
              IF (run.EQ.1.AND.runi.EQ.1) THEN
                WRITE(fnumlvs,*)' '
                WRITE(fnumlvs,'(A37)')
     &           '! LNUM  = Number of leaf on main axis'
                WRITE(fnumlvs,'(A38)')
     &           '! AREAP = Potential area of leaf (cm2)'
                WRITE(fnumlvs,'(A41)')
     &           '! AREA1 = Area of leaf on main axis (cm2)'
                WRITE(fnumlvs,'(A44,A16)')
     &           '! AREAT = Area of leaves on all axes at leaf',
     &           ' position (cm2) '
                WRITE(fnumlvs,'(A50,A6)')
     &           '! AREAS = Area of leaves senesced at leaf position',
     &           ' (cm2)'
                WRITE(fnumlvs,'(A46)')
     &           '! T#PL  = Tiller number/plant at leaf position'
                WRITE(fnumlvs,'(A49)')
     &           '! T#AL  = Tiller number/area(m2) at leaf position'
                WRITE(fnumlvs,'(A38,A17)')
     &           '! WFLF  = Water stress factor for leaf',
     &           ' (0-1,0=0 stress)'
                WRITE(fnumlvs,'(A51)')
     &           '! NFLF  = N stress factor for leaf (0-1,0=0 stress)'
                WRITE(fnumlvs,'(A36,A24)')
     &           '! AFLF  = Assimilate factor for leaf',
     &           ' (0-1,0=0 no limitation)'
              ENDIF
              CLOSE (FNUMLVS)
            ENDIF

            WRITE (fnumwrk,*) ' '
            WRITE (fnumwrk,'(A28,A10,I3)')
     &       ' STRESS FACTOR AVERAGES FOR ',excode,tn
            WRITE (fnumwrk,'(A55)')
     &       '  PHASE  H2O(PS)   H2O(GR)   N(PS)     N(GR)  PHASE END'
            DO tvi1=1,5
              WRITE (fnumwrk,'(I6,F8.2,3F10.2,2X,A10)')
     &        tvi1,1.0-wfpav(tvi1),1.0-wfgav(tvi1),
     &        1.0-nfpav(tvi1),1.0-nfgav(tvi1),stname(tvi1)
            ENDDO
            WRITE (fnumwrk,'(A42)')
     &       '  NB 0.0 = minimum ; 1.0 = maximum stress.'

            WRITE (fnumwrk,*) ' '
            WRITE (fnumwrk,'(A22,A10,I3)')
     &       ' RESERVES STATUS FOR ',excode,tn
            WRITE (fnumwrk,'(A20,F6.1)')'  Kg/ha at anthesis ',RSWAA
            WRITE (fnumwrk,'(A20,F6.1)')'  Kg/ha at maturity ',RSWAD
            IF (cwaa.GT.0) WRITE (fnumwrk,'(A20,F6.1)')
     &       '  % at anthesis     ',rsca*100.0
            IF (lfwt+stwt+rswt.GT.0) WRITE (fnumwrk,'(A20,F6.1)')
     &       '  % at maturity     ',rswt/(lfwt+stwt+rswt)*100.0
            WRITE (fnumwrk,*) ' '
            WRITE (fnumwrk,'(A20,F6.2)')'  Reserves coeff    ',RSFRS
            WRITE (fnumwrk,'(A20,F6.2)')'  Stem gr end stage ',P4SGE
            WRITE (fnumwrk,'(A20,F6.2)')
     &       '  Anthesis stage    ',(4.0+PD4(1)/PD(4))
            WRITE (fnumwrk,*) ' '
            IF (grnum.GT.0.0) WRITE (fnumwrk,'(A20,F6.1)')
     &       '  Grain weight mg   ',GRWT/GRNUM*1000.0
            WRITE (fnumwrk,'(A20,F6.1)')
     &       '  Grain weight coeff',g2kwt
            IF (GRNUM.GT.0.0.AND.G2KWT-GRWT/GRNUM*1000.0.GT.0.1) THEN
              WRITE (fnumwrk,'(A34)')
     &         '  Some limitation on grain growth!'
              WRITE(fnumwrk,'(A22,I4)')'   Days of Ch2o limit ',ch2olim
              WRITE(fnumwrk,'(A22,I4)')'   Days of N limit    ',nlimit
              WRITE(fnumwrk,'(A22,I4)')'   Days of temp limit ',tlimit
            ENDIF
            IF (grwt.GT.0.0) WRITE (fnumwrk,'(A20,F6.1)')
     &       '  Grain N %         ',grainn/grwt*100.0
            WRITE (fnumwrk,'(A20,F6.1)')
     &       '  Minimum grain N % ',grnmn
            WRITE (fnumwrk,'(A20,F6.1)')
     &       '  Standard grain N %',grns

            CALL CSOUTPUT (FILEIO, FILEIOT, RUN, TN, RN, RNMODE,
     &       CUDIRFLE, ECDIRFLE, SPDIRFLE, IDETG, IDETO, IDETL, IDETOU,
     &       ISWWAT, ISWNIT, RUNI, SN, ON, REP, STEP, CN,
     &       MODEL, MODULE, MODE, OUTHED, FROP, VERSION, VERSIOND,
     &       EXCODE, RUNNAME, VARNO,
     &       SRADC, TMAXX, TMAXM, TMINN, TMINM, RAINC, RAINCA, CO2MAX,
     &       AMTNIT,
     &       ADAT, STGDOY, YEARPLT, YEARSIM, DRDAT, TSDAT, JDAT,
     &       SDRATE, SDNAP,
!CHP 2/4/2005     &       GWAD, GWUD, GRNUMAD, HPC, HBPC,
     &       GWAD, GWAD+CHWAD, GWUD, GRNUMAD, HPC, HBPC,
     &       HIAD, LAIX, LNUMSD, TNUMAD,
     &       CARBOAC,SENWAL(0)+SENWAS,
     &       CWAD,
     &       VWAD,CWAA,
     &       CNAD,VNAD,
     &       SENNAL(0)+SENNAS,
     &       GNAD,
     &       RWAD, RNAD,
     &       RSWAD,
     &       HIND, GRAINANC*100.0, VANC*100.0,
     &       CNAA, LNPCA,
     &       NUAD,
     &       STNAME,CWADSTG,CNADSTG,LAISTG,LNUMSTG,NFPAV,WFPAV,
     &       ENAME,TNAME,CROP,VRNAME,PLTPOP,ROWSPC,EDATM)

             ! Need to re-initialize here because of automatic
             ! fertilization routines in DSSAT
             NFG = 1.0
             NFP = 1.0
             NFS = 1.0
             NFTI = 1.0
             WFG = 1.0
             WFP = 1.0
             WFS = 1.0
             WFTI = 1.0

          ! CHP moved this at LAH's request 12/07/2005
          ! LAH FOR PAUL'S PROBLEM
          IF (FILEIOT.EQ.'DS4') CLOSE(FNUMWRK)

          ENDIF

!          ! LAH FOR PAUL'S PROBLEM
!          IF (FILEIOT.EQ.'DS4') CLOSE(FNUMWRK)

        ENDIF        ! YEARDOY >= YEARPLT


      ELSEIF (DYNAMIC.EQ.FINAL) THEN

        CLOSE (NOUTDG)
        CLOSE (NOUTDGN)

      ENDIF   ! Tasks

      cswdis = 'N'
!     IF(cswdis.EQ.'Y')
!    X CALL Disease(run,sn,on,spdirfle,     ! Run+crop component in
!    X cn,step,runi,frop,ename,runname,excode, ! Loop info.
!    X tn,tname,
!    X year,doy,                           ! Dates
!    & tmax,tmin,dewdur,daylt,             ! Drivers - weather
!    & pla,plas,pltpop,                    ! States - leaves
!    & lcnum,lap,LAPP,laps ,               ! States - leaves
!    & stgdoy,                             ! Stage dates
!    & dynamic)                            ! Control

      END  ! CSCER040

!=======================================================================
!  CE_ROOTGR Subroutine
!  Determines root growth aspects
!-----------------------------------------------------------------------
!  Revision history
!  1. Written
!  2  Modified                              E. Alocilja & B. Baer 9-88
!  3  Modified                              T. Jou                4-89
!  4. Header revision and minor changes             P.W.W.      2-8-93
!  5. Added switch block, etc.                      P.W.W.      2-8-93
!  6  Slowed growth of roots in deeper soils.  J.T.R. & B.D.B. 6-20-94
!  7. Converted to modular routine                  W.D.B.     4-01-01
!  8. Worked further on modular structure           L.A.H.    11-09-02
!  9. Removed integration step,introduced layer wt  L.A.H.    13-12-02
!=======================================================================

      SUBROUTINE CE_ROOTGR (ISWNIT,STDDAY,VERSION,
     & CUMTT,TT,ISTAGE,DAE,
     & NO3LEFT,NH4LEFT,NLAYR,DLAYR,SW,LL,DUL,SHF,
     & RLWR,RSEN,RDGS1,RDGS2,WFRG,NFRG,WFRDG,RDGTH,SDAFR,RLDGR,
     & PLTPOP,RTDEP,RTWTL,WFP,RTWTG,SEEDRSAV,RANC,RMNC,
     & rtdepg,rtwts,rtwtgl,rtwtsl,rtnsl,rtwtgs)

      IMPLICIT  NONE
      SAVE

      REAL          CUMDEP        ! Cumulative depth               cm
      REAL          CUMTT         ! Cumulative thermal time        C
      INTEGER       DAE           ! Days after emergence           #
      REAL          DLAYR(20)     ! Depth of soil layers           cm
      REAL          TT            ! Thermal time                   C
      REAL          DUL(20)       ! Drained upper limit for soil   #
      INTEGER       FNUMWRK       ! File number,work file          #
      INTEGER       ISTAGE        ! Developmental stage            #
      CHARACTER*1   ISWNIT        ! Soil nitrogen balance switch   code
      INTEGER       L             ! Loop counter                   #
      INTEGER       L1            ! Loop counter                   #
      REAL          LL(20)        ! Lower limit,soil h2o           #
      REAL          NFRG          ! N factor,root growth 0-1       #
      REAL          NH4LEFT(20)   ! NH4 concentration in soil      mg/Mg
      INTEGER       NLAYR         ! Number of layers in soil       #
      REAL          NO3LEFT(20)   ! NO3 concentration in soil      mg/Mg
      REAL          PLTPOP        ! Plant Population               #/m2
      REAL          RANC          ! Roots actual N concentration   #
      REAL          RDGS1         ! Root depth growth rate,initial cm/d
      REAL          RDGS2         ! Root depth growth rate,2nd     cm/d
      REAL          RDGTH         ! Rooting depth growth threshold dd
      REAL          RLDF(20)      ! Root length density fac,new gr #
      REAL          RLDGR         ! Root length/root depth g ratio cm/cm
      REAL          RLWR          ! Root length/weight ratio       m/mg?
      REAL          RMNC          ! Root minimum N conc            g/g
      REAL          RNFAC         ! N factor for root growth 0-1   #
      REAL          RSEN          ! Root senescence fraction       /d
      REAL          RTDEP         ! Root depth                     cm
      REAL          RTDEPG        ! Root depth growth              cm/d
      REAL          RTDEPTMP      ! Root depth,temporary value     cm/d
      REAL          RTWTG         ! Root weight growth             g/p
      REAL          RTWTGL(20)    ! Root weight growth by layer    g/p
      REAL          RTWTGS        ! Root weight growth from seed   g/p
      REAL          RTWTL(20)     ! Root weight by layer           g/p
      REAL          RTWTSL(20)    ! Root weight senesced by layer  g/p
      REAL          RTWTS         ! Root weight senesced           g/p
      REAL          RTNSL(20)     ! Root N senesced by layer       g/p
      REAL          SDAFR         ! Seed reserves fraction avail   /d
      REAL          SEEDRSAV      ! Seed reserves                  g/p
      REAL          SHF(20)       ! Soil hospitality factor 0-1    #
      REAL          STDDAY        ! Standard day                   C.d/d
      REAL          SW(20)        ! Soil water content             #
      REAL          SWDF          ! Soil water deficit factor 0-1  #
      REAL          TRLDF         ! Intermediate factor,new roots  #
      REAL          VERSION       ! Version # for internal changes #
      REAL          WFP           ! Water factor,photosynthesis    #
      REAL          WFRDG         ! Water factor,root depth growth #
      REAL          WFRG          ! Water factor,root growth 0-1   #

      IF (FNUMWRK.LE.0) CALL Getlun ('WORK.OUT',fnumwrk)

      RTWTGS = 0.0
      DO L = 1, NLAYR
        RTWTGL(L) = 0.0
        RTWTSL(L) = 0.0
        RTNSL(L) = 0.0
      ENDDO

      IF (ISTAGE.LT.6 .OR. ISTAGE.GE.8) THEN

        ! Establish root tip layer
        CUMDEP = 0.0
        L = 0
        DO WHILE ((RTDEP.GE.CUMDEP) .AND. (L.LT.NLAYR))
          L = L + 1
          CUMDEP = CUMDEP + DLAYR(L)
        END DO

        ! Establish water factor for root depth growth
        SWDF = AMIN1(1.0,AMAX1(0.1,
     &   (SW(L)-LL(L))/((DUL(L)-LL(L))*WFRG)))
        IF (VERSION.GE.4.05) THEN
          IF (L.EQ.1) THEN
            ! Water content of layer 2 used because
            ! elongation most likely at base of layer
            SWDF = AMIN1(1.0,AMAX1(0.1,
     &       (SW(2)-LL(2))/((DUL(2)-LL(2))*WFRG)))
          ENDIF
        ENDIF

        ! Root depth growth
        RTDEPG = 0.0
        IF (ISTAGE.LT.7) THEN
          IF (RTWTG.GT.0.0) THEN
            IF (CUMTT.LT.RDGTH) THEN
              RTDEPG = TT*RDGS1/STDDAY
     &        * SQRT(SHF(L)*AMIN1(WFP*WFRDG,SWDF))
              IF (VERSION.GE.7.01)
     &         RTDEPG = TT*RDGS1/STDDAY*SQRT(SHF(L))
            ELSE
              RTDEPG = TT*RDGS2/STDDAY
     &        * SQRT(SHF(L)*AMIN1(WFP*WFRDG,SWDF))
              IF (VERSION.GE.7.01)
     &         RTDEPG = TT*RDGS2/STDDAY*SQRT(SHF(L))
            ENDIF
          ELSE
            ! This is to handle planting on the surface and to
            ! allow root depth growth immediately after emergence
            IF (DAE.LT.20) RTDEPG = TT*RDGS1/STDDAY
          ENDIF
        ELSEIF (ISTAGE.GE.9) THEN      ! Germination to emergence
          RTDEPG = TT*RDGS1/STDDAY
        ENDIF

        L = 0
        CUMDEP = 0.0
        RTDEPTMP = RTDEP
        IF (VERSION.GE.4.03) RTDEPTMP = RTDEP+RTDEPG
        DO WHILE ((CUMDEP.LE.RTDEPTMP) .AND. (L.LT.NLAYR))
          L = L + 1
          CUMDEP = CUMDEP + DLAYR(L)
          ! NOTE the limit on SWDF. Should not have 0 SWDF, which when
          ! only one layer -> 0 TRLDF. Could prevent problems with
          ! IF statement (as is done), but this would result in dry
          ! matter assigned to roots simply 'disappearing'.
          SWDF = AMIN1(1.0,AMAX1(0.1,
     &     (SW(L)-LL(L))/((DUL(L)-LL(L))*WFRG)))
          RNFAC = 1.0
          IF (ISWNIT.EQ.'Y') THEN
            RNFAC = AMAX1(0.01,
     &              (1.0-(1.17*EXP(NFRG*(NO3LEFT(L)+NH4LEFT(L))))))
          ENDIF
          RLDF(L) = AMIN1(SWDF,RNFAC)*SHF(L)*DLAYR(L)
          RLDF(L) =       SWDF       *SHF(L)*DLAYR(L)
        END DO
        IF (L.GT.0) RLDF(L) = RLDF(L)*(1.0-(CUMDEP-RTDEP)/DLAYR(L))
        L1 = L

        RTDEPG = 0.0
        IF (ISTAGE.LT.7) THEN
          IF (RTWTG.GT.0.0) THEN
            IF (CUMTT.LT.RDGTH) THEN
              RTDEPG = TT*RDGS1/STDDAY
     &        * SQRT(SHF(L)*AMIN1(WFP*WFRDG,SWDF))
            ELSE
              RTDEPG = TT*RDGS2/STDDAY
     &        * SQRT(SHF(L)*AMIN1(WFP*WFRDG,SWDF))
            ENDIF
          ELSE
            ! This is to handle planting on the surface
            ! It allows root depth growth immediately after emergence
            ! In time, root growth should be limited by sd mobilisation
            ! AND this should have a moisture limit!
            IF (DAE.LT.20) RTDEPG = TT*RDGS1/STDDAY
          ENDIF
        ELSEIF (ISTAGE.GE.9) THEN      ! Germination to emergence
          RTDEPG = TT*RDGS1/STDDAY
        ENDIF

        RTWTS = 0.0
        DO L = 1, L1
          RTWTSL(L) = RTWTL(L)*RSEN    ! NB. No temp effect yet
          RTWTS = RTWTS + RTWTL(L)*RSEN
          RTNSL(L) = AMIN1(RTWTSL(L)*RMNC,RTWTSL(L)*RANC)
        ENDDO

        ! Root length to depth growth ratio (120) derived from Ceres3.5
        IF (RTWTG.LT.RLDGR*RTDEPG/((RLWR*1.0E4)*PLTPOP)) THEN
          RTWTGS = AMAX1(0.0,AMIN1(SDAFR*SEEDRSAV,
     &    (RLDGR*RTDEPG/((RLWR*1.0E4)*PLTPOP) - RTWTG)))
          IF (VERSION.GE.4.02) SEEDRSAV = SEEDRSAV - RTWTGS
        ENDIF
        TRLDF = 0.0
        DO  L = 1, L1
          TRLDF = TRLDF + RLDF(L)
        END DO
        IF (TRLDF.GT.0.0) THEN
          DO  L = 1, L1
            RTWTGL(L) = (RLDF(L)/TRLDF)*(RTWTG+RTWTGS)
          END DO
        ENDIF
      ENDIF

      RETURN

      END  ! CE_ROOTGR

!=======================================================================
!  CE_PHENOL Subroutine
!  Determines phenological stage; initializes new phase
!-----------------------------------------------------------------------
!  Revision history
!  1. Written
!  2. Header revision and minor changes           P.W.W.      2-7-93
!  3. Added switch block, code cleanup            P.W.W.      2-7-93
!  4. Modified TT calculations to reduce line #'s P.W.W.      2-7-93
!  5. Modified for MILLET model                   W.T.B.      MAY 94
!  6. Converted to modular format                 W.D.B       3-29-01
!  7. Further work on modular structure           L.A.H      12-08-02
!=======================================================================

      SUBROUTINE CE_PHENOL(ISWWAT,
     & DAYLT,SRAD,TT,
     & NLAYR,DLAYR,LL,DUL,SW,
     & P1D,P1DT,P1DPE,WFGEU,
     & PLTPOP,SDEPTH,CROP,ISTAGE,VF,LNUMSD,
     & df,du,geu)

      IMPLICIT  NONE
      SAVE

      CHARACTER*2   CROP          ! Crop identifier (ie. WH, BA)   text
      REAL          CUMDEP        ! Cumulative depth               cm
      REAL          DAYLT         ! Daylength (6deg below horizon) h
      REAL          DF            ! Daylength factor 0-1           #
      REAL          DLAYR(20)     ! Depth of soil layers           cm
      REAL          TT            ! Thermal time                   C
      REAL          DU            ! Developmental units            PVC.d
      REAL          DUL(20)       ! Drained upper limit for soil   #
      INTEGER       FNUMWRK       ! File number,work file          #
      REAL          GEU           ! Germination,emergence units    #
      INTEGER       ISTAGE        ! Developmental stage            #
      CHARACTER*1   ISWWAT        ! Soil water balance switch Y/N  code
      INTEGER       L             ! Loop counter                   #
      INTEGER       L0            ! Layer with seed                #
      REAL          LNUMSD       ! Leaf number,Haun stage         #
      REAL          LIF2          ! Light interception factor 2    #
      REAL          LL(20)        ! Lower limit,soil h2o           #
      INTEGER       NLAYR         ! Number of layers in soil       #
      REAL          P1D           ! Photoperiod sensitivity coeff. %/10h
      REAL          P1DA          ! Photoperiod coeff,age adjusted /h
      REAL          P1DAFAC       ! Photoperiod coeff,adjust fac   /lf
      REAL          P1DPE         ! Photoperiod factor,pre-emer,fr #
      REAL          P1DT          ! Photoperiod threshold          h
      REAL          PLTPOP        ! Plant Population               #/m2
      REAL          SDEPTH        ! Sowing depth                   cm
      REAL          SRAD          ! Solar radiation                MJ/m2
      REAL          SW(20)        ! Soil water content             #
      REAL          SWP(0:20)     ! Soil water 'potential'         #
      REAL          SWPSD         ! Soil water potential at seed   #
      REAL          VF            ! Vernalization factor 0-1       #
      REAL          WFGE          ! Water factor,germ,emergence    #
      REAL          WFGEU         ! Water factor,GE,upper limit    #

      IF (FNUMWRK.LE.0) CALL Getlun ('WORK.OUT',fnumwrk)

      ! Daylength factor.
      IF (ISTAGE.EQ.1) THEN
        IF (P1D.GE.0.0) THEN      ! Long day plants
          P1DAFAC = 0.00          ! Age adjustment factor
          P1DA = AMAX1(.0,(P1D/10000)-(P1D/10000)*P1DAFAC*(LNUMSD-5.))
          DF = AMAX1(0.0,AMIN1(1.0,1.0 - P1DA*(P1DT-DAYLT)**2))
        ELSE                      ! Short day plants
          DF = AMAX1(0.0,AMIN1(1.0,1.0-(ABS(P1D)/1000)*(DAYLT-P1DT)))
        ENDIF
      ELSEIF (ISTAGE.GT.1 .AND.ISTAGE.LT.7) THEN
        DF = 1.0
      ELSEIF (ISTAGE.GE.7) THEN
        DF = P1DPE
      ENDIF

      ! Light intensity factor
      LIF2 = 1.0
      IF (CROP.EQ.'BA' .AND. SRAD.LE.10.0) THEN
        LIF2 = 1.0 - ( 10.0-SRAD)**2/PLTPOP
      ENDIF

      ! Developmental units
      DU = TT*VF*DF*LIF2    ! NB. Changed from Ceres 3.5
      ! DU = TT*AMIN1(VF,DF)*LIF2    ! Ceres 3.5

      !chp Feb 13 2006 - Don't allow negative DU
      DU = AMAX1(0.0, DU)

      ! Water factor for germination
      IF (ISWWAT.EQ.'Y' .AND. ISTAGE.GT.7) THEN
        DO L = 1, NLAYR
          CUMDEP = CUMDEP + DLAYR(L)
         IF (SDEPTH.LT.CUMDEP) GO TO 100
        END DO
  100   CONTINUE
        L0 = L                       ! L0 is layer with seed
        DO L = 1,NLAYR
          SWP(L) = AMIN1(1.0,AMAX1(.0,((SW(L)-LL(L))/(DUL(L)-LL(L)))))
        ENDDO
        SWP(0) = AMIN1(1.0,AMAX1(0.0,(SWP(1)-(SWP(2)-SWP(1)))))
        IF (L0.GT.1) THEN
          SWPSD = SWP(L0)
        ELSE
          SWPSD = AMIN1(SWP(2),(SWP(0)+SDEPTH*(SWP(2)-SWP(0))))
        ENDIF
        WFGE = AMAX1(0.0,AMIN1(1.0,(SWPSD/WFGEU)))
      ELSE
        WFGE = 1.0
      ENDIF

      ! Germination units
      GEU = TT*WFGE

      RETURN

      END  ! CE_PHENOL

!=======================================================================
!  CE_GROSUB Subroutine
!  Cereals growth routine
!-----------------------------------------------------------------------
!  Revision history
!  1. Written
!  2. Header revision and minor changes           P.W.W.      2-7-93
!  3. Switch block added, etc                     P.W.W.      2-7-93
!  4. Updated PCARB calculation          J.T.R. & B.D.B. 21-Jun-1994
!  5. Converted to modular version                W.D.B.      3-29-01
!  6. Continued conversion to modular structure   L.A.H.      9-11-02
!  7. Declare PD(0:10) per LAH request            C.H.P.      9-16-04 

!=======================================================================

      SUBROUTINE CE_GROSUB (STDDAY,VERSION,
     & SRAD,PARAD,CO2,DU,
     & PD,G2,G3,PHINT,PHINTS,PHINTCHG,CO2RF,CO2FR,PARUV,PARUR,PTH,
     & LAWRS,LAWR2,LA1S,LAVS,LARS,LLIFE,LATFR,
     & PTFS,PTFA,STFR,LSHFR,LSENS,
     & P4SGE,RSFRS,PLASF,PTFX,RTREF,LAWFRMN,SDAFR,
     & TI1LF,TILDF,TFP,
     & CROP,PLTPOP,PARI,ISTAGE,XSTAGE,GRNUM,SSTAGE,LAGSTAGE,
     & TT,CUMDU,
     & WFP,WFG,NFP,NFG,LCNF,NFSM,
     & TFG,TFGF,
     & SEEDRSAV,LFWT,STWT,RSWT,RSC,GRWT,TNUM,
     & GPLA,LNUMSD,LNUMSG,LAP,LAPS,PLAG,PLA,SENLA,
     & tnumloss,pltloss,plagt,tnumg,tnumd,
     & plas,plass,lapot,
     & carbo,rtwtg,grolf,grost,rtresp,grors,grorspm,grogrst,
     & grogrpa,grorssd,carbolsd,ptf,ch2olim,tlimit,
     & co2fp,wfti,nfti,rsfp,wflf,nflf,aflf,
     & DYNAMICI)

      IMPLICIT  NONE
      SAVE

      INTEGER       LNUMX         ! Maximum number of leaves       #
      PARAMETER     (LNUMX = 25)  ! Maximum number of leaves

      REAL          AFLF(LNUMX)   ! CH2O factor for leaf,average   #
      REAL          AFLFSUM(LNUMX)! CH2O factor for leaf,sum       #
      REAL          CARBO         ! Carbohydrate available,phs+rs  g/p
      REAL          CARBOAPM      ! Carbohydrate available,>mature g/p
      REAL          CARBOAR       ! Carbohydrate available,roots   g/p
      REAL          CARBOASD      ! Carbohydrate available,seed    g/p
      REAL          CARBOAT       ! Carbohydrate available,tops    g/p
      REAL          CARBOLRS      ! CH2O used for leaves from rsvs g/pdd
      REAL          CARBOLSD      ! CH2O used for leaves from seed g/pdd
      INTEGER       CH2OLIM       ! Number of days CH2O limited gr #
      REAL          CO2           ! CO2 concentration in air       vpm
      REAL          CO2FP         ! CO2 factor,photosynthesis 0-1  #
      REAL          CO2FR(10)     ! CO2 factor,relative val 0-1    #
      REAL          CO2RF(10)     ! CO2 reference concentration    vpm
      CHARACTER*2   CROP          ! Crop identifier (ie. WH, BA)   text
      REAL          CUMDU         ! Total development units        C.d
      REAL          DU            ! Developmental units            PVC.d
      INTEGER       DYNAMICI      ! Module control,internal        code
      INTEGER       FNUMWRK       ! File number,work file          #
      REAL          G2            ! Cultivar coefficient,grain gr  mg/du
      REAL          G3            ! Cultivar coefficient,stem wt   g
      REAL          GPLA(10)      ! Green leaf area                cm2/p
      REAL          GPLASENF      ! Green leaf area,final sen strt #
      REAL          GPLASENS      ! Green leaf area,senesce stage  cm2/p
      REAL          GRNUM         ! Grains per plant               #/p
      REAL          GROGRP        ! Grain growth potential         g/p
      REAL          GROGRPA       ! Grain growth possible,assim    g/p
      REAL          GROGRST       ! Grain growth from stem ch2o    g/p
      REAL          GROLF         ! Leaf growth                    g/p
      REAL          GROLFP        ! Leaf growth,potential          g/p
      REAL          GRORS         ! Reserves growth                g/p
      REAL          GRORSP        ! Reserves growth,potential      g/p
      REAL          GRORSPM       ! Reserves growth,post-maturity  g/p
      REAL          GRORSSD       ! Reserves growth,seed           g/p
      REAL          GRORT         ! Root growth                    g/p
      REAL          GROST         ! Stem growth rate               g/p
      REAL          GROSTP        ! Stem growth,potential          g/p
      REAL          GRWT          ! Grain weight                   g/p
      INTEGER       ISTAGE        ! Developmental stage            #
      INTEGER       L             ! Loop counter                   #
      REAL          LA1FAC        ! Area of early leaves increment #
      REAL          LA1S          ! Area of leaf 1,standard        cm2
      REAL          LAVS          ! Area of vegetative leaves,std  cm2
      REAL          LARS          ! Area of reproductive lves,std  cm2
      REAL          LAGSTAGE      ! Lag phase,grain filling stage  #
      REAL          LAP(LNUMX)    ! Leaf area at leaf position     cm2/p
      REAL          LAPOT(LNUMX)  ! Leaf area potentials           cm2/l
      REAL          LAPOTNXT      ! Leaf area potential of next lf cm2/l
      REAL          LAPS(LNUMX)   ! Leaf senesced area at lf posn  cm2/p
      REAL          LASENLF       ! Leaf area of senescing leaf ch cm2/p
      REAL          LASWITCH      ! Leaf area at increment change  cm2/l
      REAL          LATFR(20)     ! Leaf area of tillers,fr main   #
      REAL          LAWFRMN       ! Leaf area/wt ratio,minimum     #
      REAL          LAWR          ! Area to weight ratio,lamina    cm2/g
      REAL          LAWR2         ! Leaf area/weight ratio,stage2  cm2/g
      REAL          LAWRS         ! Leaf area/wt ratio,standard    cm2/g
      REAL          LCNF          ! Leaf critical N fraction       #
      REAL          LFFRS         ! Leaf fraction,during phase     #
      INTEGER       LLIFE         ! Leaf longevity (phyllochrons)  #
      REAL          LFWT          ! Leaf weight                    g/p
      REAL          LIF1          ! Light interception factor 1    #
      INTEGER       LNSWITCH      ! Leaf # at increment change     #
      REAL          LNUMSD        ! Leaf number,Haun stage         #
      INTEGER       LNUMSG        ! Growing leaf number            #
      REAL          LSENS         ! Leaf senescence,start stage    #
      REAL          LSHFR         ! Leaf sheath fraction of total  #
      REAL          NFG           ! N factor,growth 0-1            #
      REAL          NFLF(LNUMX)   ! N factor for leaf,average      #
      REAL          NFLFSUM(LNUMX)! N factor for leaf,sum          #
      REAL          NFP           ! N factor,photosynthesis 0-1    #
      REAL          NFSM          ! N factor,sen,maturity trigger  #
      REAL          NFTI          ! N factor,tillering 0-1         #
      REAL          P4SGE         ! Stem growth end,X-stage        #
      REAL          PARAD         ! PAR                            MJ/m2
      REAL          PARI          ! PAR interception fraction      #
      REAL          PARUR         ! PAR utilization effic,reprod   g/MJ
      REAL          PARUV         ! PAR utilization effic,veg      g/MJ
      REAL          PCARB         ! Potential carbon fixation      g/p

           !chp 9/16/04 changed PD from (10) to (0:10) per LAH request
      REAL          PD(0:10)      ! Phase durations                deg.d
      REAL          PHINT         ! Phylochron interval            deg.d
      INTEGER       PHINTCHG      ! Phylochron interval,change lf# #
      REAL          PHINTS        ! Phylochron interval,standard   deg.d
      REAL          PLA           ! Plant leaf area                cm2
      REAL          PLAG(2)       ! Plant leaf area growth,tiller1 cm2/t
      REAL          PLAGT(2)      ! Plant leaf area growth         cm2/p
      REAL          PLAGTP(2)     ! Plant lf area growth,potential cm2/p
      REAL          PLAS          ! Leaf area senesced,normal      cm2/p
      REAL          PLASF(10)     ! Leaf area senesced fr,phase,st #
      REAL          PLASS         ! Leaf area senesced,stress      cm2/p
      REAL          PLASTMP       ! Leaf area senesced,temporary   cm2/p
      REAL          PLTLOSS       ! Plant popn lost through cold   #/m2
      REAL          PLTPOP        ! Plant Population               #/m2
      REAL          PTF           ! Partition fraction to tops     #
      REAL          PTFA(10)      ! Partition fr adjustment coeff. #
      REAL          PTFS(10)      ! Partition fraction by stage    #
      REAL          PTFSS         ! Partition fraction for stage   #
      REAL          PTFX          ! Partition fraction,maximum     #
      REAL          PTH(0:10)     ! Phase thresholds               du
      REAL          RSC           ! Reserves concentration         fr
      REAL          RSFP          ! Reserves factor,photosynthesis #
      REAL          RSFR          ! Reserves fraction              fr
      REAL          RSFRS         ! Reserves fraction,standard     #
      REAL          RSWT          ! Reserves weight                g/p
      REAL          RTREF         ! Root respiration fraction      #
      REAL          RTRESP        ! Root respiration               g/p
      REAL          RTSW          ! Tiller wt relative to standard #
      REAL          RTWTG         ! Root weight growth             g/p
      INTEGER       RUNINIT       ! Program control variable (= 1) #
      REAL          SDAFR         ! Seed availability fraction     /d
      INTEGER       SEASINIT      ! Program control variable (=2)  #
      REAL          SEEDRSAV      ! Seed reserves available        g/p
      REAL          SEEDRSUX      ! Seed reserves use maximum      g/pdd
      REAL          SENLA         ! Senesced leaf area,total       cm2/p
      REAL          SRAD          ! Solar radiation                MJ/m2
      REAL          SSTAGE        ! Secondary stage of development #
      REAL          STDDAY        ! Standard day                   C.d/d
      REAL          STFR(10)      ! Stem fraction,start phase      #
      REAL          STFRS         ! Stem fraction,during phase     #
      REAL          STWT          ! Stem weight                    g/p
      REAL          TFG           ! Temperature factor,leaf growth #
      REAL          TFGF          ! Temperature factor,grain fill  #
      REAL          TFP           ! Temperature factor,photosyn..  #
      REAL          TI1LF         ! Tiller 1 site (leaf #)         #
      REAL          TILDF         ! Tiller death rate,maximum fr   /d
      REAL          TILSW         ! Tiller standard weight         g/s
      REAL          TILWT         ! Tiller weight                  g/s
      INTEGER       TLIMIT        ! Number of days temp limited gr #
      REAL          TNUM          ! Tiller (incl.main stem) number #/p
      REAL          TNUMAFAC      ! Tiller # Aassimilates factor   #/p
      REAL          TNUMD         ! Tiller number death            #/p
      REAL          TNUMG         ! Tiller number growth           #/p
      REAL          TNUMIFF       ! Tiller number fibonacci factor #
      REAL          TNUMLOSS      ! Tillers lost through death     #/p
      INTEGER       TNUMOUT       ! Tiller # warning op counter    #
      REAL          TT            ! Thermal time                   C
      REAL          TTTMP         ! Thermal time,temporary value   C
      REAL          VERSION       ! Version number                 #
      REAL          WFG           ! Water factor,growth 0-1        #
      REAL          WFLF(LNUMX)   ! H2O factor for leaf,average    #
      REAL          WFLFNUM(LNUMX)! H2O factor for leaf,# in sum   #
      REAL          WFLFSUM(LNUMX)! H2O factor for leaf,sum        #
      REAL          WFP           ! Water factor,photosynthesis    #
      REAL          WFTI          ! Water factor,tillering 0-1     #
      REAL          XSTAGE        ! Stage of development           #
      REAL          XSTAGEFS      ! Xstage when final sen started  #
      REAL          XSTAGEP       ! Stage of development,previous  #
      REAL          YVALXY        ! Y value from function          #

      PARAMETER     (RUNINIT = 1)
      PARAMETER     (SEASINIT = 2)

      ! Leaf area potential increase factor
      LA1FAC = (LAVS-LA1S)/25.0
      IF (LA1FAC.LT.0.2) LA1FAC = 0.2

      IF (FNUMWRK.LE.0) CALL Getlun ('WORK.OUT',fnumwrk)

      IF (PLTPOP.EQ.0.0) RETURN

      IF (DYNAMICI.EQ.RUNINIT .OR. DYNAMICI.EQ.SEASINIT) THEN
        SEEDRSUX = 0.0
        LAGSTAGE = -99.0
        TNUMOUT = 0.0
        GPLASENS = -99.0
        DO L=1,LNUMX
          AFLFSUM(L) = 0.0
          WFLFSUM(L) = 0.0
          NFLFSUM(L) = 0.0
          WFLFNUM(L) = 0
          AFLF(L) = 0.0
          WFLF(L) = 0.0
          NFLF(L) = 0.0
        ENDDO
      ENDIF

      CARBO = 0.0
      GROST = 0.0
      GRORT = 0.0
      GROLF = 0.0
      GROLFP = 0.0
      GROGRP = 0.0
      GROGRPA = 0.0
      GROGRST = 0.0
      GRORS = 0.0
      GRORSSD = 0.0
      GRORSPM = 0.0
      GRORSP = 0.0
      GROST = 0.0
      GROSTP = 0.0
      PCARB = 0.0
      PLAS = 0.0
      PLASS = 0.0
      PLTLOSS = 0.0
      RSFR = 0.0
      RTRESP = 0.0
      RTWTG = 0.0
      TNUMD = 0.0
      TNUMG = 0.0
      TNUMLOSS = 0.0
      DO L = 1,2
        PLAG(L) = 0.0
        PLAGT(L) = 0.0
        PLAGTP(L) = 0.0
      ENDDO
      XSTAGEFS = 0.0

      ! 'Light intensity' factor (0.6,1.0 at SRAD's of 0,7)
      LIF1 = 1.0
      IF (CROP.EQ.'BA' .AND. SRAD.LE.10.0) THEN
        LIF1 = 1.0 - ((10.0-SRAD)**2*PLTPOP*0.000025)
      ENDIF

      ! CO2 factor
      CO2FP = YVALXY(CO2RF,CO2FR,CO2)

      ! Temperature factors
      ! Must check. One cold night --> no phs next day!!

      ! Tops partition fraction; standard first,then adjustment
      IF (PTFS(ISTAGE+1).GT.0)
     & PTFSS = PTFS(ISTAGE) + (PTFS(ISTAGE+1)-PTFS(ISTAGE))*SSTAGE
      IF (PTFA(ISTAGE).GT.0)
     & PTF = AMIN1(PTFX,PTFSS + PTFA(ISTAGE)*AMIN1(WFP,NFG,LIF1))

      ! Within tops distribution fractions
      LFFRS = 1.0
      STFRS = 0.0
      STFRS = (STFR(ISTAGE)
     &      + ((STFR(ISTAGE+1)-STFR(ISTAGE))*(XSTAGE-FLOAT(ISTAGE))))
      IF (ISTAGE.GE.3.AND.ISTAGE.LT.7) STFRS = 1.0
      IF (ISTAGE.GT.6) STFRS = 0.0
      LFFRS = 1.0 - STFRS
      IF (XSTAGE.GT.P4SGE) THEN
        RSFR = 1.0
      ELSE
        RSFR = RSFRS
      ENDIF

      ! CO2 Assimilation
      PCARB = PARUV * PARAD/PLTPOP * PARI
      IF (XSTAGE.GE.3.0) PCARB = PARUR * PARAD/PLTPOP * PARI

      ! PCARB = 7.5 * PARAD**0.6/PLTPOP*(1.0-EXP(-0.85*LAI)) ! Ceres 3.0
      ! Y1 = 1.5 - 0.768 * ((ROWSPC * 0.01)**2 * PLTPOP)**0.1
      ! PCARB = 1.48 * SRAD/PLTPOP * (1.0 - EXP(-Y1 * LAI)) ! Maize
      ! Following is as in Ceres 3.5. Now eliminated minimum choice
      ! CARBO = AMAX1(0.0,PCARB*CO2FP*TFP*AMIN1(WFP,NFP)*RSFP)

      CARBO = AMAX1(0.0,PCARB*CO2FP*TFP*WFP*NFP*RSFP)
      ! Following is to stop assim once mature
      IF (XSTAGE.GT.6.0) CARBO = AMAX1(0.0,CARBO*(6.3-XSTAGE)/0.3)

      ! Available carbohydrate for growth
      IF (ISTAGE.EQ.6) THEN
        CARBOAT = 0.0
        CARBOAR = 0.0
        CARBOASD = 0.0
        CARBOAPM = CARBO
      ELSE
        CARBOASD = SDAFR/STDDAY*TT*SEEDRSAV
        IF (VERSION.GE.4.04) THEN
          CARBOASD = 0.0
          CARBOAT = CARBO*PTF
        ENDIF
        IF (VERSION.GE.4.02) SEEDRSAV = SEEDRSAV - CARBOASD
        CARBOAT = CARBOASD+CARBO*PTF
        CARBOAR = CARBO*(1.0-PTF)
        CARBOAPM = 0.0
      ENDIF

      ! Potential leaf sizes
      IF (XSTAGE.GE.1.6.AND.XSTAGE.LT.7.0) THEN
        IF(LNUMSG.GT.0 .AND. LNSWITCH.LE.0.0) THEN
          LNSWITCH = LNUMSG
          WRITE(fnumwrk,*)
     &     'Leaf number when size increment changed ',lnswitch
          LASWITCH =
     &     AMIN1(LARS,LA1S*(1.0+(FLOAT(LNUMSG-1))*LA1FAC))
          WRITE(fnumwrk,*)
     &     'Leaf size when size increment changed ',laswitch
        ENDIF
      ELSE
        LNSWITCH = -99
      ENDIF
      IF (LNUMSG.GT.0) THEN
        IF (LNSWITCH.GT.-99.AND.LNUMSG.GT.LNSWITCH) THEN
          LAPOT(LNUMSG) =
     &     LASWITCH + (LNUMSG-LNSWITCH)*((LARS-LASWITCH)/6.0)
          LAPOTNXT =
     &     LASWITCH + (1.0+LNUMSG-LNSWITCH)*((LARS-LASWITCH)/6.0)
        ELSE
          LAPOT(LNUMSG) =
     &     AMIN1(LARS,LA1S*(1.0+(FLOAT(LNUMSG-1))*LA1FAC))
          LAPOTNXT = AMIN1(LARS,LA1S*(1.0+FLOAT(LNUMSG)*LA1FAC))
        ENDIF
      ENDIF

      ! Growth potentials
      IF (ISTAGE.LE.2) THEN
        LAWR = AMAX1(LAWRS-
     &       ((LAWRS-LAWR2)*AMAX1(0.0,(XSTAGE-1.0))),LAWR2)
     &       * AMAX1(LAWFRMN,WFG*NFG)

        ! NB. Ceres 3.5 used: PLAG(1) = LA1S * (LNUMSD**0.5) * ....
        !     LA1S = 7.5
        !     EGFT = 1.2 - 0.0042*(TEMPM-17.0)**2
        IF (LNUMSG.GT.0) THEN
          ! NB. Temperature factor introduced .. not purely TT control
          ! Assimilates generally control expansion if no reserve use
          PLAG(1) = LAPOT(LNUMSG) * AMIN1(WFG,NFG) * TFG *
     &     AMIN1(TT/PHINT,(FLOAT(LNUMSG)-LNUMSD))
          IF ((TT/PHINT).GT.(FLOAT(LNUMSG)-LNUMSD)) THEN
            IF (LNUMSG.EQ.PHINTCHG) THEN
              TTTMP = TT - PHINT*(FLOAT(LNUMSG)-LNUMSD)
              PLAG(2) = LAPOTNXT * AMIN1(WFG,NFG) * TFG *
     &         TTTMP/PHINTS
            ELSE
              PLAG(2) = LAPOTNXT * AMIN1(WFG,NFG) * TFG *
     &         (TT/PHINT-(FLOAT(LNUMSG)-LNUMSD))
            ENDIF
          ELSE
            PLAG(2) = 0.0
          ENDIF
          IF (TT.GT.0.0) THEN
            WFLFNUM(LNUMSG) = WFLFNUM(LNUMSG)+1.0
            WFLFSUM(LNUMSG) = WFLFSUM(LNUMSG)+WFG
            NFLFSUM(LNUMSG) = NFLFSUM(LNUMSG)+NFG
            WFLF(LNUMSG) = WFLFSUM(LNUMSG)/WFLFNUM(LNUMSG)
            NFLF(LNUMSG) = NFLFSUM(LNUMSG)/WFLFNUM(LNUMSG)
          ENDIF
          PLAGTP(1) = PLAG(1)
          PLAGTP(2) = PLAG(2)
          DO L = 1,INT(TNUM)
            IF (L.LT.20) THEN
              PLAGTP(1) = PLAGTP(1) + PLAG(1)*LATFR(L+1)
     &                              * AMAX1(0.0,AMIN1(1.0,(TNUM-1.0)))
              PLAGTP(2) = PLAGTP(2) + PLAG(2)*LATFR(L+1)
     &                              * AMAX1(0.0,AMIN1(1.0,(TNUM-1.0)))
            ELSE
              TNUMOUT = TNUMOUT + 1
              IF (TNUMOUT.LT.2)
     &         WRITE(fnumwrk,*)'Tiller number at limit of 20! '
            ENDIF
          ENDDO
        ENDIF
      ENDIF
      IF (LAWR.GT.0.0) GROLFP = ((PLAGTP(1)+PLAGTP(2))/LAWR)/(1.0-LSHFR)
      GROSTP = CARBOAT*(1.0-RSFR)
      IF (LFFRS.GT.0.0) GROSTP = GROLFP*(STFRS/LFFRS)
      GRORSP = CARBOAT*RSFR

      IF (ISTAGE.EQ.4.OR.ISTAGE.EQ.5) THEN
        GROGRP = AMAX1(0.0,LAGSTAGE*TFGF*GRNUM*G2*DU*0.001)
       !write(fnumwrk,*)' grogrp ',LAGSTAGE,TFGF,GRNUM,G2,DU
        IF (LAGSTAGE.GT.0.0.AND.TFGF.LT.1.0) THEN
          WRITE(fnumwrk,'(A44,F6.2)')
     &     ' Temperature limit on grain growth at xstage',xstage
          TLIMIT = TLIMIT+1
        ENDIF
      ENDIF

      ! Actual growth
      GRORT = CARBOAR
      GROLF = AMIN1(GROLFP,CARBOAT*LFFRS)
      CARBOLSD = 0.0
      IF (VERSION.GE.4.04) THEN
        IF (GROLFP.GT.0.0) THEN
          IF (SEEDRSUX.LE.0.0) SEEDRSUX = SEEDRSAV/(4.0*PHINT)
          IF (GROLFP.GT.0.0.AND.GROLF.LT.GROLFP) THEN
            CARBOLSD = AMIN1((GROLFP-GROLF),SEEDRSAV,SEEDRSUX*TT)
            SEEDRSAV = SEEDRSAV - CARBOLSD
            GROLF = GROLF + CARBOLSD
          ENDIF
        ENDIF
      ENDIF
      CARBOLRS = 0.0
      IF (VERSION.GE.9.12) THEN
        IF (GROLFP.GT.0.0.AND.GROLF.LT.GROLFP) THEN
          CARBOLRS = AMIN1((GROLFP-GROLF),0.1*RSWT)
          GROLF = GROLF + CARBOLRS
        ENDIF
      ENDIF
      IF (LNUMSG.GT.0.AND.GROLFP.GT.0.0) THEN
        AFLFSUM(LNUMSG) =
     &   AFLFSUM(LNUMSG)+AMIN1(1.0,(((CARBOAT*LFFRS)+CARBOLSD)/GROLFP))
      ENDIF
      IF (LNUMSG.GT.0.AND.WFLFNUM(LNUMSG).GT.0.0)
     & AFLF(LNUMSG) = AFLFSUM(LNUMSG)/WFLFNUM(LNUMSG)

      GROST = AMIN1(GROSTP,CARBOAT*STFRS*(1.0-RSFR))

      IF (GROGRP.GT.GRORSP+RSWT) THEN
        GROGRST = 0.0
        IF (GROST.GT.0.0) THEN
          GROGRST = AMIN1(GROST,GROGRP-(GRORSP+RSWT))
          IF (GROGRST.GT.0.0) THEN
            WRITE(fnumwrk,*)'CH2O destined for stem used for grain'
          ENDIF
        ENDIF
        IF (GROGRP.GT.GRORSP+RSWT+GROGRST) THEN
          WRITE(fnumwrk,*)'CH2O limit on grain growth.'
          CH2OLIM = CH2OLIM+1
          WRITE(fnumwrk,'(A15,F6.2,A5,F6.3,A10)') ' CH2O shortage:',
     &     (GROGRP-(GRORSP+RSWT+GROGRST)),' g/p ',
     &     (GROGRP-(GRORSP+RSWT+GROGRST))/GRNUM,' g/kernel '
        ENDIF
      ENDIF
      GROGRPA = AMIN1(GROGRP,GRORSP+RSWT+GROGRST)
       !write(fnumwrk,*)' grogrpa ',grogrp,grogrp,rswt,grogrst

      GRORSSD = -(CARBOASD-AMAX1(.0,CARBOASD-GROLF-GROST-GROGRPA))
      GRORS = AMAX1(-RSWT,
     & (CARBOAT-CARBOASD-GRORSSD)-GROLF-GROST-GROGRPA)
      GRORSPM = CARBOAPM

      IF (PLAGTP(1)+PLAGTP(2).GT.0.0) THEN
        PLAGT(1) = GROLF*(1.0-LSHFR)*LAWR*
     &   (PLAGTP(1)/(PLAGTP(1)+PLAGTP(2)))
        PLAGT(2) = GROLF*(1.0-LSHFR)*LAWR*
     &   (PLAGTP(2)/(PLAGTP(1)+PLAGTP(2)))
      ENDIF
      DO L = 1,2
        IF(PLAGTP(1)+PLAGTP(2).GT.0.0) THEN
          PLAG(L) = PLAG(L)*(PLAGT(1)+PLAGT(2))/(PLAGTP(1)+PLAGTP(2))
        ENDIF
      ENDDO

      ! Growth adjusted for respiration
      RTWTG = GRORT * (1.0-RTREF)

      ! Leaf senescence
      IF (LNUMSG.GT.0.AND.LNUMSG.GT.LLIFE) THEN
        PLASTMP = AMAX1(0.0,LAP(LNUMSG-LLIFE)*TT/PHINT)
        ! Senescence cannot be greater than area remaining for
        ! senescing leaf. May have been killed by cold,etc..
        LASENLF = AMAX1(0.0,LAP(LNUMSG-LLIFE)-LAPS(LNUMSG-LLIFE))
        PLASTMP = AMIN1(LASENLF,PLASTMP)
      ELSE
        PLASTMP = 0.0
      ENDIF

      PLAS = 0.0
      IF (ISTAGE.EQ.1) THEN
        PLAS = PLASTMP
      ELSEIF (ISTAGE.EQ.2) THEN
        PLAS = AMIN1(PLASTMP,PLASF(ISTAGE)*GPLA(ISTAGE-1)*DU/PD(ISTAGE))
      ELSEIF (ISTAGE.EQ.3.OR.ISTAGE.EQ.4.OR.ISTAGE.EQ.5) THEN
        ! Determine if N shortage senescence triggered
        IF (XSTAGE.GT.5.0. AND. LCNF.LT.NFSM) THEN
          XSTAGEFS = XSTAGE
          GPLASENF = AMAX1(0.0,PLA-SENLA)
        ENDIF
        ! Calculate leaf area senesced
        IF (XSTAGE.GT.5.0.AND.XSTAGEFS.GT.0.0.AND.XSTAGE.LT.LSENS) THEN
          PLAS = GPLASENF*(XSTAGE-XSTAGEFS)/(6.3-XSTAGEFS)
        ELSE
          IF (XSTAGE.GT.LSENS) THEN
            IF (GPLASENS.LT.0.0) GPLASENS = AMAX1(0.0,PLA-SENLA)
            PLAS = GPLASENS*(XSTAGE-LSENS)/(6.3-LSENS)
          ELSE
            PLAS = PLASF(ISTAGE) * GPLA(ISTAGE-1)*DU/PD(ISTAGE)
          ENDIF
        ENDIF
      ELSEIF (ISTAGE.EQ.6) THEN
        PLAS = GPLA(ISTAGE-1)*TT/20.0*0.1
      ENDIF

      ! Increased senescence if reserves fall too low
      ! NB. 3% of green leaf area senesces ... must check
      IF (RSC.LT.0.10 .AND. ISTAGE.GE.4. AND. PLA.GT.0.0) THEN
        PLAS = PLAS + AMAX1(0.0,0.03*(PLA-PLAS-SENLA))
        WRITE(fnumwrk,*)'Senescence accelerated because low reserves'
      ENDIF

      ! Overall check to restrict senescence to what available
      PLAS = AMAX1(0.0,AMIN1(PLAS,PLA-SENLA))

      ! Tillering
      IF (GROLFP+GROSTP.GT.0.0) THEN
        TNUMAFAC = AMIN1(1.0,(GROLF+GROST)/(GROLFP+GROSTP))
        IF (VERSION.GT.4.07) THEN
          TNUMAFAC = AMAX1(0.0,
     &     (1.0-(1.0-((GROLF+GROST)/(GROLFP+GROSTP)))/(1.0-0.8)))
           IF (RSC.LT.0.1) TNUMAFAC = 0.0
        ENDIF
      ELSE
        TNUMAFAC = 0.0
      ENDIF
      IF (LNUMSD.GE.TI1LF) THEN
        IF (XSTAGE.LT.2.0) THEN
        !IF (XSTAGE.LE.2.4) THEN
          IF (LNUMSD.LT.ti1lf+3) THEN    ! Fibonacci factors
            tnumiff=1.0
          ELSEIF(LNUMSD.GE.ti1lf+3 .AND. LNUMSD.LT.ti1lf+4) THEN
            tnumiff=1.5
          ELSEIF(LNUMSD.GE.ti1lf+4 .AND. LNUMSD.LT.ti1lf+5) THEN
            tnumiff=3.0
          ELSEIF(LNUMSD.GE.ti1lf+5 .AND. LNUMSD.LT.ti1lf+6) THEN
            tnumiff=4.0
          ELSEIF(LNUMSD.GE.ti1lf+6 .AND. LNUMSD.LT.ti1lf+7) THEN
            tnumiff=6.0
          ENDIF
          !TNUMG = TT/PHINT * TNUMIFF * AMIN1(WFTI,NFTI,LIF1)
          TNUMG = TT/PHINT * TNUMIFF * WFTI*NFTI*LIF1
          IF (LNUMSD.GT.TI1LF+3) TNUMG = TNUMG * TNUMAFAC
        ENDIF
      ELSE
        TNUMG = 0.0
      ENDIF

      ! Tiller death
      RTSW = 1.0
      TILWT = 0.0
      TILSW = G3 * CUMDU/PTH(5)
      IF (TNUM.GT.0.0) TILWT = (LFWT+STWT+RSWT+GRWT)/TNUM
      IF (TILSW.GT.0.0) RTSW = TILWT/TILSW
      !  (XSTAGE.GT.2.4 .AND. XSTAGE.LT.5.8)  ! From CSCERES
      IF (XSTAGE.GE.2.0 .AND. XSTAGE.LT.4.0)
     & TNUMD = AMAX1(0.0,(TNUM-1.0)*(1.0-RTSW)*TT*(TILDF/20.0))

      ! Root respiration
      RTRESP = GRORT * RTREF

      XSTAGEP = XSTAGE

      RETURN

      END  ! CE_GROSUB

!=======================================================================
!  CE_COLD Subroutine
!  Calculates vernalization status and cold losses
!-----------------------------------------------------------------------
!  Revision history
!  1. Written                                     W.T. Bowen  SEPT 1991
!  2. Header revision and minor changes           P.W.W.         2-7-93
!  3. Added AMIN1 and AMAX1 to code               P.W.W.         2-7-93
!  4. Modularised                                 L.A.H.       12-09-02
!=======================================================================

      SUBROUTINE CE_COLD (
     & DOY,TMIN,TMAX,
     & ISTAGE,PLTPOP,PLTPOPP,TNUM,PLA,SENLA,
     & TKILL,CUMVD,HARDI,
     & cflfail,hardilos,vdlost,tnumloss,pltloss,plasc)

      IMPLICIT  NONE
      SAVE

      CHARACTER*1   CFLFAIL       ! Control flag for failure       text
      REAL          CKCOLD        ! Cold temp factor,leaf death    #
      REAL          CUMVD         ! Cumulative vernalization days  d
      INTEGER       DOY           ! Day of year                    #
      INTEGER       FNUMWRK       ! File number,work file          #
      LOGICAL       FOPEN         ! File open indicator            code
      REAL          HARDI         ! Hardening index                #
      REAL          HARDILOS      ! Hardening index loss           #
      INTEGER       ISTAGE        ! Developmental stage            #
      REAL          PLA           ! Plant leaf area                cm2
      REAL          PLASC         ! Leaf area senesced,cold        cm2
      REAL          PLTLOSS       ! Plant popn lost through cold   #/m2
      REAL          PLTPOP        ! Plant Population               #/m2
      REAL          PLTPOPP       ! Plant Population planned       #/m2
      REAL          SENLA         ! Senescent leaf area,total      cm2/p
      REAL          TKILL         ! Temperature for plant death    C
      REAL          TNUM          ! Tiller (incl.main stem) number #/p
      REAL          TNUMLOSS      ! Tillers lost through death     #/p
      REAL          TMAX          ! Temperature maximum            C
      REAL          TMIN          ! Temperature minimum            C
      REAL          VDLOST        ! Vernalization lost (de-vern)   d


      IF (FNUMWRK.LE.0.OR.FNUMWRK.GT.1000) THEN
        CALL Getlun ('WORK.OUT',fnumwrk)
        INQUIRE (FILE = 'WORK.OUT',OPENED = fopen)
        IF (.NOT.fopen) OPEN (UNIT = fnumwrk,FILE = 'WORK.OUT')
      ENDIF

      ! Devernalization
      VDLOST = 0.0
      IF (CUMVD.LT.10.0 .AND. TMAX.GT.30.0) THEN
        VDLOST = 0.5*(TMAX-30.0)
      ENDIF

      ! Loss of cold hardiness
      IF (ISTAGE.GE.9 .OR. ISTAGE.LT.7) THEN
        IF (ISTAGE.GE.2) THEN
          HARDILOS = AMAX1(0.0,(TMAX-10.0)*0.1)
        ELSE
          HARDILOS = AMAX1(0.0,(TMAX-10.0)*0.01)
        ENDIF
      ENDIF

      IF (ISTAGE.LE.7.0) THEN
        TNUMLOSS = 0.0
        PLTLOSS = 0.0
        CKCOLD = 0.0
 500    IF (TMIN.LE.-6.0) THEN
          ! Leaf senescence
          IF ((TMIN+TMAX)/2.0.LT.-10.0) THEN
            CKCOLD = ABS((TMIN+TMAX)/2.0-(-10.0))*0.20
          ENDIF
          ! Following is original (as CK)
          ! CKCOLD = AMAX1(0.00,AMIN1(0.96,
          !    (0.020*HARDI-0.10)*(TMIN*0.85+TMAX*0.15+10.0+0.25*SNOW)))
          PLASC = AMAX1(0.0,
     &            AMIN1(CKCOLD*(PLA-SENLA),((PLA-SENLA)-TNUM*0.035)))

          ! Tiller and plant death
          IF (TKILL.GT.(TMIN+TMAX)/2.0) THEN
            IF (TNUM.GE.1.0) THEN
              TNUMLOSS=TNUM *
     &         (1.0-(0.9-0.02*ABS(((TMIN+TMAX)/2.0-TKILL))**2))
            ENDIF
            IF (TNUM-TNUMLOSS.GE.1.0) THEN
              WRITE (FNUMWRK,900)
     &         DOY,TKILL,(TMIN+TMAX)/2.0,HARDI,TNUM,PLTPOP
 900          FORMAT (' Crop was damaged by cold on day',I4,/,
     &          ' TKILL =',F5.1,5X,'TMEAN=',F5.1,5X,
     &          'HARDI=',F5.2,5X,'TNUM =',  F7.2,5X,'PLTPOP=',F4.0)
            ELSE
              PLTLOSS =
     &         PLTPOP*(1.0-(0.95-0.02*((TMIN+TMAX)/2.0-TKILL)**2))
               IF (ISTAGE.GE.4) PLTLOSS = 0.0
              IF (PLTPOP-PLTLOSS.GE.0.05*PLTPOPP) THEN
                WRITE (FNUMWRK,900) DOY,TKILL,
     &           (TMIN+TMAX)/2.0,HARDI,TNUM,PLTPOP
              ELSE
                CFLFAIL = 'Y'
                PLTLOSS = AMIN1(PLTPOP,PLTLOSS)
                IF (ISTAGE.GE.4) PLTLOSS = 0.0
                WRITE (FNUMWRK,1100) DOY,TKILL,(TMIN+TMAX)/2.0,HARDI
 1100           FORMAT (' At least 95% killed by cold on day',I4,/,
     &          ' TKILL =',F5.1,5X,'TMEAN =',F5.1,5X,
     &          'HARDII =',F5.2)
              ENDIF
            ENDIF
          ENDIF
        ENDIF
      ENDIF

      RETURN

      END  ! CE_COLD

!=======================================================================
!  CE_NUPTAK Subroutine
!  Determines N uptake
!-----------------------------------------------------------------------
!  Revision history
!  1. Written
!  2  Modified by
!  3. Header revision and minor changes               P.W.W.      2-8-93
!  4  Modified by                                     W.T.B.     JUNE 94
!  5. Changed water content dependent factor J.T.R. & B.D.B. 28-Jun-1994
!  6. Converted to modular format                     W.D.B      3-29-01
!  7. Continue modularisation                         L.A.H     11-09-02
!=======================================================================

      SUBROUTINE CE_NUPTAK (ISWNIT,DU,
     & SW,NO3LEFT,NH4LEFT,LL,DUL,SAT,DLAYR,BD,NLAYR,SHF,FAC,
     & NO3MN,NH4MN,RLFNU,NUMAX,NTUPF,WFNUL,WFNUU,
     & XSTAGE,LAGSTAGE,PLTPOP,RTWT,RLV,LFWT,STWT,
     & GRNUM,G2,GRNS,GRNMX,TFGN,
     & SEEDN,RSN,RCNC,RANC,RMNC,LCNC,LANC,LMNC,SCNC,SANC,SMNC,XNFS,
     & RTWTG,RTWTGS,RTWTS,NUSELIM,
     & GROLF,SENLFG,SENLFGRS,GROST,SENSTG,GROGRPA,
     & dleafn,dstemn,drootn,
     & grainng,grainngr,grainngl,grainngs,
     & seednr,seednt,rsnuser,rsnuset,rsnuseg,
     & uno3alg,unh4alg,nupd,nupr)

      IMPLICIT  NONE
      SAVE

      REAL          ANDEM         ! Crop N demand                  kg/ha
      REAL          BD(20)        ! Bulk density (moist)           g/cm3
      REAL          DLAYR(20)     ! Depth of soil layers           cm
      REAL          DTOPN         ! Change in tops N               g/p
      REAL          DROOTN        ! Change in root N               g/p
      REAL          DROOTNA       ! Daily adjustment in root N gr  g/p
      REAL          DSTEMN        ! Change in stem N               g/p
      REAL          DSTOVN        ! Change in stover N             g/p
      REAL          DLEAFN        ! Change in leaf N               g/p
      REAL          DU            ! Developmental units            PVC.d
      REAL          DUL(20)       ! Drained upper limit for soil   #
      REAL          FAC(20)       ! Factor ((mg/Mg)/(kg/ha))       #
      REAL          FNH4          ! Unitless ammonium supply index #
      REAL          FNO3          ! Unitless nitrate supply index  #
      INTEGER       FNUMWRK       ! File number,work file          #
      LOGICAL       FOPEN         ! File open indicator            code
      REAL          G2            ! Cultivar coefficient,grain gr  mg/du
      REAL          GRNUM         ! Grains per plant               #/p
      REAL          GRAINNG       ! Grain N growth,uptake          g/p
      REAL          GRAINNGR      ! Grain N growth from roots      g/p
      REAL          GRAINNGL      ! Grain N growth from leaves     g/p
      REAL          GRAINNGS      ! Grain N growth from stems      g/p
      REAL          GRAINNGV      ! Grain N growth from veg parts  g/p
      REAL          GRNS          ! Grain N standard concentration %
      REAL          GRNMX         ! Grain N,maximum concentration  %
      REAL          GROGRPA       ! Grain growth,possible,assim    g/p
      REAL          GROLF         ! Leaf growth rate               g/p
      REAL          GROST         ! Stem growth rate               g/p
      CHARACTER*1   ISWNIT        ! Soil nitrogen balance switch   code
      INTEGER       L             ! Loop counter                   #
      INTEGER       L1            ! Loop counters                  #
      REAL          LAGSTAGE      ! Lag phase,grain filling stage  #
      REAL          LANC          ! Leaf N concentration           #
      REAL          LCNC          ! Leaf critical N conc           #
      REAL          LFWT          ! Leaf weight                    g/p
      REAL          LMNC          ! Leaf minimum N conc            #
      REAL          LNDEM         ! Leaf demand for N              g/p
      REAL          LL(20)        ! Lower limit,soil h2o           #
      REAL          NDEMS         ! Plant nitrogen demand,soil     g/p
      REAL          NUPR          ! N uptake ratio to demand       #
      REAL          NH4LEFT(20)   ! NH4 concentration in soil      mg/Mg
      REAL          NH4MN         ! NH4 conc minimum for uptake    mg/Mg
      INTEGER       NLAYR         ! Number of layers in soil       #
      REAL          NO3LEFT(20)   ! NO3 concentration in soil      mg/Mg
      REAL          NO3MN         ! NO3 conc minimum for uptake    mg/Mg
      REAL          NPOOLV        ! Vegetative N available for gr  g/p
      REAL          NPOOLR        ! Root N available for grain     g/p
      REAL          NPOOLL        ! Leaf N available for grain     g/p
      REAL          NPOOLST       ! Stem N available for grain     g/p
      REAL          NSINK         ! N demand for grain filling     g/p
      REAL          NSINKADJ      ! N demand for gr,after rs use   g/p
      REAL          NUAG          ! Total root N uptake            kg/ha
      REAL          NUAP          ! Total root N uptake,potential  kg/ha
      REAL          NUF           ! Plant N supply/demand ratio    ft
      REAL          NUFACM        ! N uptake factor,maturation,0-1 #
      REAL          NUMAX         ! N uptake rate,maximum fractio  /d
      REAL          NUPD          ! Total root N uptake            g/p
      REAL          NUSELIM       ! N limit on N for grain filling #
      REAL          NUSEFAC       ! N use factor (mx nuselim,xnfs) #
      REAL          PLTPOP        ! Plant Population               #/m2
      REAL          RANC          ! Roots actual N concentration   #
      REAL          RCNC          ! Root critical N                #
      REAL          RSN           ! Reserve N                      g/p
      REAL          RSNV          ! Reserve N for vegetative gr    g/p
      REAL          RFAC          ! Root length density fac,uptake #
      REAL          RLFNU         ! Root length factor,N uptake    #
      REAL          RLV(20)       ! Root length volume by layer    #
      REAL          RMNC          ! Root minimum N conc            g/g
      REAL          RNDEM         ! Root demand for N              g/p
      REAL          RNDEMS        ! Root demand for N,soil         g/p
      REAL          RNDEM1        ! Root demand for N,overall      g/p
      REAL          RNH4U(20)     ! Potential ammonium uptake      kg/ha
      REAL          RNO3U(20)     ! Potential nitrate uptake       kg/ha
      REAL          RSNUSEG       ! Reserves N use for grain       g/p
      REAL          RSNUSER       ! Reserves N use for root growth g/p
      REAL          RSNUSET       ! Reserves N use for top growth  g/p
      REAL          RTWT          ! Root weight                    g/p
      REAL          RTWTG         ! Root weight growth             g/p
      REAL          RTWTGS        ! Root weight growth from seed   g/p
      REAL          RTWTS         ! Root weight senesced           g/p
      REAL          SANC          ! Stem N concentration           #
      REAL          SAT(20)       ! Saturated limit,soil           #
      REAL          SCNC          ! Stem critical N conc           #
      REAL          SEEDN         ! Seed N                         g/p
      REAL          SEEDNT        ! Seed N used by tops            g/p
      REAL          SEEDNTA       ! Seed N used by tops,additional g/p
      REAL          SEEDNTB       ! Seed N used by tops,basic      g/p
      REAL          SEEDNR        ! Seed N used by roots           g/p
      REAL          SEEDNRA       ! Seed N used by roots,additionl g/p
      REAL          SEEDNRB       ! Seed N used by roots,basic     g/p
      REAL          SENLFG        ! Senesced leaf                  g/p
      REAL          SENLFGRS      ! Senesced leaf to reserves      g/p
      REAL          SENSTG        ! Senesced material from stems   g/p
      REAL          SHF(20)       ! Soil hospitality factor 0-1    #
      REAL          SMDFR         ! Soil moisture factor,N uptake  #
      REAL          SMNC          ! Stem minimum N conc            #
      REAL          SNH4(20)      ! Soil NH4 N                     kg/ha
      REAL          SNO3(20)      ! Soil NO3 N                     kg/ha
      REAL          SNDEM         ! Stem demand for N              g/p
      REAL          STWT          ! Stem weight                    g/p
      REAL          SW(20)        ! Soil water content             #
      REAL          TFGN          ! Temperature factor,grain N 0-1 #
      REAL          TNDEM         ! Plant tops demand for N        g/p
      REAL          TNDEMS        ! Plant tops demand for N,soil   g/p
      REAL          NTUPF         ! N top-up fraction              /d
      REAL          TRLV          ! Total root length density      cm-2
      REAL          TVR1          ! Temporary real variable        #
      REAL          UNH4ALG(20)   ! Uptake of NH4 N                kg/ha
      REAL          UNO3ALG(20)   ! Uptake of NO3 N                kg/ha
      REAL          WFNL          ! Water content,N uptake,lower   #
      REAL          WFNU          ! Water content,N uptake,upper   #
      REAL          WFNUL         ! Water factor,N uptake,lower    #
      REAL          WFNUU         ! Water factor,N uptake,upper    #
      REAL          XMIN          ! Minimum NO3,NH4-N for uptake   mg/Mg
      REAL          XNFS          ! N labile fraction,standard     #
      REAL          XSTAGE        ! Stage of development           #


      IF (ISWNIT.EQ.'Y') THEN

        IF (FNUMWRK.LE.0.OR.FNUMWRK.GT.1000) THEN
          CALL Getlun ('WORK.OUT',fnumwrk)
          INQUIRE (FILE = 'WORK.OUT',OPENED = fopen)
          IF (.NOT.fopen) OPEN (UNIT = fnumwrk,FILE = 'WORK.OUT')
        ENDIF

        DTOPN = 0.0
        DROOTN = 0.0
        DSTEMN = 0.0
        DLEAFN = 0.0
        DSTOVN = 0.0
        GRAINNG = 0.0
        NUPD = 0.0
        NUAG = 0.0
        NUAP = 0.0
        NUF = 0.0
        SEEDNR = 0.0
        SEEDNRA = 0.0
        SEEDNRB = 0.0
        SEEDNT = 0.0
        SEEDNTA = 0.0
        SEEDNTB = 0.0
        RSNUSET = 0.0
        RSNUSER = 0.0
        RSNV = 0.0
        ANDEM = 0.0
        NDEMS = 0.0
        RNDEM = 0.0
        RNDEMS = 0.0
        RNDEM1 = 0.0
        TNDEM = 0.0
        TNDEMS = 0.0
        TRLV = 0.0
        DROOTNA = 0.0
        GRAINNGR = 0.0
        GRAINNGV = 0.0
        NPOOLL = 0.0
        NPOOLST = 0.0
        NPOOLV = 0.0


        DO L = 1, NLAYR
          UNO3ALG(L) = 0.0
          UNH4ALG(L) = 0.0
          RNO3U(L) = 0.0
          RNH4U(L) = 0.0
          TRLV = TRLV + RLV(L)
          FAC(L) = 10.0/(BD(L)*DLAYR(L))
          SNO3(L) = NO3LEFT(L) / FAC(L)
          SNH4(L) = NH4LEFT(L) / FAC(L)
        END DO

        ! Grain N uptake.
        NSINK = 0.0
        IF (GRNUM.GT.0.0 .AND. XSTAGE.LT.6.0) THEN
          NSINK = AMIN1(GROGRPA*(GRNMX/100.0),
     &     LAGSTAGE*TFGN*GRNUM*G2*DU*.001*(GRNS/100.))
        ENDIF

        ! N uptake factor after maturity
        IF (XSTAGE.GT.6.0 .AND. XSTAGE.LT.7.0) THEN
          NUFACM = AMAX1(0.0,1.0 - (XSTAGE-6.0)/(6.5-6.0))
        ELSE
          NUFACM = 1.0
        ENDIF
        LNDEM = NUFACM *
     &          ((LFWT-SENLFG-SENLFGRS)*AMAX1(0.0,NTUPF*(LCNC-LANC))
     &          + GROLF*LCNC)
        SNDEM = NUFACM *
     &          ((STWT-SENSTG)*AMAX1(0.0,NTUPF*(SCNC-SANC))
     &          + AMAX1(0.0,GROST)*SCNC)

        RNDEM = NUFACM *
     &          ((RTWT-RTWTS) * AMAX1(0.0,NTUPF*(RCNC-RANC))
     &          + (RTWTG+RTWTGS) * RCNC)


        ! Reserve N use
        RSNUSEG = 0.0
        RSNUSET = 0.0
        RSNUSER = 0.0
        IF (NSINK.GT.0.0) RSNUSEG = AMAX1(0.0,AMIN1(NSINK,RSN))
        NSINKADJ = NSINK - RSNUSEG
        RSNV = RSN - RSNUSEG
        IF (LNDEM+SNDEM+RNDEM.GT.0.0 .AND. RSNV.GT.0.0) THEN
          IF (LNDEM+SNDEM+RNDEM.LT.RSNV) THEN
            RSNUSET = LNDEM + SNDEM
            RSNUSER = RNDEM
            TNDEM = 0.0
            RNDEM = 0.0
          ELSE
            RSNUSET = RSNV * (LNDEM+SNDEM)/(LNDEM+SNDEM+RNDEM)
            RSNUSER = RSNV * RNDEM/(LNDEM+SNDEM+RNDEM)
            TNDEM = (LNDEM+SNDEM) - RSNUSET
            RNDEM = RNDEM - RSNUSER
          ENDIF
          IF (RSNUSET.LT.1E-20) RSNUSET = 0.0
          IF (RSNUSER.LT.1E-20) RSNUSER = 0.0
        ELSE
          TNDEM = LNDEM + SNDEM
          RNDEM = RNDEM
        ENDIF

        ! Seed N use (basic)
        SEEDNTB = 0.0
        SEEDNRB = 0.0
        IF (XSTAGE.LT.4 .OR. XSTAGE.GT.6) THEN
          IF (SEEDN.GT.1.0E-6) THEN
            SEEDNTB = AMIN1(TNDEM,SEEDN*0.20)
            SEEDNRB = AMIN1(RNDEM,SEEDN*0.20-SEEDNTB)
          ENDIF
        ENDIF

        TNDEMS = TNDEM - SEEDNTB
        RNDEMS = RNDEM - SEEDNRB
        NDEMS = TNDEMS + RNDEMS

        ANDEM = NDEMS * PLTPOP*10.0
        ! Potential N supply in soil layers with roots (NUAP)
        DO L = 1, NLAYR
          IF (RLV(L).NE.0.0) THEN
            L1 = L
            RNH4U(L) = 0.0
            RNO3U(L) = 0.0

            ! Original SMDFR =
            !  1.5-6.0*((SW(L)-LL(L))/(SAT(L)-LL(L))-0.5)**2
            ! Original SMDFR = AMAX1 (SMDFR,0.0)
            ! Original SMDFR = AMIN1 (SMDFR,1.0)
            ! Original RFAC = 1.0-EXP(-8.0*RLV(L))
            ! Original FNH4 = SHF(L)*0.075
            ! Original FNO3 = SHF(L)*0.075
            ! Amax1 added LAH Aug 2002. Was going negative!
            ! Origin RNH4U(L) =
            !  SMDFR*RFAC*FNH4*AMAX1(0.0,(NH4LEFT(L)-0.5))*DLAYR(L)
            ! Original RNO3U(L) = SMDFR*RFAC*FNO3*NO3(L)*DLAYR(L)

            WFNU = LL(L)+(DUL(L)-LL(L))*WFNUU
            WFNL = LL(L)+(DUL(L)-LL(L))*WFNUL
            ! Dry soil effect
            IF (SW(L).LE.WFNUL) THEN
              SMDFR = 0.0
            ELSEIF (SW(L).GT.WFNUU.AND.SW(L).LE.WFNUU) THEN
              SMDFR = AMAX1(0.0,AMIN1(1.0,(SW(L)-WFNL)/(WFNU-WFNL)))
            ELSE
              SMDFR = 1.0
            ENDIF
            ! Wet soil effect .. Not implemented because of problem when
            ! irrigated at time of planting or emergence
            IF (SW(L).GT.DUL(L)) THEN
              SMDFR = AMAX1(0.,AMIN1(1.,(SW(L)-DUL(L))/(SAT(L)-DUL(L))))
              SMDFR = 1.0
            ENDIF
            RFAC = 1.0 - EXP(-RLFNU*RLV(L))
            FNH4 = 1.0
            FNO3 = 1.0
            RNH4U(L) = SMDFR*RFAC*FNH4*SHF(L)*
     &       AMAX1(0.0,(NH4LEFT(L)-NH4MN))/FAC(L)*NUMAX
            RNO3U(L) = SMDFR*RFAC*FNO3*SHF(L)*
     &       AMAX1(0.0,(NO3LEFT(L)-NO3MN))/FAC(L)*NUMAX
            NUAP = NUAP + RNO3U(L) + RNH4U(L)
          ENDIF
        END DO

        ! Ratio (NUPR) to indicate N supply for output
        IF (ANDEM.GT.0) THEN
          NUPR = NUAP/ANDEM
        ELSE
          NUPR = 10.0
        ENDIF
        ! Factor (NUF) to reduce N uptake to level of demand
        IF (NUAP.GT.0.0) NUF = AMIN1(1.0,ANDEM/NUAP)

        ! Actual N uptake by layer roots based on demand (kg/ha)
        DO L = 1, L1
          UNO3ALG(L) = RNO3U(L)*NUF
          UNH4ALG(L) = RNH4U(L)*NUF
          XMIN = NO3MN/FAC(L)
          ! Original XMIN = 0.25/FAC(L)
          UNO3ALG(L) = MAX(0.0,MIN (UNO3ALG(L),SNO3(L) - XMIN))
          ! Original XMIN = 0.5/FAC(L)
          XMIN = NH4MN/FAC(L)
          UNH4ALG(L) = MAX(0.0,MIN (UNH4ALG(L),SNH4(L) - XMIN))
          NUAG = NUAG + UNO3ALG(L) + UNH4ALG(L)
        END DO

        NUPD = NUAG/(PLTPOP*10.0)

        ! Change in above and below ground N
        IF (NDEMS.LE.0.0 .OR. NUPD.LE.0.0) THEN
          DTOPN = 0.0 + RSNUSET
          DROOTN = 0.0 + RSNUSER
        ELSE
          DTOPN = TNDEMS / NDEMS*NUPD + RSNUSET
          DROOTN = RNDEMS / NDEMS*NUPD + RSNUSER
        ENDIF

        ! Make sure that roots do not fall below minimum
        IF ((RTWTG+RTWTGS)*RMNC.GT.DROOTN) THEN
          DROOTNA = AMIN1(DTOPN,((RTWTG+RTWTGS)*RMNC)-DROOTN)
          DROOTN = DROOTN + DROOTNA
          DTOPN = DTOPN - DROOTNA
        ENDIF

        ! Use N allotted to tops and roots for grain if in grain fill
        IF (NSINKADJ.GT.0.0) THEN
          IF (NSINKADJ.GE.DTOPN+DROOTN) THEN
            GRAINNG = DTOPN + DROOTN
            DSTOVN = 0.0
            DROOTN = 0.0
          ELSE
            GRAINNG = NSINKADJ
            TVR1 = DTOPN+DROOTN-NSINKADJ
            IF (TNDEM+RNDEM > 1.E-6) THEN
            DSTOVN = TNDEM/(TNDEM+RNDEM) * TVR1
            DROOTN = RNDEM/(TNDEM+RNDEM) * TVR1
            ELSE
              DSTOVN = 0.0
              DROOTN = 0.0
            ENDIF
          ENDIF
        ELSE
          DSTOVN = DTOPN
        ENDIF

        ! Use additional seed if not sufficient so far
        IF (XSTAGE.LT.4 .OR. XSTAGE.GT.6) THEN
          SEEDNTA = AMAX1(.0,AMIN1(SEEDN-SEEDNTB-SEEDNRB,TNDEMS-DSTOVN))
          SEEDNRA = AMAX1 (0.0,
     &     AMIN1(SEEDN-SEEDNTB-SEEDNTA-SEEDNRB,RNDEMS-DROOTN))
          SEEDNT = SEEDNTB + SEEDNTA
          SEEDNR = SEEDNRB + SEEDNRA
        ENDIF

        ! Move N to grain from roots and tops if necessary
        IF (NSINKADJ.GT.0.0 .AND. NSINKADJ.GT.GRAINNG) THEN
          NPOOLR = AMAX1 (0.0,XNFS*(RTWT*(RANC-RMNC)))
          IF (NPOOLR.GT.NSINKADJ-GRAINNG) THEN
            GRAINNGR = NSINKADJ-GRAINNG
          ELSE
            GRAINNGR = NPOOLR
          ENDIF
          IF (NSINKADJ.GT.GRAINNG+GRAINNGR) THEN
            NUSEFAC = AMAX1(NUSELIM,XNFS)
            NPOOLL = AMAX1 (0.0,
     &       NUSEFAC*((LFWT-SENLFG-SENLFGRS)*(LANC-LMNC)))
            NPOOLST = AMAX1 (0.0,
     &       NUSEFAC*((STWT-SENSTG)*(SANC-SMNC)))
            NPOOLV = NPOOLL + NPOOLST
            IF (NPOOLV.GT.NSINKADJ-(GRAINNG+GRAINNGR)) THEN
              GRAINNGV = NSINKADJ-GRAINNG-GRAINNGR
            ELSE
              GRAINNGV = NPOOLV
            ENDIF
          ENDIF
        ENDIF

        ! Split tops aspects into leaf and stem aspects
        IF (LNDEM+SNDEM.GT.0.0) THEN
          DLEAFN = DSTOVN * LNDEM / (LNDEM+SNDEM)
          DSTEMN = DSTOVN * SNDEM / (LNDEM+SNDEM)
        ELSE
          DLEAFN = 0.0
          DSTEMN = 0.0
        ENDIF
        IF (NPOOLL+NPOOLST.GT.0.0) THEN
          GRAINNGL = GRAINNGV * NPOOLL / (NPOOLL+NPOOLST)
          GRAINNGS = GRAINNGV * NPOOLST / (NPOOLL+NPOOLST)
        ELSE
          GRAINNGL = 0.0
          GRAINNGS = 0.0
        ENDIF

      ENDIF

      RETURN

      END  ! CE_NUPTAK

!=======================================================================
!  CSTRANS Subroutine
!  Calculates potential plant evaporation (ie.transpiration) rate
!-----------------------------------------------------------------------
!  Revision history
!  01/01/89 JR  Written
!  01/01/89 JWJ Modified for climate change using ETRATIO subroutine.
!  12/05/93 NBP Made into subroutine and changed to TRATIO function.
!  10/13/97 CHP Modified for modular format.
!  11/25/97 CHP Put in file TRANS.FOR w/ TRATIO and BLRRES
!  09/01/99 GH  Incorporated into CROPGRO
!  01/13/00 NBP Added DYNAMIC contruct to input KCAN
!  04/09/01 LAH Modified for CROPGRO-SIM
!=======================================================================

      SUBROUTINE CSTRANS(ISWWAT,                          !Control
     & TMAX, TMIN, WINDSP, CO2, EO,                       !Weather
     & CROP, LAI, KEP,                                    !Crop,LAI
     & eop,                                               !Pot.pl.evap
     & DYNAMICI)                                          !Control

      IMPLICIT NONE
      SAVE

      REAL          BLRESD        ! Boundary layer resistance      s/m
      REAL          BLRESE1       ! Boundary layer resistance      s/m
      REAL          BLRESE2       ! Boundary layer resistance      s/m
      REAL          BLRESE3       ! Boundary layer resistance      s/m
      REAL          BLRESE4       ! Boundary layer resistance      s/m
      REAL          BLRESE5       ! Boundary layer resistance      s/m
      REAL          BLRESE6       ! Boundary layer resistance      s/m
      REAL          BLRESEN       ! Boundary layer resistance      s/m
      REAL          BLRESRC1      ! Boundary layer resistance      s/m
      REAL          BLRESRC2      ! Boundary layer resistance      s/m
      REAL          BLRESRS1      ! Boundary layer resistance      s/m
      REAL          BLRESRS2      ! Boundary layer resistance      s/m
      REAL          BLRESX        ! Boundary layer resistance      s/m
      REAL          BLRESZ0       ! Boundary layer resistance      s/m
      REAL          BLRESZ1       ! Boundary layer resistance      s/m
      REAL          CHIGHT        ! Reference height for crop      m
      REAL          CO2           ! CO2 concentration in air       vpm
      CHARACTER*2   CROP          ! Crop identifier (ie. WH, BA)   text
      REAL          DELTA         ! Slope,sat vapor pres/tem curve Pa/K
      INTEGER       DYNAMICI      ! Module control,internal        code
      REAL          EO            ! Potential evapotranspiration   mm/d
      REAL          EOP           ! Potential evaporation,plants   mm/d
      REAL          GAMMA         ! Variable in Penman formula     #
      CHARACTER*1   ISWWAT        ! Soil water balance switch Y/N  code
      REAL          KEP           ! Extinction coeff for SRAD      #
      REAL          LAI           ! Leaf area index                #
      REAL          LAIMAX        ! Leaf area index,maximum        #
      REAL          LHV           ! Latent heat of vaporization    J/g
      REAL          RA            ! Atmospheric resistance         s/m
      REAL          RATIO         ! Ratio of LAI to maximum LAI    #
      REAL          RB            ! Leaf resistance addition fac   s/m
      REAL          RL            ! Canopy resistance for CO2      s/m
      REAL          RLC           ! Canopy resistance,actual CO2   s/m
      REAL          RLF           ! Leaf stomatal res,330.0 ppmCO2 s/m
      REAL          RLFC          ! Leaf stomatal resistance       s/m
      INTEGER       RUNINIT       ! Control variable,initiation    #
      REAL          TMAX          ! Temperature maximum            C
      REAL          TMIN          ! Temperature minimum            C
      REAL          TRATIO        ! Function,relative tr rate      #
      REAL          UAVG          ! Average wind speed             m/s
      REAL          VPSLOP        ! Slope,sat vapor pres/tem curve Pa/K
      REAL          WINDSP        ! Wind speed                     km/d
      REAL          XDEN          ! Transpiration,actual CO2       g/m2
      REAL          XNUM          ! Transpiration,standaard CO2    g/m2

      PARAMETER     (RUNINIT=1)

      EOP = 0.0
      DYNAMICI = DYNAMICI    ! Temporary until used for initialisation

      IF(ISWWAT.EQ.'Y')THEN
        IF (LAI .LT. 0.01) THEN
          TRATIO = 1.0
          GO TO 9999    ! Don't calculate tratio if LAI very small
        ENDIF

        ! Initialize.
        IF (WINDSP .LE. 0.0) WINDSP = 86.4
        UAVG = WINDSP / 86.4
        RB = 10.0
        LAIMAX = 3.5

        ! Set canopy height
        CHIGHT = 1.0

        ! Canopy resistances, RL and RLC.
        ! RLF = Leaf stomatal resistance at 330.0 ppm CO2, s/m
        ! RLFC = Leaf stomatal resistance at other CO2 conc., s/m
        ! (Allen, 1986), Plant responses to rising CO2.
        IF (INDEX('MZMLSG',CROP) .GT. 0) THEN
           ! C-4 Crops  EQ 7 from Allen (1986) for corn.
          RLF =(1.0/(0.0328 - 5.49E-5*330.0 + 2.96E-8 * 330.0**2))+RB
          RLFC=(1.0/(0.0328 - 5.49E-5* CO2  + 2.96E-8 * CO2  **2))+RB
        ELSE
          ! C-3 Crops
          RLF  = 9.72 + 0.0757 * 330.0 + 10.0
          RLFC = 9.72 + 0.0757 *  CO2  + 10.0
        ENDIF

        RL = RLF / LAI
        RLC = RLFC / LAI

        ! Boundary layer resistance (Jagtap and Jones, 1990).
        BLRESEN = 3.0
        BLRESZ1 = 0.01
        BLRESX = 2.0
        BLRESD = 0.7 * CHIGHT**0.979
        BLRESZ0 = 0.13 * CHIGHT**0.997

        BLRESE1 = EXP(BLRESEN*(1. - (BLRESD + BLRESZ0) / CHIGHT))
        BLRESE2 = EXP(BLRESEN)
        BLRESE3 = CHIGHT/(BLRESEN*(CHIGHT-BLRESD))
        BLRESE4 = ALOG((BLRESX - BLRESD)/BLRESZ0)
        BLRESE5 = 0.4 * 0.4 * UAVG
        BLRESE6 = ALOG((BLRESX - BLRESD) / (CHIGHT - BLRESD))

        BLRESRS2 = BLRESE4 * BLRESE3 * (BLRESE2 - BLRESE1)/BLRESE5
        BLRESRC2 = BLRESE4*(BLRESE6+BLRESE3*(BLRESE1-1.))/BLRESE5
        BLRESRS1 = ALOG(BLRESX/BLRESZ1)*
     &             ALOG((BLRESD+BLRESZ0)/BLRESZ1)/BLRESE5
        BLRESRC1 = (ALOG(BLRESX/BLRESZ1)**2)/BLRESE5
        BLRESRC1 = BLRESRC1-BLRESRS1

        RATIO = LAI/LAIMAX
        IF (RATIO .GT. 1.0) RATIO = 1.0
        RA = BLRESRC1 + (BLRESRC2 - BLRESRC1) * RATIO

        ! Transpiration ratio (CO2=330 vpm gives 1.0)
        DELTA = VPSLOP((TMAX+TMIN)/2.0) / 100.0
        LHV    = 2500.9 - 2.345*(TMAX+TMIN)/2.0
        GAMMA  = 1013.0*1.005/(LHV*0.622)
        XNUM = DELTA + GAMMA*(1.0+RL/RA)
        XDEN = DELTA + GAMMA*(1.0+RLC/RA)
        TRATIO = XNUM / XDEN

 9999   CONTINUE

        EOP = EO * (1.0-EXP(-LAI*KEP)) * TRATIO
        EOP = MAX(EOP,0.0)

      ENDIF

      RETURN

      END  ! CSTRANS

!=======================================================================
!  CSROOTWU Subroutine
!  Root water uptake rate for each soil layer and total rate.
!-----------------------------------------------------------------------
!  Revision history
!  01/01/89 JR  Written
!  12/05/93 NBP Made into subroutine.
!  01/18/96 JWJ Added flooding effect on water uptake
!  01/06/96 GH  Added soil water excess stress
!  10/10/97 CHP Updated for modular format.
!  09/01/99 GH  Incorporated in CROPGRO
!  01/10/00 NBP Added SAVE for stored variables and set SWCON2=RWU=0.0
!  01/12/00 NBP Removed FILECC from input
!  01/25/00 NBP Added IOSTAT to READ statements to set ERRNUM.  Cleaned.
!  05/09/01 LAH Modified for CROPSIM
!=======================================================================

      SUBROUTINE CSROOTWU(ISWWAT, VERSION,                 !Control
     & NLAYR, DLAYR, LL, SAT, WFSAG,                       !Soil
     & EOP,                                                !Pot.evap.
     & RLV, PORMIN, RWUMX, RTDEP,                          !Crop state
     & SW,                                                 !Soil h2o
     & UH2O, TRWUP,                                        !H2o uptake
     & DYNAMICI)                                           !Control

      IMPLICIT NONE
      SAVE

      INTEGER       NL            ! Maximum number soil layers,20
      PARAMETER     (NL=20)       !

      REAL          BLAYER        ! Depth at base of layer         cm
      INTEGER       DYNAMICI      ! Module control,internal        code
      REAL          DLAYR(20)     ! Depth of soil layers           cm
      REAL          DLAYRTMP(20)  ! Depth of soil layers with root cm
      REAL          EOP           ! Potential evaporation,plants   mm/d
      INTEGER       FNUMWRK       ! File number,work file          #
      CHARACTER*1   ISWWAT        ! Soil water balance switch Y/N  code
      INTEGER       L             ! Loop counter                   #
      REAL          LL(NL)        ! Lower limit,soil h2o           #
      INTEGER       NLAYR         ! Actual number of soil layers   #
      REAL          PORMIN        ! Pore space threshold,pl effect #
      REAL          RLV(20)       ! Root length volume by layer    #
      REAL          RLVTMP(20)    ! Root length volume by layer    #
      REAL          RLVSUM        ! Temporary RLV sum              #
      REAL          RTDEP         ! Root depth                     cm
      INTEGER       RUNINIT       ! Control variable,initiation    #
      REAL          RWU(20)       ! Root water uptake by layer     mm/d
      REAL          RWUMX         ! Root water uptake,maximum      mm2/m
      REAL          RWUP          ! Root water uptake,potential    cm/d
      REAL          SAT(20)       ! Saturated limit,soil           #
      REAL          SATFACL       ! Soil water excess stress factr #
      REAL          SW(20)        ! Soil water content             #
      REAL          SWAFOLD       ! Soil water availability CERES  #
      REAL          SWCON1        ! Constant for root water uptake #
      REAL          SWCON2(NL)    ! Variable for root water uptake #
      REAL          SWCON3        ! Constant for root water uptake #
      REAL          TRWUP         ! Total water uptake,potential   mm
      REAL          TSS(NL)       ! Number of days saturated       d
      REAL          UH2O(NL)      ! Uptake of water                cm/d
      REAL          VERSION       ! Version number                 #
      REAL          WFSAT         ! Soil water excess stress fact  #
      REAL          WFSAG         ! Soil water excess,genotype sen #
      REAL          WUF           ! Water uptake factor            #
      REAL          WUP(NL)       ! Water uptake                   cm/d
      REAL          WUT           ! Water uptake,total             cm/d

      PARAMETER     (RUNINIT=1)


      IF (ISWWAT.NE.'Y') RETURN

      IF (DYNAMICI.EQ.RUNINIT) THEN

        CALL Getlun('WORK.OUT',fnumwrk)

        ! Compute SWCON2 for each soil layer.  Adjust SWCON2 for very
        ! high LL to avoid water uptake limitations.
        SATFACL = 1.0
        DO L = 1,NL
          SWCON2(L) = 0.0
          RWUP = 0.0
          RWU(L) = 0.0
        ENDDO
        DO L = 1,NLAYR
          SWCON2(L) = 120. - 250. * LL(L)
          IF (LL(L) .GT. 0.30) SWCON2(L) = 45.0
        ENDDO

        ! Set SWCON1 and SWCON3.
        SWCON1 = 1.32E-3
        SWCON3 = 7.01

      ENDIF

      TRWUP   = 0.0
      RLVSUM = 0.0
      BLAYER = 0.0

      DO L = 1,NLAYR
        DLAYRTMP(L) = DLAYR(L)
        RLVTMP(L) = RLV(L)
        BLAYER = BLAYER + DLAYR(L)
        IF (VERSION.GE.4.06) THEN
          IF (RTDEP.GT.0.0.AND.RTDEP.LT.BLAYER) THEN
            DLAYRTMP(L) = RTDEP-(BLAYER-DLAYR(L))
            IF (DLAYRTMP(L).LE.0.0) EXIT
            RLVTMP(L) = RLV(L)*DLAYR(L)/DLAYRTMP(L)
          ENDIF
        ENDIF
      ENDDO

      DO L = 1,NLAYR
        IF (RLVTMP(L).LE.0.00001 .OR. SW(L).LE.LL(L)) THEN
          RWUP = 0.
        ELSE
          RWUP = SWCON1*EXP(MIN((SWCON2(L)*(SW(L)-LL(L))),40.))/
     &    (SWCON3-ALOG(RLVTMP(L)))
          ! Excess water effect
          ! PORMIN = Minimum pore space required for supplying oxygen
          ! TSS(L) = number of days soil layer L has been saturated
          IF ((SAT(L)-SW(L)) .GE. PORMIN) THEN
            TSS(L) = 0.
          ELSE
            TSS(L) = TSS(L) + 1.
          ENDIF
          ! 2 days after saturation before water uptake is affected
          IF (TSS(L).GT.2.0 .AND. PORMIN.GT.0.0) THEN
             SATFACL = MIN(1.0,MAX(0.0,(SAT(L)-SW(L))/PORMIN))
             IF (WFSAG.GT.0.0) THEN
               WRITE(fnumwrk,'(A52,I3)')
     &         ' WARNING  Water uptake resticted by saturation,layer',L
               WRITE(fnumwrk,'(A26,F4.2,A19,F4.2)')
     &         ' Uptake saturation factor ',satfacl,
     &         '  Uptake weighting ',wfsag
             ENDIF
          ELSE
             SATFACL = 1.0
          ENDIF
          WFSAT = 1.0 - (1.0-SATFACL)*WFSAG
          RWUP = MIN(RWUP,RWUMX*WFSAT)
          RWUP = MIN(RWUP,RWUMX)
        ENDIF
        IF (RLVTMP(L).GT.0.0) THEN
          SWAFOLD = AMIN1(1.0,AMAX1(0.0,(RWUP*RLVTMP(L))/(SW(L)-LL(L))))
          WUP(L) = SWAFOLD*DLAYRTMP(L)*(SW(L)-LL(L))
          TRWUP = TRWUP+WUP(L)
        ELSE
          WUP(L) = 0.0
        ENDIF
      ENDDO

      IF (TRWUP .GT. 0.0) THEN
        IF (EOP*0.1 .GE. TRWUP) THEN
          WUF = 1.0
        ELSE
          WUF = (EOP*0.1) / TRWUP
        ENDIF
        WUT = 0.0
        DO L = 1, NLAYR
          UH2O(L) = WUP(L) * WUF
          WUT = WUT + UH2O(L)
        END DO
      ELSE        !No root extraction of soil water
        WUT = 0.0
        DO L = 1,NLAYR
          UH2O(L) = 0.0
        ENDDO
      ENDIF

      RETURN

      END  ! CSROOTWU

!=======================================================================

      SUBROUTINE CSOUTPUT (FILEIO, FILEIOT, RUN, TN, RN, RNMODE,
     & CUDIRFLE, ECDIRFLE, SPDIRFLE, IDETG, IDETO, IDETL, IDETOU,
     & ISWWAT, ISWNIT, RUNI, SN, ON, REP, STEP, CN,
     & MODEL, MODULE, MODE, OUTHED, FROP, VERSION, VERSIOND,
     & EXCODE, RUNNAME, VARNO,
     & SRADC, TMAXX, TMAXM, TMINN, TMINM, RAINC, RAINCA, CO2MAX,
     & AMTNIT,
     & ADAT, STGDOY, YEARPLT, YEARSIM, DRDAT, TSDAT, JDAT,
     & SDRATE, SDNAP,
!CHP 2/4/2005     & GWAM, GWUM, HNUMAM, HPC, HBPC,
     & GWAM, PWAM, GWUM, HNUMAM, HPC, HBPC,
     & HIAM, LAIX, LNUMSM, TNUMAM,
     & CARBOAC,SENWATC,
     & CWAM,
     & VWAM, CWAA,
     & CNAM, VNAM,
     & SENNATC,
     & GNAM,
     & RWAM, RNAM,
     & RSWAM,
     & HINM, GNPCM, VNPCM,
     & VNAA, LNPCA,
     & NUAD,
     & STNAME,CWADSTG,CNADSTG,LAISTG,LNUMSTG,NFPAV,WFPAV,
     & ENAME,TNAME,CR,VRNAME,PLTPOP,ROWSPC,EMDATM)

      IMPLICIT NONE
      SAVE

      INTEGER       A1DATM        ! Apex 1cm date,measured         #
      INTEGER       ADAP          ! Anthesis,days after planting   d
      INTEGER       ADAPM         ! Anthesis,DAP,measured          d
      INTEGER       ADAT          ! Anthesis date (Year+doy)       #
      INTEGER       ADATEAA       ! Anthesis date abs error avg    #
      INTEGER       ADATEAV       ! Anthesis date average error    #
      INTEGER       ADATERR       ! Anthesis date error            d
      INTEGER       ADATM         ! Anthesis date,measured         #
      INTEGER       ADATNUM       ! Anthesis date error #          #
      INTEGER       ADATSUA       ! Anthesis date abs error #      #
      INTEGER       ADATSUM       ! Anthesis date error sum        #
      REAL          ADATT         ! Anthesis date from t file      YrDoy
      INTEGER       ADAY          ! Anthesis day of year           d
      INTEGER       ADAYH         ! Anthesis harvest d>anthesis    d
      INTEGER       ADAYM         ! Anthesis day of year,measured  d
      REAL          AMTNIT        ! Cumulative amount of N applied kg/ha
      REAL          AMTNITP       ! Cumulative N,previous treatmnt kg/ha
      INTEGER       AYEAR         ! Anthesis year                  #
      INTEGER       AYEARM        ! Anthesis year,measured         #
      INTEGER       BLANKS        ! Number of blan lines read      #
      REAL          CARBOAC       ! Carbohydrate assimilated,cum   kg/ha
      REAL          CARBOACM      ! Carbohydrate assimilated,cum,m kg/ha
      CHARACTER*1   CFLHEAD       ! Control flag to write headers  code
      CHARACTER*1   CFLTFILE      ! Control flag for T-file        code
      INTEGER       CN            ! Crop component (multicrop)     #
      REAL          CNAAM         ! Canopy N,anthesis,measured     kg/ha
      REAL          CNADSTG(20)   ! Canopy nitrogen,specific stage kg/ha
      REAL          CNAM          ! Canopy N at maturity           kg/ha
      REAL          CNAMEAA       ! Canopy N/area abs error avg    #
      REAL          CNAMEAV       ! Canopy N/area average error    #
      REAL          CNAMERR       ! Canopy N,maturity,error        %
      REAL          CNAMM         ! Canopy N,mature,measured       kg/ha
      INTEGER       CNAMNUM       ! Canopy N/area error #          #
      REAL          CNAMSUA       ! Canopy N/area abs error #      #
      REAL          CNAMSUM       ! Canopy N/area error sum        #
      CHARACTER*10  CNCHAR        ! Crop component (multicrop)     text
      CHARACTER*2   CNCHAR2       ! Crop component (multicrop)     text
      REAL          CNCTMP        ! Canopy N concentration,temp    %
      REAL          CO2ADJ        ! CO2 adjustment                 vpm
      REAL          CO2MAX        ! CO2 maximum during cycle       vpm
      INTEGER       COLNUM        ! Column number                  #
      CHARACTER*2   CR            ! Crop identifier (ie. WH, BA)   text
      INTEGER       CSTIMDIF      ! Time difference function       #
      INTEGER       CSYDOY        ! Yr+Doy output from function    #
      CHARACTER*93  CUDIRFLE      ! Cultivar directory+file        text
      REAL          CWAAM         ! Canopy wt,anthesis,measured    kg/ha
      REAL          CWADSTG(20)   ! Canopy weight,particular stage kg/ha
      REAL          CWADT         ! Canopy weight from t file      kg/ha
      REAL          CWAM          ! Canopy weight at maturity      kg/ha
      REAL          CWAMEAA       ! Canopy wt/area abs error avg   #
      REAL          CWAMEAV       ! Canopy wt/area average error   #
      REAL          CWAMERR       ! Canopy weight,maturity,error   %
      REAL          CWAMM         ! Canopy wt,mature,measured      kg/ha
      INTEGER       CWAMNUM       ! Canopy wt/area error #         #
      REAL          CWAMSUA       ! Canopy wt/area abs error #     #
      REAL          CWAMSUM       ! Canopy wt/area error sum       #
      INTEGER       DAP           ! Days after planting            d
      INTEGER       DAPCALC       ! DAP output from funcion        #
      CHARACTER*10  DAPCHAR       ! DAP in character form          text
      CHARACTER*6   DAPWRITE      ! DAP character string -> output text
      INTEGER       DAS           ! Days after start of simulation #
      INTEGER       DATE          ! Date (Yr+Doy)                  #
      INTEGER       DATECOL       ! Date column number             #
      REAL          DAYADJ        ! Daylength adjustment           h
      INTEGER       DOM           ! Day of month                   #
      INTEGER       DOY           ! Day of year                    #
      INTEGER       DOYCOL        ! Day of year column number      #
      REAL          DPTADJ        ! Dew point adjustment           C
      INTEGER       DRDAT         ! Double ridges date             #
      INTEGER       DRDATM        ! Double ridges date,measured    #
      CHARACTER*64  ECDIRFLE      ! Ecotype directory+file         text
      INTEGER       EDAP          ! Emergence DAP                  #
      INTEGER       EDAPM         ! Emergence DAP measured         #
      INTEGER       EDATM         ! Emergence date,measured (Afle) #
      INTEGER       EMDATEAA      ! Emergence date abs error avg   #
      INTEGER       EMDATEAV      ! Emergence date average error   #
      INTEGER       EMDATERR      ! Emergence date error           d
      INTEGER       EMDATM        ! Emergence yr+d,measured (Xfle) #
      INTEGER       EMDATNUM      ! Emergence date error #         #
      INTEGER       EMDATSUA      ! Emergence date abs error #     #
      INTEGER       EMDATSUM      ! Emergence date error sum       #
      CHARACTER*60  ENAME         ! Experiment description         text
      REAL          ERRORVAL      ! Plgro-tfile values/Plgro       #
      INTEGER       EVALOUT       ! Evaluate output lines for exp  #
      CHARACTER*10  EXCODE        ! Experiment code/name           text
      CHARACTER*10  EXCODEP       ! Previous experiment code/name  text
      CHARACTER*12  EVHEADER      ! Evaluater.out header           text
      INTEGER       EVHEADNM      ! Number of headings in ev file  #
      LOGICAL       FEXIST        ! File existence indicator       code
      LOGICAL       FEXISTA       ! File A existence indicator     code
      LOGICAL       FEXISTT       ! File T existence indicator     code
      CHARACTER*120 FILEA         ! Name of A-file                 text
      CHARACTER*120 FILEIO        ! Name of input file             text
      CHARACTER*3   FILEIOT       ! Input file type indicator      text
      INTEGER       FILELEN       ! Length of file name            #
      CHARACTER*120 FILENEW       ! Temporary name of file         text
      CHARACTER*120 FILET         ! Name of T-file                 text
      CHARACTER*12  FNAMETMP      ! File name,temporary            #
      INTEGER       FNUMT         ! Number used for T-file         #
      INTEGER       FNUMTMP       ! File number,temporary          #
      INTEGER       FNUMWRK       ! File number,work file          #
      LOGICAL       FOPEN         ! File open indicator            code
      INTEGER       FROP          ! Frquency of outputs            d
      REAL          GNAM          ! Harvest N,mature               kg/ha
      REAL          GNAMEAA       ! Grain N/area abs error avg     #
      REAL          GNAMEAV       ! Grain N/area average error     #
      REAL          GNAMERR       ! Harvest N,error                %
      REAL          GNAMM         ! Harvest N,mature,measured      kg/ha
      INTEGER       GNAMNUM       ! Grain N/area error #           #
      REAL          GNAMSUA       ! Grain N/area abs error #       #
      REAL          GNAMSUM       ! Grain N/area error sum         #
      REAL          GNPCM         ! Harvest N%,measured            %
      REAL          GNPCMEAA      ! Grain N% abs error avg         #
      REAL          GNPCMEAV      ! Grain N% average error         #
      REAL          GNPCMERR      ! Harvest N%,error               %
      REAL          GNPCMM        ! Harvest N,mature,measured      %
      INTEGER       GNPCMNUM      ! Grain N% error #               #
      REAL          GNPCMSUA      ! Grain N% abs error #           #
      REAL          GNPCMSUM      ! Grain N% error sum             #
      CHARACTER*1   GROUP         ! Flag for type of group         code
      REAL          GSTDM         ! Growth stage,measured          #
      REAL          GWADT         ! Grain weight from t file       kg/ha
      REAL          GWGM          ! Grain wt per unit,maturity     mg
      REAL          GWGMM         ! Grain wt per unit,mat,measured mg
      INTEGER       HADAY         ! Harvest day of year            #
      REAL          HPC           ! Harvest percentage             %
      REAL          HBPC          ! Harvested by-product percentage %
      INTEGER       HAYEAR        ! Harvest year                   #
      REAL          HIADT         ! Harvest index from t file      #
      REAL          HIAM          ! Harvest index,mature           %
      REAL          HIAMEAA       ! Harvest index abs error avg    #
      REAL          HIAMEAV       ! Harvest index average error    #
      REAL          HIAMERR       ! Harvest index,maturity,error   %
      REAL          HIAMM         ! Harvest index,mature,measure   #
      REAL          HIAMMTMP      ! Harvest index,mature,temporary #
      INTEGER       HIAMNUM       ! Harvest index error #          #
      REAL          HIAMSUA       ! Harvest index abs error #      #
      REAL          HIAMSUM       ! Harvest index error sum        #
      REAL          HINM          ! Harvest index,N,abground,mat   #
      REAL          HINMM         ! Harvest N index,mature,meas    %
      REAL          HNUMAEAA      ! Harvest #/area abs error avg   #
      REAL          HNUMAEAV      ! Harvest #/area average error   #
      REAL          HNUMAERR      ! Harvest #,maturity,error       %
      REAL          HNUMAM        ! Harvest #,maturity             #/m2
      REAL          HNUMAMM       ! Harvest #,mature,measured      #/m2
      INTEGER       HNUMANUM      ! Harvest #/area error #         #
      REAL          HNUMASUA      ! Harvest #/area abs error #     #
      REAL          HNUMASUM      ! Harvest #/area error sum       #
      REAL          HNUMAT        ! Harvest number/area,t file     #/m2
      REAL          HNUMET        ! Harvest number/ear,t file      #/s
      REAL          HNUMGEAA      ! Harvest #/group abs error avg  #
      REAL          HNUMGEAV      ! Harvest #/group average error  #
      REAL          HNUMGERR      ! Harvest #/group,error          %
      REAL          HNUMGM        ! Harvest #,maturity             #/g
      REAL          HNUMGMM       ! Harvest #,mature,measured      #/g
      INTEGER       HNUMGNUM      ! Harvest #/group error #        #
      REAL          HNUMGSUA      ! Harvest #/group abs error #    #
      REAL          HNUMGSUM      ! Harvest #/group error sum      #
      REAL          HNUMSMM       ! Harvest #,mature,measured      #/s
      REAL          HWADM         ! Harvest wt,measured            kg/ha
      REAL          HWAHEAA       ! Harvest wt/area abs error avg  #
      REAL          HWAHEAV       ! Harvest wt/area average error  #
      REAL          HWAHERR       ! Harvest wt,harvest,error       %
      REAL          HWAHM         ! Harvest wt,harvest,measured    kg/ha
      INTEGER       HWAHNUM       ! Harvest wt/area error #        #
      REAL          HWAHSUA       ! Harvest wt/area abs error #    #
      REAL          HWAHSUM       ! Harvest wt/area error sum      #
      REAL          GWAM          ! Harvest wt,maturity            kg/ha
      REAL          GWAMM         ! Harvest wt,mature,measured     kg/ha
      REAL          GWUM          ! Grain wt per unit,maturity     g
      REAL          GWUMEAA       ! Grain wt/unit abs error avg    #
      REAL          GWUMEAV       ! Grain wt/unit average error    #
      REAL          GWUMERR       ! Grain wt per unit error        %
      REAL          GWUMM         ! Grain wt/unit,mat,measured     g
      CHARACTER*6   GWUMMC        ! Grain wt/unit,mat,measured     text
      INTEGER       GWUMNUM       ! Grain wt/unit error #          #
      REAL          GWUMSUA       ! Grain wt/unit abs error #      #
      REAL          GWUMSUM       ! Grain wt/unit error sum        #
      REAL          GWUMYLD       ! Grain wt,mature,calculated     g/#
      REAL          GWUT          ! Grain weight/unit,t file       mg
      CHARACTER*1   IDETOU        ! Control flag,error op,inputs   code
      CHARACTER*1   IDETG         ! Control flag,growth outputs    code
      CHARACTER*1   IDETL         ! Control switch,detailed output code
      CHARACTER*1   IDETO         ! Control flag,overall outputs   code
      CHARACTER*1   ISWNIT        ! Soil nitrogen balance switch   code
      CHARACTER*1   ISWWAT        ! Soil water balance switch Y/N  code
      INTEGER       JDAT          ! Jointing date (Year+doy)       #
      INTEGER       JDATM         ! Jointing date,measured,Yeardoy #
      INTEGER       L             ! Loop counter                   #
      INTEGER       L1            ! Loop counter                   #
      INTEGER       L2            ! Loop counter                   #
      REAL          LAISTG(20)    ! Leaf area index,specific stage #
      REAL          LAIX          ! Leaf area index,maximum        m2/m2
      REAL          LAIXEAA       ! Leaf area index,max,abs err av #
      REAL          LAIXEAV       ! Leaf area index,max,average er #
      REAL          LAIXERR       ! Leaf area index,max,error      %
      REAL          LAIXM         ! Lf lamina area index,mx,meas   m2/m2
      INTEGER       LAIXNUM       ! Leaf area index,max, error #   #
      REAL          LAIXSUA       ! Leaf area index,max, abs error #
      REAL          LAIXSUM       ! Leaf area index,max, error sum #
      REAL          LAIXT         ! Leaf area index,max,t-file     m2/m2
      INTEGER       LENFILEI      ! Length,input file name         #
      INTEGER       LENGROUP      ! Length of group name           #
      INTEGER       LENLINE       ! Length of characgter string    #
      INTEGER       LENTNAME      ! Length,treatment description   #
      CHARACTER*80  LINESTAR      ! Group header line (with star)  text
      CHARACTER*180 LINET         ! Line from T-file               text
      INTEGER       LLDATM        ! Last leaf (mature) date,measured
      REAL          LNAAM         ! Leaf N,anthesis,measured       kg/ha
      REAL          LNPCA         ! Leaf N,anthesis                %
      REAL          LNPCAM        ! Leaf N,anthesis,measured       %
      REAL          LNUMSEAA      ! Leaf #/shoot abs error avg     #
      REAL          LNUMSEAV      ! Leaf #/shoot average error     #
      REAL          LNUMSERR      ! Leaf #,error                   %
      REAL          LNUMSM        ! Leaf #/shoot,maturity          #
      REAL          LNUMSMM       ! Leaf #,mature,measured         #/s
      INTEGER       LNUMSNUM      ! Leaf #/shoot error #           #
      REAL          LNUMSSUA      ! Leaf #/shoot abs error #       #
      REAL          LNUMSSUM      ! Leaf #/shoot error sum         #
      REAL          LNUMSTG(20)   ! Leaf number,specific stage     #
      REAL          LNUMT         ! Leaf number from t file        #
      REAL          LWAAM         ! Leaf wt,anthesis,measured      kg/ha
      INTEGER       MDAP          ! Maturity days after planting   #
      INTEGER       MDAPM         ! Maturity DAP,measured          #
      INTEGER       MDATEAA       ! Maturity date abs error avg    #
      INTEGER       MDATEAV       ! Maturity date average error    #
      INTEGER       MDATERR       ! Maturity date error            d
      INTEGER       MDATM         ! Maturity date,measured yr+d    #
      INTEGER       MDATNUM       ! Maturity date error #          #
      INTEGER       MDATSUA       ! Maturity date abs error #      #
      INTEGER       MDATSUM       ! Maturity date error sum        #
      REAL          MDATT         ! Maturity date from t file      YrDoy
      INTEGER       MDAY          ! Maturity day of year           d
      INTEGER       MDAYM         ! Maturity day of year,measured  d
      CHARACTER*1   MODE          ! Mode of model operation        code
      CHARACTER*8   MODEL         ! Name of model                  text
      CHARACTER*8   MODULE        ! Name of module                 text
      CHARACTER*3   MONTH         ! Month                          text
      INTEGER       MYEAR         ! Maturity year                  #
      INTEGER       MYEARM        ! Maturity year,measured         #
      REAL          NFPAV(9)      ! N factor,phs,average,phase     #
      INTEGER       NOUTDG        ! Number for growth output file  #
      REAL          NUAD          ! N uptake,cumulative->maturity  kg/ha
      REAL          NUADM         ! N uptake,cumulative,measured   kg/ha
      INTEGER       ON            ! Option number (sequence runs)  #
      CHARACTER*3   OUT           ! Output file extension          text
      INTEGER       OUTCOUNT      ! Output counter                 #
      CHARACTER*70  OUTHED        ! Output file heading            text
      CHARACTER*80  OVLINE(60)    ! Overview lines from Header.out text
      INTEGER       PGDAP         ! Plantgro file days after plt   #
      INTEGER       PGROCOL(20)   ! Plantgro column = t-file data  #
      REAL          PGVAL         ! Plantgro file value            #
      INTEGER       PLDAY         ! Planting day of year           #
      INTEGER       PLDAYP        ! Planting day of year           #
      REAL          PLTPOP        ! Plant Population               #/m2
      INTEGER       PLYEAR        ! Planting year                  #
      REAL          PRCADJ        ! Precipitation adjustment       mm
      REAL          PREW          ! Production estimate from water kg/ha
      REAL          PRER          ! Production estimate from radn  kg/ha
      REAL          PREO          ! Production estimate,overall    kg/ha
      REAL          PWAM          ! Chaff + seed wt,maturity       kg/ha
      REAL          RADADJ        ! Radiation adjustment           MJ/m2
      REAL          RAINC         ! Rainfall,cumulative            mm
      REAL          RAINCA        ! Rainfall,cumulativ to anthesis mm
      INTEGER       REP           ! Number of run repetitions      #
      INTEGER       RN            ! Treatment replicate            #
      REAL          RNAM          ! Root N at maturity             kg/ha
      REAL          RNAMM         ! Root N at maturity,measured    kg/ha
      CHARACTER*1   RNMODE        ! Run mode (eg.I=interactive)    #
      REAL          ROWSPC        ! Row spacing                    cm
      REAL          RSWAM         ! Reserves at maturity           kg/ha
      REAL          RSWAMM        ! Reserves at maturity,measured  kg/ha
      INTEGER       RUN           ! Run (from command line) number #
      INTEGER       RUNI          ! Run (internal for sequences)   #
      CHARACTER*75  RUNNAME       ! Run title                      text
      REAL          RWAM          ! Root wt at maturity            kg/ha
      REAL          RWAMM         ! Root wt at maturity,measured   kg/ha
      REAL          SDNAP         ! Seed N at planting             kg/ha
      REAL          SDRATE        ! Seeding 'rate'                 kg/ha
      REAL          SENNATC       ! Senesced N,litter+soil,cum     kg/ha
      REAL          SENNATCM      ! Senesced N,litter+soil,cum,mes kg/ha
      REAL          SENWATC       ! Senesced om,litter+soil,cum    kg/ha
      REAL          SENWATCM      ! Senesced om,litter+soil,cum    kg/ha
      INTEGER       SN            ! Sequence number,crop rotation  #
      REAL          TNUMAEAA      ! Shoot #/area abs error avg     #
      REAL          TNUMAEAV      ! Shoot #/area average error     #
      REAL          TNUMAERR      ! Shoot #,error                  %
      REAL          TNUMAM        ! Shoot #,maturity               #/m2
      REAL          TNUMAMM       ! Shoot #,mature,measured        #/m2
      INTEGER       TNUMANUM      ! Shoot #/area error #           #
      REAL          TNUMASUA      ! Shoot #/area abs error #       #
      REAL          TNUMASUM      ! Shoot #/area error sum         #
      REAL          TNUMT         ! Shoot number from t file       #/m2
      INTEGER       SPDATM        ! Spike emergence date,measured  #
      CHARACTER*64  SPDIRFLE      ! Species directory+file         text
      REAL          SRADC         ! Solar radiation,cumulative     MJ/m2
      INTEGER       STARNUM       ! Star line number,as read file  #
      INTEGER       STARNUMM      ! Star line number,measured data #
      INTEGER       STARNUMO      ! Star line number,output file   #
      INTEGER       STEP          ! Step number                    #
      INTEGER       STGDOY(20)    ! Stage dates (Year+Doy)         #
      CHARACTER*10  STNAME(20)    ! Stage names                    text
      CHARACTER*6   TCHAR         ! Temporary character string     #
      INTEGER       TFCOLNUM      ! T-file column number           #
      INTEGER       TFDAP         ! T-file days after planting     #
      INTEGER       TFDAPCOL      ! T-file DAP column #            #
      REAL          TFLEAVA(10)   ! ERT-file average absolute err  #
      REAL          TFLEAVE(10)   ! ERT-file average error         #
      INTEGER       TFLECOL(10)   ! ERT-file error column          #
      REAL          TFLENUM(10)   ! ERT-file error number          #
      REAL          TFLEVAA(10)   ! ERT-file error absoulte value  #
      REAL          TFLEVAL(10)   ! ERT-file error value           #
      REAL          TFVAL         ! T-file value                   #
      CHARACTER*6   THEAD(20)     ! T-file headings                #
      CHARACTER*10  TL10FROMI     ! Temporary line from integer    text
      CHARACTER*180 TLINEGRO      ! Temporary line from GRO file   text
      INTEGER       TLINENUM      ! Temporary var,# lines in tfile #
      CHARACTER*180 TLINET        ! Temporary line from T-file     text
      CHARACTER*180 TLINETMP      ! Temporary line                 #
      INTEGER       TLPOS         ! Position on temporary line     #
      REAL          TMADJ         ! Temperature,minimum,adjustment C
      REAL          TMAXM         ! Temperature maximum,monthly av C
      REAL          TMAXX         ! Temperature max during season  C
      REAL          TMINM         ! Temperature minimum,monthly av C
      REAL          TMINN         ! Temperature min during season  C
      INTEGER       TN            ! Treatment number               #
      CHARACTER*25  TNAME         ! Treatment name                 text
      REAL          TNAMM         ! Total N at maturity,measured   kg/ha
      CHARACTER*10  TNCHAR        ! Treatment number,characters    text
      INTEGER       TSDAT         ! Terminal spkelet date          #
      INTEGER       TSDATM        ! Terminal spkelet date,measured #
      INTEGER       TVI1          ! Temporary integer variable     #
      INTEGER       TVICOLNM      ! Column number function output  #
      INTEGER       TVILENT       ! String length,trimmed,output   #
      REAL          TXADJ         ! Temperature,maximum,adjustment C
      INTEGER       VALUEI        ! Output from Getstri function   #
      REAL          VALUER        ! Output from Getstrr function   #
      REAL          VALUERR       ! Value of error                 #
      CHARACTER*6   VARNO         ! Variety identification code    text
      CHARACTER*6   VARNOP        ! Variety code,previous run      text
      REAL          VERSION       ! Version number                 #
      REAL          VERSIOND      ! Version # default              #
      REAL          VNAA          ! Vegetative N,anthesis          kg/ha
      REAL          VNAM          ! Vegetative N,mature            kg/ha
      REAL          VNAMM         ! Vegetative N,mature,measured   kg/ha
      REAL          VNPCM         ! Vegetative N %,maturity        %
      REAL          VNPCMM        ! Vegetative N,mature,measure    %
      CHARACTER*16  VRNAME        ! Variety name or identifier     text
      REAL          CWAA          ! Canopy wt,anthesis             kg/ha
      REAL          VWAM          ! Vegetative wt,mature           kg/ha
      REAL          VWAMEAA       ! Vegetative wt/area abs err avg #
      REAL          VWAMEAV       ! Vegetative wt/area average err #
      REAL          VWAMERR       ! Vegetative wt,error            %
      REAL          VWAMM         ! Veg wt,mature,measured         kg/ha
      INTEGER       VWAMNUM       ! Vegetative wt/area error #     #
      REAL          VWAMSUA       ! Vegetative wt/area abs error # #
      REAL          VWAMSUM       ! Vegetative wt/area error sum   #
      REAL          WFPAV(9)      ! Water factor,phs,average 0-1   #
      REAL          WNDADJ        ! Wind adjustment                m/s
      REAL          XWTDP         ! Water table depth              cm
      INTEGER       YEAR          ! Year                           #
      INTEGER       YEARCOL       ! Colum number for year data     #
      INTEGER       YEARPLT       ! Year+Doy for planting          #
      INTEGER       YEARSIM       ! Year+Doy for simulation start  #

      INTEGER istat

      ! Arrays for passing variables to OPSUM subroutine, CSM model only
      INTEGER,      PARAMETER :: SUMNUM = 16
      CHARACTER*4,  DIMENSION(SUMNUM) :: LABEL
      REAL,         DIMENSION(SUMNUM) :: VALUE

      IF (tnumam.GT.0.0) hnumgm = hnumam/tnumam
      gwgm = gwum*1000.0    ! mg

!-----------------------------------------------------------------------

      CALL Getlun ('WORK.OUT',fnumwrk)
      CALL Getlun ('OUTO',FNUMTMP)
      CALL GETLUN ('OUTPG',NOUTDG)

      WRITE (fnumwrk,*) ' '
      WRITE (fnumwrk,*) 'HARVEST DAY OUTPUTS'
      WRITE (fnumwrk,*) ' '
      IF (STEP.NE.1) THEN
        WRITE (fnumwrk,*) ' Step number greater than 1!'
        WRITE (fnumwrk,*) ' Not set up for hourly runs!'
        WRITE (fnumwrk,*) ' Will skip final outputs.'
        GO TO 8888
      ENDIF
      WRITE(fnumwrk,*)'Harvest percentage (Technology coeff) ',hpc

      CNCHAR = ' '
      CNCHAR2 = '  '
      IF (CN.EQ.1) THEN
        OUT = 'OUT'
        CNCHAR2= '1 '
      ELSE
        CNCHAR = TL10FROMI(CN)
        OUT = 'OU'//CNCHAR(1:1)
        CNCHAR2(1:1) = CNCHAR(1:1)
      ENDIF

      CALL CSYR_DOY (STGDOY(7),PLYEAR,PLDAY)
      IF (ADAT.GT.0) THEN
        CALL CSYR_DOY (ADAT,AYEAR,ADAY)
      ELSE
        AYEAR = -99
        ADAY = -99
      ENDIF
      IF (STGDOY(5).GT.0) THEN
        CALL CSYR_DOY (STGDOY(5),MYEAR,MDAY)
      ELSE
        MYEAR = -99
        MDAY = -99
      ENDIF
      CALL CSYR_DOY (STGDOY(11),HAYEAR,HADAY)

      CALL Ltrim (runname)
      IF (runname(1:6).EQ.'      ' .OR.
     &    runname(1:3).EQ.'-99') runname(1:25) = tname

!-----------------------------------------------------------------------

      ! SCREEN OUTPUTS (CROPSIM)

      IF (FILEIOT(1:3).EQ.'XFL' .AND. CN.EQ.1 .AND. MODE.NE.'G') THEN

        IF (OUTCOUNT.LE.0 .OR. OUTCOUNT.EQ.25) THEN
          WRITE (*,499)
  499     FORMAT ('   RUN EXCODE      TN RN',
     X     ' TNAME..................',
     X     '.. REP  RUNI S O C CR  GWAM')
        ENDIF
        IF (OUTCOUNT .EQ. 25) THEN
          OUTCOUNT = 1
        ELSE
          OUTCOUNT = OUTCOUNT + 1
        ENDIF
        WRITE (*,410) run,excode,tn,rn,tname(1:25),
     X  rep,runi,sn,on,cn,cr,NINT(gwam)
  410   FORMAT (I6,1X,A10,I4,I3,1X,A25,
     X  I4,I6,I2,I2,I2,1X,A2,I6)
      ENDIF

      ! END OF SCREEN OUTPUTS

!-----------------------------------------------------------------------

      ! PLANT SUMMARY

      WRITE (fnumwrk,*) 'Writing PLANT SUMMARY'

      FNAMETMP = ' '
      FNAMETMP(1:12) = 'PLANTSUM.'//OUT
      IF (RUN.EQ.1 .AND. RUNI.EQ.1) THEN
       OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,STATUS = 'UNKNOWN')
       WRITE (FNUMTMP,'(A20)') '$(2004)PLANT SUMMARY'
       WRITE (FNUMTMP,*) ' '
       WRITE (fnumtmp,96)
       WRITE (fnumtmp,99)
   96  FORMAT ('*PLANTSUM',/)
   99  FORMAT ('@  RUN EXCODE      TN RN TNAME..................',
     X '.. REP  RUNI S O C    CR',
     X '  YEAR  PDAY  ADAY  MDAY HYEAR  HDAY SDWAP  CWAM  GWAM  HWAH',
     X '  BWAH  GWGM  H#AM  H#UM',
     x ' SDNAP  CNAM  GNAM  RNAM  TNAM  NUAM  GN%M  VN%M')
       CLOSE(fnumtmp)
      ENDIF

      OPEN (UNIT=fnumtmp,FILE=FNAMETMP,ACCESS='APPEND')

      WRITE (fnumtmp,400) run,excode,tn,rn,tname(1:25),
     X  rep,runi,sn,on,cn,cr,
     X  plyear,plday,aday,mday,hayear,haday,
     X  NINT(sdrate),
     X  NINT(cwam),NINT(gwam),
     X  NINT(gwam*hpc/100.0),NINT(cwam-gwam),
     X  NINT(gwgm),NINT(hnumam),NINT(hnumgm),
     X  sdnap,NINT(cnam),NINT(gnam),NINT(rnam),
     X  NINT(cnam+rnam),NINT(nuad),
     X  gnpcm,vnpcm
  400 FORMAT (I6,1X,A10,I4,I3,1X,A25,
     X I4,I6,I2,I2,I2,4X,A2,
     X I6,I6,I6,I6,I6,I6,
     X I6,
     X I6,I6,
     X I6,I6,
     X I6,I6,I6,
     X F6.1,I6,I6,I6,
     X I6,I6,
     X F6.2,F6.2)

      CLOSE(fnumtmp)       ! END OF PLANT SUMMARY

!-----------------------------------------------------------------------

      ! CSM SUMMARY ... not used in CROPSIM

      ! Store Summary labels and values in arrays to send to
      ! OPSUM routine for printing.  Integers are temporarily
      ! saved as real numbers for placement in real array.

      LABEL(1) = 'ADAT'; VALUE(1) = FLOAT(adat)
      LABEL(2) = 'MDAT'; VALUE(2) = FLOAT(stgdoy(5))
      LABEL(3) = 'DWAP'; VALUE(3) = sdrate
      LABEL(4) = 'CWAM'; VALUE(4) = cwam
      LABEL(5) = 'HWAM'; VALUE(5) = gwam

! LAH / CHP 12/17/04 added hpc and hbpc to SUMVALS call
      LABEL(6) = 'HWAH'; VALUE(6) = gwam * hpc / 100.
      LABEL(7) = 'BWAH'; VALUE(7) = vwam * hbpc / 100. / 10.

      LABEL(8) = 'HWUM'; VALUE(8) = gwum
      LABEL(9) = 'H#AM'; VALUE(9) = hnumam
      LABEL(10) = 'H#UM'; VALUE(10) = hnumgm
      LABEL(11) = 'NUCM'; VALUE(11) = nuad
      LABEL(12) = 'CNAM'; VALUE(12) = cnam
      LABEL(13) = 'GNAM'; VALUE(13) = gnam
      LABEL(14) = 'PWAM'; VALUE(14) = PWAM    !CHP ADDED 2/4/2005
      LABEL(15) = 'LAIX'; VALUE(15) = LAIX    !CHP ADDED 2/4/2005
      LABEL(16) = 'HIAM'; VALUE(16) = HIAM    !CHP ADDED 2/4/2005
      IF (FILEIOT(1:2).EQ.'DS') CALL SUMVALS (SUMNUM, LABEL, VALUE)

      ! END OF CSM SUMMARY

!-----------------------------------------------------------------------

      IF (RNMODE.NE.'E') THEN
        IF (IDETO.NE.'Y') GO TO 8888
      ENDIF

!-----------------------------------------------------------------------

      ! A-FILE READS

      adatm = -99
      adatt = -99
      adayh = -99
      carboacm = -99
      cnaam = -99
      cnamm = -99
      cwaam = -99
      cwadt = -99
      cwamm = -99
      drdatm = -99
      edatm = -99
      emdatm = -99
      gnamm = -99
      gnpcmm = -99
      gstdm = -99
      gwadt = -99
      hiadt = -99
      hiamm = -99
      hinmm = -99
      hnumamm = -99
      hnumat = -99
      hnumet = -99
      hnumgmm = -99
      hwadm = -99
      hwahm = -99
      gwamm = -99
      gwut = -99
      gwumm = -99
      jdatm = -99
      laixm = -99
      lnaam = -99
      lnpcam = -99
      lnumsmm = -99
      lnumt = -99
      lwaam = -99
      mdatm = -99
      mdatt = -99
      nuadm = -99
      rnamm = -99
      rswamm = -99
      rwamm = -99
      sennatcm = -99
      senwatcm = -99
      tnumamm = -99
      tnumt = -99
      tsdatm = -99
      vnamm = -99
      vnpcmm = -99
      cwaam = -99

      CALL LTRIM2 (FILEIO,filenew)
      FILELEN = TVILENT(FILENEW)
      FILEA = FILENEW(1:FILELEN-12)//EXCODE(1:8)//'.'//EXCODE(9:10)//'A'
      FEXISTA = .FALSE.
      INQUIRE (FILE = FILEA,EXIST = FEXISTA)
      IF (.not.FEXISTA) THEN
        WRITE (fnumwrk,*) 'A-file not found!'
      ELSE
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'GWAM',gwamm)
        IF (gwamm.LE.0.0)
     &   CALL AREADR (FILEA,TN,RN,SN,ON,CN,'HWAM',gwamm)
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'HWAH',hwahm)
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'HWUM',gwumm)
        IF (gwumm.le.0.0)
     &   CALL AREADR (FILEA,TN,RN,SN,ON,CN,'GWUM',gwumm)
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'LAIX',laixm)
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'CWAM',cwamm)
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'BWAH',vwamm)
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'CWAA',cwaam)
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'T#AM',tnumamm)
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'H#AM',hnumamm)
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'H#SM',hnumsmm)
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'L#SM',lnumsmm)

        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'CNAM',cnamm)
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'VNAM',vnamm)
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'CNAA',cnaam)
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'GNAM',gnamm)
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'LN%A',lnpcam)
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'GN%M',gnpcmm)
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'VN%M',vnpcmm)
        IF (vnpcmm.le.0.0)
     &   CALL AREADR (FILEA,TN,RN,SN,ON,CN,'VN%D',vnpcmm)
        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'L#SM',lnumsmm)

        CALL AREADR (FILEA,TN,RN,SN,ON,CN,'HIAM',hiamm)
        IF (HIAMM.GE.1.0) HIAMM = HIAMM/100.0

        CALL AREADI (FILEA,TN,RN,SN,ON,CN,'EDAT',edatm)
        CALL AREADI (FILEA,TN,RN,SN,ON,CN,'DRDAT',drdatm)
        CALL AREADI (FILEA,TN,RN,SN,ON,CN,'TSPD',tsdatm)
        CALL AREADI (FILEA,TN,RN,SN,ON,CN,'A1DAT',a1datm)
        CALL AREADI (FILEA,TN,RN,SN,ON,CN,'LLDAT',lldatm)
        CALL AREADI (FILEA,TN,RN,SN,ON,CN,'SPDAT',spdatm)
        CALL AREADI (FILEA,TN,RN,SN,ON,CN,'ADAT',adatm)
        CALL AREADI (FILEA,TN,RN,SN,ON,CN,'JDAT',jdatm)
        IF (ADATM.LE.0) THEN
          CALL AREADI (FILEA,TN,RN,SN,ON,CN,'GS059',adatm)
          IF (ADATM.GT.0) THEN
            ADATM = ADATM + 2
            WRITE (fnumwrk,*) 'WARNING  ADAT = GS059 + 2'
          ENDIF
        ENDIF
        IF (ADATM.LE.0) THEN
          CALL AREADI (FILEA,TN,RN,SN,ON,CN,'ADAY',adaym)
          CALL AREADI (FILEA,TN,RN,SN,ON,CN,'YEAR',ayearm)
          ADATM = CSYDOY(AYEARM,ADAYM)
        ENDIF
        CALL AREADI (FILEA,TN,RN,SN,ON,CN,'MDAT',mdatm)
        IF (MDATM.LE.0) THEN
          CALL AREADI (FILEA,TN,RN,SN,ON,CN,'MDAY',mdaym)
          CALL AREADI (FILEA,TN,RN,SN,ON,CN,'YEAR',myearm)
          MDATM = CSYDOY(MYEARM,MDAYM)
        ENDIF
      ENDIF

      IF (EDATM.LE.0) edatm = emdatm   ! If nothing in A-file,use X-file

      ! END OF A-FILE READS

!-----------------------------------------------------------------------

      ! CHECK DATA AND USE EQUIVALENTS IF NECESSARY

      ! Product wt at maturity
      IF (hwahm.GT.0 .AND. gwamm.LE.0) gwamm = hwahm/(hpc/100.0)

      ! Product wt at harvest
      IF (gwamm.GT.0 .AND. hwahm.LE.0) hwahm = gwamm*(hpc/100.0)

      ! Canopy wt at maturity
      IF (vwamm.GT.0 .AND. gwamm.GT.0) cwamm = vwamm+gwamm

      ! Vegetative wt at maturity
      IF (gwamm.GT.0 .AND. cwamm.GT.0) vwamm = cwamm-gwamm

      ! Harvest index at maturity
      IF (hiamm.LE.0.0) THEN
        IF (cwamm.GT.0 .AND. gwamm.GT.0) hiamm = gwamm/cwamm
      ELSE
        IF (cwamm.GT.0 .AND. gwamm.GT.0) THEN
          hiammtmp = gwamm/cwamm
          IF (hiammtmp/hiam.GT.1.1 .OR. hiammtmp/hiam.LT.0.9) THEN
            IF (ABS(hiammtmp-hiamm)/hiamm.GT.0.05) THEN
              WRITE (fnumwrk,*) 'Reported HI not consistent',
     &         ' with yield and total weight data!!'
              WRITE (fnumwrk,*) ' Reported HI   ',hiamm
              WRITE (fnumwrk,*) ' Calculated HI ',hiammtmp
              WRITE (fnumwrk,*) ' Will use reported value '
            ENDIF
          ENDIF
        ENDIF
      ENDIF

      ! Product unit wt at maturity
      IF (gwumm.GT.1.0) gwumm = gwumm/1000.0 ! mg->g
      IF (gwumm.LE.0 .AND. hnumamm.GT.0) THEN
        IF (gwamm.GT.0.0) gwumm=gwamm*0.1/hnumamm  ! kg->g
      ELSE
        IF (gwamm.gt.0.0.AND.hnumamm.GT.0.0) THEN
          gwumyld = gwamm*0.1/hnumamm
          IF (ABS(gwumyld-gwumm)/gwumm.GT.0.05) THEN
            WRITE (fnumwrk,*) 'Reported kernel wt.not consistent',
     &      ' with yield and kernel # data!!'
            WRITE (fnumwrk,*) ' Reported wt   ',gwumm
            WRITE (fnumwrk,*) ' Calculated wt ',gwumyld
            WRITE (fnumwrk,*) '   Yield       ',gwamm
            WRITE (fnumwrk,*) '   Kernel #    ',hnumamm
            WRITE (fnumwrk,*) ' Will use reported value '
            !gwumm=gwumyld
          ENDIF
        ENDIF
      ENDIF
      gwgmm = gwumm*1000.0  ! mg

      ! Product number at maturity
      IF (HNUMAMM.LE.0.0.AND.HNUMGMM.GT.0.0.AND.TNUMAMM.GT.0.0) THEN
        HNUMAMM = HNUMGMM * TNUMAMM
        WRITE(fnumwrk,*)'Tiller # * grains/tiller used for HNUMAMM'
      ENDIF
      IF (hnumgmm.LE.0. AND. tnumamm.GT.0 .AND. hnumamm.GT.0) THEN
        hnumgmm = hnumamm/tnumamm
        WRITE(fnumwrk,*)'Grains/area / tiller # used for HNUMGMM'
      ENDIF

      ! Tiller number at maturity
      IF (tnumamm.LE.0 .AND. hnumamm.GT.0. AND. hnumgmm.GT.0)
     &   tnumamm = hnumamm/hnumgmm

      ! Canopy N at maturity
      IF (vnamm.GT.0 .AND. gnamm.GT.0 .AND. cnamm.LE.0)
     &  cnamm = vnamm + gnamm

      ! Vegetative N at maturity
      IF (vnamm.LE.0) THEN
       IF (gnamm.GE.0 .AND. cnamm.GT.0) vnamm=cnamm-gnamm
      ENDIF

      ! Product N harvest index at maturity
      IF (cnamm.GT.0 .AND. gnamm.GT.0) hinmm=gnamm/cnamm

      ! Vegetative N concentration at maturity
      IF (vnpcmm.LE.0) THEN
       IF (vwamm.GT.0 .AND. vnamm.GT.0) vnpcmm = (vnamm/vwamm)*100
      ENDIF

      ! Product N concentration at maturity
      IF (gnpcmm.LE.0) THEN
       IF (gwamm.GT.0 .AND. gnamm.GT.0) gnpcmm = (gnamm/gwamm)*100
      ENDIF

      ! Leaf N concentration at maturity
      IF (lnpcam.LE.0 .AND. lnaam.GT.0 .AND. lwaam.GT.0.0)
     &  lnpcam = lnaam/lwaam

!-----------------------------------------------------------------------

      ! Character equivalents for output

      IF (gwumm.LE.0) THEN
        gwummc = ' -99.0'
      ELSE
        gwummc = ' '
        WRITE (gwummc,'(F6.3)') gwumm
      ENDIF

      ! END OF CHECKING DATA

!-----------------------------------------------------------------------

      IF (FILEIOT(1:3).EQ.'DS4' .AND. CN.EQ.1 .AND. RNMODE.EQ.'E') THEN

        CALL CSCLEAR5
        WRITE(*,9600)
        DO L = 7, 9
          CALL CSYR_DOY(STGDOY(L),YEAR,DOY)
          CALL Calendar(year,doy,dom,month)
          CNCTMP = 0.0
          IF (CWADSTG(L).GT.0.0) CNCTMP = CNADSTG(L)/CWADSTG(L)*100
          WRITE (*,'(I8,I4,1X,A3,I4,1X,I1,1X,A10,I6,F6.2,
     &     F6.1,I6,F6.1,F6.2,F6.2)')
     &     STGDOY(L),DOM,MONTH,
     &     Dapcalc(stgdoy(L),plyear,plday),L,STNAME(L),
     &     NINT(CWADSTG(L)),LAISTG(L),LNUMSTG(L),
     &     NINT(CNADSTG(L)),CNCTMP,1.0-WFPAV(L),1.0-NFPAV(L)
        ENDDO
        DO L = 1, 6
          CALL CSYR_DOY(STGDOY(L),YEAR,DOY)
          CALL Calendar(year,doy,dom,month)
          CNCTMP = 0.0
          IF (CWADSTG(L).GT.0.0) CNCTMP = CNADSTG(L)/CWADSTG(L)*100
          IF (STGDOY(L).GT.0) THEN
            WRITE (*,'(I8,I4,1X,A3,I4,1X,I1,1X,A10,I6,F6.2,
     &       F6.1,I6,F6.1,F6.2,F6.2)')
     &       STGDOY(L),DOM,MONTH,
     &       Dapcalc(stgdoy(L),plyear,plday),L,STNAME(L),
     &       NINT(CWADSTG(L)),LAISTG(L),LNUMSTG(L),
     &       NINT(CNADSTG(L)),CNCTMP,1.0-WFPAV(L),1.0-NFPAV(L)
          ENDIF
        ENDDO

        CALL CSCLEAR5

!     chp added 10/4/2005
      edap = Dapcalc(stgdoy(9),plyear,plday)
      edapm = Dapcalc(edatm,plyear,plday)
      adap = Dapcalc(adat,plyear,plday)
      adapm = Dapcalc(adatm,plyear,plday)
      mdap = Dapcalc(stgdoy(5),plyear,plday)
      mdapm = Dapcalc(mdatm,plyear,plday)


        WRITE (*,206)
        WRITE (*,305) MAX(-99,edap),MAX(-99,edapm),
     x   adap,adapm,
     x   mdap,mdapm,
     x   NINT(gwam),NINT(gwamm),
     x   gwum,gwummc,
     x   NINT(hnumam),NINT(hnumamm),
     x   hnumgm,hnumgmm,
     x   hiam,hiamm,
     x   laix,laixm,
     x   lnumsm,lnumsmm,
     x   NINT(tnumam),NINT(tnumamm),
     x   NINT(cwam),NINT(cwamm),
     x   NINT(vwam),NINT(vwamm),
     x   NINT(rwam),NINT(rwamm),
     x   NINT(carboac),NINT(carboacm),
     x   NINT(senwatc),NINT(senwatcm),
     x   NINT(rswam),NINT(rswamm),
     x   nuad,nuadm,
     x   sennatc,sennatcm,
     x   cnam,cnamm,
     x   rnam,rnamm,
     x   vnam,vnamm,
     x   gnam,gnamm,
     x   hinm,hinmm,
     x   gnpcm,gnpcmm,
     x   vnpcm,vnpcmm,
     x   NINT(cwaa),NINT(cwaam),
     x   vnaa,cnaam,
     x   lnpca,lnpcam
        CALL CSCLEAR5

      ENDIF

      ! END OF SCREEN WRITES FOR SENSITIVITY MODE

!-----------------------------------------------------------------------

      ! PLANT EVALUATION (MEASURED - SIMULATED COMPARISONS)

      WRITE (fnumwrk,*) 'Writing EVALUATION'

      EVHEADER = ' '
      FNAMETMP = ' '
      IF (VERSION.EQ.VERSIOND) THEN
        EVHEADER(1:12) = '*EVALUATION:'
        FNAMETMP(1:12) = 'EVALUATE.OUT'
      ELSE
        WRITE(EVHEADER,'(A7,F4.2,A1)') '*EVAL__',VERSION,':'
        WRITE(FNAMETMP,'(A4,A1,A1,A2,A4)')
     &   EVHEADER(2:5),'_',EVHEADER(8:8),EVHEADER(10:11),'.OUT'
      ENDIF
      IF (RUN.EQ.1 .AND. RUNI.EQ.1) THEN
       OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,STATUS = 'UNKNOWN')
       WRITE (FNUMTMP,'(A23)') '$(2004)PLANT EVALUATION'
       CLOSE(FNUMTMP)
       EVALOUT = 0
       EVHEADNM = 0
      ENDIF

      IF (EVHEADNM.LT.7) THEN
      IF (EXCODE.NE.EXCODEP.AND.EVALOUT.GT.1 .OR.
     &    RUN.EQ.1.AND.RUNI.EQ.1) THEN
       EVHEADNM = EVHEADNM + 1
       OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,ACCESS = 'APPEND')
       WRITE (FNUMTMP,*) ' '
       IF (EVHEADNM.LT.7) THEN
         WRITE (FNUMTMP,993) EVHEADER,EXCODE,ENAME(1:55)
  993    FORMAT (A12,A10,'  ',A55,/)
       ELSE
         WRITE (FNUMTMP,1995)
     &    EVHEADER, 'MANY??????','  REMAINING EXPERIMENTS'
 1995    FORMAT (A12,A10,A23,/)
       ENDIF
       WRITE (FNUMTMP,994)
  994  FORMAT ('@RUN',
     x  ' EXCODE    ',
     x  ' TN RN',
     x  ' CR',
     x  ' EDAPS EDAPM',
     x  ' JDAPS JDAPM',
     x  ' ADAPS ADAPM',
     x  ' MDAPS MDAPM',
     x  ' HWAHS HWAHM',
     x  ' HWUMS HWUMM',
     x  ' H#AMS H#AMM',
     x  ' H#GMS H#GMM',
     x  ' LAIXS LAIXM',
     x  ' L#SMS L#SMM',
     x  ' T#AMS T#AMM',
     x  ' CWAMS CWAMM',
     x  ' VWAMS VWAMM',
     x  ' HIAMS HIAMM',
     x  ' GN%MS GN%MM',
     x  ' CNAMS CNAMM',
     x  ' GNAMS GNAMM',
     x  ' DRIDS DRIDM',
     x  ' TSPDS TSPDM')
       CLOSE(FNUMTMP)
      ENDIF
      ENDIF

      IF (EXCODE.NE.EXCODEP) EVALOUT = 0

      EVALOUT = EVALOUT + 1

      OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,ACCESS = 'APPEND')

      WRITE (FNUMTMP,8404) RUN,EXCODE,TN,RN,CR,
     x Dapcalc(stgdoy(9),plyear,plday),Dapcalc(edatm,plyear,plday),
     x Dapcalc(jdat,plyear,plday),Dapcalc(jdatm,plyear,plday),
     x Dapcalc(adat,plyear,plday),Dapcalc(adatm,plyear,plday),
     x Dapcalc(stgdoy(5),plyear,plday),Dapcalc(mdatm,plyear,plday),
     x NINT(gwam),NINT(gwamm),
     x gwum,gwummc,
     x NINT(hnumam),NINT(hnumamm),
     x hnumgm,hnumgmm,
     x laix,laixm,
     x lnumsm,lnumsmm,
     x NINT(tnumam),NINT(tnumamm),
     x NINT(cwam),NINT(cwamm),
     x NINT(vwam),NINT(vwamm),
     x hiam*100.0,AMAX1(-99.0,hiamm*100.0),
     x gnpcm,gnpcmm,
     x NINT(cnam),NINT(cnamm),
     x NINT(gnam),NINT(gnamm),
     x Dapcalc(drdat,plyear,plday),Dapcalc(drdatm,plyear,plday),
     x Dapcalc(tsdat,plyear,plday),Dapcalc(tsdatm,plyear,plday)

 8404  FORMAT (I4,1X,A10,I3,I3,1X,A2,
     x I6,I6,
     x I6,I6,
     x I6,I6,
     x I6,I6,
     x I6,I6,
     x 1X,F5.3,A6,
     x I6,I6,
     x F6.1,F6.1,
     x F6.1,F6.1,
     x F6.1,F6.1,
     x I6,I6,
     x I6,I6,
     x I6,I6,
     x F6.1,F6.1,
     x F6.1,F6.1,
     x I6,I6,
     x I6,I6,
     x I6,I6,
     x I6,I6)

       Close(FNUMTMP)       ! END OF PLANT EVALUATION

!-----------------------------------------------------------------------

      ! PLANT OVERVIEW

      WRITE (fnumwrk,*) 'Writing OVERVIEW'

      FNAMETMP = ' '
      FNAMETMP(1:12) = 'OVERVIEW.'//OUT

      INQUIRE (FILE = 'HEADER.OUT', EXIST = FEXIST)
      IF (FILEIOT(1:2).NE.'DS') THEN
        OPEN (UNIT=FNUMTMP, FILE='HEADER.OUT', STATUS = 'UNKNOWN')
        CLOSE (UNIT=FNUMTMP, STATUS = 'DELETE')
        INQUIRE (FILE = 'HEADER.OUT', EXIST = FEXIST)
      ENDIF
      IF (FEXIST) THEN
        OPEN (UNIT=FNUMTMP, FILE='HEADER.OUT', STATUS = 'UNKNOWN')
        L = 0
        DO WHILE (istat.eq.0)
          L = L + 1
          READ(FNUMTMP,'(A80)', iostat=istat)OVLINE(L)
          IF (TVILENT(OVLINE(L)).LT.5) THEN
            BLANKS = BLANKS + 1
          ELSE
            BLANKS = 0
          ENDIF
          IF (BLANKS.GT.2) THEN
            L = L - 3
            EXIT
          ENDIF
          IF (L.EQ.60) EXIT
        ENDDO
        CLOSE (FNUMTMP)
        IF (RUN.EQ.1 .AND. RUNI.EQ.1) THEN
          OPEN (UNIT = FNUMTMP, FILE = FNAMETMP)
          WRITE(FNUMTMP,'("*SIMULATION OVERVIEW FILE")')
        ELSE
          INQUIRE (FILE = FNAMETMP, EXIST = FEXIST)
          IF (FEXIST) THEN
            OPEN (UNIT = FNUMTMP, FILE = FNAMETMP, STATUS = 'OLD',
     &      ACCESS = 'APPEND')
          ELSE
            OPEN (UNIT = FNUMTMP, FILE = FNAMETMP, STATUS = 'NEW')
            WRITE(FNUMTMP,'("*SIMULATION OVERVIEW FILE")')
          ENDIF
        ENDIF
        WRITE (FNUMTMP,*) ' '
        DO L1 = 1,L
          WRITE (FNUMTMP,'(A80)') OVLINE(L1)
        ENDDO
      ELSE
        IF (RUN.EQ.1 .AND. RUNI.EQ.1) THEN
          OPEN (UNIT = FNUMTMP, FILE = FNAMETMP)
          WRITE (FNUMTMP,'(A15)') '$(2004)OVERVIEW'
        ELSE
          OPEN (UNIT = FNUMTMP, FILE = FNAMETMP, ACCESS = 'APPEND')
        ENDIF

        WRITE (FNUMTMP,'(/,A70,/)') OUTHED
        WRITE (FNUMTMP,103) MODEL
  103   FORMAT (' MODEL            ',A8)
        WRITE (FNUMTMP,1031) MODULE
 1031   FORMAT (' MODULE           ',A8)
        WRITE (FNUMTMP,1032) FILENEW
 1032   FORMAT (' FILE             ',A12)
        WRITE (FNUMTMP,104)
     &   EXCODE(1:8),' ',EXCODE(9:10),'  ',ENAME(1:47)
  104   FORMAT (' EXPERIMENT       ',A8,A1,A2,A2,A47)
        WRITE (FNUMTMP,102) TN, TNAME
  102   FORMAT (' TREATMENT',I3,'     ',A25)
        WRITE (FNUMTMP,107) CR,VARNO,VRNAME
  107   FORMAT (' GENOTYPE         ',A2,A6,'  ',A16)
        CALL Calendar (plyear,plday,dom,month)
        WRITE (FNUMTMP,108)month,dom,NINT(pltpop),NINT(rowspc)
  108   FORMAT (' ESTABLISHMENT    ',A3,I3,2X,I4,' plants/m2 in ',
     &  I3,' cm rows')
        WRITE (fnumtmp,109) tmaxx,tminn,NINT(co2max)
  109   FORMAT (' ENVIRONMENT      ','Tmax (max): ',F4.1,
     &   '  Tmin (min): ',F5.1,
     &   '  Co2 (max):',I4)
        WRITE (fnumtmp,110) iswwat, iswnit
  110   FORMAT (' MODEL SWITCHES   ','Water: ',A1,
     &   '  Nitrogen: ',A1)
      ENDIF

      ! Below is for possible incorporation ... but need coefficients!
      ! CULTIVAR DETAILS
      !  P1V     Vernalization requirement (days)
      !  P1D     Photoperiod sensitivity (%/10h)
      !  P5      Grain filling duration (oC.d)
      !  G1      Kernel set at anthesis (#/g)
      !  G2      Standard kernel size (mg)
      !  G3      Standard tiller weight at maturity (g)
      !  PHINT   Phylochron interval (oC.d)
      !  ECOTYPE

      edap = Dapcalc(stgdoy(9),plyear,plday)
      edapm = Dapcalc(edatm,plyear,plday)
      adap = Dapcalc(adat,plyear,plday)
      adapm = Dapcalc(adatm,plyear,plday)
      mdap = Dapcalc(stgdoy(5),plyear,plday)
      mdapm = Dapcalc(mdatm,plyear,plday)

      WRITE(fnumtmp,*) ' '
      WRITE(fnumtmp,9600)
 9600 FORMAT('   DATE  DOM MON DAP STAGE........ CWAD'
     X,'  LAID  LNUM  CNAD  CN%D WSPAV NSPAV')
      DO L = 7, 9
         CALL CSYR_DOY(STGDOY(L),YEAR,DOY)
         CALL Calendar(year,doy,dom,month)
         CNCTMP = 0.0
         IF (CWADSTG(L).GT.0.0) CNCTMP = CNADSTG(L)/CWADSTG(L)*100
         WRITE (fnumtmp,'(I8,I4,1X,A3,I4,1X,I1,1X,A10,I6,F6.2,
     &    F6.1,I6,F6.1,F6.2,F6.2)')
     &    STGDOY(L),DOM,MONTH,
     &    Dapcalc(stgdoy(L),plyear,plday),L,STNAME(L),
     &    NINT(CWADSTG(L)),LAISTG(L),LNUMSTG(L),
     &    NINT(CNADSTG(L)),CNCTMP,1.0-WFPAV(L),1.0-NFPAV(L)
      ENDDO
      DO L = 1, 6
        CALL CSYR_DOY(STGDOY(L),YEAR,DOY)
        CALL Calendar(year,doy,dom,month)
        CNCTMP = 0.0
        IF (CWADSTG(L).GT.0.0) CNCTMP = CNADSTG(L)/CWADSTG(L)*100
        IF (STGDOY(L).GT.0) THEN
          WRITE (fnumtmp,'(I8,I4,1X,A3,I4,1X,I1,1X,A10,I6,F6.2,
     &     F6.1,I6,F6.1,F6.2,F6.2)')
     &     STGDOY(L),DOM,MONTH,
     &     Dapcalc(stgdoy(L),plyear,plday),L,STNAME(L),
     &     NINT(CWADSTG(L)),LAISTG(L),LNUMSTG(L),
     &     NINT(CNADSTG(L)),CNCTMP,1.0-WFPAV(L),1.0-NFPAV(L)
        ENDIF
      ENDDO
      IF (RUN.EQ.1 .AND. RUNI.EQ.1) THEN
        WRITE(fnumtmp,*)' '
        WRITE(fnumtmp,*)'CWAD  = Canopy wt (kg dm/ha)'
        WRITE(fnumtmp,*)'CNAD  = Canopy N (kg/ha)'
        WRITE(fnumtmp,*)'CN%D  = Canopy N concentration (%)'
        WRITE(fnumtmp,*)'LAID  = Leaf area index (m2/m2)'
        WRITE(fnumtmp,*)'LNUM  = Leaf number (Haun stage)'
        WRITE(fnumtmp,*)
     &   'NSPAV = N stress,photosynthesis,average (0-1,0=none)'
        WRITE(fnumtmp,*)
     &   'WSPAV = H2o stress,photosynthesis,average (0-1,0=none)'
      ENDIF
      WRITE(fnumtmp,*)' '

      WRITE (FNUMTMP,206)
  206 Format ('      VARIABLE....................   PREDICTED     ME',
     x 'ASURED')
      WRITE (FNUMTMP,305) MAX(-99,edap),MAX(-99,edapm),
     x adap,adapm,
     x mdap,mdapm,
     x NINT(gwam),NINT(gwamm),
     x gwum,gwummc,
     x NINT(hnumam),NINT(hnumamm),
     x hnumgm,hnumgmm,
     x hiam,hiamm,
     x laix,laixm,
     x lnumsm,lnumsmm,
     x NINT(tnumam),NINT(tnumamm),
     x NINT(cwam),NINT(cwamm),
     x NINT(vwam),NINT(vwamm),
     x NINT(rwam),NINT(rwamm),
     x NINT(carboac),NINT(carboacm),
     x NINT(senwatc),NINT(senwatcm),
     x NINT(rswam),NINT(rswamm),
     x nuad,nuadm,
     x sennatc,sennatcm,
     x cnam,cnamm,
     x rnam,rnamm,
     x vnam,vnamm,
     x gnam,gnamm,
     x hinm,hinmm,
     x gnpcm,gnpcmm,
     x vnpcm,vnpcmm,
     x NINT(cwaa),NINT(cwaam),
     x vnaa,cnaam,
     x lnpca,lnpcam

  305 FORMAT (6X, 'Emergence (DAP)             ',4X,I7,  6X,I7,  /,
     x       6X, 'Anthesis (DAP)              ',4X,I7,  6X,I7,  /,
     x       6X, 'Maturity (DAP)              ',4X,I7,  6X,I7,  /,
     x       6X, 'Product wt (kg dm/ha;no loss)',3X,I7, 6X,I7,  /,
     x       6X, 'Product unit weight (g dm)  ',4X,F7.3,7X,A6,  /,
     x       6X, 'Product number (no/m2)      ',4X,I7,  6X,I7,  /,
     x       6X, 'Product number (no/group)   ',4X,F7.1,6X,F7.1,/,
     x       6X, 'Product harvest index (ratio)',3X,F7.2,6X,F7.2,/,
     x       6X, 'Maximum leaf area index     ',4X,F7.1,6X,F7.1,/,
     x       6X, 'Final leaf number (one axis)',4X,F7.1,6X,F7.1,/,
     x       6X, 'Final shoot number (#/m2)   ',4X,I7  ,6X,I7  ,/,
     x       6X, 'Canopy (tops) wt (kg dm/ha) ',4X,I7,  6X,I7,  /,
     x       6X, 'Vegetative wt (kg dm/ha)    ',4X,I7,  6X,I7,  /,
     x       6X, 'Root wt (kg dm/ha)          ',4X,I7,  6X,I7,  /,
     x       6X, 'Assimilate wt (kg dm/ha)    ',4X,I7,  6X,I7,  /,
     x       6X, 'Senesced wt (kg dm/ha)      ',4X,I7,  6X,I7,  /,
     x       6X, 'Reserves wt (kg dm/ha)      ',4X,I7,  6X,I7,  /,
     x       6X, 'N uptake (kg/ha)            ',4X,F7.1,6X,F7.1,/,
     x       6X, 'N senesced (kg/ha)          ',4X,F7.1,6X,F7.1,/,
     x       6X, 'Above-ground N (kg/ha)      ',4X,F7.1,6X,F7.1,/,
     x       6X, 'Root N (kg/ha)              ',4X,F7.1,6X,F7.1,/,
     x       6X, 'Vegetative N (kg/ha)        ',4X,F7.1,6X,F7.1,/,
     x       6X, 'Product N (kg/ha)           ',4X,F7.1,6X,F7.1,/,
     x       6X, 'Product N harvest index (ratio)',1X,F7.2,6X,F7.2,/,
     x       6X, 'Product N (%)               ',4X,F7.1,6X,F7.1,/,
     x       6X, 'Vegetative N (%)            ',4X,F7.1,6X,F7.1,/,
     x       6X, 'Leaf+stem wt,anthesis (kg dm/ha)',   I7,  6X,I7,/,
     x       6X, 'Leaf+stem N,anthesis (kg/ha)',4X,F7.1,6X,F7.1,/,
     x       6X, 'Leaf N,anthesis (%)         ',4X,F7.1,6X,F7.1)

      IF (run.EQ.1.AND.runi.EQ.1) THEN

        WRITE (FNUMTMP,'(/,A59,/,A59)')
     x    '  Seed N must be added to N uptake to obtain a             ',
     x    '  balance with N in above-ground plus root material        '
        WRITE (FNUMTMP,'(/,16(A59,/))')
     x    '  Measured data are obtained from the A file,either        ',
     x    '  directly or by calculation from other other variables    ',
     x    '  using the expressions given below:                       ',
     x    '                                                           ',
     x    '  Product wt       Harvest wt (HWAH) / (Harvest%/100) (HPC)',
     x    '  Canopy wt        Grain wt (HWAM) + vegetative wt (VWAM)  ',
     x    '  Vegetative wt    Canopy wt (CWAM) - grain wt (HWAM)      ',
     x    '    = leaf+stem+retained dead material                     ',
     x    '  Product unit wt  Grain yield (HWAM)/grain number (G#AM)  ',
     x    '  Product #/area   Product#/tiller (H#SM) *                ',
     x    '                                    tiller number (T#AM)   ',
     x    '  Product #/group  Product#/area (H#AM) /                  ',
     x    '                                tiller number (T#AM)       ',
     x    '  Harvest index    Product wt (HWAM)/Canopy wt.(CWAM)      ',
     x    '                                                           ',
     x    '  The same procedure is followed for nitrogen aspects      '
      ENDIF

      CLOSE(FNUMTMP)      ! END OF PLANT OVERVIEW

!-----------------------------------------------------------------------

      IF (IDETL.NE.'Y') GO TO 8888

!-----------------------------------------------------------------------

      ! METADATA WRITES

      IF (FILEIOT(1:2).EQ.'XF' .AND. CN.EQ.1) THEN
        FNAMETMP = ' '
        LENFILEI = LEN(TRIM(FILEIO))
        IF (LENFILEI.GT.12) THEN
          FNAMETMP(1:12) = FILEIO(LENFILEI-11:lenfilei-1)//'M'
        ELSE
          FNAMETMP(1:12) = FILEIO(1:11)//'M'
        ENDIF
        INQUIRE (FILE = FNAMETMP,EXIST = FEXIST)
        IF (.not.FEXIST) THEN
          OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,STATUS = 'UNKNOWN',
     &        ACCESS = 'APPEND')
        ELSE
          OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,ACCESS='APPEND')
        ENDIF
        WRITE (FNUMTMP,*)' '
        WRITE (FNUMTMP,'(A24)')'*GENOTYPE               '
        WRITE (FNUMTMP,'(A26)')'@  VAR   CODE,FILE        '
        WRITE (FNUMTMP,'(A6,3X,A6)')
     &   ' CCODE',VARNO
        WRITE (FNUMTMP,'(A6,3X,A60)')
     &   ' CFILE',CUDIRFLE(1:60)
        WRITE (FNUMTMP,'(A6,3X,A64)')
     &   ' EFILE',ECDIRFLE
        WRITE (FNUMTMP,'(A6,3X,A64)')
     &   ' SFILE',SPDIRFLE
        WRITE (FNUMTMP,*)' '
        WRITE (FNUMTMP,'(A24)')'*CONDITIONS             '
        WRITE (FNUMTMP,'(A26)')'@  VAR   VALUE DESCRIPTION'
        XWTDP = -99.0
        WRITE (FNUMTMP,'(A6,F8.1,A40)')
     &   ' XRAIN',RAINC,' Rainfall total (mm)                    '
        WRITE (FNUMTMP,'(A6,F8.1,A39)')
     &   ' XRAIA',RAINCA,' Rainfall before anthesis (mm)         '
        WRITE (FNUMTMP,'(A6,F8.1,A40)')
     &   ' XWTDP',XWTDP,' Lowest water table depth (cm)          '
        WRITE (FNUMTMP,'(A6,I8,A34)')
     &   ' XSRAD',NINT(SRADC),' Radiation total (MJ/m2)          '
        WRITE (FNUMTMP,'(A6,F8.1,A40)')
     &   ' XTMAX',TMAXX,' Maximum temperature recorded (oC)      '
        WRITE (FNUMTMP,'(A6,F8.1,A40)')
     &   ' XTMIN',TMINN,' Minimum temperature recorded (oC)      '
        WRITE (FNUMTMP,'(A6,F8.1,A40)')
     &   ' XTMXN',TMAXM,' Maximum temperature,monthly av (oC)    '
        WRITE (FNUMTMP,'(A6,F8.1,A40)')
     &   ' XTMNM',TMINM,' Minimum temperature,monthly av (oC)    '
        WRITE (FNUMTMP,*)' '
        PREW = (-0.33+0.0021*RAINC)*10000.0
        PRER = SRADC*1.5*10.0
        PREO = AMIN1(PRER,PREW)
        WRITE (FNUMTMP,'(A24)')'*PRODUCTION ESTIMATES   '
        WRITE (FNUMTMP,'(A26)')'@  VAR   VALUE DESCRIPTION'
        WRITE (FNUMTMP,'(A6,F8.1,A40)')
     &   ' PRER ',PRER,' Production possible from radn (kg/ha)  '
        WRITE (FNUMTMP,'(A6,F8.1,A40)')
     &   ' PREW ',PREW,' Production possible from rain (kg/ha)  '
        WRITE (FNUMTMP,'(A6,F8.1,A40)')
     &   ' PREO ',PREO,' Production possible overall (kg/ha)    '
        CLOSE(FNUMTMP)
      ENDIF

      ! END OF METADATA

!-----------------------------------------------------------------------

      IF (IDETG.EQ.'Y'.AND.FILEIOT(1:2).EQ.'XF') THEN

        ! T-FILE READS AND MEASURED.OUT WRITES

        WRITE (fnumwrk,*) 'Writing MEASURED.OUT'

        FNAMETMP = ' '
        FNAMETMP(1:12) = 'MEASURED.'//OUT
        IF (RUN.EQ.1 .AND. RUNI.EQ.1) THEN
         CALL Getlun ('FILET',FNUMT)
         OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,STATUS = 'UNKNOWN')
         WRITE (FNUMTMP,'(A32)') '$(2004)MEASURED TIME-COURSE DATA'
         CLOSE(FNUMTMP)
        ENDIF

        STARNUMO = STARNUMO + 1  ! Number of datasets in sim output file

        CALL LTRIM2 (FILEIO,filenew)
        FILELEN = TVILENT(FILENEW)
        FILET=FILENEW(1:FILELEN-12)//EXCODE(1:8)//'.'//EXCODE(9:10)//'T'
        FEXISTT  = .FALSE.
        INQUIRE (FILE = FILET,EXIST = FEXISTT)

        CFLTFILE = 'N'
        LAIXT = -99.0
        VALUER = -99.0

        IF (.not.FEXISTT) THEN

          WRITE (fnumwrk,*) 'T-file not found!'

        ELSE

          TLINENUM = 0
          OPEN (UNIT = FNUMT,FILE = FILET)
          OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,ACCESS = 'APPEND')
          COLNUM = 1
          L1 = 0
          DO
            READ(FNUMT,'(A180)',END = 5555)LINET
            TLINENUM = TLINENUM + 1  ! Only used to check if file empty
            IF (LINET(1:5).EQ.'*FLAG' .OR. LINET(1:5).EQ.'*CODE' .OR.
     &          LINET(1:5).EQ.'*GENE') THEN
              DO
                READ(FNUMT,'(A180)',END = 5555)LINET
                IF (LINET(1:1).EQ.'*') THEN
                  IF (LINET(1:7).EQ.'*DATA(T') EXIT
                  IF (LINET(1:7).EQ.'*EXP.DA') EXIT
                  IF (LINET(1:7).EQ.'*EXP. D') EXIT
                  IF (LINET(1:7).EQ.'*AVERAG') EXIT
                  IF (LINET(1:7).EQ.'*TIME_C') EXIT
                ENDIF
              ENDDO
            ENDIF
            L1 = 0
            L2 = 0
            IF (LINET(1:7).EQ.'*DATA(T' .OR.
     &       LINET(1:7).EQ.'*EXP.DA' .OR.
     &       LINET(1:7).EQ.'*EXP. D' .OR.
     &       LINET(1:7).EQ.'*TIME_C' .OR.
     &       LINET(1:7).EQ.'*AVERAG') THEN
              TNCHAR = TL10FROMI(TN)
              LENLINE = LEN(TRIM(LINET))
              IF(LINET(1:7).EQ.'*EXP.DA'.OR.LINET(1:7).EQ.'*EXP. D')THEN
                GROUP = 'A'
                DO L = 1,30
                  IF (LINET(L:L+1).EQ.': ') L1 = L+2
                  IF (LINET(L:L).EQ.':' .AND. LINET(L+1:L+1).NE.' ')
     &              L1 = L+1
                  IF (L1.GT.0.AND.L.GT.L1+9.AND.LINET(L:L).NE.' ') THEN
                    L2 = L    ! Start of group information in t-file
                    EXIT
                  ENDIF
                ENDDO
                CALL LTRIM (TNAME)
                LENTNAME = MIN(15,LEN(TRIM(TNAME)))
                LENGROUP = MIN(L2+14,LENLINE)
                IF (LEN(TRIM(TNCHAR)).EQ.1) THEN
                  LINESTAR = '*DATA(T):'//LINET(L1:L1+9)//
     &            ' '//TNCHAR(1:1)//' C'//CNCHAR2//TNAME(1:LENTNAME)//
     &            ' '//LINET(L2:LENGROUP)
                ELSEIF (LEN(TRIM(TNCHAR)).EQ.2) THEN
                  LINESTAR = '*DATA(T):'//LINET(L1:L1+9)//
     &            ' '//TNCHAR(1:2)//' C'//CNCHAR2//TNAME(1:LENTNAME)//
     &            ' '//LINET(L2:LENGROUP)
                ELSEIF (LEN(TRIM(TNCHAR)).EQ.3) THEN
                  LINESTAR = '*DATA(T):'//LINET(L1:L1+9)//
     &            ' '//TNCHAR(1:3)//' C'//CNCHAR2//TNAME(1:LENTNAME)//
     &            ' '//LINET(L2:LENGROUP)
                ENDIF
              ENDIF
              IF (LINET(1:7).EQ.'*DATA(T') THEN
                GROUP = 'D'
                DO L = 1,30
                  IF (LINET(L:L).EQ.' ') L1 = L-1
                  IF (L1.NE.0 .AND. LINET(L:L).NE.' ') THEN
                    L2 = L    ! Start of group information in t-file
                    EXIT
                  ENDIF
                ENDDO
                CALL LTRIM (TNAME)
                LENTNAME = MIN(15,LEN(TRIM(TNAME)))
                LENGROUP = MIN(L2+14,LENLINE)
                IF (LEN(TRIM(TNCHAR)).EQ.1) THEN
                  LINESTAR = LINET(1:L1)//' TN:'//
     &            TNCHAR(1:1)//' C'//CNCHAR2//TNAME(1:LENTNAME)//
     &            ' '//LINET(L2:LENGROUP)
                ELSEIF (LEN(TRIM(TNCHAR)).EQ.2) THEN
                  LINESTAR = LINET(1:L1)//' TN:'//
     &            TNCHAR(1:2)//' C'//CNCHAR2//TNAME(1:LENTNAME)//
     &            ' '//LINET(L2:LENGROUP)
                ELSEIF (LEN(TRIM(TNCHAR)).EQ.3) THEN
                  LINESTAR = LINET(1:L1)//' TN:'//
     &            TNCHAR(1:3)//' C'//CNCHAR2//TNAME(1:LENTNAME)//
     &            ' '//LINET(L2:LENGROUP)
                ENDIF
              ENDIF
              IF (LINET(1:7).EQ.'*AVERAG' .OR.
     &            LINET(1:7).EQ.'*TIME_C') THEN
                GROUP = 'A'
                DO L = 1,30
                  IF (LINET(L:L).EQ.' ') L1 = L-1
                  IF (L1.NE.0 .AND. LINET(L:L).NE.' ') THEN
                    L2 = L    ! Start of group information in t-file
                    EXIT
                  ENDIF
                ENDDO
                CALL LTRIM (TNAME)
                LENTNAME = MIN(15,LEN(TRIM(TNAME)))
                LENGROUP = MIN(L2+14,LENLINE)
                IF (LEN(TRIM(TNCHAR)).EQ.1) THEN
                  LINESTAR = LINET(1:L1)//' TN:'//
     &            TNCHAR(1:1)//' C'//CNCHAR2//TNAME(1:LENTNAME)//
     &            ' '//LINET(L2:LENGROUP)
                ELSEIF (LEN(TRIM(TNCHAR)).EQ.2) THEN
                  LINESTAR = LINET(1:L1)//' TN:'//
     &            TNCHAR(1:2)//' C'//CNCHAR2//TNAME(1:LENTNAME)//
     &            ' '//LINET(L2:LENGROUP)
                ELSEIF (LEN(TRIM(TNCHAR)).EQ.3) THEN
                  LINESTAR = LINET(1:L1)//' TN:'//
     &            TNCHAR(1:3)//' C'//CNCHAR2//TNAME(1:LENTNAME)//
     &            ' '//LINET(L2:LENGROUP)
                ENDIF
              ENDIF
            ELSEIF (LINET(1:1).EQ.'@') THEN
              DATECOL = Tvicolnm(linet,'DATE')
              YEARCOL = Tvicolnm(linet,'YEAR')
              DOYCOL = Tvicolnm(linet,'DOY')
              IF (DOYCOL.LE.0) DOYCOL = Tvicolnm(linet,'DAY')
              LENLINE = LEN(TRIM(LINET))
              LINET(LENLINE+1:LENLINE+12) = '   DAP   DAS'
              LINET(1:1) = '@'
              WRITE (FNUMTMP,*) ' '
              WRITE (FNUMTMP,'(A80)') LINESTAR(1:80)
              WRITE (FNUMTMP,*) ' '
              WRITE (FNUMTMP,'(A180)') LINET(1:180)
              STARNUMM = STARNUMM + 1              ! Number of datasets
              CFLTFILE = 'Y'
            ELSE
              CALL Getstri (LINET,COLNUM,VALUEI)
              IF (VALUEI.EQ.TN) THEN
                IF (DATECOL.GT.0.OR.DOYCOL.GT.0) THEN
                  IF (DATECOL.GT.0) THEN
                    CALL Getstri (LINET,DATECOL,DATE)
                  ELSEIF (DATECOL.LE.0) THEN
                    CALL Getstri (LINET,DOYCOL,DOY)
                    CALL Getstri (LINET,YEARCOL,YEAR)
                    IF (YEAR.GT.2000) YEAR = YEAR-2000
                    IF (YEAR.GT.1900) YEAR = YEAR-1900
                    DATE = YEAR*1000+DOY
                  ENDIF
                  DAP = MAX(0,CSTIMDIF(YEARPLT,DATE))
                  DAS = MAX(0,CSTIMDIF(YEARSIM,DATE))
                  DAPCHAR = TL10FROMI(DAP)
                  IF (LEN(TRIM(DAPCHAR)).EQ.1) THEN
                    DAPWRITE = '     '//DAPCHAR(1:1)
                  ELSEIF (LEN(TRIM(DAPCHAR)).EQ.2) THEN
                    DAPWRITE = '    '//DAPCHAR(1:2)
                  ELSEIF (LEN(TRIM(DAPCHAR)).EQ.3) THEN
                    DAPWRITE = '   '//DAPCHAR(1:3)
                  ENDIF
                  LENLINE = LEN(TRIM(LINET))
                  LINET(LENLINE+1:LENLINE+6) = DAPWRITE(1:6)
                  DAPCHAR = TL10FROMI(DAS)
                  IF (LEN(TRIM(DAPCHAR)).EQ.1) THEN
                    DAPWRITE = '     '//DAPCHAR(1:1)
                  ELSEIF (LEN(TRIM(DAPCHAR)).EQ.2) THEN
                    DAPWRITE = '    '//DAPCHAR(1:2)
                  ELSEIF (LEN(TRIM(DAPCHAR)).EQ.3) THEN
                    DAPWRITE = '   '//DAPCHAR(1:3)
                  ENDIF
                  LENLINE = LEN(TRIM(LINET))
                  LINET(LENLINE+1:LENLINE+6) = DAPWRITE(1:6)
                ENDIF
                WRITE (FNUMTMP,'(A180)') LINET
              ENDIF
            ENDIF
          ENDDO
 5555     CONTINUE
          ! If T-file was empty
          IF (TLINENUM.LT.4) THEN
            WRITE (fnumwrk,*) 'T-file was empty!'
          ENDIF
        ENDIF

        CLOSE(FNUMT)
        CLOSE(FNUMTMP)

      ENDIF              ! END OF T-FILE READS AND MEASURED.OUT WRITES

!-----------------------------------------------------------------------

      ! PLANT RESPONSES (SIMULATED)

      WRITE (fnumwrk,*) 'Writing PLANT RESPONSES (SIMULATED)'

      ! NOTE This does not deal with a set of ON/OFF days
      CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'EDAY',dayadj)
      CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'ERAD',radadj)
      CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'EMAX',txadj)
      CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'EMIN',tmadj)
      CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'ERAIN',prcadj)
      CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'ECO2',co2adj)
      CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'EDEW',dptadj)
      CALL XREADR (FILEIO,TN,RN,SN,ON,CN,'EWIND',wndadj)

      IF (DAYADJ.LT.0.0) DAYADJ = 0.0
      IF (RADADJ.LT.0.0) RADADJ = 0.0
      IF (TXADJ.LT.0.0) TXADJ = 0.0
      IF (TMADJ.LT.0.0) TMADJ = 0.0
      IF (PRCADJ.LT.0.0) PRCADJ = 0.0
      IF (CO2ADJ.LT.0.0) CO2ADJ = 0.0
      IF (DPTADJ.LT.0.0) DPTADJ = 0.0
      IF (WNDADJ.LT.0.0) WNDADJ = 0.0

      FNAMETMP = ' '
      FNAMETMP(1:12) = 'PLANTRES.'//OUT
      IF (RUN.EQ.1 .AND. RUNI.EQ.1) THEN
        OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,STATUS = 'UNKNOWN')
        WRITE (FNUMTMP,'(A34)') '$(2004)PLANT RESPONSES (SIMULATED)'
        CLOSE(FNUMTMP)
      ENDIF

      IF (EXCODE.NE.EXCODEP) AMTNITP = 0.0

      IF (EXCODE.NE.EXCODEP.OR.TNAME(1:1).EQ.'*'.OR.
     &  AMTNIT.LT.AMTNITP) THEN
        OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,ACCESS = 'APPEND')
        WRITE (FNUMTMP,*) ' '
        IF (TNAME(1:1).EQ.'*') THEN
          WRITE (FNUMTMP,9951) EXCODE,TNAME(2:25)
 9951     FORMAT ('*RESPONSES(S):',A10,'  ',A24,/)
        ELSEIF (AMTNIT.LT.AMTNITP) THEN
          WRITE (FNUMTMP,9951) EXCODE,TNAME(1:24)
        ELSE
          WRITE (FNUMTMP,995) EXCODE,ENAME(1:55)
  995     FORMAT ('*RESPONSES(S):',A10,'  ',A55,/)
        ENDIF
        PLDAYP = 0
        WRITE (FNUMTMP,97)
   97   FORMAT ('@  RUN',
     x  ' EXCODE     ',
     x  ' TN RN',
     x  '    CR',
     x  '  PDAY  EDAP',
     x  '  ADAP  JDAP  MDAP',
     x  '  NICM',
     x  '  GWAM  GWUM',
     x  '  H#AM  H#GM  LAIX  L#SM',
     x  '  CWAM  VWAM  HIAM  RWAM',
     x  '  GN%M  TNAM',
     x  '  CNAM  GNAM',
     x  '  HINM PLPOP',
     x  '  DLAJ  SRAJ  TXAJ  TNAJ  PRAJ  COAJ',
     x  '  DPAJ  WNAJ      ')
      ELSE
        OPEN (UNIT = FNUMTMP, FILE = FNAMETMP, ACCESS = 'APPEND')
      ENDIF

      IF (plday.LT.pldayp) THEN
        IF (varno.EQ.varnop) THEN
          pldayp = plday + 365
        ELSE
          pldayp = plday
        ENDIF
      ELSE
        pldayp = plday
      ENDIF
      varnop = varno

      WRITE (FNUMTMP,7401) RUN,EXCODE,TN,RN,CR,
     x PLDAYP,
     x Dapcalc(stgdoy(9),plyear,plday),
     x Dapcalc(adat,plyear,plday),
     x Dapcalc(jdat,plyear,plday),
     x Dapcalc(stgdoy(5),plyear,plday),
     x NINT(amtnit),
     x NINT(gwam),gwum,
     x NINT(hnumam),NINT(hnumgm),laix,lnumsm,
     x NINT(cwam),
     x NINT(vwam), hiam*100.0, NINT(rwam),
     x gnpcm,NINT(AMAX1(-99.0,cnam+rnam)),
     x NINT(cnam),NINT(gnam),
     x hinm,pltpop,
     & DAYADJ, RADADJ, TXADJ, TMADJ, PRCADJ, CO2ADJ,
     & DPTADJ, WNDADJ

 7401  FORMAT (I6,1X,A10,1X,I3,I3,4X,A2,
     x I6,
     x I6,I6,I6,I6,
     x I6,
     x I6,1X,F5.3,
     x I6,I6,F6.1,F6.1,
     x I6,
     x I6,F6.1,I6,
     x F6.1,I6,
     x I6,I6,
     x F6.2,F6.1,
     x 8F6.1)

      CLOSE(FNUMTMP)       ! END OF PLANT RESPONSES (SIMULATED)

!-----------------------------------------------------------------------

      ! PLANT RESPONSES (MEASURED)

      WRITE (fnumwrk,*) 'Writing PLANT RESPONSES (MEASURED)'

      FNAMETMP = ' '
      FNAMETMP(1:12) = 'PLANTREM.'//OUT
      IF (RUN.EQ.1 .AND. RUNI.EQ.1) THEN
       OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,STATUS = 'UNKNOWN')
       WRITE (FNUMTMP,'(A33)') '$(2004)PLANT RESPONSES (MEASURED)'
       CLOSE(FNUMTMP)
      ENDIF

      IF (EXCODE.NE.EXCODEP .OR.TNAME(1:1).EQ.'*'.OR.
     &  AMTNIT.LT.AMTNITP) THEN
        OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,ACCESS = 'APPEND')
        WRITE (FNUMTMP,*) ' '
        IF (TNAME(1:1).EQ.'*') THEN
          WRITE (FNUMTMP,992) EXCODE,TNAME(2:25)
  992     FORMAT ('*RESPONSES(M):',A10,'  ',A24,/)
        ELSEIF (AMTNIT.LT.AMTNITP) THEN
          WRITE (FNUMTMP,992) EXCODE,TNAME(1:24)
        ELSE
          WRITE (FNUMTMP,991) EXCODE,ENAME(1:55)
  991     FORMAT ('*RESPONSES(M):',A10,'  ',A55,/)
        ENDIF
        WRITE (FNUMTMP,97)
      ELSE
        OPEN (UNIT = FNUMTMP, FILE = FNAMETMP, ACCESS = 'APPEND')
      ENDIF

      IF (CNAMM.GT.0.0 .AND. RNAMM.GT.0.0) THEN
        tnamm = cnamm+rnamm
      ELSE
        tnamm = -99.0
      ENDIF

      WRITE (FNUMTMP,7402) RUN,EXCODE,TN,RN,CR,
     x PLDAYP,
     x Dapcalc(edatm,plyear,plday),
     x Dapcalc(adatm,plyear,plday),
     x Dapcalc(jdatm,plyear,plday),
     x Dapcalc(mdatm,plyear,plday),
     x NINT(amtnit),
     x NINT(gwamm),gwummc,
     x NINT(hnumamm),NINT(hnumgmm),laixm,lnumsmm,
     x NINT(cwamm),
     x NINT(vwamm), AMAX1(-99.0,hiamm*100.0), NINT(rwamm),
     x gnpcmm,NINT(tnamm),
     x NINT(cnamm),NINT(gnamm),
     x AMAX1(0.0,hinmm),pltpop,
     & DAYADJ, RADADJ, TXADJ, TMADJ, PRCADJ, CO2ADJ,
     & DPTADJ, WNDADJ

 7402  FORMAT (I6,1X,A10,1X,I3,I3,4X,A2,
     x I6,
     x I6,I6,I6,I6,
     x I6,
     x I6,A6,
     x I6,I6,F6.1,F6.1,
     x I6,
     x I6,F6.1,I6,
     x F6.1,I6,
     x I6,I6,
     x F6.2,F6.1,
     x 8F6.1)

      AMTNITP = AMTNIT

      CLOSE(FNUMTMP)       ! END OF PLANT RESPONSES (MEASURED)

!-----------------------------------------------------------------------

      IF (IDETOU.NE.'Y') GO TO 8888

!-----------------------------------------------------------------------

      ! PLANT ERRORS (A-file data)

      WRITE (fnumwrk,*) 'Writing PLANT ERRORS (A)'

      FNAMETMP = ' '
      FNAMETMP(1:12) = 'PLANTERA.'//OUT
      IF (RUN.EQ.1 .AND. RUNI.EQ.1) THEN
       OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,STATUS = 'UNKNOWN')
       WRITE (FNUMTMP,'(A27)') '$(2004)ERRORS (A-FILE DATA)'
       WRITE (FNUMTMP,501)
  501  FORMAT(/,
     & '! This file presents the differences between simulated and',/,
     & '! single-time measured values (eg.date of anthesis,yield) for'/,
     & '! individual runs. The abbreviations are based on those',/,
     & '! listed in the DATA.CDE file, with the simple abbreviation',/,
     & '! indicating the simulated value,the basic abbreviation plus',/,
     & '! a final E the error. The units for the latter are days for',/,
     & '! time differences (EDAP,ADAP,MDAP) and percentages of',/,
     & '! simulated values for the remainder.,'/,
     & ' ',/,
     & '! As usual, a -99 indicates that no data were available.')
       CLOSE(FNUMTMP)
      ENDIF

      IF (EXCODE.NE.EXCODEP) THEN
       OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,ACCESS = 'APPEND')
       WRITE (FNUMTMP,996) OUTHED(11:70)
  996  FORMAT (/,'*ERRORS(A):',A60,/)
       WRITE (FNUMTMP,896)
  896  FORMAT ('@  RUN',
     x ' EXCODE     ',
     x ' TN RN',
     x '    CR',
     x '  EDAP EDAPE',
     x '  ADAP ADAPE',
     x '  MDAP MDAPE',
     x '  HWAH HWAHE',
     x '  GWUM GWUME',
     x '  H#AM H#AME',
     x '  H#GM H#GME',
     x '  LAIX LAIXE',
     x '  L#SM L#SME',
     x '  S#AM S#AME',
     x '  CWAM CWAME',
     x '  VWAM VWAME',
     x '  HIAM HIAME',
     x '  GN%M GN%ME',
     x '  CNAM CNAME',
     x '  GNAM GNAME',
     x '            ',
     x '            ',
     x '            ',
     x '            ')
       CLOSE(FNUMTMP)
      ENDIF

      OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,ACCESS = 'APPEND')

      IF (edatm.GT.0) THEN
       emdaterr = Dapcalc(stgdoy(9),plyear,plday)-
     X Dapcalc(edatm,plyear,plday)
      ELSE
       emdaterr = -99
      Endif
      IF (adatm.GT.0) THEN
       adaterr = Dapcalc(adat,plyear,plday)-
     X Dapcalc(adatm,plyear,plday)
      ELSE
       adaterr = -99
      Endif
      IF (mdatm.GT.0) THEN
       mdaterr = Dapcalc(stgdoy(5),plyear,plday)-
     X Dapcalc(mdatm,plyear,plday)
      ELSE
       mdaterr = -99
      Endif
      IF (hwahm.GT.0 .AND. gwam.GT.0 .AND. hpc.GT.0) THEN
       hwaherr = 100.*(gwam*hpc/100.-hwahm)/(gwam*hpc/100.)
       IF (hwaherr.GT.99999.0) hwaherr = 99999.0
       IF (hwaherr.LT.-9999.0) hwaherr = -9999.0
      ELSE
       hwaherr = -99
      ENDIF
      IF (gwumm.GT.0 .AND. gwum.GT.0) THEN
       gwumerr = 100.0*(gwum-gwumm)/gwum
      ELSE
       gwumerr = -99
      ENDIF
      IF (hnumamm.GT.0 .AND. hnumam.GT.0) THEN
       hnumaerr = 100.0*(hnumam-hnumamm)/(hnumam)
      ELSE
       hnumaerr = -99
      ENDIF
      IF (hnumgmm.GT.0 .AND. hnumgm.GT.0) THEN
       hnumgerr = 100.0*((hnumgm-hnumgmm)/hnumgm)
      ELSE
       hnumgerr = -99
      ENDIF
      IF (laixm.GT.0 .AND. laix.GT.0) THEN
       laixerr = 100.0*((laix-laixm)/laix)
      ELSE
       laixerr = -99
      ENDIF
      IF (lnumsmm.GT.0 .AND. lnumsm.GT.0) THEN
       lnumserr = 100.0*((lnumsm-lnumsmm)/lnumsm)
      ELSE
       lnumserr = -99
      ENDIF
      IF (tnumamm.GT.0 .AND. tnumam.GT.0) THEN
       tnumaerr = 100.0*((tnumam-tnumamm)/tnumam)
      ELSE
       tnumaerr = -99
      Endif
      IF (cwamm.GT.0 .AND. cwam.GT.0) THEN
       cwamerr = 100.0*(cwam-cwamm)/cwam
      ELSE
       cwamerr = -99
      Endif
      IF (vwamm.GT.0 .AND. vwam.GT.0) THEN
       vwamerr = 100.0*(vwam-vwamm)/vwam
      ELSE
       vwamerr = -99
      Endif
      IF (hiamm.GT.0 .AND. hiam.GT.0) THEN
       hiamerr = 100.0*(hiam-hiamm)/hiam
      ELSE
       hiamerr = -99
      Endif
      IF (gnpcmm.GT.0 .AND. gnpcm.GT.0) THEN
       gnpcmerr = 100.0*(gnpcm-gnpcmm)/gnpcm
      ELSE
       gnpcmerr = -99
      Endif
      IF (cnamm.GT.0 .AND. cnam.GT.0) THEN
       cnamerr = 100.0*(cnam-cnamm)/cnam
      ELSE
       cnamerr = -99
      Endif
      IF (gnamm.GT.0 .AND. gnam.GT.0) THEN
       gnamerr = 100.0*(gnam-gnamm)/gnam
      ELSE
       gnamerr = -99
      Endif

      WRITE (FNUMTMP,8401) RUN,EXCODE,TN,RN,CR,
     x Dapcalc(stgdoy(9),plyear,plday),emdaterr,
     x Dapcalc(adat,plyear,plday),adaterr,
     x Dapcalc(stgdoy(5),plyear,plday),mdaterr,
     x NINT(gwam),NINT(hwaherr),
     x gwum,NINT(gwumerr),
     x NINT(hnumam),NINT(hnumaerr),
     x hnumgm,NINT(hnumgerr),
     x laix,NINT(laixerr),
     x lnumsm,NINT(lnumserr),
     x NINT(tnumam),NINT(tnumaerr),
     x NINT(cwam),NINT(cwamerr),
     x NINT(vwam),NINT(vwamerr),
     x hiam,NINT(hiamerr),
     x gnpcm,NINT(gnpcmerr),
     x NINT(cnam),NINT(cnamerr),
     x NINT(gnam),NINT(gnamerr)

 8401 FORMAT (I6,1X,A10,1X,I3,I3,4X,A2,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x F6.3,I6,
     x I6,  I6,
     x F6.1,I6,
     x F6.1,I6,
     x F6.1,I6,
     x I6  ,I6,
     x I6,  I6,
     x I6,  I6,
     x F6.2,I6,
     x F6.1,I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6)

      CLOSE(FNUMTMP)       ! END OF PLANT ERRORS (A)

!-----------------------------------------------------------------------

      ! PLANT ERRORS SUMMARY (A-FILE DATA)

      WRITE (fnumwrk,*) 'Writing PLANT ERRORS SUMMARY (A)'

      IF (RUN.EQ.1 .AND. RUNI.EQ.1) THEN
        EMDATNUM  = 0
        ADATNUM   = 0
        MDATNUM   = 0
        HWAHNUM   = 0
        GWUMNUM   = 0
        HNUMANUM  = 0
        HNUMGNUM  = 0
        LAIXNUM   = 0
        LNUMSNUM  = 0
        TNUMANUM  = 0
        CWAMNUM   = 0
        VWAMNUM   = 0
        HIAMNUM   = 0
        GNPCMNUM  = 0
        CNAMNUM   = 0
        GNAMNUM   = 0
        EMDATSUM  = 0
        ADATSUM   = 0
        MDATSUM   = 0
        HWAHSUM   = 0.0
        GWUMSUM   = 0.0
        HNUMASUM  = 0.0
        HNUMGSUM  = 0.0
        LAIXSUM   = 0.0
        LNUMSSUM  = 0.0
        TNUMASUM  = 0.0
        CWAMSUM   = 0.0
        VWAMSUM   = 0.0
        HIAMSUM   = 0.0
        GNPCMSUM  = 0.0
        CNAMSUM   = 0.0
        GNAMSUM   = 0.0
        EMDATSUA  = 0
        ADATSUA   = 0
        MDATSUA   = 0
        HWAHSUA   = 0.0
        GWUMSUA   = 0.0
        HNUMASUA  = 0.0
        HNUMGSUA  = 0.0
        LAIXSUA   = 0.0
        LNUMSSUA  = 0.0
        TNUMASUA  = 0.0
        CWAMSUA   = 0.0
        VWAMSUA   = 0.0
        HIAMSUA   = 0.0
        GNPCMSUA  = 0.0
        CNAMSUA   = 0.0
        GNAMSUA   = 0.0
        EMDATEAV  = -99
        ADATEAV   = -99
        MDATEAV   = -99
        HWAHEAV   = -99.0
        GWUMEAV   = -99.0
        HNUMAEAV  = -99.0
        HNUMGEAV  = -99.0
        LAIXEAV   = -99.0
        LNUMSEAV  = -99.0
        TNUMAEAV  = -99.0
        CWAMEAV   = -99.0
        VWAMEAV   = -99.0
        HIAMEAV   = -99.0
        GNPCMEAV  = -99.0
        CNAMEAV   = -99.0
        GNAMEAV   = -99.0
        EMDATEAA  = -99
        ADATEAA   = -99
        MDATEAA   = -99
        HWAHEAA   = -99.0
        GWUMEAA   = -99.0
        HNUMAEAA  = -99.0
        HNUMGEAA  = -99.0
        LAIXEAA   = -99.0
        LNUMSEAA  = -99.0
        TNUMAEAA  = -99.0
        CWAMEAA   = -99.0
        VWAMEAA   = -99.0
        HIAMEAA   = -99.0
        GNPCMEAA  = -99.0
        CNAMEAA   = -99.0
        GNAMEAA   = -99.0
      ENDIF

      FNAMETMP = ' '
      FNAMETMP(1:12) = 'PLANTERS.'//OUT
      OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,STATUS = 'UNKNOWN')
      WRITE (FNUMTMP,'(A21)') '$(2004)ERRORS SUMMARY'
      WRITE (FNUMTMP,502)
  502 FORMAT(/,
     &'! This file summarizes the error differences reported in',/,
     &'! the files PLANTERA.OUT and PLANTERT.OUT. The errors in',/,
     &'! these files have been averaged taking actual values first,'/,
     &'! then the absolute value of the original errors. The number',/,
     &'! of runs used is indicated in the RUNS column.',/,
     &' ',/,
     &'! The abbreviations are based on those listed in the',/,
     &'! DATA.CDE file, with the abbreviation plus a final #',/,
     &'! indicating the number of values actually used for',/,
     &'! averaging, the basic abbreviation plus a final E the',/,
     &'! averaged error. The units for the latter are days for',/,
     &'! time differences (EDAP,ADAP,MDAP) and percentages of',/,
     &'! simulated values for the remainder.',/,
     &' ',/,
     &'! The major heading (the * line) includes codes for model',/,
     &'! and plant module. The batch column, as generated, is',/,
     &'! filled with a 1, and the batchcode with the code for',/,
     &'! the last experiment in the PLANTERA/T.OUT files. The',/,
     &'! entries in these columns can (and should) be changed if',/,
     &'! an overall summary file is constructed by combining files',/,
     &'! from different model and module runs.',/,
     &' ',/,
     &'! As usual, a -99 indicates that no data were available.')

       WRITE (FNUMTMP,*) ' '
       WRITE (FNUMTMP,1996) MODEL,MODULE
 1996  FORMAT ('*ERRORSUM(A):',A8,',',A8,/)
       WRITE (FNUMTMP,1896)
 1896  FORMAT ('@ RUNS BATCH',
     x ' BATCHCODE  ',
     x ' ERROR_TYPE ',
     x ' EDAP# EDAPE',
     x ' ADAP# ADAPE',
     x ' MDAP# MDAPE',
     x ' HWAH# HWAHE',
     x ' GWUM# GWUME',
     x ' H#AM# H#AME',
     x ' H#GM# H#GME',
     x ' LAIX# LAIXE',
     x ' L#SM# L#SME',
     x ' S#AM# S#AME',
     x ' CWAM# CWAME',
     x ' VWAM# VWAME',
     x ' HIAM# HIAME',
     x ' GN%M# GN%ME',
     x ' CNAM# CNAME',
     x ' GNAM# GNAME',
     x '            ',
     x '            ',
     x '            ',
     x '            ')

       IF (emdaterr.NE.-99) THEN
         emdatsua = emdatsua +  ABS(emdaterr)
         emdatsum = emdatsum +  emdaterr
         emdatnum = emdatnum +  1
         emdateaa = emdatsua/emdatnum
         emdateav = emdatsum/emdatnum
       ENDIF
       IF (adaterr.NE.-99) THEN
         adatsua = adatsua   + ABS(adaterr)
         adatsum = adatsum   + adaterr
         adatnum = adatnum   + 1
         adateaa = adatsua/adatnum
         adateav = adatsum/adatnum
       ENDIF
       IF (mdaterr.NE.-99) THEN
         mdatsua = mdatsua   + ABS(mdaterr)
         mdatsum = mdatsum   + mdaterr
         mdatnum = mdatnum   + 1
         mdateaa = mdatsua/mdatnum
         mdateav = mdatsum/mdatnum
       ENDIF
       IF (hwaherr.NE.-99) THEN
         hwahsua = hwahsua   + ABS(hwaherr)
         hwahsum = hwahsum   + ABS(hwaherr)
         hwahnum = hwahnum   + 1
         hwaheaa = hwahsua/hwahnum
         hwaheav = hwahsum/hwahnum
       ENDIF
       IF (gwumerr.NE.-99) THEN
         gwumsua = gwumsua   + ABS(gwumerr)
         gwumsum = gwumsum   + ABS(gwumerr)
         gwumnum = gwumnum   + 1
         gwumeaa = gwumsua/gwumnum
         gwumeav = gwumsum/gwumnum
       ENDIF
       IF (hnumaerr.NE.-99) THEN
         hnumasua = hnumasua + ABS(hnumaerr)
         hnumasum = hnumasum + hnumaerr
         hnumanum = hnumanum +  1
         hnumaeaa = hnumasua/hnumanum
         hnumaeav = hnumasum/hnumanum
       ENDIF
       IF (hnumgerr.NE.-99) THEN
         hnumgsua = hnumgsua +  ABS(hnumgerr)
         hnumgsum = hnumgsum +  hnumgerr
         hnumgnum = hnumgnum +  1
         hnumgeaa = hnumgsua/hnumgnum
         hnumgeav = hnumgsum/hnumgnum
       ENDIF
       IF (laixerr.NE.-99) THEN
         laixsua = laixsua +  ABS(laixerr)
         laixsum = laixsum +  laixerr
         laixnum = laixnum +  1
         laixeaa = laixsua/laixnum
         laixeav = laixsum/laixnum
       ENDIF
       IF (lnumserr.NE.-99) THEN
         lnumssua = lnumssua +  ABS(lnumserr)
         lnumssum = lnumssum +  lnumserr
         lnumsnum = lnumsnum +  1
         lnumseaa = lnumssua/lnumsnum
         lnumseav = lnumssum/lnumsnum
       ENDIF
       IF (tnumaerr.NE.-99) THEN
         tnumasua = tnumasua +  ABS(tnumaerr)
         tnumasum = tnumasum +  tnumaerr
         tnumanum = tnumanum +  1
         tnumaeaa = tnumasua/tnumanum
         tnumaeav = tnumasum/tnumanum
       ENDIF
       IF (cwamerr.NE.-99) THEN
         cwamsua = cwamsua   + ABS(cwamerr)
         cwamsum = cwamsum   + cwamerr
         cwamnum = cwamnum   + 1
         cwameaa = cwamsua/cwamnum
         cwameav = cwamsum/cwamnum
       ENDIF
       IF (vwamerr.NE.-99) THEN
         vwamsua = vwamsua   + ABS(vwamerr)
         vwamsum = vwamsum   + vwamerr
         vwamnum = vwamnum   + 1
         vwameaa = vwamsua/vwamnum
         vwameav = vwamsum/vwamnum
       ENDIF
       IF (hiamerr.NE.-99) THEN
         hiamsua = hiamsua   + ABS(hiamerr)
         hiamsum = hiamsum   + hiamerr
         hiamnum = hiamnum   + 1
         hiameaa = hiamsua/hiamnum
         hiameav = hiamsum/hiamnum
       ENDIF
       IF (gnpcmerr.NE.-99) THEN
         gnpcmsua = gnpcmsua +  ABS(gnpcmerr)
         gnpcmsum = gnpcmsum +  gnpcmerr
         gnpcmnum = gnpcmnum +  1
         gnpcmeaa = gnpcmsua/gnpcmnum
         gnpcmeav = gnpcmsum/gnpcmnum
       ENDIF
       IF (cnamerr.NE.-99) THEN
         cnamsua = cnamsua   + ABS(cnamerr)
         cnamsum = cnamsum   + cnamerr
         cnamnum = cnamnum   + 1
         cnameaa = cnamsua/cnamnum
         cnameav = cnamsum/cnamnum
       ENDIF
       IF (gnamerr.NE.-99) THEN
         gnamsua = gnamsua   + ABS(gnamerr)
         gnamsum = gnamsum   + gnamerr
         gnamnum = gnamnum   + 1
         gnameaa = gnamsua/gnamnum
         gnameav = gnamsum/gnamnum
       ENDIF

      WRITE (FNUMTMP,6401) RUN,'     1',EXCODE,'ACTUALS   ',
     x emdatnum,emdateav,
     x adatnum,adateav,
     x mdatnum,mdateav,
     x hwahnum,NINT(hwaheav),
     x gwumnum,NINT(gwumeav),
     x hnumanum,NINT(hnumaeav),
     x hnumgnum,NINT(hnumgeav),
     x laixnum,NINT(laixeav),
     x lnumsnum,NINT(lnumseav),
     x tnumanum,NINT(tnumaeav),
     x cwamnum,NINT(cwameav),
     x vwamnum,NINT(vwameav),
     x hiamnum,NINT(hiameav),
     x gnpcmnum,NINT(gnpcmeav),
     x cnamnum,NINT(cnameav),
     x gnamnum,NINT(gnameav)

      WRITE (FNUMTMP,6401) RUN,'     1',EXCODE,'ABSOLUTES ',
     x emdatnum,emdateaa,
     x adatnum,adateaa,
     x mdatnum,mdateaa,
     x hwahnum,NINT(hwaheaa),
     x gwumnum,NINT(gwumeaa),
     x hnumanum,NINT(hnumaeaa),
     x hnumgnum,NINT(hnumgeaa),
     x laixnum,NINT(laixeaa),
     x lnumsnum,NINT(lnumseaa),
     x tnumanum,NINT(tnumaeaa),
     x cwamnum,NINT(cwameaa),
     x vwamnum,NINT(vwameaa),
     x hiamnum,NINT(hiameaa),
     x gnpcmnum,NINT(gnpcmeaa),
     x cnamnum,NINT(cnameaa),
     x gnamnum,NINT(gnameaa)

 6401 FORMAT (I6,A6,1X,A10,2X,A10,1X,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6,
     x I6,  I6)

      CLOSE(FNUMTMP)       ! END OF PLANT ERRORS SUMMARY (A)

!-----------------------------------------------------------------------

      ! PLANT ERRORS (TIME-COURSE)

      IF (CFLTFILE.NE.'Y' .OR. FROP.GT.1) THEN

        WRITE (fnumwrk,*) 'Cannot write PLANT ERRORS (T)'
        IF (FROP.GT.1)WRITE (fnumwrk,*) 'Frequency of output > 1 day'
        IF (RUN.EQ.1 .AND. RUNI.EQ.1) CFLHEAD = 'Y'

      ELSE

        WRITE (fnumwrk,*) 'Writing PLANT ERRORS (T)'

        FNAMETMP = ' '
        FNAMETMP(1:12) = 'PLANTERT.'//OUT
        IF (RUN.EQ.1 .AND. RUNI.EQ.1 .OR. CFLHEAD.EQ.'Y') THEN
         CFLHEAD = 'N'
         OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,STATUS = 'UNKNOWN')
         WRITE (FNUMTMP,'(A27)') '$(2004)ERRORS (T-FILE DATA)'
         WRITE (FNUMTMP,1501)
 1501    FORMAT(/,
     &   '! This file summarizes the differences between simulated',/,
     &   '! and measured values for individual runs. Abbreviations',/,
     &   '! are based on those listed in the DATA.CDE file, but with',/,
     &   '! an E added to indicate error. The units for the errors',/,
     &   '! are % of simulated values (ie.100*[SIM-MEAS]/SIM).'/,
     &   ' ',/,
     &   '! A -99 indicates that no data were available. Here, this'/,
     &   '! could be simulated as well as measured data.')
         CLOSE(FNUMTMP)
        ENDIF

        INQUIRE (FILE = 'PlantGro.OUT',OPENED = fopen)
        IF (fopen) CLOSE (NOUTDG)

        STARNUM = 0
        OPEN (UNIT = FNUMT,FILE = 'MEASURED.OUT',STATUS = 'UNKNOWN')
        DO WHILE (TLINET(1:1).NE.'@')
          TLINET = ' '
          READ (FNUMT,1502,END=1600,ERR=1600) TLINET
 1502     FORMAT(A180)
          IF (TLINET(1:1).EQ.'*') STARNUM = STARNUM + 1
          IF (TLINET(1:1).EQ.'@') THEN
            IF (STARNUM.NE.STARNUMM) THEN
              TLINET = ' '
              READ (FNUMT,1502,END=1600,ERR=1600) TLINET
            ENDIF
          ENDIF
        ENDDO
        tlinet(1:1) = ' '
        STARNUM = 0

        OPEN (UNIT = NOUTDG,FILE = 'PlantGro.OUT',STATUS = 'UNKNOWN')

        DO WHILE (TLINEGRO(1:1).NE.'@')
          TLINEGRO = ' '
          READ (NOUTDG,'(A180)') TLINEGRO
          IF (TLINEGRO(1:4).EQ.'*RUN') STARNUM = STARNUM + 1
          IF (TLINEGRO(1:1).EQ.'@') THEN
            IF (STARNUM.NE.STARNUMO) THEN
              TLINEGRO = ' '
              READ (NOUTDG,'(A180)') TLINEGRO
            ENDIF
          ENDIF
        ENDDO
        tlinegro(1:1) = ' '

        ! Find headers from Measured file
        DO L = 1,20
          CALL Getstr(tlinet,l,thead(l))
          IF (THEAD(L)(1:3).EQ.'-99') EXIT
          IF (THEAD(L)(1:3).EQ.'DAP') tfdapcol = l
        ENDDO
        TFCOLNUM = L-1
        IF (TFCOLNUM.LE.0) THEN
          WRITE (FNUMWRK,*) 'No columns found in T-file!'
          GO TO 7777
        ENDIF

        ! Make new header line
        TLINETMP = ' '
        TLINETMP(1:1) = '@'
        DO L = 1, TFCOLNUM
          TLPOS = (L-1)*6+1
          IF (THEAD(L).EQ.'TRNO'.OR.THEAD(L).EQ.'YEAR'.OR.
     &      THEAD(L).EQ.'DATE') THEN
            TLINETMP(TLPOS+2:TLPOS+5)=THEAD(L)(1:4)
          ELSEIF(THEAD(L).EQ.'DOY'.OR.THEAD(L).EQ.'DAP' .OR.
     &      THEAD(L).EQ.'DAS'.OR.THEAD(L).EQ.'DAY') THEN
            TLINETMP(TLPOS+3:TLPOS+5)=THEAD(L)(1:3)
          ELSE
            WRITE (TCHAR,'(I6)') NINT(ERRORVAL*100.0)
            TLINETMP(TLPOS+1:TLPOS+4) = THEAD(L)(1:4)
            TLINETMP(TLPOS+5:TLPOS+5) = 'E'
          ENDIF
        ENDDO

        ! Find corresponding columns in PlantGro.OUT
        DO L = 1,TFCOLNUM
          pgrocol(l) = Tvicolnm(tlinegro,thead(l))
        ENDDO

        OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,ACCESS = 'APPEND')

         WRITE (FNUMTMP,2996) OUTHED(11:70)
 2996    FORMAT (/,'*ERRORS(T):',A60,/)
         tlinet(1:1) = '@'
         WRITE (FNUMTMP,'(A180)') TLINETMP

        ! Read data lines, match dates, calculate errors, write
        DO L1 = 1,200
          TLINET = ' '
          READ (FNUMT,7778,ERR=7777,END=7777) TLINET
 7778     FORMAT(A180)
          IF (TLINET(1:1).EQ.'*') GO TO 7777
          IF (TLINET(1:6).EQ.'      ') GO TO 7776
          CALL Getstrr(tlinet,tfdapcol,tfdap)
          IF (TFDAP.LE.0) THEN
            WRITE (FNUMWRK,*) 'DAP in T-file <= 0!'
            GO TO 7777
          ENDIF
          DO WHILE (tfdap.NE.pgdap)
            TLINEGRO = ' '
            READ (NOUTDG,7779,ERR=7777,END=7777) TLINEGRO
            CALL Getstrr(tlinegro,pgrocol(tfdapcol),pgdap)
            IF (PGDAP.LT.0) THEN
              WRITE (FNUMWRK,*) 'DAP in Plantgro file < 0!'
              GO TO 7777
            ENDIF
          ENDDO
 7779     FORMAT(A180)
          TLINETMP = ' '
          DO L = 1, TFCOLNUM
            CALL Getstrr(tlinet,l,tfval)
            CALL Getstrr(tlinegro,pgrocol(l),pgval)
            ERRORVAL = 0.0
            IF (TFVAL.GT.0.0 .AND. PGVAL.NE.-99 .AND.PGVAL.NE.0.0) THEN
              ERRORVAL = 100.0 * (PGVAL - TFVAL) / PGVAL
            ELSE
              ERRORVAL = -99.0
            ENDIF
            IF (THEAD(L).EQ.'TRNO'.OR.THEAD(L).EQ.'YEAR' .OR.
     &        THEAD(L).EQ.'DOY'.OR.THEAD(L).EQ.'DAP' .OR.
     &        THEAD(L).EQ.'DAY' .OR.
     &        THEAD(L).EQ.'DAS'.OR.THEAD(L).EQ.'DATE') THEN
              CALL Getstri(tlinet,l,tvi1)
              WRITE (TCHAR,'(I6)') TVI1
            ELSE
              WRITE (TCHAR,'(I6)') NINT(ERRORVAL)
            ENDIF
            TLPOS = (L-1)*6+1
            TLINETMP(TLPOS:TLPOS+5)=TCHAR
          ENDDO
          WRITE (FNUMTMP,'(A180)') TLINETMP
 7776     CONTINUE
        ENDDO

 7777   CONTINUE
        GO TO 1601

 1600   CONTINUE
        WRITE(fnumwrk,*)'End of file reading Measured.out'
        WRITE(fnumwrk,*)'Starnum and starnumm were: ',starnum,starnumm
 1601   CONTINUE

        CLOSE (FNUMTMP)       ! END OF PLANT ERRORS (TIME-COURSE)
        CLOSE (FNUMT)
        CLOSE (NOUTDG)
        IF (FOPEN) THEN
          OPEN (UNIT = NOUTDG,FILE = 'PlantGro.OUT',ACCESS = 'APPEND')
        ENDIF

      ENDIF

!-----------------------------------------------------------------------

      ! PLANT ERRORS SUMMARY (T-FILE DATA)

      IF (STARNUMM.GT.0) THEN

        WRITE (fnumwrk,*) 'Writing PLANT ERRORS SUMMARY (T) '

        OPEN (UNIT = FNUMTMP,FILE = 'PLANTERT.OUT',STATUS = 'UNKNOWN')

        DO L = 1,10
          TFLECOL(L) = 0
          TFLEVAL(L) = 0.0
          TFLEVAA(L) = 0.0
          TFLENUM(L) = 0.0
          TFLEAVE(L) = -99.0
          TFLEAVA(L) = -99.0
        ENDDO
        VALUERR = -99.0

        DO L = 1, 200
          TLINET = ' '
          READ (FNUMTMP,1552,END=1650,ERR=1650) TLINET
 1552     FORMAT(A180)
          IF (TLINET(1:1).NE.'!' .AND. TLINET(1:1).NE.'$') THEN
            IF (TLINET(1:1).EQ.'@') THEN
              !WRITE (fnumwrk,*) 'Found @-line '
              TFLECOL(1) = Tvicolnm(tlinet,'LAIDE')
              TFLECOL(2) = Tvicolnm(tlinet,'LWADE')
              TFLECOL(3) = Tvicolnm(tlinet,'CWADE')
              TFLECOL(4) = Tvicolnm(tlinet,'T#ADE')
              TFLECOL(5) = Tvicolnm(tlinet,'GWADE')
              TFLECOL(6) = Tvicolnm(tlinet,'SWADE')
              TLINET(1:1) = '@'
            ENDIF
            IF (TLINET(1:6).NE.'      ' .AND. TLINET(1:1).NE.'*' .AND.
     &        TLINET(1:1).NE.'@') THEN
              DO L1 = 1,6
                IF (TFLECOL(L1).GT.0) THEN
                  CALL Getstrr (TLINET,TFLECOL(L1),VALUERR)
                  IF (VALUERR.NE.-99) THEN
                    TFLEVAL(L1) = TFLEVAL(L1) + VALUERR
                    TFLEVAA(L1) = TFLEVAA(L1) + ABS(VALUERR)
                    TFLENUM(L1) = TFLENUM(L1) + 1.0
                    TFLEAVE(L1) = TFLEVAL(L1)/TFLENUM(L1)
                    TFLEAVA(L1) = TFLEVAA(L1)/TFLENUM(L1)
                    VALUERR = -99.0
                  ENDIF
                ENDIF
              ENDDO
            ENDIF
          ENDIF
        ENDDO

 1650   CONTINUE
 1651   CONTINUE

        CLOSE(FNUMTMP)

        FNAMETMP = ' '
        FNAMETMP(1:12) = 'PLANTERS.'//OUT
        OPEN (UNIT = FNUMTMP,FILE = FNAMETMP,ACCESS = 'APPEND')
        WRITE (FNUMTMP,*) ' '
        WRITE (FNUMTMP,1596) MODEL,MODULE
 1596   FORMAT ('*ERRORSUM(T):',A8,',',A8,/)
        WRITE (FNUMTMP,1496)
 1496   FORMAT ('@ RUNS BATCH',
     x  ' BATCHCODE  ',
     x  ' ERROR_TYPE ',
     x  ' LAID# LAIDE',
     x  ' LWAD# LWADE',
     x  ' CWAD# CWADE',
     x  ' T#AD# T#ADE',
     x  ' GWAD# GWADE',
     x  ' SWAD# SWADE')
        WRITE (FNUMTMP,6451) STARNUMM,'     1',EXCODE,'ACTUALS   ',
     x   NINT(TFLENUM(1)),NINT(TFLEAVE(1)),
     x   NINT(TFLENUM(2)),NINT(TFLEAVE(2)),
     x   NINT(TFLENUM(3)),NINT(TFLEAVE(3)),
     x   NINT(TFLENUM(4)),NINT(TFLEAVE(4)),
     x   NINT(TFLENUM(5)),NINT(TFLEAVE(5)),
     x   NINT(TFLENUM(6)),NINT(TFLEAVE(6))

        WRITE (FNUMTMP,6451) STARNUMM,'     1',EXCODE,'ABSOLUTES ',
     x   NINT(TFLENUM(1)),NINT(TFLEAVA(1)),
     x   NINT(TFLENUM(2)),NINT(TFLEAVA(2)),
     x   NINT(TFLENUM(3)),NINT(TFLEAVA(3)),
     x   NINT(TFLENUM(4)),NINT(TFLEAVA(4)),
     x   NINT(TFLENUM(5)),NINT(TFLEAVA(5)),
     x   NINT(TFLENUM(6)),NINT(TFLEAVA(6))
 6451   FORMAT (I6,A6,1X,A10,2X,A10,1X,
     x  6I6,  6I6)

        CLOSE(FNUMTMP)

      ENDIF               ! END OF PLANT ERRORS SUMMARY (T)

!-----------------------------------------------------------------------

 8888 CONTINUE   ! Jump to here depending on IDET switches

!-----------------------------------------------------------------------

      EXCODEP = EXCODE
      WRITE (fnumwrk,*) ' '
      WRITE (fnumwrk,*) 'END OF HARVEST DAY OUTPUTS'
      WRITE (fnumwrk,*) 'WILL BEGIN NEW CYCLE (IF CALLED FOR)'
      WRITE (fnumwrk,*) ' '


      RETURN

      END  ! CSOUTPUT

!=======================================================================
!  CSLAYERS Subroutine
!  Leaf distribution module
!-----------------------------------------------------------------------
!  Revision history
!  1. Written for Cropsim                         L.A.H.      ?-?-98
!=======================================================================

      SUBROUTINE Cslayers
     X (htfr,lafr,                ! Canopy characteristics
     X pltpop,lai,canht,          ! Canopy aspects
     X lcnum,lap,lap0,            ! Leaf cohort number and size
     X LAIL)                      ! Leaf area indices by layer

      IMPLICIT NONE
      SAVE

      INTEGER       clx           ! Canopy layers,maximum          #
      INTEGER       lcx           ! Leaf cohort number,maximum     #
      PARAMETER     (clx=30)      ! Canopy layers,maximum          #
      PARAMETER     (lcx=25)      ! Leaf cohort number,maximum     #

      REAL          caid          ! Canopy area index              m2/m2
      REAL          canfr         ! Canopy fraction                #
      REAL          canht         ! Canopy height                  cm
      !REAL         clpos         ! Canopy layer,temporary         #
      REAL          clthick       ! Canopy layer thickness,temp    cm
      !INTEGER      cltot         ! Canopy layer number,total      #
      INTEGER       clnum         ! Canopy layer number,species    #
      !REAL         cltotfr       ! Canopy fraction in top layer   #
      !INTEGER      cn            ! Component                      #
      REAL          htfr(10)      ! Canopy ht fraction for lf area #
      INTEGER       l             ! Loop counter                   #
      REAL          lafr(10)      ! Canopy lf area fraction w ht   #
      REAL          lai           ! Leaf lamina area index         m2/m2
      !REAL         lailad(clx)   ! Lf lamina area index,active    m2/m2
      REAL          lailatmp      ! Leaf lamina area,active,temp   m2/m2
      REAL          lail(clx)     ! Leaf lamina area index         m2/m2
      REAL          lailtmp       ! Leaf lamina area,temporary     m2/m2
      REAL          lap(lcx)      ! Leaf lamina area,cohort        cm2/p
      REAL          lap0          ! Leaf lamina area gr,cohort     cm2/p
      REAL          lapp(lcx)     ! Leaf lamina area,infected      cm2/p
      REAL          laps(lcx)     ! Leaf lamina area,senescent     cm2/p
      INTEGER       lcnum         ! Leaf cohort number             #
      INTEGER       lcnumr        ! Leaf cohorts remaining         #
      REAL          lfrltmp       ! Leaves above bottom of layer   fr
      REAL          lfrutmp       ! Leaves above top of layer      fr
      REAL          pltpop        ! Plant population               #/m2
      INTEGER       tvi1          ! Temporary variable,integer     #
      !INTEGER      tvilc         ! Temporary value,lf cohort      #
      REAL          YVALXY        ! Y value from function          #

!-----------------------------------------------------------------------

      caid = lai
      DO L = 1,25
        LAPP(L) = lap(l)  ! Temporary - avoid warning
        LAPS(L) = 0.0
      ENDDO

!-----------------------------------------------------------------------

      IF (caid.LT.0.0) RETURN
      IF (canht.LE.0.0) RETURN

!-----------------------------------------------------------------------

      ! Establish layer thickness (Must be ok for tallest species!)
      clthick=10.0                     ! Layer thickness (cm)

!-----------------------------------------------------------------------

      ! Determine layer number for species
      IF(MOD(canht,clthick).GT.0)THEN
       clnum=AINT(canht/clthick)+1
      ELSE
       clnum=AINT(canht/clthick)
      ENDIF
      clnum = MAX(clx,clnum)

      ! Distribute leaf area over layers

      DO tvi1=30,1,-1                  ! Do all layers;top down (old=1)
       lail(tvi1)=0.0                  ! Lai by layer
      ENDDO

      lfrutmp=1.0

      lfrutmp=0.0
      DO tvi1=clnum,1,-1               ! Do over layers down to soil
       canfr = (canht-(clthick*(tvi1-1))) / canht
       IF (canfr.GT.0.0) THEN
         lfrltmp = YVALXY(HTFR,LAFR,CANFR)
         lail(tvi1)=lai*(lfrltmp-lfrutmp)
         lfrutmp=lfrltmp
        ENDIF
      ENDDO

!-----------------------------------------------------------------------

      ! Calculate active leaf area in layers
      ! Disease damage

      lcnumr=lcnum
      lailtmp=lap0*pltpop*0.0001
      lailatmp=lap0*pltpop*0.0001

c     DO tvi1=cltot,1,-1               ! Do over layers down to soil
c      lail(tvi1)=lailtmp
c      lailad(tvi1)=lailatmp
c      lailtmp=0.0
c      lailatmp=0.0
c
c      DO tvilc=lcnumr,0,-1            ! Do damage,living cohorts
c       IF(tvilc.GT.0)THEN
c        lail(tvi1)=lail(tvi1)+
c    x   (lap(tvilc)-laps(tvilc))*pltpop*0.0001
c        lailad(tvi1)=lailad(tvi1)+
c    x   (lap(tvilc)-laps(tvilc)-lapp(tvilc))*pltpop*0.0001
c        ! Could adjust above for effect on activity as well as area -
c        ! ie multiply by a 0-1 factor dependent on pathogen and area
c       ENDIF
c
c       IF(caid.GT.0.AND.
c    x  lail(tvi1).GE.cails(cn,tvi1)*(lai/caid))THEN
c        lailtmp=lail(tvi1)-cails(cn,tvi1)*(lai/caid)
c        lail(tvi1)=lail(tvi1)-lailtmp
c        IF(tvilc.GT.0)THEN
c         IF(lap(tvilc)-laps(tvilc).GT.0)THEN
c          lailatmp=lailtmp*
c    x     (lap(tvilc)-laps(tvilc)-lapp(tvilc))/
c    x     (lap(tvilc)-laps(tvilc))
c          lailad(tvi1)=lailad(tvi1)-lailatmp
c         ENDIF
c        ENDIF
c        EXIT
c       ENDIF
c
c      ENDDO
c      lcnumr=tvilc
c      ! End damaged and senescent area section
c
c     ENDDO

      RETURN

      END  ! CSLAYERS

