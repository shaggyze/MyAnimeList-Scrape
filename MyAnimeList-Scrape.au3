;MyAnimeList-Scrape by ShaggyZE
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=mal.ico
#AutoIt3Wrapper_Compression=0
#AutoIt3Wrapper_Res_Comment=MyAnimeList-Scrape
#AutoIt3Wrapper_Res_Description=MyAnimeList-Scrape
#AutoIt3Wrapper_Res_Fileversion=0.0.0.21
#AutoIt3Wrapper_Res_LegalCopyright=ShaggyZE
#AutoIt3Wrapper_Res_requestedExecutionLevel=requireAdministrator
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#region Includes
#include-once
#include <Inet.au3>
#include <Array.au3>
#include <String.au3>
#include <MsgBoxConstants.au3>
#include <GuiButton.au3>
#include <EditConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiComboBoxEx.au3>
#include <WindowsConstants.au3>
#include <GDIPlus.au3>
#include <IE.au3>
#include <Math.au3>
#include <GUIListView.au3>
#include <WinAPI.au3>
#include <File.au3>
#include <Misc.au3>
#include <vkConstants.au3>
#include <GUIScrollBars_Ex.au3>
#include <GuiScrollBars.au3>
#include <GuiScroll.au3>
#include <GUICtrl_SetResizing.au3>
#include <StaticConstants.au3>
#include <ProgressConstants.au3>
#include <ColorConstants.au3>
#include <GUIMenu.au3>
#include <GuiEdit.au3>
#endregion Includes
Global $szText, $szText, $szURL, $source, $sValue1, $sValue2, $szDelay, $Username, $Template, $Method, $anime_id, $anime_ids, $manga_id, $manga_ids, $id, $data, $read, $read2, $readtags[0], $parseStr, $parseStr2, $o, $mode, $sURL_Status, $latest_anime_id, $latest_manga_id, $image, $title, $titleeng, $titleraw
Global $oIE = _IECreateEmbedded()
Global $version = "0.0.0.21"
Local $hGUI = GUICreate("MyAnimeList-Scrape v" & $version & "                                                        To Pause or Close Click the MAL Icon in your System Tray at the Bottom Right", 900, 470, -1, -1, -1)
Local $hSysMenu = _GUICtrlMenu_GetSystemMenu($hGUI)
_GUICtrlMenu_DeleteMenu($hSysMenu, $SC_CLOSE, False)
_GUICtrlMenu_DeleteMenu($hSysMenu, $SC_MAXIMIZE, False)
GUISetIcon(@ScriptDir & "\mal.ico")
$REGKEY="HKEY_CURRENT_USER\Software\ShaggyZE\MyAnimeList-Scrape\"
$Username=REGREAD($REGKEY,"Username")
$Template=REGREAD($REGKEY,"Template")
;GUI Frontend
$ButtonS = GUICtrlCreateButton("Start", 5, 5, 65, 20)
GUICtrlSetTip(-1, "Click to Start/Stop")
$UsernameINP = GUICtrlCreateInput($Username, 80, 5, 100, 20)
GUICtrlSetState (-1,$GUI_Disable)
GUICtrlSetTip(-1, "Your Mal Username")
GUICtrlCreateLabel("Output", 225, 10, 65, 20)
GUICtrlSetTip(-1, "This is where your CSS code will be")
$Progress = GUICtrlCreateLabel("", 60, 40, 100, 20, $SS_CENTER, $WS_EX_TOPMOST)
GUICtrlSetTip(-1, "")
GUICtrlCreateLabel("Delay", 5, 60, 65, 20)
GUICtrlSetTip(-1, "Milliseconds between Scraping MyAnimeList.net")
$DelayINP = GUICtrlCreateInput("3000", 5, 80, 40, 20)
GUICtrlSetTip(-1, "Milliseconds between Scraping MyAnimeList.net")
$OutputCHK = GUICtrlCreateCheckbox("Halt Output UI", 80, 80, 100, 20)
GUICtrlSetTip(-1, "Output only to mal.css")
GUICtrlCreateLabel("Template", 5, 110, 65, 20)
GUICtrlSetTip(-1, "CSS Template")
$TemplateINP = GUICtrlCreateInput($Template, 5, 130, 220, 20)
GUICtrlSetTip(-1, "CSS Template")
GUICtrlCreateLabel("Method", 5, 160, 65, 20)
GUICtrlSetTip(-1, "Method of scraping Data for CSS")
$MethodCMB = GUICtrlCreateCombo("MAL-Anime", 5, 180, 150, 20, BitOR($CBS_DROPDOWNLIST, $CBS_AUTOHSCROLL, $WS_VSCROLL))
GUICtrlSetData(-1, "MAL-Manga|User-Anime|User-Manga")
GUICtrlSetTip(-1, "Method of scraping Data for CSS")
GUICtrlCreateLabel("Start and Finish", 5, 210, 100, 20)
GUICtrlSetTip(-1, "ID# from Start to Finsh")
$FromINP = GUICtrlCreateInput("1", 5, 230, 40, 20)
GUICtrlSetTip(-1, "Start ID#")
$ToINP = GUICtrlCreateInput("", 45, 230, 40, 20)
GUICtrlSetTip(-1, "Finish ID#")
$OutputINP = GUICtrlCreateEdit("Newly generated code will be output here.", 225, 25, 675, 445, $ES_MULTILINE)
GUICtrlSetStyle($OutputINP, $WS_VSCROLL)
;_GUICtrlEdit_SetReadOnly(ControlGetHandle($hGUI,"",$OutputINP),True)
GUICtrlSetTip(-1, "Newly generated code will be output here")
$AntiSpamCHK = GUICtrlCreateCheckbox("Show Anti-Spam", 5, 260, 95, 20)
GUICtrlSetTip(-1, "Anti-Spam")
$GUIActiveX = GUICtrlCreateObj($oIE, 12.5, 280, 200, 180)
GUICtrlSetState($GUIActiveX, $GUI_HIDE)
$szFile1 = "scrape.txt"
$szFile2 = "mal.txt"
$szFile3 = "scrape.html"
$szFile4 = "jikan.html"
$szFile5 = "jikan.txt"
$x = @DesktopWidth - 200
$y = @DesktopHeight - 62.5
GUISetState(@SW_SHOW, $hGUI)

