/*
NEXT VERSION
- Positions
- HUD Overlay
- Ball automatic rotation
- Database

*/

#include <sourcemod>
#include <sdktools>
#include <sdktools_sound>
#include <sdkhooks>
#include <cstrike>
//#include <csgocolors>
#include <clientprefs>
#include <timers>
#include <entity> 

////////****<<<<<< DEFINE >>>>>>****////////
////////****<<<<<< DEFINE >>>>>>****////////
////////****<<<<<< DEFINE >>>>>>****////////

#define PLUGIN_VERSION "5.1.7.5" // 18/12/2019
#define MODELO_JUGCT "models/player/custom_player/legacy/ctm_fbi_variantb.mdl"
#define MODELO_JUGCTGK "models/player/custom_player/legacy/ctm_swat.mdl"
#define MODELO_JUGTT "models/player/tm_balkan_variantA.mdl"
#define MODELO_JUGTTGK "models/player/tm_separatist.mdl"
#define MAX_E_DISTANCE 50
#define MAX_E_GK_DISTANCE 50
#define MAX_SHIFT_GK_DISTANCE 65
#define MAX_KNIFE_DISTANCE 85
#define MAX_WAKE_DISTANCE 110
#define SCORE_FOR_SAVE 35 // Global score for saving ball with E or knife
#define SCORE_FOR_OWN_GOAL -15 // Global score for own goal
#define SCORE_FOR_GOAL 75 // MVP global score
#define SCORE_FOR_LOSING -1 // Losing ball
#define SCORE_FOR_ASSIST 60 // Assist global score
#define SCORE_FOR_STEAL 5 // Kill global score
#define SCORE_FOR_PASS 3 // Death global score
#define SPEED_NORMAL Float: 1.00
#define	SPEED_TURBO Float: 1.35
#define SPEED_NORMAL_CARRY Float: 0.85
#define SPEED_TURBO_CARRY Float: 1.10
#define NORMAL_E_HEIGHT Float:11.0
#define MAX_CURVE_HEIGHT Float:512.0
#define GK_E_HEIGHT Float:40.0
#define BALL_RADIUS Float:11.0
#define GUARIDA_HEIGHT Float:64.0
#define Z_BOUNDARY Float:12512.0
#define MAX_ACTION_HEIGHT Float:12.0 // Add +12 of ball initial Z position
#define MAX_SHIFT_HEIGHT Float:4.0
#define SCALE_R_BACKWARDS_DISTANCE Float:2.0
#define SCALE_E_DISTANCE Float:35.0
#define SCALE_R_DISTANCE Float:68.0
#define ATTRACT_MULTIPLIER Float:7.0
#define NULL_VELOCITY Float:{0.0, 0.0, 0.0}

////////****<<<<<< GLOBAL VARS >>>>>>****////////
////////****<<<<<< GLOBAL VARS >>>>>>****////////
////////****<<<<<< GLOBAL VARS >>>>>>****////////

new ball0;
new ball0_dynamic;
new goles_tt = 0;
new goles_ct = 0;
new forward_mode = 0;
new backwards_mode = 0;
new String:ball0_model_name[128] = "";
new Float:ball0_pos_init[3]
new Float:blackbox0_pos_init[3];
new	Float:ball0_position[3];
new Float:ball0_previous_position[3];
new Float:ball0_dynamic_position[3];
new Float:ball0_dynamic_previous_position[3];
new Float:client_position[3];
new Float:original_angles[3];
new Float:player_grabbing_position[3];
new Float:vector_difference[3];
new Float:gk_e_position[3];
new	Float:client_distance = 0.0;
new Float:dest_origin[3];
new Float:fix_dest[3];
new Float:client_origin[3];
new Float:client_eye_angles[3];
new Float:cos = 0.0;
new Float:sin = 0.0;
new real_buttons[MAXPLAYERS+1] = {0,...};
const Float:speed_player_carry = 0.90;
const Float:speed_player_normal = 1.00;
const Float:speed_player_carry_turbo = 1.15;
const Float:speed_player_turbo = 1.35;
new Float:actual_speed;
new refresh_ball = 0; // 0=ball position update disabled ; 1=ball refreshing
new postround = 0; // 0=round is still on course; 1=round has finished
new ball0_invulnerable = 0; // 0=normal ; 1=goalkeeper mode
new ball0_control = 0; // 0=free ; 1=dribble mode
new player_grabbing = -1; // client/player that is grabbing ball; -1=free
new ct_goalkeeper = -1; // client ct goalkeeper
new tt_goalkeeper = -1; // client t goalkeeper
new ct_area_touch[MAXPLAYERS+1] = {0,...}; // 0=player is NOT inside its own area; 1=player is inside its own area
new tt_area_touch[MAXPLAYERS+1] = {0,...};
new ball0_disable[MAXPLAYERS+1] = {0,...}; // 0=player can grab ball with E; 1=ball is disabled for grabbing
new rl; // random loser index
new Float:vector_loser[3];
new Float:vector_client[3];
new last_ct_activity = -1; // Last CT that touch ball
new last_t_activity = -1;
new last_ct_pass = -1; // Last CT that made a pass
new last_t_pass = -1;
new last_ct_lost = -1; // Last CT that lose ball
new last_t_lost = -1;
new last_ct_lost_pass = -1; // 
new last_t_lost_pass = -1;
new last_loser_team = 0;
new curve_counter = 0;
new last_curve = 0;
new curve_client = -1;
new ball0_curve[MAXPLAYERS+1] = {0,...}; // 0=No curve; 1=Curve ball to left; 2=Curve ball to right
new curve_delay[MAXPLAYERS+1] = {0,...};
new steal_reward[MAXPLAYERS+1] = {0,...}; // 0=Available for reward; 1=No steal reward
new ball0_delay_shift[MAXPLAYERS+1] = {0,...}; // example [4]=0 means no delay for player 4
new ball0_delay_e[MAXPLAYERS+1] = {0,...};
new ball0_delay_e_gk[MAXPLAYERS+1] = {0,...};
new ball0_delay_click[MAXPLAYERS+1] = {0,...};
new ball0_delay_click_right[MAXPLAYERS+1] = {0,...};
new ball0_delay_r[MAXPLAYERS+1] = {0,...};
new player_kills[MAXPLAYERS+1] = {0,...}; // Steals
new player_assists[MAXPLAYERS+1] = {0,...}; // Assists
new player_deaths[MAXPLAYERS+1] = {0,...}; // Passes completed
new player_mvps[MAXPLAYERS+1] = {0,...}; // MVPS = Goals
new player_scores[MAXPLAYERS+1] = {0,...}; // Scores will be globally updated
new largest_value1 = 0;
new largest_value2 = 0;
new largest_value3 = 0;
new largest_value4 = 0;
new largest_value5 = 0;
new victim_id;
new victim_index = -1;
new player_id;
new player_index = -1;
char player_name[MAX_NAME_LENGTH];
char client_name[MAX_NAME_LENGTH];
char target_name[MAX_NAME_LENGTH];
char victim_name[MAX_NAME_LENGTH];
ConVar mp_join_grace_time;
Handle timer_physics_handle;
Handle delay_timers_curve[MAXPLAYERS+1];
Handle delay_timers_click[MAXPLAYERS+1];
Handle delay_timers_click_right[MAXPLAYERS+1];
Handle delay_timers_shift[MAXPLAYERS+1];
Handle delay_timers_e[MAXPLAYERS+1];
Handle delay_timers_e_gk[MAXPLAYERS+1];
Handle delay_timers_r[MAXPLAYERS+1];
Handle delay_timers_invulnerable[MAXPLAYERS+1];
new Handle:cvar_restart = INVALID_HANDLE;

////////****<<<<<< MAIN >>>>>>****////////
////////****<<<<<< MAIN >>>>>>****////////
////////****<<<<<< MAIN >>>>>>****////////

public Plugin myinfo =
{
	name = "[CS:GO/SMP5] SoccerMod Pro V", // Only tested in LINUX
	author = "Ulreth / Arbol",
	description = "Ultimate SoccerMod only for CS:GO",
	version = PLUGIN_VERSION,
	url = "http://steamcommunity.com/groups/F-I-F-A"
};

public void OnPluginStart()
{
	RegConsoleCmd("sm_gk", Command_GK, "Type !gk to be the goalkeeper");
	RegConsoleCmd("sm_stats", Command_Stats, "Type !stats to see your global stats");
	RegConsoleCmd("sm_leftcurve", Command_Curve_Left);
	RegConsoleCmd("sm_rightcurve", Command_Curve_Right);
	RegConsoleCmd("sm_nocurve", Command_Curve_0);
	RegConsoleCmd("kill", Command_Kill);
	//RegAdminCmd("sm_delete_database", Command_Delete_Database, ADMFLAG_SLAY); // Delete database
	RegAdminCmd("sm_getball", Command_Admin_Ball, ADMFLAG_SLAY); // Brings ball to admin position
	RegAdminCmd("sm_spawnball", Command_Spawn_Ball, ADMFLAG_SLAY); // Spawns a simple physics ball
	RegAdminCmd("sm_removeball", Command_Admin_Remove, ADMFLAG_SLAY); // Removes ball from game
	RegAdminCmd("sm_fight", Command_Admin_Fight, ADMFLAG_SLAY); // Knife fight enabled for this round
	RegAdminCmd("sm_goal_disable", Command_Goal_Disable, ADMFLAG_SLAY); // Disable goals in current round
	RegAdminCmd("sm_goal_enable", Command_Goal_Enable, ADMFLAG_SLAY); // Enable goals in current round
	RegAdminCmd("sm_freeze_all", Command_Freeze_All, ADMFLAG_SLAY); // Freeze all players
	RegAdminCmd("sm_unfreeze_all", Command_Unfreeze_All, ADMFLAG_SLAY); // Unfreeze all players
	RegAdminCmd("sm_ct_teleport", Command_CT_Teleport, ADMFLAG_SLAY); // Teleport all CT players to admin position
	RegAdminCmd("sm_tt_teleport", Command_TT_Teleport, ADMFLAG_SLAY); // Teleport all T players to admin position
	RegAdminCmd("sm_ct_wins", Command_CT_Wins, ADMFLAG_SLAY); // CT wins this round
	RegAdminCmd("sm_tt_wins", Command_TT_Wins, ADMFLAG_SLAY); // TT wins this round
	RegAdminCmd("sm_clean_score", Command_Clean_Score, ADMFLAG_SLAY); // Scoreboard to 0 0
	RegAdminCmd("sm_ct_point", Command_CT_Point, ADMFLAG_SLAY); // +1 goals to CT
	RegAdminCmd("sm_tt_point", Command_TT_Point, ADMFLAG_SLAY); // +1 goals to T
	RegAdminCmd("sm_ct_substract", Command_CT_Substract, ADMFLAG_SLAY); // -1 goals to CT
	RegAdminCmd("sm_tt_substract", Command_TT_Substract, ADMFLAG_SLAY); // -1 goals to T
	RegAdminCmd("sm_round_draw", Command_Round_Draw, ADMFLAG_SLAY); // Round draw
	RegAdminCmd("sm_ball_info", Command_Ball_Info, ADMFLAG_SLAY); // Provides ball location to debug
	HookEvent("round_start", Event_RoundStart, EventHookMode_Pre);
	HookEvent("round_end", Event_RoundEnd);
	HookEvent("player_jump", Event_PlayerJump);
	HookEvent("player_hurt", Event_PlayerHurt);
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
	HookEvent("cs_win_panel_match", Event_WinPanel, EventHookMode_Pre);
	AddNormalSoundHook(High_Volume_Sounds_Played);
	AddCommandListener(Event_JoinTeam, "jointeam");
	//
	cvar_restart = FindConVar("mp_restartgame");
	if (cvar_restart != INVALID_HANDLE)
	{
		HookConVarChange(cvar_restart, On_Cvar_Changed);
	}
	mp_join_grace_time = FindConVar("mp_join_grace_time");
    if(mp_join_grace_time != null)
    {
        mp_join_grace_time.SetBounds(ConVarBound_Upper, false);        
    }
	//
	CreateTimer(2.0, timer_stats_update, _,TIMER_REPEAT);
}

public OnEntityCreated(entity, const String:classname[])
{
    if(StrEqual(classname, "trigger_multiple"))
    {
		SDKHook(entity, SDKHook_Touch, OnTouching);
		SDKHookEx(entity, SDKHook_EndTouch, OnEndTouch);
		SDKHookEx(entity, SDKHook_StartTouch, OnStartTouch);
    }
}

public OnMapStart()
{
	AddFileToDownloadsTable("sound/customsounds/shot2_arb.mp3");
	AddFileToDownloadsTable("sound/customsounds/bloqueo_arb.mp3");
	AddFileToDownloadsTable("sound/customsounds/ready.mp3");
	AddFileToDownloadsTable("sound/customsounds/ready_gk.mp3");
	AddFileToDownloadsTable("sound/customsounds/radio_gk_start.mp3");
	AddFileToDownloadsTable("sound/customsounds/radio_gk_end.mp3");
	PrecacheModel("materials/sprites/laserbeam.vmt", true);
    SetVariablesToZero();
	Find_Black_Box();
	Find_Ball();
	Stop_Ball();
	if(GameRules_GetProp("m_bWarmupPeriod") == 1)
	{
		StatsToZero();
	}
	SetCvar("phys_pushscale", 				1);
}
public Action:Command_Kill(client, args)
{
	refresh_ball = 0;
	if (player_grabbing == client)
	{
		// Check_Interference(player_grabbing);
		GetEntPropVector(ball0, Prop_Send, "m_vecOrigin", ball0_position);
		GetEntPropVector(ball0_dynamic, Prop_Send, "m_vecOrigin", ball0_dynamic_position);
		ball0_invulnerable = 0;
		ball0_control = 0;
		player_grabbing = -1;
		Return_Ball();
		PrintToChatAll(" \x01\x0B\x05 [SMP5] The ball was released.");
	}
	tt_area_touch[client]=0;
	ct_area_touch[client]=0;
	real_buttons[client]=0;
	refresh_ball = 1;
}
/*public OnClientPutInServer(client)
{



}*/
public OnClientDisconnect(client)
{
	refresh_ball = 0;
	if ((player_grabbing == client) && (IsClientInGame(client)))
	{
		// Check_Interference(player_grabbing);
		ball0_invulnerable = 0;
		ball0_control = 0;
		player_grabbing = -1;
		Return_Ball();
		PrintToChatAll(" \x01\x0B\x05 [SMP5] The ball was released.");
	}
	if (ct_goalkeeper == client)
	{
		ct_goalkeeper = -1;
	}
	if (tt_goalkeeper == client)
	{
		tt_goalkeeper = -1;
	}
	// Close timer handles
	if (delay_timers_click[client] != null)
	{
		KillTimer(delay_timers_click[client]);
		delay_timers_click[client] = null;
	}
	if (delay_timers_click_right[client] != null)
	{
		KillTimer(delay_timers_click_right[client]);
		delay_timers_click_right[client] = null;
	}
	if (delay_timers_curve[client] != null)
	{
		KillTimer(delay_timers_curve[client]);
		delay_timers_curve[client] = null;
	}
	if (delay_timers_shift[client] != null)
	{
		KillTimer(delay_timers_shift[client]);
		delay_timers_shift[client] = null;
	}
	if (delay_timers_e[client] != null)
	{
		KillTimer(delay_timers_e[client]);
		delay_timers_e[client] = null;
	}
	if (delay_timers_e_gk[client] != null)
	{
		KillTimer(delay_timers_e_gk[client]);
		delay_timers_e_gk[client] = null;
	}
	if (delay_timers_r[client] != null)
	{
		KillTimer(delay_timers_r[client]);
		delay_timers_r[client] = null;
	}
	if (delay_timers_invulnerable[client] != null)
	{
		KillTimer(delay_timers_invulnerable[client]);
		delay_timers_invulnerable[client] = null;
	}
	if (client == last_ct_activity)
	{
		last_ct_activity = -1;
	}
	if (client == last_t_activity)
	{
		last_t_activity = -1;
	}
	if (client == last_ct_pass)
	{
		last_ct_pass = -1;
	}
	if (client == last_t_pass)
	{
		last_t_pass = -1;
	}
	if (client == last_ct_lost)
	{
		last_ct_lost = -1;
	}
	if (client == last_t_lost)
	{
		last_t_lost = -1;
	}
	if (client == last_ct_lost_pass)
	{
		last_ct_lost_pass = -1;
	}
	if (client == last_t_lost_pass)
	{
		last_t_lost_pass = -1;
	}
	// Set to 0 some variables
	real_buttons[client]=0;
	steal_reward[client]=0;
	tt_area_touch[client]=0;
	ct_area_touch[client]=0;
	ball0_delay_shift[client]=0; // example [4]=0 means no delay for player 4
	ball0_delay_e[client]=0;
	ball0_delay_r[client]=0;
	ball0_delay_e_gk[client]=0;
	ball0_delay_click[client]=0;
	ball0_delay_click_right[client]=0;
	player_kills[client]=0;
	player_assists[client]=0;
	player_deaths[client]=0;
	player_mvps[client]=0;
	player_scores[client]=0;
	refresh_ball = 1;
}

