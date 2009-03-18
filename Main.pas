unit Main;

{
  Disk Image Manager -  Copyright 2002-2009 Envy Technologies Ltd.

  Main window
}

interface

uses
  DiskMap, DskImage, Utils, About, Options, SectorProperties,
  Classes, Graphics, Registry, SysUtils, Forms, Dialogs, Menus, ComCtrls,
  ExtCtrls, ImgList, Controls, Messages, Windows, ShellApi, Clipbrd, StrUtils;

type
  // Must match the imagelist, put sides last
  ItemType = (itDisk, itSpecification, itTracksAll, itTrack, itFiles, itSector, itAnalyse, itSides, itSide0, itSide1, itDiskCorrupt);

  TfrmMain = class(TForm)
    mnuMain: TMainMenu;
    itmDisk: TMenuItem;
    itmOpen: TMenuItem;
    itmNew: TMenuItem;
    N1: TMenuItem;
    itmSaveCopyAs: TMenuItem;
    N2: TMenuItem;
    itmExit: TMenuItem;
    itmView: TMenuItem;
    itmHelp: TMenuItem;
    itmAbout: TMenuItem;
    dlgOpen: TOpenDialog;
    pnlLeft: TPanel;
    splVertical: TSplitter;
    staBar: TStatusBar;
    pnlRight: TPanel;
    pnlListLabel: TPanel;
    tvwMain: TTreeView;
    lvwMain: TListView;
    imlSmall: TImageList;
    pnlTreeLabel: TPanel;
    N4: TMenuItem;
    itmClose: TMenuItem;
    itmOptions: TMenuItem;
    DiskMap: TSpinDiskMap;
    itmCloseAll: TMenuItem;
    dlgSave: TSaveDialog;
    popDiskMap: TPopupMenu;
    itmSaveMapAs: TMenuItem;
    dlgSaveMap: TSaveDialog;
    itmDarkBlankSectorsPop: TMenuItem;
    itmStatusBar: TMenuItem;
    N3: TMenuItem;
    N5: TMenuItem;
    itmDarkUnusedSectors: TMenuItem;
    itmSave: TMenuItem;
    popSector: TPopupMenu;
    itmSectorResetFDC: TMenuItem;
    itmSectorBlankData: TMenuItem;
    itmSectorUnformat: TMenuItem;
    N6: TMenuItem;
    itmSectorProperties: TMenuItem;
    itmEdit: TMenuItem;
    itmEditCopy: TMenuItem;
    itmEditSelectAll: TMenuItem;
    popListItem: TPopupMenu;
    itmCopyDetailsClipboard: TMenuItem;
    N7: TMenuItem;
    itmFind: TMenuItem;
    itmFindNext: TMenuItem;
    dlgFind: TFindDialog;
    procedure itmOpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tvwMainChange(Sender: TObject; Node: TTreeNode);
    procedure lvwMainDblClick(Sender: TObject);
    procedure itmAboutClick(Sender: TObject);
    procedure itmCloseClick(Sender: TObject);
    procedure itmExitClick(Sender: TObject);
    procedure itmOptionsClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure itmCloseAllClick(Sender: TObject);
    procedure itmSaveCopyAsClick(Sender: TObject);
    procedure itmSaveMapAsClick(Sender: TObject);
    procedure itmDarkBlankSectorsPopClick(Sender: TObject);
    procedure popDiskMapPopup(Sender: TObject);
    procedure itmNewClick(Sender: TObject);
    procedure itmDarkUnusedSectorsClick(Sender: TObject);
    procedure itmStatusBarClick(Sender: TObject);
    procedure itmSaveClick(Sender: TObject);
    procedure itmSectorResetFDCClick(Sender: TObject);
    procedure itmSectorBlankDataClick(Sender: TObject);
    procedure itmSectorUnformatClick(Sender: TObject);
    procedure itmSectorPropertiesClick(Sender: TObject);
    procedure itmEditCopyClick(Sender: TObject);
    procedure itmEditSelectAllClick(Sender: TObject);
    procedure itmFindClick(Sender: TObject);
    procedure dlgFindFind(Sender: TObject);
    procedure itmFindNextClick(Sender: TObject);
  private
    NextNewFile: Integer;
    function AddTree(Parent: TTreeNode; Text: String; ImageIdx: Integer; NodeObject: TObject): TTreeNode;
    function AddListInfo(Key: String; Value: String): TListItem;
    function AddListTrack(Track: TDSKTrack): TListItem;
    function AddListSector(Sector: TDSKSector): TListItem;
    function AddListSides(Side: TDSKSide): TListItem;
    procedure SetListSimple;
	  function GetSelectedSector(Sender: TObject): TDSKSector;
    function GetTitle(Data: TTreeNode): String;
  public
    SectorFont: TFont;
    RestoreWindow, RestoreWorkspace: Boolean;
    WarnConversionProblems, RemoveEmptyTracks, WarnSectorChange: Boolean;
    BytesPerLine: Integer;
    UnknownASCII: String;
    SaveMapX, SaveMapY: Integer;
    procedure AddWorkspaceImage(Image: TDSKImage);
    procedure LoadSettings;
    procedure SaveSettings;
    function CloseAll(AllowCancel: Boolean): Boolean;
	  function ConfirmChange(Action: String; Upon: String): Boolean;

	  procedure SaveImage(Image: TDSKImage);
    procedure SaveImageAs(Image: TDSKImage; Copy: Boolean);

    procedure AnalyseMap(Side: TDSKSide);
    procedure DropMsg(var msg: TWMDropFiles); message WM_DROPFILES;
    procedure RefreshList;
    procedure RefreshListFiles(FileSystem: TDSKFileSystem);
    procedure RefreshListImage(Image: TDSKImage);
    procedure RefreshListTrack(OptionalSide: TObject);
    procedure RefreshListSector(Track: TDSKTrack);
    procedure RefreshListSectorData(Sector: TDSKSector);
    procedure RefreshListSides(Disk: TDSKDisk);
    procedure RefreshListSpecification(Specification: TDSKSpecification);
    procedure UpdateMenus;

    procedure SelectTree(Parent: TTreeNodes; Item: TObject);
    procedure SelectTreeChild(Parent: TTreeNode; Item: TObject);
    function LoadImage(FileName: TFileName): Boolean;
    procedure CloseImage(Image: TDSKImage);
    function GetNextNewFile: Integer;
  end;

