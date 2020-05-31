#include <sourcemod>
#include <cstrike>
#include <sdktools>

new Handle:sm_Join_Message = INVALID_HANDLE;
public Plugin:myinfo =
{
	name = "createProp",
	author = "arbol",
	description = "Displays message, summons prop",
	version = "1.1.0.0",
	url = "http://www.google.com"
};

public OnPluginStart()
{
	sm_Join_Message = CreateConVar("sm_join_message", "Bienvenido %N, a CONMEBOL Soccer - Mod !", "Default Join Message", FCVAR_NOTIFY)
	AutoExecConfig(true, "onJoin")
}

public OnClientPostAdminCheck(client)
{
  new String:name[MAX_NAME_LENGTH]
  new String:Message[128]
  GetConVarString(sm_Join_Message, Message, sizeof(Message))
  GetClientName(client, name, sizeof(name))
  PrintToChat(client, Message, client); 
  
  new Ent = CreateEntityByName("prop_dynamic");
  DispatchKeyValue(Ent, "model", "models/soccer_mod/ball_2009_a1.mdl");
  DispatchKeyValue(Ent, "targetname", "ball_created");
  DispatchSpawn(Ent);
  decl Float:ClientOrigin[3];
  decl Float:EyeAngles[3];
  GetClientEyeAngles(client, EyeAngles);
  GetClientAbsOrigin(client, ClientOrigin);
  TeleportEntity(Ent, ClientOrigin, EyeAngles, NULL_VECTOR);
  
  PrintToChat(client, "summoned prop.", client); 
}