_GetLastestID("anime")

GUIRegisterMsg($WM_COMMAND, "_MY_WM_COMMAND")

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		;Start
		Case $ButtonS
			If GUICtrlRead($ButtonS) = "Start" Then
            GUICtrlSetData($ButtonS, "Stop (close)")
			$Method = GUICtrlRead($MethodCMB)
			$Username = GUICtrlRead($UsernameINP)
			$Template = GUICtrlRead($TemplateINP)
			If $Username = "" Then
				$Username = "ShaggyZE"
				GUICtrlSetData($UsernameINP, $Username)
				REGWRITE($REGKEY,"Username","REG_SZ",GUICtrlRead($UsernameINP))
			EndIf
			If $Template = "" Then
				$Template = "#tags-[ID]:after {font-family: Finger Paint; content: '[DESC]';}"
				GUICtrlSetData($TemplateINP, $Template)
				REGWRITE($REGKEY,"Template","REG_SZ",GUICtrlRead($TemplateINP))
			EndIf
			If $Method = "MAL-Anime" Then
				$sValue1 = GUICtrlRead($FromINP)
				$sValue2 = GUICtrlRead($ToINP)
				If $sValue1 = "" Then $sValue1 = "1" And GUICtrlSetData($FromINP, 1)
				If $sValue2 = "" Then _GetLastestID("anime")
				FileDelete($szFile2)
				$Template = GUICtrlRead($TemplateINP)
				$szText = '/* Generated by MyAnimeList-Scrape https://github.com/shaggyze/MyAnimeList-Scrape' & @CRLF & 'Template=' & $Template & ' */'
				FileWrite($szFile2, $szText)
				ToolTip("Scraping MAL data...", $x, $y)
				Sleep(GUICtrlRead($DelayINP))
				_ScrapeMAL("anime")
				FileDelete($szFile1)
				FileDelete($szFile3)
			ElseIf $Method = "MAL-Manga" Then
				$sValue1 = GUICtrlRead($FromINP)
				$sValue2 = GUICtrlRead($ToINP)
				If $sValue1 = "" Then $sValue1 = "1" And GUICtrlSetData($FromINP, 1)
				If $sValue2 = "" Then _GetLastestID("manga")
				FileDelete($szFile2)
				$Template = GUICtrlRead($TemplateINP)
				$szText = '/* Generated by MyAnimeList-Scrape https://github.com/shaggyze/MyAnimeList-Scrape' & @CRLF & 'Template=' & $Template & ' */'
				FileWrite($szFile2, $szText)
				ToolTip("Scraping MAL data...", $x, $y)
				Sleep(GUICtrlRead($DelayINP))
				_ScrapeMAL("manga")
				FileDelete($szFile1)
				FileDelete($szFile3)
			ElseIf $Method = "User-Anime" Then
				$data = ""
				$o = 0
				FileDelete($szFile2)
				$Template = GUICtrlRead($TemplateINP)
				$szText = '/* Generated by MyAnimeList-Scrape https://github.com/shaggyze/MyAnimeList-Scrape' & @CRLF & 'Template=' & $Template & ' */'
				FileWrite($szFile2, $szText)
				GUICtrlSetData($OutputINP, "Gathering IDs...This may take awhile depending on the size of the list.")
				ToolTip("Gathering IDs...", $x, $y)
				_GetloadjsonAnimeMAL()
				ToolTip("", $x, $y)
				$mode = ""
				FileDelete($szFile1)
				FileDelete($szFile3)
			ElseIf $Method = "User-Manga" Then
				$data = ""
				$o = 0
				FileDelete($szFile2)
				$Template = GUICtrlRead($TemplateINP)
				$szText = '/* Generated by MyAnimeList-Scrape https://github.com/shaggyze/MyAnimeList-Scrape' & @CRLF & 'Template=' & $Template & ' */'
				FileWrite($szFile2, $szText)
				GUICtrlSetData($OutputINP, "Gathering IDs...This may take awhile depending on the size of the list.")
				ToolTip("Gathering IDs...", $x, $y)
				_GetloadjsonMangaMAL()
				ToolTip("", $x, $y)
				$mode = ""
				FileDelete($szFile1)
				FileDelete($szFile3)
			EndIf
			EndIf
		Case $MethodCMB
			$Method = GUICtrlRead($MethodCMB)
			If $Method = "MAL-Anime" Then
				_GetLastestID("anime")
				GUICtrlSetState ($UsernameINP,$GUI_Disable)
				GUICtrlSetState ($FromINP,$GUI_Enable)
				GUICtrlSetState ($ToINP,$GUI_Enable)
			ElseIf $Method = "MAL-Manga" Then
				_GetLastestID("manga")
				GUICtrlSetState ($UsernameINP,$GUI_Disable)
				GUICtrlSetState ($FromINP,$GUI_Enable)
				GUICtrlSetState ($ToINP,$GUI_Enable)
			ElseIf $Method = "User-Anime" Then
				GUICtrlSetState ($UsernameINP,$GUI_Enable)
				GUICtrlSetState ($FromINP,$GUI_Disable)
				GUICtrlSetState ($ToINP,$GUI_Disable)
			ElseIf $Method = "User-Manga" Then
				GUICtrlSetState ($UsernameINP,$GUI_Enable)
				GUICtrlSetState ($FromINP,$GUI_Disable)
				GUICtrlSetState ($ToINP,$GUI_Disable)
			EndIf
		Case $AntiSpamCHK
			If GUICtrlRead($AntiSpamCHK) = 1 Then
				GUICtrlSetState($GUIActiveX, $GUI_SHOW)
			Else
				GUICtrlSetState($GUIActiveX, $GUI_HIDE)
			EndIf
		Case Else
			REGWRITE($REGKEY,"Username","REG_SZ",GUICtrlRead($UsernameINP))
			REGWRITE($REGKEY,"Template","REG_SZ",GUICtrlRead($TemplateINP))
			;MsgBox(0,"",$nMsg)
	EndSwitch
