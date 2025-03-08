unit Sco.Fmx.Grid;

interface

uses
  System.Generics.Collections, FMX.Grid, FMX.Grid.Style,
  System.Classes, System.Rtti;

type

  TScoFmxGrid<T: class> = class;

  TScoFieldOrder = (Asc, Desc);

  TScoColumnType = (Text, Check, Progress, PopUp, IntegerNumber, DateTime, Currency, Float, Image);

  TScoColumnInfo = record
    Id: string;
    Index: Integer;
    ColumnType: TScoColumnType;
    Header: string;
    FieldName: string;
    Width: Integer;
    PopUpItens: string;
  public
    constructor Create(AIndex: Integer; AColumnType: TScoColumnType; AHeader: string; AFieldName: string; AWidth: Integer; APopUpItens: string);
  end;

  TScoGridData<T: class> = class
  private
    FOwner: TScoFmxGrid<T>;
    FData: TList<T>;
    FVisibleData: TDictionary<Integer, T>;
    function CompareProperty(const APropName: string; ALeft, ARigth: T; const AOrder: TScoFieldOrder): Integer;
    function PropertyHastext(const AObject: T; const APropName: string; const AValue: string): Boolean;
  public
    constructor Create(const AOwner: TScoFmxGrid<T>);
    destructor Destroy; override;

    procedure Clear;

    procedure Add(const Value: T);
    function Count: Integer;
    function TryGetValue(const Key: integer; var Value: T): Boolean;
    procedure Update(const Key: integer; var Value: T);

    procedure OrderData(const APropertyName: string; const AOrder: TScoFieldOrder);
    procedure FilterData(const APropertyName: string; const Value: string);

    property Data: TList<T> read FData;
    property VisibleData: TDictionary<Integer, T> read FVisibleData;
  end;

  TMyGridColumnsInfo<T: class> = class
  private
    FOwner: TScoFmxGrid<T>;
    FColumns: TDictionary<string, TScoColumnInfo>;
    procedure CreateCheckColumn(AInfo: TScoColumnInfo);
    procedure CreateIntegerColumn(AInfo: TScoColumnInfo);
    procedure CreatePopUpColumn(AInfo: TScoColumnInfo);
    procedure CreateProgressColumn(AInfo: TScoColumnInfo);
    procedure CreateTextColumn(AInfo: TScoColumnInfo);
    procedure CreateDateTimeColumn(AInfo: TScoColumnInfo);
    procedure CreateCurrencyColumn(AInfo: TScoColumnInfo);
  public
    constructor Create(const AOwner: TScoFmxGrid<T>);
    destructor Destroy; override;

    function Add(AInfo: TScoColumnInfo): string;
    procedure Clear;
    function GetById(const AId: string): TScoColumnInfo;
    procedure Build;
  end;

  TScoFmxGrid<T: class> = class(TCustomGrid)
  private
    FData: TScoGridData<T>;
    FColumnsInfo: TMyGridColumnsInfo<T>;
    function GetPropertyValue(AObject: T;
      const APropName: string): Variant;
    procedure SetPropertyValue(AObject: T; const APropName: string;
      const AValue: TValue);
    function VariantToTValue(const AValue: Variant): TValue;
  protected
    function GetDefaultStyleLookupName: string; override;
    procedure DoEndUpdate; override;

    procedure DoOnGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
    procedure DoOnSetValue(Sender: TObject; const ACol, ARow: Integer; const Value: TValue);
    procedure DoOnHeaderClick(Column: TColumn);

  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;

    property Data: TScoGridData<T> read FData;
    property ColumnsInfo: TMyGridColumnsInfo<T> read FColumnsInfo;

  published
    property Anchors;
    property Align;
    property CanFocus;
    property CanParentFocus;
    property ClipChildren;
    property ClipParent;
    property ControlType;
    property Cursor;
    property DisableFocusEffect;
    property DragMode;
    property EnableDragHighlight;
    property Enabled;
    property Height;
    property HelpContext;
    property HelpKeyword;
    property HelpType;
    property HitTest;
    property Locked;
    property Padding;
    property Opacity;
    property Margins;
    property PopupMenu;
    property Position;
    property ReadOnly;
    property RotationAngle;
    property RotationCenter;
    property Scale;
    property Size;
    property StyleLookup;
    property TextSettings;
    property StyledSettings;
    property TabOrder;
    property TabStop;
    property TouchTargetExpansion;
    property Visible;
    property Width;
    property RowHeight;
    property RowCount;
    property Options;
    property Images;

    property DefaultDrawing;
    property OnHeaderClick;
    property OnColumnMoved;
    property OnDrawColumnHeader;
    property OnSelectCell;
    property OnSelChanged;
    property OnDrawColumnBackground;
    property OnDrawColumnCell;
    //property OnGetValue;
    //property OnSetValue;
    property OnCreateCustomEditor;
    property OnEditingDone;
    property OnResize;
    property OnResized;
    property OnCellClick;
    property OnCellDblClick;
    property OnDragEnter;
    property OnDragLeave;
    property OnDragOver;
    property OnDragDrop;
    property OnDragEnd;
  end;


