using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }

log_waiting_for_more_players_device := class(log_channel){}

# 지정된 범위 사이에 값을 허용하는 인티저입니다. 이 타입은 player_ui_slot.ZOrder에 필요합니다.
waiting_int_clamped := type{_X:int where 0 <= _X, _X <= 2147483647}

# 이 메시지는 라운드를 시작할 수 있기까지 필요한 플레이어 수를 출력하는 데 사용됩니다.
WaitingForMorePlayersMessage<localizes>(Count:int):message = "Waiting for {Count} more Player(s)"

# 이 클래스는 라운드를 시작하는 데 필요한 플레이어 수를 표시하는 용도입니다.
waiting_for_more_players_ui := class:
    var Canvas:canvas
    var TextBlock:text_block
<#
이 클래스에는 최소 플레이어 수를 설정하고 라운드를 시작하기에 충분한지 확인하기 위한 모든 로직이 포함되어 있습니다.
이 클래스를 사용하려면 다음 단계를 따릅니다.
    1) 프로젝트에 파일을 추가합니다.

    2) 툴바의 Verse 메뉴에서 Verse 코드를 컴파일합니다.

    3) 콘텐츠 브라우저에 있는 섬의 콘텐츠(Content)/Creative Devices 폴더에서 장치를 섬으로 드래그합니다.

    4) 타이머 장치를 이 장치의 'WaitingForMorePlayersTimer' 프로퍼티에 연결합니다.

    5) 다음을 통해 또 다른 Verse 스크립트에 waiting_for_more_players 클래스를 추가합니다.
        @editable
        WaitingForMorePlayers:waiting_for_more_players = waiting_for_more_players{}

    6) 툴바의 Verse 메뉴에서 Verse 코드를 컴파일합니다.

    7) 3단계에서 만든 장치를 6단계에서 노출한 Verse 장치 및 프로퍼티에 연결합니다.

    8) 플레이어에 전달하여 CheckForMinimumNumberOfPlayers 함수를 대기합니다. 예시는 다음과 같습니다.
        Players = GetPlayspace().GetPlayers()
        CheckForMinimumNumberOfPlayers(Players)

    9) IslandSettings에서 게임 시작 카운트다운을 0.0으로 설정합니다.
