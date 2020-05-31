#include <sourcemod>

public Plugin:myinfo = 
{
    name        = "Help Menu - SMP V",
    author      = "Ulreth",
    description = "Help menu for SoccerMod Pro V",
    version     = "1.2",
    url         = "https://steamcommunity.com/groups/F-I-F-A"
}

new Handle: g_English_ControlsGoalkeeper;
new Handle: g_Portugues_Controls;
new Handle: g_Spanish_Community;
new Handle: g_English_ControlsSuggestions;
new Handle: g_Spanish_ControlsSuggestions;
new Handle: g_Portugues_Community;
new Handle: g_MainMenu_Spanish;
new Handle: g_Portugues_ControlsSuggestions;
new Handle: g_Portugues_ControlsGoalkeeper;
new Handle: g_MainMenu_Portuguese;
new Handle: g_English_Commands;
new g_English_Commands_position[MAXPLAYERS + 1];
new Handle: g_Spanish_Commands;
new g_Spanish_Commands_position[MAXPLAYERS + 1];
new Handle: g_English_Community;
new Handle: g_Spanish_ControlsGoalkeeper;
new Handle: g_Portugues_Rules;
new Handle: g_MainMenu_English;
new Handle: g_English_Controls;
new Handle: g_Spanish_Rules;
new Handle: g_Spanish_ControlsPlayer;
new g_Spanish_ControlsPlayer_position[MAXPLAYERS + 1];
new Handle: g_English_ControlsPlayer;
new g_English_ControlsPlayer_position[MAXPLAYERS + 1];
new Handle: g_English_Rules;
new Handle: g_Spanish_Controls;
new Handle: g_Portugues_Commands;
new g_Portugues_Commands_position[MAXPLAYERS + 1];
new Handle: g_Portugues_ControlsPlayer;
new g_Portugues_ControlsPlayer_position[MAXPLAYERS + 1];
new Handle: g_Main_Languages;
new bool: g_shown[MAXPLAYERS + 1];

