program GridDemo;

uses
  System.StartUpCopy,
  FMX.Forms,
  Person.View in 'Person.View.pas' {Form1},
  Person.Dto in 'Person.Dto.pas',
  Sco.Fmx.Grid in '..\Sco.Fmx.Grid.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