#>
waiting_for_more_players := class(creative_device):
    Logger:log = log{Channel:=log_waiting_for_more_players_device}

    @editable # 라운드를 시작하기 위해 매치에 필요한 최소 플레이어 수입니다.
    MinimumNumberOfPlayers:int = 2

    @editable # 화면상 타이머 UI의 수평 및 수직 위치입니다. X 0~1은 왼쪽~오른쪽, Y 0~1은 상단~하단입니다.
    UIPosition:vector2 = vector2{X:= 0.5, Y:=0.4}

    @editable # 화면상 타이머 UI의 수평 및 수직 위치입니다. X 0~1은 왼쪽~오른쪽, Y 0~1은 상단~하단입니다.
    UIAlignment:vector2 = vector2{X := 0.5, Y := 0.5}

    @editable # 다른 UI 엘리먼트와 비교한 UI의 Z 순서입니다.
    UIZOrder:waiting_int_clamped = 3

    @editable # 이 타이머는 플레이어가 매치에 참가하기를 기다린 후 라운드 시작까지 카운트다운하는 데 사용됩니다.
    WaitingForMorePlayersTimer:timer_device = timer_device{}
 
   # 이 맵은 라운드를 시작하는 데 필요한 플레이어 수를 표시하기 위한 UI 캔버스를 각 플레이어에게 연결합니다.
    var WaitingForMorePlayersUI:[player]?waiting_for_more_players_ui = map{}
  
  # 라운드를 시작하기에 충분한 수의 플레이어가 있는지 확인합니다. 없는 경우 플레이어 수가 MinimumNumberOfPlayers보다 크거나 같아질 때까지 대기합니다.
    WaitForMinimumNumberOfPlayers(Players:[]player)<suspends>:[]player =
        Logger.Print("Waiting if there are enough players for the round to start.")
        # 더 많은 플레이어가 참가하면 수정할 수 있도록 새 변수를 생성합니다. 함수에 전달된 플레이어 배열로 초기화합니다.
        var PlayersWaiting:[]player = Players
        # 플레이어 수가 라운드를 시작하는 데 필요한 최솟값 미만인 경우...
        if (PlayersWaiting.Length < MinimumNumberOfPlayers):
            loop: # 플레이어 수가 필요한 최솟값보다 크거나 같아질 때까지 루프합니다.
                Logger.Print("{PlayersWaiting.Length}/{MinimumNumberOfPlayers} players needed for the round to start.")
                # '더 많은 플레이어 기다리는 중(Waiting for more players)' UI를 업데이트합니다.
                DisplayWaitingForMorePlayers(PlayersWaiting)
                Sleep(2.0) # 더 많은 플레이어가 매치에 참가하는지 확인하기 위해 대기한 다음, 라운드를 시작하기에 충분한 수의 플레이어가 있는지 확인합니다.
                set PlayersWaiting = GetPlayspace().GetPlayers()
                if (PlayersWaiting.Length >= MinimumNumberOfPlayers):
                    # 이제 플레이어가 충분하다면 '더 많은 플레이어 기다리는 중' UI를 지웁니다.
                    Logger.Print("{PlayersWaiting.Length}/{MinimumNumberOfPlayers} players in round, preparing for round start.")
                    ClearWaitingForMorePlayers()
                    # 그런 다음 루프를 중단합니다.
                    break
        # 라운드 시작 카운트다운을 시작하고, 카운트다운이 완료될 때까지 대기합니다.
        WaitingForMorePlayersTimer.Start()
        WaitingForMorePlayersTimer.SuccessEvent.Await()
        Logger.Print("Starting round.")
        # 세션 내 플레이어 목록을 반환합니다.
        return PlayersWaiting
   
 # 각 플레이어에게 '더 많은 플레이어 기다리는 중' UI 메시지가 없는 경우 해당 메시지를 표시합니다. 모든 플레이어의 플레이어 카운터를 업데이트합니다.
    DisplayWaitingForMorePlayers(Players:[]player):void =
        PlayersNeededCount := MinimumNumberOfPlayers - Players.Length
        Logger.Print("{Players.Length} players in round, waiting for {PlayersNeededCount} more player(s) to join.")
        for (Player: Players):
       
     # 플레이어에게 WaitingForMorePlayersUI가 있는 경우 라운드를 시작하는 데 필요한 올바른 플레이어 수를 표시하도록 TextBlock을 얻고 텍스트를 새로고침합니다.
            if (UIData := WaitingForMorePlayersUI[Player]?):
                UIData.TextBlock.SetText(WaitingForMorePlayersMessage(PlayersNeededCount))
            # 그렇지 않으면 플레이어에게 WaitingForMorePlayersUI를 생성합니다.
            else:
                SetUpWaitingForMorePlayersUI(Player, PlayersNeededCount)
     
  # 플레이어 및 player_ui를 수락하여 화면에 '더 많은 플레이어 기다리는 중' UI 캔버스를 추가합니다.
    SetUpWaitingForMorePlayersUI(Player:player, PlayersNeededCount:int):void =
        Logger.Print("Creating 'waiting for more players' UI.")
        if (PlayerUI := GetPlayerUI[Player]):
            # 화면에 '더 많은 플레이어 기다리는 중' 텍스트를 출력하는 text_block입니다.
            TextBlock:text_block = text_block:
                DefaultText := WaitingForMorePlayersMessage(PlayersNeededCount)
                DefaultTextColor := NamedColors.White
                DefaultShadowColor := NamedColors.Black
          
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
            # 더 많은 플레이어가 게임에 참가하면 나중에 텍스트를 업데이트할 수 있도록 text_block을 맵에 저장합니다.
            if (set WaitingForMorePlayersUI[Player] = option{ waiting_for_more_players_ui{Canvas := Canvas, TextBlock := TextBlock} }) {}
  
  # '더 많은 플레이어 기다리는 중' UI 메시지가 있는 각 플레이어로부터 해당 메시지를 제거합니다.
    ClearWaitingForMorePlayers():void =
        Logger.Print("Clearing 'waiting for more players' UI.")
        for (Player -> UIData : WaitingForMorePlayersUI):
            if:
                PlayerUI := GetPlayerUI[Player]
                Canvas := UIData?.Canvas
                set WaitingForMorePlayersUI[Player] = false
            then:
                PlayerUI.RemoveWidget(Canvas)