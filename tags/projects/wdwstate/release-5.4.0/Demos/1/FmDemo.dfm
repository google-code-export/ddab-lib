�
 TDEMOFORM 0�	  TPF0	TDemoFormDemoFormLeftTop� Width�HeightcCaption	Main FormColor	clBtnFaceConstraints.MaxWidth�Font.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style OldCreateOrderOnCreate
FormCreatePixelsPerInch`
TextHeight TLabelLabel1LeftxTopWidth� HeightAutoSizeCaptionLabel1WordWrap	  TButton
btnShowDlgLeftTopWidthiHeightCaptionShow DialogTabOrder OnClickbtnShowDlgClick  TPanelPanel1LeftTop(Width�HeightAnchorsakLeftakTopakRightakBottom CaptionPanel1TabOrder 	TSplitter	Splitter1Left	TopWidthHeightCursorcrHSplit  TMemoMemo1LeftTopWidthHeightAlignalLeftFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style Lines.StringstTry moving and resizing this form and then closing it. When restarted it should appear with the same shape and size. hNext try minimizing and maximising the form then closing. When restarted the state should be remembered. �Now click the button to display a fixed size dialog box. Move the dialog and then close it. Click the button again and the dialog should appear in the same place. C  The window settings for the main form and dialog are stored in the registry under the keys: HKCU\Software\DelphiDabbler\Demos\WindowState\Main and HKCU\Software\DelphiDabbler\Demos\WindowState\Dlg respectively. The main form sets this in the OnGetRegData event handler while the dialog sets the SubKey property at run time. qNote that window position and size read from the registry are displayed in both the main form and the dialog box. ParentColor	
ParentFontReadOnly	
ScrollBars
ssVerticalTabOrder WordWrap  TMemoMemo2LeftTopWidth� HeightAlignalClientFont.CharsetDEFAULT_CHARSET
Font.ColorclWindowTextFont.Height�	Font.NameMS Sans Serif
Font.Style Lines.Strings}Drag the splitter to the left of this control to change the size of the memo controls then close and re-open the application. �You should find that the splitter remembers its position. This is done by handling the OnGettingRegData and OnPuttingRegData events ParentColor	
ParentFontReadOnly	
ScrollBars
ssVerticalTabOrderWordWrap   TPJRegWdwStatePJRegWdwState1AutoSaveRestore	OnReadWdwStatePJRegWdwState1ReadWdwStateOnGetRegDataPJRegWdwState1GetRegDataOnGettingRegDataPJRegWdwState1GettingRegDataOnPuttingRegDataPJRegWdwState1PuttingRegDataLeftTopD   