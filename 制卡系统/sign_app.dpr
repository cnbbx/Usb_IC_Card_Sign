program sign_app;

uses
  Forms,
  signmain in 'signmain.pas' {Form1};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := '艾美e族实体会员卡制卡系统';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