////////****<<<<<< EVENTS >>>>>>****////////
////////****<<<<<< EVENTS >>>>>>****////////
////////****<<<<<< EVENTS >>>>>>****////////

public Event_RoundStart(Event event, const char[] name, bool dontBroadcast)
{
    SetVariablesToZero();
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Round start.");
	Find_Black_Box();
	Find_Ball();
	Stop_Ball();
	Fix_Physics();
	timer_physics_handle = CreateTimer(0.1, timer_physics_update, _,TIMER_REPEAT);
	if(GameRules_GetProp("m_bWarmupPeriod") == 1)
	{
		StatsToZero();
	}
	// LOSER AUTO-TELEPORT NEAR BALL
	/*
	rl = 1;
	while(rl <= MAXPLAYERS)
	{
		//if ((GetClientTeam(rl) == last_loser_team) && (last_loser_team != 0) && (rl != tt_goalkeeper) && (rl != ct_goalkeeper) && (IsPlayerAlive(rl)))
		if ((GetClientTeam(rl) == last_loser_team) && (last_loser_team != 0) && (IsPlayerAlive(rl)))
		{
			CreateTimer(0.5, timer_teleport_loser);
			PrintToChat(rl, " \x01\x0B\x05 [SMP5] You have been teleported forward for losing last round.")
			break;
		}
		rl = rl+1;
	}
	*/
	rl = GetRandomPlayer(last_loser_team);
	if ((IsClientInGame(rl)) && (IsPlayerAlive(rl)) && (IsValidEntity(rl)))
	{
		CreateTimer(1.0, timer_teleport_loser);
		PrintToChat(rl, " \x01\x0B\x05 [SMP5] You have been teleported forward for losing last round.")
	}
	// BALL TRAIL
	/*
	int trail = CreateEntityByName("env_spritetrail");
	DispatchKeyValue(trail, "renderamt", "255");
	DispatchKeyValue(trail, "rendermode", "5");
	PrecacheModel("materials/sprites/cbbl_smoke.vmt")
	DispatchKeyValue(trail, "spritename", "materials/sprites/cbbl_smoke.vmt");
	DispatchKeyValue(trail, "lifetime", "3.0");
	DispatchKeyValue(trail, "startwidth", "10.0");
	DispatchKeyValue(trail, "endwidth", "0.1");
	DispatchKeyValue(trail, "rendercolor", "225, 225, 255");
	DispatchSpawn(trail);
	TeleportEntity(trail, ball0_position, NULL_VECTOR, NULL_VECTOR);
	SetVariantString("pelota0");
	AcceptEntityInput(trail, "SetParent", -1, -1);
	AcceptEntityInput(trail, "showsprite", -1, -1);
	SetVariantFloat(1.1);
	AcceptEntityInput(trail, "SetScale");
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Trail activated.");
	*/
}
public Action timer_teleport_loser(Handle timer)
{
	GetClientAbsOrigin(rl, vector_client);
	vector_loser[0] = ((vector_client[0] + ball0_pos_init[0]) / 2);
	vector_loser[1] = ((vector_client[1] + ball0_pos_init[1]) / 2);
	vector_loser[2] = vector_client[2];
	TeleportEntity(rl, vector_loser, NULL_VECTOR, NULL_VECTOR);
	return Plugin_Stop;
}
public On_Cvar_Changed(Handle:hCVar, const String:strOld[], const String:strNew[])
{
    if (hCVar == cvar_restart)
    {
        PrintToChatAll("***Restarting match and stats***");
        StatsToZero();
    }
}
public Event_RoundEnd(Event event, const char[] name, bool dontBroadcast)
{
	int winner = GetEventInt(event, "winner");
	char goal_scorer[MAX_NAME_LENGTH] = "";
	char assist_name[MAX_NAME_LENGTH] = "";
	last_loser_team = 0;
	KillTimer(timer_physics_handle);
	timer_physics_handle = null;
	if (last_ct_activity != -1)
	{ // Cases for CT team
		if(winner == CS_TEAM_CT)
		{
			last_loser_team = 2;
			goles_ct = goles_ct+1;
			if (postround == 0)
			{
				player_mvps[last_ct_activity]=player_mvps[last_ct_activity]+1;
				player_scores[last_ct_activity]=player_scores[last_ct_activity]+SCORE_FOR_GOAL;
			}
			GetClientName(last_ct_activity, goal_scorer, sizeof(goal_scorer));
			if ((last_ct_pass != -1) && (last_ct_pass != last_ct_activity))
			{
				GetClientName(last_ct_pass, assist_name, sizeof(assist_name));
				if (postround == 0)
				{
					player_assists[last_ct_pass]=player_assists[last_ct_pass]+1;
					player_scores[last_ct_pass]=player_scores[last_ct_pass]+SCORE_FOR_ASSIST;
				}
				PrintHintTextToAll("GOAL SCORER: %s \n ASSIST BY: %s", goal_scorer, assist_name);
				PrintToChatAll(" \x01\x0B\x05 [SMP5] Goal scorer: \x01\x0B\x03 %s \x01\x0B\x05       Assist by: \x01\x0B\x03 %s \x01\x0B\x05", goal_scorer, assist_name);
			}
			if ((last_ct_pass == -1) || (last_ct_pass == last_ct_activity))
			{
				PrintHintTextToAll("GOAL SCORER: %s \n NO ASSIST", goal_scorer);
				PrintToChatAll(" \x01\x0B\x05 [SMP5] Goal scorer: \x01\x0B\x03 %s \x01\x0B\x05    No assist", goal_scorer);
			}
		}
		/*
		if(winner == CS_TEAM_T) // OWN GOAL MADE BY A CT
		{
			last_loser_team = 3;
			goles_tt = goles_tt+1;
			if ((last_ct_activity != ct_goalkeeper) || ((last_ct_activity == ct_goalkeeper) && ((last_ct_pass != -1) || (last_t_lost == -1))))
			{
				if (last_ct_pass == -1)
				{
					if (postround == 0)
					{
						//player_scores[last_ct_activity]=player_scores[last_ct_activity]+SCORE_FOR_OWN_GOAL;
						player_mvps[last_t_activity]=player_mvps[last_t_activity]+1;
						player_scores[last_t_activity]=player_scores[last_t_activity]+SCORE_FOR_GOAL;
					}
					//GetClientName(last_ct_activity, goal_scorer, sizeof(goal_scorer));
					GetClientName(last_t_activity, goal_scorer, sizeof(goal_scorer));
				}
				else
				{
					if (postround == 0)
					{
						//player_scores[last_ct_pass]=player_scores[last_ct_pass]+SCORE_FOR_OWN_GOAL;
						player_mvps[last_t_activity]=player_mvps[last_t_activity]+1;
						player_scores[last_t_activity]=player_scores[last_t_activity]+SCORE_FOR_GOAL;
					}
					//GetClientName(last_ct_pass, goal_scorer, sizeof(goal_scorer));
					GetClientName(last_t_activity, goal_scorer, sizeof(goal_scorer));
				}
				////////////
				if ((last_t_pass != -1) && (last_t_pass != last_t_activity))
				{
					if (postround == 0)
					{
						player_assists[last_t_pass]=player_assists[last_t_pass]+1;
						player_scores[last_t_pass]=player_scores[last_t_pass]+SCORE_FOR_ASSIST;
					}
					GetClientName(last_t_pass, assist_name, sizeof(assist_name));
					PrintHintTextToAll("GOAL SCORER: %s \n ASSIST BY: %s", goal_scorer, assist_name);
					PrintToChatAll(" \x01\x0B\x05 [SMP5] Goal scorer: \x01\x0B\x03 %s \x01\x0B\x05       Assist by: \x01\x0B\x03 %s \x01\x0B\x05", goal_scorer, assist_name);
				}
				if ((last_t_pass == -1) || (last_t_pass == last_t_activity))
				{
					PrintHintTextToAll("GOAL SCORER: %s \n NO ASSIST", goal_scorer);
					PrintToChatAll(" \x01\x0B\x05 [SMP5] Goal scorer: \x01\x0B\x03 %s \x01\x0B\x05    No assist", goal_scorer);
				}
				////////////
				//PrintHintTextToAll("OWN GOAL BY: %s ", goal_scorer);
				//PrintToChatAll(" \x01\x0B\x05 [SMP5] Own goal by \x01\x0B\x03 %s \x01\x0B\x05, what a shame!", goal_scorer);
			}
			if ((last_ct_activity == ct_goalkeeper) && (last_ct_pass == -1) && (last_t_lost != -1))
			{ // T GOAL BUT CT GK TRIED TO STOP BALL
				char gk_ct_name[MAX_NAME_LENGTH] = "";
				GetClientName(ct_goalkeeper, gk_ct_name, sizeof(gk_ct_name));
				PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 (CT GK) tried to stop the ball with no success.", gk_ct_name);
				if (postround == 0)
				{
					player_mvps[last_t_lost]=player_mvps[last_t_lost]+1;
					player_scores[last_t_lost]=player_scores[last_t_lost]+SCORE_FOR_GOAL;
				}
				GetClientName(last_t_lost, goal_scorer, sizeof(goal_scorer));
				if (last_t_lost_pass != -1)
				{
					if (postround == 0)
					{
						player_assists[last_t_lost_pass]=player_assists[last_t_lost_pass]+1;
						player_scores[last_t_lost_pass]=player_scores[last_t_lost_pass]+SCORE_FOR_ASSIST;
					}
					GetClientName(last_t_lost_pass, assist_name, sizeof(assist_name));
					PrintHintTextToAll("GOAL SCORER: %s \n ASSIST BY: %s", goal_scorer, assist_name);
					PrintToChatAll(" \x01\x0B\x05 [SMP5] Goal scorer: \x01\x0B\x03 %s \x01\x0B\x05       Assist by: \x01\x0B\x03 %s \x01\x0B\x05", goal_scorer, assist_name);
				}
				if (last_t_lost_pass == -1)
				{
					PrintHintTextToAll("GOAL SCORER: %s \n NO ASSIST", goal_scorer);
					PrintToChatAll(" \x01\x0B\x05 [SMP5] Goal scorer: \x01\x0B\x03 %s \x01\x0B\x05    No assist", goal_scorer);
				}
			}
		}
		*/
		
	}
	////////////
	if (last_t_activity != -1)
	{ // Cases for T team
		if(winner == CS_TEAM_T)
		{
			last_loser_team = 3;
			goles_tt = goles_tt+1;
			if (postround == 0)
			{
				player_mvps[last_t_activity]=player_mvps[last_t_activity]+1;
				player_scores[last_t_activity]=player_scores[last_t_activity]+SCORE_FOR_GOAL;
			}
			GetClientName(last_t_activity, goal_scorer, sizeof(goal_scorer));
			if ((last_t_pass != -1) && (last_t_pass != last_t_activity))
			{
				if (postround == 0)
				{
					player_assists[last_t_pass]=player_assists[last_t_pass]+1;
					player_scores[last_t_pass]=player_scores[last_t_pass]+SCORE_FOR_ASSIST;
				}
				GetClientName(last_t_pass, assist_name, sizeof(assist_name));
				PrintHintTextToAll("GOAL SCORER: %s \n ASSIST BY: %s", goal_scorer, assist_name);
				PrintToChatAll(" \x01\x0B\x05 [SMP5] Goal scorer: \x01\x0B\x03 %s \x01\x0B\x05       Assist by: \x01\x0B\x03 %s \x01\x0B\x05", goal_scorer, assist_name);
			}
			if ((last_t_pass == -1) || (last_t_pass == last_t_activity))
			{
				PrintHintTextToAll("GOAL SCORER: %s \n NO ASSIST", goal_scorer);
				PrintToChatAll(" \x01\x0B\x05 [SMP5] Goal scorer: \x01\x0B\x03 %s \x01\x0B\x05    No assist", goal_scorer);
			}
		}
		/*
		if(winner == CS_TEAM_CT) // OWN GOAL MADE BY A TT
		{
			last_loser_team = 2;
			goles_ct = goles_ct+1;
			if ((last_t_activity != tt_goalkeeper) || ((last_t_activity == tt_goalkeeper) && ((last_t_pass != -1) || (last_ct_lost == -1))))
			{
				if (last_t_pass == -1)
				{
					if (postround == 0)
					{
						//player_scores[last_t_activity]=player_scores[last_t_activity]+SCORE_FOR_OWN_GOAL;
						player_mvps[last_ct_activity]=player_mvps[last_t_activity]+1;
						player_scores[last_ct_activity]=player_scores[last_t_activity]+SCORE_FOR_GOAL;
					}
					//GetClientName(last_t_activity, goal_scorer, sizeof(goal_scorer));
					GetClientName(last_ct_activity, goal_scorer, sizeof(goal_scorer));
				}
				else
				{
					if (postround == 0)
					{
						//player_scores[last_t_pass]=player_scores[last_t_pass]+SCORE_FOR_OWN_GOAL;
						player_mvps[last_ct_activity]=player_mvps[last_t_activity]+1;
						player_scores[last_ct_activity]=player_scores[last_t_activity]+SCORE_FOR_GOAL;
					}
					//GetClientName(last_t_pass, goal_scorer, sizeof(goal_scorer));
					GetClientName(last_ct_activity, goal_scorer, sizeof(goal_scorer));
				}
				////////////
				if ((last_ct_pass != -1) && (last_ct_pass != last_ct_activity))
				{
					if (postround == 0)
					{
						player_assists[last_ct_pass]=player_assists[last_ct_pass]+1;
						player_scores[last_ct_pass]=player_scores[last_ct_pass]+SCORE_FOR_ASSIST;
					}
					GetClientName(last_ct_pass, assist_name, sizeof(assist_name));
					PrintHintTextToAll("GOAL SCORER: %s \n ASSIST BY: %s", goal_scorer, assist_name);
					PrintToChatAll(" \x01\x0B\x05 [SMP5] Goal scorer: \x01\x0B\x03 %s \x01\x0B\x05       Assist by: \x01\x0B\x03 %s \x01\x0B\x05", goal_scorer, assist_name);
				}
				if ((last_t_pass == -1) || (last_t_pass == last_t_activity))
				{
					PrintHintTextToAll("GOAL SCORER: %s \n NO ASSIST", goal_scorer);
					PrintToChatAll(" \x01\x0B\x05 [SMP5] Goal scorer: \x01\x0B\x03 %s \x01\x0B\x05    No assist", goal_scorer);
				}
				////////////
				//PrintHintTextToAll("OWN GOAL BY: %s ", goal_scorer);
				//PrintToChatAll(" \x01\x0B\x05 [SMP5] Own goal by \x01\x0B\x03 %s \x01\x0B\x05, what a shame!", goal_scorer);
			}
			if ((last_t_activity == tt_goalkeeper) && (last_t_pass == -1) && (last_ct_lost != -1))
			{ // CT GOAL BUT T GK TRIED TO STOP BALL
				char gk_t_name[MAX_NAME_LENGTH] = "";
				GetClientName(tt_goalkeeper, gk_t_name, sizeof(gk_t_name));
				PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 (T GK) tried to stop the ball with no success.", gk_t_name);
				if (postround == 0)
				{
					player_mvps[last_ct_lost]=player_mvps[last_ct_lost]+1;
					player_scores[last_ct_lost]=player_scores[last_ct_lost]+SCORE_FOR_GOAL;
				}
				GetClientName(last_ct_lost, goal_scorer, sizeof(goal_scorer));
				if (last_ct_lost_pass != -1)
				{
					if (postround == 0)
					{
						player_assists[last_ct_lost_pass]=player_assists[last_ct_lost_pass]+1;
						player_scores[last_ct_lost_pass]=player_scores[last_ct_lost_pass]+SCORE_FOR_ASSIST;
					}
					GetClientName(last_ct_lost_pass, assist_name, sizeof(assist_name));
					PrintHintTextToAll("GOAL SCORER: %s \n ASSIST BY: %s", goal_scorer, assist_name);
					PrintToChatAll(" \x01\x0B\x05 [SMP5] Goal scorer: \x01\x0B\x03 %s \x01\x0B\x05       Assist by: \x01\x0B\x03 %s \x01\x0B\x05", goal_scorer, assist_name);
				}
				if (last_ct_lost_pass == -1)
				{
					PrintHintTextToAll("GOAL SCORER: %s \n NO ASSIST", goal_scorer);
					PrintToChatAll(" \x01\x0B\x05 [SMP5] Goal scorer: \x01\x0B\x03 %s \x01\x0B\x05    No assist", goal_scorer);
				}
			}
		}
		*/
	}
	postround = 1;
	if(GameRules_GetProp("m_bWarmupPeriod") == 1)
	{
		StatsToZero();
	}
    PrintToChatAll(" \x01\x0B\x05 [SMP5] Round end.");
}
public Event_PlayerJump(Event event, const char[] name, bool dontBroadcast)
{
	refresh_ball = 0;
    player_id = event.GetInt("userid");
	player_index = GetClientOfUserId(player_id);
	GetClientName(player_index, player_name, sizeof(player_name));
	if ((ball0_invulnerable == 0) && (ball0_control == 1) && (player_grabbing == player_index))
	{
		// Check_Interference(player_grabbing);
		ball0_control = 0;
		player_grabbing = -1;
		Last_Activity(player_index);
		Return_Ball();
		Recover_Speed(player_index);
		if (ball0_delay_e[player_index] == 0)
		{
			ball0_delay_e[player_index]=1;
			delay_timers_e[player_index] = CreateTimer(0.5, timer_delay_e, player_index);
		}
		PrintHintText(player_index, "BALL RELEASED");
		PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 has jumped and lost ball control.", player_name);
		ClientCommand(player_index, "play *customsounds/bloqueo_arb.mp3" );
	}
	refresh_ball = 1;
}
public Event_PlayerHurt(Event event, const char[] name, bool dontBroadcast)
{
	refresh_ball = 0;
	victim_id = event.GetInt("userid");
	victim_index = GetClientOfUserId(victim_id);
	GetClientName(victim_index, victim_name, sizeof(victim_name));
	if ((ball0_invulnerable == 0) && (victim_index == player_grabbing) && (ball0_control == 1))
	{
		// Check_Interference(player_grabbing);
		ball0_control = 0;
		player_grabbing = -1;
		Last_Activity(victim_index);
		Return_Ball();
		if (postround == 0)
		{
			player_scores[victim_index]=player_scores[victim_index]+SCORE_FOR_LOSING;
		}
		Recover_Speed(victim_index);
		if (ball0_delay_e[victim_index] == 0)
		{
			ball0_delay_e[victim_index]=1;
			delay_timers_e[victim_index] = CreateTimer(0.5, timer_delay_e, victim_index);
		}
		PrintHintText(victim_index, "BALL RELEASED");
		PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 was hurted and lost ball control.", victim_name);
		ClientCommand(victim_index, "play *customsounds/bloqueo_arb.mp3" );
	}
	if (ball0_delay_r[victim_index] == 0)
	{
		ball0_delay_r[victim_index]=1;
		delay_timers_r[victim_index] = CreateTimer(0.9, timer_delay_r, victim_index);
	}
	refresh_ball = 1;
}
public Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast)
{
	refresh_ball = 0;
	new death_id = event.GetInt("userid");
	new death_index = GetClientOfUserId(death_id);
	if (player_grabbing == death_index)
	{
		// Check_Interference(player_grabbing);
		GetEntPropVector(ball0, Prop_Send, "m_vecOrigin", ball0_position);
		GetEntPropVector(ball0_dynamic, Prop_Send, "m_vecOrigin", ball0_dynamic_position);
		ball0_invulnerable = 0;
		ball0_control = 0;
		player_grabbing = -1;
		Return_Ball();
		PrintToChatAll(" \x01\x0B\x05 [SMP5] The ball was released.");
	}
	tt_area_touch[death_index]=0;
	ct_area_touch[death_index]=0;
	refresh_ball = 1;
}
public Event_WinPanel(Event event, const char[] name, bool dontBroadcast)
{
	char best_striker[MAX_NAME_LENGTH] = "";
	char best_assist[MAX_NAME_LENGTH] = "";
	char best_defense[MAX_NAME_LENGTH] = "";
	char best_passer[MAX_NAME_LENGTH] = "";
	char best_global[MAX_NAME_LENGTH] = "";
	///////////// Searching highest value in each type of score
	largest_value1 = 0;
	for (new x=1; x<=MaxClients; x++)
	{
		new temp_kills = 0;
		if ((IsClientInGame(x)) && (IsValidEntity(x)))
		{
			temp_kills = player_kills[x];
			//GetEntProp(x, Prop_Data, "m_iFrags", temp_kills);
			if ((temp_kills > largest_value1) && (temp_kills > 0))
			{
				largest_value1 = temp_kills;
				GetClientName(x, best_defense, sizeof(best_defense));
			}
		}
	}
	largest_value2 = 0;
	for (new x=1; x<=MaxClients; x++)
	{
		new temp_deaths = 0;
		if ((IsClientInGame(x)) && (IsValidEntity(x)))
		{
			temp_deaths = player_deaths[x];
			//GetEntProp(x, Prop_Data, "m_iDeaths", temp_deaths);
			if ((temp_deaths > largest_value2) && (temp_deaths > 0))
			{
				largest_value2 = temp_deaths;
				GetClientName(x, best_passer, sizeof(best_passer));
			}
		}
	}
	largest_value3 = 0;
	for (new x=1; x<=MaxClients; x++)
	{
		new temp_assists = 0;
		if ((IsClientInGame(x)) && (IsValidEntity(x)))
		{
			temp_assists = player_assists[x];
			//temp_assists = CS_GetClientAssists(x);
			if ((temp_assists > largest_value3) && (temp_assists > 0))
			{
				largest_value3 = temp_assists;
				GetClientName(x, best_assist, sizeof(best_assist));
			}
		}
	}
	largest_value4 = 0;
	for (new x=1; x<=MaxClients; x++)
	{
		new temp_mvp = 0;
		if ((IsClientInGame(x)) && (IsValidEntity(x)))
		{
			temp_mvp = player_mvps[x];
			//temp_mvp = CS_GetMVPCount(x);
			if ((temp_mvp > largest_value4) && (temp_mvp > 0))
			{
				largest_value4 = temp_mvp;
				GetClientName(x, best_striker, sizeof(best_striker));
			}
		}
	}
	largest_value5 = 0;
	for (new x=1; x<=MaxClients; x++)
	{
		new temp_global = 0;
		if ((IsClientInGame(x)) && (IsValidEntity(x)))
		{
			temp_global = player_scores[x];
			//temp_global = CS_GetClientContributionScore(x);
			if ((temp_global > largest_value5) && (temp_global > 0))
			{
				largest_value5 = temp_global;
				GetClientName(x, best_global, sizeof(best_global));
			}
		}
	}
	////////////////
	if (!StrEqual(best_striker, ""))
	{
		PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 wins award for most goals scored! (MVP)", best_striker);
	}
	else
	{
		PrintToChatAll(" \x01\x0B\x05 [SMP5] No goalscorer in this game. (MVP)");
	}
	if (!StrEqual(best_assist, ""))
	{
		PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 wins award for most assists! (A)", best_assist);
	}
	else
	{
		PrintToChatAll(" \x01\x0B\x05 [SMP5] 0 assists in this game. (A)");
	}
	if (!StrEqual(best_defense, ""))
	{
		PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 wins award for most ball steals! (K)", best_defense);
	}
	else
	{
		PrintToChatAll(" \x01\x0B\x05 [SMP5] 0 ball steals in this game. (K)");
	}
	if (!StrEqual(best_passer, ""))
	{
		PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 wins award for most passes completed! (D)", best_passer);
	}
	else
	{
		PrintToChatAll(" \x01\x0B\x05 [SMP5] 0 passes completed in this game. (D)");
	}
	if (!StrEqual(best_global, ""))
	{
		PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 wins award for most game contribution! (Score)", best_global);
	}
	else
	{
		PrintToChatAll(" \x01\x0B\x05 [SMP5] Empty score for all players.");
	}
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Match end, thanks for playing!");
}

