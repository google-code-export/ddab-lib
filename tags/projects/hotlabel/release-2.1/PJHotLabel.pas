{
 * Hot Label Component
 *
 * PJHotLabel.pas
 *
 * Source of the TPJHotLabel component. TPJHotLabel is a label that when clicked
 * opens a URL in the default web browser or email client.
 *
 * v1.0 of 24 Oct 1999  - Original version. Named HotLabel.pas
 * v2.0 of 02 Nov 2004  - Added separate URL property to enable caption to be
 *                        different to URL accessed.
 *                      - Added ability to highlight label text when cursor
 *                        passes over it.
 *                      - Added ability to display URL in hint or to display
 *                        custom hints set by handling the new OnCustomHint
 *                        event.
 *                      - Now uses built in hand point cursor for Delphi 4 and
 *                        higher while still loading custom cursor from
 *                        resources for earlier compilers. Value of custom
 *                        cursor constant changed from $0A to $630B.
 *                      - Moved error messages to resource strings for Delphi 3
 *                        and later while using constants for Delphi 2.
 *                      - Added support for https:// protocol.
 *                      - Changed default URL to http://localhost/
 *                      - Renamed unit as PJHotLabel.pas
 * v2.1 of 17/03/2007   - Fixed bug where label's colour could be displayed
 *                        wrongly at design if mouse had been moved over the
 *                        label and highlighting was enabled. Fixed by ignoring
 *                        mouse over events at design time.
 *                      - Made some minor refactorings.
 *                      - Changed name of cursor read from resources in Delphi 2
 *                        and Delphi 3.
 *                      - Changed to Mozilla Public License.
 *
 *
 * ***** BEGIN LICENSE BLOCK *****
 *
 * Version: MPL 1.1
 *
 * The contents of this file are subject to the Mozilla Public License Version
 * 1.1 (the "License"); you may not use this file except in compliance with the
 * License. You may obtain a copy of the License at http://www.mozilla.org/MPL/
 *
 * Software distributed under the License is distributed on an "AS IS" basis,
 * WITHOUT WARRANTY OF ANY KIND, either express or implied. See the License for
 * the specific language governing rights and limitations under the License.
 *
 * The Original Code is PJHotLabel.pas.
 *
 * The Initial Developer of the Original Code is Peter Johnson
 * (http://www.delphidabbler.com/).
 *
 * Portions created by the Initial Developer are Copyright (C) 1999-2007 Peter
 * Johnson. All Rights Reserved.
 *
 * ***** END LICENSE BLOCK *****
}


unit PJHotLabel;


interface


// Determine conditional symbols based on compiler
{$IFDEF VER90}    // --- Delphi 2
  {$DEFINE NO_RES_STRINGS}
  {$DEFINE NO_HAND_CURSOR}
{$ENDIF}
{$IFDEF VER100}   // --- Delphi 3
  {$DEFINE NO_HAND_CURSOR}
{$ENDIF}


uses
  // Delphi
  SysUtils, Classes, Graphics, Messages, Controls, StdCtrls;


const
  // We make sure the crHandPoint cursor is defined. It is not defined for all
  // versions of Delphi.
  {$IFDEF NO_HAND_CURSOR}
  crHandPoint = TCursor($630B);   (* changed: cast to TCursor *)
  {$ENDIF}
  // For reasons of backward compatibility we also define crHand as an alias
  // for crHandPoint.
  crHand = crHandPoint;


type

  {
  EPJURLError:
    Exception triggered by TPJHotLabel when URL problems encountered.
  }
  EPJURLError = class(Exception);


  {
  TPJHLHintStyle:
    The various hint styles used by TPJHotLabel.
  }
  TPJHLHintStyle = (
    hsNormal,   // display normal hints per Hint property
    hsURL,      // display URL property in hint and ignore Hint property
    hsCustom    // display a custom hint by handling OnCustomHint event
                // (hsCustom is same hsNormal if OnCustomHint not handled)
  );


  {
  TPJHLCustomHintEvent:
    Type of event triggered just before hint is displayed when HintStyle
    property is set to hsCustom. Handler can change the default.
      @param Sender [in] Reference to component that triggered event.
      @param HintStr [in/out] Set to value of component's Hint property when
        called. Handler sets to desired hint string.
  }
  TPJHLCustomHintEvent = procedure(Sender: TObject; var HintStr: string)
    of object;


  {
  TPJHotLabel:
    Label component that opens a URL in the default web browser or email client
    when clicked.
  }
  TPJHotLabel = class(TLabel)
  private
    fBackupFont: TFont;
      {Font used to store original value of Font property while inherited Font
      is being used to display highlight font}
    fBackupFontUsed: Boolean;
      {Flag set true when backup font is storing font property}
    fValidateURL: Boolean;
      {Value of ValidateURL property}
    fURL: string;
      {Value of URL property}
    fCaptionIsURL: Boolean;
      {Value of CaptionIsURL property}
    fHighlightFont: TFont;
      {Value of HighlightFont property}
    fHighlightURL: Boolean;
      {Value of HighlightURL property}
    fHintStyle: TPJHLHintStyle;
      {Value of HintStyle property}
    fOnCustomHint: TPJHLCustomHintEvent;
      {Reference to any OnCustomHint event handler}
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
      {Handles mouse enter event. Highlights label text if required.
        @param Msg [in/out] Not used.
      }
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
      {Handles mouse leave event. Un-highlight label text if it was highlighted.
        @param Msg [in/out] Not used.
      }
    procedure CMHintShow(var Msg: TMessage); message CM_HINTSHOW;
      {Message handler that intercepts hints before they are displayed and sets
      hint as required by the HintStyle property. Triggers OnCustomHint event
      when HintStyle = hsCustom.
        @param Msg [in/out] Message parameters. Hint info structure pointed to by
          LParam parameter may be changed.
      }
    procedure SetValidateURL(const Value: Boolean);
      {Write access method for ValidateURL property.
        @param Value [in] New property value. If EPJURLError raised, URL is set
          to default URL.
        @except EPJURLError raised if URL does not have a supported protocol and
          Value is true.
      }
    procedure SetURL(const Value: string);
      {Write access method for URL property. Sets Caption property to same value
      if CaptionIsURL property is true.
        @param Value [in] New property value.
        @except EPJURLError raised if URL is not valid and ValidateURL is true.
      }
    procedure SetCaptionIsURL(const Value: Boolean);
      {Write access method for CaptionIsURL property. When set true we set
      Caption property to same value as URL property.
        @param Value [in] New property value.
      }
    procedure SetHighlightFont(const Value: TFont);
      {Write access method for HighlightFont property.
        @param Value [in] New property value.
      }
  protected
    procedure SetDefaultURL; virtual;
      {Sets the URL to the default value. Override this method in descendant
      classes to change this default.
      }
    procedure CheckURL(const URL: string); virtual;
      {Checks that a URL has one of the supported protocols. Override this
      method to add additional protocols in a descendant component.
        @param URL [in] URL to be checked.
        @except EPJURLError raised if URL does not have a supported protocol.
      }
    procedure Click; override;
      {Starts default browser or e-mail client using URL property when label
      clicked, providing URL is not empty and label is enabled.
        @except EPJURLError raised if Windows can't access URL.
      }
    procedure Loaded; override;
      {Ensures Caption matches URL property if CaptionIsURL property is true
      when component is loaded from resources.
      }
    procedure SetCaption(const Value: TCaption); virtual;
      {"Overridden" write access method for Caption property. Also sets URL
      property to same value when CaptionIsURL property is true.
        @param Value [in] New property value.
        @except EPJURLError raised if CaptionIsURL and ValidateURL are true and
          Value is not a valid URL.
      }
    function GetCaption: TCaption; virtual;
      {"Overridden" read access method for Caption property.
        @return Value of inherited Caption property.
      }
    function GetFont: TFont; virtual;
      {"Overridden" read access method for Font property.
        @return Value of Font property.
      }
    procedure SetFont(const Value: TFont); virtual;
      {"Overridden" write access method for Font property.
        @param Value [in] New property value.
      }
  public
    constructor Create(AOwner: TComponent); override;
      {Class constructor. Initialises object and sets default property values.
        @param AOwner [in] Reference to owning component or nil if no owner.
      }
    destructor Destroy; override;
      {Class destructor. Tears down object.
      }
  published
    // New properties
    property CaptionIsURL: Boolean
      read fCaptionIsURL write SetCaptionIsURL default True;
      {Determines if the Caption displays the URL per the URL property. When
      true the Caption displays the URL and setting either property updates the
      other. When false the Caption and URL are idependent of each other}
    property HighlightFont: TFont read fHighlightFont write SetHighlightFont;
      {Font displayed by label when the mouse cursor is over the component.
      Ignored when HighlightURL is false}
    property HighlightURL: Boolean
      read fHighlightURL write fHighlightURL default False;
      {Determines whether the label is highlighted using HighlightFont when the
      mouse cursor is over it}
    property HintStyle: TPJHLHintStyle
      read fHintStyle write fHintStyle default hsNormal;
      {Determines how the component's hint is displayed. See TPJHLHintStyle for
      details of possible values and their effects}
    property URL: string
      read fURL write SetURL;
      {URL to be accessed when the label is clicked. This value is validated if
      ValidateURL is true. Setting this property also sets Caption when
      CaptionIsURL is true}
    property ValidateURL: Boolean
      read fValidateURL write SetValidateURL default True;
      {Causes URL property to be validated when true. Invalid URLs causes an
      exception to be raised. Setting this property true when URL is invalid
      raises an exception and restores the default URL}
    property OnCustomHint: TPJHLCustomHintEvent
      read fOnCustomHint write fOnCustomHint;
      {Event triggered just before the component's hint is displayed when the
      HintStyle property is hsCustom. Handlers can modified the displayed hint}
    // Overridden inherited properties
    property Caption: TCaption read GetCaption write SetCaption;
      {Label's caption. When CaptionIsURL is true, the property has the same
      value and behaviour as the URL property}
    property Cursor default crHandPoint;
      {Cursor property is now a hand pointer by default}
    property Font: TFont
      read GetFont write SetFont;
      {Font used by label when not in highlighted state}
    property ParentFont default False;
      {ParentFont property is set false since the default caption font style is
      different to the parent font}
  end;


procedure Register;
  {Registers component.
  }


implementation


uses
  // Delphi
  Windows, ShellAPI, Forms;


// Only link this resource for Delphi version with no built in hand point cursor
{$IFDEF NO_HAND_CURSOR}
{$R PJHotLabel.res}
{$ENDIF}


const
  // URL used as default caption property by SetDefaultURL method
  cDefaultURL = 'http://localhost/';


// Message strings. Uses resource strings where supported, and const if not
{$IFDEF NO_RES_STRINGS}
const
{$ELSE}
resourcestring
{$ENDIF}
  sCantAccessURL = 'Can''t access URL "%s"';
  sBadProtocol = 'Protocol not recognised for URL "%s"';


procedure Register;
  {Registers component.
  }
begin
  RegisterComponents('DelphiDabbler', [TPJHotLabel]);
end;


{ TPJHotLabel }

procedure TPJHotLabel.CheckURL(const URL: string);
  {Checks that a URL has one of the supported protocols. Override this method to
  add additional protocols in a descendant component.
    @param URL [in] URL to be checked.
    @except EPJURLError raised if URL does not have a supported protocol.
  }
const
  // List of recognised URLs
  cValidURLS: array[1..5] of string
    = ('http://', 'https://', 'mailto', 'file:', 'ftp://');
var
  I: Integer; // loops thru all recognised URLs
begin
  // Allow '': we don't ever try to jump to empty URL!
  if URL = '' then Exit;
  // Check caption against array of valid protocols: exit if we recognise one
  for I := Low(cValidURLS) to High(cValidURLS) do
    if CompareText(cValidURLS[I],Copy(URL, 1, Length(cValidURLS[I]))) = 0 then
      Exit;
  // If we get here, we haven't recognised the protocol so raise exception
  raise EPJURLError.CreateFmt(sBadProtocol, [URL]);
end;

procedure TPJHotLabel.Click;
  {Starts default browser or e-mail client using URL property when label
  clicked, providing URL is not empty and label is enabled.
    @except EPJURLError raised if Windows can't access URL.
  }
begin
  if Enabled and (fURL <> '')then
  begin
    if ShellExecute(ValidParentForm(Self).Handle, nil, PChar(fURL), nil,
      nil, SW_SHOW) < 32 then
      raise EPJURLError.CreateFmt(sCantAccessURL, [fURL]);
  end;
  // Make sure inherited processing happens
  inherited Click;
end;

procedure TPJHotLabel.CMHintShow(var Msg: TMessage);
  {Message handler that intercepts hints before they are displayed and sets hint
  as required by the HintStyle property. Triggers OnCustomHint event when
  HintStyle = hsCustom.
    @param Msg [in/out] Message parameters. Hint info structure pointed to by
      LParam parameter may be changed.
  }
var
  HintStr: string;  // the hint to be displayed when custom hints being used
begin
  // Displayed hint depends on HintStyle property
  case fHintStyle of
    hsNormal:
      // Hint property displays as normal
      {Do nothing};
    hsURL:
      // Display URL in hint
      PHintInfo(Msg.LParam)^.HintStr := fURL;
    hsCustom:
    begin
      // Custom hint. User sets hint text in event handler. If event not handled
      // then hint is as specified by Hint property
      HintStr := Hint;
      if Assigned(fOnCustomHint) then
        fOnCustomHint(Self, HintStr);
      PHintInfo(Msg.LParam)^.HintStr := HintStr;
    end;
  end;
  inherited;
end;

procedure TPJHotLabel.CMMouseEnter(var Msg: TMessage);
  {Handles mouse enter event. Highlights label text if required.
    @param Msg [in/out] Not used.
  }
begin
  inherited;
  if HighlightURL and not (csDesigning in ComponentState) then
  begin
    // Highlight the label by using the highlight font, saving original Font
    fBackupFont.Assign(Font);
    fBackupFontUsed := True;
    inherited Font.Assign(HighlightFont);
  end;
end;

procedure TPJHotLabel.CMMouseLeave(var Msg: TMessage);
  {Handles mouse leave event. Un-highlight label text if it was highlighted.
    @param Msg [in/out] Not used.
  }
begin
  inherited;
  if HighlightURL and not (csDesigning in ComponentState) then
  begin
    // Un-highlight the label by restoring saved Font property
    inherited Font.Assign(fBackupFont);
    fBackupFontUsed := False;
  end;
end;

constructor TPJHotLabel.Create(AOwner: TComponent);
  {Class constructor. Initialises object and sets default property values.
    @param AOwner [in] Reference to owning component or nil if no owner.
  }
begin
  inherited Create(AOwner);

  // Ensure crHandPoint cursor is available and use it as default
  {$IFDEF NO_HAND_CURSOR}
  Screen.Cursors[crHandPoint] := LoadCursor(HInstance, 'PJHOTLABEL_HANDPOINT');
  {$ENDIF}
  Cursor := crHandPoint;

  // Create backup and highlight fonts
  fBackupFont := TFont.Create;
  fHighlightFont := TFont.Create;

  // Set default values
  // NOTE: various defaults have been chosen to make default behaviour of
  // component emulate earlier versions
  Font.Color := clNavy; // sets ParentFont to False
  Font.Style := [fsUnderline];
  HighlightFont := Font;
  HighlightFont.Color := clRed;
  SetValidateURL(True);
  fCaptionIsURL := True;
  SetDefaultURL;  // sets URL and Caption properties to default URL
  fHighlightURL := False;
  fHintStyle := hsNormal;
  inherited Caption := fURL;
end;

destructor TPJHotLabel.Destroy;
  {Class destructor. Tears down object.
  }
begin
  fHighlightFont.Free;
  fBackupFont.Free;
  inherited;
end;

function TPJHotLabel.GetCaption: TCaption;
  {"Overridden" read access method for Caption property.
    @return Value of inherited Caption property.
  }
begin
  Result := inherited Caption;
end;

function TPJHotLabel.GetFont: TFont;
  {"Overridden" read access method for Font property.
    @return Value of Font property.
  }
begin
  // When label is highlighted inherited Font property contains highlight font
  // and true value of Font property is stored in backup font object
  if fBackupFontUsed then
    Result := fBackupFont
  else
    Result := inherited Font;
end;

procedure TPJHotLabel.Loaded;
  {Ensures Caption matches URL property if CaptionIsURL property is true when
  component is loaded from resources.
  }
begin
  inherited;
  if fCaptionIsURL then
    SetCaption(fURL);
end;

procedure TPJHotLabel.SetCaption(const Value: TCaption);
  {"Overridden" write access method for Caption property. Also sets URL property
  to same value when CaptionIsURL property is true.
    @param Value [in] New property value.
    @except EPJURLError raised if CaptionIsURL and ValidateURL are true and
      Value is not a valid URL.
  }
begin
  if fCaptionIsURL then
  begin
    // Caption is a URL
    if fValidateURL and not (csLoading in ComponentState) then
      CheckURL(Value);  // raises exception on bad URL
    fURL := Value;
  end;
  // Now update actual caption
  inherited Caption := Value;
end;

procedure TPJHotLabel.SetCaptionIsURL(const Value: Boolean);
  {Write access method for CaptionIsURL property. When set true we set Caption
  property to same value as URL property.
    @param Value [in] New property value.
  }
begin
  fCaptionIsURL := Value;
  if Value then
    SetCaption(fURL);
end;

procedure TPJHotLabel.SetDefaultURL;
  {Sets the URL to the default value. Override this method in descendant classes
  to change this default.
  }
begin
  try
    // Try to set URL to default
    SetURL(cDefaultURL)
  except on EPJURLError do
    // Catch exception thrown if default URL not valid
    // we also set URL to '': aren't we being cautious!
    SetURL('');
  end;
end;

procedure TPJHotLabel.SetFont(const Value: TFont);
  {"Overridden" write access method for Font property.
    @param Value [in] New property value.
  }
begin
  // When label is highlighted inherited Font property contains highlight font
  // so the new value of the Font property is stored in backup font object
  if fBackupFontUsed then
    fBackupFont.Assign(Value)
  else
    inherited Font := Value;
end;

procedure TPJHotLabel.SetHighlightFont(const Value: TFont);
  {Write access method for HighlightFont property.
    @param Value [in] New property value.
  }
begin
  fHighlightFont.Assign(Value);
end;

procedure TPJHotLabel.SetURL(const Value: string);
  {Write access method for URL property. Sets Caption property to same value if
  CaptionIsURL property is true.
    @param Value [in] New property value.
    @except EPJURLError raised if URL is not valid and ValidateURL is true.
  }
begin
  // We only validate URL and set Caption if component isn't loading
  if not (csLoading in ComponentState) then
  begin
    if fValidateURL then
      CheckURL(Value);
    if fCaptionIsURL then
      Caption := Value;
  end;
  fURL := Value;
end;

procedure TPJHotLabel.SetValidateURL(const Value: Boolean);
  {Write access method for ValidateURL property.
    @param Value [in] New property value. If EPJURLError raised, URL is set to
      default URL.
    @except EPJURLError raised if URL does not have a supported protocol and
      Value is true.
  }
begin
  // Record new value
  fValidateURL := Value;
  if fValidateURL then
    try
      CheckURL(fURL);
    except
      on E: EPJURLError do
      begin
        // Not a valid URL - replace it with default and re-raise
        // exception so user gets to know about error
        SetDefaultURL;
        raise;
      end;
    end;
end;

end.