const
  RegKey = 'Software\Envy Technologies\Disk Image Manager';
  TAB = #9;
  CR = #13;
  LF = #10;
  EOL = CR + LF;

var
  frmMain: TfrmMain;

function GetListViewAsText(ForListView: TListView): String;

implementation

{$R *.dfm}

uses new;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  Idx: Integer;
  FileName: String;
begin
  LoadSettings;
  NextNewFile := 0;
  DragAcceptFiles(Handle,true);
  Caption := Application.Title;
  itmAbout.Caption := 'About ' + Application.Title;
  itmDarkUnusedSectors.Checked := DiskMap.DarkBlankSectors;

  for Idx := 1 to ParamCount do
  begin
    FileName := ParamStr(Idx);
    If FileExists(FileName) then LoadImage(FileName);
  end;
end;

procedure TfrmMain.itmOpenClick(Sender: TObject);
var
  Idx: Integer;
begin
  if (dlgOpen.Execute) then
     for Idx := 0 To dlgOpen.Files.Count-1 do LoadImage(dlgOpen.Files[Idx]);
end;

function TfrmMain.LoadImage(FileName: TFileName): Boolean;
var
  NewImage: TDSKImage;
begin
  NewImage := TDSKImage.Create;
  if (NewImage.LoadFile(FileName)) then
  begin
     AddWorkspaceImage(NewImage);
     Result := True;
  end
  else
  begin
     NewImage.Free;
     Result := False;
  end;
end;

procedure TfrmMain.AddWorkspaceImage(Image: TDSKImage);
var
  SIdx, TIdx, EIdx: Integer;
  ImageNode, SidesNode, SideNode, TrackNode, TracksNode: TTreeNode;
begin
	tvwMain.Items.BeginUpdate;

  if (Image.Corrupt) then
    ImageNode := AddTree(nil,ExtractFileName(Image.FileName),Ord(itDiskCorrupt),Image)
  else
    ImageNode := AddTree(nil,ExtractFileName(Image.FileName),Ord(itDisk),Image);

  if (Image.Disk.Sides > 0) then
  begin
     // Optional specification
     if (Image.Disk.Specification.Read <> dsFormatInvalid) then
        AddTree(ImageNode,'Specification',Ord(itSpecification),Image.Disk.Specification);
     // Add the sides
     SidesNode := AddTree(ImageNode,'Sides',Ord(itSides),Image.Disk);
     for SIdx := 0 to Image.Disk.Sides-1 do
     begin
        SideNode := AddTree(SidesNode,Format('Side %d',[SIdx+1]),Ord(itSide0)+SIdx,Image.Disk.Side[SIdx]);
        AddTree(SideNode, 'Map',Ord(itAnalyse),Image.Disk.Side[SIdx]);
        // Add the tracks
        TracksNode := AddTree(SideNode, 'Tracks',Ord(itTracksAll),Image.Disk.Side[SIdx]);
        with Image.Disk.Side[SIdx] do
           for TIdx := 0 to Tracks-1 do
           begin
              TrackNode := AddTree(TracksNode,Format('Track %d',[TIdx]),Ord(itTrack),Track[TIdx]);
              // Add the sectors
              with Image.Disk.Side[SIdx].Track[TIdx] do
                 for EIdx := 0 to Sectors-1 do
                    AddTree(TrackNode, SysUtils.Format('Sector %d',[EIdx]),Ord(itSector),Sector[EIdx]);
           end;
     end;
     // Add file view
     //FileNode := AddTree(ImageNode,'Files',Ord(itFiles),Image.Disk.FileSystem);
  end;
  tvwMain.Items.EndUpdate;

  ImageNode.Expanded := True;
end;

function TfrmMain.AddTree(Parent: TTreeNode; Text: String; ImageIdx: Integer; NodeObject: TObject): TTreeNode;
var
  NewTreeNode: TTreeNode;
begin
  NewTreeNode := tvwMain.Items.AddChild(Parent,Text);
  with NewTreeNode do
  begin
     ImageIndex := ImageIdx;
     SelectedIndex := ImageIdx;
     Data := NodeObject;
  end;
  Result := NewTreeNode;
end;

procedure TfrmMain.tvwMainChange(Sender: TObject; Node: TTreeNode);
begin
	UpdateMenus;
end;

procedure TfrmMain.UpdateMenus;
var
   AllowImageFile: Boolean;
