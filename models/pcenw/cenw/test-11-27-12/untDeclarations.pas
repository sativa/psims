{ ================================================================
  = Project   : CenW                                             =
  ================================================================
  = Modules   : Declarations                                     =
  =                                                              =
  =             This is where all structured types and           =
  =             variables are declared.                           =
  ================================================================
  = File      : untDeclarations.PAS                              =
  =                                                              =
  = Version   : 4.0                                              =
  ================================================================ }

unit untDeclarations;

interface

const MaxSapWoodYears = 100;
      WoodRings = 500;
      MaxedtFieldWidth = 6;
      MaxFertiliseEvents = 1000;
      MaxPestEvents = 1000;
      MaxFireEvents = 1000;
      MaxHarvestEvents = 1000;
      MaxEnvironmentEvents = 1000;
      MaxPloughEvents = 100;
      MaxOMAdditions = 100;
      MaxGrazings = 5000;
      MaxSoilLayers = 20;
      MaxProjects = 10;
      MaxListRows = 1000;
      Kelvin = 273.15;
      GammaSea = 65;
      DayDisplay = 500;
      MonthDisplay = 2500;
      Latent = 2500000.0;
      rho = 1.204;
      cp = 1010.0;
      LengthOfSpring = 91;
      NorthernStartOfSpring = 60;
      SouthernStartOfSpring = NorthernStartOfSpring + 184;
{     SOMDecay1 = 0.0217140000;  // Decay constant (d-1) for structural surface litter
      SOMDecay2 = 0.0800000000;  // Decay constant (d-1) for metabolic surface litter
      The above are the original CENTURY constants that were lower than corresponding soil
      parameter to account for the less favourable environment, esp. with respect to moisture relations.
      In the latest formulation, moisture relations are explictly calculated for the litter layer
      so that it is no longer warranted to use different parameters for the soil and the surface.}
      SOMDecay1 = 0.0268580000;  // Decay constant (d-1) for structural surface litter
      SOMDecay2 = 0.1000000000;  // Decay constant (d-1) for metabolic surface litter
      SOMDecay3 = 0.0268580000;  // Decay constant (d-1) for structural soil litter
      SOMDecay4 = 0.1000000000;  // Decay constant (d-1) for metabolic soil litter
      SOMDecay5 = 0.0400000000;  // Decay constant (d-1) for active organic matter
      SOMDecay6 = 0.0010860000;  // Decay constant (d-1) for slow organic matter  {the value from version 3.1}
      SOMDecay7 = 0.0000380000;  // Decay constant (d-1) for resistant organic matter
//      SOMDecay6 = 0.0010428600;  // that's the value in the current 4.0 version for the constant (d-1) for slow organic matter
      { Textlength for numerical input in dialogboxes. }
      num_t_len    = 12;
      String_t_len = 100;
      Info_String_len = 100;
      ParFileMaxWidth = 12;
      MaxListEntries = 12;
      type TColors = record
                    Black, DarkBlue, Blue, DarkGreen, Green, DarkRed, Red, DarkMagenta,
                    Magenta, DarkYellow, Yellow, BrightYellow, White, Grey, DarkGrey, Orange: integer;
                    end;

Const Color: TColors = (Black       : $00000000;
                        DarkBlue    : $00A00000;
                        Blue        : $00FF0000;
                        DarkGreen   : $0000A000;
                        Green       : $0000FF00;
                        DarkRed     : $000000A0;
                        Red         : $000000FF;
                        DarkMagenta : $00800080;
                        Magenta     : $00FF00FF;
                        DarkYellow  : $0000B0B0;
                        Yellow      : $0000E0E0;
                        BrightYellow: $0000FFFF;
                        White       : $00FFFFFF;
                        Grey        : $00C0C0C0;
                        DarkGrey    : $00808080;
                        Orange      : $0000B0E0);

type ElementsUsed = (C13, C, N, P);
     TElements = array[C13..P] of double;
     SoilElements = array[0..MaxSoilLayers] of TElements;
     Infotype = array[0..40] of char;
     FileNameType = String[String_t_len];
     InfoTransferRecord = array[0..Info_String_len-1] of char;
     OrganicFlowType = array[0..MaxSoilLayers] of double;
     MultipleRunsType = array[0..MaxProjects] of FileNameType;
     ColorOptions = (Green, Red, Black, Blue, Yellow);
     ScreenTypes = (Pixel, Line);
     RespirationTypes = (Basics, Ratio);
     MortalityTypes = (Fraction, Density, Both);
     PhenologyUnitsType = (HeatSum, JulianDay, Daylength, nDays);
     EquilOptions = (SOM, LeafNConc, LeafNitrogen, LeafMass, WoodMass);
     EquilParameterOptions = (BiolNFix, NFraction);
     PhotosynthesisTypes = (C3, C4);
     SetDeltaOptions = (SetValue, CalculateValue);
     array365 = array[0..365] of double;
     CohortTypes = (Total, Under, Over);

AllOptions = (Sapwood, HeartWood, CoarseRoot, HeartRoot, FineRoot, Branches,
              Leaves1, Leaves2, Leaves3, Pollen, Fruit,
              CoarseWood, FineWood, CoarseRootLitter, FineRootlitter, Leaves, Other,
              StructSurf, StructSoil, MetabSurf, MetabSoil, Slow, Active, Resistant, Soluble,
              Tmax, Tmin, TSoil, PAR, Humidity, StoredWater, WaterLimit, CO2Conc, Rain);

