{
  DelphiDabbler Console Application Runner Classes

  Demo Program 9: Subclassing TPJConsoleApp.

  Demo9.dpr
    v1.0 of 03 Oct 2007  - Project file. Original version.

  Written by Peter Johnson (www.delphidabbler.com).
  This demo program and its source code is placed in the public domain with no
  restrictions as to use.

  THE PROGRAM IS PROVIDED "AS-IS", WITHOUT ANY EXPRESS OR IMPLIED WARRANTY. IN
  NO EVENT SHALL THE AUTHOR BE HELD LIABLE FOR ANY DAMAGES ARISING FROM THE USE
  OF THIS LIBRARY.
}

program Demo9;

uses
  Forms,
  FmDemo9 in 'FmDemo9.pas' {Form1},
  PJPipe in '..\..\PJPipe.pas',
  PJConsoleApp in '..\..\PJConsoleApp.pas',
  UConsoleAppEx in 'UConsoleAppEx.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.