begin
  AllowImageFile := False;
  tvwMain.PopupMenu := nil;

  // Decide what class operating on
  if (tvwMain.Selected <> nil) then
     if (tvwMain.Selected.Data <> nil) then
     begin
        if (TObject(tvwMain.Selected.Data).ClassType = TDSKImage) then
        begin
           AllowImageFile := True;
        end;
        if (TObject(tvwMain.Selected.Data).ClassType = TDSKSector) or
          (TObject(tvwMain.Selected.Data).ClassType = TDSKTrack) then
           tvwMain.PopupMenu := popSector;
     end;

  // Set main menu options
  itmClose.Enabled := AllowImageFile;
  itmSave.Enabled := AllowImageFile;
  itmSaveCopyAs.Enabled := AllowImageFile;

  RefreshList;
end;

function TfrmMain.GetTitle(Data: TTreeNode): String;
var
  CurNode: TTreeNode;
begin
  CurNode := tvwMain.Selected;
  while (CurNode <> nil) do
  begin
    if ((CurNode.ImageIndex <> 2) and (CurNode.ImageIndex <> 7)) or
     	(CurNode = tvwMain.Selected) then
			Result := CurNode.Text + ' > ' + Result;
        CurNode := CurNode.Parent;
  end;
  Result := Copy(Result,0,Length(Result)-3);
end;

procedure TfrmMain.RefreshList;
var
  OldViewStyle: TViewStyle;
begin
  with lvwMain do
  begin
     PopupMenu := nil;
     OldViewStyle := ViewStyle;
     Items.BeginUpdate;
     ViewStyle := vsList;
     Items.Clear;
     Columns.BeginUpdate();
     Columns.Clear;

     ParentFont := True;
     ShowColumnHeaders := True;

     if (tvwMain.Selected <> nil) then
        with tvwMain.Selected do
        begin
           pnlListLabel.Caption := AnsiReplaceStr(GetTitle(tvwMain.Selected), '&', '&&');
   				 lvwMain.Visible := not (ItemType(ImageIndex)=itAnalyse);
           DiskMap.Visible := not lvwMain.Visible;
           case ItemType(ImageIndex) of
              itDisk: RefreshListImage(Data);
              itDiskCorrupt: RefreshListImage(Data);
              itSpecification: RefreshListSpecification(Data);
              itTracksAll: RefreshListTrack(Data);
              itSides: RefreshListSides(Data);
              itTrack: RefreshListSector(Data);
              itAnalyse: AnalyseMap(Data);
              itFiles: RefreshListFiles(Data);
              else
                 if (TObject(Data).ClassType = TDSKSide) then RefreshListTrack(TDSKSide(Data));
                 if (TObject(Data).ClassType = TDSKSector) then RefreshListSectorData(TDSKSector(Data));
           end;
        end
     else
     pnlListLabel.Caption := '';
     ViewStyle := OldViewStyle;
     Columns.EndUpdate();
     Items.EndUpdate;
  end;
end;

procedure TfrmMain.RefreshListImage(Image: TDSKImage);
begin
  SetListSimple;
  if (Image <> nil) then
     with Image do
     begin
        AddListInfo('Creator',Creator);
        if (Corrupt) then
          AddListInfo('Format', DSKImageFormats[FileFormat] + ' (Corrupt)')
        else
          AddListInfo('Format',DSKImageFormats[FileFormat]);
        AddListInfo('Sides',StrInt(Disk.Sides));
        if (Disk.Sides > 0) then
        begin
           AddListInfo('Tracks per side',StrInt(Disk.Side[0].Tracks));
           AddListInfo('Track total',StrInt(Disk.TrackTotal));
           AddListInfo('Formatted capacity',SysUtils.Format('%d KB', [Disk.FormattedCapacity div BytesPerKB]));
				if Disk.IsTrackSizeUniform then
           	AddListInfo('Track size',SysUtils.Format('%d bytes',[Disk.Side[0].Track[0].Size]));
           if Disk.IsUniform(False) then
					AddListInfo('Uniform layout','Yes')
           else
           	if Disk.IsUniform(True) then
						AddListInfo('Uniform layout','Yes (except empty tracks)')
              else
						AddListInfo('Uniform layout','No');
           AddListInfo('Format analysis',Disk.DetectFormat);
				if Disk.BootableOn <> '' then
           	AddListInfo('Boot sector',Disk.BootableOn);
           if disk.HasFDCErrors then
           	AddListInfo('FDC errors','Yes')
           else
           	AddListInfo('FDC errors','No');
           if IsChanged then
           	AddListInfo('Is changed','Yes')
           else
           begin
           	AddListInfo('Is changed','No');
            //AddListInfo('Fingerprint (SHA-1)',Image.FingerPrint);
            AddListInfo('File size', SysUtils.Format('%d bytes', [FileSize]));
           end;
        end;
     end;
end;

procedure TfrmMain.SetListSimple;
begin
  lvwMain.ShowColumnHeaders := False;
  with lvwMain.Columns do
  begin
     Clear;
     with Add do
     begin
        Caption := 'Key';
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'Value';
        Width := -2;
     end;
  end;
end;

