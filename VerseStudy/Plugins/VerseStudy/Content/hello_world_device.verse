
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }

# A Verse-authored creative device that can be placed in a level
hello_world_device := class(creative_device):

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        # TODO: Replace this with your code
        Print("Hello, world!")
        Print("2 + 2 = {2 + 2}")
        Print("StrangeGame...")
        Print("🐈💗🐟 = {"🐈💗🐟"}")
        var cat : string = "🐈"
        fish : string ="🐟"
        Print("cat find fish")
        
        set cat = <# 고양이가 생선을 찾음#>cat+fish
        Print(cat)#dfdfd
        var IsCatGetAFish : logic = false
        if (cat="🐈🐟"):
            Print("yeeeeeeeeeeeeees")
        else: 
            Print("nope")