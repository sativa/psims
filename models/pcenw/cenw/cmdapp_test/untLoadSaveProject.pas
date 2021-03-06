{ ================================================================
  = Project   : CenW                                             =
  ================================================================
  = Modules   : GenProject                                       =
  =             SaveProject                                      =
  =                                                              =
  =             Routines to load and save the                    =
  =             project-parameters file.                         =
  =             The save/retrieve algorithms are set up in such  =
  =             a way that new information can easily be added   =
  =             to the list of parameters saved previously       =
  =             so that saved information can remain valid over  =
  =             successvive upgrades of the program.             =
  ================================================================
  = File      : untLoadSaveProject.PAS                           =
  =                                                              =
  = Version   : 4.0                                              =
  ================================================================ }

Unit untLoadSaveProject;

{$V-}
INTERFACE

Uses SysUtils, untDeclarations, untDivideValidation, untFieldValidation;

Procedure RealProjectVariables(ReadWrite: Char; CommentStr, VarStr: String; var defp: Text);
Procedure GenProject(name : string);
Procedure SaveProject(name : string);

IMPLEMENTATION

Procedure ReadInteger (Var Item: Integer; Comment, CommentStr, VarStr: String);
var ErrCode: Integer;
Begin
If CommentStr = Comment then
   val (VarStr, Item, ErrCode);
End; {of Procedure 'ReadInteger'}

Procedure IntegerOut (Datum: Integer; Comment: string; var Defp: Text);
Begin
Writeln (Defp, Datum: ParFileMaxWidth, ' ', Comment);
End;  {of Procedure 'IntegerOut'}

Procedure ReadReal (Var Item: double; Comment, CommentStr, VarStr: String);
var ErrCode: Integer;
Begin
If CommentStr = Comment then
   val (VarStr, Item, ErrCode);
End; {of Procedure 'ReadReal'}

Procedure RealOut (Datum: double; Comment: string; var Defp: Text);
var Width, Digits: integer;
Begin
GetField(Datum, ParFileMaxWidth, Width, Digits);
Writeln (Defp, Datum: ParFileMaxWidth: Digits, ' ', Comment);
End;  {of Procedure 'RealOut'}

Procedure BoolVarIn (Var Item: Boolean; Comment, CommentStr, VarStr: String);
Var Ch: char;
Begin
If CommentStr = Comment then
   Begin
   Ch := VarStr[1];
   IF Ch = 'T' then
      Item := true
   Else
      Item := false;
   End
Else
   {Do nothing}
End; {of Procedure 'BoolVarIn'}

Procedure BoolVarOut (Var Item: Boolean; Comment: String; var Defp: Text);
Begin
Writeln (defp, Item:1, ' ', Comment);
End; {of Procedure 'BoolVarOut'}

Procedure IntegerProjectVariables(ReadWrite: Char; CommentStr, VarStr: String; var defp: Text);

    Procedure ProcessNext(var NextVar: Integer; ProcessString: String; DefaultValue: Integer;
                          CommentStr, VarStr: String; ReadWrite: Char; var Defp: Text);
    Begin
    if ReadWrite = 'R' then
       ReadInteger (NextVar, ProcessString, CommentStr, VarStr)
    Else if ReadWrite = 'W' then
       IntegerOut (NextVar, ProcessString, Defp)
    Else {if ReadWrite = 'D' then}
       NextVar := DefaultValue;
    End;