procedure TfrmMain.RefreshListSpecification(Specification: TDSKSpecification);
begin
  SetListSimple;
  Specification.Read;
  AddListInfo('Format',DSKSpecFormats[Specification.Format]);
  if (Specification.Format <> dsFormatInvalid) then
  begin
     AddListInfo('Sided',DSKSpecSides[Specification.Side]);
     AddListInfo('Track mode',DSKSpecTracks[Specification.Track]);
     AddListInfo('Tracks/side',StrInt(Specification.TracksPerSide));
     AddListInfo('Sectors/track',StrInt(Specification.SectorsPerTrack));
     AddListInfo('Directory blocks',StrInt(Specification.DirectoryBlocks));
     AddListInfo('Reserved tracks',StrInt(Specification.ReservedTracks));
     AddListInfo('Gap (format)',StrInt(Specification.GapFormat));
     AddListInfo('Gap (read/write)',StrInt(Specification.GapReadWrite));
     AddListInfo('Sector size',StrInt(Specification.SectorSize));
     AddListInfo('Block size',StrInt(Specification.BlockSize));
  end;
end;

function TfrmMain.AddListInfo(Key: String; Value: String): TListItem;
var
  NewListItem: TListItem;
begin
  NewListItem := lvwMain.Items.Add;
  with NewListItem do
  begin
     Caption := Key;
     SubItems.Add(Value);
  end;
  Result := NewListItem;
end;

procedure TfrmMain.RefreshListTrack(OptionalSide: TObject);
var
  SIdx,TIdx: Integer;
  HideSide: Boolean;
  DSK: TDSKImage;
  Side: TDSKSide;
begin
  HideSide := (OptionalSide.ClassType = TDSKSide);
  with lvwMain.Columns do
  begin
     with Add do
     begin
        Caption := 'Logical track';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'Physical track';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'Side';
        Alignment := taRightJustify;
        if HideSide then
           Width := 0
        else
           Width := -2;
     end;
     with Add do
     begin
        Caption := 'Track size';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'Sectors';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'Sector size';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'Gap';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'Filler';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := '';
        Alignment := taRightJustify;
        Width := -2;
     end;
  end;

  if HideSide then
  begin
     Side := TDSKSide(OptionalSide);
     for TIdx := 0 to Side.Tracks-1 do AddListTrack(Side.Track[TIdx]);
  end
  else
  begin
     DSK := TDSKImage(OptionalSide);
     for TIdx := 0 to DSK.Disk.Side[0].Tracks-1 do
        for SIdx := 0 to DSK.Disk.Sides-1 do AddListTrack(DSK.Disk.Side[SIdx].Track[TIdx]);
  end;
end;

function TfrmMain.AddListTrack(Track: TDSKTrack): TListItem;
var
  NewListItem: TListItem;
begin
  NewListItem := lvwMain.Items.Add;
  with NewListItem do
  begin
     Caption := StrInt(Track.Logical);
     Data := Track;
     Subitems.Add(StrInt(Track.Track));
     Subitems.Add(StrInt(Track.Side));
     Subitems.Add(StrInt(Track.Size));
     Subitems.Add(StrInt(Track.Sectors));
     Subitems.Add(StrInt(Track.SectorSize));
     Subitems.Add(StrInt(Track.GapLength));
     Subitems.Add(StrHex(Track.Filler));
  end;
  Result := NewListItem;
end;

procedure TfrmMain.RefreshListSides(Disk: TDSKDisk);
var
  Idx: Integer;
begin
  with lvwMain.Columns do
  begin
     with Add do
     begin
        Caption := 'Side';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'Tracks';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := '';
        Alignment := taRightJustify;
        Width := -2;
     end;
  end;
  for Idx := 0 to Disk.Sides-1 do AddListSides(Disk.Side[Idx]);
end;

function TfrmMain.AddListSides(Side: TDSKSide): TListItem;
var
  NewListItem: TListItem;
begin
  NewListItem := lvwMain.Items.Add;
  with NewListItem do
  begin
     Caption := StrInt(Side.Side + 1);
     SubItems.Add(StrInt(Side.Tracks));
     Data := Side;
  end;
  Result := NewListItem;
end;

procedure TfrmMain.lvwMainDblClick(Sender: TObject);
begin
  if ((tvwMain.Selected <> nil) and (lvwMain.Selected <> nil)) then
     SelectTree(tvwMain.Items,lvwMain.Selected.Data);
end;

procedure TfrmMain.SelectTree(Parent: TTreeNodes; Item: TObject);
var
  Idx: Integer;
begin
  for Idx := 0 to Parent.Count-1 do
  begin
     if (Parent.Item[Idx].Data = Item) then
        tvwMain.Selected := Parent.Item[Idx]
     else
        SelectTreeChild(Parent.Item[Idx],Item);
  end;
end;

procedure TfrmMain.SelectTreeChild(Parent: TTreeNode; Item: TObject);
var
  Idx: Integer;
begin
  for Idx := 0 to Parent.Count-1 do
  begin
     if (Parent.Item[Idx].Data = Item) then
        tvwMain.Selected := Parent.Item[Idx]
     else
        SelectTreeChild(Parent.Item[Idx],Item);
  end;
end;

procedure TfrmMain.RefreshListSector(Track: TDSKTrack);
var
  Idx: Integer;
begin
  lvwMain.PopupMenu := popSector;
  with lvwMain.Columns do
  begin
     with Add do
     begin
        Caption := 'Sector';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'Track';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'Side';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'ID';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'FDC size';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'FDC flags';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'Data size';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'Status';
        Width := -2;
     end;
     with Add do
     begin
        Caption := '';
        Alignment := taRightJustify;
        Width := -2;
     end;
  end;
  for Idx := 0 to Track.Sectors-1 do AddListSector(Track.Sector[Idx]);