implementation

uses
  System.Generics.Defaults, System.Math, System.SysUtils, FMX.Presentation.Factory,
  FMX.Controls, FMX.Presentation.Style, System.Types, System.Variants;

{ TScoGridData }

procedure TScoGridData<T>.Add(const Value: T);
begin
  FData.Add(Value);
  FVisibleData.AddOrSetValue(FVisibleData.Count, Value);
end;

procedure TScoGridData<T>.Clear;
begin
  FData.Clear;
  FData.TrimExcess;

  FVisibleData.Clear;
  FVisibleData.TrimExcess;
end;

function TScoGridData<T>.Count: Integer;
begin
  Result := FVisibleData.Count;
end;

constructor TScoGridData<T>.Create(const AOwner: TScoFmxGrid<T>);
begin
  FOwner := AOwner;
  FData := TList<T>.Create;
  FVisibleData := TDictionary<Integer, T>.Create;
end;

destructor TScoGridData<T>.Destroy;
begin
  FData.Clear;
  FVisibleData.Clear;

  FData.Free;
  FVisibleData.Free;
  inherited;
end;

procedure TScoGridData<T>.FilterData(const APropertyName, Value: string);
var
  LValue: T;
begin

  FVisibleData.Clear;
  FVisibleData.TrimExcess;

  for LValue in FData do
  begin

    if Value.Trim.IsEmpty then
    begin
      FVisibleData.AddOrSetValue(FVisibleData.Count, LValue);
      Continue;
    end;

    if PropertyHastext(LValue, APropertyName, Value) then
      FVisibleData.AddOrSetValue(FVisibleData.Count, LValue);

  end;
  FOwner.RowCount := FVisibleData.Count;
end;

function TScoGridData<T>.CompareProperty(const APropName: string; ALeft, ARigth: T; const AOrder: TScoFieldOrder): Integer;
var
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  RttiProp: TRttiProperty;
  LValueLeft, LValueRigth: TValue;
  LObjLeft, LObjRigth: TObject;
begin
  Result := 0;

  if not Assigned(ALeft) or not Assigned(ARigth) then
    raise Exception.Create('Os objetos não podem ser nulos.');

  // Obtém informações de RTTI
  RttiType := RttiContext.GetType(T);
  RttiProp := RttiType.GetProperty(APropName);

  if not Assigned(RttiProp) or not RttiProp.IsReadable then
    raise Exception.CreateFmt('Propriedade "%s" não encontrada ou não pode ser lida.', [APropName]);

  LObjLeft := TObject(ALeft);
  LObjRigth := TObject(ARigth);

  // Obtém os valores das propriedades dos objetos
  LValueLeft := RttiProp.GetValue(LObjLeft);
  LValueRigth := RttiProp.GetValue(LObjRigth);

  // Comparação de valores conforme o tipo
  case RttiProp.PropertyType.TypeKind of
    tkInteger, tkInt64:
      Result := CompareValue(LValueLeft.AsInteger, LValueRigth.AsInteger);
    tkFloat:
      Result := CompareValue(LValueLeft.AsExtended, LValueRigth.AsExtended);
    tkUString, tkString, tkLString, tkWString:
      Result := CompareStr(LValueLeft.AsString, LValueRigth.AsString);
    tkEnumeration:
      if RttiProp.PropertyType.Handle = TypeInfo(Boolean) then
        Result := CompareValue(Integer(LValueLeft.AsBoolean), Integer(LValueRigth.AsBoolean));
  else
    raise Exception.Create('Tipo de propriedade não suportado para comparação.');
  end;
  Result := Result * IfThen(AOrder = Asc, 1, -1);
