using { /UnrealEngine.com/Temporary/UI }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /Fortnite.com/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }


count_down_manager := class:
    #카운트다운 종료 이벤트
    CountdownEndedEvent : event() = event(){}
    # 플레이어 UI 옵션 MaybePlayerUI 를 추가하고 false 로 초기화합니다.
    MaybePlayerUI : ? player_ui = false
    # 플로트 변수 RemainingTime 을 추가하고 0.0 으로 초기화합니다.
    var RemainingTime : float = 0.0
    var Canvas : canvas = canvas{}
    # 텍스트 위젯 RemainingTimeWidget 을 추가하고 디폴트 텍스트 색상을 흰색으로 설정합니다.
    RemainingTimeWidget : text_block = text_block{DefaultTextColor := NamedColors.White}
    # 남은 시간 출력
    RemainingTimeText<localizes>(CurrentRemainingTime : int) : message = "{CurrentRemainingTime}"
    # 시간 추가 위젯
    AddedTimeWidget : text_block = text_block{DefaultTextColor := NamedColors.White} 
    # 추가 시간 출력
    AddedTimeText<localizes>(AddedTime : int) : message = " +{AddedTime}!"
    # block 표현식을 추가해 화면 상단 중앙에 시간을 표시하는 UI를 생성합니다. 클래스 정의의 block 표현식은 해당 클래스가 인스턴스화될 때만 실행되므로 이 block 표현식에 들어가면 UI를 생성할 수 있습니다.
    block:
        set Canvas = canvas:
            Slots := array:
                canvas_slot:
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.05}
                        Maximum := vector2{X := 0.5, Y := 0.05}
                    Alignment := vector2{X := 0.5, Y := 0.0}
                    Offsets := margin{Top := 0.0, Left := 50.0, Bottom := 0.0, Right := 0.0}
                    SizeToContent := true
                    Widget := AddedTimeWidget
                canvas_slot:
                    Anchors := anchors:
                        Minimum := vector2{X := 0.5, Y := 0.05}
                        Maximum := vector2{X := 0.5, Y := 0.05}
                    Alignment := vector2{X := 0.5, Y := 0.0}
                    Offsets := margin{Top := 25.0, Left := 0.0, Bottom := 0.0, Right := 0.0}
                    SizeToContent := true
                    Widget := RemainingTimeWidget
                    
    StartCountDown() : void =
        Print("Start count down")
        #canvas 추가
        if(PlayerUI := MaybePlayerUI?):
            PlayerUI.AddWidget(Canvas)
            #타이머가 시작했을때 UI 업데이트해서 시간 표시
            UpdateUI()
            spawn:
                RunCountdown()
                
    
    #추가 시간 호출 함수
    AddTimeCallout(Time : float) <suspends> : void =
        if:
            PlayerUI := MaybePlayerUI?
            IntTime:= Int[Time]
        then:
            AddedTimeWidget.SetVisibility(widget_visibility.Visible)
            AddedTimeWidget.SetText(AddedTimeText(IntTime))
            Sleep(2.0)
            AddedTimeWidget.SetVisibility(widget_visibility.Hidden)
            

    # 시간 추가 함수
    AddRemainTimer(Time : float) : void =
        set RemainingTime+=Time
        # 시간 추가시 UI 업데이트용
        UpdateUI()
         # 추가된 시간을 표시하는 간단한 콜아웃을 호출합니다.
        spawn:
            AddTimeCallout(Time)

    #시간 틱 마다 깎는 함수
    RunCountdown()<suspends> : void = 
        loop:
            Sleep(1.0)
            set RemainingTime-=1.0;
            #ui 업데이트
            UpdateUI();
            # 타이머 종료
            if (RemainingTime < 0.0):
                if (PlayerUI := MaybePlayerUI?):
                    PlayerUI.RemoveWidget(Canvas)
                #시간 종료시 종료 이벤트 투척
                CountdownEndedEvent.Signal()
                break
    # UI 업데이트 함수
    UpdateUI() : void = 
        if(IntTime := Int[RemainingTime]):
            RemainingTimeWidget.SetText(RemainingTimeText(IntTime))
    


    
    
    