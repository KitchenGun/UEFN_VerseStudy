# fill this file with your verse-script
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Playspaces }
using { /Verse.org/Simulation }
using { /Verse.org/Verse }

DamageCtrlSample := class(creative_device):

    # 게임 실행 중 장치가 시작되면 실행됩니다
    OnBegin<override>()<suspends>:void=
        #get world와 유사한 플레이 공간 접근
        Playspace: fort_playspace = GetPlayspace()
        # 모든 플레이어 정보 가져오기
        AllPlayers: []player = Playspace.GetPlayers()
        #첫번째 플레이어에게 데미지 주기
        if (FirstPlayer : player = AllPlayers[0]):
            if (FortniteCharacter : fort_character = FirstPlayer.GetFortCharacter[]):
                FortniteCharacter.Damage(50.0)