Begin
ProcessNext (Control.nCohorts, 'Number of cohorts to simulate', 1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (MaxWidth, 'Variable to define the width for each variable in the output file', 8, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Event.IrrigationInterval, 'Interval between applications of irrigation', 3, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Event.IrrigStartDay, 'Starting day for irrigation', -1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Event.IrrigStartMonth, 'Starting month for irrigation', -1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Event.IrrigStartYear, 'Starting year for irrigation', -1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Event.IrrigEndDay, 'Last day for irrigation', -1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Event.IrrigEndMonth, 'Last month for irrigation', -1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Event.IrrigEndYear, 'Last year for irrigation', -1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.nYears, 'years for simulation run', 50, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.nMonths, 'months for simulation run', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.nDays, 'number of days for simulation run', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Age, 'Initial setting for stand age', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Days, 'Initial setting starting day', 1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Months, 'Initial setting starting month', 1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Years, 'Initial setting starting year', 2000, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Spatial.Initial, 'Initial for spatial runs', 1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Spatial.Calcs, 'Calculations for spatial runs', -1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.BatchCalcs, 'For batch run: number of calculations', -1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Equil.MaxIterations, 'Maximum number of iterations for equlibrium runs', 500, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Equil.MaxGoodCount, 'Required number of good fits to satisfy user of equlibrium conditions', 10, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Equil.OscillationCount, 'Sequence length to check for oscillations', 3, CommentStr, VarStr, ReadWrite, Defp);
End; {of Procedure 'IntegerProjectVariables'}

Procedure BooleanProjectVariables(ReadWrite: Char; CommentStr, VarStr: String; var defp: Text);

    Procedure ProcessNext(var NextVar: Boolean; ProcessString: String; DefaultValue: Boolean;
                          CommentStr, VarStr: String; ReadWrite: Char; var Defp: Text);
    Begin
    if ReadWrite = 'R' then
       BoolVarIn (NextVar, ProcessString, CommentStr, VarStr)
    Else if ReadWrite = 'W' then
       BoolVarOut (NextVar, ProcessString, Defp)
    Else {if ReadWrite = 'D' then}
       NextVar := DefaultValue;
    End;

Begin
ProcessNext (WeatherFile[W_Tmax], 'Boolean variable to read Tmax', True, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (WeatherFile[W_Tmin], 'Boolean variable to read Tmin', True, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (WeatherFile[W_Tmean], 'Boolean variable to read Tmean', False, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (WeatherFile[W_Tsoil], 'Boolean variable to read Tsoil', False, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (WeatherFile[W_Tmax], 'Boolean variable to read Tmax', False, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (WeatherFile[W_Radn], 'Boolean variable to read Radn', True, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (WeatherFile[W_Rain], 'Boolean variable to read Rainfall', True, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (WeatherFile[W_AbsHum], 'Boolean variable to read absolute humidity', False, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (WeatherFile[W_RelHum], 'Boolean variable to read relative humidity', False, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (WeatherFile[W_CO2], 'Boolean variable to read CO2 concentration', False, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.DecayOnly, 'Boolean variable for calculations of organic matter decomposition only', False, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.AllOneLayer, 'Boolean variable for organic matter to be treated as single layer', False, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.ResetPlantPools, 'Boolean variable to indicate whether plant pools should be reset at the beginning of a run', False, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.OutputByLayer, 'Boolean variable whether output is to be given by soil layer', True, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.IncludeIsotopes, 'Boolean variable whether to include information about carbon isotopes', False, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.IncludeP, 'Boolean variable whether to include the phosphorus cycle', False, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Spatial.ShowNumeric, 'Boolean variable whether to give numeric output as part of spatial runs', True, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Equil.SamePlantPools, 'Boolean variable to indiate whether to keep the same initial plant pools in searching for equilibrium', True, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Equil.AdjustPInput, 'Boolean variable to indiate whether to adjust P input rates in searching for equilibrium', True, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.NoticeFlags, 'Indicates whether to include flags in the output for background events', True, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.IncludeWeeds, 'Indicates whether to include weed competition', False, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Event.AdjustVP, 'Indicates whether to include vapur pressure adjustments if the tempeature is changed', True, CommentStr, VarStr, ReadWrite, Defp);
End; {of Procedure 'BooleanProjectVariables'}

Procedure RealProjectVariables(ReadWrite: Char; CommentStr, VarStr: String; var defp: Text);

    Procedure ProcessNext(var NextVar: double; ProcessString: String; DefaultValue: double;
                          CommentStr, VarStr: String; ReadWrite: Char; var Defp: Text);
    Begin
    if ReadWrite = 'R' then
       ReadReal (NextVar, ProcessString, CommentStr, VarStr)
    Else if ReadWrite = 'W' then
       RealOut (NextVar, ProcessString, Defp)
    Else {if ReadWrite = 'D' then}
       NextVar := DefaultValue;
    End;

Begin
ProcessNext (Parameter.FertilityAdjust, 'Adjustment to soil fertility level at start-up', 1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Parameter.StemDeath, 'Fraction of trees dying annually', 0.01/ 365, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Parameter.FertiliserRelease, 'Daily rate of fertiliser release', 0.1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.SapWood[C], 'Initial setting for sapwood carbon', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.HeartWood[C], 'Initial setting for heartwood carbon', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.CoarseRoot[C], 'Initial setting for coarseroot carbon', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.FineRoot[C], 'Initial setting for fineroot carbon', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Branches[C], 'Initial setting for branch carbon', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Bark[C], 'Initial setting for bark carbon', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Leaves[C], 'Initial setting for foliage carbon', 100, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Pollen[C], 'Initial setting for pollen carbon', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Fruit[C], 'Initial setting for fruit carbon', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Soluble[C], 'Initial setting for soluble carbon', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Reserves[C], 'Initial setting for leaf primordia carbon', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.WeedLeaves[C], 'Initial setting for weed leaf carbon', 100, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.WeedRoots[C], 'Initial setting for weed root carbon', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.SapWood[N], 'Initial setting for sapwood nitrogen', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.HeartWood[N], 'Initial setting for heartwood nitrogen', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.CoarseRoot[N], 'Initial setting for coarseroot nitrogen', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.FineRoot[N], 'Initial setting for fineroot nitrogen', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Branches[N], 'Initial setting for branch nitrogen', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Bark[N], 'Initial setting for bark nitrogen', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Leaves[N], 'Initial setting for foliage nitrogen', 5, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Pollen[N], 'Initial setting for pollen nitrogen', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Fruit[N], 'Initial setting for fruit nitrogen', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Soluble[N], 'Initial setting for soluble nitrogen', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Reserves[N], 'Initial setting for leaf primordia nitrogen', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.WeedLeaves[N], 'Initial setting for weed leaf nitrogen', 2, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.WeedRoots[N], 'Initial setting for weed root nitrogen', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.SapWood[P], 'Initial setting for sapwood phosphorus', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.HeartWood[P], 'Initial setting for heartwood phosphorus', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.CoarseRoot[P], 'Initial setting for coarseroot phosphorus', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.FineRoot[P], 'Initial setting for fineroot phosphorus', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Branches[P], 'Initial setting for branch phosphorus', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Bark[P], 'Initial setting for bark phosphorus', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Leaves[P], 'Initial setting for foliage phosphorus', 1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Pollen[P], 'Initial setting for pollen phosphorus', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Fruit[P], 'Initial setting for fruit phosphorus', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Soluble[P], 'Initial setting for soluble phosphorus', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Reserves[P], 'Initial setting for leaf primordia phosphorus', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.WeedLeaves[P], 'Initial setting for weed leaf phosphorus', 0.5, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.WeedRoots[P], 'Initial setting for weed root phosphorus', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Stocking, 'Initial setting for stocking', 1000, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.Height, 'Initial setting for height', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Initial.DBH, 'Initial setting for diameter', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.CConversion, 'Coefficient to convert between carbon and biomass', 2, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.NConversion, 'Coefficient to convert between nitrogen units in model and output', 1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Parameter.gamma, 'Conversion factor from MJ to umol', 2000000, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Parameter.DeathRatio, 'Ratio of tree sizes of dieing and average trees', 0.1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Equil.Criterion1, 'Value for equilibrium criterium 1 in equilibrium runs', 0.01, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Equil.Criterion2, 'Value for equilibrium criterium 2 in equilibrium runs', 0.01, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Equil.Criterion3, 'Value for equilibrium criterium 3 in equilibrium runs', 0.01, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Equil.TargetValue, 'Target value for equilibrium runs', 0.02, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Equil.TargetPlimit, 'Target value for phosphorus limitation', 0.95, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Equil.DeltaMin, 'Minimum delta value for equilibrium runs', 0.1, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Equil.DeltaMax, 'Maximum delta value for equilibrium runs', 10, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Equil.DeltaAdjust, 'Percentage adjustment of delta value for equilibrium runs', 50, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Equil.MaxChangeRatio, 'Maximum change ratio in equilibrium runs', 1.5, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Equil.BoostResistant, 'Boosting of changes in resistant organic matter relative to other changes', 10, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (TestSens.Range, 'Fractional change in variables for testing sensitivity', 0.01, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Spatial.LongMin, 'Minimum Longitude for spatial mode', 166, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Spatial.LongMax, 'Maximum Longitude for spatial mode', 179, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Spatial.integererval, 'Longitude interval for spatial mode', 0.25, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Spatial.LatMin, 'Minimum Latitude for spatial mode', -34, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Spatial.LatMax, 'Maximum Latitude for spatial mode', -48, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Spatial.LatInterval, 'Latitude interval for spatial mode', 0.25, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Spatial.RainMin, 'Minimum rain for spatial mode', 50, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Spatial.RainMax, 'Maximum rain for spatial mode', 3000, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Spatial.TempMin, 'Minimum temperature for spatial mode', 0, CommentStr, VarStr, ReadWrite, Defp);
ProcessNext (Control.Spatial.TempMax, 'Maximum temperature for spatial mode', 40, CommentStr, VarStr, ReadWrite, Defp);
End; {of Procedure 'RealProjectVariables'}

Procedure ProcessLine (Linein: String; var VarStr, CommentStr: String);
Var CharPos: Integer;
    LastChar: String;
Begin
CharPos := 1;
While (CharPos = 1) do {Remove leading spaces}
      Begin
      CharPos := Pos(' ', LineIn);
      If CharPos = 1 then
         LineIn := Copy(LineIn, CharPos + 1, Length(LineIn) - 1);
      End;
CharPos := Pos(' ', LineIn);
If CharPos <> 0 then
   Begin
   VarStr := Copy(LineIn, 1, CharPos -1);
   CommentStr := Copy(LineIn, CharPos + 1, Length(LineIn));
   CharPos := 1;
   While (CharPos = 1) do {Remove leading spaces at start of comment}
         Begin
         CharPos := Pos(' ', CommentStr);
         If CharPos = 1 then
            CommentStr := Copy(CommentStr, CharPos + 1, Length(CommentStr));
         End;
   LastChar := Copy(CommentStr, Length(CommentStr), 1);
   While LastChar = ' ' do {Remove trailing spaces}
         Begin
         CommentStr := Copy(CommentStr, 1, Length(CommentStr) - 1);
         LastChar := Copy(CommentStr, Length(CommentStr), 1);
         End;
   End
Else
   Begin
   VarStr := LineIn;
   CommentStr := '';
   End;
End; {of Procedure 'ProcessLine'}

Procedure GenProject(name : string);
    Var iHarvest, iFertiliser, iEnviron, iPest, iFire, iPlough, iGraze,
        iOMAdditions, ErrCode: integer;
        FileFound: Boolean;
        Defp: text;
        SetSensVar: SensitivityType;
        SaveOldVar, SaveVariable: SaveVariableOptions;
        BatchVariable: BatchOptions;
        Linein, VarStr, CommentStr, Extension: string;
        ScreenVar: ScreenOptions;

        Procedure ReadBool (Var Bool_in: Boolean);
           Var Ch: char;
           Begin
           Ch := VarStr[1];
           IF Ch = 'T' then
              Bool_in := true
           Else
              Bool_in := false;
           End; {of Procedure 'ReadBool'}

        Procedure RealIn (Var Item: double; Comment: String);
           Begin
           If CommentStr = Comment then
              val (VarStr, Item, ErrCode);
           End; {of Procedure 'RealIn'}

        Procedure IntegerIn (Var Item: Integer; Comment: String);
           Begin
           If CommentStr = Comment then
              val (VarStr, Item, ErrCode);
           End; {of Procedure 'IntegerIn'}

        Procedure LongIn (Var Item: integer; Comment: String);
           Begin
           If CommentStr = Comment then
              val (VarStr, Item, ErrCode);
           End; {of Procedure 'LongIn'}

        Procedure BoolIn (Var Item: Boolean; Comment: String);
           Begin
           If CommentStr = Comment then
              ReadBool (Item);
           End; {of Procedure 'BoolIn'}

        Procedure CharIn (Var Item: Char; Comment: String);
           Begin
           If CommentStr = Comment then
              Item := VarStr[1];
           End; {of Procedure 'CharIn'}

        Procedure FileIn;
           var i, CharPos: Integer;
           Begin
           CharPos := Pos('!', VarStr);
           If CharPos > 3 then
              Begin
              FileFound := true;
              Extension := Copy(VarStr, CharPos - 2, 3);
              CharPos := Pos('*', VarStr);
              While CharPos <> 0 do {Turn '*' back into spaces}
                 Begin
                 VarStr := Copy(VarStr, 1, CharPos -1) + ' ' + Copy(VarStr, CharPos + 1, Length(VarStr));
                 CharPos := Pos('*', VarStr);
                 End;
              for i := 1 to Length(Extension) do
                 Extension[i] := UpCase(Extension[i]);
              End
           Else
              FileFound := false;
           End; {of Procedure 'FileIn'}

        Procedure EquilIn (Var Target: EquilOptions; Comment: String);
           Begin
           If CommentStr = Comment then
              Begin
              If VarStr = 'SOM' then
                 Target := SOM
              Else if VarStr = 'Foliage_[N]' then
                 Target := LeafNConc
              Else if VarStr = 'Foliage_nitrogen' then
                 Target := LeafNitrogen
              Else if VarStr = 'Foliage_mass' then
                 Target := Leafmass
              Else {if VarStr = 'Wood_mass'}
                 Target := WoodMass;
              End;
           End; {of Procedure 'EquilIn'}

        Procedure EquilParameters (Var EquilPar: EquilParameterOptions; Comment: String);
           Begin
           If CommentStr = Comment then
              Begin
              If VarStr = 'Biological_N_fixation' then
                 EquilPar := BiolNFix
              Else if VarStr = 'N_fractional_loss' then
                 EquilPar := NFraction;
              End;
           End; {of Procedure 'EquilIn'}

        Procedure MultipleRunIn (Comment: String);
           var i: Integer;
           Begin
           If CommentStr = Comment then
              Begin
              IntegerIn (Control.nProjects, Comment);
              If Control.nProjects > MaxProjects then
                 Control.nProjects := MaxProjects;
              Readln(defp, Linein);
              ProcessLine (Linein, VarStr, CommentStr);
              FileIn;
              Control.MultipleRunPoolFile := VarStr;
              For i := 1 to Control.nProjects do
                  Begin
                  Readln(defp, Linein);
                  ProcessLine (Linein, VarStr, CommentStr);
                  FileIn;
                  Control.MultipleRuns[i] := VarStr;
                  End;
              For i := Control.nProjects + 1 to MaxProjects do
                  Control.MultipleRuns[i] := '';
              End;
           End; {of Procedure 'MultipleRunIn'}

        Procedure ScreenIn(ScreenVar: ScreenOptions);
        Begin
        BoolIn (ScreenRec.Choose[ScreenVar], 'Boolean variable for display of ' + ScreenVariableNames[ScreenVar]);
        RealIn (ScreenRec.UpRange[ScreenVar], 'Upper range for display of ' + ScreenVariableNames[ScreenVar]);
        RealIn (ScreenRec.LowRange[ScreenVar], 'Lower range for display of ' + ScreenVariableNames[ScreenVar]);
        LongIn (ScreenRec.Color[ScreenVar], 'Colour for display of ' + ScreenVariableNames[ScreenVar]);
        End; {of Procedure 'ScreenIn'}

        Procedure BatchIn(BatchVar: BatchOptions);
        Begin
        BoolIn (Batch.Choose[BatchVar], 'Boolean variable for batchfile selection of ' + BatchVariableNames[BatchVar]);
        End; {of Procedure 'BatchIn'}

Begin
Assign (Defp, Name);
Reset (Defp);
Event.nFertilisations := 0;
Event.nPloughing := 0;
Event.nHarvests := 0;
SaveOldVar := S_Year;
SetSensVar := Dummy;
iFertiliser := 0;
iHarvest := 0;
iEnviron := 0;
iPest := 0;
iFire := 0;
iPlough := 0;
iOMAdditions := 0;
iGraze := 0;
// go through the project file
while not eof(defp) do
      Begin
      Readln(defp, Linein);
      ProcessLine (Linein, VarStr, CommentStr);
      If CommentStr = '(Project name)' then
         StrPCopy(Control.ProjectName, VarStr);
      for ScreenVar := D_CarbonGain to D_Dummy do
          ScreenIn (ScreenVar);
      for SaveVariable := S_Year to S_Dummy do
          BoolIn (SaveVar.Choose[SaveVariable], 'Boolean variable for filesave of ' + SaveVariableNames[SaveVariable]);
      If CommentStr = 'Boolean variable for filesave of particular variables' then // For reading old files
         Begin
         ReadBool(SaveVar.Choose[SaveOldVar]);
         If SaveOldVar <> S_Dummy then
            SaveOldVar := succ(SaveOldVar);
         End;
      If CommentStr = 'Do sensitivity test of ' + SensitivityNames[SetSensVar] then
         Begin
         ReadBool(TestSens.Choose[SetSensVar]);
         SetSensVar := succ(SetSensVar);
         End;
      for BatchVariable := B_Dummy to B_EndDummy do
          BatchIn (BatchVariable);
      IntegerProjectVariables('R', CommentStr, VarStr, defp);
      RealProjectVariables('R', CommentStr, VarStr, defp);
      BooleanProjectVariables('R', CommentStr, VarStr, defp);
      CharIn (Control.Fertilise_DateType, 'Interpretation of fertiliser dates');
      IntegerIn (Event.nFertilisations, 'Number of times that fertiliser is to be applied');
      If CommentStr = 'Day for fertiliser application' then
         If iFertiliser < MaxFertiliseEvents then
            iFertiliser := iFertiliser + 1;
      If iFertiliser > 0 then
         Begin
         LongIn (Event.FertiliseTimes[iFertiliser, 1], 'Day for fertiliser application');
         LongIn (Event.FertiliseTimes[iFertiliser, 2], 'Month for fertiliser application');
         LongIn (Event.FertiliseTimes[iFertiliser, 3], 'Year for fertiliser application');
         RealIn (Event.FertiliseAmount[iFertiliser, N], 'Application rate of fertiliser');  // For reading old files
         RealIn (Event.FertiliseAmount[iFertiliser, N], 'Application rate of N fertiliser');
         RealIn (Event.FertiliseAmount[iFertiliser, P], 'Application rate of P fertiliser');
         End;
      CharIn (Event.HarvestUnits, 'Interpretation of harvest units');
      CharIn (Control.Harvest_DateType, 'Interpretation of harvest dates');
      IntegerIn (Event.nHarvests, 'Number of harvests or thinnings');
      If CommentStr = 'Day for harvest/ thinning' then
         If iHarvest < MaxHarvestEvents then
            iHarvest := iHarvest + 1;
      If iHarvest > 0 then
         Begin
         LongIn (Event.HarvestTimes[iHarvest, 1], 'Day for harvest/ thinning');
         LongIn (Event.HarvestTimes[iHarvest, 2], 'Month for harvest/ thinning');
         LongIn (Event.HarvestTimes[iHarvest, 3], 'Year for harvest/ thinning');
         LongIn (Event.HarvestTimes[iHarvest, 4], 'Day number of harvest/ thinning');
         RealIn (Event.WoodCut[iHarvest], 'Fraction of stems cut');
         RealIn (Event.RelativeSize[iHarvest], 'Size of harvested trees relative to that of average trees');
         BoolIn (Event.AdjustStocking[iHarvest], 'Indicates whether stocking rate is to be adjusted during the harvest');
         RealIn (Event.BranchesCut[iHarvest], 'Fraction of branches/ leaves cut');
         RealIn (Event.WoodRemoval[iHarvest], 'Fraction of stems removed from the site');
         RealIn (Event.FineRemoval[iHarvest], 'Fraction of leaves, branches, etc removed from the site');
         End;
      CharIn (Control.Pest_DateType, 'Interpretation of pest dates');
      CharIn (Event.PestDamageUnits, 'Units in which pest damage is expressed (% or W)');
      IntegerIn (Event.nPests, 'Number of pest outbreaks');
      If CommentStr = 'Day for pest outbreak' then
         If iPest < MaxPestEvents then
            iPest := iPest + 1;
      If iPest > 0 then
         Begin
         LongIn (Event.PestTimes[iPest, 1], 'Day for pest outbreak');
         LongIn (Event.PestTimes[iPest, 2], 'Month for pest outbreak');
         LongIn (Event.PestTimes[iPest, 3], 'Year for pest outbreak');
         LongIn (Event.PestTimes[iPest, 4], 'Day number of pest outbreak');
         LongIn (Event.PestTimes[iPest, 5], 'Duration (days) of of pest outbreak');
         RealIn (Event.LeafDamage[iPest], 'Daily foliage damage by insects');
         RealIn (Event.SolubleDamage[iPest], 'Daily loss by sap-sucking insect pests');
         RealIn (Event.SenescenceDamage[iPest], 'Daily induced foliage senesce by pest damage');
         RealIn (Event.PhotosynthesisFraction[iPest], 'Fractional reduction in photosynthesis for the duration of the pest outbreak');
         RealIn (Event.PestMortality[iPest], 'Death rate due to pest damage');
         RealIn (Event.PestDeathRatio[iPest], 'Size ratio of trees killed by pests to living trees');
         End;
      CharIn (Control.Fire_DateType, 'Interpretation of fire dates');
      IntegerIn (Event.nFires, 'Number of fire outbreaks');
      If CommentStr = 'Day for fire outbreak' then
         If iFire < MaxFireEvents then
            iFire := iFire + 1;
      If iFire > 0 then
         Begin
         LongIn (Event.FireTimes[iFire, 1], 'Day for fire outbreak');
         LongIn (Event.FireTimes[iFire, 2], 'Month for fire outbreak');
         LongIn (Event.FireTimes[iFire, 3], 'Year for fire outbreak');
         LongIn (Event.FireTimes[iFire, 4], 'Day number of fire outbreak');
         RealIn (Event.LeafBurn[iFire], 'Fraction of foliage burnt during a fire');
         RealIn (Event.WoodBurn[iFire], 'Fraction of stem wood burnt during a fire');
         RealIn (Event.WoodToChar[iFire], 'Fraction of wood converted to charcoal during a fire');
         RealIn (Event.FineToChar[iFire], 'Fraction of fine material (foliage and litter) converted to charcoal during a fire');
         RealIn (Event.LitterBurn[iFire], 'Fraction of forest litter burnt during a fire');
         RealIn (Event.LeafBurnSenesc[iFire], 'Fraction of foliage killed (but not burnt) during a fire');
         RealIn (Event.WoodBurnSenesc[iFire], 'Fraction of trees killed (but not burnt) during a fire');
         RealIn (Event.Burn_N_CRatio[iFire], 'Ratio of nitrogen to carbon losses during combustion');
         RealIn (Event.Burn_P_CRatio[iFire], 'Ratio of phosphorus to carbon losses during combustion');
         End;
      CharIn (Control.Plough_DateType, 'Interpretation of plough dates');
      IntegerIn (Event.nPloughing, 'Number of ploughing events');
      If CommentStr = 'Day for ploughing' then
         If iPlough < MaxPloughEvents then
            iPlough := iPlough + 1;
      If iPlough > 0 then
         Begin
         LongIn (Event.PloughTimes[iPlough, 1], 'Day for ploughing');
         LongIn (Event.PloughTimes[iPlough, 2], 'Month for ploughing');
         LongIn (Event.PloughTimes[iPlough, 3], 'Year for ploughing');
         LongIn (Event.PloughTimes[iPlough, 4], 'Day number of ploughing');
         IntegerIn (Event.PloughDepth[iPlough], 'Depth of Ploughing (layers)');
         End;
      CharIn (Control.OMAdditions_DateType, 'Interpretation of OMAdditions dates');
      IntegerIn (Event.nOMAdditions, 'Number of OMAdditions events');
      If CommentStr = 'Day for OMAdditions' then
         If iOMAdditions < MaxOMAdditions then
            iOMAdditions := iOMAdditions + 1;
      If Event.nOMAdditions > 0 then
         Begin
         LongIn (Event.OMAdditionTimes[iOMAdditions, 1], 'Day for OMAdditions');
         LongIn (Event.OMAdditionTimes[iOMAdditions, 2], 'Month for OMAdditions');
         LongIn (Event.OMAdditionTimes[iOMAdditions, 3], 'Year for OMAdditions');
         LongIn (Event.OMAdditionTimes[iOMAdditions, 4], 'Day number of OMAdditions');
         RealIn (Event.OMAddition[iOMAdditions, C], 'Rate of C addition');
         RealIn (Event.OMAddition[iOMAdditions, N], 'Rate of N addition');
         RealIn (Event.OMAddition[iOMAdditions, P], 'Rate of P addition');
         RealIn (Event.OMExtraH2O[iOMAdditions], 'Rate of H2O addition');
         RealIn (Event.OMLignin[iOMAdditions], 'Lignin concentration');
         End;
      CharIn (Event.GrazingUnits, 'Interpretation of grazing units');
      IntegerIn (Event.nGrazings, 'Number of Grazing events');
      If CommentStr = 'Day for Grazing' then
         If iGraze < MaxGrazings then
            iGraze := iGraze + 1;
      If Event.nGrazings > 0 then
         Begin
         LongIn (Event.GrazingTimes[iGraze, 1], 'Day for Grazing');
         LongIn (Event.GrazingTimes[iGraze, 2], 'Month for Grazing');
         LongIn (Event.GrazingTimes[iGraze, 3], 'Year for Grazing');
         LongIn (Event.GrazingTimes[iGraze, 4], 'Day number of Grazing');
         RealIn (Event.GrazingAmount[iGraze], 'Amount grazed');
         RealIn (Event.GrazingFraction[iGraze, C], 'Fraction of C returned');
         RealIn (Event.GrazingFraction[iGraze, N], 'Fraction of N returned');
         RealIn (Event.GrazingFraction[iGraze, P], 'Fraction of P returned');
         End;
      IntegerIn (Event.nEnvironments, 'Number of times environmental variables are changed');
      If CommentStr = 'Day number of change in environmental variable' then
         Begin
         If iEnviron < MaxEnvironmentEvents then
            iEnviron := iEnviron + 1;
         Event.VP[iEnviron] := 1;
         Event.Radn[iEnviron] := 1;
         End;
      If iEnviron > 0 then
         Begin
         LongIn (Event.EnvironmentTimes[iEnviron], 'Day number of change in environmental variable');
         RealIn (Event.CO2[iEnviron], 'Change CO2 concentration');
         RealIn (Event.Temperature[iEnviron], 'Change Temperature');
         RealIn (Event.Rainfall[iEnviron], 'Change Rainfall');
         RealIn (Event.VP[iEnviron], 'Change Vapour pressure');
         RealIn (Event.Radn[iEnviron], 'Change Radiation');
         End;
      BoolIn (Event.Irrigate, 'Boolean variable to indicate whether irrigation is applied');
      CharIn (Event.IrrigationType, 'Type of irrigation');
      RealIn (Event.IrrigationAmount, 'Amount of irrigation applied');
      RealIn (Event.IrrigationFraction, 'Fraction of field capacity to which irrigation water is applied');
      LongIn(Control.StartBatchSave, 'Start saving data after nominated no. of iterations');
      If CommentStr = 'plant type for spatial runs' then
         If VarStr = 'Optimal' then
            Control.Spatial.PlantType := Optimal
         Else
            Control.Spatial.PlantType := Exotic;
      If CommentStr = 'soil type for spatial runs' then
         If VarStr = 'Equil' then
            Control.Spatial.SoilType := Equil
         Else
            Control.Spatial.SoilType := SoilSet;
      LongIn (Control.nDisplays, 'number of times output is given');
      LongIn (Control.nDiskOut, 'number of times output is written to disk');
      CharIn (Control.CalcType, 'Calculation type');
      CharIn (Control.ClimType, 'Type of climate input');
      MultipleRunIn ('Number of projects to load for multiple project runs');
      FileIn;
      If FileFound then
         Begin
         If Extension = 'CL!' then
            Control.ClimFile := VarStr
         Else if Extension = 'DT!' then
            Control.FileOut := VarStr
         Else if Extension = 'IL!' then
            Control.PoolFile := VarStr
         Else if Extension = 'SL!' then
            Begin
            Control.SavePoolFile := VarStr;
            Control.SavePoolFile[Length(Control.SavePoolFile) - 2] := 'i';
            End
         Else if Extension = 'ST!' then
            Control.SiteFile := VarStr
         Else if Extension = 'PL!' then
            Control.PlantFile := VarStr
         Else if Extension = 'BT!' then
            Control.BatchFile := VarStr
         Else if Extension = 'SP!' then
            Control.SpatialFile := VarStr;
         End;
      If CommentStr = 'Type of function to calculate mortality' then
         If VarStr = 'Fraction:' then
            Parameter.MortalityType := Fraction
         Else if VarStr = 'Both:' then
            Parameter.MortalityType := Both
         Else if VarStr = 'Density:' then
            Parameter.MortalityType := Density;
      Equilin (Control.Equil.EquilTarget, 'Type of target value for equilibrium runs');
      EquilParameters (Control.Equil.EquilParameter, 'Type of parameter to change for equilibrium runs');
      end; {of 'while not eof(defp)' statement}
  Close (Defp);
Control.IncludeP := false; // temporarily included to omit use of the P cycle in this version
End; {of Procedure 'GenProject'}

Procedure SaveProject(name : string);
    Var Defp: text;
        TempFile: FileNameType;
        i, iGraze: integer;
        BatchVariable: BatchOptions;
        SetSensVar: SensitivityType;
        SaveInFileVar: SaveVariableOptions;
        ScreenVar: ScreenOptions;

    Procedure LineOut (Datum: double; Comment: string);
       var Width, Digits: integer;
       Begin
       GetField(Datum, ParFileMaxWidth, Width, Digits);
       Writeln (Defp, Datum: ParFileMaxWidth: Digits, Comment);
       End;  {of Procedure 'LineOut'}

    Procedure IntegerOut (Datum: Integer; Comment: string);
       Var StrngVar: String;
       Begin
       Str(Datum, StrngVar);
       Writeln (Defp, StrngVar,' ', Comment);
       End;  {of Procedure 'IntegerOut'}

    Procedure LongOut (Datum: integer; Comment: string);
       Var StrngVar: String;
       Begin
       Str(Datum, StrngVar);
       Writeln (Defp, StrngVar,' ', Comment);
       End;  {of Procedure 'LongOut'}

    Procedure FileOut (FileName: string);
       Var CharPos: Integer;
       Begin
       CharPos := Pos(' ', FileName);
       While CharPos <> 0 do {Turn spaces into '*'}
          Begin
          FileName := Copy(FileName, 1, CharPos -1) + '*' + Copy(FileName, CharPos + 1, Length(FileName));
          CharPos := Pos(' ', FileName);
          End;
       Writeln (Defp, FileName);
       End;  {of Procedure 'FileOut'}

    Procedure ScreenOut(ScreenVar: ScreenOptions);
    Begin
    Writeln(defp, ScreenRec.Choose[ScreenVar]:1,'    Boolean variable for display of ' + ScreenVariableNames[ScreenVar]);
    LineOut(ScreenRec.UpRange[ScreenVar],' Upper range for display of ' + ScreenVariableNames[ScreenVar]);
    LineOut(ScreenRec.LowRange[ScreenVar],' Lower range for display of ' + ScreenVariableNames[ScreenVar]);
    LongOut(ScreenRec.Color[ScreenVar], 'Colour for display of ' + ScreenVariableNames[ScreenVar]);
    End;

    Procedure BatchOut(BatchVar: BatchOptions);
    Begin
    Writeln (defp, Batch.Choose[BatchVar]:1, '    Boolean variable for batchfile selection of ' + BatchVariableNames[BatchVar]);
    End; {of Procedure 'BatchOut'}


    Begin
    assign (defp, Name);   rewrite (defp);
    Writeln(defp, Control.Version + ' Project');
    Writeln(defp, Control.ProjectName, ' (Project name)');
    for ScreenVar := D_CarbonGain to D_Dummy do
      ScreenOut(ScreenVar);
    For SaveInFileVar := S_Year to S_Dummy do
        Writeln (defp, SaveVar.Choose[SaveInFileVar]:1,'    Boolean variable for filesave of ' + SaveVariableNames[SaveInFileVar]);
    For SetSensVar := Dummy to EndDummy do
        Writeln (defp, TestSens.Choose[SetSensVar]:1, '    Do sensitivity test of ' + SensitivityNames[SetSensVar]);
    for BatchVariable := B_Dummy to B_EndDummy do
        BatchOut (BatchVariable);
    Writeln (defp, MaxWidth:ParFileMaxWidth,' Variable to define the width for each variable in the output file');
    IntegerProjectVariables('W', 'Dummy', 'Dummy', defp);
    RealProjectVariables('W', 'Dummy', 'Dummy', defp);
    BooleanProjectVariables('W', 'Dummy', 'Dummy', defp);
    Writeln (defp, Control.Fertilise_DateType, '       Interpretation of fertiliser dates');
    Writeln (defp, Event.nFertilisations:ParFileMaxWidth, ' Number of times that fertiliser is to be applied');
    For i := 1 to Event.nFertilisations do
        Begin
        Writeln (defp, Event.FertiliseTimes[i, 1], ' Day for fertiliser application');
        Writeln (defp, Event.FertiliseTimes[i, 2], ' Month for fertiliser application');
        Writeln (defp, Event.FertiliseTimes[i, 3], ' Year for fertiliser application');
        LineOut (Event.FertiliseAmount[i, N], ' Application rate of N fertiliser');
        LineOut (Event.FertiliseAmount[i, P], ' Application rate of P fertiliser');
        End;
    Writeln (defp, Event.HarvestUnits, '       Interpretation of harvest units');
    Writeln (defp, Control.Harvest_DateType, '       Interpretation of harvest dates');
    Writeln (defp, Event.nHarvests:ParFileMaxWidth, ' Number of harvests or thinnings');
    For i := 1 to Event.nHarvests do
        Begin
        LongOut (Event.HarvestTimes[i, 1], ' Day for harvest/ thinning');
        LongOut (Event.HarvestTimes[i, 2], ' Month for harvest/ thinning');
        LongOut (Event.HarvestTimes[i, 3], ' Year for harvest/ thinning');
        LongOut (Event.HarvestTimes[i, 4], ' Day number of harvest/ thinning');
        LineOut (Event.WoodCut[i], ' Fraction of stems cut');
        LineOut (Event.RelativeSize[i], ' Size of harvested trees relative to that of average trees');
        Writeln (defp, Event.AdjustStocking[i], ' Indicates whether stocking rate is to be adjusted during the harvest');
        LineOut (Event.BranchesCut[i], ' Fraction of branches/ leaves cut');
        LineOut (Event.WoodRemoval[i], ' Fraction of stems removed from the site');
        LineOut (Event.FineRemoval[i], ' Fraction of leaves, branches, etc removed from the site');
        End;
    Writeln (defp, Control.Pest_DateType, '       Interpretation of pest dates');
    Writeln (defp, Event.PestDamageUnits, '       Units in which pest damage is expressed (% or W)');
    Writeln (defp, Event.nPests:ParFileMaxWidth, ' Number of pest outbreaks');
    For i := 1 to Event.nPests do
        Begin
        LongOut (Event.PestTimes[i, 1], ' Day for pest outbreak');
        LongOut (Event.PestTimes[i, 2], ' Month for pest outbreak');
        LongOut (Event.PestTimes[i, 3], ' Year for pest outbreak');
        LongOut (Event.PestTimes[i, 4], ' Day number of pest outbreak');
        LongOut (Event.PestTimes[i, 5], ' Duration (days) of of pest outbreak');
        LineOut (Event.LeafDamage[i], ' Daily foliage damage by insects');
        LineOut (Event.SolubleDamage[i], ' Daily loss by sap-sucking insect pests');
        LineOut (Event.SenescenceDamage[i], ' Daily induced foliage senesce by pest damage');
        LineOut (Event.PhotosynthesisFraction[i], ' Fractional reduction in photosynthesis for the duration of the pest outbreak');
        LineOut (Event.PestMortality[i], ' Death rate due to pest damage');
        LineOut (Event.PestDeathRatio[i], ' Size ratio of trees killed by pests to living trees');
        End;
    Writeln (defp, Control.Fire_DateType, '       Interpretation of fire dates');
    Writeln (defp, Event.nFires:ParFileMaxWidth, ' Number of fire outbreaks');
    For i := 1 to Event.nFires do
        Begin
        LongOut (Event.FireTimes[i, 1], ' Day for fire outbreak');
        LongOut (Event.FireTimes[i, 2], ' Month for fire outbreak');
        LongOut (Event.FireTimes[i, 3], ' Year for fire outbreak');
        LongOut (Event.FireTimes[i, 4], ' Day number of fire outbreak');
        LineOut (Event.LeafBurn[i], ' Fraction of foliage burnt during a fire');
        LineOut (Event.WoodBurn[i], ' Fraction of stem wood burnt during a fire');
        LineOut (Event.LitterBurn[i], ' Fraction of forest litter burnt during a fire');
        LineOut (Event.WoodToChar[i], ' Fraction of wood converted to charcoal during a fire');
        LineOut (Event.FineToChar[i], ' Fraction of fine material (foliage and litter) converted to charcoal during a fire');
        LineOut (Event.LeafBurnSenesc[i], ' Fraction of foliage killed (but not burnt) during a fire');
        LineOut (Event.WoodBurnSenesc[i], ' Fraction of trees killed (but not burnt) during a fire');
        LineOut (Event.Burn_N_CRatio[i], ' Ratio of nitrogen to carbon losses during combustion');
        LineOut (Event.Burn_P_CRatio[i], ' Ratio of phosphorus to carbon losses during combustion');
        End;
    Writeln (defp, Control.Plough_DateType, '       Interpretation of plough dates');
    Writeln (defp, Event.nPloughing:ParFileMaxWidth, ' Number of ploughing events');
    For i := 1 to Event.nPloughing do
        Begin
        LongOut (Event.PloughTimes[i, 1], ' Day for ploughing');
        LongOut (Event.PloughTimes[i, 2], ' Month for ploughing');
        LongOut (Event.PloughTimes[i, 3], ' Year for ploughing');
        LongOut (Event.PloughTimes[i, 4], ' Day number of ploughing');
        Writeln (defp, Event.PloughDepth[i]:3, ' Depth of Ploughing (layers)');
        End;
    Writeln (defp, Control.OMAdditions_DateType, '       Interpretation of OMAdditions dates');
    Writeln (defp, Event.nOMAdditions:ParFileMaxWidth, ' Number of OMAdditions events');
    For i := 1 to Event.nOMAdditions do
        Begin
        LongOut (Event.OMAdditionTimes[i, 1], ' Day for OMAdditions');
        LongOut (Event.OMAdditionTimes[i, 2], ' Month for OMAdditions');
        LongOut (Event.OMAdditionTimes[i, 3], ' Year for OMAdditions');
        LongOut (Event.OMAdditionTimes[i, 4], ' Day number of OMAdditions');
        LineOut (Event.OMAddition[i, C], ' Rate of C addition');
        LineOut (Event.OMAddition[i, N], ' Rate of N addition');
        LineOut (Event.OMAddition[i, P], ' Rate of P addition');
        LineOut (Event.OMExtraH2O[i], ' Rate of H2O addition');
        LineOut (Event.OMLignin[i], ' Lignin concentration');
        End;
      Writeln (defp, Event.GrazingUnits, ' Interpretation of grazing units');
      Writeln (defp, Event.nGrazings: ParFileMaxWidth, ' Number of Grazing events');
      For iGraze := 1 to Event.nGrazings do
          Begin
          LongOut (Event.GrazingTimes[iGraze, 1], ' Day for Grazing');
          LongOut (Event.GrazingTimes[iGraze, 2], ' Month for Grazing');
          LongOut (Event.GrazingTimes[iGraze, 3], ' Year for Grazing');
          LongOut (Event.GrazingTimes[iGraze, 4], ' Day number of Grazing');
          LineOut (Event.GrazingAmount[iGraze], ' Amount grazed');
          LineOut (Event.GrazingFraction[iGraze, C], ' Fraction of C returned');
          LineOut (Event.GrazingFraction[iGraze, N], ' Fraction of N returned');
          LineOut (Event.GrazingFraction[iGraze, P], ' Fraction of P returned');
          End;
    Writeln (defp, Event.nEnvironments:ParFileMaxWidth, ' Number of times environmental variables are changed');
    For i := 1 to Event.nEnvironments do
        Begin
        LongOut (Event.EnvironmentTimes[i], ' Day number of change in environmental variable');
        LineOut (Event.CO2[i], ' Change CO2 concentration');
        LineOut (Event.Temperature[i], ' Change Temperature');
        LineOut (Event.Rainfall[i], ' Change Rainfall');
        LineOut (Event.VP[i], ' Change Vapour pressure');
        LineOut (Event.Radn[i], ' Change Radiation');
        End;
    Writeln (defp, Event.Irrigate:1, '    Boolean variable to indicate whether irrigation is applied');
    Writeln (defp, Event.IrrigationType, '       Type of irrigation');
    LineOut (Event.IrrigationAmount, ' Amount of irrigation applied');
    LineOut (Event.IrrigationFraction, ' Fraction of field capacity to which irrigation water is applied');
    LongOut(Control.StartBatchSave, ' Start saving data after nominated no. of iterations');
    If Control.Spatial.PlantType = Optimal then
       Writeln (defp, ' Optimal plant type for spatial runs')
    Else
       Writeln (defp, ' Exotic plant type for spatial runs');
    If Control.Spatial.SoilType = Equil then
       Writeln (defp, ' Equil soil type for spatial runs')
    Else
       Writeln (defp, ' SoilSet soil type for spatial runs');
    Writeln (defp, Control.nDisplays:ParFileMaxWidth, ' number of times output is given');
    Writeln (defp, Control.nDiskOut:ParFileMaxWidth, ' number of times output is written to disk');
    Writeln (defp, Control.CalcType, '       Calculation type');
    Writeln (defp, Control.ClimType, '       Type of climate input');
    Writeln (defp, Control.nProjects:1, '   Number of projects to load for multiple project runs');
    If Control.nProjects > 0 then
        FileOut (Control.MultipleRunPoolFile);
    For i := 1 to Control.nProjects do
        FileOut (Control.MultipleRuns[i]);
    FileOut (Control.ClimFile);
    FileOut (Control.FileOut);
    FileOut (Control.PoolFile);
    FileOut (Control.SpatialFile);
    If Control.SavePoolFile <> '' then
       TempFile := Control.SavePoolFile
    Else
       TempFile := Control.PoolFile;
    TempFile[Length(TempFile) - 2] := 'S';
    FileOut (TempFile);
    FileOut (Control.SiteFile);
    FileOut (Control.PlantFile);
    FileOut (Control.BatchFile);
    If Control.Equil.EquilTarget = SOM then
       Writeln (defp, 'SOM       Type of target value for equilibrium runs')
    Else if Control.Equil.EquilTarget = LeafNConc then
       Writeln (defp, 'Foliage_[N]   Type of target value for equilibrium runs')
    Else if Control.Equil.EquilTarget = LeafNitrogen then
       Writeln (defp, 'Foliage_nitrogen   Type of target value for equilibrium runs')
    Else if Control.Equil.EquilTarget = Leafmass then
       Writeln (defp, 'Foliage_mass       Type of target value for equilibrium runs')
    Else {if Control.Equil.EquilTarget = WoodMass then}
       Writeln (defp, 'Wood_mass       Type of target value for equilibrium runs');
    If Control.Equil.EquilParameter = BiolNFix then
       Writeln (defp, 'Biological_N_fixation  Type of parameter to change for equilibrium runs')
    Else if Control.Equil.EquilParameter = NFraction then
       Writeln (defp, 'N_fractional_loss  Type of parameter to change for equilibrium runs');
    If Parameter.MortalityType = Fraction then
       Writeln (defp, 'Fraction:        Type of function to calculate mortality')
    Else if Parameter.MortalityType = Density then
       Writeln (defp, 'Density:        Type of function to calculate mortality')
    Else
       Writeln (defp, 'Both:       Type of function to calculate mortality');
    close (defp);
End; {of Procedure 'SaveProject'}

{ --- end of file untLoadSaveProject.PAS ------------------------------------------ }

End.

