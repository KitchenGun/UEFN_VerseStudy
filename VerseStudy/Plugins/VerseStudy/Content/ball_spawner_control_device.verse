
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }




ball_spawner_control_device := class(creative_device):

    @editable
    Spawner:ball_spawner_device =ball_spawner_device {}

    OnBegin<override>()<suspends>:void=
        loop:
            Sleep(0.1)
            ShowBallPos()



    ShowBallPos():void=
        Print("")
        #{Spawner.creative_device.Ball.Position}