DerivedEquilType = Record
                   SearchValue, Converg1, Converg2, Converg3,
                   ConvergP, Delta, PDelta, PRestrict: double;
                   GoodCount, Iterations: Integer;
                   SolutionFound, ManualAdjust, Oscillating: Boolean;
                   End;

DerivedType = Record
              CarbonGain, CAI, NPP, WaterLimit, p_internal, IrrigateWater,
              NLimit, Rm, Rg, TDamageUnits, RainDamageUnits, RainDamage, TDamage, BallBerry, NBiol, Plimit,
              PestLeafDamage, PestSolubleDamage, PestSenesc, PestPhsFrac, PestMortality, PestDeathRatio,
              gs, Desic, Transpiration, DroughtMort, nMortality, CLossMortality, MeanNLimit, RespnBase,
              Deciduous, LeafGrowth, MaxPlantNUptake, Functionf1, Functionf2, HDSlope,
              SoilRespn, NUptake, NMineralised, DecompLimit, NEE, DayCFlux, NightCFlux, Evaporation, NLeached,
              HeatSum, ExcessN, All_Litter, SoilTRadnEffect, HeteroRespn, WoodDensity, AnnualMeanTemp,
              C_ActFruitAlloc, C_ActPollenAlloc, N_FruitAlloc, N_PollenAlloc, P_FruitAlloc, P_PollenAlloc,
              C_SapWoodAlloc, C_BranchAlloc, C_BarkAlloc, C_RootAlloc, C_FineRootAlloc, C_CoarseRootAlloc, C_LeafAlloc,
              N_SapWoodAlloc, N_BranchAlloc, N_BarkAlloc, N_RootAlloc, N_FineRootAlloc, N_CoarseRootAlloc, N_LeafAlloc,
              P_SapWoodAlloc, P_BranchAlloc, P_BarkAlloc, P_RootAlloc, P_FineRootAlloc, P_CoarseRootAlloc, P_LeafAlloc,
              PUptake, PMineralised, PLeached, SpringMaxTemp, SpringTempSum,
              SoilN, GrowthSheathDensity, Dummy: double;
              Drainage, DecompWatLimit: array[0..MaxSoilLayers] of double;
              Equil: DerivedEquilType;
              LastYearsWood, LastYearsDecomp, NPPCount, Temperature: array365;
              LAI, Absorb, Intercept, NConc, PConc: array[CohortTypes] of double;
              SpringTempCounter: Integer;
              End;

ListType = Record
           nEntries, nRows, Header, StrOptions, nRadios, HelpContext, MaxRows,
           Trans1stRow, TransLastRow, TransSetColumn: Integer;
           Trans1stNo, TransIncrement: double;
           TextBoxEntry: double;
           Caption, FileExt, FileComment, TextBoxCaption, TransString: String;
           RadioOptions: array[1..2] of Integer;
           RadioHeading: array[1..2] of String;
           RadioText: array[1..2, 1..3] of String;
           RbtnSelected: array[1..2] of Integer;
           StringConst: array[1..5] of String;
           Width: array[0..MaxListEntries] of Integer;
           Text: array[1..3, 0..MaxListEntries] of String;
           DataType: array[0..MaxListEntries] of (S, R, I);
           Data: array[1..MaxListRows, 0..MaxListEntries] of double;
           HasChanged, ShowMessage, TextBox, Redraw, RedrawOption, SetColumn, TransUseIncrement: Boolean;
           Message: String;
           End;

EquilibriumSetup = Record
                   Maxiterations, MaxGoodCount, OscillationCount: Integer;
                   Criterion1, Criterion2, Criterion3, TargetValue, DeltaMin, DeltaMax,
                   MaxChangeRatio, DeltaAdjust, BoostResistant, TargetPlimit: double;
                   EquilTarget: EquilOptions;
                   EquilParameter: EquilParameterOptions;
                   SamePlantPools, AdjustPInput, HoldPInput: Boolean;
                   End;

PhenologyType = Record
                nChanges: Integer;
                Threshold: double;
                Units: array[1..365] of PhenologyUnitsType;
                JulianDay, nDays: array[1..365] of Integer;
                HeatSum, DayLength, Senescence, LeafGrowth: array[1..365] of double;
                End;

Littertype = record
             CoarseWood, FineWood, CoarseRoot, FineRoot, Leaves, Other, WeedLeaves, WeedRoots,
             OMAddition: TElements;
             OMLignin: double;
             end;

WeedType = Record
           MaxHeight, KMHeight, Senescence, AllocLeaves, KMRootPlantNUptake, KMRootPlantPUptake: double;
           End;