////////****<<<<<< ACTIONS >>>>>>****////////
////////****<<<<<< ACTIONS >>>>>>****////////
////////****<<<<<< ACTIONS >>>>>>****////////

public Action:timer_physics_update(Handle:timer)
{
	Fix_Physics();
	// BALL TRAIL
	int color[4] = {225, 225, 255, 255};
	TE_SetupBeamFollow(ball0, PrecacheModel("materials/sprites/laserbeam.vmt", true), 0, 0.5, 3.0, 0.5, 1, color);
	//TE_SetupBeamFollow(ball0, PrecacheModel("materials/sprites/laserbeam.vmt", true), 0, 1.0, 5.0, 1.0, 1, color);
    TE_SendToAll();
	TE_SetupBeamFollow(ball0_dynamic, PrecacheModel("materials/sprites/laserbeam.vmt", true), 0, 0.5, 3.0, 0.5, 1, color);
	TE_SendToAll();
	/*
	// BALL TRAIL x2
	PrecacheModel("materials/sprites/cbbl_smoke.vmt")
	new color[4] = {225, 225, 255, 255};
	TE_SetupBeamFollow(ball0, PrecacheModel("materials/sprites/cbbl_smoke.vmt"),	0, Float:0.5, Float:10.0, Float:0.1, 0.5, color);
	TE_SetupBeamFollow(ball0_dynamic, PrecacheModel("materials/sprites/cbbl_smoke.vmt"),	0, Float:0.5, Float:10.0, Float:0.1, 0.5, color);
    TE_SendToAll();
	// BALL TRAIL USING BEAMS +COMPLEX
	TE_SetupBeamPoints(ball0_position, ball0_previous_position, PrecacheModel("materials/sprites/cbbl_smoke.vmt"), 0, 0, 0, Float:0.5, Float:6.0, Float:6.0, 2, 0.0, color, 0);
	TE_SetupBeamPoints(ball0_dynamic_position, ball0_dynamic_previous_position, PrecacheModel("materials/sprites/cbbl_smoke.vmt"), 0, 0, 0, Float:0.5, Float:6.0, Float:6.0, 2, 0.0, color, 0);
	TE_SendToAll();
	ball0_previous_position = ball0_position;
	ball0_dynamic_previous_position = ball0_dynamic_position;
	*/
}
public Action:timer_stats_update(Handle:timer)
{
	//refresh_ball = 0;
	//if ((player_grabbing == -1) && (ball0_control == 0) && (ball0_invulnerable == 0) && (ball0_position[2]<=(ball0_pos_init[2]-Z_BOUNDARY)))
	//{ // True if ball0 is under the ground (almost unused)
	//	TeleportEntity(ball0, fix_dest, NULL_VECTOR, NULL_VECTOR);
	//	TeleportEntity(ball0_dynamic, blackbox0_pos_init, NULL_VECTOR, NULL_VECTOR);
	//	for (new k=1; k<=MAXPLAYERS; k++)
	//	{
	//		if ((IsClientInGame(k)) && (IsPlayerAlive(k)) && (IsValidEntity(k)))
	//		{
	//			Recover_Speed(k);
	//		}
	//	}
	//}
	//if ((player_grabbing == -1) && (ball0_control == 0) && (ball0_invulnerable == 0) && ((ball0_position[2]<=(blackbox0_pos_init[2]+GUARIDA_HEIGHT)) && (ball0_position[2]>=(blackbox0_pos_init[2]-GUARIDA_HEIGHT))))
	//{ // True if ball0 is inside blackbox when it should be on the field (so this detects annoying bug)
	//	TeleportEntity(ball0, fix_dest, NULL_VECTOR, NULL_VECTOR);
	//	TeleportEntity(ball0_dynamic, blackbox0_pos_init, NULL_VECTOR, NULL_VECTOR);
	//	for (new k=1; k<=MAXPLAYERS; k++)
	//	{
	//		if ((IsClientInGame(k)) && (IsPlayerAlive(k)) && (IsValidEntity(k)))
	//		{
	//			Recover_Speed(k);
	//		}
	//	}
	//}
	//
	// Ball Trail
	//PrecacheModel("effects/blueblacklargebeam.vmt")
	//new color[4] = {255, 255, 255, 255};
	//TE_SetupBeamFollow(ball0, PrecacheModel("effects/blueblacklargebeam.vmt"),	0, Float:2.0, Float:10.0, Float:6.0, 0, color);
	//TE_SetupBeamFollow(ball0_dynamic, PrecacheModel("effects/blueblacklargebeam.vmt"),	0, Float:2.0, Float:10.0, Float:6.0, 0, color);
	//TE_SendToAll(0.0);
	for (new x=1; x<=MaxClients; x++)
	{
		if ((IsClientInGame(x)) && (IsValidEntity(x)))
		{
			SetEntProp(x, Prop_Data, "m_iFrags", player_kills[x]);
			SetEntProp(x, Prop_Data, "m_iDeaths", player_deaths[x]);
			CS_SetClientAssists(x, player_assists[x]);
			CS_SetMVPCount(x, player_mvps[x]);
			CS_SetClientContributionScore(x, player_scores[x]);
			if (x == tt_goalkeeper)
			{
				PrecacheModel(MODELO_JUGTTGK, true);
				SetEntityModel(x, MODELO_JUGTTGK);
				SetEntityRenderColor(x, 255, 255, 255, 255);
			}
			if (x == ct_goalkeeper)
			{
				PrecacheModel(MODELO_JUGCTGK, true);
				SetEntityModel(x, MODELO_JUGCTGK);
				SetEntityRenderColor(x, 255, 255, 255, 255);
			}
		}
	}
	refresh_ball = 1;
    return Plugin_Continue;
}
public Action:OnTouching(entity, other)
{
    new String:class_name_t[32];
    GetEdictClassname(other, class_name_t, 32);
    new String:trigger_name_t[128];
    GetEntPropString(entity, Prop_Data, "m_iName", trigger_name_t, sizeof(trigger_name_t));
	if (StrEqual(class_name_t, "player", true))
	{
		if ((StrEqual(trigger_name_t, "wall_release", true)) && (other == player_grabbing) && (ball0_invulnerable == 0) && ((other != ct_goalkeeper) || ((other == ct_goalkeeper) && (ct_area_touch[other] == 0))) && ((other != tt_goalkeeper) || ((other == tt_goalkeeper) && (tt_area_touch[other] == 0))))
		{
			refresh_ball = 0;
			ClientCommand(other, "play *customsounds/bloqueo_arb.mp3" );
			// Check_Interference(player_grabbing);
			char other_name_t[MAX_NAME_LENGTH] = "";
			GetClientName(other, other_name_t, sizeof(other_name_t));
			player_grabbing = -1;
			ball0_control = 0;
			ball0_invulnerable = 0;
			Last_Activity(other);
			Return_Ball();
			Recover_Speed(other);
			PrintHintText(other, "BALL RELEASED");
			PrintToChatAll(" \x01\x0B\x05 [SMP5] Server forced \x01\x0B\x03 %s \x01\x0B\x05 to release the ball.", other_name_t);
			refresh_ball = 1;
		}
	}
}

