
using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }


team_multiplayer_balancing := class(creative_device):
    #팀 갯수
    var Teams : []team = array{}

    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=

        GetPlayspace().PlayerAddedEvent().Subscribe(OnPlayerAdded)
        Print("Beginning to balance teams")
        BalanceTeams()
    
    FindSmallestTeam(CurrentTeamSize : int) : ?team=
        var SmallestTeam : ?team = false
        var TeamSize : int = CurrentTeamSize
        #가장 인원수가 적은 팀을 찾아냄  
        #필터링 조건이 성공할때만 내부 코드 실행
        for(Team : Teams,CandidateTeamSize := GetPlayspace().GetTeamCollection().GetAgents[Team].Length,TeamSize>CandidateTeamSize):
            #team순회 하고 CandidateTeamSize에 플레이어 인원수를 가져옴 인원수가 적은경우 해당 팀을 가장 적은 팀으로 설정
            set SmallestTeam = option{Team}
            set TeamSize = CandidateTeamSize
            Print("Found a team with less players: {CandidateTeamSize}") 
        return SmallestTeam

     <#
        각 플레이어에 대해 해당 플레이어가 속한 팀의 플레이어 수를 구합니다. 팀 목록을 순회하며 반복작업하여
        플레이어 수가 가장 적은 팀에 플레이어를 배정하거나
        같은 순위인 경우 기존 팀을 유지합니다.
    #>

    BalanceTeams() : void =
        AllPlayers:=GetPlayspace().GetPlayers()
        for(TeamPlayer:AllPlayers,CurrentTeam:=GetPlayspace().GetTeamCollection().GetTeam[TeamPlayer]):
            #팀밸런스가 맞지 않으면 플레이어들을 새로운 팀에 배정합니다
            var TeamSize : int = 0
            if(set TeamSize = GetPlayspace().GetTeamCollection().GetAgents[CurrentTeam].Length):
                #팀크기가 없으면 메세지 출력
            SmallestTeam : ?team = FindSmallestTeam(TeamSize)
            #플레이어가 가장 적은 팀이면 패스 아니면 새팀에 배정해야함
            #옵션을 실행인자로 직접 전달하는 것을 허용하지 않는 메서드때 아래와 같이 사용해야함
            if(TeamToAssign := SmallestTeam?,GetPlayspace().GetTeamCollection().AddToTeam[TeamPlayer,TeamToAssign]):
                Print("Attempting to assign player to a new team")
            
    
    # 게임에 참가하는 새 플레이어를 처리합니다
    OnPlayerAdded(InPlayer : player) : void =
        Print("A new Player joined, assigning them to a team!")
        Print("{GetPlayspace().GetPlayers().Length}")
        BalanceTeams()  
        
