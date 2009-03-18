unit Options;

{
  Disk Image Manager -  Copyright 2002-2009 Envy Technologies Ltd.

  Options window
}

interface

uses
  DiskMap, Utils,
  Graphics, Forms, ComCtrls, StdCtrls, Classes, Controls, ExtCtrls, Registry, Dialogs;

type
  TfrmOptions = class(TForm)
    pnlButtons: TPanel;
    pnlSheet: TPanel;
    pagOptions: TPageControl;
    tabMain: TTabSheet;
    btnOK: TButton;
    btnCancel: TButton;
    tabSectors: TTabSheet;
    tabDiskMap: TTabSheet;
    lblFontMainLabel: TLabel;
    dlgFont: TFontDialog;
    lblFontMain: TLabel;
    btnFontMain: TButton;
    DiskMap: TSpinDiskMap;
    lblFontMapLabel: TLabel;
    lblFontMap: TLabel;
    btnFontMap: TButton;
    lblBackColorLabel: TLabel;
    lblGridColorLabel: TLabel;
    lblFontSectorLabel: TLabel;
    lblFontSector: TLabel;
    btnFontSector: TButton;
    lblTrackMarksLabel: TLabel;
    udTrackMarks: TUpDown;
    edtTrackMarks: TEdit;
    lblBytesLabel: TLabel;
    edtBytes: TEdit;
    udBytes: TUpDown;
    lblNonDisplayLabel: TLabel;
    edtNonDisplay: TEdit;
    chkRestoreWindow: TCheckBox;
    chkRestoreWorkspace: TCheckBox;
    btnReset: TButton;
    chkDarkBlankSectors: TCheckBox;
    cbxBack: TColorBox;
    cbxGrid: TColorBox;
    tabSaving: TTabSheet;
    chkWarnConversionProblems: TCheckBox;
    chkSaveRemoveEmptyTracks: TCheckBox;
    lblMapSave: TLabel;
    edtMapX: TEdit;
    edtMapY: TEdit;
    lblBy: TLabel;
    udMapX: TUpDown;
    udMapY: TUpDown;
    chkWarnSectorChange: TCheckBox;
    procedure cbxBackChange(Sender: TObject);
    procedure cbxGridChange(Sender: TObject);
    procedure btnFontMainClick(Sender: TObject);
    procedure btnFontMapClick(Sender: TObject);
    procedure btnFontSectorClick(Sender: TObject);
    procedure edtTrackMarksChange(Sender: TObject);
    procedure btnResetClick(Sender: TObject);
    procedure chkDarkBlankSectorsClick(Sender: TObject);
  private
     MainFont, SectorFont, MapFont: TFont;
     procedure Read;
     procedure Write;
  public
    function Show: Boolean;
  end;

var
  frmOptions: TfrmOptions;

implementation

uses main;

{$R *.dfm}

procedure TfrmOptions.cbxBackChange(Sender: TObject);
begin
  DiskMap.Color := cbxBack.Selected;
end;

procedure TfrmOptions.cbxGridChange(Sender: TObject);
begin
  DiskMap.GridColor := cbxGrid.Selected;
end;

procedure TfrmOptions.btnFontMainClick(Sender: TObject);
begin
  with dlgFont do
  begin
     Font := MainFont;
     Options := Options - [fdFixedPitchOnly];
     if Execute then
     begin
        MainFont := Font;
        lblFontMain.Caption := FontDescription(MainFont);
     end;
  end;
end;

procedure TfrmOptions.btnFontMapClick(Sender: TObject);
begin
  with dlgFont do
  begin
     Font := MapFont;
     Options := Options - [fdFixedPitchOnly];
     if Execute then
     begin
        MapFont := Font;
        lblFontMap.Caption := FontDescription(MapFont);
        DiskMap.Font := MapFont;
     end;
  end;
end;

procedure TfrmOptions.btnFontSectorClick(Sender: TObject);
begin
  with dlgFont do
  begin
     Font := SectorFont;
     Options := Options + [fdFixedPitchOnly];
     if Execute then
     begin
        SectorFont := Font;
        lblFontSector.Caption := FontDescription(SectorFont);
     end;
  end;
end;

function TfrmOptions.Show: Boolean;
begin
  Read;
  Result := (ShowModal = mrOK);
  if Result then Write;
end;

procedure TfrmOptions.Read;
begin
  MainFont := FontCopy(frmMain.Font);
  SectorFont := FontCopy(frmMain.SectorFont);
  MapFont := FontCopy(frmMain.DiskMap.Font);
  lblFontMain.Caption := FontDescription(MainFont);
  lblFontSector.Caption := FontDescription(SectorFont);
  lblFontMap.Caption := FontDescription(MapFont);
  chkRestoreWindow.Checked := frmMain.RestoreWindow;
  chkRestoreWorkspace.Checked := frmMain.RestoreWorkspace;
  udBytes.Position := frmMain.BytesPerLine;
  udTrackMarks.Position := frmMain.DiskMap.TrackMark;
  chkDarkBlankSectors.Checked := frmMain.DiskMap.DarkBlankSectors;
  edtNonDisplay.Text := frmMain.UnknownASCII;
  cbxBack.Selected := frmMain.DiskMap.Color;
  cbxBackChange(Self);
  cbxGrid.Selected := frmMain.DiskMap.GridColor;
  cbxGridChange(Self);
  chkWarnConversionProblems.Checked := frmMain.WarnConversionProblems;
  chkWarnSectorChange.Checked := frmMain.WarnSectorChange;
  chkSaveRemoveEmptyTracks.Checked := frmMain.RemoveEmptyTracks;
  udMapX.Position := frmMain.SaveMapX;
  udMapY.Position := frmMain.SaveMapY;
end;

procedure TfrmOptions.Write;
begin
  with frmMain do
  begin
     frmMain.SectorFont := FontCopy(Self.SectorFont);
     frmMain.Font := FontCopy(Self.MainFont);
     DiskMap.Color := cbxBack.Selected;
     DiskMap.DarkBlankSectors := chkDarkBlankSectors.Checked;
     DiskMap.GridColor := cbxGrid.Selected;
     DiskMap.TrackMark := udTrackMarks.Position;
     DiskMap.Font := FontCopy(Self.MapFont);
     RestoreWindow := chkRestoreWindow.Checked;
     BytesPerLine := udBytes.Position;
     UnknownASCII := edtNonDisplay.Text;
     RestoreWorkspace := chkRestoreWorkspace.Checked;
     WarnConversionProblems := chkWarnConversionProblems.Checked;
     WarnSectorChange := chkWarnSectorChange.Checked;
     RemoveEmptyTracks := chkSaveRemoveEmptyTracks.Checked;
     SaveMapX := udMapX.Position;
     SaveMapY := udMapY.Position;
  end;
end;

procedure TfrmOptions.edtTrackMarksChange(Sender: TObject);
begin
  DiskMap.TrackMark := udTrackMarks.Position;
end;

procedure TfrmOptions.btnResetClick(Sender: TObject);
var
  Reg: TRegIniFile;
begin
  Reg := TRegIniFile.Create(RegKey);
  Reg.EraseSection('DiskMap');
  Reg.EraseSection('SectorView');
  Reg.EraseSection('Window');
  Reg.EraseSection('Workspace');
  frmMain.LoadSettings;
  Read;
end;

procedure TfrmOptions.chkDarkBlankSectorsClick(Sender: TObject);
begin
  DiskMap.DarkBlankSectors := chkDarkBlankSectors.Checked;
end;

end.