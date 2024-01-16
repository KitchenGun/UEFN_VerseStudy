using { /Verse.org/Simulation }
using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/UI }


countdown_device:= class(creative_device):
    #uefn 스폰 물체
    @editable
    AddMoreTimeButton : button_device = button_device{}
    @editable
    EndGame : end_game_device = end_game_device{}

    #카운트 다운 매니져
    var CountDownTimer: count_down_manager = count_down_manager{}
    #초기 타이머 값
    InitalCountDownTime :float = 30.0
    # 버튼 활성화 비활성화 체크
    var IsActive : logic = true

    OnBegin<override>()<suspends> : void =
        AddMoreTimeButton.InteractedWithEvent.Subscribe(OnButtonInteractedWith)

        if: # 실패하지 않으면 then을 실행함
            FirstPlayer := Self.GetPlayspace().GetPlayers()[0]
            PlayerUI:=GetPlayerUI[player[FirstPlayer]]
        then:
            set CountDownTimer = count_down_manager{MaybePlayerUI := option{PlayerUI}, RemainingTime := InitalCountDownTime}

            CountDownTimer.StartCountDown()
            #이벤트 호출 전까지 대기
            CountDownTimer.CountdownEndedEvent.Await()
            #게임 종료 처리
            EndGame.Activate(FirstPlayer)

        else :#실패한 경우
            Print("Cant find player")


    #버튼 상호작용 바인드 함수
    OnButtonInteractedWith(Agent:agent) : void = 
        if(IsActive?):
            AddMoreTimeButton.Disable()
            set IsActive = false;
            spawn:
                ButtonCoolTime()
            TimeToAdd : float  = 20.0
            CountDownTimer.AddRemainTimer(TimeToAdd)
        else :#비활성화 되서 호출 안될거임
            Print("CoolTime~")
        
    #버튼 동작 쿨타임 함수
    ButtonCoolTime()<suspends> : void =
        Sleep(2.0)
        AddMoreTimeButton.Enable()
        set IsActive = true;



        
