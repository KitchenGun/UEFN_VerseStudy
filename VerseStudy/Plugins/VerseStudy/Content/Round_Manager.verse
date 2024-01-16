using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }

log_round_timer_device := class(log_channel){}

# 지정된 범위 사이에 값을 허용하는 인티저입니다. 이 타입은 player_ui_slot.ZOrder에 필요합니다.
round_int_clamped := type{_X:int where 0 <= _X, _X <= 2147483647}

# 이 메시지는 라운드 종료 전 남은 시간을 출력하는 데 사용됩니다.
TimeRemainingMessage<localizes>(Minutes:string, Seconds:string):message = "{Minutes}:{Seconds}"

<#
이 클래스에는 라운드 시간을 관리하고 화면에 시간을 표시하기 위한 모든 로직이 포함되어 있습니다.
이 장치를 round_settings_device와 함께 사용하여 실제로 라운드를 종료할 수 있습니다.

이 장치는 타이머를 사용하지 않고 시간을 관리합니다.
이 클래스를 사용하려면 다음 단계를 따릅니다.

    1) 프로젝트에 파일을 추가합니다.

    2) 툴바의 Verse 메뉴에서 Verse 코드를 컴파일합니다.

    3) 콘텐츠 브라우저에 있는 섬의 콘텐츠(Content)/Creative Devices 폴더에서 장치를 섬으로 드래그합니다.

    4) 다음을 통해 또 다른 Verse 스크립트에 waiting_for_more_players 클래스를 추가합니다.

        @editable
        RoundTimer:round_timer = round_timer{}

    5) 툴바의 Verse 메뉴에서 Verse 코드를 컴파일합니다.

    6) 3단계에서 만든 장치를 Verse 장치에 연결합니다.

    7) 다음 Verse로 라운드 타이머를 시작합니다.
        RoundTimer.Start()

    8) 해당 함수로 타이머를 재시작하거나 중지합니다.

    9) 다음을 통해 타이머 시작을 대기합니다.
        RoundTimer.AwaitStart()

    10) 다음을 통해 타이머 완료를 대기합니다.
        RoundTimer.AwaitEnd()
        round_settings_device에서 EndRound 함수를 호출하여 실제로 게임 라운드를 종료합니다.

