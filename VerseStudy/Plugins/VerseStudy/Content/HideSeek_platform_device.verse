
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Assets }
using { /Fortnite.com/Characters }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
HideSeek_platform_device := class(creative_device):

    @editable
    ToggleDelay : float = 3.0 # 사라지는거 대기할 시간
    @editable
    var StartPos : transform = transform{}
    @editable
    var HidePos : transform = transform{}
    @editable
    Platform : color_changing_tiles_device  = color_changing_tiles_device {}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=

        set StartPos = Platform.GetTransform()
        set HidePos = Platform.GetTransform()
        #var addPos:vector3 = vector3{0,100,0}
        #set HidePos.Translation = HidePos.Translation + addPos


        loop:
            Sleep(ToggleDelay) #ToggleDelay 시간만큼 대기
            Platform.MoveTo(HidePos,10.0) #플랫폼 사라짐
            Sleep(ToggleDelay) #ToggleDelay 시간만큼 대기
            Platform.MoveTo(StartPos,10.0) # 나타남
    
    