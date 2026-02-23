#include-once

#cs ----------------------------------------------------------------------------

     AutoIt Version: 3.3.18.0
     Author:         Incognito

     Script Function:
        Gargoyle Skull Farm - Pre Searing

#ce ----------------------------------------------------------------------------

Global $GargPath1[8][2] = [ _ ; Barradin to entrance
    [-7879, 1439], _
    [-7894, 2398], _
    [-7390, 2797], _
    [-5410, 3031], _
    [-4257, 3123], _
    [-4137, 4612], _
    [-4177, 6637], _
    [-4142, 8031] _
]

Global $GargPath2[2][2] = [ _ ; Inside catacombs, move closer
    [-8467, 15243], _
    [-7552, 15349] _
]

Global $GargPath3[4][2] = [ _ ; Reset coords
    [-7508, 15363], _
    [-9068, 15338], _
    [-10349, 15744], _
    [-11297, 16216] _
]

Func Farm_GargoyleSkull()
    While 1
        If CountSlots() < 4 Then InventoryPre()
        If Not $hasBonus Then GetBonus()
        
        GargoyleSkullSetup()

        While CountSlotS() > 1
            If Not $BotRunning Then
                ResetStart()
                Return
            EndIf

            GargoyleSkull()

            If SurvivorMode() Then
                Return
            EndIf
        WEnd
    WEnd
EndFunc

Func GargoyleSkullSetup()
    If Map_GetMapID() = 163 Then
        LogInfo("We are in Barradin Estate. Starting the Gargoyle Skull farm...")
    ElseIf Map_GetMapID() <> 163 And Map_IsMapUnlocked(163) Then
        LogInfo("We are not in Barradin Estate. Teleporting to Barradin Estate...")
        Map_RndTravel(163)
        Sleep(2000)
    ElseIf Not Map_IsMapUnlocked(163) Then
        LogWarn("Barradin Estate is not unlocked on this character, lets try to run there...")
        While Not UnlockBarradin()
            LogError("Failed to unlock Barradin Estate.  Retrying...")
            Sleep(2000)
        WEnd
    EndIf

    ExitBarradin()

    RunTo($GargPath1)
    LogInfo("Who dares to toil, with the gargoyle? ME!")
EndFunc

Func GargoyleSkull()
    MoveTo(-3579, 9052)
    Map_Move(-2862, 9414)
    Map_WaitMapLoading(145, 1)
    
    Sleep(1000)
    
    $RunTime = TimerInit()

    RunTo($GargPath2)
    UseSummoningStone()

    AggroMoveSmartFilter(-6655, 15657, 2000, 2000)

    If SurvivorMode() Then
        LogError("Survivor mode activated!")
        Return
    EndIf

    LogInfo("Run complete. Restarting...")
    UpdateStats()
    Other_RndSleep(250)

    RunTo($GargPath3)
    Map_Move(-4000, 9560)
    Map_WaitMapLoading(160, 1)
    Sleep(2000)
EndFunc