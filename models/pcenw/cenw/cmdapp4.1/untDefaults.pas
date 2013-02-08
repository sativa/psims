{ ================================================================
  = Project   : CenW                                             =
  ================================================================
  = Unit      : PlantDefaults                                    =
  =             ProjectDefaults                                  =
  =             PoolDefaults                                     =
  =             SiteDefaults                                     =
  =                                                              =
  =             Routines to read sets of default values if an    =
  =             appropriate file cannot be found.                =
  ================================================================
  = File      : DEFAULTS.PAS                                     =
  =                                                              =
  = Version   : 4.1                                              =
  ================================================================ }

Unit untDefaults;

{$V-}

INTERFACE

Uses
  untDeclarations, untLoadSaveProject, untLoadSavePlant, untLoadSaveSite, untLoadSaveInitial;

Procedure PlantDefaults;
Procedure ProjectDefaults;
Procedure PoolDefaults;
Procedure SiteDefaults;

IMPLEMENTATION

Procedure ProjectDefaults;
Begin
RealProjectVariables('D', 'Dummy', 'Dummy', Control.Dummy);
ScreenRec.Choose[D_CarbonGain] := FALSE;
ScreenRec.UpRange[D_CarbonGain] := 500;
ScreenRec.LowRange[D_CarbonGain] := 0.0;
ScreenRec.Choose[D_CAI] := TRUE;
ScreenRec.Color[D_CAI] := 255;
ScreenRec.UpRange[D_CAI] := 20;
ScreenRec.LowRange[D_CAI] := 0.0;
ScreenRec.Choose[D_NPP] := TRUE;
ScreenRec.Color[D_NPP] := 255255;
ScreenRec.UpRange[D_NPP] := 50;
ScreenRec.LowRange[D_NPP] := 0.0;
ScreenRec.Choose[D_NEE] := FALSE;
ScreenRec.Color[D_NEE] := 255255;
ScreenRec.UpRange[D_NEE] := 50;
ScreenRec.LowRange[D_NEE] := -50;
ScreenRec.Choose[D_Respn] := FALSE;
ScreenRec.Color[D_Respn] := 255255;
ScreenRec.UpRange[D_Respn] := 50;
ScreenRec.LowRange[D_Respn] := 0;
ScreenRec.Choose[D_DayCFlux] := FALSE;
ScreenRec.Color[D_DayCFlux] := 255255;
ScreenRec.UpRange[D_DayCFlux] := 100;
ScreenRec.LowRange[D_DayCFlux] := -50;
ScreenRec.Choose[D_NightCFlux] := FALSE;
ScreenRec.Color[D_NightCFlux] := 255255;
ScreenRec.UpRange[D_NightCFlux] := 100;
ScreenRec.LowRange[D_NightCFlux] := 0;
ScreenRec.Choose[D_SolubleCH2O] := FALSE;
ScreenRec.Color[D_SolublecH2O] := 255255;
ScreenRec.UpRange[D_SolubleCH2O] := 10;
ScreenRec.LowRange[D_SolubleCH2O] := 0;
ScreenRec.Choose[D_LAI] := TRUE;
ScreenRec.Color[D_LAI] := 10195204;
ScreenRec.UpRange[D_LAI] := 10;
ScreenRec.LowRange[D_LAI] := 0.0;
ScreenRec.Choose[D_pi] := FALSE;
ScreenRec.UpRange[D_pi] := 600;
ScreenRec.LowRange[D_pi] := 0.0;
ScreenRec.Choose[D_Wood] := TRUE;
ScreenRec.Color[D_Wood] := 500000;
ScreenRec.UpRange[D_Wood] := 250;
ScreenRec.LowRange[D_Wood] := 0.0;
ScreenRec.Choose[D_SapW] := FALSE;
ScreenRec.UpRange[D_SapW] := 100;
ScreenRec.LowRange[D_SapW] := 0.0;
ScreenRec.Choose[D_HeartW] := FALSE;
ScreenRec.UpRange[D_HeartW] := 100;
ScreenRec.LowRange[D_HeartW] := 0.0;
ScreenRec.Choose[D_Reserves] := FALSE;
ScreenRec.Color[D_Reserves] := 255255;
ScreenRec.UpRange[D_Reserves] := 10;
ScreenRec.LowRange[D_Reserves] := 0;
ScreenRec.Choose[D_Leaf] := FALSE;
ScreenRec.UpRange[D_Leaf] := 20;
ScreenRec.LowRange[D_Leaf] := 0.0;
ScreenRec.Choose[D_FineRoot] := FALSE;
ScreenRec.UpRange[D_FineRoot] := 10;
ScreenRec.LowRange[D_FineRoot] := 0.0;
ScreenRec.Choose[D_Bark] := FALSE;
ScreenRec.Color[D_Bark] := 255255;
ScreenRec.UpRange[D_Bark] := 10;
ScreenRec.LowRange[D_Bark] := 0;
ScreenRec.Choose[D_CoarseRoot] := FALSE;
ScreenRec.UpRange[D_CoarseRoot] := 50;
ScreenRec.LowRange[D_CoarseRoot] := 0.0;
ScreenRec.Choose[D_Branches] := FALSE;
ScreenRec.UpRange[D_Branches] := 10;
ScreenRec.LowRange[D_Branches] := 0.0;
ScreenRec.Choose[D_Reprod] := FALSE;
ScreenRec.UpRange[D_Reprod] := 1;
ScreenRec.LowRange[D_Reprod] := 0.0;
ScreenRec.Choose[D_Height] := FALSE;
ScreenRec.Color[D_Height] := 255255;
ScreenRec.UpRange[D_Height] := 50;
ScreenRec.LowRange[D_Height] := 0;
ScreenRec.Choose[D_DBH] := FALSE;
ScreenRec.Color[D_DBH] := 255255;
ScreenRec.UpRange[D_DBH] := 50;
ScreenRec.LowRange[D_DBH] := 0;
ScreenRec.Choose[D_CanopyCover] := FALSE;
ScreenRec.Color[D_CanopyCover] := 255255;
ScreenRec.UpRange[D_CanopyCover] := 1;
ScreenRec.LowRange[D_CanopyCover] := 0;
ScreenRec.Choose[D_kex] := FALSE;
ScreenRec.Color[D_kex] := 255255;
ScreenRec.UpRange[D_kex] := 1;
ScreenRec.LowRange[D_kex] := 0;
ScreenRec.Choose[D_BasalArea] := FALSE;
ScreenRec.Color[D_BasalArea] := 255255;
ScreenRec.UpRange[D_BasalArea] := 50;
ScreenRec.LowRange[D_BasalArea] := 0;
ScreenRec.Choose[D_Stocking] := FALSE;
ScreenRec.Color[D_Stocking] := 255255;
ScreenRec.UpRange[D_Stocking] := 5000;
ScreenRec.LowRange[D_Stocking] := 0;
ScreenRec.Choose[D_TDamage] := FALSE;
ScreenRec.Color[D_TDamage] := 255255;
ScreenRec.UpRange[D_TDamage] := 100;
ScreenRec.LowRange[D_TDamage] := 0;
ScreenRec.Choose[D_NConc] := TRUE;
ScreenRec.Color[D_NConc] := 400000;
ScreenRec.UpRange[D_NConc] := 30;
ScreenRec.LowRange[D_NConc] := 0.0;
ScreenRec.Choose[D_NConc1] := FALSE;
ScreenRec.Color[D_NConc1] := 255255;
ScreenRec.UpRange[D_NConc1] := 30;
ScreenRec.LowRange[D_NConc1] := 0;
ScreenRec.Choose[D_SolubleN] := FALSE;
ScreenRec.UpRange[D_SolubleN] := 100;
ScreenRec.LowRange[D_SolubleN] := 0.0;
ScreenRec.Choose[D_WoodN] := FALSE;
ScreenRec.UpRange[D_WoodN] := 100;
ScreenRec.LowRange[D_WoodN] := 0.0;
ScreenRec.Choose[D_SapWN] := FALSE;
ScreenRec.UpRange[D_SapWN] := 100;
ScreenRec.LowRange[D_SapWN] := 0.0;
ScreenRec.Choose[D_HeartWN] := FALSE;
ScreenRec.UpRange[D_HeartWN] := 100;
ScreenRec.LowRange[D_HeartWN] := 0.0;
ScreenRec.Choose[D_ReservesN] := FALSE;
ScreenRec.Color[D_ReservesN] := 255255;
ScreenRec.UpRange[D_ReservesN] := 200;
ScreenRec.LowRange[D_ReservesN] := 0;
ScreenRec.Choose[D_LeafN] := FALSE;
ScreenRec.UpRange[D_LeafN] := 200;
ScreenRec.LowRange[D_LeafN] := 0.0;
ScreenRec.Choose[D_FineRootN] := FALSE;
ScreenRec.UpRange[D_FineRootN] := 20;
ScreenRec.LowRange[D_FineRootN] := 0.0;
ScreenRec.Choose[D_BarkN] := FALSE;
ScreenRec.Color[D_BarkN] := 255255;
ScreenRec.UpRange[D_BarkN] := 100;
ScreenRec.LowRange[D_BarkN] := 0;
ScreenRec.Choose[D_CoarseRootN] := FALSE;
ScreenRec.UpRange[D_CoarseRootN] := 20;
ScreenRec.LowRange[D_CoarseRootN] := 0.0;
ScreenRec.Choose[D_BranchN] := FALSE;
ScreenRec.UpRange[D_BranchN] := 20;
ScreenRec.LowRange[D_BranchN] := 0.0;
ScreenRec.Choose[D_ReprodN] := FALSE;
ScreenRec.UpRange[D_ReprodN] := 10;
ScreenRec.LowRange[D_ReprodN] := 0.0;
ScreenRec.Choose[D_NSum] := FALSE;
ScreenRec.UpRange[D_NSum] := 10000;
ScreenRec.LowRange[D_NSum] := 0.0;
ScreenRec.Choose[D_CLeafLitter] := FALSE;
ScreenRec.Color[D_CLeafLitter] := 255255;
ScreenRec.UpRange[D_CLeafLitter] := 100;
ScreenRec.LowRange[D_CLeafLitter] := 0;
ScreenRec.Choose[D_CAll_Litter] := FALSE;
ScreenRec.Color[D_CAll_Litter] := 255255;
ScreenRec.UpRange[D_CAll_Litter] := 100;
ScreenRec.LowRange[D_CAll_Litter] := 0;
ScreenRec.Choose[D_CMetabSurf] := FALSE;
ScreenRec.UpRange[D_CMetabSurf] := 1;
ScreenRec.LowRange[D_CMetabSurf] := 0.0;
ScreenRec.Choose[D_CMetabSoil] := FALSE;
ScreenRec.UpRange[D_CMetabSoil] := 1;
ScreenRec.LowRange[D_CMetabSoil] := 0.0;
ScreenRec.Choose[D_CStructSurf] := FALSE;
ScreenRec.UpRange[D_CStructSurf] := 10;
ScreenRec.LowRange[D_CStructSurf] := 0.0;
ScreenRec.Choose[D_CStructSoil] := FALSE;
ScreenRec.UpRange[D_CStructSoil] := 10;
ScreenRec.LowRange[D_CStructSoil] := 0.0;
ScreenRec.Choose[D_CWoodyLitter] := FALSE;
ScreenRec.UpRange[D_CWoodyLitter] := 100;
ScreenRec.LowRange[D_CWoodyLitter] := 0.0;
ScreenRec.Choose[D_CActive] := FALSE;
ScreenRec.UpRange[D_CActive] := 10;
ScreenRec.LowRange[D_CActive] := 0.0;
ScreenRec.Choose[D_CSlow] := FALSE;
ScreenRec.UpRange[D_CSlow] := 50;
ScreenRec.LowRange[D_CSlow] := 0.000;
ScreenRec.Choose[D_CResistant] := FALSE;
ScreenRec.UpRange[D_CResistant] := 50;
ScreenRec.LowRange[D_CResistant] := 0.0;
ScreenRec.Choose[D_SoilRespn] := FALSE;
ScreenRec.Color[D_SoilRespn] := 255255;
ScreenRec.UpRange[D_SoilRespn] := 100;
ScreenRec.LowRange[D_SoilRespn] := 0;
ScreenRec.Choose[D_NLeafLitter] := FALSE;
ScreenRec.Color[D_NLeafLitter] := 255255;
ScreenRec.UpRange[D_NLeafLitter] := 10;
ScreenRec.LowRange[D_NLeafLitter] := 0;
ScreenRec.Choose[D_NAll_Litter] := FALSE;
ScreenRec.Color[D_NAll_Litter] := 255255;
ScreenRec.UpRange[D_NAll_Litter] := 10;
ScreenRec.LowRange[D_NAll_Litter] := 0;
ScreenRec.Choose[D_NMetabSurf] := FALSE;
ScreenRec.UpRange[D_NMetabSurf] := 50;
ScreenRec.LowRange[D_NMetabSurf] := 0.0;
ScreenRec.Choose[D_NMetabSoil] := FALSE;
ScreenRec.UpRange[D_NMetabSoil] := 50;
ScreenRec.LowRange[D_NMetabSoil] := 0.0;
ScreenRec.Choose[D_NStructSurf] := FALSE;
ScreenRec.UpRange[D_NStructSurf] := 50;
ScreenRec.LowRange[D_NStructSurf] := 0.0;
ScreenRec.Choose[D_NStructSoil] := FALSE;
ScreenRec.UpRange[D_NStructSoil] := 50;
ScreenRec.LowRange[D_NStructSoil] := 0.0;
ScreenRec.Choose[D_NWoodyLitter] := FALSE;
ScreenRec.UpRange[D_NWoodyLitter] := 20;
ScreenRec.LowRange[D_NWoodyLitter] := 0.0;
ScreenRec.Choose[D_NActive] := FALSE;
ScreenRec.UpRange[D_NActive] := 1000;
ScreenRec.LowRange[D_NActive] := 0.0;
ScreenRec.Choose[D_NSlow] := FALSE;
ScreenRec.UpRange[D_NSlow] := 5000;
ScreenRec.LowRange[D_NSlow] := 0.0000;
ScreenRec.Choose[D_NResistant] := FALSE;
ScreenRec.UpRange[D_NResistant] := 5000;
ScreenRec.LowRange[D_NResistant] := 0.0;
ScreenRec.Choose[D_NMineral] := TRUE;
ScreenRec.Color[D_NMineral] := 10000;
ScreenRec.UpRange[D_NMineral] := 1.00;
ScreenRec.LowRange[D_NMineral] := 0.0;
ScreenRec.Choose[D_NLeached] := TRUE;
ScreenRec.Color[D_NLeached] := 10000;
ScreenRec.UpRange[D_NLeached] := 1.00;
ScreenRec.LowRange[D_NLeached] := 0.0;
ScreenRec.Choose[D_Tmax] := FALSE;
ScreenRec.UpRange[D_Tmax] := 40.00000;
ScreenRec.LowRange[D_Tmax] := 0.0;
ScreenRec.Choose[D_Tmin] := FALSE;
ScreenRec.UpRange[D_Tmin] := 40.00000;
ScreenRec.LowRange[D_Tmin] := 0.0;
ScreenRec.Choose[D_Tmean] := FALSE;
ScreenRec.UpRange[D_Tmean] := 40.00000;
ScreenRec.LowRange[D_Tmean] := 0.00000;
ScreenRec.Choose[D_Tsoil] := FALSE;
ScreenRec.UpRange[D_Tsoil] := 40.00000;
ScreenRec.LowRange[D_Tsoil] := 0.0;
ScreenRec.Choose[D_Tday] := FALSE;
ScreenRec.UpRange[D_Tday] := 40.00000;
ScreenRec.LowRange[D_Tday] := 0.0;
ScreenRec.Choose[D_Radn] := FALSE;
ScreenRec.UpRange[D_Radn] := 40.0000;
ScreenRec.LowRange[D_Radn] := 0.0;
ScreenRec.Choose[D_CO2] := FALSE;
ScreenRec.UpRange[D_CO2] := 400.0000;
ScreenRec.LowRange[D_CO2] := 0.0;
ScreenRec.Choose[D_Rain] := FALSE;
ScreenRec.UpRange[D_Rain] := 100.00000;
ScreenRec.LowRange[D_Rain] := 0.0;
ScreenRec.Choose[D_StoredWater] := FALSE;
ScreenRec.UpRange[D_StoredWater] := 400.0000;
ScreenRec.LowRange[D_StoredWater] := 0.0;
ScreenRec.Choose[D_AbsHum] := FALSE;
ScreenRec.UpRange[D_AbsHum] := 40.00000;
ScreenRec.LowRange[D_AbsHum] := 0.0;
ScreenRec.Choose[D_RelHum] := FALSE;
ScreenRec.UpRange[D_RelHum] := 110;
ScreenRec.LowRange[D_RelHum] := 0.0;
ScreenRec.Choose[D_WaterLimit] := FALSE;
ScreenRec.UpRange[D_WaterLimit] := 1.100000;
ScreenRec.LowRange[D_WaterLimit] := 0.0;
ScreenRec.Choose[D_Transpiration] := FALSE;
ScreenRec.UpRange[D_Transpiration] := 10.00000;
ScreenRec.LowRange[D_Transpiration] := 0.0;
ScreenRec.Choose[D_Evaporation] := FALSE;
ScreenRec.UpRange[D_Evaporation] := 10.00000;
ScreenRec.LowRange[D_Evaporation] := 0.0;
ScreenRec.Choose[D_Drainage] := FALSE;
ScreenRec.Color[D_Drainage] := 10000;
ScreenRec.UpRange[D_Drainage] := 10;
ScreenRec.LowRange[D_Drainage] := 0.0;
ScreenRec.Choose[D_HeatSum] := FALSE;
ScreenRec.Color[D_HeatSum] := 10000;
ScreenRec.UpRange[D_HeatSum] := 1000;
ScreenRec.LowRange[D_HeatSum] := 0.0;
ScreenRec.Choose[D_Snow] := FALSE;
ScreenRec.Color[D_Snow] := 10000;
ScreenRec.UpRange[D_Snow] := 100;
ScreenRec.LowRange[D_Snow] := 0.0;
ScreenRec.Choose[D_Dummy] := FALSE;
ScreenRec.Color[D_Dummy] := 10000;
ScreenRec.UpRange[D_Dummy] := 1000;
ScreenRec.LowRange[D_Dummy] := 0.0;
SaveVar.Choose[S_Year] := TRUE;
SaveVar.Choose[S_Month] := TRUE;
SaveVar.Choose[S_Day] := TRUE;
SaveVar.Choose[S_LAI] := FALSE;
SaveVar.Choose[S_SapWoodC] := FALSE;
SaveVar.Choose[S_HeartWoodC] := FALSE;
SaveVar.Choose[S_LeafC] := FALSE;
SaveVar.Choose[S_FineRootC] := FALSE;
SaveVar.Choose[S_CoarseRootC] := FALSE;
SaveVar.Choose[S_BranchesC] := FALSE;
SaveVar.Choose[S_ReprodC] := FALSE;
SaveVar.Choose[S_SapWoodN] := FALSE;
SaveVar.Choose[S_HeartWoodN] := FALSE;
SaveVar.Choose[S_LeafN] := FALSE;
SaveVar.Choose[S_FineRootN] := FALSE;
SaveVar.Choose[S_CoarseRootN] := FALSE;
SaveVar.Choose[S_BranchesN] := FALSE;
SaveVar.Choose[S_ReprodN] := FALSE;
SaveVar.Choose[S_NConc] := FALSE;
SaveVar.Choose[S_pi] := FALSE;
SaveVar.Choose[S_CAI] := FALSE;
SaveVar.Choose[S_NPP] := FALSE;
SaveVar.Choose[S_CarbonGain] := FALSE;
SaveVar.Choose[S_CMetabolic] := FALSE;
SaveVar.Choose[S_NMetabolic] := FALSE;
SaveVar.Choose[S_CStructural] := FALSE;
SaveVar.Choose[S_NStructural] := FALSE;
SaveVar.Choose[S_CWoodyLitter] := FALSE;
SaveVar.Choose[S_NWoodyLitter] := FALSE;
SaveVar.Choose[S_CActive] := FALSE;
SaveVar.Choose[S_NActive] := FALSE;
SaveVar.Choose[S_CSlow] := FALSE;
SaveVar.Choose[S_NSlow] := FALSE;
SaveVar.Choose[S_CResistant] := FALSE;
SaveVar.Choose[S_NResistant] := FALSE;
SaveVar.Choose[S_NMineral] := FALSE;
SaveVar.Choose[S_Tmax] := FALSE;
SaveVar.Choose[S_Tmin] := FALSE;
SaveVar.Choose[S_Tmean] := FALSE;
SaveVar.Choose[S_Tsoil] := TRUE;
SaveVar.Choose[S_Tday] := FALSE;
SaveVar.Choose[S_Radn] := FALSE;
SaveVar.Choose[S_Rain] := FALSE;
SaveVar.Choose[S_StoredWater] := TRUE;
SaveVar.Choose[S_AbsHum] := FALSE;
SaveVar.Choose[S_RelHum] := FALSE;
SaveVar.Choose[S_WaterLimit] := FALSE;
SaveVar.Choose[S_Evaporation] := FALSE;
SaveVar.Choose[S_Dummy] := FALSE;
WeatherFile[W_Tmax] := TRUE;
WeatherFile[W_Tmin] := TRUE;
WeatherFile[W_Tmean] := FALSE;
WeatherFile[W_Tsoil] := FALSE;
WeatherFile[W_Radn] := TRUE;
WeatherFile[W_Rain] := FALSE;
WeatherFile[W_AbsHum] := FALSE;
WeatherFile[W_RelHum] := FALSE;
WeatherFile[W_CO2] := FALSE;
Parameter.MortalityType := Fraction;
Control.BatchCalcs := 1;
Control.Equil.EquilTarget := LeafNConc;
Control.Equil.EquilParameter := BiolNFix;
Control.Equil.MaxIterations := 500;
Control.Equil.MaxGoodCount := 10;
Control.Equil.SamePlantPools := true;
Event.nFertilisations := 0;
Event.nHarvests := 0;
Event.nEnvironments := 0;
Event.nPests := 0;
Event.nFires := 0;
Event.Irrigate := FALSE;
Event.IrrigationType := 'S';
Event.IrrigationAmount := 50.0;
Event.IrrigationFraction := 0.95;
Event.IrrigationInterval := 14;
Control.nYears := 50;
Control.nMonths := 0;
Control.nDays := 0;
Control.nDisplays := 400;
Control.nDiskOut := 2000;
Control.CalcType := 'D';
Control.DecayOnly := FALSE;
Control.AllOneLayer := FALSE;
Control.OutputByLayer := true;
Control.IncludeIsotopes := false;
Control.nProjects := 0;
Control.ClimType := 'S';
Control.ClimFile := 'CenW.CL!';
Control.FileOut := 'CenW.DT!';
Control.ProjectFile := 'CenW.PJ!';
Control.PlantFile := 'CenW.PL!';
Control.SiteFile := 'CenW.ST!';
Control.PoolFile := 'CenW.IL!';
Control.BatchFile := 'CenW.BT!';
Control.Initial.Days := 1;
Control.Initial.Months := 1;
Control.Initial.Years := 2000;
Control.ResetPlantPools := true;
End; {of Procedure 'ProjectDefaults'}