end;

function TfrmMain.AddListSector(Sector: TDSKSector): TListItem;
var
  NewListItem: TListItem;
begin
  NewListItem := lvwMain.Items.Add;
  with NewListItem do
  begin
     Caption := StrInt(Sector.Sector);
     Data := Sector;
     SubItems.Add(StrInt(Sector.Track));
     SubItems.Add(StrInt(Sector.Side));
     SubItems.Add(StrInt(Sector.ID));
     SubItems.Add(StrInt(Sector.FDCSize));
     SubItems.Add(Format('%d, %d',[Sector.FDCStatus[1], Sector.FDCStatus[2]]));
     if (Sector.DataSize <> Sector.AdvertisedSize) then
       SubItems.Add(Format('%d (%d)', [Sector.DataSize, Sector.AdvertisedSize]))
     else
       SubItems.Add(StrInt(Sector.DataSize));
     SubItems.Add(DSKSectorStatus[Sector.Status]);
  end;
  Result := NewListItem;
end;

procedure TfrmMain.RefreshListSectorData(Sector: TDSKSector);
var
  Idx: Integer;
  SecData: String;
  SecHex: String;
begin
  lvwMain.Font := SectorFont;
  with lvwMain.Columns do
  begin
     Clear;
     BeginUpdate;
     with Add do
     begin
        Caption := 'Off';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'Hex';
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'ASCII';
        Width := -2;
     end;
  end;

  for Idx := 0 to Sector.DataSize do
  begin
     if ((Idx mod BytesPerLine = 0) and (Idx > 0)) then
     begin
        with lvwMain.Items.Add do
        begin
           Caption := StrInt(Idx-BytesPerLine);
           Subitems.Add(SecHex);
           Subitems.Add(SecData);
        end;
        SecData := '';
        SecHex := '';
     end;

     if (Idx < Sector.DataSize) then
     begin
	     if (Sector.Data[Idx] > 31) then
	        SecData := SecData + Char(Sector.Data[Idx])
	     else
	        SecData := SecData + UnknownASCII;
  	   SecHex := SecHex + StrHex(Sector.Data[Idx]) + ' ';
     end;
  end;
end;

// Menu: Help > About
procedure TfrmMain.itmAboutClick(Sender: TObject);
begin
  frmAbout := TfrmAbout.Create(Self);
  frmAbout.ShowModal;
  frmAbout.Free;
end;

// Find a disk image and remove it from the tree
procedure TfrmMain.CloseImage(Image: TDSKImage);
var
  Idx: Integer;
begin
  for Idx := 0 to tvwMain.Items.Count-1 do
     if ((tvwMain.Items[Idx].Data = Image) and
        (tvwMain.Items[Idx].ImageIndex = 0)) then
     begin
        TDSKImage(tvwMain.Items[Idx].Data).Free;
        tvwMain.Items[Idx].Delete;
        RefreshList;
        exit;
     end;
end;

procedure TfrmMain.itmCloseClick(Sender: TObject);
begin
  if (tvwMain.Selected <> nil) then
     if (tvwMain.Selected.ImageIndex = 0) then
        CloseImage(TDSKImage(tvwMain.Selected.Data));
end;

procedure TfrmMain.itmExitClick(Sender: TObject);
begin
  // TODO: Interrogate through disk images, see if any unsaved and prompt
  Close;
end;

// Show the disk map
procedure TfrmMain.AnalyseMap(Side: TDSKSide);
begin
  lvwMain.Visible := False;
  DiskMap.Side := Side;
  DiskMap.Visible := True;
end;

// Load list with filenames
procedure TfrmMain.RefreshListFiles(FileSystem: TDSKFileSystem);
var
  Idx: Integer;
  NewFile: TDSKFile;
begin
  with lvwMain.Columns do
  begin
     with Add do
     begin
        Caption := 'File name';
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'Size';
        Alignment := taRightJustify;
        Width := -2;
     end;
     with Add do
     begin
        Caption := 'Type';
        Width := -2;
     end;
  end;

  for Idx := 0 to 10 do
  begin
     with lvwMain.Items.Add do
     begin
        NewFile := FileSystem.GetDiskFile(Idx);
        Caption := NewFile.FileName;
        Subitems.Add(StrInt(NewFile.Size));
        Subitems.Add(Newfile.FileType);
     end;
  end;
end;

// Menu: View > Options
procedure TfrmMain.itmOptionsClick(Sender: TObject);
var
	frmOptions: TfrmOptions;
begin
	frmOptions := TfrmOptions.Create(Self);
	frmOptions.Show;
end;

// Windows: Files dropped from explorer
procedure TfrmMain.DropMsg(var msg: TWMDropFiles);
var
  Files, Idx: Integer;
  FileBuf: array[0..255] of Char;
  FileName : String;
begin
  Files := DragQueryFile(Msg.Drop, $FFFFFFFF, FileBuf, SizeOf(FileName));
  for Idx := 0 to Files-1 do
  begin
     FileName := Copy(FileBuf, 0, DragQueryFile(Msg.Drop, Idx, FileBuf, 255));
     LoadImage(FileName);
  end;
  Msg.Result:=0;
  DragFinish(msg.Drop);