end;

procedure TScoGridData<T>.OrderData(const APropertyName: string; const AOrder: TScoFieldOrder);
var
  LValue: T;
  LList: TList<T>;
begin
  LList := TList<T>.Create;
  try
    LList.AddRange(FVisibleData.Values);
    LList.Sort(
      TComparer<T>.Construct(
        function (const Left, Right: T): integer
        begin
          Result := CompareProperty(APropertyName, Left, Right, AOrder);
        end
      )
    );
    FVisibleData.Clear;
    FVisibleData.TrimExcess;
    for LValue in LList do
      FVisibleData.AddOrSetValue(FVisibleData.Count, LValue);

  finally
    LList.Free;
  end;
end;

function TScoGridData<T>.PropertyHastext(const AObject: T; const APropName, AValue: string): Boolean;
var
  strValor: string;
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  RttiProp: TRttiProperty;
  LValueLeft: TValue;
  LObjLeft: TObject;
begin
  Result := False;

  if not Assigned(AObject) then
    raise Exception.Create('O objeto não pode ser nulo!.');

  // Obtém informações de RTTI
  RttiType := RttiContext.GetType(T);
  RttiProp := RttiType.GetProperty(APropName);

  if not Assigned(RttiProp) or not RttiProp.IsReadable then
    raise Exception.CreateFmt('Propriedade "%s" não encontrada ou não pode ser lida.', [APropName]);

  LObjLeft := TObject(AObject);

  // Obtém os valores das propriedades dos objetos
  LValueLeft := RttiProp.GetValue(LObjLeft);

  if Assigned(RttiProp) and RttiProp.IsReadable then
  begin
    case RttiProp.PropertyType.TypeKind of
      tkInteger:
        strValor := LValueLeft.AsInteger.ToString;
      tkFloat:
        if RttiProp.PropertyType.Handle = TypeInfo(Single) then
          strValor := LValueLeft.AsType<Single>.ToString
        else
          strValor := LValueLeft.AsExtended.ToString;
      tkString, tkLString, tkWString, tkUString:
        strValor := LValueLeft.AsString;
      tkEnumeration:
        if RttiProp.PropertyType.Handle = TypeInfo(Boolean) then
          strValor := LValueLeft.AsBoolean.ToString(True);
    end;
  end;

  Result := Pos(AValue, strValor) > 0;

end;

function TScoGridData<T>.TryGetValue(const Key: integer; var Value: T): Boolean;
begin
  Result := FVisibleData.TryGetValue(Key, Value);
end;

procedure TScoGridData<T>.Update(const Key: integer; var Value: T);
begin
  FVisibleData.AddOrSetValue(Key, Value);
end;

{ TScoFmxGrid }

constructor TScoFmxGrid<T>.Create(AOwner: TComponent);
begin
  inherited;
  FData := TScoGridData<T>.Create(Self);
  FColumnsInfo := TMyGridColumnsInfo<T>.Create(Self);
  RowCount := 0;

  Self.OnGetValue := DoOnGetValue;
  Self.OnSetValue := DoOnSetValue;
  Self.OnHeaderClick := DoOnHeaderClick;

end;

destructor TScoFmxGrid<T>.Destroy;
begin
  FData.Free;
  FColumnsInfo.Free;
  inherited;
end;

procedure TScoFmxGrid<T>.DoEndUpdate;
begin
  Model.ClearCache;
  inherited;
end;

function TScoFmxGrid<T>.VariantToTValue(const AValue: Variant): TValue;
begin
  case VarType(AValue) of
    varSmallint, varInteger, varByte, varShortInt, varWord, varLongWord, varInt64:
      Result := TValue.From<Integer>(AValue);
    varSingle:
      Result := TValue.From<Single>(AValue);
    varDouble, varCurrency:
      Result := TValue.From<Double>(AValue);
    varBoolean:
      Result := TValue.From<Boolean>(AValue);
    varUString, varOleStr, varString:
      Result := TValue.From<string>(AValue);
    else
      raise Exception.Create('Tipo de Variant não suportado para conversão.');
  end;
