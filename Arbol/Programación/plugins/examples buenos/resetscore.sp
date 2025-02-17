#include <sourcemod>
#undef REQUIRE_EXTENSIONS
#include <cstrike>

#include <morecolors>

#undef REQUIRE_PLUGIN
#include <updater>

#define PLUGIN_VERSION "2.5.1"
#define UPDATE_URL "https://dl.dropbox.com/u/80272443/resetscore/resetscore.txt"

#pragma semicolon 1

new Handle:gH_Enabled = INVALID_HANDLE;
new Handle:gH_Resets = INVALID_HANDLE;
new Handle:gH_Timer[MAXPLAYERS+1] = {INVALID_HANDLE, ...};
new Handle:gH_ResetTime = INVALID_HANDLE;
new Handle:gH_AdvertTimer = INVALID_HANDLE;
new Handle:gH_Advertisments = INVALID_HANDLE;
new Handle:gH_CheaterAdmins = INVALID_HANDLE;

new gI_Resets;
new gI_Score[MAXPLAYERS+1];
new gI_Frags[MAXPLAYERS+1];
new gI_Deaths[MAXPLAYERS+1];
new gI_Assists[MAXPLAYERS+1];
new gI_ResetLeft[MAXPLAYERS+1];

new Float:gF_Timeleft;
new Float:gF_Autoadvert;

new bool:gB_Enabled;
new bool:gB_OverUsed[MAXPLAYERS+1] = {false, ...};
new bool:gB_CheaterAdmins;

new String:Mod[PLATFORM_MAX_PATH];
new Game;
// 1 - CSS/CS PROMOD
// 2 - CSGO
// 3 - TF2
// 4 - DOD:S

public Plugin:myinfo = 
{
	name = "Resetscore",
	author = "ml/shavit",
	description = "Allows the players to reset their scores and pause them if they've reached the limit.",
	version = PLUGIN_VERSION
}

public OnClientPutInServer(client)
{
	if(gB_Enabled)
	{
		if(!IsFakeClient(client))
		{
			if(gB_OverUsed[client])
			{
				switch(Game)
				{
					case 1, 4:
					{
						SetEntProp(client, Prop_Data, "m_iFrags", gI_Frags[client]);
						SetEntProp(client, Prop_Data, "m_iDeaths", gI_Deaths[client]);
					}
					
					case 2:
					{
						CS_SetClientContributionScore(client, gI_Score[client]);
						CS_SetClientAssists(client, gI_Assists[client]);
						SetEntProp(client, Prop_Send, "m_iFrags", gI_Frags[client]);
						SetEntProp(client, Prop_Send, "m_iDeaths", gI_Deaths[client]);
					}
					
					case 3:
					{
						SetEntProp(client, Prop_Send, "m_iFrags", gI_Frags[client]);
						SetEntProp(client, Prop_Send, "m_iDeaths", gI_Deaths[client]);
						SetEntProp(client, Prop_Send, "m_iAssists", gI_Deaths[client]);
					}
				}
			}
		}
	}
}

