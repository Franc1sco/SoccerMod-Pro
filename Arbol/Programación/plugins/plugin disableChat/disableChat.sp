#include <sourcemod>
#include <cstrike>
#include <sdktools>





public Plugin:myinfo =
{
	name = "disableChat",
	author = "arbol",
	description = "Disables chat - say - for all players.",
	version = "1.03",
};




public OnPluginStart()
{
	RegAdminCmd("sm_allplayers", Command_showplayers, ADMFLAG_SLAY);
	AddCommandListener(SayHook, "say");
	
}
 
 
 


public Action:Command_showplayers(client, args)
{
  for (new x = 1; x <= 40; x++)
  {
  if (IsClientInGame(x))
    {
      decl String:Name[MAX_NAME_LENGTH];
      GetClientName(x, Name, sizeof(Name));
      
      
      decl String:buffer[512];
      Format(buffer, sizeof(buffer), "%s          %d",  Name, x);
      
      
      PrintToConsole(client, "......" );
      PrintToConsole(client, buffer );
      PrintToConsole(client, "......" );
      
    }
  }
}


public Action:SayHook(client, const String:command[], args)
{
  decl String:Msg[256];
  
  GetCmdArgString(Msg, sizeof(Msg));
  Msg[strlen(Msg)-1] = '\0';
  
  //PrintToChatAll("Redirecting chat.");
  //PrintToChatAll("Original chat:" );
  //PrintToChatAll("HEADER ... \x01\x0B\x01 %s", Msg[1]);
  
  decl String:Name[MAX_NAME_LENGTH];
  GetClientName(client, Name, sizeof(Name));
  
  for (new x = 1; x <= 40; x++)
  {
  if (IsClientInGame(x))
    {
      if ( ( GetClientTeam(x)  == GetClientTeam(client) ) || (GetClientTeam(x) < 2) ){
        PrintToChat(x, "Redirected chat: \x01\x0B\x04 %s : \x01\x0B\x01 %s", Name, Msg[1] );
      }
    }
  }
  
  
  //PrintToChatAll("Done.-" );
  return Plugin_Handled;
}