public OnPluginStart()
{
	RegConsoleCmd("sm_tutorial", Command_OpenMenu_Main_Languages, "Type !tutorial to know how to play");
    RegConsoleCmd("sm_help", Command_OpenMenu_Main_Languages, "Type !help to know how to play");
	RegConsoleCmd("sm_ayuda", Command_OpenMenu_Main_Languages, "Escribe !ayuda para aprender a jugar");
	RegConsoleCmd("sm_ajuda", Command_OpenMenu_Main_Languages, "Escribe !ajuda para aprender a jugar");
	RegConsoleCmd("sm_helpmenu", Command_OpenMenu_Main_Languages, "Type !helpmenu to know how to play");
	RegConsoleCmd("sm_menu", Command_OpenMenu_Main_Languages, "Type !menu to know how to play");
	RegConsoleCmd("sm_controls", Command_OpenMenu_Main_Languages, "Type !controls to know how to play");
	RegConsoleCmd("sm_buttons", Command_OpenMenu_Main_Languages, "Type !comandos to know how to play");
	RegConsoleCmd("sm_botaos", Command_OpenMenu_Main_Languages, "Type !comandos to know how to play");
	RegConsoleCmd("sm_comandos", Command_OpenMenu_Main_Languages, "Type !comandos to know how to play");
	RegConsoleCmd("sm_botones", Command_OpenMenu_Main_Languages, "Type !comandos to know how to play");
	RegConsoleCmd("sm_commands", Command_OpenMenu_Main_Languages, "Type !commands to know how to play");
	RegConsoleCmd("sm_controles", Command_OpenMenu_Main_Languages, "Escribe !controles para saber como jugar");
	RegConsoleCmd("sm_rules", Command_OpenMenu_Main_Languages, "Type !rules to display server rules");
	RegConsoleCmd("sm_reglas", Command_OpenMenu_Main_Languages, "Escribe !reglas para saber mas sobre ellas");
	RegConsoleCmd("sm_regras", Command_OpenMenu_Main_Languages, "Escribe !regras para saber mas sobre ellas");

    g_English_ControlsGoalkeeper = CreateMenu(Handler_English_ControlsGoalkeeper);
    SetMenuTitle(g_English_ControlsGoalkeeper, "Goalkeeper - Controls")
    AddMenuItem(g_English_ControlsGoalkeeper, "1", "Shift (once) = Save incoming shot", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_ControlsGoalkeeper, "2", "Both clicks (simultaneously) = Clear ball", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_ControlsGoalkeeper, "3", "!gk (inside goal box) = Become goalkeeper", ITEMDRAW_DISABLED)
	AddMenuItem(g_English_ControlsGoalkeeper, "4", "E (once) = Save incoming shot", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_English_ControlsGoalkeeper, true);

    g_Portugues_Controls = CreateMenu(Handler_Portugues_Controls);
    SetMenuTitle(g_Portugues_Controls, "Controles")
    AddMenuItem(g_Portugues_Controls, "1", "Jogador")
    AddMenuItem(g_Portugues_Controls, "2", "Goleiro")
    AddMenuItem(g_Portugues_Controls, "3", "Sugestões")
    SetMenuExitBackButton(g_Portugues_Controls, true);

    g_Spanish_Community = CreateMenu(Handler_Spanish_Community);
    SetMenuTitle(g_Spanish_Community, "Comunidad")
    AddMenuItem(g_Spanish_Community, "1", "Grupo Steam Mundial: http://steamcommunity.com/groups/F-I-F-A", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_Community, "2", "DEV Team (Ulreth & Arbol)", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_Community, "3", "No dudar en contactar admins para organizar partidos oficiales", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_Spanish_Community, true);

    g_English_ControlsSuggestions = CreateMenu(Handler_English_ControlsSuggestions);
    SetMenuTitle(g_English_ControlsSuggestions, "Gameplay Suggestions")
    AddMenuItem(g_English_ControlsSuggestions, "1", "Keep the ball in front of you to shoot accurately", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_ControlsSuggestions, "2", "Knife enemy player near feet to break their dribbling control, also stuck them with your body", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_ControlsSuggestions, "3", "Look up to the sky in order to lift ball", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_ControlsSuggestions, "4", "Use left click to dribble forward and combine it with R (hold)", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_ControlsSuggestions, "5", "Goalkeepers need to knife incoming shot at exact time to save ball", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_ControlsSuggestions, "6", "Save your turbo for moments where opponents are resting (cooldown)", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_English_ControlsSuggestions, true);

    g_Spanish_ControlsSuggestions = CreateMenu(Handler_Spanish_ControlsSuggestions);
    SetMenuTitle(g_Spanish_ControlsSuggestions, "Sugerencias generales")
    AddMenuItem(g_Spanish_ControlsSuggestions, "1", "Tener la pelota siempre en frente del jugador para mayor precisión", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_ControlsSuggestions, "2", "Usar cuchillo cerca de los pies o pelota del rival para cortar con su dominio", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_ControlsSuggestions, "3", "Mirar para arriba para levantar pelota", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_ControlsSuggestions, "4", "Aprovechar click izquierdo para moverse y combinarlo con R (mantenido)", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_ControlsSuggestions, "5", "Porteros necesitan apretar los dos clicks en el momento justo para desviar un tiro", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_ControlsSuggestions, "6", "Guarda el turbo para cuando tus rivales descansan (cooldown)", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_Spanish_ControlsSuggestions, true);

    g_Portugues_Community = CreateMenu(Handler_Portugues_Community);
    SetMenuTitle(g_Portugues_Community, "Comunidade")
    AddMenuItem(g_Portugues_Community, "1", "Grupo Mundial da Steam: http://steamcommunity.com/groups/F-I-F-A", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_Community, "2", "DEV Team (Ulreth & Arbol)", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_Community, "3", "Não hesite em entrar em contato com os administradores para organizar partidas oficiais", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_Portugues_Community, true);

    g_MainMenu_Spanish = CreateMenu(Handler_MainMenu_Spanish);
    SetMenuTitle(g_MainMenu_Spanish, "AYUDA - Español")
    AddMenuItem(g_MainMenu_Spanish, "1", "Controles")
    AddMenuItem(g_MainMenu_Spanish, "2", "Comandos")
    AddMenuItem(g_MainMenu_Spanish, "3", "Reglas")
    AddMenuItem(g_MainMenu_Spanish, "4", "Comunidad")
    SetMenuExitBackButton(g_MainMenu_Spanish, true);

    g_Portugues_ControlsSuggestions = CreateMenu(Handler_Portugues_ControlsSuggestions);
    SetMenuTitle(g_Portugues_ControlsSuggestions, "Sugestões")
    AddMenuItem(g_Portugues_ControlsSuggestions, "1", "Mantenha a bola sempre na frente do jogador para maior precisão", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_ControlsSuggestions, "2", "Use uma faca perto dos pés ou uma bola rival para remover o domínio", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_ControlsSuggestions, "3", "Olhe para cima para levantar a bola", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_ControlsSuggestions, "4", "Combine o botão esquerdo com R para driblar para a frente", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_ControlsSuggestions, "5", "Golero precisa pressionar os dois botões do mouse no momento certo para desviar a bola", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_ControlsSuggestions, "6", "Economize turbo para quando os rivais descansarem (cooldown)", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_Portugues_ControlsSuggestions, true);

    g_Portugues_ControlsGoalkeeper = CreateMenu(Handler_Portugues_ControlsGoalkeeper);
    SetMenuTitle(g_Portugues_ControlsGoalkeeper, "Goleiro - Controles")
    AddMenuItem(g_Portugues_ControlsGoalkeeper, "1", "Shift (uma vez) = Pegar bola", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_ControlsGoalkeeper, "2", "Dois Botaos (mesmo tempo) = Desviar o tiro", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_ControlsGoalkeeper, "3", "!gk (dentro da area) = Ser goleiro", ITEMDRAW_DISABLED)
	AddMenuItem(g_Portugues_ControlsGoalkeeper, "4", "E (uma vez) = Pegar bola", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_Portugues_ControlsGoalkeeper, true);

    g_MainMenu_Portuguese = CreateMenu(Handler_MainMenu_Portuguese);
    SetMenuTitle(g_MainMenu_Portuguese, "AJUDA - Portugues")
    AddMenuItem(g_MainMenu_Portuguese, "1", "Controles")
    AddMenuItem(g_MainMenu_Portuguese, "2", "Comandos")
    AddMenuItem(g_MainMenu_Portuguese, "3", "Regras")
    AddMenuItem(g_MainMenu_Portuguese, "4", "Comunidade")
    SetMenuExitBackButton(g_MainMenu_Portuguese, true);

    g_English_Commands = CreateMenu(Handler_English_Commands);
    SetMenuTitle(g_English_Commands, "Client Commands")
    AddMenuItem(g_English_Commands, "1", "Tab (hold) --> Mute", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_Commands, "2", "!tp = Switch camera", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_Commands, "3", "!gk = Become goalkeeper", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_Commands, "4", "!skins = Change your outfit", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_Commands, "5", "!stuck = Unstucks player", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_Commands, "6", "nominate | rtv", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_Commands, "7", "!rankme", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_Commands, "8", "!rank", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_Commands, "9", "!statsme", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_Commands, "10", "!top", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_English_Commands, true);

    g_Spanish_Commands = CreateMenu(Handler_Spanish_Commands);
    SetMenuTitle(g_Spanish_Commands, "Comandos libres")
    AddMenuItem(g_Spanish_Commands, "1", "Tab (mantener) --> Silenciar jugador", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_Commands, "2", "!tp = Cambiar camara", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_Commands, "3", "!gk = Convertirse en portero", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_Commands, "4", "!skins = Cambiar modelo", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_Commands, "5", "!stuck = Destrabarse", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_Commands, "6", "nominate | rtv", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_Commands, "7", "!rankme", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_Commands, "8", "!rank", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_Commands, "9", "!statsme", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_Commands, "10", "!top", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_Spanish_Commands, true);

    g_English_Community = CreateMenu(Handler_English_Community);
    SetMenuTitle(g_English_Community, "Community")
    AddMenuItem(g_English_Community, "1", "Worldwide Steam Group: http://steamcommunity.com/groups/F-I-F-A", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_Community, "2", "DEV Team (Ulreth & Arbol)", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_Community, "3", "Feel free to contact admins in order to play official matches", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_English_Community, true);

    g_Spanish_ControlsGoalkeeper = CreateMenu(Handler_Spanish_ControlsGoalkeeper);
    SetMenuTitle(g_Spanish_ControlsGoalkeeper, "Portero - Controles")
    AddMenuItem(g_Spanish_ControlsGoalkeeper, "1", "Shift (una vez) = Atrapar pelota", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_ControlsGoalkeeper, "2", "Click Izq+Der (mismo tiempo) = Despejar pelota", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_ControlsGoalkeeper, "3", "!gk (dentro de area) = Convertirse en portero", ITEMDRAW_DISABLED)
	AddMenuItem(g_Spanish_ControlsGoalkeeper, "4", "E (una vez) = Atrapar bola", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_Spanish_ControlsGoalkeeper, true);

    g_Portugues_Rules = CreateMenu(Handler_Portugues_Rules);
    SetMenuTitle(g_Portugues_Rules, "Regras")
    AddMenuItem(g_Portugues_Rules, "1", "Nao marcar gols em sua propria meta", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_Rules, "2", "Nao usar cheats o fazer exploits", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_Rules, "3", "Nao envie spam da outras comunidades", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_Rules, "4", "Nao seja tóxico", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_Rules, "5", "Respeite os outros jogadores e obedeça aos administradores", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_Rules, "6", "As punições podem variar entre slay, mute, kick o ban", ITEMDRAW_DISABLED)
	AddMenuItem(g_Portugues_Rules, "7", "Nao fique ocioso quando o servidor estiver cheio", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_Portugues_Rules, true);

    g_MainMenu_English = CreateMenu(Handler_MainMenu_English);
    SetMenuTitle(g_MainMenu_English, "HELP - English")
    AddMenuItem(g_MainMenu_English, "1", "How to play")
    AddMenuItem(g_MainMenu_English, "2", "Client commands")
    AddMenuItem(g_MainMenu_English, "3", "Rules")
    AddMenuItem(g_MainMenu_English, "4", "Community")
    SetMenuExitBackButton(g_MainMenu_English, true);

    g_English_Controls = CreateMenu(Handler_English_Controls);
    SetMenuTitle(g_English_Controls, "How to play")
    AddMenuItem(g_English_Controls, "1", "Player")
    AddMenuItem(g_English_Controls, "2", "Goalkeeper")
    AddMenuItem(g_English_Controls, "3", "Suggestions")
    SetMenuExitBackButton(g_English_Controls, true);

    g_Spanish_Rules = CreateMenu(Handler_Spanish_Rules);
    SetMenuTitle(g_Spanish_Rules, "Reglas")
    AddMenuItem(g_Spanish_Rules, "1", "Prohibido meterse goles en contra", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_Rules, "2", "No usar cheats ni exploits", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_Rules, "3", "Evitar spam de otras comunidades", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_Rules, "4", "Mantener toxicidad al minímo", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_Rules, "5", "Respetar a los otros jugadores y obedecer a los admins", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_Rules, "6", "Castigos pueden variar entre mute, kick, slay, ban, etc", ITEMDRAW_DISABLED)
	AddMenuItem(g_Spanish_Rules, "7", "Solo se permite idlear cuando el servidor no esta lleno", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_Spanish_Rules, true);

    g_Spanish_ControlsPlayer = CreateMenu(Handler_Spanish_ControlsPlayer);
    SetMenuTitle(g_Spanish_ControlsPlayer, "Jugador - Controles")
    AddMenuItem(g_Spanish_ControlsPlayer, "1", "Click Izq+Der (mismo tiempo) = Patear fuerte", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_ControlsPlayer, "2", "Click Der = Pase fuerte", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_ControlsPlayer, "3", "Click Izq = Dribble o pase corto", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_ControlsPlayer, "4", "Mouse = Dirección del tiro", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_ControlsPlayer, "5", "W (2 veces) = Turbo o sprint", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_ControlsPlayer, "6", "R (mantener) = Atraer pelota", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_ControlsPlayer, "7", "Shift = Detener pelota", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_ControlsPlayer, "8", "Shift + A (una vez) = Proximo tiro curva hacia izquierda", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_ControlsPlayer, "9", "Shift + D (una vez) = Proximo tiro curva hacia derecha", ITEMDRAW_DISABLED)
    AddMenuItem(g_Spanish_ControlsPlayer, "10", "Shift + S (una vez) = Cancelar comba", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_Spanish_ControlsPlayer, true);

    g_English_ControlsPlayer = CreateMenu(Handler_English_ControlsPlayer);
    SetMenuTitle(g_English_ControlsPlayer, "Player - Controls")
    AddMenuItem(g_English_ControlsPlayer, "1", "Both clicks (simultaneously) = Strong kick", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_ControlsPlayer, "2", "Right click (once) = Medium kick", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_ControlsPlayer, "3", "Left click = Soft push / Dribble", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_ControlsPlayer, "4", "Crosshair = Shot direction", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_ControlsPlayer, "5", "W (tap 2 times) = Sprint / Turbo", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_ControlsPlayer, "6", "R (hold) = Attract ball", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_ControlsPlayer, "7", "Shift (once) = Stop ball", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_ControlsPlayer, "8", "Shift + A (once) = Next shot will curve to left", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_ControlsPlayer, "9", "Shift + D (once) = Next shot will curve to right", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_ControlsPlayer, "10", "Shift + S (once) = Cancel curve", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_English_ControlsPlayer, true);

    g_English_Rules = CreateMenu(Handler_English_Rules);
    SetMenuTitle(g_English_Rules, "Rules")
    AddMenuItem(g_English_Rules, "1", "Do NOT score own goals", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_Rules, "2", "Do NOT use cheats or exploits", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_Rules, "3", "Do NOT spam communities", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_Rules, "4", "Avoid toxic behaviour", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_Rules, "5", "Respect other players & obey admins", ITEMDRAW_DISABLED)
    AddMenuItem(g_English_Rules, "6", "Punishment can vary between mute, kick or ban", ITEMDRAW_DISABLED)
	AddMenuItem(g_English_Rules, "7", "Idle farming only allowed when server is empty", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_English_Rules, true);

    g_Spanish_Controls = CreateMenu(Handler_Spanish_Controls);
    SetMenuTitle(g_Spanish_Controls, "Controles")
    AddMenuItem(g_Spanish_Controls, "1", "Jugador")
    AddMenuItem(g_Spanish_Controls, "2", "Portero")
    AddMenuItem(g_Spanish_Controls, "3", "Sugerencias")
    SetMenuExitBackButton(g_Spanish_Controls, true);

    g_Portugues_Commands = CreateMenu(Handler_Portugues_Commands);
    SetMenuTitle(g_Portugues_Commands, "Comandos")
    AddMenuItem(g_Portugues_Commands, "1", "Tab (mantener) --> Mute jogador", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_Commands, "2", "!tp = Alterar a vista da camera", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_Commands, "3", "!gk = Ativar goleiro dentro da area", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_Commands, "4", "!skins = Escolher o equipamento", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_Commands, "5", "!stuck = Liberar jogador", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_Commands, "6", "nominate | rtv", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_Commands, "7", "!rankme", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_Commands, "8", "!rank", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_Commands, "9", "!statsme", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_Commands, "10", "!top", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_Portugues_Commands, true);

    g_Portugues_ControlsPlayer = CreateMenu(Handler_Portugues_ControlsPlayer);
    SetMenuTitle(g_Portugues_ControlsPlayer, "Jogador - Controles")
    AddMenuItem(g_Portugues_ControlsPlayer, "1", "Dois Botaos (mesmo tempo) =  Chute muy forte", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_ControlsPlayer, "2", "Botao direito = Chute normal", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_ControlsPlayer, "3", "Botao esquerdo = Passar o dribble", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_ControlsPlayer, "4", "Direcao do mouse = Direcao do chute", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_ControlsPlayer, "5", "W (dois veces) = Turbo o sprint", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_ControlsPlayer, "6", "R (mantener) = Atrair bola", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_ControlsPlayer, "7", "Shift (apretar) = Pare a bola", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_ControlsPlayer, "8", "Shift + A (uma vez) = Chute virado hacia esquerda", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_ControlsPlayer, "9", "Shift + D (uma vez) = Chute virado hacia direita", ITEMDRAW_DISABLED)
    AddMenuItem(g_Portugues_ControlsPlayer, "10", "Shift + S (uma vez) = Cancelar curva", ITEMDRAW_DISABLED)
    SetMenuExitBackButton(g_Portugues_ControlsPlayer, true);

    g_Main_Languages = CreateMenu(Handler_Main_Languages);
    SetMenuTitle(g_Main_Languages, "HELP MENU")
    AddMenuItem(g_Main_Languages, "1", "English")
    AddMenuItem(g_Main_Languages, "2", "Español")
    AddMenuItem(g_Main_Languages, "3", "Portugues")
    AddMenuItem(g_Main_Languages, "4", "Francais", ITEMDRAW_DISABLED)
}