public OnLibraryAdded(const String:name[])
{
    if(StrEqual(name, "updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
}

public OnPluginStart()
{
	if(LibraryExists("updater"))
    {
        Updater_AddPlugin(UPDATE_URL);
    }
	
	CreateConVar("sm_resetscore_version", PLUGIN_VERSION, "Resetscore's version", FCVAR_NOTIFY|FCVAR_PLUGIN|FCVAR_DONTRECORD);
	SetConVarString(FindConVar("sm_resetscore_version"), PLUGIN_VERSION, _, true);
	
	gH_Enabled = CreateConVar("sm_resetscore_enabled", "1", "Resetscore enabled?", FCVAR_PLUGIN, true, 0.0, true, 1.0);	
	gH_Resets = CreateConVar("sm_resetscore_resets", "2", "Resets available.", FCVAR_PLUGIN, true, 1.0);
	gH_ResetTime = CreateConVar("sm_resetscore_time", "1200.0", "Time [FLOAT/SECONDS] to wait before retrieving new resets.", FCVAR_PLUGIN);
	gH_CheaterAdmins = CreateConVar("sm_resetscore_admins", "0", "Allow admins to cheat by allowing them to have infinite resets?", FCVAR_PLUGIN, true, 0.0, true, 1.0);
	gH_Advertisments  = CreateConVar("sm_resetscore_advert", "60.0", "Time [FLOAT/SECONDS] to auto-advertisements, 0 - disabled", FCVAR_PLUGIN);
	
	gB_Enabled = true;
	gI_Resets = 2;
	gF_Timeleft = 1200.0;
	gB_CheaterAdmins = false;
	gF_Autoadvert = 60.0;
	
	HookConVarChange(gH_Enabled, ConVarChanged);
	HookConVarChange(gH_Resets, ConVarChanged);
	HookConVarChange(gH_ResetTime, ConVarChanged);
	HookConVarChange(gH_CheaterAdmins, ConVarChanged);
	
	RegConsoleCmd("sm_resetscore", Command_RS, "Reset your score");
	RegConsoleCmd("sm_rs", Command_RS, "Reset your score");
	
	HookEvent("player_disconnect", DisconnectedClient, EventHookMode_Pre);
	
	LoadTranslations("resetscore.phrases");
	AutoExecConfig(true, "resetscore");
	
	GetGameFolderName(Mod, PLATFORM_MAX_PATH);
	
	if(StrEqual(Mod, "cstrike") || StrEqual(Mod, "cstrike_beta"))
	{
		Game = 1;
	}
	
	else if(StrEqual(Mod, "csgo"))
	{
		Game = 2;
	}
	
	else if(StrEqual(Mod, "tf"))
	{
		Game = 3;
	}
	
	else if(StrContains(Mod, "dod"))
	{
		Game = 4;
	}
	
	gH_AdvertTimer = CreateTimer(gF_Autoadvert, Advert, _, TIMER_REPEAT);
}

public Action:Advert(Handle:Timer)
{
	if(gB_Enabled)
	{
		PrintToChatAll("\x04[SM]\x01 %t", "TYPE_RS");
	}
}

public ConVarChanged(Handle:cvar, const String:oldVal[], const String:newVal[])
{
	if(cvar == gH_Enabled)
	{
		gB_Enabled = StringToInt(newVal)? true:false;
	}
	
	else if(cvar == gH_Resets)
	{
		gI_Resets = StringToInt(newVal);
	}
	
	else if(cvar == gH_ResetTime)
	{
		gF_Timeleft = StringToFloat(newVal);
	}
	
	else if(cvar == gH_CheaterAdmins)
	{
		gB_CheaterAdmins = StringToInt(newVal)? true:false;
	}
	
	else if(cvar == gH_Advertisments)
	{
		gF_Autoadvert = StringToFloat(newVal);
		DisableTimer(gH_AdvertTimer);
		
		if(StringToInt(newVal) != 0)
		{
			gH_AdvertTimer = CreateTimer(gF_Autoadvert, Advert, _, TIMER_REPEAT);
		}
	}
}

stock DisableTimer(Handle:Timer)
{
	CloseHandle(Timer);
	Timer = INVALID_HANDLE;
}

public Action:NewResets(Handle:Timer, any:client)
{
	if(gB_Enabled && gH_Timer[client] != INVALID_HANDLE)
	{
		gI_ResetLeft[client] = gI_Resets;
		gB_OverUsed[client] = false;
		DisableTimer(gH_Timer[client]);
	}
}

public Action:DisconnectedClient(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));
	
	if(gB_Enabled && IsValidEntity(client) && !IsFakeClient(client))
	{
		switch(Game)
		{
			case 1, 4:
			{
				gI_Frags[client] = GetEntProp(client, Prop_Data, "m_iFrags");
				gI_Deaths[client] = GetEntProp(client, Prop_Data, "m_iDeaths");
			}
			
			case 2:
			{
				gI_Score[client] = CS_GetClientContributionScore(client);
				gI_Assists[client] = CS_GetClientAssists(client);
				gI_Frags[client] = GetEntProp(client, Prop_Send, "m_iFrags");
				gI_Deaths[client] = GetEntProp(client, Prop_Send, "m_iDeaths");
			}
			
			case 3:
			{
				gI_Frags[client] = GetEntProp(client, Prop_Send, "m_iFrags");
				gI_Deaths[client] = GetEntProp(client, Prop_Send, "m_iDeaths");
				gI_Assists[client] = GetEntProp(client, Prop_Send, "m_iAssists");
			}
		}
		
		if(gH_Timer[client] != INVALID_HANDLE)
		{
			DisableTimer(gH_Timer[client]);
		}
	}
}