ParameterType = Record
        FineSoil, MeanSoilTemp, CO2Conc, AtmosPressure, gamma, alpha,
        AnnualRain, RainProb, MeanTmax, MeanTmin, MeanRadn, MeanAbsHum, Latitude, Longitude,
        FertiliserRelease, FertilityAdjust, RateAdjust, Immobilise, LitterWHC, DirectEvapSlope,
        DirectEvapFract, CriticalCN, Decay8, Decay9, Decay10, DefaultSoilDelta, ImmobiliseInSlow,
        DecayBranch_StructRatio, DecayWood_StructRatio, Inert_Resistant_Ratio,
        RelWaterSens, RelativeCN, OMTransfer_Old, OMIncorporate, Mulching, SoilEvap, MinDecomp,
        Nloss, Leaching, Atmos_N, Temp_Amplitude, Radn_Amplitude, Daily_Amplitude, Humid_Amplitude,
        Snowmelt, RadnMelt, SoilTResist, SnowInsulate, Respnalpha, Respnbeta, RespnOpt,
        RespFromN, SenescLeafRatio, InternalNRatio, LeafSenesc,
        BranchSenesc, RootSenesc, FruitSenesc, PollenSenesc, SenescLowLight, MaxSenescLowLight,
        RootLeafRatio1, RootLeafRatio2, Form, MinWoodAlloc, ExcessNUptake, WaterLogLimit, WaterLogSensitivity,
        WoodDensity, WoodDensity25, WoodDensity0, WoodDensTemp, WoodDensFertility, WoodDensStocking,
        WoodBranchRatio, RootLeafRatio, LeafBranchRatio, BarkWoodRatio, CoarseRootWoodRatio,
        C_FruitAlloc, C_PollenAlloc, RelativeCP, CriticalCPmin, CriticalCPmax, Atmos_P, P0, Pcrit, Pmax,
        SLA, Amax, Theta, Kexmax, KlowRange, CanopyWidthInter, CanopyWidthSlope,
        ConstantLeafNValue, Albedo, AeroResist, RainDamageLimit, RainDamageSensitivity, RainDamageRepair,
        DrySenesc, DeathLimit, BiolFix, GrowthRespn, BarkSenesc, MicroFract,
        DryDeath, StressLimit, HDInter, HDSlope, WDSlope, WHSlope, Mindbh, Ht_Diameter,
        HD_Const, HD_Temp, HD_Stocking, HD_Fertil, HD_Age1, HD_Age2, HD_InitialSlope, HD_InitialInter,
        HDSlopeMin, HDSlopeMax, CrowdingPower, CrowdingMax, CrowdingFactor, CrowdingOffset,
        TMinLim, TOpt1, TOpt2, TmaxLim, TFrost, TScorch, TSensitivity, TRepair, NMVOC,
        WoodRetrans, bRoots, bWood, bBark, bBranch, bFruit, bPollen,
        N0, Ncrit, Nmax, AgePower, SizePower, NewDelta, ExtraDelta, phi,
        StemDeath, DeathRatio, Three_Two_Power_Law, RespnAdjust,
        WoodLignin, LeafLignin, RootLignin, LigninInhibition, TMaxRepairTime, RespnRatio,
        Transmit, BallBerry1, BallBerry2, DefaultPlantDelta, MaxTBoost, TLAISensitivity,
        relkPEP, Beta,
        Weathering, Labile_to_Sec, Sec_to_Labile, OccludedP_rate, Phosphatase: double;
        Phenology: PhenologyType;
        KmGrowth: TElements;
        WarmestDay, MostRadn: Integer;
        SexAge, SapWoodYears, MatureAge, MatureSize: Integer;
        DirectEvapType: Char;
        Weed: WeedType;
        SetDeltaType: SetDeltaOptions;
        MortalityType: MortalityTypes;
        RespnType: RespirationTypes;
        Phs: PhotosynthesisTypes;
        AgeDecline, SizeDecline, FoliageClumping, ConstantLeafN, RespnTAcclimation, VariableNFixation,
        VariableHD, UseAllometrics: Boolean;
        end;

Planttype = Record
            Sapwood, HeartWood, CoarseRoot, FineRoot, Leaves, Reserves,
            Branches, Bark, Pollen, Fruit, Soluble, NewGrowth,
            NewWeedGrowth, WeedLeaves, WeedRoots: TElements;
            Stocking, Height, Area, DBH, CanopyCover, kex, WeedHeight: double;
            SapWoodAmount: array[0..MaxSapWoodYears] of double;
            AllWoodRings: array[0..WoodRings] of double;
            Age: integer;
            end;

InitialType = Record
            Sapwood, HeartWood, CoarseRoot, FineRoot, Leaves, Reserves,
            Branches, Bark, Pollen, Fruit, Soluble, WeedLeaves, WeedRoots: TElements;
            Stocking, Height, DBH: double;
            Age, Days, Months, Years: integer;
            end;

