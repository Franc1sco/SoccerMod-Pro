#include <cstrike>
#include <sourcemod>
#include <sdktools>

new Handle:Restart_Delay;

//Info
public Plugin:myinfo =
{
	name = "ScoreSoccer v1.07",
	author = "arbol",
	description = "Makes soccer goals count.",
	version = "1.07"
};

public OnPluginStart()
{
    HookEvent("round_end", Event_Round);
    Restart_Delay = FindConVar("mp_round_restart_delay");
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
          PrintToChat(client, "scoreSoccer: Player alive, processing score.");
          new emevepe = CS_GetMVPCount(client);
          new classist = CS_GetClientAssists(client);
          new contrscore = CS_GetClientContributionScore(client);
          CS_SetMVPCount(client, emevepe+1);
          CS_SetClientAssists(client, classist+1);
          CS_SetClientContributionScore(client, contrscore+1);
          PrintToChat(client, "scoreSoccer: Processing almost done.-");
          new olddeaths = GetEntProp(client, Prop_Data, "m_iDeaths");
          SetEntProp(client, Prop_Data, "m_iDeaths", olddeaths+1);
          PrintToChat(client, "scoreSoccer: Processing done.-");
        }
        /*if ( (IsPlayerAlive(client)) && (GetClientTeam(client) > 1)){
                new emevepe = CS_GetMVPCount(client);
                PrintToChat(client, "scoreSoccer: Contrib = %d", emevepe);
                new classist = CS_GetClientAssists(client);
                PrintToChat(client, "scoreSoccer: Cl.Assist = %d", classist);
                CS_SetMVPCount(client, emevepe+1);
                CS_SetClientAssists(client, classist+1);
                PrintToChat(client, "scoreSoccer: Updated.");
        }*/
    }
}