end;

// Load system settings
procedure TfrmMain.LoadSettings;
var
  Reg: TRegIniFile;
  Count, Idx: Integer;
  FileName: TFileName;
  S: String;
begin
  Reg := TRegIniFile.Create(RegKey);

  S := 'DiskMap';
  DiskMap.DarkBlankSectors := Reg.ReadBool(S,'DarkBlankSectors',True);
  DiskMap.Font := FontFromDescription(Reg.ReadString(S,'Font','Tahoma,7pt,,'));
  DiskMap.Color := TColor(Reg.ReadInteger(S,'BackgroundColour',Integer(clGray)));
  DiskMap.GridColor := TColor(Reg.ReadInteger(S,'GridColour',Integer(clSilver)));
  DiskMap.TrackMark := Reg.ReadInteger(S,'TrackMark',5);

  S := 'Window';
  frmMain.Font := FontFromDescription(Reg.ReadString(S,'Font','Tahoma,8pt,,'));
  RestoreWindow := Reg.ReadBool(S,'Restore',False);
  if RestoreWindow then
  begin
     Left := Reg.ReadInteger(S,'Left',Left);
     Top := Reg.ReadInteger(S,'Top',Top);
     Height := Reg.ReadInteger(S,'Height',Height);
     Width := Reg.ReadInteger(S,'Width',Width);
     tvwMain.Width := Reg.ReadInteger(S,'TreeWidth',tvwMain.Width);
  end;

  S := 'SectorView';
  UnknownASCII := Reg.ReadString(S,'UnknownASCII','?');
  BytesPerLine := Reg.ReadInteger(S,'BytesPerLine',8);
  SectorFont := FontFromDescription(Reg.ReadString(S,'Font','Lucida Console,7pt,,'));
  WarnSectorChange := Reg.ReadBool(S,'WarnSectorChange',True);

  S := 'Workspace';
  RestoreWorkspace := Reg.ReadBool(S,'Restore',False);
  if RestoreWorkspace then
  begin
     Count := Reg.ReadInteger(S,'',0);
     for Idx := 1 to Count do
     begin
        FileName := Reg.ReadString(S,StrInt(Idx),'');
        If FileExists(FileName) then LoadImage(FileName);
     end;
  end;

  S := 'Saving';
  WarnConversionProblems := Reg.ReadBool(S,'WarnConversionProblems',True);
  RemoveEmptyTracks := Reg.ReadBool(S,'RemoveEmptyTracks',False);
 	SaveMapX := Reg.ReadInteger('S','MapWidth',640);
 	SaveMapY := Reg.ReadInteger('S','MapHeight',480);

  Reg.Free;
end;

procedure TfrmMain.SaveSettings;
var
  Reg: TRegIniFile;
  Idx, Count: Integer;
  S: String;
begin
  Reg := TRegIniFile.Create(RegKey);

  S := 'DiskMap';
  Reg.WriteInteger(S,'BackgroundColour',Integer(DiskMap.Color));
  Reg.WriteBool(s,'DarkBlankSectors',DiskMap.DarkBlankSectors);
  Reg.WriteInteger(S,'GridColour',Integer(DiskMap.GridColor));
  Reg.WriteInteger(S,'TrackMark',DiskMap.TrackMark);
  Reg.WriteString(S,'Font',FontToDescription(DiskMap.Font));

  S := 'Window';
  Reg.WriteBool(S,'Restore',RestoreWindow);
  Reg.WriteInteger(S,'Left',Left);
  Reg.WriteInteger(S,'Top',Top);
  Reg.WriteInteger(S,'Height',Top);
  Reg.WriteInteger(S,'Width',Width);
  Reg.WriteInteger(S,'TreeWidth',tvwMain.Width);
  Reg.WriteString(S,'Font',FontToDescription(frmMain.Font));

  S := 'SectorView';
  Reg.WriteString(S,'UnknownASCII',UnknownASCII);
  Reg.WriteInteger(S,'BytesPerLine',BytesPerLine);
  Reg.WriteString(S,'Font',FontToDescription(SectorFont));
  Reg.WriteBool(S,'WarnSectorChange',WarnSectorChange);

  S := 'Workspace';
  Count := 1;
  Reg.EraseSection(S);
  Reg.WriteBool(S,'Restore',RestoreWorkspace);
  for Idx := 0 to tvwMain.Items.Count-1 do
  begin
     if (tvwMain.Items[Idx].Data <> nil) then
        if (TObject(tvwMain.Items[Idx].Data).ClassType = TDSKImage) then
           begin
              Reg.WriteString(S,StrInt(Count),TDSKImage(tvwMain.Items[Idx].Data).FileName);
              inc(Count);
           end;
  end;
  Reg.WriteInteger(S,'',Count-1);

  S := 'Saving';
  Reg.WriteBool(S,'WarnConversionProblems',WarnConversionProblems);
  Reg.WriteBool(S,'RemoveEmptyTracks',RemoveEmptyTracks);
  Reg.WriteInteger(S,'MapWidth',SaveMapX);
  Reg.WriteInteger(S,'MapHeight',SaveMapY);

  Reg.Free;
end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  SaveSettings;
	if (CloseAll(true)) then
  begin
    Action := caFree;
  end
  else
  	Action := caNone;
end;

procedure TfrmMain.itmCloseAllClick(Sender: TObject);
begin
	CloseAll(True);
