unit Person.View;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, System.Rtti,
  FMX.Grid.Style, FMX.StdCtrls, FMX.Controls.Presentation, FMX.ScrollBox,
  FMX.Grid, System.Generics.Collections, Person.Dto, FMX.Edit, Sco.Fmx.Grid,
  FMX.ListBox;

type

  TForm1 = class(TForm)
    StatusBar1: TStatusBar;
    Panel1: TPanel;
    ButtonFillData: TButton;
    Label1: TLabel;
    EditFilter: TEdit;
    Button1: TButton;
    ComboBoxFilter: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure ButtonFillDataClick(Sender: TObject);
    procedure EditFilterTyping(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    FNames: array[1..5] of string;
    FLastNames: array[1..5] of string;
    FKinds: array[1..5] of string;
    FGrid: TScoFmxGrid<TPersonDto>;
    FPersons: TObjectList<TPersonDto>;
    procedure BuildColumns;
    function NewPerson: TPersonDto;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

uses
  System.Math, System.Generics.Defaults, FMX.Presentation.Factory, FMX.Presentation.Style;

procedure TForm1.Button1Click(Sender: TObject);
var
  LPerson: TPersonDto;
begin
  FGrid.BeginUpdate;
  try
    LPerson := NewPerson;
    FGrid.Data.Add(LPerson);
    FGrid.RowCount := FGrid.Data.Count;
  finally
    FGrid.EndUpdate;
  end;
end;

procedure TForm1.ButtonFillDataClick(Sender: TObject);
var
  LPerson: TPersonDto;
begin
  FPersons.Clear;
  FGrid.BeginUpdate;
  try

    FGrid.Data.Clear;

    LPerson := NewPerson;
    FGrid.Data.Add(LPerson);

    LPerson := NewPerson;
    FGrid.Data.Add(LPerson);

    LPerson := NewPerson;
    FGrid.Data.Add(LPerson);

    LPerson := NewPerson;
    FGrid.Data.Add(LPerson);

    LPerson := NewPerson;
    FGrid.Data.Add(LPerson);

    FGrid.RowCount := FGrid.Data.Count;

  finally
    FGrid.EndUpdate;
  end;
end;

procedure TForm1.EditFilterTyping(Sender: TObject);
begin
  FGrid.BeginUpdate;
  try
    FGrid.Data.FilterData(ComboBoxFilter.Text, EditFilter.Text);
  finally
    FGrid.EndUpdate;
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin

  FGrid := TScoFmxGrid<TPersonDto>.Create(Self);
  Self.AddObject(FGrid);
  FGrid.Align := TAlignLayout.Client;
  FGrid.Options := FGrid.Options + [
    TGridOption.AlternatingRowBackground,
    TGridOption.RowSelect
  ];

  FPersons := TObjectList<TPersonDto>.Create;

  FNames[1] := 'Alice';
  FNames[2] := 'Bruno';
  FNames[3] := 'Carlos';
  FNames[4] := 'Daniela';
  FNames[5] := 'Eduardo';

  FLastNames[1] := 'Silva';
  FLastNames[2] := 'Santos';
  FLastNames[3] := 'Barros';
  FLastNames[4] := 'Carvalho';
  FLastNames[5] := 'Moreira';

  FKinds[1] := 'Animal';
  FKinds[2] := 'Vegetal';
  FKinds[3] := 'Mineral';
  FKinds[4] := 'Espacial';
  FKinds[5] := 'Metálico';

  BuildColumns;

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FPersons.Clear;
  FPersons.TrimExcess;
  FPersons.Free;
end;

function TForm1.NewPerson: TPersonDto;
begin
  Randomize;
  Result := TPersonDto.Create;
  Result.Name := Format('%s %s', [FNames[RandomRange(1, 5)], FLastNames[RandomRange(1, 5)]]);
  Result.Active := Random(9) < 5;
  Result.Progress := Random(99);
  Result.Kind := FKinds[RandomRange(1, 5)];
  Result.Age := Random(150);
  Result.Date := Now + RandomRange(-5, 5);
  Result.Value := RandomRange(-5, 95);
  FPersons.Add(Result);
end;

procedure TForm1.BuildColumns;
var
  LColumnInfo: TScoColumnInfo;
begin

  ComboBoxFilter.Clear;
  FGrid.ColumnsInfo.Clear;

  LColumnInfo := TScoColumnInfo.Create(
    0,
    TScoColumnType.Text,
    'Nome',
    'Name',
    150,
    EmptyStr
  );
  ComboBoxFilter.Items.Add(LColumnInfo.FieldName);
  FGrid.ColumnsInfo.Add(LColumnInfo);

  LColumnInfo := TScoColumnInfo.Create(
    1,
    TScoColumnType.Check,
    'Ativo',
    'Active',
    70,
    EmptyStr
  );
  ComboBoxFilter.Items.Add(LColumnInfo.FieldName);
  FGrid.ColumnsInfo.Add(LColumnInfo);

  LColumnInfo := TScoColumnInfo.Create(
    2,
    TScoColumnType.Progress,
    'Progresso',
    'Progress',
    150,
    EmptyStr
  );
  ComboBoxFilter.Items.Add(LColumnInfo.FieldName);
  FGrid.ColumnsInfo.Add(LColumnInfo);

  LColumnInfo := TScoColumnInfo.Create(
    3,
    TScoColumnType.Text,
    'Progresso',
    'Progress',
    150,
    EmptyStr
  );
  ComboBoxFilter.Items.Add(LColumnInfo.FieldName);
  FGrid.ColumnsInfo.Add(LColumnInfo);

  LColumnInfo := TScoColumnInfo.Create(
    4,
    TScoColumnType.PopUp,
    'Tipo',
    'Kind',
    70,
    'Animal|Mineral|Metálico|Vegetal'
  );
  ComboBoxFilter.Items.Add(LColumnInfo.FieldName);
  FGrid.ColumnsInfo.Add(LColumnInfo);

  LColumnInfo := TScoColumnInfo.Create(
    5,
    TScoColumnType.IntegerNumber,
    'Idade',
    'Age',
    70,
    EmptyStr
  );
  ComboBoxFilter.Items.Add(LColumnInfo.FieldName);
  FGrid.ColumnsInfo.Add(LColumnInfo);

  LColumnInfo := TScoColumnInfo.Create(
    6,
    TScoColumnType.DateTime,
    'Data',
    'Date',
    120,
    EmptyStr
  );
  ComboBoxFilter.Items.Add(LColumnInfo.FieldName);
  FGrid.ColumnsInfo.Add(LColumnInfo);

  LColumnInfo := TScoColumnInfo.Create(
    6,
    TScoColumnType.Currency,
    'Valor',
    'Value',
    100,
    EmptyStr
  );
  ComboBoxFilter.Items.Add(LColumnInfo.FieldName);
  FGrid.ColumnsInfo.Add(LColumnInfo);

  FGrid.ColumnsInfo.Build;

end;

initialization
  TPresentationProxyFactory.Current.Register(TScoFmxGrid<TPersonDto>, TControlType.Styled, TStyledPresentationProxy<TStyledGrid>);

finalization
  TPresentationProxyFactory.Current.Unregister(TScoFmxGrid<TPersonDto>, TControlType.Styled, TStyledPresentationProxy<TStyledGrid>);

end.
