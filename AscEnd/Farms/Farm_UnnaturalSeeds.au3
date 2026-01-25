#include-once

#cs ----------------------------------------------------------------------------

	 AutoIt Version: 3.3.18.0
	 Author:         Coaxx

	 Script Function:
		Unnatural Seed Farm

#ce ----------------------------------------------------------------------------

Global $SeedsPath[19][2] = [ _
    [22556, 6260], _
    [22216, 4992], _
    [21428, 3892], _
    [21028, 2592], _
    [20128, 1592], _
    [19728, 392], _
    [19140, -808], _
    [18740, -2108], _
    [17840, -3008], _
    [17040, -4008], _
    [16352, -5208], _
    [16052, -6508], _
    [15952, -7808], _
    [16452, -9008], _
    [17340, -9908], _
    [17640, -11208], _
    [18740, -12008], _
    [20028, -12108], _
    [20645, -12323] _
]

Func Farm_UnnaturalSeeds()

    While 1
        If CountSlots() < 4 Then InventoryPre()
        If Not $hasBoners Then GetBoners()
        
        UnnaturalSeedSetup()

        While CountSlots() > 1
            UnnaturalSeed()
        WEnd
    WEnd
EndFunc

Func UnnaturalSeedSetup()
    If Map_GetMapID() = 166 Then
        Out("We are in Fort Ranik. Starting the Unnatural Seeds farm...")
    ElseIf Map_GetMapID() <> 166 And Map_IsMapUnlocked(166) Then
        Out("We are not in Fort Ranik. Teleporting to Fort Ranik...")
        Map_RndTravel(166)
        Sleep(2000)
    ElseIf Not Map_IsMapUnlocked(166) Then
        Out("Fort Ranik is not unlocked on this character, lets try to run there...")
        While Not UnlockRanik()
            Out("Failed to unlock Fort Ranik.  Retrying...")
            Sleep(2000)
        WEnd
    EndIf

    $spawn[0] = Agent_GetAgentInfo(-2, "X")
    $spawn[1] = Agent_GetAgentInfo(-2, "Y")
    Local $sp1 = ComputeDistance(23020, 10125, $spawn[0], $spawn[1])
        
    Select
        Case $sp1 <= 2400
            Out("Little high, little low.")
            MoveTo(22865, 11380)
            MoveTo(22958, 11149)
        Case $sp1 > 2400 And $sp1 <= 4200
            Out("Anywhere the wind blows.")
            MoveTo(23038, 11847)
        Case $sp1 > 4200
            Out("King Adelbern, doesn't even matter.")
            MoveTo(23186, 13527)
            MoveTo(23038, 11847)
        EndSelect

        MoveTo(22552, 7515) ; Gate trick setup
        Map_Move(22530, 7300)
        Map_WaitMapLoading(162, 1)
        Sleep(2000)
        Map_Move(22538, 7280)
        Map_WaitMapLoading(166, 0)
        Sleep(2000)
EndFunc

Func UnnaturalSeed()
    Other_RndSleep(250)
    MoveTo(22552, 7515)
    Map_Move(22530, 7300)
    Map_WaitMapLoading(162, 1)
    Sleep(1000)

    $RunTime = TimerInit()

    UseSummoningStone()
    RunToSeeds($SeedsPath)
    Other_RndSleep(250)
    Out("Run complete. Restarting...")
    UpdateStats()
    Other_RndSleep(250)
    Resign()
    Sleep(5000)
    Map_ReturnToOutpost()
    Sleep(1000)
    Map_WaitMapLoading(166, 0)
    Sleep(1000)
EndFunc

Func RunToSeeds($g_ai2_RunPath)
    For $i = 0 To UBound($g_ai2_RunPath, 1) - 1
        AggroMoveToExFilter($g_ai2_RunPath[$i][0], $g_ai2_RunPath[$i][1], 2500, "UnnaturalSeeds")
        If SurvivorMode() Then
            Out("Survivor mode activated!")
            Return
        EndIf
    Next
EndFunc

; Use this as an example, to filter out any enemies we want to 'Lock On' to.
; Target is an enemy and we make sure the target isn't dead, not kicking corpses round 'ere boys!
; In the function below, Bandits are filtered out using model id's, get the model id of your enemy and away you go.
Func UnnaturalSeeds($aAgentPtr) ; Custom filter for bandits in the Hamnet farm.

	If Agent_GetAgentInfo($aAgentPtr, 'Allegiance') <> 3 Then Return False
    If Agent_GetAgentInfo($aAgentPtr, 'HP') <= 0 Then Return False
    If Agent_GetAgentInfo($aAgentPtr, 'IsDead') > 0 Then Return False

    Local $ModelID = Agent_GetAgentInfo($aAgentPtr, 'PlayerNumber')
    Local $SpiderAloeIDs[6] = [1401, 1403, 1426, 1428, 1429] ; Array of bandit model IDs
    Local $IsSpiderAloe = False
    For $i = 0 To UBound($SpiderAloeIDs) - 1
        If $ModelID == $SpiderAloeIDs[$i] Then
            $IsSpiderAloe = True
            ExitLoop
        EndIf
    Next
    If Not $IsSpiderAloe Then Return False

    Return True
EndFunc