end;

function TScoFmxGrid<T>.GetPropertyValue(AObject: T; const APropName: string): Variant;
var
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  RttiProp: TRttiProperty;
  Obj: TObject;
begin
  Result := Null;

  if not Assigned(AObject) then
    Exit;

  // Obtendo o objeto por trás da interface
  Obj := TObject(AObject);

  // Criando o contexto RTTI
  RttiType := RttiContext.GetType(Obj.ClassType);

  // Buscando a propriedade pelo nome
  RttiProp := RttiType.GetProperty(APropName);

  if Assigned(RttiProp) and RttiProp.IsReadable then
  begin
    case RttiProp.PropertyType.TypeKind of
      tkInteger: Result := RttiProp.GetValue(Obj).AsInteger;
      tkFloat:
        if RttiProp.PropertyType.Handle = TypeInfo(Single) then
          Result := RttiProp.GetValue(Obj).AsType<Single>
        else
          Result := RttiProp.GetValue(Obj).AsExtended;
      tkString, tkLString, tkWString, tkUString:
        Result := RttiProp.GetValue(Obj).AsString;
      tkEnumeration:
        if RttiProp.PropertyType.Handle = TypeInfo(Boolean) then
          Result := RttiProp.GetValue(Obj).AsBoolean;
    end;
  end;
end;

procedure TScoFmxGrid<T>.DoOnGetValue(Sender: TObject; const ACol, ARow: Integer; var Value: TValue);
var
  LPerson: T;
  LColumn: TColumn;
  LColumnInfo: TScoColumnInfo;
  LValue: Variant;
begin

  if not FData.TryGetValue(ARow, LPerson) then
    Exit;

  LColumn := Self.Columns[ACol];

  LColumnInfo := FColumnsInfo.GetById(LColumn.TagString);

  LValue := GetPropertyValue(LPerson, LColumnInfo.FieldName);
  Value := VariantToTValue(LValue);

end;

procedure TScoFmxGrid<T>.DoOnHeaderClick(Column: TColumn);
var
  LColumn: TColumn;
  LColumnInfo: TScoColumnInfo;
  i: integer;
begin

  // coluna atual
  case Column.Tag of
    0: Column.Tag := 1; // se não esta ordenado, deixa crescente
    1: Column.Tag := 2; // se esta crescente, deixa decrecente
    2: Column.Tag := 1; // se esta decrecente, deixa crescente
  end;

  // desmarcar as demais colunas
  for I := 0 to Self.ColumnCount - 1 do
  begin
    LColumn := Self.Columns[i];
    if LColumn.TagString <> Column.TagString then
      LColumn.Tag := 0;
  end;

  // definir o tiulo das colunas
  for I := 0 to Self.ColumnCount - 1 do
  begin
    LColumn := Self.Columns[i];
    LColumnInfo := FColumnsInfo.GetById(LColumn.TagString);

    case LColumn.Tag of
      0: LColumn.Header := LColumnInfo.Header; // sem ordenação
      1: LColumn.Header := LColumnInfo.Header + ' 🔺'; // crescente
      2: LColumn.Header := LColumnInfo.Header + ' 🔻'; // decrecente
    end;

  end;

  LColumnInfo := FColumnsInfo.GetById(Column.TagString);

  Self.BeginUpdate;
  try
    case Column.Tag of
      1: FData.OrderData(LColumnInfo.FieldName, TScoFieldOrder.Asc);
      2: FData.OrderData(LColumnInfo.FieldName, TScoFieldOrder.Desc);
    end;
  finally
    Self.EndUpdate;
  end;

end;

procedure TScoFmxGrid<T>.SetPropertyValue(AObject: T; const APropName: string; const AValue: TValue);
var
  RttiContext: TRttiContext;
  RttiType: TRttiType;
  RttiProp: TRttiProperty;
  Obj: TObject;
