{
 * FmEg3.pas
 *
 * Form unit that implements example 3 for the Version Information Component
 * HelpEgs demo program.
 *
 * $Rev$
 * $Date$
 *
 * Any copyright in this file is dedicated to the Public Domain.
 * http://creativecommons.org/publicdomain/zero/1.0/
}

unit FmEg3;

{$UNDEF Supports_RTLNameSpaces}
{$IFDEF CONDITIONALEXPRESSIONS}
  {$IF CompilerVersion >= 15.0}   // >= Delphi 7
    {$WARN UNSAFE_CODE OFF}
  {$IFEND}
  {$IF CompilerVersion >= 23.0}   // Delphi XE2
    {$DEFINE Supports_RTLNameSpaces}
  {$IFEND}
{$ENDIF}

interface

uses
  // Delphi
  {$IFDEF Supports_RTLNameSpaces}
  Vcl.Forms, System.Classes, Vcl.Controls, Vcl.StdCtrls,
  {$ELSE}
  Forms, Classes, Controls, StdCtrls,
  {$ENDIF}
  // DelphiDabbler component
  PJVersionInfo;


type
  TEgForm3 = class(TForm)
    Memo1: TMemo;
    PJVersionInfo1: TPJVersionInfo;
    Button3: TButton;
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  end;

var
  EgForm3: TEgForm3;

implementation

uses
  // Delphi
  {$IFDEF Supports_RTLNameSpaces}
  System.SysUtils, Winapi.Windows, Winapi.ShellAPI;
  {$ELSE}
  SysUtils, Windows, ShellAPI;
  {$ENDIF}

{$R *.DFM}

type
  TTableEntry = record
    Code: DWORD;
    Desc: string;
  end;

const
  cFileType: array[0..6] of TTableEntry =
  (
    (Code: VFT_APP; Desc: 'Application'),
    (Code: VFT_DLL; Desc: 'DLL'),
    (Code: VFT_DRV; Desc: 'Device driver'),
    (Code: VFT_FONT; Desc: 'Font'),
    (Code: VFT_STATIC_LIB; Desc: 'Static link library'),
    (Code: VFT_VXD; Desc: 'Virtual device driver'),
    (Code: VFT_UNKNOWN; Desc: 'Unknown')
  );

  cFileOSBase: array[0..4] of TTableEntry =
  (
    ( Code: VOS_NT; Desc: 'Windows NT' ),
    ( Code: VOS_DOS; Desc: 'MS-DOS' ),
    ( Code: VOS_OS232; Desc: 'OS2 32 bit' ),
    ( Code: VOS_OS216; Desc: 'OS2 16 bit' ),
    ( Code: VOS_UNKNOWN; Desc: 'Any' )
  );

  cFileOSTarget: array[0..4] of TTableEntry =
  (
    ( Code: VOS__WINDOWS32; Desc: '32 bit Windows' ),
    ( Code: VOS__WINDOWS16; Desc: 'Windows 3.x' ),
    ( Code: VOS__PM32; Desc: 'Presentation Manager 32' ),
    ( Code: VOS__PM16; Desc: 'Presentation Manager 16' ),
    ( Code: VOS__BASE; Desc: 'Unknown' )
  );

function CodeToDesc(Code: DWORD; Table: array of TTableEntry): string;
var
  I: Integer;
begin
  Result := '';
  for I := Low(Table) to High(Table) do
    if Table[I].Code = Code then
    begin
      Result := Table[I].Desc;
      Break;
    end;
end;

function FileOSDesc(const OS: DWORD): string;
  // describe OS
var
  Target, Base: DWORD;
begin
  // get target and base OS
  Target := OS and $0000FFFF;
  Base := OS and $FFFF0000;
  // build description
  if Base = VOS_UNKNOWN then
    Result := CodeToDesc(Target, cFileOSTarget)
  else if Target = VOS__BASE then
    Result := CodeToDesc(Base, cFileOSBase)
  else
    Result := Format('%s on %s',
      [CodeToDesc(Target, cFileOSTarget),
      CodeToDesc(Base, cFileOSBase)]);
end;

function FileFlagsToStr(const Flags: DWORD): string;
  // build string of file flags
const
  cFileFlags: array[0..5] of TTableEntry =
  (
    (Code: VS_FF_DEBUG;        Desc: 'Debug'),
    (Code: VS_FF_PRERELEASE;   Desc: 'Pre-release'),
    (Code: VS_FF_PATCHED;      Desc: 'Patched'),
    (Code: VS_FF_PRIVATEBUILD; Desc: 'Private build'),
    (Code: VS_FF_INFOINFERRED; Desc: 'Inferred'),
    (Code: VS_FF_SPECIALBUILD; Desc: 'Special build')  );
var
  I: Integer;
begin
  Result := '';
  for I := Low(cFileFlags) to High(cFileFlags) do
    if Flags and cFileFlags[I].Code = cFileFlags[I].Code then
      Result := Result + #13#10'   ' + cFileFlags[I].Desc
end;

function VerToStr(Ver: TPJVersionNumber): string;
  // return ver number as string
begin
  Result := Format('%d.%d.%d.%d', [Ver.V1, Ver.V2, Ver.V3, Ver.V4]);
end;

procedure TEgForm3.FormCreate(Sender: TObject);
begin
  // clear memo
  Memo1.Lines.Clear;
  // check if we have version info
  if PJVersionInfo1.HaveInfo then
    // we have version info: display fixed file info
    with Memo1.Lines do
    begin
      Clear;
      Add('File Version:'#13#10'   '
        + VerToStr(PJVersionInfo1.FileVersionNumber));
      Add('Product Version:'#13#10'   '
        + VerToStr(PJVersionInfo1.ProductVersionNumber));
      Add('File Flags Mask: '
        + FileFlagsToStr(PJVersionInfo1.FileFlagsMask));
      Add('File Flags: '
        + FileFlagsToStr(PJVersionInfo1.FileFlags));
      Add('File Type:'#13#10'   '
        + CodeToDesc(PJVersionInfo1.FileType, cFileType));
      Add('File sub type:');
      case PJVersionInfo1.FileType of
        VFT_FONT, VFT_DRV, VFT_VXD:
          Add(Format('   %0.8X', [PJVersionInfo1.FileSubType]));
        else Add('   None');
      end;
      Add('File OS:'#13#10'   '
        + FileOSDesc(PJVersionInfo1.FileOS));
    end
  else
    Memo1.Lines.Add('NO VERSION INFO');
end;

procedure TEgForm3.Button3Click(Sender: TObject);
  // Displays example in help
  // this event handler is not included in help example
const
  cURL = 'http://delphidabbler.com/url/verinfo-eg3';
begin
  ShellExecute(Handle, 'open', cURL, nil, nil, SW_SHOWNORMAL);
end;

end.