public Action:OnStartTouch(entity, other)
{ // OnStartTouch event action
        new String:class_name[32];
        GetEdictClassname(other, class_name, 32);
		
        new String:trigger_name[128];
        GetEntPropString(entity, Prop_Data, "m_iName", trigger_name, sizeof(trigger_name));

        // AREA DETECTION
        if (StrEqual(class_name, "player", true))
		{
            if (StrEqual(trigger_name, "areatt", true) && (GetClientTeam(other) == 2 )) 
			{
              // A TT IS INSIDE AREA TT
			  tt_area_touch[other]=1;
            }
            if (StrEqual(trigger_name, "areact", true) && (GetClientTeam(other) == 3 )) 
			{
              // A CT IS INSIDE AREA CT
			  ct_area_touch[other]=1;
            }
			if (StrEqual(trigger_name, "wall_release", true))
			{
				ball0_disable[other] = 1;
			}
        }
        return Plugin_Continue;
}

public Action:OnEndTouch(entity, other)
{ // OnEndTouch event action
        new String:class_name[32];
        GetEdictClassname(other, class_name, 32);
		
        new String:trigger_name[128];
        GetEntPropString(entity, Prop_Data, "m_iName", trigger_name, sizeof(trigger_name));

        // AREA DETECTION
        if (StrEqual(class_name, "player", true))
		{
            if (StrEqual(trigger_name, "areatt", true) && (GetClientTeam(other) == 2 )) 
			{
              // A TT IS OUTSIDE AREA TT
			  tt_area_touch[other]=0;
			  if ((other == player_grabbing) && (ball0_invulnerable == 1))
			  {
					refresh_ball = 0;
					ClientCommand(other, "play *customsounds/bloqueo_arb.mp3" );
					// Check_Interference(player_grabbing);
					char other_name[MAX_NAME_LENGTH] = "";
					GetClientName(other, other_name, sizeof(other_name));
					ball0_control = 0;
					ball0_invulnerable = 0;
					player_grabbing = -1;
					Last_Activity(other);
					Return_Ball();
					Recover_Speed(other);
					PrintHintText(other, "BALL RELEASED");
					PrintToChatAll(" \x01\x0B\x05 [SMP5] GK \x01\x0B\x03 %s \x01\x0B\x05 released the ball in order to exit goal box.", other_name);
					refresh_ball = 1;
			  }
            }
            if (StrEqual(trigger_name, "areact", true) && (GetClientTeam(other) == 3 )) 
			{
              // A CT IS OUTSIDE AREA CT
			  ct_area_touch[other]=0;
			  if ((other == player_grabbing) && (ball0_invulnerable == 1))
			  {
					refresh_ball = 0;
					ClientCommand(other, "play *customsounds/bloqueo_arb.mp3" );
					// Check_Interference(player_grabbing);
					char other_name[MAX_NAME_LENGTH] = "";
					GetClientName(other, other_name, sizeof(other_name));
					ball0_control = 0;
					ball0_invulnerable = 0;
					player_grabbing = -1;
					Last_Activity(other);
					Return_Ball();
					Recover_Speed(other);
					PrintHintText(other, "BALL RELEASED");
					PrintToChatAll(" \x01\x0B\x05 [SMP5] GK \x01\x0B\x03 %s \x01\x0B\x05 released the ball in order to exit goal box.", other_name);
					refresh_ball = 1;
			  }
            }
			if ((StrEqual(trigger_name, "wall_release", true)) && (ball0_disable[other] == 1))
			{
				ball0_disable[other] = 0;
			}
        }
        return Plugin_Continue;
}

public Action:Event_JoinTeam(client, const String:command[], argc) 
{
	refresh_ball = 0;
	if ((client == player_grabbing) && (IsClientInGame(client)))
	{
		// Check_Interference(player_grabbing);
		GetEntPropVector(ball0, Prop_Send, "m_vecOrigin", ball0_position);
		GetEntPropVector(ball0_dynamic, Prop_Send, "m_vecOrigin", ball0_dynamic_position);
		ball0_invulnerable = 0;
		ball0_control = 0;
		player_grabbing = -1;
		Last_Activity(client);
		Return_Ball();
		PrintToChatAll(" \x01\x0B\x05 [SMP5] The ball was released because of team switch.");
	}
	if (ct_goalkeeper == client)
	{
		ct_goalkeeper = -1;
		PrintToChatAll(" \x01\x0B\x05 [SMP5] Now CT team does not have a goalkeeper.");
	}
	if (tt_goalkeeper == client)
	{
		tt_goalkeeper = -1;
		PrintToChatAll(" \x01\x0B\x05 [SMP5] Now T team does not have a goalkeeper.");
	}
	steal_reward[client]=0;
	ball0_delay_shift[client]=0;
	ball0_delay_e[client]=0;
	ball0_delay_r[client]=0;
	ball0_delay_e_gk[client]=0;
	ball0_delay_click[client]=0;
	ball0_delay_click_right[client]=0;
	ct_area_touch[client]=0;
	tt_area_touch[client]=0;
	refresh_ball = 1;
    return Plugin_Continue;
}

public Action High_Volume_Sounds_Played (int clients[MAXPLAYERS], int &numClients,
		char sample[PLATFORM_MAX_PATH], int &entity, int &channel, float &volume, int &level,
		int &pitch, int &flags, char soundEntry[PLATFORM_MAX_PATH], int &seed) 
{	// DETECT HIGH VOLUME SOUNDS OF SOME STADIUMS
	if (StrContains(sample, "crowd_generic1.wav") != -1) 
	{
		volume = 0.4;
		return Plugin_Changed;
	}
	if (StrContains(sample, "crowd_generic2.wav") != -1) 
	{
		volume = 0.4;
		return Plugin_Changed;
	}
	if (StrContains(sample, "madrid_sonido.wav") != -1) 
	{
		volume = 0.4;
		return Plugin_Changed;
	}
	if (StrContains(sample, "boca_def3.wav") != -1) 
	{
		volume = 0.5;
		return Plugin_Changed;
	}
	if (StrContains(sample, "river_def.wav") != -1) 
	{
		volume = 0.6;
		return Plugin_Changed;
	}
	if (StrContains(sample, "gcloss_2.wav") != -1) 
	{
		volume = 0.4;
		return Plugin_Changed;
	}
	return Plugin_Continue;
}