begin
  if not Assigned(AObject) then
    Exit;

  // Obtendo o objeto por trás da interface
  Obj := TObject(AObject);

  // Criando o contexto RTTI
  RttiType := RttiContext.GetType(Obj.ClassType);

  // Buscando a propriedade pelo nome
  RttiProp := RttiType.GetProperty(APropName);

  if Assigned(RttiProp) and RttiProp.IsWritable then
  begin
    case RttiProp.PropertyType.TypeKind of
      tkInteger:
        RttiProp.SetValue(Obj, AValue.AsInteger);
      tkFloat:
        if RttiProp.PropertyType.Handle = TypeInfo(Single) then
          RttiProp.SetValue(Obj, AValue.AsType<Single>)
        else
          RttiProp.SetValue(Obj, AValue.AsExtended);
      tkString, tkLString, tkWString, tkUString:
        RttiProp.SetValue(Obj, AValue.AsString);
      tkEnumeration:
        if RttiProp.PropertyType.Handle = TypeInfo(Boolean) then
          RttiProp.SetValue(Obj, AValue.AsBoolean);
    end;
  end
  else
    raise Exception.CreateFmt('Propriedade "%s" não encontrada ou não pode ser escrita.', [APropName]);
end;

procedure TScoFmxGrid<T>.DoOnSetValue(Sender: TObject; const ACol, ARow: Integer; const Value: TValue);
var
  LPerson: T;
  LColumn: TColumn;
  LColumnInfo: TScoColumnInfo;
begin

  if not FData.TryGetValue(ARow, LPerson) then
    Exit;

  LColumn := Self.Columns[ACol];
  LColumnInfo := FColumnsInfo.GetById(LColumn.TagString);
  SetPropertyValue(LPerson, LColumnInfo.FieldName, Value);
  FData.Update(ARow, LPerson);

end;

function TScoFmxGrid<T>.GetDefaultStyleLookupName: string;
begin
  Result := 'gridstyle';
end;

{ TMyGridColumnsInfo }

function TMyGridColumnsInfo<T>.Add(AInfo: TScoColumnInfo): string;
begin
  Result := TGUID.NewGuid.ToString;
  AInfo.Id := Result;
  FColumns.AddOrSetValue(Result, AInfo);
end;

procedure TMyGridColumnsInfo<T>.CreateTextColumn(AInfo: TScoColumnInfo);
var
  LColumn: TStringColumn;
begin
  LColumn := TStringColumn.Create(FOwner);
  LColumn.Header := AInfo.Header;
  LColumn.TagString := AInfo.Id;
  LColumn.Width := AInfo.Width;
  FOwner.AddObject(LColumn);
end;

procedure TMyGridColumnsInfo<T>.CreateCheckColumn(AInfo: TScoColumnInfo);
var
  LColumn: TCheckColumn;
begin
  LColumn := TCheckColumn.Create(FOwner);
  LColumn.Header := AInfo.Header;
  LColumn.TagString := AInfo.Id;
  LColumn.Width := AInfo.Width;
  FOwner.AddObject(LColumn);
end;

procedure TMyGridColumnsInfo<T>.CreateProgressColumn(AInfo: TScoColumnInfo);
var
  LColumn: TProgressColumn;
begin
  LColumn := TProgressColumn.Create(FOwner);
  LColumn.Header := AInfo.Header;
  LColumn.TagString := AInfo.Id;
  LColumn.Width := AInfo.Width;
  FOwner.AddObject(LColumn);
end;

procedure TMyGridColumnsInfo<T>.CreatePopUpColumn(AInfo: TScoColumnInfo);
var
  LColumn: TPopupColumn;
  LArray: TArray<string>;
begin

  LArray := AInfo.PopUpItens.Split(['|']);

  LColumn := TPopupColumn.Create(FOwner);
  LColumn.Header := AInfo.Header;
  LColumn.TagString := AInfo.Id;
  LColumn.Width := AInfo.Width;

  LColumn.Items.Clear;
  LColumn.Items.AddStrings(LArray);

  FOwner.AddObject(LColumn);
end;

procedure TMyGridColumnsInfo<T>.CreateIntegerColumn(AInfo: TScoColumnInfo);
var
  LColumn: TIntegerColumn;
