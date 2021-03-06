{ ================================================================
  = Project   : CenW                                             =
  ================================================================
  = Modules   : TfrmSaveWeatherInfo                              =
  =                                                              =
  =             Interface routine to nominate weather-related    =
  =             variables that are to be saved in an ASCII file  =
  =             during program execution.                        =
  ================================================================
  = File      : untSaveWeatherInfo.PAS                           =
  =                                                              =
  = Version   : 3.1                                              =
  ================================================================ }

unit untSaveWeatherInfo;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons;

type
  TfrmSaveWeatherInfo = class(TForm)
    btnOK: TBitBtn;
    btnCancel: TBitBtn;
    btnHelp: TBitBtn;
    rgSaveGeneric: TRadioGroup;
    Procedure FormShow(Sender: TObject);
    Procedure btnOKClick(Sender: TObject);
    Procedure rgSaveGenericClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  frmSaveWeatherInfo: TfrmSaveWeatherInfo;

implementation

{$R *.DFM}

uses
  untDeclarations, untMiscellaneous;

Procedure TfrmSaveWeatherInfo.FormShow(Sender: TObject);
var
  cbEnabled: TCheckBox;
  iCount, column, iEntries, HalfEntries: integer;
  SaveInFileVar: SaveVariableOptions;
begin
  while (Self.ComponentCount > 4) do
    Self.Components[4].Free;
  iCount := 16;
  Column := 1;
  For SaveInFileVar := S_Year to S_Day do
  Begin
    cbEnabled := TCheckBox.Create(Self);
    cbEnabled.Parent := Self;
    cbEnabled.Left := 8;
    cbEnabled.Top := iCount;
    cbEnabled.Caption := SaveVariableNames[SaveInFileVar];
    If SaveVar.Choose[SaveInFileVar] then
      cbEnabled.Checked := true;
    iCount := iCount + 16;
  End;
  iEntries := 0;
  For SaveInFileVar := S_Tmax to S_Dummy do
      iEntries := iEntries + 1;
  If iEntries <= 20 then
     Begin
     frmSaveWeatherInfo.ClientWidth := 260;
     End
  Else
     Begin
     frmSaveWeatherInfo.ClientWidth := 400;
     End;
  If iEntries > 20 then
      HalfEntries := (iEntries + 1) div 2
  Else
      HalfEntries := iEntries;
  frmSaveWeatherInfo.Height := 110 + (HalfEntries + 4) * 16;
  btnOK.Top := frmSaveWeatherInfo.Height - 60;
  btnCancel.Top := btnOK.Top;
  btnHelp.Top := btnOK.Top;
  iEntries := 0;
  For SaveInFileVar := S_Tmax to S_Dummy do
  Begin
    iCount := iCount + 16;
    iEntries := iEntries + 1;
    cbEnabled := TCheckBox.Create(Self);
    cbEnabled.Parent := Self;
    If iEntries > HalfEntries then
       Begin
       iEntries := 0;
       Column := 2;
       iCount := 80;
       End;
    If Column = 1 then
       cbEnabled.Left := 8
    Else
       cbEnabled.Left := 200;
    cbEnabled.Top := iCount;
    cbEnabled.Caption := SaveVariableNames[SaveInFileVar];
    If SaveVar.Choose[SaveInFileVar] then
      cbEnabled.Checked := true;
  End;
end;

Procedure TfrmSaveWeatherInfo.btnOKClick(Sender: TObject);
var
  iCount: integer;
  SaveInFileVar: SaveVariableOptions;
begin
  // save parameters
  iCount := 0;
  For SaveInFileVar := S_Year to S_Day do
  begin
    SaveVar.Choose[SaveInFileVar] := TCheckBox(Self.Components[iCount + 4]).Checked;
    iCount := iCount + 1;
  End;
  For SaveInFileVar := S_Tmax to S_Dummy do
  begin
    SaveVar.Choose[SaveInFileVar] := TCheckBox(Self.Components[iCount + 4]).Checked;
    iCount := iCount + 1;
  End;
 Control.ProjectHasChanged := TRUE;
end;

Procedure TfrmSaveWeatherInfo.rgSaveGenericClick(Sender: TObject);
var SaveInFileVar: SaveVariableOptions;
begin
frmSaveWeatherInfo.btnOKClick(Sender);
If rgSaveGeneric.ItemIndex = 0 then
   Begin
   For SaveInFileVar := S_Year to S_Day do
       SaveVar.Choose[SaveInFileVar] := true;
   For SaveInFileVar := S_Tmax to S_Dummy do
       SaveVar.Choose[SaveInFileVar] := true;
   Control.ProjectHasChanged := TRUE;
   End
Else if rgSaveGeneric.ItemIndex = 1 then
   Begin
   For SaveInFileVar := S_Year to S_Day do
       SaveVar.Choose[SaveInFileVar] := false;
   For SaveInFileVar := S_Tmax to S_Dummy do
       SaveVar.Choose[SaveInFileVar] := false;
   Control.ProjectHasChanged := TRUE;
   End;
frmSaveWeatherInfo.FormShow(Sender);

end;

end.
