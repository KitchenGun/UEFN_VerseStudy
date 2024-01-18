using { /UnrealEngine.com/Temporary/UI }
using { /Fortnite.com/UI }
using { /Fortnite.com/Devices }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/SpatialMath}
 using { /UnrealEngine.com/Temporary/UI }
 using { /Fortnite.com/Devices }
 using { /Fortnite.com/UI }
 using { /Verse.org/Colors }
 using { /Verse.org/Simulation }

 MakeScoreManager<constructor><public>(InPlayer : agent, InScoreManagerDevice : score_manager_device) := score_manager:
     MaybePlayer := option{InPlayer}
     MaybePlayerUI := option{GetPlayerUI[player[InPlayer]]} 

 score_manager := class:
     <# 점수 관리자의 수명 동안 캔버스를 재생성하지 않을 것이므로, 이 타입의 오브젝트가 생성될 때 한 번만 수행합니다. #>
     block:
         set Canvas = canvas:
             Slots := array:
                 canvas_slot:
                     Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.25}, Maximum := vector2{X := 0.0, Y := 0.25} }
                     Offsets := margin{Top := 0.0, Left := 25.0, Right := 0.0, Bottom := 0.0}
                     Alignment := vector2{X := 0.0, Y := 0.0}
                     SizeToContent := true
                     Widget := stack_box:
                         Orientation := orientation.Vertical
                         Slots := array:
                             stack_box_slot:
                                 HorizontalAlignment := horizontal_alignment.Left
                                 Widget := TotalGameScoreWidget
                             stack_box_slot:
                                 HorizontalAlignment := horizontal_alignment.Left
                                 Widget := PendingScoreWidget
                             stack_box_slot:
                                 HorizontalAlignment := horizontal_alignment.Left
                                 Widget := PickupLevelWidget

     AddScoreManagerToUI<public>() : void =
         if (PlayerUI := MaybePlayerUI?):
             PlayerUI.AddWidget(Canvas)

             UpdateUI()

     <# TotalPickupPoints에 PendingPickupPoints를 더하고 PendingPickupPoints를 0으로 리셋합니다.
     더해진 픽업 점수의 총점을 반환합니다. #>
     AddPendingScoreToTotalScore<public>() : int =
         set TotalGameScore += PendingScore
         defer:
             set PendingScore = 0
             UpdateUI()
         return PendingScore

     <# 주어진 점수를 획득 예정 점수에 더합니다. #>
     UpdatePendingScore<public>(Points : int) : void =
         set PendingScore += Points
         UpdateUI()
        
     UpdatePickupLevel<public>(Level : int) : void=
         set PickupLevel = Level
         UpdateUI()

     <# 이 함수는 점수 관리자 장치를 활성화하여 플레이어에게 점수를 부여합니다. #>
     AwardScore<public>() : void =
         ScoreManagerDevice.SetScoreAward(TotalGameScore)
         if (AwardedPlayer := MaybePlayer?):
             ScoreManagerDevice.Activate(AwardedPlayer)
                
     MaybePlayer<internal> : ?agent = false
     MaybePlayerUI<internal> : ?player_ui = false
     ScoreManagerDevice<internal> : score_manager_device = score_manager_device{}
     var Canvas<internal> : canvas = canvas{}
     TotalGameScoreWidget<internal> : text_block = text_block{DefaultTextColor := NamedColors.White}
     PendingScoreWidget<internal> : text_block = text_block{DefaultTextColor := NamedColors.White}
     PickupLevelWidget<internal> : text_block = text_block{DefaultTextColor := NamedColors.White}        
     PickupLevelText<localizes><internal>(CurrentPickupLevel : int) : message = "Pickup Level: {CurrentPickupLevel}"
     PendingScoreText<localizes><internal>(CurrentPendingScore : int) : message = "Pending Points: {CurrentPendingScore}"
     TotalGameScoreText<localizes><internal>(CurrentTotalGameScore : int) : message = "Total Points: {CurrentTotalGameScore}"

     var TotalGameScore<private> : int = 0
     var PendingScore<private>:int = 0
     var PickupLevel<private>:int = 0

     UpdateUI<private>() : void =
         if (PlayerUI := MaybePlayerUI?):
             PickupLevelWidget.SetText(PickupLevelText(PickupLevel))
             PendingScoreWidget.SetText(PendingScoreText(PendingScore))
             PendingScoreWidget.SetText(TotalGameScoreText(TotalGameScore))

