
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
Test_device := class(creative_device):

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=

        var PlayerHealth : float = 100.0
        var PotionDamageAmount:float = 20.0
        var PotionHealAmount:float = 10.0
        MaxHealth : float = 100.0
        MinHealth : float = 1.0
        var PotionType: string = "heal"

        set PlayerHealth = 80.0
        
        # 플레이어가 치유 물약을 마셨을 때 실행할 코드
        # 플레이어가 치유되었을 때 체력이 MaxHealth를 초과하지 않는 경우
        # 최대량을 회복
        if (PotionType = "heal"):
            if ((PlayerHealth + PotionHealAmount) < MaxHealth):
                set PlayerHealth = PlayerHealth + PotionHealAmount
                Print ("Full heal")
            else:
                # 그 외의 경우, PlayerHealth를 MaxHealth로 설정
                set PlayerHealth = MaxHealth
                Print("PlayerHealth too high for full heal")

        # 플레이어가 대미지 물약을 마셨을 때 실행할 코드
        # 플레이어의 체력이 MinHealth를 초과하지만 PotionDamageAmount 미만인 경우 플레이어를 처치하지 않음
        # 플레이어의 체력이 이미 MinHealth 이하인 경우 플레이어를 처치함
        if (PotionType = "damage"):
            if ((PlayerHealth > PotionDamageAmount)):
                set PlayerHealth = PlayerHealth - PotionDamageAmount
                Print("Full damage")
            else if (PlayerHealth > MinHealth):
                # 플레이어의 체력이 낮은 경우 플레이어에게 한 번 더 기회를 줌
                set PlayerHealth = 1.0
                Print("PlayerHealth set to 1.0")
            else:
                set PlayerHealth = 0.0
                Print("Player eliminated!")

        Print("PlayerHealth now {PlayerHealth}")