SaveVariableOptions = (S_Year, S_Month, S_Day,
                       S_CH2O, S_SapWoodC, S_HeartWoodC, S_LeafC, S_FineRootC, S_BarkC,
                       S_CoarseRootC, S_BranchesC, S_ReprodC, S_Reserves,
                       S_SolubleN, S_SapWoodN, S_HeartWoodN, S_LeafN, S_FineRootN, S_BarkN,
                       S_CoarseRootN, S_BranchesN, S_ReprodN, S_ReservesN, S_Nlimit, S_TotalN,
                       S_LAI, S_Height, S_DBH, S_CanopyCover, S_kex, S_BasalArea, S_Stocking,
                       S_pi, S_CAI, S_NPP, S_NEE, S_CarbonGain, S_Respn, S_DayCFlux, S_NightCFlux,
                       S_TDamage, S_Transpiration, S_NBiol, S_NConc,
                       S_CMetabolic, S_NMetabolic, S_CStructural, S_NStructural,
                       S_CWoodyLitter, S_NWoodyLitter, S_CActive, S_NActive,
                       S_CSlow, S_NSlow, S_CResistant, S_NResistant, S_CInert, S_NInert, S_NecroC, S_NecroN,
                       S_CLitterFall, S_NLitterFall, S_CAgLitterFall, S_NAgLitterFall, S_CLeafLitterFall, S_NLeafLitterFall,
                       S_NMineral, S_NLeached, S_HeteroRespn, S_SoilRespn,
                       S_SolubleP, S_SapWoodP, S_HeartWoodP, S_LeafP, S_FineRootP, S_BarkP,
                       S_CoarseRootP, S_BranchesP, S_ReprodP, S_ReservesP,
                       S_MetabolicP, S_StructuralP, S_WoodyLitterP, S_ActiveP, S_SlowP, S_ResistantP, S_InertP, S_NecroP,
                       S_MineralP, S_RockP, S_OccludedP, S_2ndaryP, S_TotalOrganicP, S_Plimit, S_TotalP,
                       S_Tmax, S_Tmin, S_Tmean, S_Tsoil, S_Tday,
                       S_AbsHum, S_RelHum, S_Radn, S_Rain, S_StoredWater, S_WaterLimit, S_RelDecomp, S_Snow,
                       S_Drainage, S_HeatSum, S_Evaporation, S_Dummy);

ScreenOptions = (D_CarbonGain, D_CAI, D_NPP, D_NEE, D_Respn, D_DayCFlux, D_NightCFlux,
                 D_SolubleCH2O, D_LAI, D_pi, D_Wood, D_SapW, D_HeartW,
                 D_Reserves, D_Leaf, D_FineRoot, D_Bark, D_CoarseRoot, D_Branches, D_Reprod,
                 D_WeedLeaves, D_WeedHeight,
                 D_Height, D_DBH, D_CanopyCover, D_kex, D_BasalArea, D_Stocking,
                 D_TDamage, D_NConc, D_NConc1, D_SolubleN, D_WoodN, D_SapWN, D_HeartWN,
                 D_ReservesN, D_LeafN, D_FineRootN, D_BarkN,
                 D_CoarseRootN, D_BranchN, D_ReprodN, D_Nlimit, D_NBiol, D_NSum,
                 D_CLeafLitter, D_CAll_Litter, D_CAg_Litter, D_CMetabSurf, D_CMetabSoil, D_CStructSurf,
                 D_CStructSoil, D_CWoodyLitter, D_CActive, D_CSlow, D_CResistant, D_CInert, D_SoilRespn,
                 D_NLeafLitter, D_NAll_Litter, D_NAg_Litter, D_NMetabSurf, D_NMetabSoil, D_NStructSurf,
                 D_NStructSoil, D_NWoodyLitter, D_NActive, D_NSlow, D_NResistant, D_NInert, D_NMineral, D_NLeached,
                 D_PConc, D_Puptake, D_Plimit, D_PSum, D_PSumOrganic, D_PLeafLitter, D_PAll_Litter, D_PAg_Litter, D_PMetabSurf, D_PMetabSoil, D_PStructSurf,
                 D_PStructSoil, D_PWoodyLitter, D_PActive, D_PSlow, D_PResistant, D_PInert, D_PMineral, D_PRock, D_POccluded, D_2ndaryP,
                 D_Tmax, D_Tmin, D_Tmean, D_Tsoil, D_Tday, D_Radn, D_CO2, D_Rain, D_StoredWater,
                 D_AbsHum, D_RelHum, D_WaterLimit, D_Transpiration, D_Evaporation,
                 D_Drainage, D_HeatSum, D_Snow, D_Dummy, D_Equil, D_Equil2, D_Equil3);

GenericOutputType = Record
                     FirstDisplay, LastDisplay: ScreenOptions;
                     FirstSave, LastSave: SaveVariableOptions;
                     IncludeSoilLayerInfo: Boolean;
                     Title: String;
                     End;

ScreenRecord = Record
               Choose: array [ScreenOptions] of Boolean;
               UpRange, LowRange: array [ScreenOptions] of double;
               Color: array [ScreenOptions] of Longint;
               End;

