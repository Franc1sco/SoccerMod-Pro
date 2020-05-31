#include <cstrike>
#include <sourcemod>
#include <sdktools>

#define ASSISTS_OFFSET_FROM_FRAGS 4
#define SCORE_OFFSET_FROM_CONTROLLINGBOT -132
#define CASHSPENT_OFFSET_FROM_SCORE 20

new Handle:Restart_Delay;

//Info
public Plugin:myinfo =
{
	name = "ScoreSoccer v1.3",
	author = "arbol",
	description = "Makes soccer goals count.",
	version = "1.3"
};

public OnPluginStart()
{
    HookEvent("round_end", Event_Round);
    Restart_Delay = FindConVar("mp_round_restart_delay");
}

Scores_SaveAndReset() {
 
    Scores_SaveTeamScore();
    Scores_SetTeamScores( 0, 0 );
    
    new max = GetMaxClients();
    for( new i = 1; i <= max; i++ ) {
        if( IsClientConnected(i) ) {
            new assists_offset = FindDataMapOffs( i, "m_iFrags" ) + ASSISTS_OFFSET_FROM_FRAGS;

            score_frags[i]        = GetEntProp( i, Prop_Data, "m_iFrags" );
            score_assists[i]    = GetEntData( i, assists_offset );
            score_deaths[i]        = GetEntProp( i, Prop_Data, "m_iDeaths" );

            new score_offset = FindSendPropInfo( "CCSPlayer", "m_bIsControllingBot" ) + SCORE_OFFSET_FROM_CONTROLLINGBOT;
            score_score[i]        = GetEntData( i, score_offset );
            score_cashspent[i]    = GetEntData( i, score_offset + CASHSPENT_OFFSET_FROM_SCORE );
            

            Scores_SetPlayer( i, 0, 0, 0, 0, 0 );
        }
    }
}

public Action:Event_Round(Handle:event, const String:name[], bool:dontBroadcast)
{
    new Float:delay = GetConVarFloat(Restart_Delay) - 0.5
    for(new i = 1; i <= MaxClients; i++)
    {
      CreateTimer(delay, awardPeople, GetClientUserId(i));
    }
}


public Action:awardPeople(Handle:timer, any:userid)
{
    new client = GetClientOfUserId(userid);
    if(client > 0)
    {
        PrintToChat(client, "scoreSoccer: Round end detected.");
        if ( (IsPlayerAlive(client)) && (GetClientTeam(client) > 1)){
            new classist = CS_GetClientAssists(client);
            Scores_SetPlayer(client,1,classist+1,0,0,100)
            new emevepe = CS_GetMVPCount(client);
            new contrscore = CS_GetClientContributionScore(client);
            CS_SetMVPCount(client, emevepe+10);
            CS_SetMVPCount(client, emevepe+20);
            CS_SetClientContributionScore(client, contrscore+1);
            CS_SetClientContributionScore(client, contrscore+5);
            PrintToChat(client, "scoreSoccer: Processing done.");
        /*
          PrintToChat(client, "scoreSoccer: Player alive, processing score.");
          new emevepe = CS_GetMVPCount(client);
          new classist = CS_GetClientAssists(client);
          new contrscore = CS_GetClientContributionScore(client);
          CS_SetMVPCount(client, emevepe+1);
          CS_SetClientAssists(client, classist+1);
          CS_SetClientContributionScore(client, contrscore+1);
          //PrintToChat(client, "scoreSoccer: Processing almost done.-");
          //new olddeaths = GetEntProp(client, Prop_Data, "m_iDeaths");
          //SetEntProp(client, Prop_Data, "m_iDeaths", olddeaths+1);
          //PrintToChat(client, "scoreSoccer: Processing done.-");
          PrintToChat(client, "scoreSoccer: Processing almost done.");
          new score_offset = FindSendPropInfo( "CCSPlayer", "m_bIsControllingBot" ) + SCORE_OFFSET_FROM_CONTROLLINGBOT;
          score_score[i]        = GetEntData( i, score_offset );
          SetEntData( client, score_offset, score );
          new oldkills = GetEntProp(client, Prop_Data, "m_iFrags");
          SetEntProp( client, Prop_Data, "m_iFrags", oldkills+1 );
          PrintToChat(client, "scoreSoccer: Processing done.");*/
        }
    }
}




//-------------------------------------------------------------------------------------------------
Scores_SetPlayer( client, kills, assists, deaths, cashspent, score ) {
    if( !IsClientConnected(client) ) return;
    
    new assists_offset = FindDataMapOffs( client, "m_iFrags" ) + ASSISTS_OFFSET_FROM_FRAGS;
    
    SetEntProp( client, Prop_Data, "m_iFrags", kills );
    SetEntData( client, assists_offset, assists );
    SetEntProp( client, Prop_Data, "m_iDeaths", deaths );
    new score_offset = FindSendPropInfo( "CCSPlayer", "m_bIsControllingBot" ) + SCORE_OFFSET_FROM_CONTROLLINGBOT;
    SetEntData( client, score_offset, score );
    SetEntData( client, score_offset + CASHSPENT_OFFSET_FROM_SCORE, cashspent );
    
    PrintToChat(client, "scoreSoccer: set.");
}