Procedure PlantDefaults;
Begin
BooleanPlantVariables('D', 'Dummy', 'Dummy', Control.Dummy);
RealPlantVariables('D', 'Dummy', 'Dummy', Control.Dummy);
Parameter.VariableNFixation := true;
Parameter.RespnType := Ratio;
Parameter.RespnTAcclimation := true;
Parameter.SexAge := 10;
Parameter.SapWoodYears := 10;
Parameter.DirectEvapType := 'L';
Parameter.AgeDecline := false;
Parameter.SizeDecline := false;
Parameter.FoliageClumping := true;
Parameter.MatureAge := 100;
Parameter.MatureSize := 500;
Parameter.ConstantLeafN := false;
Parameter.Phs := C3;
Parameter.Phenology.nChanges := 0;
Parameter.SetDeltaType := CalculateValue;
End; {of Procedure 'PlantDefaults'}

Procedure SiteDefaults;
Begin
RealSiteVariables('D', 'Dummy', 'Dummy', Control.Dummy);
If (Soil.nLayers < 1) or (Soil.nLayers > 7) then // This is just for initialising runs. Have to make sure it does not create a conflict between layers set
   Soil.nLayers := 7;                            // by site and initial pools files. So, if a reasonable value has been set, just use that.
Soil.WaterLayer[1].Depth := 10.0;
Soil.WaterLayer[1].Pores := 20;
Soil.WaterLayer[1].MaxWater := 20.0;
Soil.WaterLayer[1].WaterContent := 10.0;
Soil.WaterLayer[1].ExtractEffort := 1.0;
Soil.WaterLayer[1].RelEvap := 1.0;
Soil.WaterLayer[2].Depth := 10.0;
Soil.WaterLayer[2].Pores := 20;
Soil.WaterLayer[2].MaxWater := 20.0;
Soil.WaterLayer[2].WaterContent := 90.0;
Soil.WaterLayer[2].ExtractEffort := 1.0;
Soil.WaterLayer[2].RelEvap := 0.0;
Soil.WaterLayer[3].Depth := 20.0;
Soil.WaterLayer[3].Pores := 15;
Soil.WaterLayer[3].MaxWater := 30.0;
Soil.WaterLayer[3].WaterContent := 15.0;
Soil.WaterLayer[3].ExtractEffort := 0.5;
Soil.WaterLayer[3].RelEvap := 0.0;
Soil.WaterLayer[4].Depth := 10.0;
Soil.WaterLayer[4].Pores := 20;
Soil.WaterLayer[4].MaxWater := 20.0;
Soil.WaterLayer[4].WaterContent := 10.0;
Soil.WaterLayer[4].ExtractEffort := 1.0;
Soil.WaterLayer[4].RelEvap := 1.0;
Soil.WaterLayer[5].Depth := 50.0;
Soil.WaterLayer[5].Pores := 20;
Soil.WaterLayer[5].MaxWater := 100.0;
Soil.WaterLayer[5].WaterContent := 50.0;
Soil.WaterLayer[5].ExtractEffort := 0.1;
Soil.WaterLayer[5].RelEvap := 0.0;
Soil.WaterLayer[6].Depth := 50.0;
Soil.WaterLayer[6].Pores := 15;
Soil.WaterLayer[6].MaxWater := 75.0;
Soil.WaterLayer[6].WaterContent := 50.0;
Soil.WaterLayer[6].ExtractEffort := 0.01;
Soil.WaterLayer[6].RelEvap := 0.0;
Soil.WaterLayer[7].Depth := 50.0;
Soil.WaterLayer[7].Pores := 15;
Soil.WaterLayer[7].MaxWater := 75.0;
Soil.WaterLayer[7].WaterContent := 50.0;
Soil.WaterLayer[7].ExtractEffort := 0.005;
Soil.WaterLayer[7].RelEvap := 0.0;
Soil.FineRootLitterIn[1] := 1;
Soil.FineRootLitterIn[2] := 0.5;
Soil.FineRootLitterIn[3] := 0.1;
Soil.FineRootLitterIn[4] := 0.05;
Soil.FineRootLitterIn[5] := 0.01;
Soil.FineRootLitterIn[6] := 0.005;
Soil.CoarseRootLitterIn[1] := 1;
Soil.CoarseRootLitterIn[2] := 0.5;
Soil.CoarseRootLitterIn[3] := 0.2;
Soil.CoarseRootLitterIn[1] := 0.1;
Soil.CoarseRootLitterIn[2] := 0.05;
Soil.CoarseRootLitterIn[3] := 0.025;
Parameter.Decay8 := SOMDecay1 / Parameter.DecayBranch_StructRatio;
Parameter.Decay9 := SOMDecay1 / Parameter.DecayWood_StructRatio;
Parameter.Decay10 := SOMDecay7 * Parameter.Inert_Resistant_Ratio;
End; {of Procedure 'SiteDefaults'}

