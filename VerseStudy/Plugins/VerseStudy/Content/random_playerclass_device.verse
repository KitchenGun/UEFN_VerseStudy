using { /Fortnite.com/Devices }
using { /Verse.org/Simulation }
using { /Verse.org/Random }
using { /UnrealEngine.com/Temporary/Diagnostics }


# A Verse-authored creative device that can be placed in a level
random_playerclass_device := class(creative_device):

    #스포너
    @editable
    PlayerSpawners : []player_spawner_device = array{}
    #클래스
    @editable
    PlayerLoadouts : []class_and_team_selector_device = array{}
    #스코어
    var ScoreManager<private> : score_manager = score_manager{}
    @editable
    ScoreManagerDevice<public> : score_manager_device = score_manager_device{}
    @editable
    var LapCount<public> : int =0
    @editable
    var KillScore<public> : int =0
    @editable
    var DeadScore<public> : int =0


    # Runs when the device is started in a running game
    OnBegin<override>()<suspends>:void=
        for(PlayerSpawner:PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnSpawnPlayer)
        GetPlayspace().PlayerAddedEvent().Subscribe(OnJoinPlayer)
        Print("begin")

    OnJoinPlayer(Agent:agent) :void=
        set ScoreManager = MakeScoreManager(Agent,ScoreManagerDevice)
        ScoreManager.AddScoreManagerToUI()
        Print("join")

    OnSpawnPlayer(Agent : agent) :void=
        var RandomLoadoutNum : int = GetRandomInt(1,3)
        
        case(RandomLoadoutNum):
            1 =>
                if(TargetPlayerLoadout := PlayerLoadouts[0]):
                    TargetPlayerLoadout.ChangeClass(Agent)
                    Print("slot1")
            2 =>
                if(TargetPlayerLoadout := PlayerLoadouts[1]):
                    TargetPlayerLoadout.ChangeClass(Agent)
                    Print("slot2")
            3 =>
                if(TargetPlayerLoadout := PlayerLoadouts[2]):
                    TargetPlayerLoadout.ChangeClass(Agent)
                    Print("slot3")
            _ =>
                return
        
        set ScoreManager = MakeScoreManager(Agent,ScoreManagerDevice)
        ScoreManager.AddScoreManagerToUI()
        Print("spawn")


        