public Action:Command_Curve_Left(client, args)
{ // SHIFT+A
	ball0_curve[client]=1;
	PrintToChat(client," \x01\x0B\x05 [SMP5] Curve ball to <<< left on next kick.");
}
public Action:Command_Curve_Right(client, args)
{ // SHIFT+D
	ball0_curve[client]=2;
	PrintToChat(client," \x01\x0B\x05 [SMP5] Curve ball to right >>> on next kick.");
}
public Action:Command_Curve_0(client, args)
{ // SHIFT+S
	ball0_curve[client]=0;
	PrintToChat(client," \x01\x0B\x05 [SMP5] No curve on next kick.");
}
public Action:Command_Stats(client, args)
{
	// Search for stats from database
}
public Action:Command_GK(client, args)
{
	if (GetClientTeam(client) < 2) 
	{
		return;
	}
	char goalkeeper_name[MAX_NAME_LENGTH] = "";
	GetClientName(client, goalkeeper_name, sizeof(goalkeeper_name));
	if ((client == ct_goalkeeper) || (client == tt_goalkeeper))
	{
		PrintToChat(client, " \x01\x0B\x05 [SMP5] You are not the goalkeeper anymore.");
		ClientCommand(client, "play *customsounds/radio_gk_end.mp3" );
		if (GetClientTeam(client) == 2)
		{
			PrecacheModel(MODELO_JUGTT, true);
			SetEntityModel(client, MODELO_JUGTT);
			SetEntityRenderColor(client, 255, 255, 255, 255);
			tt_goalkeeper = -1;
			PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 is not the T goalkeeper anymore.", goalkeeper_name);
		}
		if (GetClientTeam(client) == 3)
		{
			PrecacheModel(MODELO_JUGCT, true);
			SetEntityModel(client, MODELO_JUGCT);
			SetEntityRenderColor(client, 255, 255, 255, 255);
			ct_goalkeeper = -1;
			PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 is not the CT goalkeeper anymore.", goalkeeper_name);
		}
		return;
	}
	if (((ct_goalkeeper == -1) && (GetClientTeam(client)==3) && (ct_area_touch[client] == 1)) || ((tt_goalkeeper == -1) && (GetClientTeam(client)==2) && (tt_area_touch[client] == 1)))
	{
		refresh_ball = 0;
		PrintToChat(client, " \x01\x0B\x05 [SMP5] Now you are the goalkeeper of your team.");
		ClientCommand(client, "play *customsounds/radio_gk_start.mp3" );
		if (player_grabbing == client)
		{ // Release ball in case of being goalkeeper
			// Check_Interference(player_grabbing);
			ball0_control = 0;
			player_grabbing = -1;
			Last_Activity(client);
			Return_Ball();
			Recover_Speed(client);
			PrintHintText(client, "BALL RELEASED");
			PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 released the ball in order to be the goalkeeper.", goalkeeper_name);
		}
		if (GetClientTeam(client) ==2)
		{
			tt_goalkeeper = client;
			PrecacheModel(MODELO_JUGTTGK, true);
			SetEntityModel(client, MODELO_JUGTTGK);
			SetEntityRenderColor(client, 255, 255, 255, 255);
			PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 is the new T goalkeeper", goalkeeper_name);
		}
		if (GetClientTeam(client) ==3)
		{
			ct_goalkeeper = client;
			PrecacheModel(MODELO_JUGCTGK, true);
			SetEntityModel(client, MODELO_JUGCTGK);
			SetEntityRenderColor(client, 255, 255, 255, 255);
			PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 is the new CT goalkeeper", goalkeeper_name);
		}
		refresh_ball = 1;
		return;
	}
	if (((ct_goalkeeper == -1) && (GetClientTeam(client)==3)) || ((tt_goalkeeper == -1) && (GetClientTeam(client)==2)))
	{
		PrintToChat(client, " \x01\x0B\x05 [SMP5] You must be inside the goal box to use this command.");
		return;
	}
	PrintToChat(client, " \x01\x0B\x05 [SMP5] You cannot be goalkeeper, there is one already.");
	return;
}
/* */	/* */	/* */	/* */	/* */	/* */	/* */	/* */	/* */	/* */	/* */
//	ADMIN COMANDS
//	ADMIN COMANDS
//	ADMIN COMANDS
//	ADMIN COMANDS
/* */	/* */	/* */	/* */	/* */	/* */	/* */	/* */	/* */	/* */	/* */
public Action:Command_Delete_Database(client, args)
{
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Database deleted.");
	return Plugin_Continue;
}
public Fix_Physics()
{
	new f = -1;
	new while_count = 0;
	// New mass for ball0
	SetVariantFloat(26.0);
	AcceptEntityInput(ball0, "SetMass");
	DispatchKeyValue(ball0, "overridescript", "mass,26.0");
	// Starts to search for any trigger_push available
	while ((f = FindEntityByClassname(f, "trigger_push")) != -1)
	{
		// Finds all trigger_push
		char push_trigger_name[32] = "";
		GetEntPropString(f, Prop_Data, "m_iName", push_trigger_name, 32);
		// TRIGGERS PUSH LEFT
		if (strcmp(push_trigger_name, "trigpushleft1") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft2") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft3") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft4") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft5") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft6") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft7") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft8") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft9") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft10") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft11") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft12") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft13") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft14") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft15") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft16") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft17") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft18") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft19") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft20") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft21") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft22") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft23") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft24") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft25") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft26") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft27") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft28") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft29") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft30") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft31") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft32") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft33") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft34") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft35") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft36") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft37") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft38") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft39") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushleft40") == 0)
		{
			Change_Trigger_Left(f);
			while_count = while_count + 1;
		}
		// TRIGGERS PUSH RIGHT
		if (strcmp(push_trigger_name, "trigpushright1") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright2") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright3") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright4") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright5") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright6") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright7") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright8") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright9") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright10") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright11") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright12") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright13") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright14") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright15") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright16") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright17") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright18") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright19") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright20") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright21") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright22") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright23") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright24") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright25") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright26") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright27") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright28") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright29") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright30") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright31") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright32") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright33") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright34") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright35") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright36") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright37") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright38") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright39") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		if (strcmp(push_trigger_name, "trigpushright40") == 0)
		{
			Change_Trigger_Right(f);
			while_count = while_count + 1;
		}
		// While counter comes to end
		if (while_count >= 80)
		{
			while_count = 0;
			break;
		}
	}
	//PrintToChatAll(" \x01\x0B\x05 [SMP5] Game physics has changed.");
}
public Change_Trigger_Left(f)
{
	//AcceptEntityInput(f, "Disable"); 
	DispatchKeyValue(f, "overridescript", "speed,7500");
	//AcceptEntityInput(f, "Enable");
	//AcceptEntityInput(f, "Disable"); 
}
public Change_Trigger_Right(f)
{
	//AcceptEntityInput(f, "Disable");
	DispatchKeyValue(f, "overridescript", "speed,11000");
	//AcceptEntityInput(f, "Enable");
	//AcceptEntityInput(f, "Disable");
}
public Action:Command_Admin_Ball(client, args)
{
	refresh_ball = 0;
	new Float:admin_pos[3];
	new Float:admin_eye_angles[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", admin_pos);
	GetClientEyeAngles(client, admin_eye_angles);
	cos = Cosine(DegToRad(admin_eye_angles[1]));
	sin = Sine(DegToRad(admin_eye_angles[1]));
	admin_pos[0] = admin_pos[0] + cos*(SCALE_E_DISTANCE);
	admin_pos[1] = admin_pos[1] + sin*(SCALE_E_DISTANCE);
	admin_pos[2] += 50;
	if (player_grabbing != -1)
	{
		Recover_Speed(player_grabbing);
		Last_Activity(player_grabbing);
		// Check_Interference(player_grabbing);
		ball0_control = 0;
		ball0_invulnerable = 0;
		player_grabbing = -1;
		Return_Ball();
		TeleportEntity(ball0, admin_pos, NULL_VECTOR, NULL_VELOCITY);
	}
	else
	{
		TeleportEntity(ball0, admin_pos, NULL_VECTOR, NULL_VELOCITY);
	}
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Admin teleported the ball to his/her position.");
	refresh_ball = 1;
	return Plugin_Continue;
}
public Action:Command_Spawn_Ball(client, args)
{
    new PropSpawned;
	new Float:admin_pos[3];
	new Float:admin_eye_angles[3];
	new Float:spawned_mass = 69.0;
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", admin_pos);
	GetClientEyeAngles(client, admin_eye_angles);
	cos = Cosine(DegToRad(admin_eye_angles[1]));
	sin = Sine(DegToRad(admin_eye_angles[1]));
	admin_pos[0] = admin_pos[0] + cos*(SCALE_E_DISTANCE);
	admin_pos[1] = admin_pos[1] + sin*(SCALE_E_DISTANCE);
    admin_pos[2] += 70;
    PropSpawned = CreateEntityByName("prop_physics");
    PrecacheModel(ball0_model_name);
    DispatchKeyValue(PropSpawned, "model", ball0_model_name);
    DispatchSpawn(PropSpawned);
	TeleportEntity(PropSpawned, admin_pos, NULL_VECTOR, NULL_VELOCITY);
	SetVariantFloat(26.0);
	AcceptEntityInput(PropSpawned, "SetMass");
	DispatchKeyValue(PropSpawned, "overridescript", "mass,26.0");
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Admin spawned a training ball.");
	spawned_mass = GetEntPropFloat(PropSpawned, Prop_Send, "m_fMass");
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Training Ball Mass: m=%f ", spawned_mass);
	return Plugin_Continue;
}
public Action:Command_Admin_Remove(client, args)
{
	refresh_ball = 0;
	if (player_grabbing != -1)
	{
		Recover_Speed(player_grabbing);
		Last_Activity(player_grabbing);
		// Check_Interference(player_grabbing);
		ball0_control = 0;
		ball0_invulnerable = 0;
		player_grabbing = -1;
		Return_Ball();
		TeleportEntity(ball0, blackbox0_pos_init, NULL_VECTOR, NULL_VELOCITY);
	}
	else
	{
		TeleportEntity(ball0, blackbox0_pos_init, NULL_VECTOR, NULL_VELOCITY);
	}
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Admin removed the ball.");
	refresh_ball = 1;
	return Plugin_Continue;
}

public Action:Command_Admin_Fight(client, args)
{
	new f = -1;
	while ((f = FindEntityByClassname(f,"filter_damage_type")) != -1)
	{
		AcceptEntityInput(f, "Kill");
		break;
	}
	for (new ie = 1; ie <= 40; ie++)
	{
		new fe = -1;
		while ((fe = FindEntityByClassname(fe,"trigger_hurt")) != -1)
		{
			AcceptEntityInput(fe, "Kill");
			break;
		}
	}
	for (new l=1; l<=MAXPLAYERS; l++)
	{
		if (IsPlayerAlive(l))
		{
			SetEntProp(l, Prop_Data, "m_iMaxHealth", 100);
			SetEntProp(l, Prop_Data, "m_iHealth", 100);
			SetEntityHealth(l, 100);
		}
	}
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Admin started a deadly knife fight in this round.");
	return Plugin_Continue;
}
public Action:Command_Goal_Disable(client, args)
{
	// Disable goals in current round
	new f = -1;
	while ((f = FindEntityByClassname(f, "game_round_end")) != -1)
	{
		char entity_name[32] = "";
		GetEntPropString(f, Prop_Data, "m_iName", entity_name, sizeof(entity_name));
		if (strcmp(entity_name, "round_end") == 0)
		{
			AcceptEntityInput(f, "Kill");
			break;
		}
	}
	/*
	while ((f = FindEntityByClassname(f, "trigger_multiple")) != -1)
	{
		char goal_trigger_name[32] = "";
		GetEntPropString(f, Prop_Data, "m_iName", goal_trigger_name, sizeof(goal_trigger_name));
		if (strcmp(goal_trigger_name, "ct_But") == 0)
		{
			AcceptEntityInput(f, "Kill");
			while_count = while_count + 1;
		}
		if (strcmp(goal_trigger_name, "terro_But") == 0)
		{
			AcceptEntityInput(f, "Kill");
			while_count = while_count + 1;
		}
		if (while_count >= 2)
		{
			while_count = 0;
			break;
		}
	}
	f = -1;
	while_count = 0;
	while ((f = FindEntityByClassname(f, "trigger_once")) != -1)
	{
		char goal_trigger_name[32] = "";
		GetEntPropString(f, Prop_Data, "m_iName", goal_trigger_name, sizeof(goal_trigger_name));
		if (strcmp(goal_trigger_name, "lineact") == 0)
		{
			AcceptEntityInput(f, "Kill");
			while_count = while_count + 1;
		}
		if (strcmp(goal_trigger_name, "lineatt") == 0)
		{
			AcceptEntityInput(f, "Kill");
			while_count = while_count + 1;
		}
		if (while_count >= 2)
		{
			while_count = 0;
			break;
		}
	}
	*/
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Goals disabled (training mode ON)");
	return Plugin_Continue;
}
public Action:Command_Goal_Enable(client, args)
{
	// Enable goals in current round
	/*
	new f = -1;
	new while_count = 0;
	while ((f = FindEntityByClassname(f, "trigger_multiple")) != -1)
	{
		char goal_trigger_name[32] = "";
		GetEntPropString(f, Prop_Data, "m_iName", goal_trigger_name, sizeof(goal_trigger_name));
		if (strcmp(goal_trigger_name, "ct_But") == 0)
		{
			AcceptEntityInput(f, "Enable");
			while_count = while_count + 1;
		}
		if (strcmp(goal_trigger_name, "terro_But") == 0)
		{
			AcceptEntityInput(f, "Enable");
			while_count = while_count + 1;
		}
		if (while_count >= 2)
		{
			while_count = 0;
			break;
		}
	}
	f = -1;
	while_count = 0;
	while ((f = FindEntityByClassname(f, "trigger_once")) != -1)
	{
		char goal_trigger_name[32] = "";
		GetEntPropString(f, Prop_Data, "m_iName", goal_trigger_name, sizeof(goal_trigger_name));
		if (strcmp(goal_trigger_name, "lineact") == 0)
		{
			AcceptEntityInput(f, "Enable");
			while_count = while_count + 1;
		}
		if (strcmp(goal_trigger_name, "lineatt") == 0)
		{
			AcceptEntityInput(f, "Enable");
			while_count = while_count + 1;
		}
		if (while_count >= 2)
		{
			while_count = 0;
			break;
		}
	}
	*/
	Round_Draw();
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Goals enabled (Normal mode)");
	return Plugin_Continue;
}
public Action:Command_Freeze_All(client, args)
{
	// Freeze all players
	for (new i=1 ; i<=MAXPLAYERS; i++)
	{
		if ((i != client) && (IsClientInGame(i)) && (IsPlayerAlive(i)))
		{
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 0.0);
			SetEntityMoveType(client, MOVETYPE_NONE);
			SetEntityRenderColor(i, 255, 0, 170, 174);
		}
	}
	PrintToChatAll(" \x01\x0B\x05 [SMP5] All players frozen by admin.");
	return Plugin_Continue;
}
public Action:Command_Unfreeze_All(client, args)
{
	// Unfreeze all players
	for (new i=1 ; i<=MAXPLAYERS; i++)
	{
		if ((IsClientInGame(i)) && (IsPlayerAlive(i)))
		{
			SetEntPropFloat(i, Prop_Data, "m_flLaggedMovementValue", 1.0);
			SetEntityMoveType(i, MOVETYPE_WALK); 
			SetEntityRenderColor(i, 255, 255, 255, 255);
		}
	}
	PrintToChatAll(" \x01\x0B\x05 [SMP5] All players are free now.");
	return Plugin_Continue;
}
public Action:Command_CT_Teleport(client, args)
{
	new Float:admin_pos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", admin_pos);
    for(new i = 1; i <= MAXPLAYERS; i++)
    {
		if (IsClientInGame(i) && (!IsFakeClient(i))) 
		{
			if (GetClientTeam(i) == 3)
			{
				TeleportEntity(i, admin_pos, NULL_VECTOR, NULL_VECTOR);
			}
		}
    }
	PrintToChatAll(" \x01\x0B\x05 [SMP5] CT team teleported to admin position.");
	return Plugin_Continue;
}
public Action:Command_TT_Teleport(client, args)
{
	new Float:admin_pos[3];
	GetEntPropVector(client, Prop_Send, "m_vecOrigin", admin_pos);
    for(new i = 1; i <= MAXPLAYERS; i++)
    {
		if (IsClientInGame(i) && (!IsFakeClient(i))) 
		{
			if (GetClientTeam(i) == 2)
			{
				TeleportEntity(i, admin_pos, NULL_VECTOR, NULL_VECTOR);
			}
		}
    }
	PrintToChatAll(" \x01\x0B\x05 [SMP5] T team teleported to admin position.");
	return Plugin_Continue;
}
public Action:Command_CT_Wins(client, args)
{
	// CT Wins
	goles_ct = goles_ct+1;
	CS_SetTeamScore(CS_TEAM_CT, goles_ct);
	SetTeamScore(CS_TEAM_CT, goles_ct);
	new Handle:event = CreateEvent("cs_win_panel_round") 
	SetEventBool(event, "show_timer_defend", true)
	SetEventBool(event, "show_timer_attack", true)
	SetEventInt(event, "timer_time", 10)
	SetEventInt(event, "final_event", _:CSRoundEnd_CTWin)
	CS_TerminateRound(10.0, CSRoundEnd_TargetSaved, false);
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Referee makes CT team win this round!");
	return Plugin_Continue;
}
public Action:Command_TT_Wins(client, args)
{
	// TT Wins
	goles_tt = goles_tt+1;
	CS_SetTeamScore(CS_TEAM_T, goles_tt);
	SetTeamScore(CS_TEAM_T, goles_tt);
	new Handle:event = CreateEvent("cs_win_panel_round") 
	SetEventBool(event, "show_timer_defend", true)
	SetEventBool(event, "show_timer_attack", true)
	SetEventInt(event, "timer_time", 10)
	SetEventInt(event, "final_event", _:CSRoundEnd_TerroristWin)
	CS_TerminateRound(10.0, CSRoundEnd_TargetBombed, false);
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Referee makes T team win this round!");
	return Plugin_Continue;
}
public Action:Command_CT_Point(client, args)
{
	// Adds one goal to CT team
	goles_ct = goles_ct+1;
	CS_SetTeamScore(CS_TEAM_CT, goles_ct);
	SetTeamScore(CS_TEAM_CT, goles_ct);
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Added +1 point to CT team.");
	return Plugin_Continue;
}
public Action:Command_TT_Point(client, args)
{
	// Adds one goal to T team
	goles_tt = goles_tt+1;
	CS_SetTeamScore(CS_TEAM_T, goles_tt);
	SetTeamScore(CS_TEAM_T, goles_tt);
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Added +1 point to T team.");
	return Plugin_Continue;
}
public Action:Command_CT_Substract(client, args)
{
	// Substracts one goal from CT team
	goles_ct = goles_ct-1;
	CS_SetTeamScore(CS_TEAM_CT, goles_ct);
	SetTeamScore(CS_TEAM_CT, goles_ct);
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Substracted -1 point to CT team.");
	return Plugin_Continue;
}
public Action:Command_TT_Substract(client, args)
{
	// Substracts one goal from T team
	goles_tt = goles_tt-1;
	CS_SetTeamScore(CS_TEAM_T, goles_tt);
	SetTeamScore(CS_TEAM_T, goles_tt);
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Substracted -1 point to T team.");
	return Plugin_Continue;
}
public Action:Command_Clean_Score(client, args)
{
	// Cleans team scoreboards
	goles_ct = 0;
	goles_tt = 0;
	CS_SetTeamScore(CS_TEAM_CT, goles_ct);
	SetTeamScore(CS_TEAM_CT, goles_ct);
	CS_SetTeamScore(CS_TEAM_T, goles_tt);
	SetTeamScore(CS_TEAM_T, goles_tt);
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Scoreboard restarted.");
	return Plugin_Continue;
}
public Action:Command_Round_Draw(client, args)
{
	Round_Draw();
	return Plugin_Continue;
}
public Action:Command_Ball_Info(client, args)
{
	new Float:ball0_mass = 69.0;
	ball0_mass = GetEntPropFloat(ball0, Prop_Send, "m_fMass");
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Ball Location: X1=%f Y1=%f Z1=%f ", ball0_position[0],ball0_position[1],ball0_position[2])
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Ball Mass: m=%f ", ball0_mass)
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Dynamic Ball Location: X2=%f Y2=%f Z2=%f ", ball0_dynamic_position[0],ball0_dynamic_position[1],ball0_dynamic_position[2])
	return Plugin_Continue;
}

/* */	/* */	/* */	/* */	/* */	/* */	/* */	/* */	/* */	/* */	/* */
//	TIMERS
//	TIMERS
//	TIMERS
//	TIMERS
/* */	/* */	/* */	/* */	/* */	/* */	/* */	/* */	/* */	/* */	/* */
public Action:timer_curve_ball(Handle:timer)
{
	if (curve_counter >= 16)
	{
		curve_counter = 0;
		return Plugin_Stop;
	}
	GetEntPropVector(ball0, Prop_Send, "m_vecOrigin", ball0_position);
	if ((ball0_position[2] < ball0_pos_init[2]+MAX_CURVE_HEIGHT) && (ball0_position[2] >= ball0_pos_init[2]))
	{
		if (last_curve == 1)
		{
			Curve_Brush_Left();
		}
		if (last_curve == 2)
		{
			Curve_Brush_Right();
		}
	}
	curve_counter++;
	return Plugin_Continue;
}
public Action:Curve_Brush_Left()
{
	new Float:curve_angles_left[3];
    GetEntPropVector(ball0, Prop_Send, "m_vecOrigin", ball0_position);
	GetClientEyeAngles(curve_client, original_angles);
    curve_angles_left[0] = original_angles[0];
    curve_angles_left[1] = original_angles[1] + 90.0;
    if (curve_angles_left[1] > 180.0 )
	{
		curve_angles_left[1] -= 360.0;
    }
    curve_angles_left[2] = original_angles[2];

    new push_entity = CreateEntityByName("trigger_push");
    if (push_entity != -1)
    {
        //DispatchKeyValue(push_entity, "speed", "85");
		DispatchKeyValue(push_entity, "speed", "110");
        DispatchKeyValue(push_entity, "spawnflags", "8");
    }
    DispatchSpawn(push_entity);
    ActivateEntity(push_entity);
	TeleportEntity(push_entity, ball0_position, curve_angles_left, NULL_VECTOR);
	new Float:minbounds[3] = {-300.0, -300.0, 0.0};
	new Float:maxbounds[3] = {300.0, 300.0, 600.0};
    SetEntPropVector(push_entity, Prop_Send, "m_vecMins", minbounds);
    SetEntPropVector(push_entity, Prop_Send, "m_vecMaxs", maxbounds);
    SetEntProp(push_entity, Prop_Send, "m_nSolidType", 2);
    SetEntProp(push_entity, Prop_Send, "m_fEffects", 32);  
    CreateTimer(0.3, destroy_last_push, push_entity);
}
public Action:Curve_Brush_Right()
{
	new Float:curve_angles_left[3];
    GetEntPropVector(ball0, Prop_Send, "m_vecOrigin", ball0_position);
	GetClientEyeAngles(curve_client, original_angles);
    curve_angles_left[0] = original_angles [0];
    curve_angles_left[1] = original_angles [1] - 90.0;
    if (curve_angles_left[1] < -180.0 )
	{
		curve_angles_left[1] += 360.0;
    }
    curve_angles_left[2] = original_angles [2];

    new push_entity = CreateEntityByName("trigger_push");
    if (push_entity != -1)
    {
        //DispatchKeyValue(push_entity, "speed", "85");
		DispatchKeyValue(push_entity, "speed", "110");
        DispatchKeyValue(push_entity, "spawnflags", "8");
    }
    DispatchSpawn(push_entity);
    ActivateEntity(push_entity);
	TeleportEntity(push_entity, ball0_position, curve_angles_left, NULL_VECTOR);
	new Float:minbounds[3] = {-300.0, -300.0, 0.0};
	new Float:maxbounds[3] = {300.0, 300.0, 600.0};
    SetEntPropVector(push_entity, Prop_Send, "m_vecMins", minbounds);
    SetEntPropVector(push_entity, Prop_Send, "m_vecMaxs", maxbounds);
    SetEntProp(push_entity, Prop_Send, "m_nSolidType", 2);
    SetEntProp(push_entity, Prop_Send, "m_fEffects", 32); 
    CreateTimer(0.3, destroy_last_push, push_entity);
}
public Action:destroy_last_push(Handle:timer, any:push_entity)
{
	RemoveParticleNow(push_entity);
	return Plugin_Stop;
}
stock RemoveParticleNow(any:particle)
{
    if(IsValidEdict(particle))
    {
        AcceptEntityInput(particle, "Deactivate");
        AcceptEntityInput(particle, "Kill");
    }
}