#>
round_timer := class(creative_device):
   
    @editable # 라운드 지속 시간(분)입니다.
    RoundTimeInMinutes:float = 1.0

    @editable # 화면상 타이머 UI의 수평 및 수직 위치입니다. X 0~1은 왼쪽~오른쪽, Y 0~1은 상단~하단입니다.
    UIPosition:vector2 = vector2{X:= 0.98, Y:=0.13}

    @editable # 화면상 타이머 UI의 수평 및 수직 위치입니다. X 0~1은 왼쪽~오른쪽, Y 0~1은 상단~하단입니다.
    UIAlignment:vector2 = vector2{X := 1.0, Y := 0.0}

    @editable # 다른 UI 엘리먼트와 비교한 UI의 Z 순서입니다.
    UIZOrder:round_int_clamped = 4

    # 라운드가 시작되었을 때 신호를 전송합니다.
    RoundStarted:event() = event(){}

    # 라운드가 종료되려고 할 때 신호를 전송합니다.
    RoundEndedEvent:event() = event(){}

    # 이 맵은 각 플레이어에게 시간을 표시하는 텍스트 박스와 연관되어 있습니다.  
    var TimeRemainingTextBlocks:[player]text_block = map{}

    # 라운드가 완료되기 전 남은 시간으로, 인티저로 표현됩니다.
    var TimeRemainingInSeconds:int = 0

    # 라운드 타이머가 시작될 때까지 대기합니다.
    AwaitStart()<suspends>:void =
        RoundStarted.Await()
        Print("Round timer started.")
  
    # 라운드 타이머를 시작하는 데 사용됩니다.
    Start():void =
        Print("Starting the round timer.")
        RoundStarted.Signal()
        set TimeRemainingInSeconds = GetRoundTimeInSeconds()
        spawn{ Running() }

    # 타이머를 RoundTime으로 재시작합니다.
    Restart():void =
        Print("Restarting the round timer.")
        set TimeRemainingInSeconds = GetRoundTimeInSeconds()

    # 타이머 로직을 실행합니다.
    Running()<suspends>:void =
       Print("Round timer running.")
        loop:
            UpdateTimeUI()
            Sleep(1.0)

            # TimeRemaining을 1초 줄인 다음, 시간이 다 되었는지 확인합니다. 다 되었다면 라운드를 종료합니다.
            set TimeRemainingInSeconds -= 1
            if (TimeRemainingInSeconds < 0):
                Stop()
                break
        
    # 타이머를 중지하고 라운드를 종료합니다.
    Stop():void =
        Print("Ending the round timer.")

        # 씬에 남은 플레이어로부터 플레이어를 얻어 라운드를 종료합니다.
        Players:[]player = GetPlayspace().GetPlayers()
        if (Instigator := Players[0]):
            RoundEndedEvent.Signal()

    # 라운드 타이머가 종료되기 직전까지 대기합니다.
    AwaitEnd()<suspends>:void =
        RoundEndedEvent.Await()
        Print("Round timer ended.")

    # 시간 값을 분 단위로 수락하여 초 단위로 반환합니다.
    GetRoundTimeInSeconds():int =
        var InSeconds:int = 0
        if (set InSeconds = Round[RoundTimeInMinutes * 60.0]) {}
        InSeconds

    # 타이머가 완료되면 남은 시간을 업데이트하고 시간이 만료되었는지 확인합니다.
    UpdateTimeUI():void =

        # Minutes를 나머지 없이 TimeRemainingInSeconds/60으로 설정합니다.
        var Minutes:int = 0
        if (set Minutes = Floor(TimeRemainingInSeconds / 60)) {}

        # Seconds를 TimeRemainingInSeconds/60의 나머지로 설정합니다.
        var Seconds:int = 0
        if (set Seconds = Mod[TimeRemainingInSeconds, 60]) {}

        # Minutes 및 Seconds를 스트링으로 변환합니다.
        MinutesAsString := string("{Minutes}")

        # Seconds가 10 미만인 경우 :#가 아닌 :0#로 표시되도록 값 앞부분에 0을 추가해야 합니다.
        SecondsAsString := if (Seconds < 10) then Join(array{string("{0}"),string("{Seconds}")},string()) else string("{Seconds}")

        # 모든 플레이어를 대상으로 반복작업하고, TimeRemainingTextBlock이 있는지 확인합니다. 없는 경우 하나를 부여합니다. 그런 다음 텍스트를 업데이트합니다.
        Players:[]player = GetPlayspace().GetPlayers()
        for (Player : Players):
            var TextBlock:text_block = text_block{}
            if (set TextBlock = TimeRemainingTextBlocks[Player]) {}
            else:
                set TextBlock = SetUpTimeRemainingUI(Player)
            TextBlock.SetText(TimeRemainingMessage(MinutesAsString, SecondsAsString))

    # 플레이어를 수락한 다음, 화면에 라운드 시간 UI 캔버스를 추가하고 향후 업데이트를 위해 TimeRemainingTextBlock을 저장합니다.
    SetUpTimeRemainingUI(Player:player):text_block =
        Print("Adding round timer UI to a player.")

        # 화면에 남은 시간 텍스트를 출력하는 text_block입니다.
        TextBlock:text_block = text_block:
            DefaultTextColor := NamedColors.White
            DefaultShadowColor := NamedColors.Black
        if (PlayerUI := GetPlayerUI[Player]):
            if (set TimeRemainingTextBlocks[Player] = TextBlock) {}

            # 화면에 text_block을 고정하고 위치를 지정하는 캔버스입니다.
            Canvas := canvas:
                Slots := array:
                    canvas_slot:
                        Anchors := anchors{Minimum := UIPosition, Maximum := UIPosition}
                        Offsets := margin{Top := 0.0, Left := 0.0, Right := 0.0, Bottom := 0.0}
                        Alignment := UIAlignment
                        SizeToContent := true
                        Widget := TextBlock

            # 캔버스를 플레이어에게 할당합니다.
            PlayerUI.AddWidget(Canvas, player_ui_slot{ZOrder := UIZOrder})

        # text_block을 맵에 저장하고 시간이 줄어듦에 따라 향후 업데이트할 수 있도록 text_block이 반환됩니다.
        return TextBlock