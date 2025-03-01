unit Person.Dto;

interface

type

  IPersonDto = interface
    ['{475793BD-59AE-4D4D-9C7B-7053B23F101D}']

    function GetActive: Boolean;
    function GetAge: Integer;
    function GetKind: String;
    function GetName: string;
    function GetProgress: Single;
    procedure SetActive(const Value: Boolean);
    procedure SetAge(const Value: Integer);
    procedure SetKind(const Value: String);
    procedure SetName(const Value: string);
    procedure SetProgress(const Value: Single);

    property Name: string read GetName write SetName;
    property Active: Boolean read GetActive write SetActive;
    property Progress: Single read GetProgress write SetProgress;
    property Kind: String read GetKind write SetKind;
    property Age: Integer read GetAge write SetAge;
  end;

  TPersonDto = class(TInterfacedObject, IPersonDto)
  private

    FActive: Boolean;
    FAge: Integer;
    FKind: String;
    FName: string;
    FProgress: Single;

    function GetActive: Boolean;
    function GetAge: Integer;
    function GetKind: String;
    function GetName: string;
    function GetProgress: Single;
    procedure SetActive(const Value: Boolean);
    procedure SetAge(const Value: Integer);
    procedure SetKind(const Value: String);
    procedure SetName(const Value: string);
    procedure SetProgress(const Value: Single);
  public
    class function New: IPersonDto;

    property Name: string read GetName write SetName;
    property Active: Boolean read GetActive write SetActive;
    property Progress: Single read GetProgress write SetProgress;
    property Kind: String read GetKind write SetKind;
    property Age: Integer read GetAge write SetAge;
  end;

implementation

{ TPerson }

class function TPersonDto.New: IPersonDto;
begin
  Result := Self.Create;
end;

function TPersonDto.GetActive: Boolean;
begin
  Result := FActive;
end;

function TPersonDto.GetAge: Integer;
begin
  Result := FAge;
end;

function TPersonDto.GetKind: String;
begin
  Result := FKind;
end;

function TPersonDto.GetName: string;
begin
  Result := FName;
end;

function TPersonDto.GetProgress: Single;
begin
  Result := FProgress;
end;

procedure TPersonDto.SetActive(const Value: Boolean);
begin
  FActive := Value;
end;

procedure TPersonDto.SetAge(const Value: Integer);
begin
  FAge := Value;
end;

procedure TPersonDto.SetKind(const Value: String);
begin
  FKind := Value;
end;

procedure TPersonDto.SetName(const Value: string);
begin
  FName := Value;
end;

procedure TPersonDto.SetProgress(const Value: Single);
begin
  FProgress := Value;
end;

end.