public Action:timer_delay_click(Handle:timer, any clientx)
{
	ball0_delay_click[clientx]=0;
	KillTimer(delay_timers_click[clientx]);
	delay_timers_click[clientx] = null;
	//PrintToChat(clientx, " \x01\x0B\x05 [SMP5] Your SHIFT cooldown has expired");
}
public Action:timer_delay_click_right(Handle:timer, any clientx)
{
	ball0_delay_click_right[clientx]=0;
	KillTimer(delay_timers_click_right[clientx]);
	delay_timers_click_right[clientx] = null;
	//PrintToChat(clientx, " \x01\x0B\x05 [SMP5] Your SHIFT cooldown has expired");
}
public Action:timer_delay_shift(Handle:timer, any clientx)
{
	ball0_delay_shift[clientx]=0;
	KillTimer(delay_timers_shift[clientx]);
	delay_timers_shift[clientx] = null;
	//PrintToChat(clientx, " \x01\x0B\x05 [SMP5] Your SHIFT cooldown has expired");
}
public Action:timer_delay_r(Handle:timer, any clientx)
{
	ball0_delay_r[clientx]=0;
	KillTimer(delay_timers_r[clientx]);
	delay_timers_r[clientx] = null;
}
public Action:timer_delay_e(Handle:timer, any clientx)
{
	ball0_delay_e[clientx]=0;
	KillTimer(delay_timers_e[clientx]);
	delay_timers_e[clientx] = null;
	//PrintToChat(clientx, " \x01\x0B\x05 [SMP5] Your E cooldown has expired");
}
public Action:timer_delay_e_gk(Handle:timer, any clientx)
{
	ball0_delay_e_gk[clientx]=0;
	KillTimer(delay_timers_e_gk[clientx]);
	delay_timers_e_gk[clientx] = null;
	//PrintToChat(clientx, " \x01\x0B\x05 [SMP5] Your GK E cooldown has expired");
}
public Action:timer_delay_curve(Handle:timer, any clientx)
{
	curve_delay[clientx]=0;
	KillTimer(delay_timers_curve[clientx]);
	delay_timers_curve[clientx] = null;
}
public Action:timer_invulnerable_e(Handle:timer, any clientx)
{
	refresh_ball = 0;
	if ((player_grabbing == clientx) && (ball0_invulnerable == 1))
	{
		// Check_Interference(player_grabbing);
		player_grabbing = -1;
		ball0_control = 0;
		ball0_invulnerable = 0;
		Return_Ball();
		Recover_Speed(clientx);
		PrintHintText(clientx, "BALL RELEASED");
		char gk_name[MAX_NAME_LENGTH] = "";
		GetClientName(clientx, gk_name, sizeof(gk_name));
		PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 released the ball after 9 seconds of invulnerability.", gk_name);
	}
	refresh_ball = 1;
	KillTimer(delay_timers_invulnerable[clientx]);
	delay_timers_invulnerable[clientx] = null;
}


////////****<<<<<< HANDLERS >>>>>>****////////
////////****<<<<<< HANDLERS >>>>>>****////////
////////****<<<<<< HANDLERS >>>>>>****////////

////////****<<<<<< EXTRA FUNCTIONS >>>>>>****////////
////////****<<<<<< EXTRA FUNCTIONS >>>>>>****////////
////////****<<<<<< EXTRA FUNCTIONS >>>>>>****////////
public StatsToZero()
{
	goles_ct = 0;
	goles_tt = 0;
	last_loser_team = 0;
	for (new x=1; x<=MAXPLAYERS; x++)
	{
		player_kills[x]=0;
		player_assists[x]=0;
		player_deaths[x]=0;
		player_mvps[x]=0;
		player_scores[x]=0;
	}
}

public SetVariablesToZero()
{
	ball0_invulnerable = 0;
	ball0_control = 0;
	postround = 0;
	refresh_ball = 1;
	player_grabbing = -1;
	player_index = -1;
	victim_index = -1;
	last_ct_activity = -1;
	last_t_activity = -1;
	last_ct_pass = -1;
	last_t_pass = -1;
	last_ct_lost = -1;
	last_t_lost = -1;
	last_ct_lost_pass = -1;
	last_t_lost_pass = -1;
	curve_counter = 0;
	last_curve = 0;
	forward_mode = 0;
	backwards_mode = 0;
	timer_physics_handle = null;
	for (new x=1; x<=MAXPLAYERS; x++)
	{
		ball0_curve[x]=0;
		curve_delay[x]=0;
		ct_area_touch[x]=0;
		tt_area_touch[x]=0;
		steal_reward[x]=0;
		ball0_disable[x]=0;
		ball0_delay_shift[x]=0; // example [4]=0 means no delay for player 4
		ball0_delay_r[x]=0;
		ball0_delay_e[x]=0;
		ball0_delay_e_gk[x]=0;
		ball0_delay_click[x]=0;
		ball0_delay_click_right[x]=0;
		delay_timers_click[x]=null;
		delay_timers_click_right[x]=null;
		delay_timers_shift[x]=null;
		delay_timers_r[x]=null;
		delay_timers_e[x]=null;
		delay_timers_e_gk[x]=null;
	}
}

public Find_Ball() // Stores information about ball0
{
	new i = -1;
	while ((i = FindEntityByClassname(i,"prop_dynamic_override")) != -1)
	{
		char cover0_parent[32] = "";
		GetEntPropString(i, Prop_Data, "m_iParent", cover0_parent, sizeof(cover0_parent));
		if (strcmp(cover0_parent, "pelota0") == 0)
		{	// Founded dynamic override
			GetEntPropString(i, Prop_Data, "m_ModelName", ball0_model_name, 128);
			PrecacheModel(ball0_model_name, true);
			//PrintToChatAll(" \x01\x0B\x05 [SMP5] Model name: %s", ball0_model_name);
			break;
		}
	
	}
	new j = -1;
	while ((j = FindEntityByClassname(j,"func_physbox")) != -1)
	{
		char ball0_name[32] = "";
		GetEntPropString(j, Prop_Data, "m_iName", ball0_name, sizeof(ball0_name));
		if (strcmp(ball0_name, "pelota0") == 0)
		{	// Founded
			ball0 = j;
			GetEntPropVector(j, Prop_Send, "m_vecOrigin", ball0_pos_init);
			dest_origin = ball0_pos_init;
			fix_dest = ball0_pos_init;
			ball0_previous_position = ball0_pos_init;
			TeleportEntity(ball0, ball0_pos_init, NULL_VECTOR, NULL_VECTOR);
			TeleportEntity(ball0_dynamic, blackbox0_pos_init, NULL_VECTOR, NULL_VECTOR);
			break;
		}
	}
}

public Find_Black_Box() // Finds black hole and creates new ball
{
	new i = -1;
	while ((i = FindEntityByClassname(i,"info_target")) != -1)
	{
		char blackbox0_name[32] = "";
		GetEntPropString(i, Prop_Data, "m_iName", blackbox0_name, sizeof(blackbox0_name));
		if (strcmp(blackbox0_name, "guarida") == 0)
		{	// Black box "guarida"
			GetEntPropVector(i, Prop_Send, "m_vecOrigin", blackbox0_pos_init);
			ball0_dynamic = CreateEntityByName("prop_dynamic_override");
			//ball0_dynamic = CreateEntityByName("prop_physics_multiplayer");
			DispatchKeyValue(ball0_dynamic, "name", "pelota0_dynamic");
			DispatchKeyValue(ball0_dynamic, "model", ball0_model_name);
			//DispatchKeyValue(ball0_dynamic, "spawnflags", "4096");
			SetEntProp(ball0_dynamic, Prop_Send, "m_usSolidFlags", 12); //FSOLID_NOT_SOLID|FSOLID_TRIGGER
			SetEntProp(ball0_dynamic, Prop_Data, "m_nSolidType", 6); // SOLID_VPHYSICS
			SetEntProp(ball0_dynamic, Prop_Send, "m_CollisionGroup", 1); //COLLISION_GROUP_DEBRIS  
			DispatchSpawn(ball0_dynamic);
			SetEntityModel(ball0_dynamic, ball0_model_name);
			if(ball0_dynamic != -1)
			{
				TeleportEntity(ball0_dynamic, blackbox0_pos_init, NULL_VECTOR, NULL_VECTOR);
				ball0_dynamic_previous_position = ball0_dynamic_position;
			}
			break;
		}
	
	}
}

public Stop_Ball()
{
	AcceptEntityInput(ball0, "Sleep");
}
public Wake_Ball()
{
	AcceptEntityInput(ball0, "Wake");
}
stock GetRandomPlayer(team) 
{ 
    new clients[MaxClients+1], clientCount; 
    for (new i = 1; i <= MaxClients; i++) 
        if (IsClientInGame(i) && (GetClientTeam(i) == team)) 
            clients[clientCount++] = i; 
    return (clientCount == 0) ? -1 : clients[GetRandomInt(0, clientCount-1)]; 
}
public Attract_Ball(clientx)
{
	GetEntPropVector(clientx, Prop_Send, "m_vecOrigin", client_origin);
	GetClientAbsOrigin(clientx, client_origin);
	GetClientEyeAngles(clientx, client_eye_angles);
	cos = Cosine(DegToRad(client_eye_angles[1]));
	sin = Sine(DegToRad(client_eye_angles[1]));
	// FORWARD & BACKWARDS
	if ((forward_mode == 1) || (backwards_mode == 1))
	{
		if (forward_mode == 1)
		{
			dest_origin[0] = client_origin[0] + cos*(SCALE_R_DISTANCE);
			dest_origin[1] = client_origin[1] + sin*(SCALE_R_DISTANCE);
			dest_origin[2] = client_origin[2] + NORMAL_E_HEIGHT;
		}
		if (backwards_mode == 1)
		{
			dest_origin[0] = client_origin[0] + cos*(SCALE_R_BACKWARDS_DISTANCE);
			dest_origin[1] = client_origin[1] + sin*(SCALE_R_BACKWARDS_DISTANCE);
			dest_origin[2] = client_origin[2] + NORMAL_E_HEIGHT;
		}
	}
	else
	{ // SIDEWAYS
		dest_origin[0] = client_origin[0] + cos*(SCALE_E_DISTANCE);
		dest_origin[1] = client_origin[1] + sin*(SCALE_E_DISTANCE);
		dest_origin[2] = client_origin[2] + NORMAL_E_HEIGHT;
	}
	vector_difference[0] = (dest_origin[0] - ball0_position[0]) * ATTRACT_MULTIPLIER;
	vector_difference[1] = (dest_origin[1] - ball0_position[1]) * ATTRACT_MULTIPLIER;
	vector_difference[2] = dest_origin[2] - ball0_position[2];
	TeleportEntity(ball0, NULL_VECTOR, NULL_VECTOR, vector_difference);
}
public SetCvar(String:cvarName[64], value)
{
	new Handle:cvar;
	cvar = FindConVar(cvarName);

	new flags = GetConVarFlags(cvar);
	flags &= ~FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);

	SetConVarInt(cvar, value);

	flags |= FCVAR_NOTIFY;
	SetConVarFlags(cvar, flags);
}
public Return_Ball()
{
	//dest_origin = ball0_dynamic_position;
	//dest_origin[0] = client_origin[0] + cos*(SCALE_E_DISTANCE);
	//dest_origin[1] = client_origin[1] + sin*(SCALE_E_DISTANCE);
	//if(ball0_invulnerable == 1)
	//{
		//dest_origin[2] = client_origin[2] + GK_E_HEIGHT;
	//}
	if (ball0_invulnerable == 0)
	{
		Set_Speed_With_Ball(player_grabbing);
		//dest_origin[2] = client_origin[2] + NORMAL_E_HEIGHT;
	}	
	//if (dest_origin[2] < ball0_pos_init[2]-NORMAL_E_HEIGHT)
	//{ // Destination is under the ground so it applies a fixed position
	//	dest_origin[0] = client_origin[0] + cos*(SCALE_E_DISTANCE);
	//	dest_origin[1] = client_origin[1] + sin*(SCALE_E_DISTANCE);
	//	dest_origin[2] = client_origin[2] + NORMAL_E_HEIGHT;
	//}
	//if (ball0_dynamic_position[2] < ball0_pos_init[2]-NORMAL_E_HEIGHT)
	//{ // Dynamic ball is under the ground so it applies another fixed position
	//	dest_origin[0] = client_origin[0] + cos*(SCALE_E_DISTANCE);
	//	dest_origin[1] = client_origin[1] + sin*(SCALE_E_DISTANCE);
	//	dest_origin[2] = client_origin[2] + NORMAL_E_HEIGHT;
	//}
	//if (ball0_dynamic_position[2] > ball0_pos_init[2]-NORMAL_E_HEIGHT)
	//{ // Everything is working fine so there is no fix needed
	//	dest_origin = ball0_dynamic_position;
	//}
	TeleportEntity(ball0, ball0_dynamic_position, NULL_VECTOR, NULL_VECTOR);
	TeleportEntity(ball0_dynamic, blackbox0_pos_init, NULL_VECTOR, NULL_VECTOR);
	Wake_Ball();
}
public Hide_Ball()
{
	Stop_Ball();
	TeleportEntity(ball0, blackbox0_pos_init, NULL_VECTOR, NULL_VECTOR);
	GetEntPropVector(player_grabbing, Prop_Send, "m_vecOrigin", player_grabbing_position);
	GetClientAbsOrigin(player_grabbing, client_origin);
	GetClientEyeAngles(player_grabbing, client_eye_angles);
	cos = Cosine(DegToRad(client_eye_angles[1]));
	sin = Sine(DegToRad(client_eye_angles[1]));
	dest_origin[0] = client_origin[0] + cos*(SCALE_E_DISTANCE);
	dest_origin[1] = client_origin[1] + sin*(SCALE_E_DISTANCE);
	if(ball0_invulnerable == 1)
	{
		dest_origin[2] = client_origin[2] + GK_E_HEIGHT;
	}
	if (ball0_invulnerable == 0)
	{
		Set_Speed_With_Ball(player_grabbing);
		dest_origin[2] = client_origin[2] + NORMAL_E_HEIGHT;
	}
	TeleportEntity(ball0_dynamic, dest_origin, client_eye_angles, NULL_VECTOR);
}
public Round_Draw()
{
	new Handle:event = CreateEvent("cs_win_panel_round");
	SetEventBool(event, "show_timer_defend", true);
	SetEventBool(event, "show_timer_attack", true);
	SetEventInt(event, "timer_time", 10);
	SetEventInt(event, "final_event", _:CSRoundEnd_Draw);
	CS_TerminateRound(10.0,  CSRoundEnd_Draw, false);
	PrintToChatAll(" \x01\x0B\x05 [SMP5] Referee ends this round in a draw.");
}
public Set_Speed_With_Ball(client)
{
	actual_speed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
	if ((actual_speed > SPEED_NORMAL_CARRY) && (actual_speed < SPEED_TURBO_CARRY))
	{
		actual_speed = SPEED_NORMAL_CARRY;
		SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", speed_player_carry);
	}
	if (actual_speed > SPEED_TURBO_CARRY)
	{
		actual_speed = SPEED_TURBO_CARRY;
		SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", speed_player_carry_turbo);
	}
}
public Recover_Speed(client)
{
	actual_speed = GetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue");
	if (actual_speed == SPEED_NORMAL_CARRY)
	{
		actual_speed = SPEED_NORMAL;
		SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", speed_player_normal);
	}
	if (actual_speed == SPEED_TURBO_CARRY)
	{
		actual_speed = SPEED_TURBO;
		SetEntPropFloat(client, Prop_Send, "m_flLaggedMovementValue", speed_player_turbo);
	}
}