#https://dev.epicgames.com/documentation/ko-kr/uefn/pizza-pursuit-4-managing-and-displaying-the-score-in-verse
#해당 강좌 바탕으로 제작
<#
MakeScoreManager<constructor><public>(InPlayer : agent, InScoreManagerDevice : score_manager_device) := score_manager:
    MaybePlayer := option{InPlayer}
    MaybePlayerUI := option{GetPlayerUI[player[InPlayer]]}
    
score_manager := class:
    block:
        set Canvas = canvas:
        Slots := array:
            canvas_slot:
                Anchors := anchors{Minimum := vector2{X := 0.0, Y := 0.25}, Maximum := vector2{X := 0.0, Y := 0.25} }
                Offsets := margin{Top := 0.0, Left := 25.0, Right := 0.0, Bottom := 0.0}
                Alignment := vector2{X := 0.0, Y := 0.0}
                SizeToContent := true
                Widget := stack_box:
                    Orientation := orientation.Vertical
                    Slots := array:
                        stack_box_slot:
                            HorizontalAlignment := horizontal_alignment.Left
                            Widget := LapInfoWidget
                        stack_box_slot:
                            HorizontalAlignment := horizontal_alignment.Left
                            Widget := KillScoreWidget
                        stack_box_slot:
                            HorizontalAlignment := horizontal_alignment.Left
                            Widget := DeadScoreWidget

    #UI
    var Canvas<internal> : canvas = canvas{}
    LapInfoWidget<internal> : text_block = text_block{DefaultTextColor := NamedColors.White}
    KillScoreWidget<internal> : text_block = text_block{}
    DeadScoreWidget<internal> : text_block = text_block{}   
    
    #Variables
    MaybePlayer<internal> : ?agent = false
    MaybePlayerUI<internal> : ?player_ui = false
    ScoreManagerDevice<internal> :score_manager_device = score_manager_device{}

    #Widgets
    var LapCount<private> : int = 0
    var LapMaxCount<private> : int = 3
    var KillScore<private> : int = 0
    var DeadScore<private> : int = 0
                            
                            
    #Events
    UpdateUI<private>() : void =
        if (PlayerUI := MaybePlayerUI?):
            LapInfoWidget.SetText(LapInfoText(LapCount, LapMaxCount))
            KillScoreWidget.SetText(KillScoreText(KillScore))
            DeadScoreWidget.SetText(DeadScoreText(DeadScore))
            Print("3")
    #점수를 업데이트 하고 UI를 업데이트 합니다.
    AddScoreManagerToUI<public>() : void =
        Print("1")
        if (PlayerUI := MaybePlayerUI?):
            PlayerUI.AddWidget(Canvas)
            UpdateUI()
            Print("2")
    
    #각 점수 업데이트
    UpdateLapCount<public>(NewLapCount : int, NewLapMaxCount : int) : void =
        set LapCount = NewLapCount
        set LapMaxCount = NewLapMaxCount
        UpdateUI()
    UpdateKillScore<public>(NewKillScore : int) : void =
        set KillScore = NewKillScore
        UpdateUI()
    UpdateDeadScore<public>(NewDeadScore : int) : void =    
        set DeadScore = NewDeadScore
        UpdateUI()
 #>
      <# 이 함수는 점수 관리자 장치를 활성화하여 플레이어에게 점수를 부여합니다. #>
    <#
      AwardScore<public>() : void =
        ScoreManagerDevice.SetScoreAward(LapCount)
        if (AwardedPlayer := MaybePlayer?):
            ScoreManagerDevice.Activate(AwardedPlayer)
    

    LapInfoText<localizes>(CurrentLap : int,MaxLap : int) : message = "Lap: {CurrentLap} / {MaxLap}"
    
    KillScoreText<localizes>(CurrentKill : int) : message = "Kills: {KillScore}"
    
    DeadScoreText<localizes>(CurrentDead : int) : message = "Deaths: {DeadScore}"
    #>

