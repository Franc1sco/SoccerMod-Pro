//arbolSpeed : el propósito de este plugin es regular la velocidad.
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>

public Plugin:myinfo =
{
	name = "arbolSpeed",
	author = "arbol",
	description = "arbolSpeed test by Adm.",
	version = "1.0",
};

public OnPluginStart()
{
	RegAdminCmd("smp_arbolspeed", test_speed, ADMFLAG_SLAY);
}
 
public Action:test_speed(client, args)
{
  PrintToChatAll("SMP test_speed: init");
  new String:argument[192];
  GetCmdArgString(argument, sizeof(argument));
  new Float:speed;
  if (strlen(argument) > 0){
	  new argInteg = StringToInt(argument);
	  PrintToChatAll("SMP test_speed: args: %d" , argInteg ) ;
	  speed = 1.0 * argInteg;
  }else{
  	speed = 1.0;
  }

  PrintToChatAll("SMP test_speed: speed: %f" , speed ) ;
  SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", speed);
  PrintToChatAll("SMP test_speed: end");

}