begin
  LColumn := TIntegerColumn.Create(FOwner);
  LColumn.Header := AInfo.Header;
  LColumn.TagString := AInfo.Id;
  LColumn.Width := AInfo.Width;
  FOwner.AddObject(LColumn);
end;

procedure TMyGridColumnsInfo<T>.CreateDateTimeColumn(AInfo: TScoColumnInfo);
var
  LColumn: TDateTimeColumn;
begin
  LColumn := TDateTimeColumn.Create(FOwner);
  LColumn.Header := AInfo.Header;
  LColumn.TagString := AInfo.Id;
  LColumn.Width := AInfo.Width;
  FOwner.AddObject(LColumn);
end;

procedure TMyGridColumnsInfo<T>.CreateCurrencyColumn(AInfo: TScoColumnInfo);
var
  LColumn: TCurrencyColumn;
begin
  LColumn := TCurrencyColumn.Create(FOwner);
  LColumn.Header := AInfo.Header;
  LColumn.TagString := AInfo.Id;
  LColumn.Width := AInfo.Width;
  FOwner.AddObject(LColumn);
end;

procedure TMyGridColumnsInfo<T>.Build;
var
  LInfo: TScoColumnInfo;
  LIsUpdating: Boolean;
  LColumns: TList<TScoColumnInfo>;
begin
  LIsUpdating := FOwner.IsUpdating;

  if not LIsUpdating then
    FOwner.BeginUpdate;
  try
    FOwner.ClearColumns;

    LColumns := TList<TScoColumnInfo>.Create;
    try
      LColumns.AddRange(FColumns.Values);

      LColumns.Sort(
        TComparer<TScoColumnInfo>.Construct(
          function (const Left, Right: TScoColumnInfo): integer
          begin
            Result := 0;
            if Left.Index < Right.Index then
              Result := -1;
            if Left.Index > Right.Index then
              Result := 1;
          end
        )
      );

      for LInfo in LColumns do
        case LInfo.ColumnType of
          Text: CreateTextColumn(LInfo);
          Check: CreateCheckColumn(LInfo);
          Progress: CreateProgressColumn(LInfo);
          PopUp: CreatePopUpColumn(LInfo);
          IntegerNumber: CreateIntegerColumn(LInfo);
          DateTime: CreateDateTimeColumn(LInfo);
          Currency: CreateCurrencyColumn(LInfo);
          Float: raise Exception.Create('Coluna de Ponto Flutuante não implementada!');
          Image: raise Exception.Create('Coluna de Imagem não implementada!');
        end;

    finally
      LColumns.Free;
    end;

  finally
    if not LIsUpdating then
      FOwner.EndUpdate;
  end;
end;

procedure TMyGridColumnsInfo<T>.Clear;
begin
  FColumns.Clear;
end;

constructor TMyGridColumnsInfo<T>.Create(const AOwner: TScoFmxGrid<T>);
begin
  inherited Create;
  FOwner := AOwner;
  FColumns := TDictionary<string, TScoColumnInfo>.Create;
end;

destructor TMyGridColumnsInfo<T>.Destroy;
begin
  FColumns.Free;
  inherited;
end;

function TMyGridColumnsInfo<T>.GetById(const AId: string): TScoColumnInfo;
begin
  FColumns.TryGetValue(AId, Result);
end;

{ TScoColumnInfo }

constructor TScoColumnInfo.Create(AIndex: Integer; AColumnType: TScoColumnType; AHeader, AFieldName: string; AWidth: Integer; APopUpItens: string);
begin
  Self.Index := AIndex;
  Self.ColumnType := AColumnType;
  Self.Header := AHeader;
  Self.FieldName := AFieldName;
  Self.Width := AWidth;
  Self.PopUpItens := APopUpItens;
end;

initialization
  //TPresentationProxyFactory.Current.Register(TScoFmxGrid<T: class>, TControlType.Styled, TStyledPresentationProxy<TStyledGrid>);

finalization
  //TPresentationProxyFactory.Current.Unregister(TScoFmxGrid<T: class>, TControlType.Styled, TStyledPresentationProxy<TStyledGrid>);

end.
