#include-once

#cs ----------------------------------------------------------------------------

	 AutoIt Version: 3.3.18.0
	 Author:         Coaxx

	 Script Function:
		Red Iris Farm - Pre Searing

#ce ----------------------------------------------------------------------------

Global $IrisPath[2][3] = [ _ ; Iris Farm Pre-Searing Path
    [-10784.77, -5936.46, ""], _
    [-9838.80, -4794.23, "RedIris"] _
]


Func Farm_RedIris()

    While 1
        If CountSlots() < 4 Then InventoryPre()
        If Not $hasBoners Then GetBoners()

        IrisSetup()

	    While CountSlots() > 1
		    IrisFarm()
	    WEnd
    WEnd
EndFunc

Func IrisSetup()
    If Map_GetMapID() = 164 Then
        Out("We are in Ashford Abbey. Starting Iris farming run...")
    ElseIf Map_GetMapID() <> 164 And Map_IsMapUnlocked(164) Then
        Out("We are not in Ashford Abbey. Teleporting to Ashford...")
        Map_RndTravel(164)
        Map_WaitMapLoading(164, 0)
        Sleep(2000)
    ElseIf Not Map_IsMapUnlocked(164) Then
        Out("Ashford Abbey is not unlocked on this character, lets try to run there...")
        While Not UnlockAshford()
            Out("Failed to unlock Ashford Abbey.  Retrying...")
            Sleep(2000)
        WEnd
    EndIf

    ExitAshford() ; Gate trick setup
    Map_Move(-11100, -6200)
    Map_WaitMapLoading(164, 0)
    Sleep(2000)
EndFunc

Func IrisFarm()
    Map_Move(-11089, -6250) ; Leave Ashford Abbey
    Map_WaitMapLoading(146, 1)

    Sleep(1000)

	$RunTime = TimerInit()

    UseSummoningStone()
    RunToIris($IrisPath)
    Other_RndSleep(250)
    Out("Iris farming run complete. Restarting...")
    UpdateStats()
    Other_RndSleep(250)
    Resign()
    Sleep(5000)
    Map_ReturnToOutpost()
    Sleep(1000)
    Map_WaitMapLoading(164, 0)
    Sleep(1000)
EndFunc

Func IrisPickup()
    Local $lAgentArray = Item_GetItemArray()
    Local $maxitems = $lAgentArray[0]
    
    For $i = 1 To $maxitems
        Local $aItemPtr = $lAgentArray[$i]
        Local $aItemAgentID = Item_GetItemInfoByPtr($aItemPtr, "AgentID")
        
        If $aItemAgentID = 0 Then ContinueLoop
        
        ; Is it an Iris?
        Local $lModelID = Item_GetItemInfoByPtr($aItemPtr, "ModelID")
        If $lModelID <> $GC_I_MODELID_RED_IRIS_FLOWER Then ContinueLoop
        
        MoveTo(Agent_GetAgentInfo($aItemAgentID, "X"), Agent_GetAgentInfo($aItemAgentID, "Y"), 25)
        
        Sleep(250)
        
        Item_PickUpItem($aItemAgentID)
        
        Local $lDeadlock = TimerInit()
        While Agent_GetAgentPtr($aItemAgentID) > 0
            Sleep(100)
            If TimerDiff($lDeadlock) > 5000 Then ExitLoop
        WEnd
        
        Out("Red Iris collected!")
        Return True
    Next
    
    Out("No Red Iris nearby.")
    Return False
EndFunc

Func RunToIris($g_a_RunPath)
    For $i = 0 To UBound($g_a_RunPath) - 1
        MoveTo($g_a_RunPath[$i][0], $g_a_RunPath[$i][1])
        
        If $g_a_RunPath[$i][2] = "RedIris" Then IrisPickUp()
    Next
EndFunc

Func ExitAshford()
    $spawn[0] = Agent_GetAgentInfo(-2, "X")
    $spawn[1] = Agent_GetAgentInfo(-2, "Y")
    Local $sp1 = ComputeDistance(-12342.00, -6538.00, $spawn[0], $spawn[1])

    Select
        Case ($sp1 <= 1200) Or ($sp1 >= 1800)
            Out("What a lovely day to pick some flowers.")
            MoveTo(-11457.08, -6238.37)
        Case $sp1 > 1200 And $sp1 < 1800
            Out("Mhenlo's smiling, Meerak's humming, and I'm picking red irises..")
            MoveTo(-12536.56, -6758.55)
            MoveTo(-11457.08, -6238.37)
    EndSelect
        
    Map_Move(-11089, -6250)
    Map_WaitMapLoading(146, 1)
    Sleep(2000)
EndFunc