public OnClientPutInServer(client)
{
    FakeClientCommand(client, "sm_controls");
}

public Action:Command_OpenMenu_Main_Languages(client, argc)
{
    DisplayMenu(g_Main_Languages, client, MENU_TIME_FOREVER);
    return Plugin_Handled;
}

public Handler_English_ControlsGoalkeeper(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_English_Controls, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_Portugues_Controls(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
            if (StrEqual(info, "1"))
            {
                DisplayMenu(g_Portugues_ControlsPlayer, client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(info, "2"))
            {
                DisplayMenu(g_Portugues_ControlsGoalkeeper, client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(info, "3"))
            {
                DisplayMenu(g_Portugues_ControlsSuggestions, client, MENU_TIME_FOREVER);
            }
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_MainMenu_Portuguese, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_Spanish_Community(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_MainMenu_Spanish, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_English_ControlsSuggestions(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_English_Controls, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_Spanish_ControlsSuggestions(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_Spanish_Controls, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_Portugues_Community(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_MainMenu_Portuguese, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_MainMenu_Spanish(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
            if (StrEqual(info, "1"))
            {
                DisplayMenu(g_Spanish_Controls, client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(info, "2"))
            {
                DisplayMenu(g_Spanish_Commands, client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(info, "3"))
            {
                DisplayMenu(g_Spanish_Rules, client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(info, "4"))
            {
                DisplayMenu(g_Spanish_Community, client, MENU_TIME_FOREVER);
            }
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_Main_Languages, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_Portugues_ControlsSuggestions(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_Portugues_Controls, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_Portugues_ControlsGoalkeeper(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_Portugues_Controls, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_MainMenu_Portuguese(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
            if (StrEqual(info, "1"))
            {
                DisplayMenu(g_Portugues_Controls, client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(info, "2"))
            {
                DisplayMenu(g_Portugues_Commands, client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(info, "3"))
            {
                DisplayMenu(g_Portugues_Rules, client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(info, "4"))
            {
                DisplayMenu(g_Portugues_Community, client, MENU_TIME_FOREVER);
            }
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_Main_Languages, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_English_Commands(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_MainMenu_English, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_Spanish_Commands(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_MainMenu_Spanish, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_English_Community(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_MainMenu_English, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_Spanish_ControlsGoalkeeper(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_Spanish_Controls, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_Portugues_Rules(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_MainMenu_Portuguese, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_MainMenu_English(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
            if (StrEqual(info, "1"))
            {
                DisplayMenu(g_English_Controls, client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(info, "2"))
            {
                DisplayMenu(g_English_Commands, client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(info, "3"))
            {
                DisplayMenu(g_English_Rules, client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(info, "4"))
            {
                DisplayMenu(g_English_Community, client, MENU_TIME_FOREVER);
            }
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_Main_Languages, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_English_Controls(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
            if (StrEqual(info, "1"))
            {
                DisplayMenu(g_English_ControlsPlayer, client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(info, "2"))
            {
                DisplayMenu(g_English_ControlsGoalkeeper, client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(info, "3"))
            {
                DisplayMenu(g_English_ControlsSuggestions, client, MENU_TIME_FOREVER);
            }
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_MainMenu_English, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_Spanish_Rules(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_MainMenu_Spanish, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_Spanish_ControlsPlayer(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_Spanish_Controls, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_English_ControlsPlayer(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_English_Controls, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_English_Rules(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_MainMenu_English, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_Spanish_Controls(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
            if (StrEqual(info, "1"))
            {
                DisplayMenu(g_Spanish_ControlsPlayer, client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(info, "2"))
            {
                DisplayMenu(g_Spanish_ControlsGoalkeeper, client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(info, "3"))
            {
                DisplayMenu(g_Spanish_ControlsSuggestions, client, MENU_TIME_FOREVER);
            }
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_MainMenu_Spanish, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_Portugues_Commands(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_MainMenu_Portuguese, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_Portugues_ControlsPlayer(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
        }
        case MenuAction_Cancel:
        {
            if (slot == MenuCancel_ExitBack)
            {
                DisplayMenu(g_Portugues_Controls, client, MENU_TIME_FOREVER);
            }
        }
    }
}

public Handler_Main_Languages(Handle:menu, MenuAction:action, client, slot)
{
    switch (action)
    {
        case MenuAction_Select:
        {
            decl String:info[64];
            GetMenuItem(menu, slot, info, sizeof(info));
            
            if (StrEqual(info, "1"))
            {
                DisplayMenu(g_MainMenu_English, client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(info, "2"))
            {
                DisplayMenu(g_MainMenu_Spanish, client, MENU_TIME_FOREVER);
            }
            else if (StrEqual(info, "3"))
            {
                DisplayMenu(g_MainMenu_Portuguese, client, MENU_TIME_FOREVER);
            }
        }
    }
}