WEnd

Func _GetLastestID($list)
If $list = "anime" Then
	$szURL = "https://myanimelist.net/anime.php?o=9&c%5B0%5D=a&c%5B1%5D=d&cv=2&w=1"
Else
	$szURL = "https://myanimelist.net/manga.php?o=9&c%5B0%5D=a&c%5B1%5D=d&cv=2"
EndIf
$source = _INetGetSource($szURL)
FileDelete($szFile3)
FileWrite(@ScriptDir & "\" & $szFile3, $source)
$read = FileRead(@ScriptDir & "\" & $szFile3)
$readtags = _StringBetween($read, '<div id="sarea', '">')
If $readtags[0] = "" Then $readtags[0] = "1"
$sValue2 = $readtags[0]
GUICtrlSetData($ToINP, $readtags[0])
EndFunc

Func _REGCHK()
If $Username = "" Then
	$Username = "ShaggyZE"
	GUICtrlSetData($UsernameINP, $Username)
	REGWRITE($REGKEY,"Username","REG_SZ",GUICtrlRead($UsernameINP))
EndIf
If $Template = "" Then
	$Template = "#tags-[ID]:after {font-family: Finger Paint; content: '[DESC]';}"
	GUICtrlSetData($TemplateINP, $Template)
	REGWRITE($REGKEY,"Template","REG_SZ",GUICtrlRead($TemplateINP))
EndIf
EndFunc

Func _ParseHTML($id)
$parseStr =  StringReplace($parseStr, @CRLF, " ")
$parseStr =  StringReplace($parseStr, @LF, "")
$parseStr =  StringReplace($parseStr, @CR, "")
$parseStr =  StringReplace($parseStr, ' - MyAnimeList.net', "")
$parseStr =  StringReplace($parseStr, ' | Manga', "")
$parseStr =  StringReplace($parseStr, ' | Light Novel', "")
$parseStr =  StringReplace($parseStr, '"', '')
$parseStr =  StringReplace($parseStr, "'", '')
$parseStr =  StringReplace($parseStr, "<br />", "")
$parseStr =  StringReplace($parseStr, "<i>", "")
$parseStr =  StringReplace($parseStr, "</i>", "")
$parseStr =  StringReplace($parseStr, "<b>", "")
$parseStr =  StringReplace($parseStr, "</b>", "")
$parseStr =  StringReplace($parseStr, "</a>", "")
$parseStr =  StringReplace($parseStr, "</span>", "")
$parseStr =  StringReplace($parseStr, "&quot;", '\"')
$parseStr =  StringReplace($parseStr, "&eacute;", "é")
$parseStr =  StringReplace($parseStr, "&euml;", "é")
$parseStr =  StringReplace($parseStr, "&auml;", "ä")
$parseStr =  StringReplace($parseStr, "Å", "o")
$parseStr =  StringReplace($parseStr, "â€•", "―")
$parseStr =  StringReplace($parseStr, "&amp;", "&")
$parseStr =  StringReplace($parseStr, "&rsquo;", "")
$parseStr =  StringReplace($parseStr, "&#039;", "")
$parseStr =  StringReplace($parseStr, "&#x27;", "")
$parseStr =  StringReplace($parseStr, "&mdash;", "-")
$parseStr =  StringReplace($parseStr, "<span style=font-size: 90%;>", " ")
$parseStr =  StringReplace($parseStr, "<span style=font-size: 90%;><b>", " ")
$parseStr =  StringReplace($parseStr, "</b></span>", "")
$parseStr =  StringReplace($parseStr, "/moreinfo>", " ")
$parseStr =  StringReplace($parseStr, "<!--link-->" & $id & "/", "")
$parseStr =  StringReplace($parseStr, " <a href=/dbchanges.php?aid=" & $id & "&t=synopsis>here.", "")
$parseStr =  StringReplace($parseStr, "<a href=http://myanimelist.net/manga/" & $id & "/-/moreinfo rel=nofollow>", "")
$parseStr =  StringReplace($parseStr, "<a href=http://myanimelist.net/manga/" & $id & "/-/moreinfo rel=nofollow>", "")
$parseStr =  StringReplace($parseStr, "<a href=http://myanimelist.net/anime/" & $id & "/-/moreinfo rel=nofollow>", "")
$parseStr =  StringReplace($parseStr, "<a href=https://myanimelist.net/manga/" & $id & "/-/moreinfo rel=nofollow>", "")
$parseStr =  StringReplace($parseStr, "<a href=https://myanimelist.net/anime/" & $id & "/-/moreinfo rel=nofollow>", "")
EndFunc   ;==>_ParseHTML

Func Parse($sTemp,$key)
$res = StringRegExp($sTemp, '\W' & $key & '\W+(\d+)\W+\W+([^"]+)', 3)
Global $array[UBound($res)/2][2]
For $i = 0 to UBound($res)-1
   If Mod($i, 2) = 0 Then
       $array[$i/2][0] = $res[$i]
   Else
       $array[($i-1)/2][1] = $res[$i]
EndIf
Next
;_ArrayDisplay($array)
EndFunc   ;==>Parse

Func _getData($o,$list)
While $data = ""
	$Username = GUICtrlRead($UsernameINP)
	$URL = "https://myanimelist.net/" & $list & "list/" & $Username & "/load.json?status=7&offset=" & $o
	Sleep(GUICtrlRead($DelayINP))
	$data = _INetGetSource($URL)
	ConsoleWrite("data = " & $data & @CRLF)
WEnd
EndFunc   ;==>getData

Func _ScrapeMAL($list)
GUICtrlSetData($OutputINP, "")
ToolTip("Scanning from " & $sValue1 & " to " & $sValue2, $x, $y)
While Number($sValue1) <= Number($sValue2)
	$id = $sValue1
	GUICtrlSetData($Progress, $sValue1 & " of " & $sValue2)
	$szURL = "https://myanimelist.net/" & $list & "/" & $id
    _CheckURLStatus()
	If $sValue1 = $sValue2 Then
			GUICtrlSetState($OutputCHK, 4)
			GUICtrlSetData($ButtonS, "Done (close)")
	EndIf
	If $sURL_Status = "200" Then
		ToolTip(GUICtrlRead($Progress) & " Scanned.", $x, $y)
		Sleep(GUICtrlRead($DelayINP))
		$source = _INetGetSource($szURL)
		FileDelete($szFile3)
		FileWrite(@ScriptDir & "\" & $szFile3, $source)
If Not StringInStr($Template,"[IMGURL]") = 0 Or Not StringInStr($Template,"[TITLE2]") = 0 Or Not StringInStr($Template,"[TITLEENG]") = 0 Or Not StringInStr($Template,"[TITLERAW]") = 0 Then
$source2 = _INetGetSource("https://api.jikan.moe/v3/" & $list & "/" & $id)
FileDelete($szFile4)
FileWrite(@ScriptDir & "\" & $szFile4, $source2)
Sleep(2000)
EndIf
While FileGetSize($szFile4) = 0
If Not StringInStr($Template,"[IMGURL]") = 0 Or Not StringInStr($Template,"[TITLE2]") = 0 Or Not StringInStr($Template,"[TITLEENG]") = 0 Or Not StringInStr($Template,"[TITLERAW]") = 0 Then
Sleep (6000)
$source2 = _INetGetSource("https://api.jikan.moe/v3/" & $list & "/" & $id)
FileDelete($szFile4)
FileWrite(@ScriptDir & "\" & $szFile4, $source2)
EndIf
WEnd
$read = FileRead(@ScriptDir & "\" & $szFile3)
$szText1=""
$szText1 = @CRLF & $Template
If Not StringInStr($Template,"[IMGURL]") = 0 Then $image = _GetJIKAN('"image_url":"', '",', $list, $id)
If Not StringInStr($Template,"[TITLE2]") = 0 Then $title = _GetJIKAN('"title":"', '",', $list, $id)
If Not StringInStr($Template,"[TITLEENG]") = 0 Then $titleeng = _GetJIKAN('"title_english":"', '",', $list, $id)
If Not StringInStr($Template,"[TITLERAW]") = 0 Then $titleraw = _GetJIKAN('"title_japanese":"', '",', $list, $id)
$titleraw = Execute("'" & StringRegExpReplace($titleraw, "(\\u([[:xdigit:]]{4}))","' & ChrW(0x$2) & '") & "'")
For $tagsIndex = 1 to IniRead("maltags.ini","tags","count","")
$readtags = _StringBetween($read, IniRead("maltags.ini",$tagsIndex,"before",""), IniRead("maltags.ini",$tagsIndex,"after",""))
If IsArray($readtags) Then
	_FileWriteFromArray(@ScriptDir & '\' & $szFile1, $readtags)
	$parseStr =  FileRead($szFile1,FileGetSize($szFile1))
	If $parseStr = "" Then ExitLoop
	_ParseHTML($id)
	$szText1 = StringReplace($szText1, "[DEL]", "")
	$szText1 = StringReplace($szText1, "[ID]", $id)
	$szText1 = StringReplace($szText1, "[TYPE]", $list)
	$szText1 = StringReplace($szText1, "[TITLE2]", $title)
	$szText1 = StringReplace($szText1, "[TITLEENG]", $titleeng)
	$szText1 = StringReplace($szText1, "[TITLERAW]", $titleraw)
	$szText1 = StringReplace($szText1, "[IMGURL]", $image)
	$szText1 = StringReplace($szText1, "[" & IniRead("maltags.ini",$tagsIndex,"name","") & "]", $parseStr)
EndIf
Next
For $tagsIndex = 1 to IniRead("maltags.ini","tags","count","")
	$szText1 = StringReplace($szText1, "[" & IniRead("maltags.ini",$tagsIndex,"name","") & "]", IniRead("maltags.ini",$tagsIndex,"notfound",""))
Next
FileWrite($szFile2, $szText1)
	Else
		;$sValue1 = $sValue1 - 1
		;MsgBox($MB_OK + $MB_ICONINFORMATION, 'SUCCESS', '$sURL_Status=' & $sURL_Status)
	EndIf
	$read2 = FileRead(@ScriptDir & "\" & $szFile2)
	If GUICtrlRead($OutputCHK) = 4 Then GUICtrlSetData($OutputINP, $read2)
	If Not $sURL_Status = "" Then $sValue1 = $sValue1 + 1
WEnd
ToolTip("", $x, $y)
EndFunc   ;==>_ScrapeMAL

Func _ScrapeloadjsonMAL($id, $list)
ToolTip(GUICtrlRead($Progress) & " Scanned.", $x, $y)
Sleep(GUICtrlRead($DelayINP))
$source = _INetGetSource($szURL)
FileDelete($szFile3)
FileWrite(@ScriptDir & "\" & $szFile3, $source)
If Not StringInStr($Template,"[IMGURL]") = 0 Or Not StringInStr($Template,"[TITLE2]") = 0 Or Not StringInStr($Template,"[TITLEENG]") = 0 Or Not StringInStr($Template,"[TITLERAW]") = 0 Then
$source2 = _INetGetSource("https://api.jikan.moe/v3/" & $list & "/" & $id)
FileDelete($szFile4)
FileWrite(@ScriptDir & "\" & $szFile4, $source2)
Sleep(2000)
EndIf
While FileGetSize($szFile4) = 0
If Not StringInStr($Template,"[IMGURL]") = 0 Or Not StringInStr($Template,"[TITLE2]") = 0 Or Not StringInStr($Template,"[TITLEENG]") = 0 Or Not StringInStr($Template,"[TITLERAW]") = 0 Then
Sleep (6000)
$source2 = _INetGetSource("https://api.jikan.moe/v3/" & $list & "/" & $id)
FileDelete($szFile4)
FileWrite(@ScriptDir & "\" & $szFile4, $source2)
EndIf
WEnd
$read = FileRead(@ScriptDir & "\" & $szFile3)
$szText1=""
$szText1 = @CRLF & $Template
If Not StringInStr($Template,"[IMGURL]") = 0 Then $image = _GetJIKAN('"image_url":"', '",', $list, $id)
If Not StringInStr($Template,"[TITLE2]") = 0 Then $title = _GetJIKAN('"title":"', '",', $list, $id)
If Not StringInStr($Template,"[TITLEENG]") = 0 Then $titleeng = _GetJIKAN('"title_english":"', '",', $list, $id)
If Not StringInStr($Template,"[TITLERAW]") = 0 Then $titleraw = _GetJIKAN('"title_japanese":"', '",', $list, $id)
$titleraw = Execute("'" & StringRegExpReplace($titleraw, "(\\u([[:xdigit:]]{4}))","' & ChrW(0x$2) & '") & "'")
For $tagsIndex = 1 to IniRead("maltags.ini","tags","count","")
$readtags = _StringBetween($read, IniRead("maltags.ini",$tagsIndex,"before",""), IniRead("maltags.ini",$tagsIndex,"after",""))
If IsArray($readtags) Then
	_FileWriteFromArray(@ScriptDir & '\' & $szFile1, $readtags)
	$parseStr =  FileRead($szFile1,FileGetSize($szFile1))
	If $parseStr = "" Then ExitLoop
	_ParseHTML($id)
	$szText1 = StringReplace($szText1, "[DEL]", "")
	$szText1 = StringReplace($szText1, "[ID]", $id)
	$szText1 = StringReplace($szText1, "[TYPE]", $list)
	$szText1 = StringReplace($szText1, "[TITLE2]", $title)
	$szText1 = StringReplace($szText1, "[TITLEENG]", $titleeng)
	$szText1 = StringReplace($szText1, "[TITLERAW]", $titleraw)
	$szText1 = StringReplace($szText1, "[IMGURL]", $image)
	$szText1 = StringReplace($szText1, "[" & IniRead("maltags.ini",$tagsIndex,"name","") & "]", $parseStr)
EndIf
Next
For $tagsIndex = 1 to IniRead("maltags.ini","tags","count","")
	$szText1 = StringReplace($szText1, "[" & IniRead("maltags.ini",$tagsIndex,"name","") & "]", IniRead("maltags.ini",$tagsIndex,"notfound",""))
Next
FileWrite($szFile2, $szText1)
$read2 = FileRead(@ScriptDir & "\" & $szFile2)
If GUICtrlRead($OutputCHK) = 4 Then GUICtrlSetData($OutputINP, $read2)
EndFunc   ;==>_ScrapeloadjsonMAL

Func _GetloadjsonAnimeMAL()
Local $count = 0
Do
	$data = ""
	_getData($o,"anime")
	If Not $mode = "" Or $data = "[]" Then _BuildCSS("anime")
	;GUICtrlSetData($OutputINP, $data)
	Parse($data,"anime_id")
	If Not IsArray($array) Then ExitLoop 1
	;_ArrayDisplay($array)
	For $gather = 0 to UBound($array) - 1
		$anime_id = $array[$gather][0]
		If $anime_id  = "" Then ExitLoop 2
		If $count = 0 Then
			$anime_ids = $anime_id
		Else
			$anime_ids = $anime_ids & "," & $anime_id
		EndIf
		$count += 1
		If @error Then ExitLoop 2
	Next
	$o += 300
	ToolTip("Gathering IDs " & $o, $x, $y)
	ConsoleWrite($count & " " & $o & @CRLF)
	ConsoleWrite($anime_ids & @CRLF)
	If @error Then ExitLoop 1
Until $data = "[]"
EndFunc   ;==>_GetloadjsonAnimeMAL

Func _GetloadjsonMangaMAL()
Local $count = 0
Do
	$data = ""
	_getData($o,"manga")
	If Not $mode = "" Or $data = "[]" Then _BuildCSS("manga")
	;GUICtrlSetData($OutputINP, $data)
	Parse($data,"manga_id")
	If Not IsArray($array) Then ExitLoop 1
	;_ArrayDisplay($array)
	For $gather = 0 to UBound($array) - 1
		$manga_id = $array[$gather][0]
		If $manga_id  = "" Then ExitLoop 2
		If $count = 0 Then
			$manga_ids = $manga_id
		Else
			$manga_ids = $manga_ids & "," & $manga_id
		EndIf
		$count += 1
		If @error Then ExitLoop 2
	Next
	$o += 300
	ToolTip("Gathering IDs " & $o, $x, $y)
	ConsoleWrite($count & " " & $o & @CRLF)
	ConsoleWrite($manga_ids & @CRLF)
	If @error Then ExitLoop 1
Until $data = "[]"
EndFunc   ;==>_GetloadjsonMangaMAL

Func _BuildCSS($list)
$mode = "building"
If $list = "anime" Then
	Local $anime_ids_array = StringSplit($anime_ids,",")
	For $scrape = 1 to UBound($anime_ids_array) - 1
		GUICtrlSetData($Progress, $scrape & " of " & UBound($anime_ids_array) - 1)
		If $scrape = UBound($anime_ids_array) - 2 Then GUICtrlSetState($OutputCHK, 4)
		$szURL = "https://myanimelist.net/anime/" & $anime_ids_array[$scrape]
		_CheckURLStatus()
		If $sURL_Status = "200" Then
			_ScrapeloadjsonMAL($anime_ids_array[$scrape],"anime")
		Else
			$scrape = $scrape - 1
		EndIf
	Next
	If $scrape = UBound($anime_ids_array) Then
		$mode = ""
		GUICtrlSetData($ButtonS, "Done (close)")
	EndIf
ElseIf $list = "manga" Then
	Local $manga_ids_array = StringSplit($manga_ids,",")
	For $scrape = 1 to UBound($manga_ids_array) - 1
		GUICtrlSetData($Progress, $scrape & " of " & UBound($manga_ids_array) - 1)
		If $scrape = UBound($manga_ids_array) - 2 Then GUICtrlSetState($OutputCHK, 4)
		$szURL = "https://myanimelist.net/manga/" & $manga_ids_array[$scrape]
		_CheckURLStatus()
		If $sURL_Status = "200" Then
			_ScrapeloadjsonMAL($manga_ids_array[$scrape],"manga")
		Else
			$scrape = $scrape - 1
		EndIf
	Next
	If $scrape = UBound($manga_ids_array) Then
		$mode = ""
		GUICtrlSetData($ButtonS, "Done (close)")
	EndIf
EndIf
EndFunc   ;==>_BuildCSS

Func _GetJIKAN($before, $after, $list, $id)
$read2 = FileRead(@ScriptDir & "\" & $szFile4)
$readtags2 = _StringBetween($read2, $before, $after)
If IsArray($readtags2) Then
_FileWriteFromArray(@ScriptDir & '\' & $szFile5, $readtags2)
$parseStr2 = FileRead($szFile5,FileGetSize($szFile5))
$parseStr2 =  StringReplace($parseStr2, @LF, "")
$parseStr2 =  StringReplace($parseStr2, @CR, "")
$parseStr2 =  StringReplace($parseStr2, @CRLF, "")
$parseStr2 =  StringReplace($parseStr2, "\/", "/")
ElseIf $readtags2 = "null" Then
	If $before = '"title":"' Then Exit
	If $before = '"title_english":"' Then $parseStr2 = "N/A"
	If $before = '"title_japanese":"' Then $parseStr2 = "N/A"
EndIf
Return $parseStr2
EndFunc   ;==>_BuildCSS

Func _CheckURLStatus()
$sURL_Status = _ULRNotifier(_URL_CheckStatus($szURL))
;MsgBox($MB_OK + $MB_ICONINFORMATION, 'SUCCESS', '$sURL_Status=' & $sURL_Status)
If $sURL_Status = "403" Then
	;ShellExecute($szURL)
	While $sURL_Status = "403"
		_IENavigate($oIE, $szURL)
		_IELoadWait($oIE, 5000, 10000)
		$oLinks = _IETagNameGetCollection($oIE, "button")
		For $oLink In $oLinks
		If String($oLink.type) = "submit" Then
		  _IEAction($oLink, "click")
          ExitLoop
		EndIf
		Next
		_IELoadWait($oIE, 5000, 10000)
		Sleep (20000)
		$sURL_Status = _ULRNotifier(_URL_CheckStatus($szURL))
	WEnd
ElseIf $sURL_Status = "500" Then
	ShellExecute($szURL)
	MsgBox($MB_OK + $MB_ICONINFORMATION, 'FAILED', '$sURL_Status=' & $sURL_Status)
EndIf
EndFunc

Func _URL_CheckStatus($sURL)
    _URLChecker_COMErrDescripion("")
    Local $oErrorHandler = ObjEvent("AutoIt.Error", "_URLChecker_COMErrFunc")
    #forceref $oErrorHandler

    Local $oHTTP = ObjCreate("WinHttp.WinHttpRequest.5.1")

    $oHTTP.Open("HEAD", $sURL, False)
    If @error Then Return SetError(1, @error, '')

    $oHTTP.Send()
    Local $iError = @error

    Local $sStatus = $oHTTP.Status
    If @error Then Return SetError(3, @error, $sStatus)

    If $iError Then Return SetError(2, $iError, $sStatus)

    Return $sStatus
EndFunc   ;==>_URL_CheckStatus

Func _URLChecker_COMErrFunc($oError)
    _URLChecker_COMErrDescripion($oError.description)

    Return ; you can comment/dlete this return to show full error descripition

    ConsoleWrite(@ScriptName & " (" & $oError.scriptline & ") : ==> COM Error intercepted !" & @CRLF & _
            @TAB & "$oError.number is: " & @TAB & @TAB & "0x" & Hex($oError.number) & @CRLF & _
            @TAB & "$oError.windescription:" & @TAB & $oError.windescription & @CRLF & _
            @TAB & "$oError.description is: " & @TAB & $oError.description & @CRLF & _
            @TAB & "$oError.source is: " & @TAB & @TAB & $oError.source & @CRLF & _
            @TAB & "$oError.helpfile is: " & @TAB & $oError.helpfile & @CRLF & _
            @TAB & "$oError.helpcontext is: " & @TAB & $oError.helpcontext & @CRLF & _
            @TAB & "$oError.lastdllerror is: " & @TAB & $oError.lastdllerror & @CRLF & _
            @TAB & "$oError.scriptline is: " & @TAB & $oError.scriptline & @CRLF & _
            @TAB & "$oError.retcode is: " & @TAB & "0x" & Hex($oError.retcode) & @CRLF & @CRLF)
EndFunc   ;==>_URLChecker_COMErrFunc

Func _URLChecker_COMErrDescripion($sDescription = Default)
    Local Static $sDescription_static = ''
    If $sDescription <> Default Then $sDescription_static = $sDescription
    Return $sDescription_static
EndFunc   ;==>_URLChecker_COMErrDescripion

Func _ULRNotifier($vResult, $iError = @error, $iExtended = @extended)
    If $iError Then ConsoleWrite( _
            "! @error = " & $iError & "  @extended = " & $iExtended & " $vResult = " & $vResult & @CRLF & _
            "! " & _URLChecker_COMErrDescripion() & @CRLF _
            )
    Return SetError($iError, $iExtended, $vResult)
EndFunc   ;==>_ULRNotifier

 Func _MY_WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
	Local $iIDFrom = BitAND($wParam, 0xFFFF) ; LoWord - this gives the control which sent the message
	Local $iCode = BitShift($wParam, 16)     ; HiWord - this gives the message that was sent
	;MsgBox(0,"message",$iIDFrom & " " & $iCode)
		Switch $iIDFrom
		Case 3
			If GUICtrlRead($ButtonS) = "Stop (close)" or GUICtrlRead($ButtonS) = "Done (close)" Then
				$cMsg = MsgBox (4, "Closing" ,"Would you like to open " & $szFile2 & "?")
				If $cMsg = 6 Then
					ShellExecute($szFile2)
				EndIf
				Exit
			EndIf
		Case 18
			If GUICtrlRead($AntiSpamCHK) = 1 Then
				GUICtrlSetState($GUIActiveX, $GUI_SHOW)
			Else
				GUICtrlSetState($GUIActiveX, $GUI_HIDE)
			EndIf
	EndSwitch
 EndFunc ;==>_MY_WM_COMMAND