SensitivityType = (Dummy, FineSoil, MeanSoilTemp, CO2, AtmosPressure, WoodLignin, LeafLignin,
      RootLignin, AnnualRain, RainProb, MeanTmax, MeanTmin, MeanRadn, MeanAbsHum, Latitude,
      FertiliserRelease, FertilityAdjust, RateAdjust, TMaxRepairTime, Immobilise, DirectEvapSlope, DirectEvapFract,
      Decay1, Decay2, Decay3, Decay4, Decay5, Decay6, Decay7, Decay8, Decay9, RelativeCN, CriticalCN, Transmit, BallBerry1,
      BallBerry2, Nloss, Leaching, MicroFract, Atmos_N, BiolFix, GrowthRespn, BarkSenesc,
      RespFromN, StemDeath, SenescLeafRatio, InternalNRatio, LeafSenesc, BranchSenesc, RootSenesc,
      FruitSenesc, PollenSenesc, SenescLowLight, MaxSenescLowLight, RootLeafRatio1, RootLeafRatio2,
      WoodBranchRatio, LeafBranchRatio, BarkWoodRatio, CoarseRootWoodRatio, C_FruitAlloc,
      C_PollenAlloc, SLA, Amax, Theta, Kexmax, KlowRange, Albedo, Temp_Amplitude, Radn_Amplitude, Daily_Amplitude,
      Humid_Amplitude, DrySenesc, StressLimit, SoilEvap, HDInter, HDSlope, WDSlope, WHSlope,
      WeedMaxHeight, WeedKMHeight, WeedFoliageTurnover, WeedFoliageAllocation, WeedKmTreeRoots, WeedKmTreeRootsP,
      WoodDensPith, WoodDensOuter, WoodDensTemperature, WoodDensFertility, WoodDensStocking,
      HDConst, HDTemp, HDStocking, HDFertility, HDAge1, HDAge2, HDInitSlope, HDInitIntercept, HDSlopeMin, HDSlopeMax,
      TMinLim, TOpt1, TOpt2, TmaxLim, TFrost, TScorch, TSensitivity, TRepair, WoodRetrans,
      bRoots, bWood, bBark, bBranch, bFruit, bPollen, RelWaterSens, N0, Ncrit, Nmax, SapwoodC, HeartWoodC,
      CoarseRootC, FineRootC, BranchesC, BarkC, LeavesC, SapwoodN, HeartWoodN, CoarseRootN,
      FineRootN, BranchesN, BarkN, LeavesN, Stocking, FineWoodSurfC, CoarseWoodSurfC, CoarseWoodSoilC,
      StructSurfC, StructSoilC, MetabSurfC, MetabSoilC, SlowC, ActiveC, ResistantC, FineWoodSurfN,
      CoarseWoodSurfN, CoarseWoodSoilN, StructSurfN, StructSoilN, MetabSurfN, MetabSoilN, SlowN,
      ActiveN, ResistantN, EndInputs, CAI, NConc, LAI, Wood, ShowFineRootC, ShowFineRootN,
      ShowBranches, ShowLeaves, ShowLeafN, Height, DBH, CanopyCover, kex, ShowFineWoodSurfC, ShowCoarseWoodSurfC,
      ShowCoarseWoodSoilC, ShowStructSurfC, ShowMetabSurfC, ShowStructSurfN, ShowMetabSurfN,
      ShowSlowC, ShowActiveC, ShowResistantC, ShowSlowN, ShowActiveN, ShowResistantN, EndDummy);

const SensitivityNames: array[SensitivityType] of string =
      ('Dummy', 'FineSoil', 'MeanSoilTemp', 'CO2', 'AtmosPressure', 'WoodLignin', 'LeafLignin',
      'RootLignin', 'AnnualRain', 'RainProb', 'MeanTmax', 'MeanTmin', 'MeanRadn', 'MeanAbsHum', 'Latitude',
      'FertiliserRelease', 'FertilityAdjust', 'RateAdjust', 'TMaxRepairTime', 'Immobilise', 'DirectEvapSlope', 'DirectEvapFract',
      'Decay1', 'Decay2', 'Decay3', 'Decay4', 'Decay5', 'Decay6', 'Decay7', 'Decay8', 'Decay9', 'RelativeCN', 'CriticalCN', 'Transmit', 'BallBerry1',
      'BallBerry2', 'Nloss', 'Leaching', 'MicroFract', 'Atmos_N', 'BiolFix', 'GrowthRespn', 'BarkSenesc',
      'RespFromN', 'StemDeath', 'SenescLeafRatio', 'InternalNRatio', 'LeafSenesc', 'BranchSenesc', 'RootSenesc',
      'FruitSenesc', 'PollenSenesc', 'SenescLowLight', 'MaxSenescLowLight', 'RootLeafRatio1', 'RootLeafRatio2',
      'WoodBranchRatio', 'LeafBranchRatio', 'BarkWoodRatio', 'CoarseRootWoodRatio', 'C_FruitAlloc',
      'C_PollenAlloc', 'SLA', 'Amax', 'Theta', 'Kexmax', 'KlowRange', 'Albedo', 'Temp_Amplitude', 'Radn_Amplitude', 'Daily_Amplitude',
      'Humid_Amplitude', 'DrySenesc', 'StressLimit', 'SoilEvap', 'HDInter', 'HDSlope', 'WDSlope', 'WHSlope',
      'WeedMaxHeight', 'WeedKmHeight', 'WeedFolTurnover', 'WeedFolAlloc', 'WeedKmTreeRoots', 'WeedPKmTreeRoots',
      'WoodDensPith', 'WoodDensOuter', 'WoodDensTemperature', 'WoodDensFertility', 'WoodDensStocking',
      'HDConst', 'HDTemp', 'HDStocking', 'HDFertility', 'HDAge1', 'HDAge2', 'HDInitSlope', 'HDInitIntercept', 'HDSlopeMin', 'HDSlopeMax',
      'TMinLim', 'TOpt1', 'TOpt2', 'TmaxLim', 'TFrost', 'TScorch', 'TSensitivity', 'TRepair', 'WoodRetrans',
      'bRoots', 'bWood', 'bBark', 'bBranch', 'bFruit', 'bPollen', 'RelWaterSens', 'N0', 'Ncrit', 'Nmax', 'SapwoodC', 'HeartWoodC',
      'CoarseRootC', 'FineRootC', 'BranchesC', 'BarkC', 'LeavesC', 'SapwoodN', 'HeartWoodN', 'CoarseRootN',
      'FineRootN', 'BranchesN', 'BarkN', 'LeavesN', 'Stocking', 'FineWoodSurfC', 'CoarseWoodSurfC', 'CoarseWoodSoilC',
      'StructSurfC', 'StructSoilC', 'MetabSurfC', 'MetabSoilC', 'SlowC', 'ActiveC', 'ResistantC', 'FineWoodSurfN',
      'CoarseWoodSurfN', 'CoarseWoodSoilN', 'StructSurfN', 'StructSoilN', 'MetabSurfN', 'MetabSoilN', 'SlowN',
      'ActiveN', 'ResistantN', 'EndInputs', 'CAI', 'NConc', 'LAI', 'Wood', 'ShowFineRootC', 'ShowFineRootN',
      'ShowBranches', 'ShowLeaves', 'ShowLeafN', 'Height', 'DBH', 'CanopyCover', 'kex', 'ShowFineWoodSurfC', 'ShowCoarseWoodSurfC',
      'ShowCoarseWoodSoilC', 'ShowStructSurfC', 'ShowMetabSurfC', 'ShowStructSurfN', 'ShowMetabSurfN',
      'ShowSlowC', 'ShowActiveC', 'ShowResistantC', 'ShowSlowN', 'ShowActiveN', 'ShowResistantN', 'End dummy');

