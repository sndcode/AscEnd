#include-once

#cs ----------------------------------------------------------------------------

	 AutoIt Version: 3.3.18.0
	 Author:         Coaxx

	 Script Function:
		Blank Base For Farms

#ce ----------------------------------------------------------------------------

Func Farm_Blank()
    $TotalTime = TimerInit()
    While 1
        If CountSlots() < 4 Then InventoryPre()
        
        BlankSetup()

        While CountSlotS() > 1
            Blank()
        WEnd
    WEnd
EndFunc

Func BlankSetup()
; Setup the farm here, this wont be looped but will be called again if we come back from InventoryPre().
EndFunc

Func Blank()
   
EndFunc

Func RunToAggro($g_ai2_RunPath)
    For $i = 0 To UBound($g_ai2_RunPath, 1) - 1
        AggroMoveToExFilter($g_ai2_RunPath[$i][0], $g_ai2_RunPath[$i][1], 2500)
        If SurvivorMode() Then
            Out("Survivor mode activated!")
            Return
        EndIf
    Next
EndFunc

; Use this as an example, to filter out any enemies we want to 'Lock On' to.
; Target is an enemy and we make sure the target isn't dead, not kicking corpses round 'ere boys!
; In the function below, Bandits are filtered out using model id's, get the model id of your enemy and away you go.
Func BanditFilter($aAgentPtr) ; Custom filter for bandits in the Hamnet farm.

	If Agent_GetAgentInfo($aAgentPtr, 'Allegiance') <> 3 Then Return False
    If Agent_GetAgentInfo($aAgentPtr, 'HP') <= 0 Then Return False
    If Agent_GetAgentInfo($aAgentPtr, 'IsDead') > 0 Then Return False

    Local $ModelID = Agent_GetAgentInfo($aAgentPtr, 'PlayerNumber')
    Local $BanditModelIDs[6] = [7824, 7825, 7839, 7840, 7857, 7858] ; Array of bandit model IDs
    Local $IsBandit = False
    For $i = 0 To UBound($BanditModelIDs) - 1
        If $ModelID == $BanditModelIDs[$i] Then
            $IsBandit = True
            ExitLoop
        EndIf
    Next
    If Not $IsBandit Then Return False

    Return True
EndFunc