end;

function TfrmMain.CloseAll(AllowCancel: Boolean): Boolean;
var
	Image: TDSKImage;
  Buttons: TMsgDlgButtons;
begin
	Result := True;
	if AllowCancel then
		Buttons := [mbYes, mbNo, mbCancel]
  else
		Buttons := [mbYes, mbNo];

	while (tvwMain.Items.GetFirstNode <> nil) do
  begin
		if (tvwMain.Items.GetFirstNode.ImageIndex = Ord(itDisk)) or (tvwMain.Items.GetFirstNode.ImageIndex = Ord(itDiskCorrupt)) then
     begin
       Image := TDSKImage(tvwMain.Items.GetFirstNode.Data);
       if Image.IsChanged and not Image.Corrupt then
       	  case MessageDlg(Format('Save unsaved image "%s" ?',[Image.FileName]), mtWarning, Buttons,0) of
          	 mrYes:		SaveImage(Image);
            mrCancel:
            	begin
              	Result := False;
              	exit;
              end;
          end;
		  Image.Free;
	     tvwMain.Items.GetFirstNode.Delete;
     end;
   end;
  RefreshList;
  UpdateMenus;
end;

procedure TfrmMain.itmSaveCopyAsClick(Sender: TObject);
begin
	if (TObject(tvwMain.Selected.Data).ClassType = TDSKImage) then
  	SaveImageAs(TDSKImage(tvwMain.Selected.Data),True);
end;

procedure TfrmMain.SaveImageAs(Image: TDSKImage; Copy:Boolean);
begin
	dlgSave.FileName := Image.FileName;
	case Image.FileFormat of
    	diStandardDSK: dlgSave.FilterIndex := 1;
     diExtendedDSK: dlgSave.FilterIndex := 2;
  end;

  if dlgSave.Execute then
	    case dlgSave.FilterIndex of
 	   	1: begin
        		if ((not Image.Disk.IsTrackSizeUniform) and Self.WarnConversionProblems) then
          			if MessageDlg('This image has variable track sizes that "Standard DSK format" does not support. ' +
                 	'Save anyway using largest track size?',mtWarning, [mbYes, mbNo],0) = mrOK then
                    Image.SaveFile(dlgSave.FileName,diStandardDSK,True,False)
                 else
                 	exit
              else
						Image.SaveFile(dlgSave.FileName,diStandardDSK,Copy,False);
        	end;
    	   2: Image.SaveFile(dlgSave.FileName,diExtendedDSK,Copy,RemoveEmptyTracks);
     end;
end;

procedure TfrmMain.itmSaveMapAsClick(Sender: TObject);
begin
	if dlgSaveMap.Execute then
  	DiskMap.SaveMap(dlgSaveMap.FileName, SaveMapX, SaveMapY);
end;

procedure TfrmMain.itmDarkBlankSectorsPopClick(Sender: TObject);
begin
	DiskMap.DarkBlankSectors := not itmDarkBlankSectorsPop.Checked;
  itmDarkBlankSectorsPop.Checked := DiskMap.DarkBlankSectors;
end;

procedure TfrmMain.popDiskMapPopup(Sender: TObject);
begin
	itmDarkBlankSectorsPop.Checked := DiskMap.DarkBlankSectors;
end;

procedure TfrmMain.itmNewClick(Sender: TObject);
begin
	TfrmNew.Create(Self).Show;
end;

function TfrmMain.GetNextNewFile: Integer;
begin
	NextNewFile := NextNewFile + 1;
  Result := NextNewFile;
end;

procedure TfrmMain.itmDarkUnusedSectorsClick(Sender: TObject);
begin
	DiskMap.DarkBlankSectors := not itmDarkUnusedSectors.Checked;
  itmDarkUnusedSectors.Checked := DiskMap.DarkBlankSectors;
end;

procedure TfrmMain.itmStatusBarClick(Sender: TObject);
begin
	 staBar.Visible := not itmStatusBar.Checked;
   itmStatusBar.Checked := staBar.visible;
end;

procedure TfrmMain.itmSaveClick(Sender: TObject);
begin
	if (TObject(tvwMain.Selected.Data).ClassType = TDSKImage) then
  	SaveImage(TDSKImage(tvwMain.Selected.Data));
end;

procedure TfrmMain.SaveImage(Image: TDSKImage);
begin
  if (Image.FileFormat=diNotYetSaved) then
  	SaveImageAs(Image,False)
  else
    	Image.SaveFile(Image.FileName,Image.FileFormat,False,(RemoveEmptyTracks and (Image.FileFormat=diExtendedDSK)));
end;

procedure TfrmMain.itmSectorResetFDCClick(Sender: TObject);
var
  Track: TDSKTrack;
  TIdx: Integer;
begin
 	if (tvwMain.Selected <> nil) then
  begin
     if (TObject(tvwMain.Selected.Data).ClassType = TDSKTrack) then
     	  if ConfirmChange('reset FDC flags for', 'track') then
		    begin
          Track := TDSKTrack(tvwMain.Selected.Data);
          for TIdx := 0 to (Track.Sectors - 1) do
            Track.Sector[TIdx].ResetFDC;
        end;
     if (TObject(tvwMain.Selected.Data).ClassType = TDSKSector) then
     	  if ConfirmChange('reset FDC flags for', 'sector') then
			    TDSKSector(tvwMain.Selected.Data).ResetFDC;
     UpdateMenus;
  end;
