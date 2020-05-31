#include <sourcemod>

public Plugin:myinfo = 
{
    name = "FairuTesuto",
    author = "Lord Canistra",
    description = "Desu",
    version = "0.1",
    url = "http://browse.cx"
}

public OnPluginStart()
{
    // We'll be printing out player name to everyone when he spawns
    HookEvent("player_spawn", PSpawnCB);
    
    // Basic working with files
    // "opening" a file for writing with 'w' mode creates one if it doesn't exist.
    // Files are created in the mod directory by default.
    // OpenFile retures a Handle which we can use in other functions to work with our file
    new Handle:testFile = OpenFile("wtf.txt", "w");
    // Writing a simple string of text into our file. This function adds newline automatically.
    WriteFileLine(testFile, "some line of some text");
    // Close the file when it's not needed anymore.
    CloseHandle(testFile);
    
    // Opening a file for reading with 'r' mode
    new Handle:testRead = OpenFile("wtf.txt", "r");
    // String buffer needed for ReadFileLine function
    new String:lineBuffer[128];
    // Reads an opened file one line at a time into specified buffer
    ReadFileLine(testRead, lineBuffer, sizeof(lineBuffer));
    // Print out contents of first line on the server
    PrintToServer("First line in file:\n%s", lineBuffer);
    // Close the file
    CloseHandle(testRead);
}

public Action:PSpawnCB(Handle:event, const String:name[], bool:dontBroadcast)
{
    // A string buffer for our player name.
    new String:playerName[32];
    // First, we need to know which player caused the event.
    // GetEventInt here retrieves value of event's "userid" field, which holds unique player identifier.
    // GetClientName retrieves client name into specified buffer, but it needs client entity id, not userid.
    // Therefore we translate one into another with GetClientOfUserId.
    GetClientName(GetClientOfUserId(GetEventInt(event, "userid")), playerName, sizeof(playerName));
    // Finally, print contents of our string buffer. To print to specific player, use PrintCenterText function.
    PrintCenterTextAll("Player %s has just spawned!", playerName);
}

public OnClientAuthorized(client, const String:auth[])
{
    // Steam ID should be printed out on server (tested on dedicated).
    PrintToServer("%s", auth);
}  