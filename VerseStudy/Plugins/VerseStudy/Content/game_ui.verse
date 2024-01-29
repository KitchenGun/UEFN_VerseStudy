using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Simulation }

MakeGameUI<constructor><public>(InPlayer : agent) := game_ui:
    MaybePlayer := option{InPlayer}
    MaybePlayerUI := option{GetPlayerUI[player[InPlayer]]} 

game_ui := class():
    var MyCanvas<internal> : canvas = canvas{}
    LapsCountWidget<internal> : button_loud = button_loud{}

    MaybePlayer<internal> : ?agent = false
    MaybePlayerUI<internal> : ?player_ui = false
    
    LapsText<localizes>(NbLaps : int) : message = "Laps {NbLaps} of 10"
    LapsTextDefaut<localizes>() : message = "No Lap !"
    var TotalLaps<private> : int = 0

    block: 
        set MyCanvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors{Minimum := vector2{X := 0.5, Y := 0.0}, Maximum := vector2{X := 0.5, Y := 0.0}}
                    Offsets := margin{Top := 100.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                    Alignment := vector2{X := 0.5, Y := 0.5}
                    SizeToContent := true
                    Widget := LapsCountWidget

    UpdateInitialUI<private>(): void =
        if (PlayerUI := MaybePlayerUI?):
            LapsCountWidget.SetText(LapsTextDefaut())

    UpdateUI<private>(): void =
        if (PlayerUI := MaybePlayerUI?):
            LapsCountWidget.SetText(LapsText(TotalLaps))

    RemoveAddGameUIToUI<public>() : void =
        Print("Just before add UI")
        if (PlayerUI := MaybePlayerUI?):
            Print("Adding UI")
            PlayerUI.AddWidget(MyCanvas)
            Print("Initial Message")
            UpdateInitialUI()

    RefreshGameUI<public>(Points : int): void =
        Print("Just before refresh UI")
        if (PlayerUI := MaybePlayerUI?):
            Print("Adding UI")
            PlayerUI.AddWidget(MyCanvas)
            Print("Set Total Points")
            set TotalLaps = Points
            Print("Number of Points: {Points}")
            UpdateUI()