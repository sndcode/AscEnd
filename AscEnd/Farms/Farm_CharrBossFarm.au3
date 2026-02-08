#include-once

#cs ----------------------------------------------------------------------------

	 AutoIt Version: 3.3.18.0
	 Author:         Coffee

	 Script Function: Presearing Charr Farming

#ce ----------------------------------------------------------------------------

; Pathing from (Ashford -> gate lever)
Global $CharrGatePath[16][2] = [ _
    [-10737, -5323], _
    [-10633, -3944], _
    [-10956, -2289], _
    [-11179,  -253], _
    [-12067,  2522], _
    [-11767,  3386], _
    [ -9983,  4125], _
    [ -8918,  8673], _
    [ -8819, 10227], _
    [ -8425, 11401], _
    [ -7412, 11619], _
    [ -6674, 11637], _
    [ -4189, 11382], _
    [ -3318, 11666], _
    [ -3297, 12151], _
    [ -5442, 12790] _
]

; Through gate lever -> portal
Global $CharrPortalPath[3][2] = [ _
    [-4350, 12439], _
    [-4131, 11782], _
    [-5327, 11861] _
]

Global $Test[5][2] = [ _
    [-12353, -13680], _
    [-13057, -12682], _
    [-14783, -12376], _
    [-16047, -13285], _
    [-16627, -13717] _
]

; Full charr route checkpoints
;~ Global $CharrFarmPath[24][2] = [ _
;~     [-12232, -14221], _
;~     [-12953, -12465], _
;~     [-13666, -11333], _
;~     [-13015,  -9810], _
;~     [-12504,  -8509], _
;~     [-10480,  -6856], _
;~     [-10419,  -6376], _
;~     [ -8435,  -4969], _
;~     [ -5352,  -4809], _
;~     [ -3123,  -4386], _
;~     [ -2148,  -3649], _
;~     [  -791,  -3761], _
;~     [   234,  -4893], _
;~     [   332,  -5496], _
;~     [   568,  -4305], _
;~     [   441,  -4941], _
;~     [     0,  -3436], _
;~     [    33,  -2740], _
;~     [   512,  -2724], _
;~     [  -179,  -2748], _
;~     [   719,  -3126], _
;~     [   207,  -3293], _
;~     [   944,  -2564], _
;~     [  1576,  -2494] _
;~ ]
; ^ Continue adding checkpoints

; Example boss-pull checkpoints (they used [7, 9, 11, 13, 15] 1-based)
; We'll keep that idea, 1-based index.
Global $g_aBossPullCP[5] = [7, 9, 11, 13, 15]

Func Farm_CharrBossFarm()
    While 1
        If CountSlots() < 4 Then InventoryPre()
        If Not $hasBonus Then GetBonus()

        CharrSetup()
        
        While CountSlotS() > 1
            If Not $BotRunning Then
                ResetStart()
                Return
            EndIf

            CharrBossFarm()
        WEnd
    WEnd
EndFunc

Func CharrSetup()
    QuestActive(0x2E)
    Local $cAgState = Quest_GetQuestInfo(0x2E, "LogState")

    If $cAgState <> 1 Then
        LogInfo("Charr quest is not active. We are clear to proceed to the northlands.")
    Else
        LogWarn("Charr quest is active, we will abandon it so the way is clear.")
        Quest_AbandonQuest(0x2E)
        Sleep(1000)
    EndIf
EndFunc

Func CharrBossFarm()
    If Map_GetMapID() = 164 Then
        LogInfo("We are in Ashford Abbey. Starting Charr Boss farming run...")
    ElseIf Map_GetMapID() <> 164 And Map_IsMapUnlocked(164) Then
        LogInfo("We are not in Ashford Abbey. Teleporting to Ashford...")
        Map_RndTravel(164)
        Map_WaitMapLoading(164, 0)
        Sleep(2000)
    ElseIf Not Map_IsMapUnlocked(164) Then
        LogWarn("Ashford Abbey is not unlocked on this character, lets try to run there...")
        While Not UnlockAshford()
            LogError("Failed to unlock Ashford Abbey.  Retrying...")
            Sleep(2000)
        WEnd
    EndIf

	ExitAshford()

	LogInfo("DEBUG: Entered CharBossFarm")
    Other_RndSleep(250)

    ; 1) Ashford -> Charr Gate route 
    LogInfo("Running to Charr Gate...")
    RunTo($CharrGatePath)

    ; 2) Lever open door
    LogInfo("Opening the gate lever...")
    Agent_GoSignpost(GetNearestGadgetToAgent(-2))
    Sleep(250)

    ; 3) Through gate to portal
    LogInfo("Moving to Charr portal...")
    RunTo($CharrPortalPath)
    Map_Move(-5598, 14178)
    Map_WaitMapLoading(147, 1)

    ; 4)
    $RunTime = TimerInit()

    UseSummoningStone()

    LogInfo("Arrived at Charr map. Starting checkpoints...")
    LogWarn("IMAGINE AN EPIC CHARR BOSS BATTLE!!")
    RunToCBF($Test)
    LogWarn("PEW PEW PEW, OH NO I'M HIT!")
    LogWarn("AHHHAA, FELL FOR A FEINT! SILLY LITTLE CAT!!")

    LogInfo("Run complete. Restarting...")
    Resign()
    Sleep(5000)
    Map_ReturnToOutpost()
    Sleep(1000)
    Map_WaitMapLoading(164, 0)
    Sleep(1000)
EndFunc

Func RunToCBF($g_a_RunPath)
    For $i = 0 To UBound($g_a_RunPath) - 1
        AggroMoveToExFilter($g_a_RunPath[$i][0], $g_a_RunPath[$i][1], 2500)
        If SurvivorMode() Then
            LogError("Survivor mode activated!")
            Return
        EndIf
    Next
EndFunc

Func _IsBossPullCheckpoint($cp)
    For $i = 0 To UBound($g_aBossPullCP) - 1
        If $cp = $g_aBossPullCP[$i] Then Return True
    Next
    Return False
EndFunc

Func Lever_OpenDoor()
    ; TODO: Replace this with the exact lever interaction your framework uses.
    ; Common patterns are something like:
    ;   Gadget_UseNearest()
    ;   InteractNearestGadget()
    ;   Gadget_InteractByModelID(<leverModelId>)
    ;
    Sleep(500)
EndFunc

Func PullMobs()
    Sleep(250)
EndFunc

Func KillMobs()
    Sleep(250)
EndFunc

Func CharrBossFilter($aAgentPtr) ; Custom filter for CharrBoss that applies to farm.

	If Agent_GetAgentInfo($aAgentPtr, 'Allegiance') <> 3 Then Return False
    If Agent_GetAgentInfo($aAgentPtr, 'HP') <= 0 Then Return False
    If Agent_GetAgentInfo($aAgentPtr, 'IsDead') > 0 Then Return False

    Local $ModelID = Agent_GetAgentInfo($aAgentPtr, 'PlayerNumber')
    Local $CharrBossID[4] = [48, 50, 51, 52, 53] ; Array of charr boss model IDs
    Local $IsCharrBoss = False
    For $i = 0 To UBound($CharrBossID) - 1
        If $ModelID == $CharrBossID[$i] Then
            $IsCharrBoss = True
            ExitLoop
        EndIf
    Next
    If Not $IsCharrBoss Then Return False

    Return True
EndFunc
