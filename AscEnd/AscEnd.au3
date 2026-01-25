#RequireAdmin
#include "../../API/_GwAu3.au3"
#include "GwAu3_AddOns.au3"

#Region Declarations

Global Const $doLoadLoggedChars = True
Opt("GUIOnEventMode", 1)
Opt("GUICloseOnESC", False)
Opt("ExpandVarStrings", 1)

Global $ProcessID = ""
Global $timer = TimerInit()
Global $TotalTime = 0
Global $RunTime = 0
Global $g_b_DebugMode = False
Global Const $BotTitle = "AscEnd"
Global $BotRunning = False
Global $Bot_Core_Initialized = False
Global $Survivor = False
Global $_19Stop = False
Global $Collector = False
Global $Purple = False
Global $spawn[2] = [0, 0]
Global $hasBoners = False

$g_bAutoStart = False  ; Flag for auto-start
$g_s_MainCharName  = ""

#EndRegion Declaration

#include "Farms/Farms_All.au3"

; Process command line arguments
For $i = 1 To $CmdLine[0]
    If $CmdLine[$i] = "-character" And $i < $CmdLine[0] Then
        $g_s_MainCharName = $CmdLine[$i + 1]
        $g_bAutoStart = True
        ExitLoop
    EndIf
Next

#include "GUI.au3"

Out("Based on GWA2")
Out("GWA2 - Created by: " & $GC_S_GWA2_CREATOR)
Out("GWA2 - Build date: " & $GC_S_GWA2_BUILD_DATE & @CRLF)

Out("GwAu3 - Created by: " & $GC_S_UPDATOR)
Out("GwAu3 - Build date: " & $GC_S_BUILD_DATE)
Out("GwAu3 - Version: " & $GC_S_VERSION)
Out("GwAu3 - Last Update: " & $GC_S_LAST_UPDATE & @CRLF)
Core_AutoStart()

While Not $BotRunning
    Sleep(100)
WEnd

While True
    If $BotRunning = True Then
        RunSelectedFarm()
    Else
        Sleep(1000)
    EndIf
WEnd

Func RunSelectedFarm()
    Local $FarmToRun = GUICtrlRead($FarmCombo)

    If $FarmToRun = "" Then
        Out("Error: No farm selected.")
        Out("Bot will close in 5 seconds...")
        Sleep(5000)
        Exit
    EndIf

    For $i = 0 To UBound($g_a_Farms) - 1
        If $g_a_Farms[$i][0] = $FarmToRun Then
            If $g_a_Farms[$i][1] = "" Then Return False

            AdlibRegister("UpdateTotalTime", 1000)
            $TotalTime = TimerInit()
            UpdateStats()
            Return Call($g_a_Farms[$i][1])
        EndIf
    Next

    Out("Error: No valid farm selected.")
    Out("Bot will close in 5 seconds...")
    Exit
EndFunc

Func GetBoners()
    If Map_GetMapID() <> 148 Then Map_RndTravel(148)
    Sleep(250)
    Chat_SendChat("bonus", "/")
    Other_RndSleep(4500)

    DeleteBonusItems()
    Other_RndSleep(1500)
    $hasBoners = True
EndFunc