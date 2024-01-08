
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }

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
        
        #var temp: = "string"   자료형을 지정하지 않으면 선언이 안됨

        set cat = <# 고양이가 생선을 찾음#>cat+fish
        Print(cat)#dfdfd
        var IsCatGetAFish : logic = false
        if (cat="🐈🐟"):
            Print("yeeeeeeeeeeeeees")
            set IsCatGetAFish = true
        else: 
            Print("nope")
            set IsCatGetAFish = false

        if(IsCatGetAFish?):
            Print("yeeeeeeeeeeeeees")
        else:
            Print("nope")

        temp1 : float = 1.53000011434343
        var temp2 : float = 1.5300001123123
        
        Print("{temp1}")
        Print("{temp2}")
        if (temp1=temp2):
            Print("yeeeeeeeeeeeeees")
        else:
            Print("nope")

        Print("{temp1-temp2}")

        if (temp1>1.53 or temp2>1.53):
            Print("큼")
        else:
            Print("작은거 있음")

        # 로그에 Coins의 현재 값(500)을 출력합니다.
        Print("Coins : {Coins}.")
        for(X := 0..2):
            BuyMousetrap()
        

    # 함수 호출
    # Coins를 500으로 초기화합니다. 변수로 선언하므로 나중에 값을 변경할 수 있습니다.
    var Coins : int = 500
    
    


    BuyMousetrap() : void =
        # CoinsPerMousetrap을 1~100 사이의 랜덤 integer로 초기화합니다.
        CoinsPerMousetrap : int = GetNumberOfMousetrapsYouCanAfford()
            
        # Coins를 CoinsPerMousetrap만큼 감소하고, 로그에 새 값을 출력합니다.
        set Coins = Coins - CoinsPerMousetrap
        Print("After buying one mousetrap, Coins is {Coins}.") 
        
    GetNumberOfMousetrapsYouCanAfford() : int =
        var afford : int = GetRandomInt(1, 100)
        Print("{afford}")
        return afford
    
        

   

        
            
                


        

            