Procedure PoolDefaults;
var iLayer: integer;
Begin
Soil.nLayers := 6;
Control.AllOneLayer := false;
Control.OutputByLayer := true;
Soil.Struct[0, C] := 5000;
Soil.Struct[1, C] := 1000;
Soil.Struct[2, C] := 500;
Soil.Struct[3, C] := 50;
Soil.Struct[4, C] := 10;
Soil.Struct[5, C] := 5;
Soil.Struct[6, C] := 1;
Soil.Struct[0, N] := 15;
Soil.Struct[1, N] := 1;
Soil.Struct[2, N] := 0.5;
Soil.Struct[3, N] := 0.05;
Soil.Struct[4, N] := 0.01;
Soil.Struct[5, N] := 0.005;
Soil.Struct[6, N] := 0.001;
Soil.Metab[0, C] := 0;
Soil.Metab[1, C] := 0;
Soil.Metab[2, C] := 0;
Soil.Metab[3, C] := 0;
Soil.Metab[4, C] := 0;
Soil.Metab[5, C] := 0;
Soil.Metab[6, C] := 0;
Soil.Metab[0, N] := 0;
Soil.Metab[1, N] := 0;
Soil.Metab[2, N] := 0;
Soil.Metab[3, N] := 0;
Soil.Metab[4, N] := 0;
Soil.Metab[5, N] := 0;
Soil.Metab[6, N] := 0;
Soil.FineWood[0, C] := 250;
Soil.FineWood[0, N] := 0.5;
Soil.CoarseWood[0, C] := 0;
Soil.CoarseWood[1, C] := 0;
Soil.CoarseWood[2, C] := 0;
Soil.CoarseWood[3, C] := 0;
Soil.CoarseWood[4, C] := 0;
Soil.CoarseWood[5, C] := 0;
Soil.CoarseWood[6, C] := 0;
Soil.CoarseWood[0, N] := 0;
Soil.CoarseWood[1, N] := 0;
Soil.CoarseWood[2, N] := 0;
Soil.CoarseWood[3, N] := 0;
Soil.CoarseWood[4, N] := 0;
Soil.CoarseWood[5, N] := 0;
Soil.CoarseWood[6, N] := 0;
Soil.Active[0, C] := 100;
Soil.Active[1, C] := 700;
Soil.Active[2, C] := 300;
Soil.Active[3, C] := 100;
Soil.Active[4, C] := 50;
Soil.Active[5, C] := 25;
Soil.Active[6, C] := 10;
Soil.Active[0, N] := 10;
Soil.Active[1, N] := 70;
Soil.Active[2, N] := 30;
Soil.Active[3, N] := 10;
Soil.Active[4, N] := 5;
Soil.Active[5, N] := 2.5;
Soil.Active[6, N] := 1;
Soil.Slow[0, C] := 500;
Soil.Slow[1, C] := 5000;
Soil.Slow[2, C] := 2500;
Soil.Slow[3, C] := 1000;
Soil.Slow[4, C] := 500;
Soil.Slow[5, C] := 250;
Soil.Slow[6, C] := 100;
Soil.Slow[0, N] := 10;
Soil.Slow[1, N] := 150;
Soil.Slow[2, N] := 100;
Soil.Slow[3, N] := 75;
Soil.Slow[4, N] := 40;
Soil.Slow[5, N] := 20;
Soil.Slow[6, N] := 10;
Soil.Resistant[0, C] := 100;
Soil.Resistant[1, C] := 10000;
Soil.Resistant[2, C] := 10000;
Soil.Resistant[3, C] := 5000;
Soil.Resistant[4, C] := 3000;
Soil.Resistant[5, C] := 2000;
Soil.Resistant[6, C] := 1000;
Soil.Resistant[0, N] := 5;
Soil.Resistant[1, N] := 600;
Soil.Resistant[2, N] := 600;
Soil.Resistant[3, N] := 400;
Soil.Resistant[4, N] := 300;
Soil.Resistant[5, N] := 200;
Soil.Resistant[6, N] := 100;
Soil.Inert[0, C] := 0;
Soil.Inert[1, C] := 0;
Soil.Inert[2, C] := 0;
Soil.Inert[3, C] := 0;
Soil.Inert[4, C] := 0;
Soil.Inert[5, C] := 0;
Soil.Inert[6, C] := 0;
Soil.Inert[0, N] := 0;
Soil.Inert[1, N] := 0;
Soil.Inert[2, N] := 0;
Soil.Inert[3, N] := 0;
Soil.Inert[4, N] := 0;
Soil.Inert[5, N] := 0;
Soil.Inert[6, N] := 0;
Soil.Soluble[0, C] := 0;
Soil.Soluble[1, C] := 0;
Soil.Soluble[2, C] := 0;
Soil.Soluble[3, C] := 0;
Soil.Soluble[4, C] := 0;
Soil.Soluble[5, C] := 0;
Soil.Soluble[6, C] := 0;
Soil.Soluble[0, N] := 0;
Soil.Soluble[1, N] := 0;
Soil.Soluble[2, N] := 0;
Soil.Soluble[3, N] := 0;
Soil.Soluble[4, N] := 0;
Soil.Soluble[5, N] := 0;
Soil.Soluble[6, N] := 0;
Litter.CoarseWood[C] := 0;
Litter.CoarseWood[N] := 0;
Litter.FineWood[C] := 0;
Litter.FineWood[N] := 0;
Litter.CoarseRoot[C] := 0;
Litter.CoarseRoot[N] := 0;
Litter.FineRoot[C] := 0;
Litter.FineRoot[N] := 0;
Litter.Leaves[C] := 0;
Litter.Leaves[N] := 0;
Litter.Other[C] := 0;
Litter.Other[N] := 0;
Plant.Sapwood[C] := 0;
Plant.sapwood[N] := 0;
Plant.Heartwood[C] := 0;
Plant.Heartwood[N] := 0;
Plant.Coarseroot[C] := 0;
Plant.Coarseroot[N] := 0;
Plant.Fineroot[C] := 0;
Plant.Fineroot[N] := 0;
Plant.Branches[C] := 0;
Plant.Branches[N] := 0;
Plant.Bark[C] := 0;
Plant.Bark[N] := 0;
Plant.Leaves[C] := 100;
Plant.Leaves[N] := 3;
Plant.Reserves[C] := 0;
Plant.Reserves[N] := 0;
Plant.Pollen[C] := 0;
Plant.Pollen[N] := 0;
Plant.Fruit[C] := 0;
Plant.Fruit[N] := 0;
Plant.Stocking := 5000;
Plant.Height := 0;
Plant.Area := 0;
Plant.DBH := 0;
Plant.CanopyCover := (pi * sqr((0.7544+0.2073*Plant.DBH)/2))*Plant.Stocking/10000; // added Simioni 19/02/2002
if Plant.CanopyCover>1 then Plant.CanopyCover := 1;
Plant.kex := Parameter.Kexmax * ((1-Parameter.KlowRange) * Plant.CanopyCover + Parameter.KlowRange); // Simioni 19/02/2002 effect of foliage clumping on light interception
Soil.LitterLig[0] := 0.5;
Soil.LitterLig[1] := 0.25;
Soil.LitterLig[2] := 0.25;
Soil.LitterLig[3] := 0.25;
Soil.LitterLig[4] := 0.25;
Soil.LitterLig[5] := 0.25;
Soil.LitterLig[6] := 0.25;
Soil.BranchLig[0] := 0.5;
Soil.StemLig[0] := 0.5;
Soil.StemLig[1] := 0.5;
Soil.StemLig[2] := 0.5;
Soil.StemLig[3] := 0.5;
Soil.StemLig[4] := 0.5;
Soil.StemLig[5] := 0.5;
Soil.StemLig[6] := 0.5;
Soil.TotalWater := 0;
For iLayer := 1 to Soil.nLayers do
    Begin
    Soil.WaterLayer[iLayer].WaterContent := 0.5 * Soil.WaterLayer[iLayer].MaxWater;
    Soil.TotalWater := Soil.TotalWater + Soil.WaterLayer[iLayer].WaterContent;
    End;
Soil.Snow := 0;
Control.TotalYears := 2000;
Control.ExtraMonths := 1;
Control.ExtraDays := 1;
Plant.Age := 0;
Derived.TDamageUnits := 0;
Derived.WaterLimit := 1;
Derived.DecompLimit := 0;
Derived.LeafGrowth := 1;
Derived.Deciduous := 0;
Derived.ExcessN := 0;
Derived.RespnBase := 10;
Derived.HeatSum := 0;
Weather.LastMin := 5;
Weather.TSoil := 10;
Control.NextPhenology := 1;
End; {of Procedure 'PoolDefaults'}

{ --- end of file DEFAULTS.PAS ------------------------------------------ }

End.