Type BatchOptions = (B_Dummy, B_RunDay, B_RunMonth, B_RunYear, B_Stocking, B_Latitude,
                     B_ExtraCO2, B_ExtraTemp, B_ExtraRain, B_ExtraVP, B_ExtraRadn,
                     B_LeafLignin, B_RootLignin, B_MaxWater, B_FineSoil, B_FertilityAdjust, B_ConstantLeafN,
                     B_Irrigate, B_FertiliseN, B_FertiliseP, B_ClimateFile, B_Harvesting, B_Environment, B_EndDummy);

const BatchVariableNames: array[BatchOptions] of string =
      ('Dummy', 'Run length - days', 'Run length - months', 'Run length - years', 'Initial stocking',
       'Latitude', 'ExtraCO2', 'Extra temperature', 'Extra rain', 'Extra vapour pressure', 'Extra radiation',
       'Leaf lignin', 'Root lignin', 'Water holding capacity', 'Fine soil fraction', 'Fertility index',
       'Constant leaf N', 'Irrigation', 'N Fertiliser added', 'P Fertiliser added', 'Climate file', 'Harvesting',
       'Environment changes', 'End dummy');

type BatchType = record
                 Choose: array[BatchOptions] of Boolean;
                 OldValue, NewValue: array[BatchOptions] of double;
                 nEnvironments: Integer;
                 EnvironmentTimes: array[1..MaxEnvironmentEvents] of integer;
                 CO2, Temperature, Rainfall, VP, Radn: array[1..MaxEnvironmentEvents] of double;
                 nHarvests: Integer;
                 HarvestTimes: array[1..MaxHarvestEvents, 1..4] of integer;
                 WoodCut, RelativeSize, BranchesCut, WoodRemoval, FineRemoval: array[1..MaxHarvestEvents] of double;
                 AdjustStocking: array[1..MaxHarvestEvents] of Boolean;
                 OldFile: FileNameType;
                 End;

Soilorgtype = record
              nLayers: Integer;
              FineWood, CoarseWood, Struct, Metab, Slow, Active, Resistant, Inert, Soluble, Mycorrhizal,
              RockP, OccludedP, SecondaryInorganicP: SoilElements;
              LitterLig, BranchLig, StemLig, FineRootLitterIn, CoarseRootLitterIn, OMTransfer: OrganicFlowType;
              end;

SoilWaterCategories = Record
                      Depth, Pores, MaxWater, ExtractEffort, StressSensitivity, RelEvap, WaterContent, Percolate: double;
                      End;

SoilWaterType = Record
                TotalWater, MaxWater, MaxExtract, Snow: double;
                SeparateSensitivity: Boolean;
                nLayers: integer;
                Layer: array[0..MaxSoilLayers] of SoilWaterCategories;
                End;

WeatherType = Record
              TMax, TMin, TMean, TSoil, TDay, TNight, Radn, Rain, AbsHumidity,
              RelHumidity, Evaporation, CO2, ExtraCO2, ExtraTemp, ExtraRain, ExtraVP, ExtraRadn,
              RainProb, LastMin, LastAbsHum, LastRelHum: double;
              End;

WeatherFileOptions = (W_Tmax, W_Tmin, W_Tmean, W_Tsoil, W_Radn, W_Rain,
                      W_AbsHum, W_RelHum, W_CO2);

SpatialPlantType = (Optimal, Exotic);

SpatialSoilType = (Equil, SoilSet);

SpatialType = Record
              Initial, Calcs, xInter, yInter, Count: Integer;
              RainMin, RainMax, TempMin, TempMax, LongMin, LongMax,
              integererval, LatMin, LatMax, LatInterval, WaterHold, Fertility,
              ActiveC, ActiveN, SlowC, SlowN, ResistC, ResistN: double;
              ShowNumeric: Boolean;
              PlantType: SpatialPlantType;
              SoilType: SpatialSoilType;
              Tmin, Tmax, Radn, Rain: Array [1..12] of double;
              Draw: ScreenOptions;
              End;

