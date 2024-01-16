using { /Fortnite.com/Devices }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /Verse.org/Simulation }


DanceBomb_Characterclass := class<concrete>(base_team_device):

    # 에이전트를 DanceBomb 에이전트로 설정합니다.
    InitializeAgent<override>(NewDanceBombAgent:agent):void =
        Logger.Print("Setting a DanceBomb")
        (super:)InitializeAgent(NewDanceBombAgent)

    # 에이전트가 매치에서 나갈 때 DanceBombAgents 배열에서 에이전트를 제거하고 확인합니다.
    EliminateAgent<override>(DanceBombAgents:agent)<suspends>:void =
    #   Logger.Print("DanceBombAgents agent eliminated.")
        (super:)EliminateAgent(DanceBombAgents)



