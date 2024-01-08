# fill this file with your verse-script
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Playspaces }
using { /Verse.org/Simulation }
using { /Verse.org/Verse }

DamageCtrlSample := class(creative_device):

    # 게임 실행 중 장치가 시작되면 실행됩니다
    OnBegin<override>()<suspends>:void=
        HurtPlayer();
        Sleep(5.0)
        HurtPlayer();
        Sleep(3.0)
        HealPlayer()

    HurtPlayer() : void =
        #get world와 유사한 플레이 공간 접근
        Playspace: fort_playspace = GetPlayspace()
        # 모든 플레이어 정보 가져오기
        AllPlayers: []player = Playspace.GetPlayers()
        #첫번째 플레이어에게 데미지 주기
        if (FirstPlayer : player = AllPlayers[0]):
            if (FortniteCharacter : fort_character = FirstPlayer.GetFortCharacter[]):
                health:=FortniteCharacter.GetHealth()
                DamageToDo : float = CalculateDamage(health)
                Print("{health}")
                FortniteCharacter.Damage(DamageToDo)

    HealPlayer() : void =
        #get world와 유사한 플레이 공간 접근
        Playspace: fort_playspace = GetPlayspace()
        # 모든 플레이어 정보 가져오기
        AllPlayers: []player = Playspace.GetPlayers()
        #첫번째 플레이어에게 데미지 주기
        if (FirstPlayer : player = AllPlayers[0]):
            if (FortniteCharacter : fort_character = FirstPlayer.GetFortCharacter[]):
                health:=FortniteCharacter.GetHealth()
                FortniteCharacter.Heal(20.0)
                Print("{health}")


    CalculateDamage(Target : float) : float = 
        MinHealth : float = 1.0
        PotionDamageAmount: float = 80.0
        var PlayerHealth : float =Target

        # 대미지 양에 의해 플레이어가 죽지 않는 경우 해당 대미지를 플레이어에게 적용
        if (PlayerHealth > PotionDamageAmount):
            return PotionDamageAmount
        else if (PlayerHealth > MinHealth):
            # 플레이어의 체력이 낮은 경우 플레이어에게 한 번 더 기회를 줌
            return PlayerHealth - MinHealth
        else:
            # 플레이어 사망
            return PlayerHealth