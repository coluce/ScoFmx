unit Person.Dto;

interface

type

  TPersonDto = class
  private
    FActive: Boolean;
    FAge: Integer;
    FKind: String;
    FName: string;
    FProgress: Single;
    FDate: TDateTime;
    FValue: Currency;
  public
    property Name: string read FName write FName;
    property Active: Boolean read FActive write FActive;
    property Progress: Single read FProgress write FProgress;
    property Kind: String read FKind write FKind;
    property Age: Integer read FAge write FAge;
    property Date: TDateTime read FDate write FDate;
    property Value: Currency read FValue write FValue;
  end;

implementation

end.