ControlType = Record
              NextHarvest, NextEnvironment,NextOMAdditions, NextPest, NextFire, NextPlough, BatchCalcs,
              nMonths, nDays, JulianDay, BatchCount, nProjects, NextPhenology, NextGrazing,
              ExtraMonths, ExtraDays, Count, NextFertilise, SensFlag, nCohorts: integer;
              CConversion, NConversion, OldPar: double;
              MaxDays, DaysSince, TotalDays, LastIrrigation, nSeconds, PhenologyDayCount, StartBatchSave,
              nYears, Year, DisplayInterval, TotalYears, DaysSinceDisk, DiskInterval, nDiskOut, nDisplays: integer;
              CalcType, ClimType,
              Fertilise_DateType, Harvest_DateType, Pest_DateType, Fire_DateType, Plough_DateType, OMAdditions_DateType: char;
              DecayOnly, StartRun, NewYear, Run_on, ClimFileOpen, BatchFileOpen, Range, CheckProject,
              SaveProject, IrrigAnnounced, LegendOn, OutputFileOpen, AllOneLayer, ErrorSaving, UseSimulated,
              ProjectHasChanged, PlantHasChanged, SiteHasChanged, InitHasChanged, IncludeIsotopes,
              DataToBeSaved, SensitivityTestOn, SensFileOpen, InitGenerated, BatchMode, TSoilFound,
              ScreenHasChanged, CheckSaveInit, AgreeOK, AgreeChecked, EndBatch, OutputByLayer,
              EquilMode, EndEquil, SaveBeforeRun, AbortRun, PestMode, ResetPlantPools, NoticeFlags,
              RunWithDefaults, IncludeP, IncludeWeeds, EndSpatial, SpatialMode, CountersSaved: Boolean;
              CenWFileOut, DefClim, ClimChngFile, SensFile, BatchName, SpatialText, Dummy: TextFile;
              FileOut, ClimFile, ProjectFile, SiteFile, PoolFile, SavePoolFile, BatchFile, MultipleRunPoolFile: FileNameType;
              PlantFile, SpatialFile: FileNameType;
              ProjectName, Date: InfoTransferRecord;
              MultipleRuns: MultipleRunsType;
              Initial: InitialType;
              OldSOilPar: SoilElements;
              Version: string[5];
              OldDirectory, ProjectDirectory, Display: string;
              SensParameter: SensitivityType;
              DisplayType: ScreenTypes;
              Equil: EquilibriumSetup;
              Spatial: SpatialType;
              End;

const SaveVariableNames: array[SaveVariableOptions] of string
                    = ('Year','Month','Day',
                       'CH2O', 'Sapwood C','Heartwood C','Foliage C','Fineroot C', 'Bark C',
                       'Coarseroot C', 'Branch C','Reproductive C','Reserves C',
                       'Soluble N','Sapwood N','Heartwood N','Foliage N','Fineroot N', 'Bark N',
                       'Coarseroot N','Branch N','Reproductive N','Reserves N', 'Nlimit', 'Total N',
                       'LAI','Height','DBH','Canopy cover','Extinction coeff.','Basal area', 'Stocking',
                       'pi','CAI','NPP','NEE','Carbon gain','Autotrophic respn','Day C Flux', 'Night C Flux',
                       'Temp. damage','Transpiration','Biol. N fixation','N Concentration',
                       'C Metabolic','N Metabolic', 'C Structural','N Structural',
                       'C Woody litter','N Woody litter','C Active','N Active',
                       'C Slow','N Slow','C Resistant','N Resistant','C Inert','N Inert', 'C Necromass', 'N Necromass',
                       'C All litter prod','N All litter prod', 'C A-g Litterfall', 'N A-g Litterfall', 'C Leaf litter fall','N Leaf litter fall',
                       'N Mineral', 'N Leached', 'Heterotrophic respn', 'Soil Respiration',
                       'Soluble P', 'SapWood P', 'Heartwood P', 'Foliage P', 'Fineroot P', 'Bark P',
                       'Coarseroot P', 'Branch P', 'Reprod P', 'Reserves P',
                       'Metabolic P', 'Structural P', 'Woody litter P', 'Active P',
                       'Slow P', 'Resistant P', 'Inert P', 'P Necromass', 'Mineral P', 'RockP',
                       'OccludedP', '2ndary P', 'Total Organic P', 'Plimit', 'Total P',
                       'Tmax','Tmin','Tmean','Tsoil','Tday',
                       'Absolute Humidity','Relative Humidity','Radiation','Rain','Stored water','WaterLimit','Rel. decomposition','Snow',
                       'Drainage','Heat sum','Evaporation','Dummy');

