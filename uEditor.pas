unit uEditor;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms, 
  Dialogs, JvEditor, JvHLEditor, ComCtrls, ActnList, Menus, ToolWin,
  ImgList, StdCtrls, ExtCtrls, JvExControls, JvComponent, JvEditorCommon;

type
  TfEditor = class(TForm)
    al: TActionList;
    ToolBar1: TToolBar;
    aFileClose: TAction;
    aFileSave: TAction;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    he: TJvHLEditor;
    tUpdateStatus: TTimer;
    aFileRevertToSaved: TAction;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    procedure aFileCloseExecute(Sender: TObject);
    procedure aFileSaveUpdate(Sender: TObject);
    procedure aFileSaveExecute(Sender: TObject);
    procedure tUpdateStatusTimer(Sender: TObject);
    procedure aFileRevertToSavedUpdate(Sender: TObject);
    procedure aFileRevertToSavedExecute(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure heGetLineAttr(Sender: TObject; var Line: String;
      Index: Integer; var Attrs: TLineAttrs);
  private
    FFileName: string;
    FHighlightedLine: Integer;
    procedure SetHighlightedLine(const Value: Integer);
    { Private declarations }
  public
    { Public declarations }
    property FileName: string read FFileName;
    property HighlightedLine: Integer read FHighlightedLine write SetHighlightedLine;

    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CloseFile;
    procedure Open(AFileName: string);
    procedure Save;
  end;

implementation

{$R *.dfm}

uses uMain;

{ TfEditor }

procedure TfEditor.CloseFile;
begin
  if FileName <> '' then begin
    if he.Modified then begin
      if MessageDlg(ExtractFileName(FileName) +' has been modified.'
        + ' Do you want to save the changes?', mtConfirmation,
        [mbYes, mbNo], 0) = idYes then
      Save;
    end;
    he.Lines.Clear;
    he.ReadOnly := True;
    FFileName := '';
    Caption := 'No file';
    HighlightedLine := -1;
  end;
end;

constructor TfEditor.Create(AOwner: TComponent);
begin
  inherited;
  he.ReadOnly := True;
end;

destructor TfEditor.Destroy;
begin
  CloseFile;
  inherited;
end;

procedure TfEditor.Open(AFileName: string);
begin
  CloseFile;
  he.Lines.LoadFromFile(AFileName);
  FFileName := AFileName;
  he.ReadOnly := False;
  Caption := FFileName;
  HighlightedLine := -1;
end;

procedure TfEditor.Save;
begin
  he.Lines.SaveToFile(FileName);
  he.Modified := False;
end;

procedure TfEditor.aFileCloseExecute(Sender: TObject);
begin
  Close;
end;

procedure TfEditor.aFileSaveUpdate(Sender: TObject);
begin
  aFileSave.Enabled := (FileName <> '') and (he.Modified);
end;

procedure TfEditor.aFileSaveExecute(Sender: TObject);
begin
  Save;
end;

procedure TfEditor.tUpdateStatusTimer(Sender: TObject);
begin
  if FileName = '' then
    Hint := '|No opened file.'
  else begin
    Hint := '|Column '+ IntToStr(he.CaretX+1) + ' Line '
      + IntToStr(he.CaretY+1);
    if he.CaretY <> HighlightedLine then
      HighlightedLine := -1;
  end;
end;

procedure TfEditor.aFileRevertToSavedUpdate(Sender: TObject);
begin
  aFileRevertToSaved.Enabled := (FileName <> '') and (he.Modified);
end;

procedure TfEditor.aFileRevertToSavedExecute(Sender: TObject);
begin
  if MessageDlg('Reload file and discards any changes?',
    mtConfirmation, [mbYes, mbNo], 0) = idYes then
  begin
    he.Modified := False;
    Open(FileName);
  end;
end;

procedure TfEditor.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfEditor.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Res: Integer;
begin
  if FileName <> '' then begin
    if he.Modified then begin
      Res := MessageDlg(ExtractFileName(FileName) +' has been modified.'
        + ' Do you want to save the changes?', mtConfirmation,
        [mbYes, mbNo, mbCancel], 0);
      case Res of
        idYes: Save;
        idCancel: begin
          CanClose := False;
          Exit;
        end;
      end;
    end;
    he.Lines.Clear;
    he.ReadOnly := True;
    FFileName := '';
    Caption := 'No file';
  end;
end;

procedure TfEditor.heGetLineAttr(Sender: TObject; var Line: String;
  Index: Integer; var Attrs: TLineAttrs);
var
  I: Integer;
begin
  if Index = HighlightedLine then begin
    for I := Low(Attrs) to High(Attrs) do
      Attrs[I].BC := clBtnFace;
  end;
end;

procedure TfEditor.SetHighlightedLine(const Value: Integer);
begin
  FHighlightedLine := Value;
  he.Invalidate;
end;

end.
