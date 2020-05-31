#include <cstrike>

public Action:CS_OnBuyCommand(client, const String:weapon[])
{
    PrintToChatAll("handle buy.");

    return Plugin_Continue;
}  