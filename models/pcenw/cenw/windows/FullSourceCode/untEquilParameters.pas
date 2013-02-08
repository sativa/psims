{ ================================================================
  = Project   : CENW                                             =
  ================================================================
  = Modules   : TfrmEquilParameters                              =
  =                                                              =
  =             Routines to set up the parameters for the        =
  =             routine to search for equilibrium conditions     =
  ================================================================
  = File      : untEquilParameters.PAS                           =
  =                                                              =
  = Version   : 3.1                                              =
  ================================================================ }

unit untEquilParameters;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TfrmEquilParameters = class(TForm)
    edtMaxIterations: TGroupBox;
    btnOK: TButton;
    btnCancel: TButton;
    rgEquilType: TRadioGroup;
    edtSteadyLimit: TGroupBox;
    rgEquilParameter: TRadioGroup;
    chkKeepPlantPools: TCheckBox;
    btnHelp: TBitBtn;
    edtTargetValue: TEdit;
    lblLine1: TLabel;
    edtEquilRuns: TEdit;
    edtGoodCount: TEdit;
    edtCriterion1: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    edtCriterion2: TEdit;
    edtCriterion3: TEdit;
    Label3: TLabel;
    edtDeltaMin: TEdit;
    Label4: TLabel;
    edtDeltaMax: TEdit;
    Label5: TLabel;
    edtDeltaAdjust: TEdit;
    Label6: TLabel;
    Label7: TLabel;
    edtMaxChangeRatio: TEdit;
    edtBoostResistant: TEdit;
    Label8: TLabel;
    procedure FormShow(Sender: TObject);
    procedure btnOKClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var frmEquilParameters: TfrmEquilParameters;

implementation
{$R *.DFM}

uses untDeclarations, untMain;

procedure TfrmEquilParameters.FormShow(Sender: TObject);
var Width, Digits: Integer;
begin
// fill form with parameters
frmMain.FillEdit(Sender, edtEquilRuns, Control.Equil.MaxIterations, 0);
frmMain.FillEdit(Sender, edtGoodCount, Control.Equil.MaxGoodCount, 0);
frmMain.FillEdit(Sender, edtCriterion1, Control.Equil.Criterion1, 1);
frmMain.FillEdit(Sender, edtCriterion2, Control.Equil.Criterion2, 1);
frmMain.FillEdit(Sender, edtCriterion3, Control.Equil.Criterion3, 1);
frmMain.FillEdit(Sender, edtTargetValue, Control.Equil.TargetValue, 1);
frmMain.FillEdit(Sender, edtDeltaMin, Control.Equil.DeltaMin, 1);
frmMain.FillEdit(Sender, edtDeltaMax, Control.Equil.DeltaMax, 1);
frmMain.FillEdit(Sender, edtMaxChangeRatio, Control.Equil.MaxChangeRatio, 1);
frmMain.FillEdit(Sender, edtDeltaAdjust, Control.Equil.DeltaAdjust, 1);
frmMain.FillEdit(Sender, edtBoostResistant, Control.Equil.BoostResistant, 1);
If Control.Equil.SamePlantPools then
   chkKeepPlantPools.Checked := true
Else
   chkKeepPlantPools.Checked := false;
case Control.Equil.EquilParameter of
     BiolNFix:    rgEquilParameter.ItemIndex := 0;
     NFraction:   rgEquilParameter.ItemIndex := 1;
     End;
case Control.Equil.EquilTarget of
     SOM:          rgEquilType.ItemIndex := 0;
     LeafNConc:    rgEquilType.ItemIndex := 1;
     LeafNitrogen: rgEquilType.ItemIndex := 2;
     LeafMass:     rgEquilType.ItemIndex := 3;
     WoodMass:     rgEquilType.ItemIndex := 4;
     end;
End;

procedure TfrmEquilParameters.btnOKClick(Sender: TObject);
begin
frmMain.GetInteger(Sender, edtEquilRuns, Control.Equil.MaxIterations);
frmMain.GetInteger(Sender, edtGoodCount, Control.Equil.MaxGoodCount);
frmMain.GetEdit(Sender, edtCriterion1, Control.Equil.Criterion1, 1);
frmMain.GetEdit(Sender, edtCriterion2, Control.Equil.Criterion2, 1);
frmMain.GetEdit(Sender, edtCriterion3, Control.Equil.Criterion3, 1);
frmMain.GetEdit(Sender, edtTargetValue, Control.Equil.TargetValue, 1);
frmMain.GetEdit(Sender, edtDeltaMin, Control.Equil.DeltaMin, 1);
frmMain.GetEdit(Sender, edtDeltaMax, Control.Equil.DeltaMax, 1);
frmMain.GetEdit(Sender, edtMaxChangeRatio, Control.Equil.MaxChangeRatio, 1);
frmMain.GetEdit(Sender, edtDeltaAdjust, Control.Equil.DeltaAdjust, 1);
frmMain.GetEdit(Sender, edtBoostResistant, Control.Equil.BoostResistant, 1);
Control.ProjectHasChanged := true;
Control.Equil.SamePlantPools := chkKeepPlantPools.Checked;
case rgEquilParameter.ItemIndex of
     0: Control.Equil.EquilParameter := BiolNFix;
     1: Control.Equil.EquilParameter := NFraction;
     End;
case rgEquilType.ItemIndex of
     0: Control.Equil.EquilTarget := SOM;
     1: Control.Equil.EquilTarget := LeafNConc;
     2: Control.Equil.EquilTarget := LeafNitrogen;
     3: Control.Equil.EquilTarget := LeafMass;
     4: Control.Equil.EquilTarget := WoodMass;
    end;
ModalResult := mrOK;
end;


end.
