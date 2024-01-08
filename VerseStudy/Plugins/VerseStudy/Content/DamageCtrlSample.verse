# fill this file with your verse-script
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Playspaces }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /Verse.org/Verse }

DamageCtrlSample := class(creative_device):

    # 게임 실행 중 장치가 시작되면 실행됩니다
    OnBegin<override>()<suspends>:void=
        Sleep(5.0)
        HurtPlayer(GetRandomFloat(1.0,99.0));
        Sleep(5.0)
        HurtPlayer(GetRandomFloat(1.0,99.0));
        Sleep(3.0)
        HealPlayer(GetRandomFloat(1.0,99.0))

    HurtPlayer(DamageAmount : float) : void =
        #get world와 유사한 플레이 공간 접근
        Playspace: fort_playspace = GetPlayspace()
        # 모든 플레이어 정보 가져오기
        AllPlayers: []player = Playspace.GetPlayers()
        #첫번째 플레이어에게 데미지 주기
        if (FirstPlayer : player = AllPlayers[0]):
            if (FortniteCharacter : fort_character = FirstPlayer.GetFortCharacter[]):
                health:=FortniteCharacter.GetHealth()
                DamageToDo : float = CalculateDamage(health,DamageAmount)
                Print("current DamageToDo : {DamageToDo}")
                FortniteCharacter.Damage(DamageToDo)

    HealPlayer(Healamount : float) : void =
        #get world와 유사한 플레이 공간 접근
        Playspace: fort_playspace = GetPlayspace()
        # 모든 플레이어 정보 가져오기
        AllPlayers: []player = Playspace.GetPlayers()
        #첫번째 플레이어에게 데미지 주기
        if (FirstPlayer : player = AllPlayers[0]):
            if (FortniteCharacter : fort_character = FirstPlayer.GetFortCharacter[]):
                health:=FortniteCharacter.GetHealth()
                FortniteCharacter.Heal(CalculateHeal(health,Healamount))
                Print("current hp{FortniteCharacter.GetHealth()}")


    CalculateDamage(TargetHealth : float,DamageAmount : float) : float = 
        MinHealth : float = 1.0
        #받을 데미지가져오기 
        PotionDamageAmount: float = DamageAmount
        #목표의 체력을 가져오기
        var PlayerHealth : float = TargetHealth

        # 대미지 양에 의해 플레이어가 죽지 않는 경우 해당 대미지를 플레이어에게 적용
        if (PlayerHealth > PotionDamageAmount):
            return PotionDamageAmount
        else if (PlayerHealth > MinHealth):
            # 플레이어의 체력이 낮은 경우 플레이어에게 한 번 더 기회를 줌
            return PlayerHealth - MinHealth
        else:
            # 플레이어 사망
            return PlayerHealth

    CalculateHeal(TargetHealth:float,Healamount:float):float =
        MaxHealth := 100.0
        #최대 체력
        if((TargetHealth+Healamount)>MaxHealth):
            return MaxHealth
        else:
            return TargetHealth + Healamount
