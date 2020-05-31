#include <sourcemod>
#include <cstrike>
#include <sdktools>

new Handle:sm_Join_Message = INVALID_HANDLE;
public Plugin:myinfo =
{
	name = "createProp",
	author = "arbol",
	description = "Displays message, summons prop",
	version = "1.8.2.0",
	url = "http://www.google.com"
};

public OnPluginStart()
{
  sm_Join_Message = CreateConVar("sm_join_message", "Bienvenido %N, a CONMEBOL Soccer - Mod !", "Default Join Message", FCVAR_NOTIFY)
  AutoExecConfig(true, "onJoin")
  
}

public OnMapStart(){

  
  
  /////////////////////////////////
  
  new Enty = CreateEntityByName("prop_physics");
  if (Enty == -1){
    //ReplyToCommand(client, "prop failed to create."); 
    //PrintToChatAll("prop failed to create.", client); 
  }
  else{
    PrecacheModel("models/cakehat/cakehat.mdl");
    DispatchKeyValue(Enty, "model", "models/cakehat/cakehat.mdl");
    //DispatchKeyValue(Enty, "model", "models/soccer_mod/ball_2009_a22.mdl");
    DispatchKeyValue(Enty, "targetname", "ball_createdy");
    DispatchSpawn(Enty);
    ActivateEntity(Enty);
    new Float:originy[3];
    originy[0] = 155.0
    originy[1] = -255.0
    originy[2] = 200.0
    TeleportEntity(Enty, originy, NULL_VECTOR, NULL_VECTOR);
  }
  
  new Float:position[3];
  position[0] = 188.0
  position[1] = -255.0
  position[2] = 200.0
  
  PrecacheModel("models/soccer_mod/ball_2009_a33.mdl", true);
  new entity = CreateEntityByName("prop_physics");
  DispatchKeyValue(entity, "model", "models/soccer_mod/ball_2009_a33.mdl");
  DispatchKeyValue(entity, "physdamagescale", "0.0");
  DispatchSpawn(entity);
  TeleportEntity(entity, position, NULL_VECTOR, NULL_VECTOR);
  
  
  ///////////////////
  
  new Ent2 = CreateEntityByName("prop_dynamic");
  DispatchKeyValue(Ent2, "model", "models/soccer_mod/ball_2009_a1.mdl");
  DispatchKeyValue(Ent2, "targetname", "ball_created");
  DispatchSpawn(Ent2);
  new Float:origin2[3];
  origin2[0] = 155.0
  origin2[1] = -155.0
  origin2[2] = 255.0
  TeleportEntity(Ent2, origin2, NULL_VECTOR, NULL_VECTOR);
}

public OnClientPostAdminCheck(client)
{
  new String:name[MAX_NAME_LENGTH]
  new String:Message[128]
  GetConVarString(sm_Join_Message, Message, sizeof(Message))
  GetClientName(client, name, sizeof(name))
  PrintToChat(client, Message, client); 
  
  
  /*
  new ent3 = CreateEntityByName("prop_physics");
  PrecacheModel("models/soccer_mod/ball_2009_a3.mdl");
  SetEntityModel(ent3,"models/soccer_mod/ball_2009_a3.mdl"); 
  DispatchKeyValue(ent3, "targetname", "ball_createdph");
  DispatchSpawn(ent3);
  new Float:origin3[3];
  origin3[0] = 350.0
  origin3[1] = -500.0
  origin3[2] = 200.0
  TeleportEntity(ent3, origin3, NULL_VECTOR, NULL_VECTOR);
  //NO FUNCIONA PROP_PHYSICS
  */
  
  /*
  new Entz = CreateEntityByName("prop_physics_override"); 
  DispatchKeyValue(Entz, "model", "models/soccer_mod/ball_2009_a3.mdl");
  DispatchKeyValue(Entz, "targetname", "ball_created2");
  DispatchSpawn(Entz);
  new Float:originz[3];
  originz[0] = 500.0
  originz[1] = -500.0
  originz[2] = 600.0
  TeleportEntity(Entz, originz, NULL_VECTOR, NULL_VECTOR);
  //TeleportEntity(Ent, ClientOrigin, EyeAngles, NULL_VECTOR);
  */
  
  
  
}