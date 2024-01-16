# fill this file with your verse-script
using { /Fortnite.com/Characters }
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/UI }
using { /Verse.org/Colors }
using { /Verse.org/Simulation }
log_team := class(log_channel){}
# 이 클래스는 경험 내 여러 팀에 필요한 장치를 정의합니다.
# 이 클래스는 추상이므로 자체적으로는 사용할 수 없으며, 다른 클래스에서 상속받아야 합니다.
base_team_device := class<abstract>:
    Logger:log = log{Channel:=log_team}
    @editable # 플레이어를 팀에 설정하는 데 사용됩니다.
    ClassSelector:class_and_team_selector_device = class_and_team_selector_device{}
    @editable # 팀의 에이전트에게 점수를 부여하는 데 사용됩니다.
    ScoreManager:score_manager_device = score_manager_device{}
     @editable # 팀 할당 제목을 표시하는 데 사용됩니다.
    TeamTitle:hud_message_device = hud_message_device{}
    @editable # 팀 할당 설명을 표시하는 데 사용됩니다.
    TeamDescription:hud_message_device = hud_message_device{}
    @editable # 팀원(사물 팀) 또는 적(헌터 팀) 처치됨 이벤트를 구독하는 데 사용됩니다.
    TeamManager:team_settings_and_inventory_device = team_settings_and_inventory_device{}
    # 팀의 에이전트 배열입니다.
    var TeamAgents<private>:[]agent = array{}
    # 이 이벤트는 TeamAgents 배열이 빈 상태가 될 때 라운드 종료 신호를 전송받습니다.
   TeamEmptyEvent:event() = event(){}
    # 현재 TeamAgents 배열을 반환합니다.
    # TeamAgents 배열이 프라이빗이므로 다른 클래스에서 직접 액세스할 수 없기 때문에 필요합니다.
    GetAgents()<decides><transacts>:[]agent =
        TeamAgents
    # TeamAgents 배열의 크기를 반환합니다.
    # TeamAgents 배열이 프라이빗이므로 다른 클래스에서 직접 액세스할 수 없기 때문에 함수가 필요합니다.
    Count()<transacts>:int =
        TeamAgents.Length
    # 에이전트의 TeamAgents 배열에 있는 인덱스를 반환하고, 그렇지 않으면 실패합니다.
    FindOnTeam(Agent:agent)<decides><transacts>: int =
        Index := TeamAgents.Find[Agent]
    # 에이전트를 팀에 설정하고 플레이어에게 알립니다.
    InitializeAgent(Agent:agent):void =
        AddAgentToTeam(Agent)
        ClassSelector.ChangeTeamAndClass(Agent)
        DisplayTeamInformation(Agent)
   # TeamAgents에 에이전트를 추가합니다.
    AddAgentToTeam(AgentToAdd:agent):void =
        if (not FindOnTeam[AgentToAdd]):
            Logger.Print("Adding agent to team.")
            set TeamAgents += array{AgentToAdd}
    # HUD 메시지 장치를 활성화하여 플레이어에게 소속 팀을 표시합니다.
    DisplayTeamInformation(Agent:agent):void =
        TeamTitle.Show(Agent)
        TeamDescription.Show(Agent)
    # 에이전트가 매치에서 나갈 때 TeamAgents 배열에서 에이전트를 제거하고 라운드 종료를 확인합니다.
    EliminateAgent(Agent:agent)<suspends>:void =
        Sleep(0.0) # 게임 틱 1틱을 딜레이하여 진행 전에 플레이어가 부활되도록 합니다.
        RemoveAgentFromTeam(Agent)
    # TeamAgents에서 에이전트를 제거합니다.
    # 제거된 에이전트가 마지막 남은 에이전트였다면 TeamEmptyEvent에 신호를 전송합니다.
    RemoveAgentFromTeam(AgentToRemove:agent):void =
        set TeamAgents = TeamAgents.RemoveAllElements(AgentToRemove)
        Logger.Print("{Count()} agent(s) on team remaining.")
        if (Count() < 1):
            Logger.Print("No agents on team remaining. Ending the round.")
            TeamEmptyEvent.Signal()

    #https://dev.epicgames.com/documentation/ko-kr/uefn/verse-prop-hunt-template-4-setting-up-teams-and-classes-in-unreal-editor-for-fortnite