public Last_Activity(clientx)
{	
	if (GetClientTeam(clientx)==2)
	{ // Last T that touch ball
		last_t_activity = clientx;
	}
	if (GetClientTeam(clientx)==3)	
	{ // Last CT that touch ball
		last_ct_activity = clientx;
	}
}

public Check_For_Pass(clientx)
{
	/*
	if (last_ct_activity != -1)
	{
		if ((GetClientTeam(last_ct_activity) == GetClientTeam(clientx)) && (last_ct_activity != clientx))
		{
			last_ct_pass = last_ct_activity;
			if (postround == 0)
			{
				player_scores[last_ct_activity]=player_scores[last_ct_activity]+SCORE_FOR_PASS;
				player_deaths[last_ct_activity]=player_deaths[last_ct_activity]+1;
			}
			PrintToChat(last_ct_activity," \x01\x0B\x05 [SMP5] Successful pass!");
		}
		if (GetClientTeam(last_ct_activity) != GetClientTeam(clientx))
		{ // Terrorist steals the ball from CTS
			last_ct_lost_pass = last_ct_pass;
			last_ct_lost = last_ct_activity;
			last_ct_pass = -1;
			for (new i=1; i<=MAXPLAYERS; i++)
			{
				if ((GetClientTeam(i) == 3) && (IsClientInGame(i)) && (steal_reward[i] == 1))
				{
					steal_reward[i] = 0;
				}
			}
			if ((steal_reward[clientx] == 0) && (postround == 0))
			{
				player_scores[clientx]=player_scores[clientx]+SCORE_FOR_STEAL;
				player_kills[clientx]=player_kills[clientx]+1;
			}
		}
	}
	if (last_t_activity != -1)
	{
		if ((GetClientTeam(last_t_activity) == GetClientTeam(clientx)) && (last_t_activity != clientx))
		{
			last_t_pass = last_t_activity;
			if (postround == 0)
			{
				player_scores[last_t_activity]=player_scores[last_t_activity]+SCORE_FOR_PASS;
				player_deaths[last_t_activity]=player_deaths[last_t_activity]+1;
			}
			PrintToChat(last_t_activity," \x01\x0B\x05 [SMP5] Successful pass!");
		}
		if (GetClientTeam(last_t_activity) != GetClientTeam(clientx))
		{ // Counter-T steals the ball from TS
			last_t_lost_pass = last_t_pass;
			last_t_lost = last_t_activity;
			last_t_pass = -1;
			for (new i=1; i<=MAXPLAYERS; i++)
			{
				if ((GetClientTeam(i) == 2) && (IsClientInGame(i)) && (steal_reward[i] == 1))
				{
					steal_reward[i] = 0;
				}
			}
			if ((steal_reward[clientx] == 0) && (postround == 0))
			{
				player_scores[clientx]=player_scores[clientx]+SCORE_FOR_STEAL;
				player_kills[clientx]=player_kills[clientx]+1;
			}
		}
	}
	*/
	////////////// NEW SCRIPT //////////////
	for (new i=1; i<=MaxClients; i++)
	{
		if (clientx != i)
		{
			steal_reward[i] = 0;
		}
	}
	if (last_ct_activity != -1)
	{
		if ((GetClientTeam(last_ct_activity) == GetClientTeam(clientx)) && (last_ct_activity != clientx))
		{
			// CT PASS
			last_ct_pass = last_ct_activity;
			if (postround == 0)
			{
				player_scores[last_ct_activity]=player_scores[last_ct_activity]+SCORE_FOR_PASS;
				player_deaths[last_ct_activity]=player_deaths[last_ct_activity]+1;
			}
			PrintToChat(last_ct_activity," \x01\x0B\x05 [SMP5] Successful pass!");
		}
		if (GetClientTeam(last_ct_activity) != GetClientTeam(clientx))
		{ // TT STEALS BALL FROM CT
			last_ct_lost_pass = last_ct_pass;
			last_ct_lost = last_ct_activity;
			last_ct_pass = -1;
			if ((steal_reward[clientx] == 0) && (postround == 0))
			{
				player_scores[clientx]=player_scores[clientx]+SCORE_FOR_STEAL;
				player_kills[clientx]=player_kills[clientx]+1;
			}
		}
	}
	if (last_t_activity != -1)
	{
		if ((GetClientTeam(last_t_activity) == GetClientTeam(clientx)) && (last_t_activity != clientx))
		{
			// TT PASS
			last_t_pass = last_t_activity;
			if (postround == 0)
			{
				player_scores[last_t_activity]=player_scores[last_t_activity]+SCORE_FOR_PASS;
				player_deaths[last_t_activity]=player_deaths[last_t_activity]+1;
			}
			PrintToChat(last_t_activity," \x01\x0B\x05 [SMP5] Successful pass!");
		}
		if (GetClientTeam(last_t_activity) != GetClientTeam(clientx))
		{ // CT STEALS BALL FROM TT
			last_t_lost_pass = last_t_pass;
			last_t_lost = last_t_activity;
			last_t_pass = -1;
			if ((steal_reward[clientx] == 0) && (postround == 0))
			{
				player_scores[clientx]=player_scores[clientx]+SCORE_FOR_STEAL;
				player_kills[clientx]=player_kills[clientx]+1;
			}
		}
	}
	if (steal_reward[clientx] == 0)
	{
		steal_reward[clientx] = 1;
	}
}
public Set_Left_Click_Delay(clientx)
{
	if (ball0_delay_click[clientx] == 0)
	{
		ball0_delay_click[clientx]=1;
		delay_timers_click[clientx] = CreateTimer(0.1, timer_delay_click, clientx);
	}
}
public Set_Right_Click_Delay(clientx)
{
	if (ball0_delay_click_right[clientx] == 0)
	{
		ball0_delay_click_right[clientx]=1;
		delay_timers_click_right[clientx] = CreateTimer(0.5, timer_delay_click_right, clientx);
	}
}
public Global_Cooldown()
{
	for (new a=1; a<=MaxClients; a++)
	{ // Applies cooldown to EVERYONE
		if ((IsClientInGame(a)) && (IsPlayerAlive(a)) && (IsValidEntity(a)))
		{
			if (delay_timers_r[a] != null)
			{
				KillTimer(delay_timers_r[a]);
				delay_timers_r[a] = null;
				ball0_delay_r[a] = 1;
				delay_timers_r[a] = CreateTimer(0.9, timer_delay_r, a);
			}
			if (delay_timers_e[a] != null)
			{
				KillTimer(delay_timers_e[a]);
				delay_timers_e[a] = null;
				ball0_delay_e[a] = 1;
				delay_timers_e[a] = CreateTimer(0.9, timer_delay_e, a);
			}
			if (ball0_delay_r[a] == 0)
			{
				ball0_delay_r[a] = 1;
				delay_timers_r[a] = CreateTimer(0.9, timer_delay_r, a);
			}
			if (ball0_delay_e[a] == 0)
			{
				ball0_delay_e[a] = 1;
				delay_timers_e[a] = CreateTimer(0.9, timer_delay_e, a);
			}
		}
	}
}

////////----------------------****<<<<<< SQL DATABASE >>>>>>****----------------------////////
////////----------------------****<<<<<< SQL DATABASE >>>>>>****----------------------////////
////////----------------------****<<<<<< SQL DATABASE >>>>>>****----------------------////////



////////****<<<<<< SPECIAL LOOPS >>>>>>****////////
////////****<<<<<< SPECIAL LOOPS >>>>>>****////////
////////****<<<<<< SPECIAL LOOPS >>>>>>****////////

public Ball_Refresh()
{
	if ((player_grabbing != -1) && (refresh_ball == 1))
	{
		GetEntPropVector(player_grabbing, Prop_Send, "m_vecOrigin", player_grabbing_position);
		GetClientAbsOrigin(player_grabbing, client_origin);
		GetClientEyeAngles(player_grabbing, client_eye_angles);
		cos = Cosine(DegToRad(client_eye_angles[1]));
		sin = Sine(DegToRad(client_eye_angles[1]));
		dest_origin[0] = client_origin[0] + cos*(SCALE_E_DISTANCE);
		dest_origin[1] = client_origin[1] + sin*(SCALE_E_DISTANCE);
		if(ball0_invulnerable == 1)
		{
			dest_origin[2] = client_origin[2] + GK_E_HEIGHT;
		}
		if (ball0_invulnerable == 0)
		{
			Set_Speed_With_Ball(player_grabbing);
			dest_origin[2] = client_origin[2] + NORMAL_E_HEIGHT;
		}
		TeleportEntity(ball0_dynamic, dest_origin, client_eye_angles, NULL_VECTOR);
	}
	// If player is on the air the ball will be released
	if ((player_grabbing != -1) && (player_grabbing_position[2] > (ball0_pos_init[2]+MAX_ACTION_HEIGHT)) && (ball0_invulnerable == 0))
	{
		refresh_ball = 0;
		GetClientName(player_grabbing, client_name, sizeof(client_name));
		PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 released the ball to jump higher.", client_name);
		PrintHintText(player_grabbing, "BALL RELEASED");
		ClientCommand(player_grabbing, "play *customsounds/bloqueo_arb.mp3" );
		Recover_Speed(player_grabbing);
		// Check_Interference(player_grabbing);
		ball0_control = 0;
		player_grabbing = -1;
		Return_Ball();
		refresh_ball = 1;
	}
}