public Action:Command_RS(client, args)
{
	if(!gB_Enabled)
	{
		ReplyToCommand(client, "\x04[SM]\x01 %t", "DISABLED");
		return Plugin_Handled;
	}
	
	new iFrags = 1;
	new iDeaths = 1;
	new iScore = 1;
	new iAssists = 1;
	new iKills = 1;
	new team = GetClientTeam(client);
	
	if(!gI_ResetLeft[client])
	{
		ReplyToCommand(client, "\x04[SM]\x01 %t", "NO_RESETS");
		return Plugin_Handled;
	}
	
	if(team <= 2)
	{
		ReplyToCommand(client, "\x04[SM]\x01 %t", "RESET_TEAM");
		return Plugin_Handled;
	}
	
	switch(Game)
	{
		case 1, 4:
		{
			iFrags = GetEntProp(client, Prop_Data, "m_iFrags");
			iDeaths = GetEntProp(client, Prop_Data, "m_iDeaths");
		}
		
		case 2:
		{
			iScore = CS_GetClientContributionScore(client);
			iAssists = CS_GetClientAssists(client);
			iFrags = GetEntProp(client, Prop_Data, "m_iFrags");
			iDeaths = GetEntProp(client, Prop_Data, "m_iDeaths");
		}
		
		case 3:
		{
			iKills = GetEntProp(client, Prop_Data, "m_iKills");
			iDeaths = GetEntProp(client, Prop_Data, "m_iDeaths");
			iAssists = GetEntProp(client, Prop_Data, "m_iAssists");
		}
	}
	
	if(!(iFrags && iDeaths) || !(iScore) || !(iKills && iDeaths && iAssists))
	{
		ReplyToCommand(client, "\x04[SM]\x01 %t", "SCORE_0");
		return Plugin_Handled;
	}
	
	switch(Game)
	{
		case 1, 4:
		{
			SetEntProp(client, Prop_Data, "m_iFrags", 0);
			SetEntProp(client, Prop_Data, "m_iDeaths", 0);
		}
		
		case 2:
		{
			CS_SetClientContributionScore(client, 0);
			CS_SetClientAssists(client, 0);
			SetEntProp(client, Prop_Data, "m_iFrags", 0);
			SetEntProp(client, Prop_Data, "m_iDeaths", 0);
		}
		
		case 3:
		{
			SetEntProp(client, Prop_Data, "m_iAssists", 0);
			SetEntProp(client, Prop_Send, "m_iFrags", 0);
			SetEntProp(client, Prop_Send, "m_iDeaths", 0);
		}
	}
	
	if(gB_CheaterAdmins && CheckCommandAccess(client, "resetscore_admin", ADMFLAG_GENERIC))
	{
		ReplyToCommand(client, "\x04[SM]\x01 %t", "RESET_SCORE_ADMIN");
		return Plugin_Handled;
	}
	
	else
	{
		if(!gI_ResetLeft[client])
		{
			ReplyToCommand(client, "\x04[SM]\x01 %t", "RESETS_OVER", gF_Timeleft/60);
			gH_Timer[client] = CreateTimer(gF_Timeleft, NewResets, client, TIMER_FLAG_NO_MAPCHANGE);
			gB_OverUsed[client] = true;
			return Plugin_Handled;
		}
		
		ReplyToCommand(client, "\x04[SM]\x01 %t", "RESET_SCORE", gI_ResetLeft[client]);
		CPrintToChatAllEx(client, "\x04[SM]\x01 %t", "PLAYER_RESET", client, gI_ResetLeft[client]);
		gI_ResetLeft[client]--;
	}
	
	return Plugin_Handled;
}