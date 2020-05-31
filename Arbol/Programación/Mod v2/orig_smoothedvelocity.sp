#include <sourcemod>
#include <sdktools>

new Handle:g_hSDKGetSmoothedVelocity;

public OnPluginStart()
{
    RegConsoleCmd("sm_getsmoothedvelocity", Command_GetSmoothedVelocity);
    
    new Handle:hConfig = LoadGameConfigFile("smoothedvelocity");
    if (hConfig == INVALID_HANDLE) SetFailState("Couldn't find plugin gamedata!");
    
    StartPrepSDKCall(SDKCall_Entity);
    PrepSDKCall_SetFromConf(hConfig, SDKConf_Virtual, "GetSmoothedVelocity");
    PrepSDKCall_SetReturnInfo(SDKType_Vector, SDKPass_ByValue);
    if ((g_hSDKGetSmoothedVelocity = EndPrepSDKCall()) == INVALID_HANDLE) SetFailState("Failed to create SDKCall for GetSmoothedVelocity offset!");
    
    CloseHandle(hConfig);
}

stock bool:GetEntitySmoothedVelocity(entity, Float:flBuffer[3])
{
    if (!IsValidEntity(entity)) return false;

    if (g_hSDKGetSmoothedVelocity == INVALID_HANDLE)
    {
        LogError("SDKCall for GetSmoothedVelocity is invalid!");
        return false;
    }
    
    SDKCall(g_hSDKGetSmoothedVelocity, entity, flBuffer);
    return true;
}

public Action:Command_GetSmoothedVelocity(client, args)
{
    new iTarget = GetClientAimTarget(client, false);
    if (iTarget && IsValidEntity(iTarget))
    {
        decl Float:flVelocity[3];
        if (GetEntitySmoothedVelocity(iTarget, flVelocity))
        {
            PrintCenterText(client, "flVelocity: %f %f %f", flVelocity[0], flVelocity[1], flVelocity[2]);
        }
    }
    
    return Plugin_Handled;
}