public Action:OnPlayerRunCmd(client, &buttons, &iImpulse, Float:fVelocity[3], Float:fAngles[3], &iWeapon) 
{
	real_buttons[client] = buttons; // real buttons might contain trash so...
	new v_buttons; // v_buttons only changes if clientx is valid
	GetEntPropVector(ball0, Prop_Send, "m_vecOrigin", ball0_position);
	GetEntPropVector(ball0_dynamic, Prop_Send, "m_vecOrigin", ball0_dynamic_position);
	for (new clientx = 1; clientx <= MaxClients; clientx++)
	{
		if ((IsClientInGame(clientx)) && (IsPlayerAlive(clientx)) && (IsValidEntity(clientx)))
		{
			v_buttons = real_buttons[clientx];
			// buttons = GetClientButtons(clientx);
			GetEntPropVector(clientx, Prop_Send, "m_vecOrigin", client_position);
			GetClientName(clientx, client_name, sizeof(client_name));
			Ball_Refresh();
			// ALL CASES FOR EACH ACTION GOES HERE
			// ALL CASES FOR EACH ACTION GOES HERE
			// ALL CASES FOR EACH ACTION GOES HERE
			// ALL CASES FOR EACH ACTION GOES HERE
			/*
			if (v_buttons & IN_USE)
			{
				if (player_grabbing == -1)
				{
					if (((clientx == ct_goalkeeper)&&(ct_area_touch[clientx] == 1)&&(last_ct_activity == -1)) || ((clientx == tt_goalkeeper)&&(tt_area_touch[clientx] == 1)&&(last_t_activity == -1)))
					{ // A GK tries to grab the ball
						gk_e_position[0] = client_position[0];
						gk_e_position[1] = client_position[1];
						gk_e_position[2] = client_position[2] + GK_E_HEIGHT;
						client_distance = GetVectorDistance(ball0_position, gk_e_position);
						if ((client_distance <= MAX_E_GK_DISTANCE) && (ball0_delay_e_gk[clientx]==0))
						{ // SPECIAL E GRAB
							refresh_ball = 0;
							fix_dest = ball0_position
							ball0_control = 1;
							player_grabbing = clientx;
							ball0_invulnerable = 1;
							Last_Activity(clientx);
							if (postround == 0)
							{
								player_kills[clientx]=player_kills[clientx]+3;
								player_scores[clientx]=player_scores[clientx]+SCORE_FOR_SAVE;
							}
							if (delay_timers_invulnerable[clientx] != null)
							{
								KillTimer(delay_timers_invulnerable[clientx]);
								delay_timers_invulnerable[clientx] = null;
							}
							delay_timers_invulnerable[clientx] = CreateTimer(9.1, timer_invulnerable_e, clientx);
							Hide_Ball();
							PrintHintText(clientx, "GOALKEEPER GRAB");
							PrintToChatAll(" \x01\x0B\x05 [SMP5] GK \x01\x0B\x03 %s \x01\x0B\x05 grabbed the ball with invulnerability for 9 seconds.", client_name);
							ClientCommand(clientx, "play *customsounds/ready_gk.mp3" );
							refresh_ball = 1;
						}
					}
					client_distance = GetVectorDistance(ball0_position, client_position);
					if ((client_distance <= MAX_E_DISTANCE) && (ball0_delay_e[clientx]==0) && (ball0_disable[clientx] == 0) && (ball0_invulnerable == 0) && (client_position[2] <= (ball0_pos_init[2]+MAX_ACTION_HEIGHT)))
					{ // Normal E grab
						refresh_ball = 0;
						fix_dest = ball0_position
						ball0_control = 1;
						player_grabbing = clientx;
						Check_For_Pass(clientx);
						Last_Activity(clientx);
						Hide_Ball();
						PrintHintText(clientx, "YOU HAVE THE BALL");
						PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 has the ball.", client_name);
						ClientCommand(clientx, "play *customsounds/ready.mp3" );
						refresh_ball = 1;
					}
					// Release E delays
					if (ball0_delay_e_gk[clientx] == 0 && ((ct_goalkeeper == clientx) || (tt_goalkeeper == clientx)))
					{
						delay_timers_e_gk[clientx] = CreateTimer(0.5, timer_delay_e_gk, clientx);
						ball0_delay_e_gk[clientx]=1;
					}
					if (ball0_delay_e[clientx] == 0)
					{
						ball0_delay_e[clientx]=1;
						delay_timers_e[clientx] = CreateTimer(0.5, timer_delay_e, clientx);
					}
				}
				if (player_grabbing == clientx)
				{
					if (ball0_invulnerable == 0)
					{
						if (ball0_delay_e[clientx]==0)
						{ // Normal player release ball after using E
							refresh_ball = 0;
							// Check_Interference(player_grabbing);
							ball0_control = 0;
							player_grabbing = -1;
							Last_Activity(clientx);
							Return_Ball();
							Recover_Speed(clientx);
							PrintHintText(clientx, "BALL RELEASED");
							PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 released the ball.", client_name);
							ClientCommand(clientx, "play *customsounds/bloqueo_arb.mp3" );
							refresh_ball = 1;
						}
					}
					if (ball0_invulnerable == 1)
					{
						if (ball0_delay_e_gk[clientx]==0)
						{ // GK release ball after using E
							refresh_ball = 0;
							// Check_Interference(player_grabbing);
							ball0_control = 0;
							ball0_invulnerable = 0;
							player_grabbing = -1;
							Last_Activity(clientx);
							Return_Ball();
							Recover_Speed(clientx);
							PrintHintText(clientx, "BALL RELEASED");
							PrintToChatAll(" \x01\x0B\x05 [SMP5] GK \x01\x0B\x03 %s \x01\x0B\x05 stopped grabbing the ball.", client_name);
							ClientCommand(clientx, "play *customsounds/bloqueo_arb.mp3" );
							refresh_ball = 1;
						}
					}
					// Re-grab E delays
					if (ball0_delay_e_gk[clientx] == 0)
					{
						ball0_delay_e_gk[clientx]=1;
						delay_timers_e_gk[clientx] = CreateTimer(1.0, timer_delay_e_gk, clientx);
					}
					if (ball0_delay_e[clientx] == 0)
					{
						ball0_delay_e[clientx]=1;
						delay_timers_e[clientx] = CreateTimer(0.6, timer_delay_e, clientx);
					}
				}
			}
			*/
			if (v_buttons & IN_RELOAD)
			{
				if (player_grabbing == -1)
				{
					client_distance = GetVectorDistance(ball0_position, client_position);
					//if ((client_distance <= MAX_KNIFE_DISTANCE) && (ball0_delay_r[clientx]==0) && (ball0_position[2]<=NORMAL_E_HEIGHT) && (client_position[2]<ball0_pos_init[2]+MAX_ACTION_HEIGHT))
					if ((client_distance <= MAX_KNIFE_DISTANCE) && (ball0_delay_r[clientx]==0) && (client_position[2] < (ball0_pos_init[2]+MAX_ACTION_HEIGHT)) && (ball0_position[2] < (ball0_pos_init[2]+MAX_SHIFT_HEIGHT)))
					{ // Player can attract the ball
						if ((v_buttons & IN_FORWARD) || (v_buttons & IN_BACK))
						{ // Different types of attract ball depending on type of movement
							if (v_buttons & IN_FORWARD)
							{
								forward_mode = 1;
							}
							if (v_buttons & IN_BACK)
							{
								backwards_mode = 1;
							}
						}
						else
						{
							forward_mode = 0;
							backwards_mode = 0;
						}
						AcceptEntityInput(ball0, "Wake");
						Attract_Ball(clientx);
						Check_For_Pass(clientx);
						Last_Activity(clientx);
						PrintHintText(clientx, "BALL ATTRACTED");
					}
				} // Delay for R action
				if (ball0_delay_r[clientx] == 0)
				{
					ball0_delay_r[clientx]=1;
					delay_timers_r[clientx] = CreateTimer(0.1, timer_delay_r, clientx);
				}
			}
			//if (v_buttons & IN_SPEED) --> PREVIOUSLY USED FOR SHIFT ONLY
			if ((v_buttons & IN_SPEED) || (v_buttons & IN_USE))
			{
				if (player_grabbing == -1)
				{
					//////
					if (((clientx == ct_goalkeeper)&&(ct_area_touch[clientx] == 1)&&(last_ct_pass == -1)) || ((clientx == tt_goalkeeper)&&(tt_area_touch[clientx] == 1)&&(last_t_pass == -1)))
					{ // A GK tries to shift the ball
						gk_e_position[0] = client_position[0];
						gk_e_position[1] = client_position[1];
						gk_e_position[2] = client_position[2] + GK_E_HEIGHT;
						client_distance = GetVectorDistance(ball0_position, gk_e_position);
						if ((client_distance <= MAX_SHIFT_GK_DISTANCE) && (ball0_delay_shift[clientx]==0) && (steal_reward[clientx] == 0))
						{ // SPECIAL SHIFT STOP
							if (postround == 0)
							{
								player_kills[clientx]=player_kills[clientx]+3;
								player_scores[clientx]=player_scores[clientx]+SCORE_FOR_SAVE;
							}
							curve_counter = 16; // Cancels incoming curve
							TeleportEntity(ball0, NULL_VECTOR, NULL_VECTOR, NULL_VELOCITY);
							AcceptEntityInput(ball0, "Sleep");
							Check_For_Pass(clientx);
							Last_Activity(clientx);
							Wake_Ball();
							//Attract_Ball(clientx);
							PrintToChatAll(" \x01\x0B\x05 [SMP5] GK \x01\x0B\x03 %s \x01\x0B\x05 controlled an incoming shot.", client_name);
							ClientCommand(clientx, "play *customsounds/ready_gk.mp3" );
						}
					}
					//////
					client_distance = GetVectorDistance(ball0_position, client_position);
					//if ((client_distance <= MAX_E_GK_DISTANCE) && (ball0_delay_shift[clientx]==0) && (ball0_position[2]<=NORMAL_E_HEIGHT))
					if ((client_distance <= MAX_E_GK_DISTANCE) && (ball0_delay_shift[clientx]==0) && (ball0_position[2] < (ball0_pos_init[2]+MAX_SHIFT_HEIGHT)))
					{ // Player can stop the ball
						curve_counter = 16; // Cancels incoming curve
						TeleportEntity(ball0, NULL_VECTOR, NULL_VECTOR, NULL_VELOCITY);
						AcceptEntityInput(ball0, "Sleep");
						Check_For_Pass(clientx);
						Last_Activity(clientx);
						PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 stopped the ball.", client_name);
					}
				}
				if (v_buttons & IN_MOVELEFT)
				{
					if (curve_delay[clientx]==0)
					{
						Command_Curve_Left(clientx, 0);
					}
					if (curve_delay[clientx]==0)
					{
						curve_delay[clientx]=1;
						delay_timers_curve[clientx] = CreateTimer(0.4, timer_delay_curve, clientx);
					}
				}
				if (v_buttons & IN_MOVERIGHT)
				{
					if (curve_delay[clientx]==0)
					{
						Command_Curve_Right(clientx, 0);
					}
					if (curve_delay[clientx]==0)
					{
						curve_delay[clientx]=1;
						delay_timers_curve[clientx] = CreateTimer(0.4, timer_delay_curve, clientx);
					}
				}
				if (v_buttons & IN_BACK)
				{
					if (curve_delay[clientx]==0)
					{
						Command_Curve_0(clientx, 0);
					}
					if (curve_delay[clientx]==0)
					{
						curve_delay[clientx]=1;
						delay_timers_curve[clientx] = CreateTimer(0.4, timer_delay_curve, clientx);
					}
				}
				// Delay for SHIFT action
				if (ball0_delay_shift[clientx] == 0)
				{
					ball0_delay_shift[clientx]=1;
					delay_timers_shift[clientx] = CreateTimer(0.4, timer_delay_shift, clientx);
				}
			}
			if ((v_buttons & IN_ATTACK) && (v_buttons & IN_ATTACK2))
			{	// 3 CASES FOR BOTH CLICKS AT THE SAME TIME
				if ((player_grabbing == -1) && (ball0_delay_click[clientx]==0) && (ball0_delay_click_right[clientx]==0))
				{
					Set_Left_Click_Delay(clientx);
					Set_Right_Click_Delay(clientx);
					client_distance = GetVectorDistance(ball0_position, client_position);
					if ((client_distance <= MAX_KNIFE_DISTANCE) && (steal_reward[clientx] == 0) && (((clientx == ct_goalkeeper)&&(ct_area_touch[clientx] == 1)&&(last_ct_pass == -1)) || ((clientx == tt_goalkeeper)&&(tt_area_touch[clientx] == 1)&&(last_t_pass == -1))))
					{
						curve_counter = 16; // Cancels incoming curve
						Check_For_Pass(clientx);
						Last_Activity(clientx);
						if (postround == 0)
						{
							player_kills[clientx]=player_kills[clientx]+3;
							player_scores[clientx]=player_scores[clientx]+SCORE_FOR_SAVE;
						}
						PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 saves his team!", client_name);
						ClientCommand(clientx, "play *customsounds/shot2_arb.mp3" );
						Global_Cooldown();
					}
					else
					{
						if (client_distance <= MAX_E_GK_DISTANCE)
						{
							AcceptEntityInput(ball0, "Wake");
							Check_For_Pass(clientx);
							Last_Activity(clientx);
							PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 shoots the ball!", client_name);
							ClientCommand(clientx, "play *customsounds/shot2_arb.mp3" );
							if (ball0_curve[clientx] != 0)
							{ // Executes curve for real ball0
								curve_counter = 0;
								if (client_position[2] <= ball0_pos_init[2]+MAX_ACTION_HEIGHT)
								{
									curve_client = clientx;
									last_curve = ball0_curve[clientx];
									CreateTimer(0.1, timer_curve_ball, _, TIMER_REPEAT);
									PrintToChatAll(" \x01\x0B\x05 [SMP5] Amazing curved shot!");
								}
								else
								{
									curve_client = -1;
									last_curve = 0;
									PrintToChat(clientx," \x01\x0B\x05 [SMP5] Curve canceled because kick was on the air.");
								}
								ball0_curve[clientx]=0;
							}
							Global_Cooldown();
						}
					}
				}
				if ((player_grabbing == clientx) && (ball0_delay_click[clientx]==0) && (ball0_delay_click_right[clientx]==0))
				{
					Set_Left_Click_Delay(clientx);
					Set_Right_Click_Delay(clientx);
					refresh_ball = 0;
					// Check_Interference(player_grabbing);
					ball0_control = 0;
					ball0_invulnerable = 0;
					player_grabbing = -1;
					Last_Activity(clientx);
					Return_Ball();
					Recover_Speed(clientx);
					PrintHintText(clientx, "BALL RELEASED");
					PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 shoots the ball!", client_name);
					ClientCommand(clientx, "play *customsounds/shot2_arb.mp3" );
					if (ball0_curve[clientx] != 0)
					{ // Executes curve for real ball0
						curve_counter = 0;
						if (client_position[2] <= ball0_pos_init[2]+MAX_ACTION_HEIGHT)
						{
							curve_client = clientx;
							last_curve = ball0_curve[clientx];
							CreateTimer(0.1, timer_curve_ball, _, TIMER_REPEAT);
							PrintToChatAll(" \x01\x0B\x05 [SMP5] Amazing curved shot!");
						}
						else
						{
							curve_client = -1;
							last_curve = 0;
							PrintToChat(clientx," \x01\x0B\x05 [SMP5] Curve canceled because kick was on the air.");
						}
						ball0_curve[clientx]=0;
					}
					refresh_ball = 1;
				}
			}
			if (v_buttons & IN_ATTACK)
			{ // 3 CASES FOR LEFT CLICK ACTIONS
				if ((player_grabbing == -1) && (ball0_delay_click[clientx]==0))
				{ // PLAYER WAKES UP BALL
					Set_Left_Click_Delay(clientx);
					client_distance = GetVectorDistance(ball0_position, client_position);
					if ((client_distance <= MAX_WAKE_DISTANCE) && (client_distance > MAX_SHIFT_GK_DISTANCE))
					{ // Detect ball trigger
						AcceptEntityInput(ball0, "Wake");
					}
					// PLAYER TOUCH BALL WITH LEFT CLICK
					if (client_distance <= MAX_SHIFT_GK_DISTANCE)
					{ // Detect ball trigger
						AcceptEntityInput(ball0, "Wake");
						Check_For_Pass(clientx);
						Last_Activity(clientx);
						Global_Cooldown();
					}
				}
				if ((player_grabbing == clientx) && (ball0_delay_click[clientx]==0))
				{ // PLAYER RELEASE BALL WITH LEFT CLICK
					refresh_ball = 0;
					// Check_Interference(player_grabbing);
					ball0_control = 0;
					ball0_invulnerable = 0;
					player_grabbing = -1;
					PrintHintText(clientx, "BALL RELEASED");
					PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 pushed the ball.", client_name);
					Last_Activity(clientx);
					Return_Ball();
					Recover_Speed(clientx);
					//ClientCommand(clientx, "play *customsounds/shot2_arb.mp3" );
					refresh_ball = 1;
				}
				if ((player_grabbing != clientx) && (ball0_delay_click[clientx]==0) && (player_grabbing != -1))
				{ // PLAYER TRIES TO STEAL BALL
					Set_Left_Click_Delay(clientx);
					client_distance = GetVectorDistance(ball0_dynamic_position, client_position);
					if ((ball0_invulnerable == 0) && (client_distance <= MAX_SHIFT_GK_DISTANCE))
					{
						refresh_ball = 0;
						ClientCommand(player_grabbing, "play *customsounds/bloqueo_arb.mp3" );
						// Check_Interference(player_grabbing);
						ball0_control = 0;
						GetClientName(player_grabbing, target_name, sizeof(target_name));
						if (GetClientTeam(player_grabbing) != GetClientTeam(clientx))
						{
							if (postround == 0)
							{
								player_kills[clientx]=(player_kills[clientx]+1);
								player_scores[clientx]=player_scores[clientx]+SCORE_FOR_STEAL;
								player_scores[player_grabbing]=player_scores[player_grabbing]+SCORE_FOR_LOSING;
							}
							PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 steals the ball from \x01\x0B\x03 %s \x01\x0B\x05", client_name, target_name);
						}
						else
						{
							PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 steals the ball from his teammate \x01\x0B\x03 %s \x01\x0B\x05", client_name, target_name);
						}
						player_grabbing = -1;
						Last_Activity(clientx);
						Return_Ball();
						Recover_Speed(clientx);
						ClientCommand(clientx, "play *customsounds/bloqueo_arb.mp3" );
						refresh_ball = 1;
					}
				}
			}
			if (v_buttons & IN_ATTACK2)
			{ // 2 CASES FOR RIGHT CLICK ACTIONS
				if ((player_grabbing == -1) && (ball0_delay_click_right[clientx]==0))
				{ // PLAYER WAKES UP BALL
					Set_Right_Click_Delay(clientx);
					client_distance = GetVectorDistance(ball0_position, client_position);
					if ((client_distance <= MAX_WAKE_DISTANCE) && (client_distance > MAX_SHIFT_GK_DISTANCE))
					{ // Detect ball trigger
						AcceptEntityInput(ball0, "Wake");
					}
					// PLAYER PUSH BALL WITH RIGHT CLICK
					if (client_distance <= MAX_SHIFT_GK_DISTANCE)
					{ // Detect ball trigger
						AcceptEntityInput(ball0, "Wake");
						Check_For_Pass(clientx);
						Last_Activity(clientx);
						Global_Cooldown();
						ClientCommand(clientx, "play *customsounds/shot2_arb.mp3" );
					}
				}
				if ((player_grabbing == clientx) && (ball0_delay_click_right[clientx]==0))
				{ // PLAYER RELEASE BALL WITH RIGHT CLICK
					refresh_ball = 0;
					// Check_Interference(player_grabbing);
					ball0_control = 0;
					ball0_invulnerable = 0;
					player_grabbing = -1;
					Last_Activity(clientx);
					Return_Ball();
					Recover_Speed(clientx);
					PrintHintText(clientx, "BALL RELEASED");
					PrintToChatAll(" \x01\x0B\x05 [SMP5] \x01\x0B\x03 %s \x01\x0B\x05 throws the ball.", client_name);
					ClientCommand(clientx, "play *customsounds/shot2_arb.mp3" );
					refresh_ball = 1;
				}
			}
		}
	}
	return Plugin_Continue;
}