end;

function TfrmMain.GetSelectedSector(Sender: TObject): TDSKSector;
begin
	Result := nil;

  if (Sender = lvwMain) then
  	if (lvwMain.Selected <> nil) then
	   	with lvwMain.Selected do
				Result := TDSKSector(Data);
end;

procedure TfrmMain.itmSectorBlankDataClick(Sender: TObject);
var
	Sector: TDSKSector;
begin
	Sector := GetSelectedSector(popSector.PopupComponent);
  if (Sector <> nil) then
  	if ConfirmChange('format','sector') then
		   begin
        Sector.DataSize := Sector.ParentTrack.SectorSize;
			  Sector.FillSector(Sector.ParentTrack.Filler);
     	  UpdateMenus;
		   end;
end;

procedure TfrmMain.itmSectorUnformatClick(Sender: TObject);
begin
 	if (tvwMain.Selected <> nil) then
  begin
     if (TObject(tvwMain.Selected.Data).ClassType = TDSKTrack) then
     	  if ConfirmChange('unformat', 'track') then
        begin
          TDSKTrack(tvwMain.Selected.Data).Unformat;
          tvwMain.Selected.DeleteChildren;
        end;
     if (TObject(tvwMain.Selected.Data).ClassType = TDSKSector) then
     	  if ConfirmChange('unformat', 'sector') then
			    TDSKSector(tvwMain.Selected.Data).Unformat;
     UpdateMenus;
  end;
end;

procedure TfrmMain.itmSectorPropertiesClick(Sender: TObject);
var
  Track: TDSKTrack;
  TIdx: Integer;
begin
 	if (tvwMain.Selected <> nil) then
  begin
     if (TObject(tvwMain.Selected.Data).ClassType = TDSKTrack) then
		    begin
          Track := TDSKTrack(tvwMain.Selected.Data);
          for TIdx := 0 to (Track.Sectors - 1) do
            TfrmSector.Create(Self, Track.Sector[TIdx]);
        end;
     if (TObject(tvwMain.Selected.Data).ClassType = TDSKSector) then
        TfrmSector.Create(Self, TDSKSector(tvwMain.Selected.Data));
     UpdateMenus;
  end;
end;

function TfrmMain.ConfirmChange(Action: String; Upon: String): Boolean;
begin
	if WarnSectorChange then
	 	Result := (MessageDlg('You are about to ' + Action + ' this ' + Upon + ' ' +
     			 CR + CR +'Do you know what you are doing?',mtWarning,
	        		[mbYes, mbNo],0) = mrYes)
  else
  	Result := True;
end;

function GetListViewAsText(ForListView: TListView): String;
var
  CIdx, RIdx: Integer;
begin
  // Headings
  for CIdx := 0 to ForListView.Columns.Count-1 do
    Result := Result + ForListView.Columns[CIdx].Caption + TAB;
  Result := Result + EOL;

  // Details
  for RIdx := 0 to ForListView.Items.Count-1 do
    if (ForListView.Items[RIdx].Selected) then
    begin
      Result := Result + ForListView.Items[RIdx].Caption + TAB;
      for CIdx := 0 to ForListView.Items[RIdx].SubItems.Count-1 do
        Result := Result + ForListView.Items[RIdx].SubItems[CIdx] + TAB;
      Result := Result + EOL;
    end;
end;

procedure TfrmMain.itmEditCopyClick(Sender: TObject);
begin
  Clipboard.AsText := GetListViewAsText(lvwMain);
end;

procedure TfrmMain.itmEditSelectAllClick(Sender: TObject);
begin
  lvwMain.SelectAll;
end;

procedure TfrmMain.itmFindClick(Sender: TObject);
begin
  dlgFind.Execute;
end;

procedure TfrmMain.dlgFindFind(Sender: TObject);
var
  StartSector, FoundSector: TDSKSector;
  TreeIdx: Integer;
  Obj: TObject;
begin
  if (tvwMain.Selected.Data = nil) then exit;

  // Find out where to start searching
  Obj := TObject(tvwMain.Selected.Data);
  StartSector := nil;
  if (Obj.ClassType = TDSKImage) then
     StartSector := TDSKImage(Obj).Disk.Side[0].Track[0].Sector[0];
  if (Obj.ClassType = TDSKDisk) then
     StartSector := TDSKDisk(Obj).Side[0].Track[0].Sector[0];
  if (Obj.ClassType = TDSKSide) then
     StartSector := TDSKSide(Obj).Track[0].Sector[0];
  if (Obj.ClassType = TDSKTrack) then
     StartSector := TDSKTrack(Obj).Sector[0];
  if (Obj.ClassType = TDSKSector) then
     StartSector := TDSKSector(Obj);

  if (StartSector = nil) then exit;

  FoundSector := StartSector.ParentTrack.ParentSide.ParentDisk.ParentImage.FindText(StartSector, dlgFind.FindText, frMatchCase in dlgFind.Options);

  if (FoundSector <> nil) then
  begin
    for TreeIdx := 0 to tvwMain.Items.Count-1 do
      if (tvwMain.Items[TreeIdx].Data = FoundSector) then
        tvwMain.Selected := tvwMain.Items[TreeIdx];
  end;
end;

procedure TfrmMain.itmFindNextClick(Sender: TObject);
begin
  dlgFindFind(Sender);
end;

end.