ScreenVariableNames: array[ScreenOptions] of string
                    = ('Carbon gain', 'CAI', 'NPP', 'NEE', 'Respn', 'Day C Flux', 'Night C Flux',
                       'SolubleCH2O', 'LAI', 'pi', 'Wood', 'SapW', 'HeartW',
                       'Reserves', 'Leaf', 'FineRoot', 'Bark', 'CoarseRoot', 'Branches', 'Reprod',
                       'Weed leaves', 'Weed height',
                       'Height', 'DBH', 'CanopyCover', 'kex', 'BasalArea', 'Stocking',
                       'TDamage', 'NConc', 'NConc (top)', 'SolubleN', 'WoodN', 'SapWN', 'HeartWN',
                       'ReservesN', 'LeafN', 'FineRootN', 'Bark N',
                       'CoarseRootN', 'BranchN', 'ReprodN', 'N limit', 'N biol. fixed', 'NSum',
                       'CLeafLitter', 'CAll_Litter', 'CAg_Litter', 'CMetabSurf', 'CMetabSoil', 'CStructSurf',
                       'CStructSoil', 'CWoodyLitter', 'CActive', 'CSlow', 'CResistant', 'CInert', 'SoilRespn',
                       'NLeafLitter', 'NAll_Litter', 'NAg_Litter', 'NMetabSurf', 'NMetabSoil', 'NStructSurf',
                       'NStructSoil', 'NWoodyLitter', 'NActive', 'NSlow', 'NResistant', 'NInert', 'NMineral', 'NLeached',
                       'PConc', 'Puptake', 'P limit', 'PSum', 'Organic P sum', 'PLeafLitter', 'PAll_Litter', 'PAg_Litter', 'PMetabSurf', 'PMetabSoil',
                       'PStructSurf', 'PStructSoil', 'PWoodyLitter', 'PActive', 'PSlow', 'PResistant', 'PInert', 'PMineral', 'Rock P', 'Occluded P', '2ndary P',
                       'Tmax', 'Tmin', 'Tmean', 'Tsoil', 'Tday', 'Radiation', 'CO2', 'Rain', 'StoredWater',
                       'AbsHum', 'RelHum', 'WaterLimit', 'Transpiration', 'Evaporation',
                       'Drainage', 'Heat sum', 'Snow', 'Dummy', 'Equil run', 'Slow', 'Resistant');

type SaveVariableRecord = Record
     Choose: array [SaveVariableOptions] of Boolean;
     End;

SetSensRecord = Record
                Range: double;
                Index: Integer;
                Abort: Boolean;
                Choose: array [SensitivityType] of Boolean;
                End;

EventType = Record
            nFertilisations: integer;
            FertiliseTimes: array[0..MaxFertiliseEvents, 1..4] of integer;
            FertiliseAmount: array[0..MaxFertiliseEvents, ElementsUsed] of double;
            NFertiliserAdded, PFertiliserAdded: double;
            IrrigationInterval, DaysSinceIrrigation, IrrigStartDay, IrrigStartMonth,
            IrrigStartYear, IrrigEndDay, IrrigEndMonth, IrrigEndYear: integer;
            IrrigationAmount, IrrigationFraction: double;
            Irrigate: Boolean;
            IrrigationType: char;
            HarvestUnits: Char;
            nHarvests: integer;
            HarvestTimes: array[1..MaxHarvestEvents, 1..4] of integer;
            WoodCut, RelativeSize, BranchesCut, WoodRemoval, FineRemoval:
                           array[1..MaxHarvestEvents] of double;
            AdjustStocking: array[1..MaxHarvestEvents] of Boolean;
            nEnvironments: integer;
            EnvironmentTimes: array[1..MaxEnvironmentEvents] of integer;
            CO2, Temperature, Rainfall, VP, Radn: array[1..MaxEnvironmentEvents] of double;
            AdjustVP: Boolean;
            nPests: Integer;
            PestTimes: array[1..MaxPestEvents, 1..5] of integer;
            PestDamageUnits: char;
            LeafDamage, SolubleDamage, SenescenceDamage, PhotosynthesisFraction,
            PestMortality, PestDeathRatio: array[1..MaxPestEvents] of double;
            nFires: Integer;
            FireTimes: array[1..MaxFireEvents, 1..4] of integer;
            LeafBurn, WoodBurn, LitterBurn, WoodToChar, FineToChar, LeafBurnSenesc,
            WoodBurnSenesc, Burn_N_CRatio, Burn_P_CRatio: array[1..MaxFireEvents] of double;
            nPloughing: Integer;
            PloughTimes: array[1..MaxPloughEvents, 1..4] of integer;
            PloughDepth: array[1..MaxPloughEvents] of integer{Integer};
            nOMAdditions: Integer;
            OMAdditionTimes: array[1..MaxOMAdditions, 1..4] of integer;
            OMAddition: array[1..MaxOMAdditions, ElementsUsed] of double;
            OMExtraH2O, OMLignin: array[1..MaxOMAdditions] of double;
            nGrazings: Integer;
            GrazingUnits: Char;
            GrazingTimes: array[1..MaxGrazings, 1..4] of integer;
            GrazingAmount: array[1..MaxGrazings] of double;
            GrazingFraction: array[1..MaxGrazings, ElementsUsed] of double;
            End;

ScreenHistory = Record
                First: Boolean;
                Lastx, Lasty: integer;
                End;

var Derived  : DerivedType;
    Parameter: Parametertype;
    Control  : ControlType;
    OldScreen: array[ScreenOptions] of ScreenHistory;
    ScreenRec: ScreenRecord;
    SaveVar: SaveVariableRecord;
    TestSens: SetSensRecord;
    WeatherFile: array[WeatherFileOptions] of Boolean;
    MaxWidth, DecompCount: integer;
    List: ListType;
    Plant: Planttype;
    Litter: Littertype;
    Soilorganic: soilorgtype;
    Weather: WeatherType;
    Event: EventType;
    SoilWat: SoilWaterType;
    GenericOutput: GenericOutputType;
    Batch: BatchType;
    ModalResult: integer;

implementation

end.
