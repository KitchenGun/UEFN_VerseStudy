
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }




ball_spawner_control_device := class(creative_device):

    @editable
    

    OnBegin<override>()<suspends>:void=

        Print("Hello, world!")
        Print("2 + 2 = {2 + 2}")