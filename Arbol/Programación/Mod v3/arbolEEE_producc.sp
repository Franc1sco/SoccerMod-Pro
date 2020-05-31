//el propósito de este plugin es permitir al arquero agarrar la bola
#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <cstrike>
#include <clientprefs>

#define PLUGIN_VERSION "2.51"

//en velocidades, al estar sobre 50, 50 representa 1.000 , 100 representa 2.000, 75 representa 1.500 etc...

#define ARBOL_SPEED_LENTO 30

#define ARBOL_SPEED_NORMALMIDSEGUNDO 51

#define INCREMENTO_VELOCIDAD_POR_CIENMILIS 3

#define ARBOL_SPEED_NORMALMID 50
#define ARBOL_SPEED_NORMALDEF 46
#define ARBOL_SPEED_NORMALFWD 53
#define ARBOL_SPEED_NORMALGK 50



#define ARBOL_SPEED_MAXVELNUMMID 74
#define ARBOL_SPEED_MAXVELNUMGK 68
#define ARBOL_SPEED_MAXVELNUMFWD 77
#define ARBOL_SPEED_MAXVELNUMDEF 70

#define ARBOL_SPEED_BARRIDA 88
#define ARBOL_SPEED_BARRIDAMED 116
#define ARBOL_SPEED_BARRIDADEF 146
//67

#define TIEMPO_PROHIBIDO_AGARRAR_RECIBOBARRIDA 9

#define TIEMPO_PATEOPELOTA_PROHIBIDO_AGARRAR 6

#define TIEMPO_PATEOPELOTA_PROHIBIDO_AGARRAR_EXCEP_ARK 2

#define TIEMPO_PATEOPELOTACLICKIZQ_PROHIBIDO_AGARRAR 3



#define TIEMPO_BARRIDA_PROHIBIDO_AGARRAR 2
#define TIEMPO_LASTIMADOCLICKDER_PROHIBIDO_AGARRAR 5
#define TIEMPO_LASTIMADOCLICKIZQ_PROHIBIDO_AGARRAR 4
#define LATENCIA_MAX_INUSE 10
#define LATENCIA_MAX_SHIFT 12

#define TIEMPO_ESTAR_LENTO_VELOCIDAD 2

#define TIEMPO_ESTAR_WARPEADO_POR_IR_ATRAS 6
#define TIEMPO_ESTAR_WARPEADO_POR_IR_COSTADO 4

#define TIEMPO_ESTAR_WARPEADO_POR_PEGANDO_A_BOLA 3


//def. 55
#define DISTANCE_BETWEEN_PLAYER_AND_BALL_STILL 27.0
#define ATTRACTBALL_MULTIPLIER_STILL 200.0
#define BALL_HOLD_HEIGHT_STILL 0.0

#define DISTANCE_BETWEEN_PLAYER_AND_BALL_WASD 85.0
#define ATTRACTBALL_MULTIPLIER_WASD 250.0
#define BALL_HOLD_HEIGHT_WASD 5.0

#define DISTANCE_BETWEEN_PLAYER_AND_BALL_MAXWASD 160.0
#define ATTRACTBALL_MULTIPLIER_MAXWASD 130.0
#define BALL_HOLD_HEIGHT_MAXWASD 5.0

#define DISTANCE_BETWEEN_PLAYER_AND_BALL_ATRASWASD 27.0
#define ATTRACTBALL_MULTIPLIER_ATRASWASD 250.0
#define BALL_HOLD_HEIGHT_ATRASWASD 0.0

#define DISTANCE_BETWEEN_PLAYER_AND_BALL_DIAGONALWASD 35.0
#define ATTRACTBALL_MULTIPLIER_DIAGONALWASD 250.0
#define BALL_HOLD_HEIGHT_DIAGONALWASD 5.0


#define PI_NUM 3.1415926

#define NULL_VELOCITY Float:{0.0, 0.0, 0.0}



#define DURACION_BARRA 0.75 //02/08/2015: antes estaba en 1.0

#define FUERZA_INICIAL_BOLA 3300

#define FUERZA_MAXIMA_BOLA 5000

//push puesto en mitades, el tamaño del push es, por ejemplo, EQUIS_PUSH_MITAD*2   x   etc...
//65 * 45 * 26
#define EQUIS_PUSH_MITAD 72.0
#define YGRIEGA_PUSH_MITAD 52.0
#define ZETA_PUSH_MITAD 27.0

#define EQUISVOLEA_PUSH_MITAD 120.0
#define YGRIEGAVOLEA_PUSH_MITAD 90.0
#define ZETAVOLEA_PUSH_MITAD 50.0

#define EQUISCABEZAZO_PUSH_MITAD 180.0
#define YGRIEGACABEZAZO_PUSH_MITAD 130.0
#define ZETACABEZAZO_PUSH_MITAD 90.0

#define RCOUNTER_RELOAD 3
#define RELASTCOUNTER_RELOAD 7
#define RADIUS_ATTRACTBALL 90.0
#define HEIGHT_ATTRACTBALL 60
#define HEIGHT_ATTRACTBALLRAISE 60
#define SHR_DISTANCE_BETWEEN_PLAYER_AND_BALL 20.0
#define SHRANTIBUGG_DISTANCE_BETWEEN_PLAYER_AND_BALL 5.0
#define SHR_ATTRACTBALL_MULTIPLIER 5.0
#define SHRANTIBUGG_ATTRACTBALL_MULTIPLIER 9.0
#define SHR_BALL_HOLD_HEIGHT 15

#define PLAYER_ANIM_COUNTER 3

#define TIEMPO_CONTROLBTN_COUNTER 9


#define GK_DISTANCE_BETWEEN_PLAYER_AND_BALL 9.0
#define GK_ATTRACTBALL_MULTIPLIER 10.0
#define GK_BALL_HOLD_HEIGHT 52

#define RADIUS_STOPBALL 82.0

#define RADIUS_GRABE 45.0

#define RADIUS_DANHAR_POR_BARRIDA_A_JUGADOR 35.0

#define RADIUS_ATTACK_CLICK 74

#define MAX_SUPUESTO_TOQUE_CLICKDER 82

#define MAX_SUPUESTO_TOQUE_CONSIDERAALTURA_CLICKDER 110

#define RADIO_CURVA_PERMITIDO 73

#define ARBOL_SPEED_SLOWPORG 20 //enlentecer luego de haber usado G

#define ARBOL_COUNTER_LENTITUDG 15 //contador de tiempo de enlentecer luego de haber usado G

#define ARBOL_COUNTER_REUSAR_G 180 //tiempo total a esperar para cargar TODA la barra de G

#define ARBOL_COUNTER_G_RESTARLE_POR_CENTESIMA_DE_SEG 3

#define COUNTER_HACER_BARRIDA 90

#define RANGO_BARRIDA 78

#define DECISEGUNDOS_ARQUERO_FUERADEAREA_GRACIA 600

#define DECISEGUNDOS_PERMITIDOARQUERO_AGARRARLA 78

#define ENLENTECER_LUEGO_DE_SALTO_GK 8
#define VELOCIDAD_LENTO_SALTOGK 25

#define SHIFT_COUNTER 4

//////////#define MODELO_JUGCT "models/player/soccermod/afplayer/arbplay_1.mdl"

////////#define MODELO_JUGTT "models/player/soccermod/afplayer/arbplay_2.mdl"


#define MODELO_JUGCTGK "models/player/soccermod/afplayer/arbplay_gk2.mdl"

#define MODELO_JUGTTGK "models/player/soccermod/afplayer/arbplay_gk1.mdl"

new Float:VARIABLE_DISTANCE_BETWEEN_PLAYER_AND_BALL[MAXPLAYERS]; //variable temporal que se iguala a los números mágicos de arriba según caso.
new Float:VARIABLE_ATTRACTBALL_MULTIPLIER[MAXPLAYERS];
new Float:VARIABLE_BALL_HOLD_HEIGHT[MAXPLAYERS];


new Enty; //prop physball
new String:physball_model_name[128]; //model name of the phys ball that the map has by default.

new String:MODELO_JUGCT[128];
new String:MODELO_JUGTT[128];

new Float:canchaZ = 0.0; //pos. de la bola en el mapa incialmente.

new Float:PosicBallInit[3];

new debeSoltarBola[MAXPLAYERS]; //si 1, debe soltar la bola. Si 0, agarrable bola.
new grabbingBall[MAXPLAYERS];
//new Handle:g_hSDKGetSmoothedVelocity;

new CounterSoltar[MAXPLAYERS]; //when reaches certain number, drop the ball ; if more than 1, you are losing the ball

new acabaDeSalir[MAXPLAYERS]; //acaba de salir del desagarre de EEE ; ó esta es la primera vez que la agarra.

new tipoMovActual[MAXPLAYERS]; //0:quieto  ;  1:WASD  ;  2:MAXWASD ; 3:ATRASWASD ; 4:DIAGONALWASD

new contadorLento[MAXPLAYERS]; //si >= 0 , te estás volviendo lento por girar rápido con G. ver TIEMPO_ESTAR_LENTO_VELOCIDAD

new speedJugadorActual[MAXPLAYERS]; //speed del jugador actual . Se usa para no hacer getSpeed.
new speedJugadorAnterior[MAXPLAYERS]; //speed del jugador, el intervalo anterior de tiempo. Se usa para comparar con el actual.

new Float:OLDVectorDifference[3]; //el anterior vector
new Float:OLD2VectorDifference[3]; //el viejo vector
new Float:OLD3VectorDifference[3]; //el más viejo vector
new Float:OLD4VectorDifference[3]; //el más viejo vector2
new Float:OLD5VectorDifference[3]; //el más viejo vector3
new Float:OLD6VectorDifference[3]; //el más viejo vector de todos

new clientGRABBING = -1; //current client grabbing ball.

new G_key_pressed[MAXPLAYERS];
new G_counter_enlentecer[MAXPLAYERS]; //si >0, enlentecer al jugador un tiempo
new G_time_to_use_again[MAXPLAYERS]; //counter, cuando vale 0 se puede volver a usar G.
new G_internalcounter[MAXPLAYERS]; //counter, vale desde 60 hasta 0, va diciendo cuándo se termina la G

new prohibidoAgarrar[MAXPLAYERS];
new latencia_en_uso[MAXPLAYERS];
new latencia_en_shift[MAXPLAYERS];

new apretaIZQ[MAXPLAYERS];
new apretaDER[MAXPLAYERS];

new numCurvaIter = 0;

new clientQueLaCurvo = -1;

new CurvaQueLeDio = -1; //si 1, le dio 1 de curva, si 2 le dio a la derecha...

new fuerzaClick[MAXPLAYERS];
new frameSkippedCounter[MAXPLAYERS];
new ballCurve[MAXPLAYERS]; //0: no curve, 1: left on next shoot, 2: right on next shoot

new Float:timeBarraCreated[MAXPLAYERS];
new Float:timeBarraActivated[MAXPLAYERS]; //amount of time barra has been activated

new clientTieneBarra[MAXPLAYERS] ; //si 1: cliente está ejecutando una barra...... pegándole a la bola
new clientBarra[MAXPLAYERS]; //si está en 5, recién empezó a pegarle a la pelota, si está en 0, ya cargó al máximo

new Float:OriginalAngShooter[3];


new Float:AnguloUsuarioBola[MAXPLAYERS]; //ángulo entre el vector del usuario y la bola, y clientEyeAngles ; VARIABLE IMPORTANTE
new Float:distPlayerBall[MAXPLAYERS]; // DISTANCIA USUARIO - PELOTA ; otro valor muy importante.


new timeOnAir = 0; //accumulated variable which tells how much time it spent on air
new cancelarPorJugador = 0; //si 1, jugador la baja de primera (no dice quien.)

new Float:ballPos[3];
new Float:maxBallPosAlcanzado = 0.0; //máx posición de bola alcanzado. Es lo que determina la fuerza del push UP

new BallTouchingFloor = 0;
new playerTouchingFloor[MAXPLAYERS]; //si 1, tocando suelo

new animCounter[MAXPLAYERS];
new allPlayersAnim[MAXPLAYERS]; //all players, animation number. index = clientId

new rCounter[MAXPLAYERS];
new rELASTCounter[MAXPLAYERS];

new controlBTNCounter[MAXPLAYERS];

new esDefensor[MAXPLAYERS];//0: no ; 1:defensor
new esMidfielder[MAXPLAYERS];//0: no ; 1:mid
new esForward[MAXPLAYERS];//0: no ; 1:fwd

new esArquero[MAXPLAYERS];//0: jugador ; 1:arquero
new permitidoSerArquero[MAXPLAYERS]; //1: entró al área, entonces le permito ser arquero
new counterVanishGK[MAXPLAYERS]; //600: lleno ; 0: vacío=> no soy más arquero, me saca el !gk
new numPrintedParaArquero[MAXPLAYERS];
new moviendoHaciaAtras[MAXPLAYERS]; //1: tocando S

new moviendoHaciaAdelante[MAXPLAYERS];

new ballAgarrable = 1; //1: ball agarrable por cualquiera con E.

new clientEjecutaAttack[MAXPLAYERS];
new clientEjecutaPATADA[MAXPLAYERS];
new clientApretaR[MAXPLAYERS];
new clientApretaRELAST[MAXPLAYERS];
new clientApretaSTOP[MAXPLAYERS];
new clientLaQuita[MAXPLAYERS];
new clientLaAgarra[MAXPLAYERS];



new clientEnModoAmague[MAXPLAYERS];

new clientEstaWarpeado[MAXPLAYERS];

new clienteQuitesTotales[MAXPLAYERS];
new clienteAtajadasTotales[MAXPLAYERS];


new ForzarAgache[MAXPLAYERS];
new latencia_DUCK[MAXPLAYERS];

new counterEnlentecer_SALTOGK[MAXPLAYERS] = 0;


new elTiroEsVolea = 0;

//-
new entidadesanim[MAXPLAYERS];

new esAnimPatada[MAXPLAYERS];

new g_iWorldModel;//el cuchillo universal (un punto negro escondido.)

new Handle:g_strStat;

new golesCT = 0;
new golesTT = 0;

new goalScored = 0;//1 si el gol fue metido esta ronda.. (para evitar doble gol o algo así.)

new counterClickIzquierdo[MAXPLAYERS]; //contador, propósito: que no cuente tantos clicks al hacer click en el historial.

new counterSHIFT[MAXPLAYERS]; //contador, propósito: para regular el shift.

new historia_jugadas[6];

new winningTeam = -1; //2: gano TT , 3: gano CT
new losingTeam = -1;//2: perdió TT, 3: perdió CT


new acumularKicks[MAXPLAYERS]; //cuenta cantidad de own goals.

new mostradoAdvertencia[MAXPLAYERS]; //si 1, a este jugador en este mapa se le mostró advertencia.


new Accum_GOLES[MAXPLAYERS];
new Accum_ASSIST[MAXPLAYERS];
new Accum_WIN[MAXPLAYERS]; //cantidad de MVP que tiene este jugador.
new Accum_LOSE[MAXPLAYERS];
new Accum_PUNTOS[MAXPLAYERS];//puntos es todo lo que el jugador ejecuta.

//ClientCommand( client, "play *customsounds/un_sonido.mp3" );

new Handle:removerBotMSG;

new CounterMandarMSG = 0;

new ganoAntesCT = 0;
new ganoAntesTT = 0;

new jugadorPreparado[MAXPLAYERS];

new Float: PosMidArcoTT[3];
new Float: PosLeftArcoTT[3];
new Float: PosRightArcoTT[3];

new Float: PosMidArcoCT[3];
new Float: PosLeftArcoCT[3];
new Float: PosRightArcoCT[3];

new FindBallRound = 0; //if 1, we must find ball again the next round.
new anterioresCANTCT = 0;
new anterioresCANTTT = 0;
new Handle:hRestartGame = INVALID_HANDLE;

new goalAllowed = 1;

new poniendoIMGLOGO = 0;

public Plugin:myinfo =
{
  name = "arbolEEE",
  author = "ARBOL",
  description = "arbolEEE",
  version = PLUGIN_VERSION,
  url = "http://www.soccermodpro.wordpress.com"
};




public OnPluginStart()
{
    //RegConsoleCmd("sm_getsmoothedvelocity", Command_GetSmoothedVelocityDIFF);
    RegAdminCmd("smp_soccermod_1", Command_referee1, ADMFLAG_SLAY); //goal forbid
    RegAdminCmd("smp_soccermod_2", Command_referee2, ADMFLAG_SLAY); //goal allow
    RegAdminCmd("smp_soccermod_3", Command_referee3, ADMFLAG_SLAY); //ct wins
    RegAdminCmd("smp_soccermod_4", Command_referee4, ADMFLAG_SLAY); //tt wins
    RegAdminCmd("smp_soccermod_5", Command_referee5, ADMFLAG_SLAY); //round draw
    RegAdminCmd("smp_soccermod_7", Command_referee7, ADMFLAG_SLAY); //invert goals
    RegAdminCmd("smp_rounddraw", Command_referee5, ADMFLAG_SLAY); //round draw
    //RegAdminCmd("smp_soccermod_6", Command_referee6, ADMFLAG_SLAY);
    //RegAdminCmd("smp_soccermod_7", Command_referee7, ADMFLAG_SLAY);
    RegAdminCmd("smp_soccermod_8", Command_referee8, ADMFLAG_SLAY); //telep tt to admin
    RegAdminCmd("smp_soccermod_9", Command_referee9, ADMFLAG_SLAY); //telep ct to admin
    //RegAdminCmd("smp_soccermod_10", Command_referee10, ADMFLAG_SLAY);
    RegAdminCmd("smp_soccermod_11", Command_referee11, ADMFLAG_SLAY); //info ball pos

    RegAdminCmd("smp_soccermod_12", Command_referee12, ADMFLAG_SLAY); //reset match stats
    //RegAdminCmd("smp_soccermod_12", Command_referee12, ADMFLAG_SLAY);
    RegAdminCmd("smp_altura1", Command_referee13, ADMFLAG_SLAY);
    RegAdminCmd("smp_altura2", Command_referee14, ADMFLAG_SLAY);
    RegAdminCmd("smp_altura3", Command_referee15, ADMFLAG_SLAY);
    RegAdminCmd("smp_altura4", Command_referee16, ADMFLAG_SLAY);
    RegAdminCmd("smp_altura5", Command_referee17, ADMFLAG_SLAY);




    RegConsoleCmd("smp_testcom", Command_testing);
    RegConsoleCmd("smp_testpush", Command_testCurveBall);
    RegAdminCmd("smp_getball", Command_adminball, ADMFLAG_SLAY);
    RegAdminCmd("smp_removeball", Command_adminSACARball, ADMFLAG_SLAY);

    RegAdminCmd("smp_freezeall", Command_Freezeall, ADMFLAG_SLAY);
    RegAdminCmd("smp_unfreezeall", Command_UNFreezeall, ADMFLAG_SLAY);

    RegAdminCmd("smp_freezect10", Command_FreezeCT10SEC, ADMFLAG_SLAY);
    RegAdminCmd("smp_freezett10", Command_FreezeTT10SEC, ADMFLAG_SLAY);

    RegAdminCmd("smp_spawnball", Command_SpawnBallSMP, ADMFLAG_SLAY);
    RegAdminCmd("smp_spawncanion", Command_Spawncanion, ADMFLAG_SLAY);

    RegConsoleCmd("smp_leftball", Command_BallToLeft);
    RegConsoleCmd("smp_rightball", Command_BallToRight);

    RegConsoleCmd("smp_testcab", Command_TestCrouch9);
    RegConsoleCmd("sm_models", Command_Model);

    RegServerCmd("mp_restartgame", ReiniciarStats);

    HookEvent("round_start", Event_RoundStart);
    HookEvent("player_jump",PlayerJumpEvent);
    RegAdminCmd("smp_arbolspeed", Command_Speed_Manual, ADMFLAG_SLAY);
    AddCommandListener(Command_DropVelocidad, "drop");
    //RegConsoleCmd("sm_getsmoothedvelocity", Command_GetSmoothedVelocityDIFF);
    AddTempEntHook("PlayerAnimEvent", OnPlayerAnimEvent);

    RegConsoleCmd("sm_gk", Command_GK, "Type !gk to go into gk mode");
    RegConsoleCmd("sm_def", Command_DEF, "Type !def to go into def mode");
    RegConsoleCmd("sm_df", Command_DEF, "Type !def to go into def mode");
    RegConsoleCmd("sm_mf", Command_MED, "Type !mid to go into mid mode");
    RegConsoleCmd("sm_mid", Command_MED, "Type !mid to go into mid mode");
    RegConsoleCmd("sm_med", Command_MED, "Type !mid to go into mid mode");
    RegConsoleCmd("sm_fwd", Command_DEL, "Type !fwd to go into fwd mode");
    RegConsoleCmd("sm_fw", Command_DEL, "Type !fwd to go into fwd mode");
    RegConsoleCmd("sm_del", Command_DEL, "Type !fwd to go into fwd mode");

    hRestartGame = FindConVar("mp_restartgame");
    if ( hRestartGame != INVALID_HANDLE )
        HookConVarChange(hRestartGame, CBConVarChanged);

    HookEvent("player_hurt", Event_PlayerHurt);
    RegConsoleCmd("kill", Command_antiKill);
    HookEvent("player_team", Event_PlayerTeam, EventHookMode_Pre);
    HookEvent("cs_win_panel_match", finish_Game_ev);//-.-.-
    AddCommandListener(Command_JoinTeam, "jointeam");
    VariablesToZero();
    CreateTimer(0.1, timerGlobalContinuo,  _, TIMER_REPEAT);
}


doDmg(victim,damage,attacker,dmgType,String:weapon[]="")
{   //hace daño a un usuario proveniente de un arma.
    if(victim>0 && IsValidEdict(victim) && IsClientInGame(victim) && IsPlayerAlive(victim) && damage>0)
    {
        SDKHooks_TakeDamage(victim, attacker, attacker, 100.0, dmgType);
    }
} 

public Action:Command_testing(client, args){
  // for (new i = 1; i < MAXPLAYERS; i++)
  // {
  //   if (IsValidEdict(i) && IsClientInGame(i)){
  //     new String:bufn[256];
  //     GetClientName(i, bufn, sizeof(bufn) );
  //     PrintToChatAll("%d %s", i, bufn);
  //     Command_Ponerimg(i,0);
  //   }
  // }
  for (new i = 1; i < MAXPLAYERS ; i++){
      if (IsValidEntity(i)  && IsClientInGame(i) ){
            //SlapPlayer(i, 10, true);
            new int:dmgt = (1 << 1);
            //doDmg(i, 100, 0, dmgt, "ak47");  //victim, damage, attacker=EL MUNDO, binariodañotipo, arma
            //ESTO ESTABA BUENÍSIMO, DEJAR.
      }
  }
  new randomnum = GetRandomInt(0, 5);
  if (randomnum < 3){
      Command_PiernitasDer(client, 0);
  }else{
      Command_PiernitasIzq(client, 0);
      PrintToChatAll("Test command.1_amaguenuevo");
      //Command_PonerArbHub1(client,0); 
  }
}


public Action:Command_referee1(client, args){
  //forbid goals
  goalAllowed = 0;
  PrintToChatAll(" \x01\x0B\x03 SOCCERMODPRO. Goal Forbidden.");
}

public Action:Command_referee2(client, args){
  //allow goals
  goalAllowed = 1;
  PrintToChatAll(" \x01\x0B\x03 SOCCERMODPRO. Goal Allowed.");
}

public Action:Command_referee3(client, args){
  //CT Wins

  PrintToChatAll(" \x01\x0B\x03 SOCCERMODPRO. Referee determines that CT wins this round.");
  for (new i = 1; i < MAXPLAYERS ; i++){
    if (IsValidEntity(i)  && IsClientInGame(i) &&  GetClientTeam(i) == 3){
      historia_jugadas[0] = i;
      break;
    }
  }
  if (historia_jugadas[0] < 1) historia_jugadas[0] = 1;
  GanarCT();
}

public Action:Command_referee4(client, args){
  //TT Wins
  PrintToChatAll(" \x01\x0B\x03 SOCCERMODPRO. Referee determines that TT wins this round.");
  for (new i = 1; i < MAXPLAYERS ; i++){
    if (IsValidEntity(i) && IsClientInGame(i) && GetClientTeam(i) == 2){
      historia_jugadas[0] = i;
      break;
    }
  }
  if (historia_jugadas[0] < 1) historia_jugadas[0] = 1;
  GanarTT();
}

public Action:Command_referee5(client, args){
  //draw
  PrintToChatAll(" \x01\x0B\x03 SOCCERMODPRO. Round Draw.");
  exeRoundDraw();
}

public Action:Command_referee7(client, args){
  //invert goals.
  PrintToChatAll(" \x01\x0B\x03 SOCCERMODPRO. Half Time.");
  new temporal = golesTT;
  golesTT = golesCT;
  golesCT = temporal;

  exeRoundDraw();
}

public Action:Command_referee8(client, args)
{
    new Float:PosAdmin[3];
    PrintToChatAll(" \x01\x0B\x03 SOCCERMODPRO. All TT team goes to Admin position.");
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosAdmin);
    for(new i = 1; i < MAXPLAYERS; i++)
    {
      if (IsClientInGame(i) && (!IsFakeClient(i))) 
        {
          if (GetClientTeam(i) == 2){
              TeleportEntity(i, PosAdmin, NULL_VECTOR, NULL_VECTOR);
          }
      }
    }
}

public Action:Command_referee9(client, args){
    new Float:PosAdmin[3];
    PrintToChatAll(" \x01\x0B\x03 SOCCERMODPRO. All CT team goes to Admin position.");
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosAdmin);
    for(new i = 1; i < MAXPLAYERS; i++)
    {
      if (IsClientInGame(i) && (!IsFakeClient(i))) 
        {
          if (GetClientTeam(i) == 3){
              TeleportEntity(i, PosAdmin, NULL_VECTOR, NULL_VECTOR);
          }
      }
    }
}


public Action:Command_referee11(client, args){
    new Float:PosBall[3];
    GetEntPropVector(Enty, Prop_Send, "m_vecOrigin", PosBall);
    PrintToChatAll("Ball position: x %d, y %d, z %d", RoundToNearest(PosBall[0]), RoundToNearest(PosBall[1]), RoundToNearest(PosBall[2]) );
}

public Action:Command_referee12(client, args){
    //VariablesToZero();
    resetStatsToZero();
    PrintToChatAll("Match Stats resetted." );
}

public Action:Command_referee13(client, args){
    //VariablesToZero();
    new Float:PosUser[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);
    PosUser[1] += 100;
    PosUser[2] += 20;
    TeleportEntity(Enty, PosUser, NULL_VECTOR, NULL_VELOCITY);
    internal_detenerBolaPorCompleto();
    PrintToChatAll("Testing. Bola a altura 1 (por encima del piso)." );
}

public Action:Command_referee14(client, args){
    //VariablesToZero();
    new Float:PosUser[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);
    PosUser[1] += 100;
    PosUser[2] += 40;
    TeleportEntity(Enty, PosUser, NULL_VECTOR, NULL_VELOCITY);
    internal_detenerBolaPorCompleto();
    PrintToChatAll("Testing. Bola a altura 2 (rodilla aprox)." );
}

public Action:Command_referee15(client, args){
    //VariablesToZero();
    new Float:PosUser[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);
    PosUser[1] += 100;
    PosUser[2] += 60;
    TeleportEntity(Enty, PosUser, NULL_VECTOR, NULL_VELOCITY);
    internal_detenerBolaPorCompleto();
    PrintToChatAll("Testing. Bola a altura 3 (torso-cabeza)." );
}

public Action:Command_referee16(client, args){
    //VariablesToZero();
    new Float:PosUser[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);
    PosUser[1] += 100;
    PosUser[2] += 80;
    TeleportEntity(Enty, PosUser, NULL_VECTOR, NULL_VELOCITY);
    internal_detenerBolaPorCompleto();
    PrintToChatAll("Testing. Bola a altura 4 (cabeza)." );
}

public Action:Command_referee17(client, args){
    //VariablesToZero();
    new Float:PosUser[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);
    PosUser[1] += 100;
    PosUser[2] += 100;
    TeleportEntity(Enty, PosUser, NULL_VECTOR, NULL_VELOCITY);
    internal_detenerBolaPorCompleto();
    PrintToChatAll("Testing. Bola a altura 5 ( sobre la cabeza)." );


}


public Action:Command_antiKill(client, args){
  Soltar_Bola(99, client);
}

public Action:Command_adminball(client, args)
{
  new Float:PosUser[3];
  GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);
  PosUser[2] += 100;
  TeleportEntity(Enty, PosUser, NULL_VECTOR, NULL_VELOCITY);
  PrintToChatAll("Admin has the ball.");
}


public CBConVarChanged(Handle:hCVar, const String:strOld[], const String:strNew[])
{
    if ( hCVar == hRestartGame )
    {
        PrintToChatAll("Restarting match");
        resetStatsToZero();
    }
} 

public Action:ReiniciarStats(args)
{
  PrintToChatAll("Restarting match");
  resetStatsToZero();
}


public Action:Event_RestartGame(Handle:event, const String:name[], bool:dontBroadcast)
{
  PrintToChatAll("Restarting match");
  resetStatsToZero();
}


public Action:Command_adminSACARball(client, args)
{
  new Float:PosUser[3];
  GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);
  PosUser[2] += 1500;
  TeleportEntity(Enty, PosUser, NULL_VECTOR, NULL_VELOCITY);
  AcceptEntityInput(Enty, "Sleep");
  PrintToChatAll("Admin has taken ball from field.");
}

public VariablesToZero(){
  new String:estadist_a_poner[128];
  g_strStat = CreateConVar("smp_golstr", "0");
  for (new i = 0; i < 126; i++)
  {
    estadist_a_poner[i] = '!';
  }
  estadist_a_poner[123] = '\0';
  estadist_a_poner[124] = '\0';
  estadist_a_poner[125] = '\0';
  estadist_a_poner[126] = '\0';
  estadist_a_poner[127] = '\0';

  SetConVarString(g_strStat, estadist_a_poner, true, false);
  for (new i =0; i<6; i++){
    historia_jugadas[i] = 0;
  }
  for (new i = 1; i < MAXPLAYERS; i++)
    {
      entidadesanim[i] = -1 ;
      VARIABLE_DISTANCE_BETWEEN_PLAYER_AND_BALL[i] = 0.0;
      VARIABLE_ATTRACTBALL_MULTIPLIER[i] = 0.0;
      VARIABLE_BALL_HOLD_HEIGHT[i] = 0.0;
      debeSoltarBola[i] = 0;
      grabbingBall[i] = 0;
      CounterSoltar[i] = 0;
      acabaDeSalir[i] = 0;
      tipoMovActual[i] = 0;
      contadorLento[i] = -1;


      if (esArquero[i]) speedJugadorActual[i] = ARBOL_SPEED_NORMALGK;
      if (esDefensor[i] ) speedJugadorActual[i] = ARBOL_SPEED_NORMALDEF;
      if (esMidfielder[i]) speedJugadorActual[i] = ARBOL_SPEED_NORMALMID;
      if (esForward[i]) speedJugadorActual[i] = ARBOL_SPEED_NORMALFWD;


      if (esArquero[i]) speedJugadorAnterior[i] = ARBOL_SPEED_NORMALGK;
      if (esDefensor[i] ) speedJugadorAnterior[i] = ARBOL_SPEED_NORMALDEF;
      if (esMidfielder[i]) speedJugadorAnterior[i] = ARBOL_SPEED_NORMALMID;
      if (esForward[i]) speedJugadorAnterior[i] = ARBOL_SPEED_NORMALFWD;


      G_key_pressed[i] = 0;
      G_counter_enlentecer[i] = 0;
      G_time_to_use_again[i] =  ARBOL_COUNTER_REUSAR_G ;
      latencia_en_uso[i] = 0;
      prohibidoAgarrar[i] = 0;
      latencia_en_shift[i] = 0;
      apretaIZQ[i] = 0;
      apretaDER[i] = 0;

      esAnimPatada[i] = 0;

      fuerzaClick[i] = FUERZA_INICIAL_BOLA;
      frameSkippedCounter[i] = 0;
      ballCurve[i] = 0;
      timeBarraCreated[i] = 0.0;
      timeBarraActivated[i] = 0.0;

      clientTieneBarra[i] = 0;
      clientBarra[i] = 0;

      AnguloUsuarioBola[i] = 0.0;
      distPlayerBall[i] = 0.0;

      playerTouchingFloor[i] = 0;
      animCounter[i] = 0;
      allPlayersAnim[i] = 0;
      rCounter[i] = 0;
      rELASTCounter[i] = 0;
      controlBTNCounter[i] = 0;
      //esArquero[i] = 0;
      permitidoSerArquero[i] = 0;
      counterVanishGK[i] = 600;
      numPrintedParaArquero[i] = 0;
      moviendoHaciaAtras[i] = 0;
      moviendoHaciaAdelante[i] = 0;
      clientEjecutaAttack[i] = 0;
      clientEjecutaPATADA[i] = 0;
      clientApretaR[i] = 0;
      clientApretaRELAST[i] = 0;
      clientEnModoAmague[i] = 0;
      clientApretaSTOP[i] = 0;
      clientLaQuita[i] = 0;
      ForzarAgache[i] = 0;
      latencia_DUCK[i] = 0;
      clientEstaWarpeado[i] = 0;

      clientGRABBING = -1;
      CounterSoltar[i] = 0;
      debeSoltarBola[i] = 1; //stop grab ball
      ballAgarrable = 1 ;
      acabaDeSalir[i] = 0;

      goalScored=0;

      G_internalcounter[i] = 0;

      clienteAtajadasTotales[i] = 0;
      clienteQuitesTotales[i] = 0;

      counterClickIzquierdo[i] = 0;

      winningTeam = -1;
    }

}

public OnEntityCreated(entity, const String:classname[])
{
    if(StrEqual(classname, "trigger_multiple"))
    {
        SDKHook(entity, SDKHook_Touch, TouchingTheFloor);
        SDKHookEx(entity, SDKHook_EndTouch, OnUNTouchingTrigger);
        SDKHookEx(entity, SDKHook_StartTouch, OnTouchingTrigger); 
    }
}

public Action:Command_GK(client, args)
{
  if (GetClientTeam(client) < 2 ) return;

  for (new x = 1; x < MAXPLAYERS; x++)
  {
    if (IsClientInGame(x) && IsPlayerAlive(x))
    {
      if (esArquero[x] && x!=client && GetClientTeam(x) == GetClientTeam(client) ){
        PrintToChat(client, "There is a GK already.");
        return;
      }
    }
  }

  if (esArquero[client]){
    //ya era arquero, se lo saco.
    PrintToChat(client, "You are not GK anymore. (now you are defender)");
    if (GetClientTeam(client) ==2 ){
      PrecacheModel(MODELO_JUGTT, true);
      SetEntityModel(client, MODELO_JUGTT);
      SetEntityRenderColor(client, 255, 255, 255, 255);
    }
    if (GetClientTeam(client) ==3 ){
      PrecacheModel(MODELO_JUGCT, true);
      SetEntityModel(client, MODELO_JUGCT);
      SetEntityRenderColor(client, 255, 255, 255, 255);
    }
    esArquero[client] = 0;
    esMidfielder[client] = 0;
    esForward[client] = 0;
    esDefensor[client] = 1;
    return;
  }
  if (permitidoSerArquero[client]){
    PrintToChat(client, "Now you are GoalKeeper.");
    PrintToChatAll("TRATAR DE SCARLE LA BOLA por el bug de que no se puede agarrar");
    Soltar_Bola(99,client);
    if (GetClientTeam(client) ==2 ){
      PrecacheModel(MODELO_JUGTTGK, true);
      SetEntityModel(client, MODELO_JUGTTGK);
      SetEntityRenderColor(client, 255, 255, 255, 255);
    }
    if (GetClientTeam(client) ==3 ){
      PrecacheModel(MODELO_JUGCTGK, true);
      SetEntityModel(client, MODELO_JUGCTGK);
      SetEntityRenderColor(client, 255, 255, 255, 255);
    }
    
    esArquero[client] = 1;
    esMidfielder[client] = 0;
    esForward[client] = 0;
    esDefensor[client] = 0;
    esMidfielder[client] = 0;
    SetConVarInt(removerBotMSG, GetClientTeam(client), false, false);
    //PrintToChatAll("Test msg.1");
  }
  else{
    PrintToChat(client, "You need to be on the goal box");
  }
}

public Action:Command_DEF(client, args)
{
  if (GetClientTeam(client) ==2 ){
      PrecacheModel(MODELO_JUGTT, true);
      SetEntityModel(client, MODELO_JUGTT);
      SetEntityRenderColor(client, 255, 255, 255, 255);
  }
  if (GetClientTeam(client) ==3 ){
      PrecacheModel(MODELO_JUGCT, true);
      SetEntityModel(client, MODELO_JUGCT);
      SetEntityRenderColor(client, 255, 255, 255, 255);
  }
  PrintToChat(client,"Now you are defender.");
  esArquero[client] = 0;
  esMidfielder[client] = 0;
  esForward[client] = 0;
  esDefensor[client] = 1;
}


public Action:TIMERCommand_DEF(Handle:timer, any:client)
{
  if (!IsClientInGame(client) ) return;
  if (GetClientTeam(client) ==2 ){
      PrecacheModel(MODELO_JUGTT, true);
      SetEntityModel(client, MODELO_JUGTT);
      SetEntityRenderColor(client, 255, 255, 255, 255);
  }
  if (GetClientTeam(client) ==3 ){
      PrecacheModel(MODELO_JUGCT, true);
      SetEntityModel(client, MODELO_JUGCT);
      SetEntityRenderColor(client, 255, 255, 255, 255);
  }
  PrintToChat(client,"Now you are defender.");
  esArquero[client] = 0;
  esMidfielder[client] = 0;
  esForward[client] = 0;
  esDefensor[client] = 1;
}

public Action:Command_MED(client, args)
{
  if (GetClientTeam(client) ==2 ){
      PrecacheModel(MODELO_JUGTT, true);
      SetEntityModel(client, MODELO_JUGTT);
      SetEntityRenderColor(client, 255, 255, 255, 255);
  }
  if (GetClientTeam(client) ==3 ){
      PrecacheModel(MODELO_JUGCT, true);
      SetEntityModel(client, MODELO_JUGCT);
      SetEntityRenderColor(client, 255, 255, 255, 255);
  }
  PrintToChat(client,"Now you are MidFielder.");
  esArquero[client] = 0;
  esMidfielder[client] = 1;
  esForward[client] = 0;
  esDefensor[client] = 0;
}

public Action:Command_DEL(client, args)
{
  if (GetClientTeam(client) ==2 ){
      PrecacheModel(MODELO_JUGTT, true);
      SetEntityModel(client, MODELO_JUGTT);
      SetEntityRenderColor(client, 255, 255, 255, 255);
  }
  if (GetClientTeam(client) ==3 ){
      PrecacheModel(MODELO_JUGCT, true);
      SetEntityModel(client, MODELO_JUGCT);
      SetEntityRenderColor(client, 255, 255, 255, 255);
  }
  PrintToChat(client,"Now you are Forward.");
  esArquero[client] = 0;
  esMidfielder[client] = 0;
  esForward[client] = 1;
  esDefensor[client] = 0;
}



public Action:Command_BallToLeft(client, args)
{ //tiene que ser con SHIFT A
  ballCurve[client] = 1;
  PrintToChat(client,"Ball to left on next shoot.");
}

public Action:Command_BallToRight(client, args)
{ //tiene que ser con SHIFT D
  ballCurve[client] = 2;
  PrintToChat(client,"Ball to right on next shoot.");
}

public ponerBarraEnValor(any:client, float valornuevo){

}

public Action:createBARRA(client){
    clientTieneBarra[client] = 1;
    clientBarra[client] = 5;
    timeBarraCreated[client] = GetGameTime() - 0.5;
    SetEntPropFloat(client, Prop_Send, "m_flProgressBarStartTime", GetGameTime() - 0.5);
    //PrintHintTextToAll("%f \n _ %f" , GetGameTime() - 0.5, GetGameTime() - 3.5 );
    SetEntProp(client, Prop_Send, "m_iProgressBarDuration", RoundFloat(DURACION_BARRA))
    //para matar el turbo SetEntProp(client, Prop_Send, "m_iProgressBarDuration", 0)
    //CreateTimer(DURACION_BARRA, destroyBARRACreated, client);
}

// public Action:destroyBARRACreated(Handle:timer, any:entindex)
// {
//   destroyBARRAahora(entindex);
//   return Plugin_Stop;
// }

public Action:destroyBARRAahora(any:entindex) //entindex es como client..
{
  clientTieneBarra[entindex] = 0;
  timeBarraActivated[entindex] = GetGameTime() - timeBarraCreated[entindex];
  SetEntProp(entindex, Prop_Send, "m_iProgressBarDuration", 0)
  //PrintToChatAll("test_curveBall::barra destroyed. Duration: %f", timeBarraActivated );
}



public Action:OnPlayerRunCmd(iClient, &iButtons, &iImpulse, Float:fVelocity[3], Float:fAngles[3], &iWeapon) {
  if (ForzarAgache[iClient])
    iButtons |= IN_DUCK;
}



public Action:Event_RoundStart(Handle:event, const String:name[], bool:dontBroadcast){
    goalAllowed = 1;
    if (FindBallRound == 1) FindBola();
    internal_detenerBolaPorCompleto();
    new encontreArquero = 0;
    for (new x = 1; x < MAXPLAYERS; x++)
    {
    if (IsClientInGame(x) && IsPlayerAlive(x))
      {
        if (GetClientTeam(x) == 2 ){
          //MODELO_JUGCT
          if (esArquero[x] && encontreArquero == 0){
            encontreArquero = 1; //TODO ok
          }else{
            if (esArquero[x] && encontreArquero == 1){
                  //ES ARQUERO PERO YA HABÍA ENCONTRADO A UN ARQUERO
                  PrintToChatAll("(HAY DOS ARQUEROS TEAM 2, REMUEVO A UNO)");
                  Command_DEF(x,0);
            }
          }
        }
      }
    }

    encontreArquero = 0;
    for (new x = 1; x < MAXPLAYERS; x++)
    {
    if (IsClientInGame(x) && IsPlayerAlive(x))
      {
        if (GetClientTeam(x) == 3 ){
          //MODELO_JUGCT
          if (esArquero[x] && encontreArquero == 0){
            encontreArquero = 1; //TODO ok,
          }else{
            if (esArquero[x] && encontreArquero == 1){
                  //ES ARQUERO PERO YA HABÍA ENCONTRADO A UN ARQUERO
                  PrintToChatAll("(HAY DOS ARQUEROS TEAM 3, REMUEVO A UNO)");
                  Command_DEF(x,0);
            }
          }
        }
      }
    }

    for (new x = 1; x < MAXPLAYERS; x++)
    {
    if (IsClientInGame(x) && IsPlayerAlive(x))
      {
        Soltar_Bola(99, x);
        VariablesToZero();
        //ClientCommand( x, "play *customsounds/sifflet_start_arb.mp3" );



        Command_RemoveKnife3p(x,0);
        //por alguna razón se des-setean las stats del tab al inicio de ronda. RE_setear
        CS_SetMVPCount(x, Accum_WIN[x]);
        CS_SetClientAssists(x, Accum_ASSIST[x]);  
        SetEntProp(x, Prop_Data, "m_iDeaths", Accum_LOSE[x] );
        SetEntProp(x, Prop_Data, "m_iFrags", Accum_GOLES[x] ) ;
        CS_SetClientContributionScore(x, Accum_PUNTOS[x]);
        if (GetClientTeam(x) == 2 ){
          //MODELO_JUGCT
          if (esArquero[x])
            SetEntityModel(x, MODELO_JUGTTGK);
          else
            SetEntityModel(x, MODELO_JUGTT);
          SetEntityRenderColor(x, 255, 255, 255, 255);
        }
        if (GetClientTeam(x) == 3 ){
          //MODELO_JUGCT
          if (esArquero[x])
            SetEntityModel(x, MODELO_JUGCTGK);
          else
            SetEntityModel(x, MODELO_JUGCT);
          SetEntityRenderColor(x, 255, 255, 255, 255);
        }
      }
    }
    CreateTimer(0.9, ArreglarPosiciones, 0);
    internal_detenerBolaPorCompleto();
    PrintToChatAll("(sacar bola por bug de que no se puede agarrar)");
    for (new x = 1; x < MAXPLAYERS; x++)
    {
    if (IsClientInGame(x) && IsPlayerAlive(x))
      {
                Soltar_Bola(99, x);
      }
    }
    //Y UN POCO DE SPAM PORQUE ESTO ES BETA !
    //CreateTimer(40.9, EspamearMensage2, 0);
    //CreateTimer(41.9, EspamearMensage1, 0);
}

public Action:EspamearMensage2(Handle:timer, any:client){
    PrintToChatAll("SMP BETA ___ An improved version will be released soon !");
    PrintToChatAll("SMP BETA ___ An improved version will be released soon !");
    PrintHintTextToAll("SMP BETA ___ An improved version will be released soon !");
}

public Action:EspamearMensage1(Handle:timer, any:client){
    PrintToChatAll("SMP BETA (work in progress)");
    PrintToChatAll("SMP BETA (work in progress)");
    PrintHintTextToAll("SMP BETA (work in progress)");

}

public Action:ArreglarPosiciones(Handle:timer, any:client){
  new teleporteadoTT = 0;
  new teleporteadoCT = 0;
  for (new x = 1; x < MAXPLAYERS; x++)
  {
    if (IsClientInGame(x) && IsPlayerAlive(x))
    {
      if (esArquero[x] && GetClientTeam(x) == 2){
        //poner en arco TT
        TeleportEntity(x, PosMidArcoTT, NULL_VECTOR, NULL_VECTOR);
      }else{
        if (GetClientTeam(x) == 2 && teleporteadoTT == 0  && ganoAntesCT == 1 ){
          teleporteadoTT = 1;
          new Float:PosUser[3];
          GetEntPropVector(x, Prop_Send, "m_vecOrigin", PosUser);
          new Float:DiffConUser[3];
          DiffConUser[0] = PosUser[0] + (PosicBallInit[0] - PosUser[0] ) / 3.0 ;
          DiffConUser[1] = PosUser[1] + (PosicBallInit[1] - PosUser[1] ) / 3.0 ;
          DiffConUser[2] = PosicBallInit[2];
          TeleportEntity(x, DiffConUser, NULL_VECTOR, NULL_VECTOR);
        }
      }
      if (esArquero[x] && GetClientTeam(x) == 3){
        //poner en arco CT
        TeleportEntity(x, PosMidArcoCT, NULL_VECTOR, NULL_VECTOR);
      }else{
        if (GetClientTeam(x) == 3 && teleporteadoCT == 0 && ganoAntesTT == 1 ) {
          teleporteadoCT = 1;
          new Float:PosUser[3];
          GetEntPropVector(x, Prop_Send, "m_vecOrigin", PosUser);
          new Float:DiffConUser[3];
          DiffConUser[0] = PosUser[0] + (PosicBallInit[0] - PosUser[0] ) / 3.0 ;
          DiffConUser[1] = PosUser[1] + (PosicBallInit[1] - PosUser[1] ) / 3.0 ;
          DiffConUser[2] = PosicBallInit[2];
          TeleportEntity(x, DiffConUser, NULL_VECTOR, NULL_VECTOR);
        }
      }
    }
  }

}



public Action:Command_DropVelocidad(client, const String:command[], argc){//velocidad
    
    if (G_key_pressed[client] == 1 ){
          G_key_pressed[client] = 0;
          internal_apagarVelocidad(client);
          return Plugin_Handled;
    }

    if (G_key_pressed[client] == 0 && G_time_to_use_again[client] > 10){
          G_time_to_use_again[client] -= ARBOL_COUNTER_G_RESTARLE_POR_CENTESIMA_DE_SEG ; //ESTO ES PENALIZACIÓN POR SPAMMEAR G
          G_key_pressed[client] = 1;
          //CreateTimer(6.0, apagarVelocidad, client);
          //PrintToChat(client, "G Prendido");
          ClientCommand( client, "play *customsounds/outofbreath_arb.mp3" );
          return Plugin_Handled;
    }

    // if (G_key_pressed[client] == 0 && G_time_to_use_again[client] == 0){
    //       G_key_pressed[client] = 1;
    //       G_internalcounter[client] = 60;
    //       CreateTimer(6.0, apagarVelocidad, client);
    //       //PrintToChat(client, "G Prendido");
    //       ClientCommand( client, "play *customsounds/outofbreath_arb.mp3" );
    //       return Plugin_Handled;
    // }
    return Plugin_Handled;
}


public PlayerJumpEvent(Handle:event,const String:name[],bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event,"userid"));
    //PrintToChatAll("Detected jump for: %d" , client);
    ////LE REMUEVO EL SALTO DE ARQUERO !!!!
    ////LE REMUEVO EL SALTO DE ARQUERO !!!!
    // if (esArquero[client] && G_key_pressed[client] == 1){
    //   CreateTimer(0.2, SaltoDeArquero, client);
    //   CreateTimer(0.8, lentitud_arquero_timer, client); //lo medí en 0.9 seg el salto..
    //   if (apretaIZQ[client]){
    //           //PrintToChatAll("anim salto izq");
    //           Command_TestCrouch7(client, 0);
    //   }else{
    //         if (apretaDER[client]){
    //           //PrintToChatAll("anim salto der");
    //           Command_TestCrouch8(client, 0);
    //         }

    //   }
     
    // }
    if (!esArquero[client]) Soltar_Bola(99, client);
    internal_terminarBarrida(client);//forzarle a que se le salga la barrida
}

public Action:lentitud_arquero_timer(Handle:timer, any:client){
      counterEnlentecer_SALTOGK[client] = ENLENTECER_LUEGO_DE_SALTO_GK ;
      return Plugin_Stop;
}



public Action:SaltoDeArquero(Handle:timer, any:client){
      if (esArquero[client] && permitidoSerArquero[client]){
        //hacer el salto largo
        new Float:PosUser[3];
        GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);
        new Float:vec[3];
        GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
        vec[0] *= 1.75;
        vec[1] *= 1.75;
        vec[2] += 85;
        TeleportEntity(client, NULL_VECTOR, NULL_VECTOR, vec);
        //PrintToChat(client, "fin salto arquero");
        //animaciones salto arquero.
        if (G_key_pressed[client] == 1){
          if ( !apretaIZQ[client] && !apretaDER[client] && !moviendoHaciaAtras[client] && !moviendoHaciaAdelante[client]){
            if (!IsValidEdict(entidadesanim[client]) ) //no hay anim ejecutada, entonces si.
              Command_TestCrouch5(client, 0);
          }
        }
        return Plugin_Stop;
      }
      return Plugin_Stop;
}


public Action:IntentarAgarrarla(client)
{
      if (distPlayerBall[client]> RADIUS_GRABE + 100 ){
        return;
      }
      if (clientEnModoAmague[client] == 1){
        //PrintHintTextToAll("NO PODES AGARRARLA PORQUE ENMODOAMAGUE");
        return; //está en modo amague, no quiere agarrarla.
      }

      if (prohibidoAgarrar[client] > 0){
        //PrintHintTextToAll("NO PODES AGARRARLA PORQUE prohibidoAgarrar");
        return; //no podés agarrarla.
      }
      for (new x = 1; x<MAXPLAYERS; x++){
        if (clientGRABBING!=-1){
          //PrintHintTextToAll("NO PODES AGARRARLA PORQUE clientGRABBING");

          return; //ya había alguien agarrando...
        }
      }
      if (esArquero[client] == 1){
        if (clientGRABBING == client){
          //es arquero, la tiene agarrada y volvió a apretar E, soltarla...
          numPrintedParaArquero[client] = 0;
          return;
        }
        else if (numPrintedParaArquero[client] == 0 && permitidoSerArquero[client] == 1 && (GetClientTeam(historia_jugadas[0] ) != GetClientTeam(client) ) ){
            latencia_en_uso[client] = LATENCIA_MAX_INUSE * 2; //MOLESTARLO incluso si está muy lejos.
            //es arquero: si está cerca que agarre la bola y Punto
            new Float:PosBall[3];
            new Float:PosUser[3];
            GetEntPropVector(Enty, Prop_Send, "m_vecOrigin", PosBall);
            GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);
            new Float:distPlayerBallAHORA = GetVectorDistance(PosBall, PosUser);
            if (distPlayerBallAHORA < 95.0 && AnguloUsuarioBola[client] < 2.36 && ballAgarrable ){
              CreateTimer(0.1, attractToGK,  client, TIMER_REPEAT);
              for (new x = 1; x<MAXPLAYERS; x++){
                Soltar_Bola(99,x);
              }
              clientGRABBING = client;
              ballAgarrable = 0;
              //PrintToChat(client, "arbolGKGrab: start grab ball.");
              clientLaAgarra[client] = 1;
              return;
            }else{
              //PrintToChat(client, "arbolGKGrab: fallaste y tenEs que esperar 2 seg para agarrarla de vuelta.");
            }
        }

      }
      //si llegó acá puede ser arquero que no la agarró antes, o jugador normal.
      if (distPlayerBall[client]> RADIUS_GRABE || ForzarAgache[client] == 1){
        //              PrintHintTextToAll("NO PODES AGARRARLA PORQUE distPlayerBall");

        return;
      }

      if (playerTouchingFloor[client] == 0){
        //                      PrintHintTextToAll("NO PODES AGARRARLA PORQUE playerTouchingFloor");
        return;
      }
      if ((esArquero[client] && permitidoSerArquero[client] == 0)){
        //es arquero pero está fuera del área
      }
      if(esArquero[client] && permitidoSerArquero[client] == 1 ){
        //es arquero y está en el área, no la puede agarrar
        return;
      }
      latencia_en_uso[client] = LATENCIA_MAX_INUSE
      if (debeSoltarBola[client] == 1){
          new Float:PosBall[3];
          new Float:PosUser[3];
          GetEntPropVector(Enty, Prop_Send, "m_vecOrigin", PosBall);
          GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);
          new Float:distPlayerBallAHORA = GetVectorDistance(PosBall, PosUser);
          new Float:ELANGULO = AnguloUsuarioBola[client];
          if (ELANGULO > 1.24) {
            //si estás ang mayor a 70° , no podés agarrar la bola
            //PrintToChatAll("mucho angulo, no podes agarrar. 60 ")
          }
          else{
              if (distPlayerBallAHORA < RADIUS_GRABE && ballAgarrable ){
                  for (new x = 1; x<MAXPLAYERS; x++){
                    Soltar_Bola(99,x);
                  }
                  debeSoltarBola[client] = 0;
                  clientGRABBING = client;
                  acabaDeSalir[client] = 1;
                  clientLaAgarra[client] = 1;
                  //PrintToChat(client, "arbolEEE: start grab ball.");
              }
          }

        }else{
            Soltar_Bola(0, client);
            //                              PrintHintTextToAll("NO PODES AGARRARLA PORQUE Soltar_Bola");

      }

      return;
}



public Action:attractToGK(Handle:timer, any:client){
    // if (!esArquero[client] || !permitidoSerArquero[client]){ NO DEBERÍA OCURRIR NUNCA
    //   numPrintedParaArquero[client] = 0;
    //   Soltar_Bola(4);
    //   return Plugin_Stop;
    // }
    if (clientGRABBING==-1 || AnguloUsuarioBola[client] > 2.35 || (playerTouchingFloor[client] == 0 && BallTouchingFloor == 1)) {
      //PrintToChatAll("No se pudo agarrar?");
      numPrintedParaArquero[client] = 0;
      return Plugin_Stop;
    }
    new Float:PosBall[3];
    new Float:PosUser[3];
    new Float:VectorDifference[3];
    GetEntPropVector(Enty, Prop_Send, "m_vecOrigin", PosBall);
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);

    ///
    //PrintToChat(client, "SOCCERMODPRO. Ball attracted  0.");
    new Float:destOrigin[3];
    decl Float:clientOrigin[3];
    decl Float:clientEyeAngles[3];
    GetClientAbsOrigin(client, clientOrigin);
    GetClientEyeAngles(client, clientEyeAngles);
    new Float:cos = Cosine(DegToRad(clientEyeAngles[1]));
    new Float:sin = Sine(DegToRad(clientEyeAngles[1]));
    
    new MULTIPLICADOR_ATRAS = 1;
    if (moviendoHaciaAtras[client] || (apretaIZQ[client] && !moviendoHaciaAtras[client] && !moviendoHaciaAdelante[client]) || (apretaDER[client] && !moviendoHaciaAtras[client] && !moviendoHaciaAdelante[client])){
      MULTIPLICADOR_ATRAS = 0;
    }

    destOrigin[0] = clientOrigin[0] + cos * (GK_DISTANCE_BETWEEN_PLAYER_AND_BALL + (30 * MULTIPLICADOR_ATRAS ) );
    destOrigin[1] = clientOrigin[1] + sin * (GK_DISTANCE_BETWEEN_PLAYER_AND_BALL + (30 * MULTIPLICADOR_ATRAS ) );
    destOrigin[2] = clientOrigin[2] + GK_BALL_HOLD_HEIGHT ;

    //PrintToChat(client, "SOCCERMODPRO. Ball attracted  1.");
    //TeleportEntity(enty, orig_ball, NULL_VECTOR, NULL_VECTOR); 
    //TeleportEntity(enty, destOrigin, clientEyeAngles, NULL_VECTOR); //changed.
    ///

    //TeleportEntity(Enty, destOrigin, NULL_VECTOR, NULL_VECTOR); //NO CONVIENE PORQUE GENERA BUGS


    VectorDifference[0] = (destOrigin[0] - PosBall[0]) * GK_ATTRACTBALL_MULTIPLIER ;
    VectorDifference[1] = (destOrigin[1] - PosBall[1]) * GK_ATTRACTBALL_MULTIPLIER ;
    VectorDifference[2] = (destOrigin[2] - PosBall[2]) * GK_ATTRACTBALL_MULTIPLIER ;
    TeleportEntity(Enty, NULL_VECTOR, NULL_VELOCITY, VectorDifference);
    ballAgarrable = 0;
 
    numPrintedParaArquero[client]++;
    if (numPrintedParaArquero[client] >= DECISEGUNDOS_PERMITIDOARQUERO_AGARRARLA){
      Soltar_Bola(98, client); //soltar bola para arquero que la tiene en la mano.
      return Plugin_Stop;
    }
    return Plugin_Continue;
}




public Soltar_Bola(num, client){ 
    if (!IsClientInGame(client) ) return;
    if (client == -1){
      //sacársela a todos?
      new hjk = 0;
      for (hjk= 0 ; hjk< MAXPLAYERS ; hjk++){
        clientGRABBING = -1;
        CounterSoltar[hjk] = 0;
        debeSoltarBola[hjk] = 1; //stop grab ball
        ballAgarrable = 1 ;
        acabaDeSalir[hjk] = 0;
      }
    }
    //PrintToChatAll("me pidieron soltarla %d %d", client, clientGRABBING);
    if (clientGRABBING == client){
      //AcceptEntityInput(Enty, "Sleep"); AL CONTRARIO, DESPERTARLA.
      TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, NULL_VELOCITY);
      clientGRABBING = -1;
      CounterSoltar[client] = 0;
      debeSoltarBola[client] = 1; //stop grab ball
      ballAgarrable = 1 ;
      acabaDeSalir[client] = 0;
    }
    
    

    //CounterSoltar[client] = 0;
    
    if (num == 0){
        //PrintToChat(client, "arbolEEE: stop grab ball. estaba agarrando");
    }
    if (num == 1){
        //PrintToChat(client, "arbolEEE: stop grab ball. DEMASIDO LEJOS");
    }
    if (num == 2){
        //PrintToChat(client, "arbolEEE: stop grab ball. PASO MUCHO TIEMPO SIN RE-AGARRARLA");
    }
    if (num == 3){
        //PrintToChat(client, "arbolEEE: stop grab ball. Salto");
    }
    if (num == 4){
        //PrintToChat(client, "arbolEEE: stop grab ball. Arquero");
    }
    if (num == 89){
      //89: penalización por haber sido barrido
      //latencia_en_uso[client] = LATENCIA_MAX_INUSE * 10;
      prohibidoAgarrar[client] = TIEMPO_PROHIBIDO_AGARRAR_RECIBOBARRIDA;
      return;
    }
    if (num == 91){
      //91: penalización por barrrer siendo el que la conduce.
      //latencia_en_uso[client] = LATENCIA_MAX_INUSE * 10;
      prohibidoAgarrar[client] = TIEMPO_BARRIDA_PROHIBIDO_AGARRAR;
      return;
    }
    if (num == 92){
      //92: penalización por ser el que clickea IZQ y la tiene agarrada en simultáneo
      prohibidoAgarrar[client] = TIEMPO_PATEOPELOTACLICKIZQ_PROHIBIDO_AGARRAR;
      return;
    }
    if (num == 93){
      //93: penalización por haber sido lastimado con click derecho
      prohibidoAgarrar[client] = TIEMPO_LASTIMADOCLICKDER_PROHIBIDO_AGARRAR;
      return;
    }
    if (num == 94){
      //94: penalización por ser el que recibe un click IZQ y la tiene agarrada
      prohibidoAgarrar[client] = TIEMPO_LASTIMADOCLICKIZQ_PROHIBIDO_AGARRAR;
      return;
    }
    if ( num == 98 ){
      //PrintToChat(client, "arbolGKGrab: stop grab ball.");
      numPrintedParaArquero[client] = 0;
      ballAgarrable = 1;
    }
    if (num == 99){
      return;
    }
    //PrintHintText(client, "PERDISTE LA BOLA");
}


public internal_apagarVelocidad(any:client){
  //G_time_to_use_again[client] = ARBOL_COUNTER_REUSAR_G ;
  G_key_pressed[client] = 0;
  G_counter_enlentecer[client] = ARBOL_COUNTER_LENTITUDG ;
  if (esArquero[client]) EstablecerSpeed(client, ARBOL_SPEED_NORMALGK);
  if (esDefensor[client] ) EstablecerSpeed(client, ARBOL_SPEED_NORMALDEF);
  if (esMidfielder[client]) EstablecerSpeed(client, ARBOL_SPEED_NORMALMID);
  if (esForward[client]) EstablecerSpeed(client, ARBOL_SPEED_NORMALFWD);
  //PrintToChat(client, "G APAGADO");
}

public Action:apagarVelocidad(Handle:timer, any:client){
  internal_apagarVelocidad(client);
}

public Action:timerGlobalContinuo(Handle:timer){

    if (CounterMandarMSG > 0) CounterMandarMSG--;
    new hayct = 0;
    new haytt = 0;
    new hayctVERD = 0;
    new hayttVERD = 0;
    for (new x = 1; x < MAXPLAYERS; x++)
    {
      if (IsClientInGame(x) && IsPlayerAlive(x))
      {
        if (animCounter[x] > 0) animCounter[x] --;
        if(latencia_en_uso[x] > 0 ) latencia_en_uso[x] --;
        if(prohibidoAgarrar[x] > 0 ){
          prohibidoAgarrar[x] --;
          //PrintHintTextToAll( "falta para poder agarrar: %d", prohibidoAgarrar[x]);
        }
        //if (prohibidoAgarrar[x] == 1) PrintToChatAll( "el jugador   %d   puede agarrarla ahora", x);
        if(latencia_en_shift[x] > 0 ) latencia_en_shift[x] --;
        if (rCounter[x]>0) rCounter[x]--;
        if (rELASTCounter[x]>0) rELASTCounter[x]--;
        if (controlBTNCounter[x]>0) controlBTNCounter[x]--;
        if (latencia_DUCK[x] > 0) latencia_DUCK[x]--;
        if (counterClickIzquierdo[x] > 0) counterClickIzquierdo[x]--;
        if (counterSHIFT[x] > 0) counterSHIFT[x]--;
        if (G_internalcounter[x] > 0) G_internalcounter[x]--;
        if (contadorLento[x] > 0) contadorLento[x]--;
        if (poniendoIMGLOGO > 0) poniendoIMGLOGO--;

        if (clientEstaWarpeado[x] > 0) clientEstaWarpeado[x]--;
        
        if (GetClientTeam(x) == 2) hayttVERD ++;
        if (GetClientTeam(x) == 3) hayctVERD ++;
        if (GetClientTeam(x) == 2 && esArquero[x] ) haytt++;
        if (GetClientTeam(x) == 3 && esArquero[x] ) hayct++;

        //FuncionControles(x);
        FuncionIEEE(x);
        FuncionBARRA(x);
        FuncionHabilidades(x);
        FuncionVelocidad(x);
        FuncionSTATS1(x);

        //PrintHintText(x, "playerTouchingFloor %d" , playerTouchingFloor[x]);

        if(GameRules_GetProp("m_bWarmupPeriod") == 1)
        {
          //PrintHintTextToAll("warmupppp.");
          goalAllowed = 0;
          Command_Ponerimg(x, 0);
        } 
        if (poniendoIMGLOGO == 0){
                  Command_PonerArbHub1(x, 1);
                  if (G_key_pressed[x] > 0){
                    //t2, t3, o t6
                    if (x == clientGRABBING) Command_PonerArbHub1(x, 3);
                    else Command_PonerArbHub1(x, 2);
                    if (CounterSoltar[x] > 0) Command_PonerArbHub1(x, 6);
                  }else{
                    if (x == clientGRABBING) Command_PonerArbHub1(x, 4);
                    if (CounterSoltar[x] > 0) Command_PonerArbHub1(x, 5);
                  }
        }

      }
    }

    if (hayctVERD >=1 && anterioresCANTCT == 0){
      //sumando ambos dan 1, hay un solo jugador.
      PrintToChatAll("Game stats resetted . Starting match.");
      resetStatsToZero();
    }
    if (hayttVERD >=1 && anterioresCANTTT == 0){
      //sumando ambos dan 1, hay un solo jugador.
      PrintToChatAll("Game stats resetted . Starting match.");
      resetStatsToZero();
    }
    anterioresCANTTT = hayttVERD;
    anterioresCANTCT = hayctVERD;

    if (CounterMandarMSG == 0){
          CounterMandarMSG = 13;
          new prob = GetRandomInt(1,4);
          if (!hayct && prob==1){
            SetConVarInt(removerBotMSG, 6, false, false);
          }
          if (!haytt && prob==2){
            SetConVarInt(removerBotMSG, 4, false, false);
          }
          if (hayct && prob==3){
            SetConVarInt(removerBotMSG, 3, false, false);
          }
          if (haytt && prob==4){
            SetConVarInt(removerBotMSG, 2, false, false);
          }
    }

    

    

    FuncionSLOWBALL();

    //PrintHintTextToAll("%d %d %d %d %d %d",historia_jugadas[0], historia_jugadas[1],historia_jugadas[2],historia_jugadas[3],historia_jugadas[4],historia_jugadas[5]);
    //PrintHintTextToAll("player: %d \nball: %d", playerTouchingFloor , BallTouchingFloor);
    return Plugin_Continue;
}

public FuncionHabilidades(client){
  if (esArquero[client]){

    if (permitidoSerArquero[client] == 1){

      if (counterVanishGK[client] < DECISEGUNDOS_ARQUERO_FUERADEAREA_GRACIA ) counterVanishGK[client]++;

      }
      else{
        
        if (numPrintedParaArquero[client] > 0){
                Soltar_Bola(98, client); //soltar bola para arquero que la tiene en la mano.
        }

        if (counterVanishGK[client] > 0){
          counterVanishGK[client]--;
          //EXPERIMENTAR CON MESSAGES
          //EXPERIMENTAR CON MESSAGES
          //EXPERIMENTAR CON MESSAGES
          //https://wiki.alliedmods.net/User_messages
          if (counterVanishGK[client] == 0){
              PrintHintText(client, "You lost GK");
              esArquero[client] = 0;
              if (GetClientTeam(client) ==2 ){
                PrecacheModel(MODELO_JUGTT, true);
                SetEntityModel(client, MODELO_JUGTT);
                SetEntityRenderColor(client, 255, 255, 255, 255);
              }
              if (GetClientTeam(client) ==3 ){
                PrecacheModel(MODELO_JUGCT, true);
                SetEntityModel(client, MODELO_JUGCT);
                SetEntityRenderColor(client, 255, 255, 255, 255);
              }
            }else{
              PrintHintText(client, "You will lose GK in %d seconds", counterVanishGK[client]/10);
            }
          //StopSound(client, SNDCHAN_STATIC, "UI/hint.wav"); //para deshabilitar sound del hint
        }
        
      }
  }
}

public FuncionVelocidad(x){
  //esta función controla la velocidad de todos los jugadores. En ningún otro punto, salvo round_start, se controla velocidad.

        new supuesta_nueva_velocidad = 0; //va chequeando cuál va a ser la velocidad final supuestamente. 
        new rec1;
        new rec2;
        new rec3;
        new rec4;
        if (esDefensor[x]){
            if (G_key_pressed[x] == 1) supuesta_nueva_velocidad = ARBOL_SPEED_MAXVELNUMDEF;
            if (G_key_pressed[x] == 0) supuesta_nueva_velocidad = ARBOL_SPEED_NORMALDEF;
        }
        if (esMidfielder[x]){
            if (G_key_pressed[x] == 1) supuesta_nueva_velocidad = ARBOL_SPEED_MAXVELNUMMID;
            if (G_key_pressed[x] == 0) supuesta_nueva_velocidad = ARBOL_SPEED_NORMALMID;
        }
        if (esForward[x]){
            if (G_key_pressed[x] == 1) supuesta_nueva_velocidad = ARBOL_SPEED_MAXVELNUMFWD;
            if (G_key_pressed[x] == 0) supuesta_nueva_velocidad = ARBOL_SPEED_NORMALFWD;
        }
        if (esArquero[x]){
            if (G_key_pressed[x] == 1) supuesta_nueva_velocidad = ARBOL_SPEED_MAXVELNUMGK;
            if (G_key_pressed[x] == 0) supuesta_nueva_velocidad = ARBOL_SPEED_NORMALGK;
        }

          
        if (contadorLento[x] == 0 ) contadorLento[x]--; //evita que se siga chequeando este condicional. (?????)

        rec1 = supuesta_nueva_velocidad;
        if (G_key_pressed[x] == 1){

          if (esDefensor[x]){
            supuesta_nueva_velocidad = ARBOL_SPEED_MAXVELNUMDEF;
          }
          if (esMidfielder[x]){
            supuesta_nueva_velocidad = ARBOL_SPEED_MAXVELNUMMID;
          }
          if (esForward[x]){
            supuesta_nueva_velocidad = ARBOL_SPEED_MAXVELNUMFWD;
          }
          if (esArquero[x]){
            supuesta_nueva_velocidad = ARBOL_SPEED_MAXVELNUMGK;
          }

          //supuesta_nueva_velocidad = ARBOL_SPEED_MAXVEL1; //EstablecerSpeed(x, ARBOL_SPEED_MAXVEL1);
        }
        if (contadorLento[x] > 0){

          if (esDefensor[x]){
            supuesta_nueva_velocidad = ARBOL_SPEED_LENTO; //EstablecerSpeed(x, ARBOL_SPEED_MAXVEL1 );
          }
          if (esMidfielder[x]){
            supuesta_nueva_velocidad = ARBOL_SPEED_LENTO; //EstablecerSpeed(x, ARBOL_SPEED_MAXVEL1 );
          }
          if (esForward[x]){
            supuesta_nueva_velocidad = ARBOL_SPEED_LENTO; //EstablecerSpeed(x, ARBOL_SPEED_MAXVEL1 );
          }
          if (esArquero[x]){
            supuesta_nueva_velocidad = ARBOL_SPEED_LENTO; //EstablecerSpeed(x, ARBOL_SPEED_MAXVEL1 );
          }


          //supuesta_nueva_velocidad = ARBOL_SPEED_LENTO; //EstablecerSpeed(x, ARBOL_SPEED_LENTO);
        }
        rec2 = supuesta_nueva_velocidad;

        if (clientEstaWarpeado[x] > 0){ //el jugador está warpeado por haber retrocedido con la pelota demasiada distancia.
          //o por estar pateando y en velocidad.

          if (esDefensor[x]){
            supuesta_nueva_velocidad = ARBOL_SPEED_LENTO; //EstablecerSpeed(x, ARBOL_SPEED_MAXVEL1 );
          }
          if (esMidfielder[x]){
            supuesta_nueva_velocidad = ARBOL_SPEED_LENTO; //EstablecerSpeed(x, ARBOL_SPEED_MAXVEL1 );
          }
          if (esForward[x]){
            supuesta_nueva_velocidad = ARBOL_SPEED_LENTO; //EstablecerSpeed(x, ARBOL_SPEED_MAXVEL1 );
          }
          if (esArquero[x]){
            supuesta_nueva_velocidad = ARBOL_SPEED_LENTO; //EstablecerSpeed(x, ARBOL_SPEED_MAXVEL1 );
          }


          //supuesta_nueva_velocidad = ARBOL_SPEED_LENTO; //EstablecerSpeed(x, ARBOL_SPEED_LENTO);
        }

        if (G_counter_enlentecer[x] > 0){
          G_counter_enlentecer[x]--;
          //supuesta_nueva_velocidad = ARBOL_SPEED_SLOWPORG ; /NO enlentecer por velocidad
        }

        if (G_key_pressed[x] == 1){
          //g prendido, ir restándole de a 3 
          if (G_time_to_use_again[x] > 0) G_time_to_use_again[x]-= ARBOL_COUNTER_G_RESTARLE_POR_CENTESIMA_DE_SEG;
          if (G_time_to_use_again[x] <= 0){
            G_time_to_use_again[x] = 0;
            internal_apagarVelocidad(x);
          }
        }else{
          if (G_time_to_use_again[x] <  ARBOL_COUNTER_REUSAR_G) G_time_to_use_again[x]+= 1;
        }
        rec3 = supuesta_nueva_velocidad;
        //PrintHintTextToAll("Player: %d \n G_time_to_use_again: %d \n G_key_pressed: %d", x, G_time_to_use_again[x], G_key_pressed[x] );

        if (ForzarAgache[x] == 1){
          //está haciendo barrida. considerarlo.
          if (esDefensor[x]){
            supuesta_nueva_velocidad = ARBOL_SPEED_BARRIDADEF; //EstablecerSpeed(x, ARBOL_SPEED_MAXVEL1 );
          }
          if (esMidfielder[x]){
            supuesta_nueva_velocidad = ARBOL_SPEED_BARRIDAMED; //EstablecerSpeed(x, ARBOL_SPEED_MAXVEL1 );
          }
          if (esForward[x]){
            supuesta_nueva_velocidad = ARBOL_SPEED_BARRIDA; //EstablecerSpeed(x, ARBOL_SPEED_MAXVEL1 );
          }
          if (esArquero[x]){
            supuesta_nueva_velocidad = ARBOL_SPEED_BARRIDA; //EstablecerSpeed(x, ARBOL_SPEED_MAXVEL1 );
          }


          //supuesta_nueva_velocidad = ARBOL_SPEED_BARRIDA;
        }

        if (counterEnlentecer_SALTOGK[x] > 0){
          counterEnlentecer_SALTOGK[x]--;  
          supuesta_nueva_velocidad = VELOCIDAD_LENTO_SALTOGK ; 
        }

        rec4 = supuesta_nueva_velocidad;
        if (supuesta_nueva_velocidad > speedJugadorAnterior[x]){
          supuesta_nueva_velocidad = speedJugadorAnterior[x] + INCREMENTO_VELOCIDAD_POR_CIENMILIS;
        }
        if (supuesta_nueva_velocidad != speedJugadorAnterior[x]){
          EstablecerSpeed(x, supuesta_nueva_velocidad); //si la nueva velocidad es en realidad igual a la que tenía antes, no setees nada
        }

        
        if (supuesta_nueva_velocidad == 0){
                  PrintHintText(x, "IGUAL A CERO ! \n Speed-: %d _ %d %d %d %d %d", supuesta_nueva_velocidad, rec1, rec2, rec3, rec4, G_key_pressed[x] );
        }else{
                  PrintHintText(x, "____________ ! \n Speed-: %d _ %d %d %d %d %d", supuesta_nueva_velocidad, rec1, rec2, rec3, rec4, G_key_pressed[x] );

        }





        speedJugadorAnterior[x] = speedJugadorActual[x];
}

public FuncionBARRA(x){
        if (clientBarra[x] > 0) clientBarra[x]--;
        else{
          //llego a 0 la clientBarra
          destroyBARRAahora(x);
        }
        new cl_buttons = GetClientButtons(x);
        new Float:temppp = (GetGameTime() - timeBarraCreated[x]);


        if ((cl_buttons & IN_ATTACK2) && esArquero[x] == 1 && permitidoSerArquero[x] == 1 && x != clientGRABBING && controlBTNCounter[x] == 0 ) {
          Soltar_Bola( 99 , x);
          //PrintToChatAll("despeje de arquero");
          //executeBallPush(x);
          AcceptEntityInput(Enty, "Wake");
          elTiroEsVolea = 4;//4 significa despeje de arquero pero sin agarrarla
          executeBallPush(x);
          ClientCommand( x, "play *customsounds/shot2_arb.mp3" );
          clientEjecutaPATADA[x] = 1;
          
          controlBTNCounter[x] = TIEMPO_CONTROLBTN_COUNTER;
          return;
        }
        if ( (cl_buttons & IN_ATTACK2) && controlBTNCounter[x] == 0)
        {
            //createBARRA(x);
            //el IN_ATTACK2 es 1 si el jugador está tocando click der, es 0 si no lo está, no comete errores entre medio de frames.
            if (fuerzaClick[x] == FUERZA_INICIAL_BOLA){
              createBARRA(x);
            }else{
                // sería el segundo timeclick, o el tercero...
                if ( temppp > DURACION_BARRA ){
                    //alcanzado tiempo máximo, ejecutar patada.
                    frameSkippedCounter[x] = 1;
                    controlBTNCounter[x] = TIEMPO_CONTROLBTN_COUNTER;
                }else{
                  //PrintToChatAll("NO te pasaste. %f   %f", temppp , DURACION_BARRA);
                }
            }
            frameSkippedCounter[x] = 0;
            fuerzaClick[x] += 50;



        }else{
          
          //PrintHintTextToAll("%f ; %f" , temppp, DURACION_BARRA);
          //jugador soltó click derecho o nunca lo apretó , NOTAR que fuerzaClick se usa sólo como un contador de frames... no como fuerza..
          if (fuerzaClick[x] > FUERZA_INICIAL_BOLA){

            

            frameSkippedCounter[x]++;//evita que se te desaprete click derecho por un tema de la animación (esto es bastante client-side)
            if (frameSkippedCounter[x] ==2){ //CAMBIADO DE 6 A 2, VER SI ANDA BIEN EN PC's DIFERENTES

              frameSkippedCounter[x]=0;
              fuerzaClick[x] = FUERZA_INICIAL_BOLA;
              destroyBARRAahora(x);
              Soltar_Bola(99, x);
              controlBTNCounter[x] = TIEMPO_CONTROLBTN_COUNTER;
              if (AnguloUsuarioBola[x] < 1.79 || (AnguloUsuarioBola[x] < 2.09 && BallTouchingFloor == 0) ){ //ángulo entre usuario y bola menor a 103° ; ó menor a 120 y bola aire
                
                new cabe = 0;
                new tironormal = 0;
                new esVolea = 0;

                new ejecutarAnimCabezazo = 0;

                new Float:PosBall[3];
                new Float:PosUser[3];
                GetEntPropVector(Enty, Prop_Send, "m_vecOrigin", PosBall);
                GetEntPropVector(x, Prop_Send, "m_vecOrigin", PosUser);

                //PrintToChatAll("pelota no tocando el suelo");
                new Float:difAltura=PosBall[2] - PosUser[2];
                RoundFloat(difAltura);

                if (distPlayerBall[x] < MAX_SUPUESTO_TOQUE_CLICKDER || (distPlayerBall[x] < MAX_SUPUESTO_TOQUE_CONSIDERAALTURA_CLICKDER && FloatAbs( difAltura ) > 32.0000 ) ){
                  if (clientGRABBING != -1 && esArquero[clientGRABBING] && clientGRABBING != x ){
                    //si un arquero la agarra, no se crean pushes al hacer click der.
                    return;
                  }
                  if ((AnguloUsuarioBola[x] < 2.09 && BallTouchingFloor == 0)){

                    //PrintToChat(x, "DIFALTURA %f", FloatAbs( difAltura ));
                    if (FloatAbs( difAltura ) <= 10.0000 ) {
                      //PrintToChat(x, "Es un tiro normal")
                      PrintToChatAll("Tiro normal");
                      tironormal = 1;
                    }else{
                      if (FloatAbs( difAltura ) > 52.0000 ){
                        //PrintToChat(x, "Cabezazo");
                        ballCurve[x] = 0; //no permitido curva en cabezazo ni mordido ni normal.
                        PrintToChatAll("cabezazo mordido");
                        ejecutarAnimCabezazo = 1;
                        elTiroEsVolea = 2;

                        if (!esArquero[x] || (esArquero[x] && permitidoSerArquero[x] == 0) ){
                          if (playerTouchingFloor[x] == 0){
                            elTiroEsVolea = 3;
                            ejecutarAnimCabezazo = 1;
                            cabe = 1;
                            //PrintToChat(x, "ejecuto anim cabezazo")
                            PrintToChatAll("VERDADERO CABEZAZO");
                          }
                        }
                      }
                      else{
                        PrintToChatAll( "VOLEA");
                        elTiroEsVolea = 1;
                        esVolea = 1;
                      }
                    }
                    


                  }
                  if (ejecutarAnimCabezazo){
                      Command_TestCrouch9(x, 0);
                  }
                  AcceptEntityInput(Enty, "Wake");
                  for (new jkl = 1; jkl < MAXPLAYERS; jkl++)
                  {
                    if (IsClientInGame(jkl) && IsPlayerAlive(jkl))
                    {
                      Soltar_Bola( 99 , jkl);
                      if (esArquero[jkl]){
                          prohibidoAgarrar[jkl] = TIEMPO_PATEOPELOTA_PROHIBIDO_AGARRAR_EXCEP_ARK;
                        }else{
                          prohibidoAgarrar[jkl] = TIEMPO_PATEOPELOTA_PROHIBIDO_AGARRAR; //evita que nadie la reagarre, ni siquiera el que patea..
                        }
                      rCounter[jkl] = RCOUNTER_RELOAD; //evita que nadie toque R por un momento
                      rELASTCounter[jkl] = RELASTCOUNTER_RELOAD; //evita que nadie toque RELAST por un momento
                    }
                  }
                  
                  //TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, NULL_VELOCITY);
                  if (esArquero[x] && permitidoSerArquero[x]){
                    //PrintToChatAll("Arquero despeje agarrAndola")
                    executeBallPushSOLOARQUERO(x);
                  }
                  else{
                    executeBallPush(x);
                  }
                    
                  if ( cabe == 0 && elTiroEsVolea != 2 && ejecutarAnimCabezazo==0){
                    //es decir, si es volea o tiro normal
                    Command_TestCrouch6(x, 0);
                    //PrintToChat(x, "Ejecuto anim patada normal.")
                  }
                  ClientCommand( x, "play *customsounds/shot2_arb.mp3" );
                  clientEjecutaPATADA[x] = 1;
                  Soltar_Bola( 99 , x);

                  if (ballCurve[x] != 0 && (distPlayerBall[x] < RADIO_CURVA_PERMITIDO) ) {
                    GetClientEyeAngles(x, OriginalAngShooter);
                    numCurvaIter = 0;
                    clientQueLaCurvo = x;
                    CurvaQueLeDio = ballCurve[x];
                    ballCurve[x] = 0;
                    //PrintToChatAll("Eye angle:      %f     %f     %f", OriginalAngShooter[0], OriginalAngShooter[1], OriginalAngShooter[2] );
                    CreateTimer(0.10, pushBallIteratively, _, TIMER_REPEAT);
                  }
                }
                
              }else{
                numCurvaIter = 99;
                PrintToChat(x, "You are not facing the ball to shoot !");
              }
            }
            
          }
        }
}


public FuncionControles(x){ //también cálculo de tipo de movimiento actual.

    new movimientoTEMP = 0;
    new tempHaciendoDiagonal = 0;
    new iButtons;
    new client;

    iButtons = GetClientButtons(x);
    client = x;
    

    new Float:PosBall[3];
    new Float:PosUser[3];
    GetEntPropVector(Enty, Prop_Send, "m_vecOrigin", PosBall);
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);
    distPlayerBall[x] = GetVectorDistance(PosBall, PosUser);
    
    if (client > 0) 
	{

            // Is he pressing "w"?
            if(iButtons & IN_FORWARD)
			{
                //Format(sOutput, sizeof(sOutput), "     W     ");
                movimientoTEMP = 1;
                tempHaciendoDiagonal ++;
                moviendoHaciaAdelante[x] = 1;
            }
            else{
                moviendoHaciaAdelante[x] = 0;
            }

            // Is he pressing "space"? SE MANEJA DE OTRO LADO , COMO EL G
            // if(iButtons & IN_JUMP){
            //     //Format(sOutput, sizeof(sOutput), "%s     JUMP\n", sOutput);
            //     basura = 0;
            //     Soltar_Bola(3);
            // }
            // else{
            //     basura = 0;
            // }

            // Is he pressing "a"?
            if(iButtons & IN_MOVELEFT){
                //Format(sOutput, sizeof(sOutput), "%s  A", sOutput);
                movimientoTEMP = 1;
                tempHaciendoDiagonal ++;
                apretaIZQ[x] = 1;
            }
            else{
                apretaIZQ[x] = 0;
            }

            // Is he pressing "s"?


            // Is he pressing "d"?
            if(iButtons & IN_MOVERIGHT){
                //Format(sOutput, sizeof(sOutput), "%s  D", sOutput);
                movimientoTEMP = 1;
                tempHaciendoDiagonal ++;
                apretaDER[x] = 1;
            }
            else{
                apretaDER[x] = 0;
            }

            if(iButtons & IN_BACK){
                //Format(sOutput, sizeof(sOutput), "%s  S", sOutput);
                movimientoTEMP = 3;
                tempHaciendoDiagonal = 0;
                moviendoHaciaAtras[x] = 1;
            }
            else{
                moviendoHaciaAtras[x] = 0;
            }

            // Is he pressing "CLICK1"?
            if(iButtons & IN_ATTACK){
              ActionClickButton(client);
            }

            // Is he pressing "ctrl"?
            if(iButtons & IN_DUCK){
                frameSkippedCounter[x]=0;
                fuerzaClick[x] = FUERZA_INICIAL_BOLA;
                destroyBARRAahora(client);
                controlBTNCounter[x] = TIEMPO_CONTROLBTN_COUNTER;
            }
            // Is he pressing "ctrl"?
            // if(iButtons & IN_DUCK)
            //     //Format(sOutput, sizeof(sOutput), "%s       DUCK\n", sOutput);
            // else
            //     Format(sOutput, sizeof(sOutput), "%s       _   \n", sOutput);

            // Is he pressing "shift"?
            if(iButtons & IN_SPEED){
                if ( (latencia_en_shift[x] == 0) || (latencia_en_shift[x] == LATENCIA_MAX_SHIFT - 1) ) {
                  //Format(sOutput, sizeof(sOutput), "%sWALK", sOutput);
                  movimientoTEMP = 0;
                  latencia_en_shift[x] = LATENCIA_MAX_SHIFT;
                }
            }
            else{
                //.....
            }

            if ( (iButtons & IN_RELOAD ) )
            {
              if (iButtons & IN_RELOAD && iButtons & IN_DUCK && latencia_DUCK[x] == 0){
                latencia_DUCK[x] = COUNTER_HACER_BARRIDA ; 
                Command_barrida(client);
              }
              if ( latencia_en_shift[x] ==  LATENCIA_MAX_SHIFT  && rCounter[x] == 0 && ForzarAgache[x] == 0){
                //PrintToChatAll("SOCCERMODPRO. apretado R");
                Command_attractBall(client, 0);
                rCounter[x] = RCOUNTER_RELOAD;
              }else{
                if ( rELASTCounter[x] == 0  && latencia_en_shift[x] !=  LATENCIA_MAX_SHIFT && ForzarAgache[x] == 0 ){
                  //Command_attractBallRaise(client, 0);
                  //REVISAME ACÁ PARA MODO AMAGUE
                  if ( clientEnModoAmague[client] == 1 ){
                    PrintHintText(client, "Elastica (estAs en modo amague)");
                    Command_attractBallRaise(client, 0);
                  }else{
                      PrintHintText(client, "Solo podes elAstica en modo amague");
                  }
                  rELASTCounter[x] = RELASTCOUNTER_RELOAD;
                }
              }
              
            }

            if( (iButtons & IN_USE) ){
              //PrintHintText(client, "EE apretado");
              clientEnModoAmague[client] = 1;
              if (clientGRABBING == client) Soltar_Bola(99,client);
            }else{
              //PrintHintText(client, "EE noapretado");
              clientEnModoAmague[client] = 0;
            }
            // Is he pressing "e"?
            IntentarAgarrarla(client);

            


            // if( (iButtons & IN_USE) ){
            //    // if (distPlayerBall> RADIUS_GRABE){
            //       //no estás cerca de la bola, ni siquiera la agarres.
            //     //}
            //     //else{
            //       //Format(sOutput, sizeof(sOutput), "%s    USE", sOutput);
            //     if (latencia_en_uso[x] == 0){
            //       latencia_en_uso[x] = LATENCIA_MAX_INUSE;
            //       IntentarAgarrarla(client);
            //     }
                    

                
            //     //  }
            //     //}


            // }
            // else{
            //   //.....
            // }
            
    }

    if (latencia_en_shift[x] == LATENCIA_MAX_SHIFT){
      //está apretando shift.
      if (apretaIZQ[x] == 1){
        //SHIFT A
        if (ballCurve[x] != 1)
          Command_BallToLeft(client, 0);
      }
      else if (apretaDER[x] == 1){
        //SHIFT D
        if (ballCurve[x] != 2)
          Command_BallToRight(client, 0);
      }
    }

    if ( latencia_en_shift[x] ==  LATENCIA_MAX_SHIFT  && rCounter[x] == 0 && rELASTCounter[x] == 0){
      Command_stopBall(client, 0);
    }

    if (G_key_pressed[x] == 1 && movimientoTEMP == 1){
        movimientoTEMP = 2;
    }
    if (tempHaciendoDiagonal > 1 || ( !(iButtons & IN_FORWARD) && tempHaciendoDiagonal>0 )  ) {
      movimientoTEMP = 4; //diagonal
    }
    //PrintHintTextToAll("mov: %d" , movimientoTEMP );
    tipoMovActual[x] = movimientoTEMP;

    if (tipoMovActual[x] == 0){
      //quieto: poner variables de quieto
      VARIABLE_DISTANCE_BETWEEN_PLAYER_AND_BALL[x] = DISTANCE_BETWEEN_PLAYER_AND_BALL_STILL;
      VARIABLE_ATTRACTBALL_MULTIPLIER[x] = ATTRACTBALL_MULTIPLIER_STILL;
      VARIABLE_BALL_HOLD_HEIGHT[x] = BALL_HOLD_HEIGHT_STILL;
    }
    if (tipoMovActual[x] == 1){
      //WASD: poner variables de WASD
      VARIABLE_DISTANCE_BETWEEN_PLAYER_AND_BALL[x] = DISTANCE_BETWEEN_PLAYER_AND_BALL_WASD;
      VARIABLE_ATTRACTBALL_MULTIPLIER[x] = ATTRACTBALL_MULTIPLIER_WASD;
      VARIABLE_BALL_HOLD_HEIGHT[x] = BALL_HOLD_HEIGHT_WASD;
    }
    if (tipoMovActual[x] == 2){
      //MAXWASD: poner variables de MAXWASD
      VARIABLE_DISTANCE_BETWEEN_PLAYER_AND_BALL[x] = DISTANCE_BETWEEN_PLAYER_AND_BALL_MAXWASD;
      VARIABLE_ATTRACTBALL_MULTIPLIER[x] = ATTRACTBALL_MULTIPLIER_MAXWASD;
      VARIABLE_BALL_HOLD_HEIGHT[x] = BALL_HOLD_HEIGHT_MAXWASD;
    }

    if (tipoMovActual[x] == 3){
      //ATRASWASD: poner variables de ATRASWASD
      internal_terminarBarrida(x); //si camina para atrás no puede hacer barrida.
      VARIABLE_DISTANCE_BETWEEN_PLAYER_AND_BALL[x] = DISTANCE_BETWEEN_PLAYER_AND_BALL_ATRASWASD;
      VARIABLE_ATTRACTBALL_MULTIPLIER[x] = ATTRACTBALL_MULTIPLIER_ATRASWASD;
      VARIABLE_BALL_HOLD_HEIGHT[x] = BALL_HOLD_HEIGHT_ATRASWASD;
    }
    if (tipoMovActual[x] == 4){
      //DIAGONALWASD: poner variables de DIAGONALWASD
      VARIABLE_DISTANCE_BETWEEN_PLAYER_AND_BALL[x] = DISTANCE_BETWEEN_PLAYER_AND_BALL_DIAGONALWASD;
      VARIABLE_ATTRACTBALL_MULTIPLIER[x] = ATTRACTBALL_MULTIPLIER_DIAGONALWASD;
      VARIABLE_BALL_HOLD_HEIGHT[x] = BALL_HOLD_HEIGHT_DIAGONALWASD;
    }
}


public FuncionIEEE(client){ //cálculo de ángulo del jugador y pelota, y maneja agarre E
    //new client;
    new Float:PosBall[3];
    new Float:PosUser[3];
    new Float:VectorDifference[3];
    GetEntPropVector(Enty, Prop_Send, "m_vecOrigin", PosBall);
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);

    //PrintHintTextToAll("distance %f" , distPlayerBall); //45.0 es más o menos "cerca/tocando el jugador"
    //return Plugin_Handled;
    if (ForzarAgache[client] == 1 && clientGRABBING != -1){
      if (clientGRABBING == client){
        //soy el que tiene la bola y estoy haciendo la barrida.
        Soltar_Bola(91, clientGRABBING);
      }
      else{
        //soy el jugador que barre, pero no tengo la pelota conducida.
        if (distPlayerBall[client] < RANGO_BARRIDA && (!esArquero[clientGRABBING] || (esArquero[clientGRABBING] && permitidoSerArquero[clientGRABBING] == 0))){
          //estoy barriendo,alguien la tiene agarrada , está cerca: sacarle la bola a quien la tenga agarrada.
          new String:bufn[256];
          GetClientName(client, bufn, sizeof(bufn) );
          new String:bufn2[256];
          GetClientName(clientGRABBING, bufn2, sizeof(bufn2) );
          PrintToChatAll("Player %s slide-tackles %s" , bufn, bufn2);
          new Float:PosAgarrador[3];
          new Float:VectorClientEnemigo[3];
          new viejoClientGrabeado = clientGRABBING;
          GetEntPropVector(clientGRABBING, Prop_Send, "m_vecOrigin", PosAgarrador);
          VectorClientEnemigo[0] = PosUser[0] - PosAgarrador[0];
          VectorClientEnemigo[1] = PosUser[1] - PosAgarrador[1];
          VectorClientEnemigo[2] = PosUser[2] - PosAgarrador[2];
          new Float:longitudVectorPersonaEnemigo = GetVectorLength(VectorClientEnemigo);

          Soltar_Bola(89, clientGRABBING);

          if (longitudVectorPersonaEnemigo < RADIUS_DANHAR_POR_BARRIDA_A_JUGADOR){
                      new int:dmgt = (1 << 1);
                      doDmg(viejoClientGrabeado, 100, 0, dmgt, "ak47"); //esto creo que debería estar afuera del if, dañando todo enemigo
          }
        }
      }

    }

    if (CounterSoltar[client] > 6 && distPlayerBall[client]> 47.0){
        Soltar_Bola(2, client);
        return;
    }
    new NUM_TEMP = 1;
    if (distPlayerBall[client] < 45.0 && tipoMovActual[client] == 2){
        NUM_TEMP = 7;
    }

    //if (tipoMovActual[client] == 1 || tipoMovActual[client] == 4){//CAMBIO VELOCIDAD NORMAL POR VELOCIDAD RÁPIDA
    
    if (distPlayerBall[client] < 45.0 && tipoMovActual[client] == 1){
        //NUM_TEMP = 2;
        //PrintToChat(client, "push away ball.");
    }
    

    
    //PrintHintTextToAll("tempDistBallPlayer: %f  " , tempDistBallPlayer);
    
    //PrintToChat(client, "SOCCERMODPRO. Ball attracted  0.");
    new Float:destOrigin[3];
    decl Float:clientOrigin[3];
    decl Float:clientEyeAngles[3];
    GetClientAbsOrigin(client, clientOrigin);
    GetClientEyeAngles(client, clientEyeAngles);
    new Float:cos = Cosine(DegToRad(clientEyeAngles[1]));
    new Float:sin = Sine(DegToRad(clientEyeAngles[1]));

    destOrigin[0] = clientOrigin[0] + cos * (VARIABLE_DISTANCE_BETWEEN_PLAYER_AND_BALL[client] );
    destOrigin[1] = clientOrigin[1] + sin * (VARIABLE_DISTANCE_BETWEEN_PLAYER_AND_BALL[client] );
    destOrigin[2] = clientOrigin[2] + VARIABLE_BALL_HOLD_HEIGHT[client] ;

    //PrintToChat(client, "SOCCERMODPRO. Ball attracted  1.");
    //TeleportEntity(enty, orig_ball, NULL_VECTOR, NULL_VECTOR); 
    //TeleportEntity(enty, destOrigin, clientEyeAngles, NULL_VECTOR); //changed.
    ///

    //TeleportEntity(Enty, destOrigin, NULL_VECTOR, NULL_VECTOR); //NO CONVIENE PORQUE GENERA BUGS
    VectorDifference[0] = (destOrigin[0] - PosBall[0]) ;
    VectorDifference[1] = (destOrigin[1] - PosBall[1]) ;
    VectorDifference[2] = (destOrigin[2] - PosBall[2]) ;

    new Float:LongPelotaObjetivo = GetVectorLength(VectorDifference); //longitud de la pelota a donde debería estar

    new Float:VectorPersonaPelota[3];
    VectorPersonaPelota[0] = PosBall[0] - clientOrigin[0];
    VectorPersonaPelota[1] = PosBall[1] - clientOrigin[1];
    VectorPersonaPelota[2] = PosBall[2] - clientOrigin[2];
    new Float:longitudVectorPersonaPelota = GetVectorLength(VectorPersonaPelota);

    VectorPersonaPelota[0] /= longitudVectorPersonaPelota;
    VectorPersonaPelota[1] /= longitudVectorPersonaPelota;
    VectorPersonaPelota[2] /= longitudVectorPersonaPelota;

    //-----------------------------
    //ÁNGULO ENTRE PERSONA Y PELOTA
    //-----------------------------
    new Float:Angulos[3];
    GetAngleVectors(clientEyeAngles, Angulos, NULL_VECTOR, NULL_VECTOR);
    new Float:DOSDAngles[3];
    DOSDAngles[0] = Angulos[0];
    DOSDAngles[1] = Angulos[1];
    DOSDAngles[2] = 0.0;
    new Float:DOSDPosPelota[3];
    DOSDPosPelota[0] = VectorPersonaPelota[0];
    DOSDPosPelota[1] = VectorPersonaPelota[1];
    DOSDPosPelota[2] = 0.0;
    NormalizeVector(DOSDAngles, DOSDAngles);
    NormalizeVector(DOSDPosPelota, DOSDPosPelota);

    //ángulo? hago el dot product y eso me DEVUELVE el coseno del ángulo
    new Float:tempnumero = DOSDAngles[0] *  DOSDPosPelota[0] + DOSDAngles[1] * DOSDPosPelota[1]; //tempnumero = coseno(ángulo entre ambos)
    new Float:ELANGULO = ArcCosine(tempnumero);
    AnguloUsuarioBola[client] = ELANGULO;

    //FIN CÁLCULOS DE SUMA IMPORTANCIA PARA TODO EL MOD.
    
    //--------------------------
    //--------------------------
    //--------------------------
    //LO REMUEVO PARA EVITAR QUE NOOBS SE HAGAN PERDER LA BOLA POR NO ROTAR...
    //CHEQUEAR POSIBILIDAD DE BUG DE QUE TE AUTOEMPUJA LA BOLA
    // if (ELANGULO > 2.79 && tipoMovActual[client] == 1) {
    //   //si estás en normal y ang mayor a 160 , perdés la pelota
    //   //PrintToChat(client, "You lost the ball.");
    //   Soltar_Bola(99, client);
    //   grabbingBall[client] = 0;
    //   ballAgarrable = 1;
    // }

    if (tipoMovActual[client] == 1){//CAMBIO VELOCIDAD NORMAL POR VELOCIDAD RÁPIDA
      tipoMovActual[client] = 2;
    }

    grabbingBall[client] = 1;
    if (debeSoltarBola[client] > 0){
        //PrintToChatAll("arbolEEE: stop grab ball.");
        grabbingBall[client] = 0;
        ballAgarrable = 1;
        return;
    }

    //PrintHintTextToAll("%f %f \n%f %f \n   %f" , DOSDAngles[0], DOSDAngles[1], DOSDPosPelota[0], DOSDPosPelota[1] , ELANGULO);
    //PrintHintTextToAll("distPlayerBall: %f" , distPlayerBall );
    //return Plugin_Continue;



    // //new Float:AngEntrePersonaYPelota = 180.0 - (((VectorPersonaPelota[0] * -1.0)+1.0) * 90) ; SERÍA EL MÁS REALÍSTICO PERO NO CONCUERDA CON EYEANGLE
    // new Float:TEMPVectorPersonaPelota = (((VectorPersonaPelota[0] * -1.0)+1.0) * 90) ;
    // new SignoAngEntrePersonaYPelota = 0;
    // if (VectorPersonaPelota[1] < 0.0) SignoAngEntrePersonaYPelota = -1;
    // else SignoAngEntrePersonaYPelota = 1;
    // //PrintHintTextToAll("EyeAngle: %f \n VecDifPersPel: %f     %f   %f" , clientEyeAngles[1], VectorPersonaPelota[0], VectorPersonaPelota[1], VectorPersonaPelota[2]);
    // new Float:AngPersPelota = FloatAbs(FloatAbs(TEMPVectorPersonaPelota) - FloatAbs(clientEyeAngles[1]));

    // //PrintHintTextToAll("EyeAngle: %f \n Ang: %f     Sgn: %d" , clientEyeAngles[1], TEMPVectorPersonaPelota, SignoAngEntrePersonaYPelota);
    // PrintHintTextToAll("Ang: %f \n %f" , AngPersPelota , VectorPersonaPelota[0] );
    //return Plugin_Continue;

    if (ELANGULO > 1.04 && tipoMovActual[client] == 2) {
      //si estás en velocidad y ang mayor a 60° , te volvés lento y empujás la pelota
      
      if (G_internalcounter[client] > 5) NUM_TEMP = 3;
      contadorLento[client] = RoundFloat(TIEMPO_ESTAR_LENTO_VELOCIDAD * ELANGULO * 2.65 ); //más ángulo, más tiempo lento
      //PrintHintText(client, "-grab slow-");
    }





    

    if ( (ELANGULO > 1.32 && tipoMovActual[client] == 0) || (ELANGULO > 0.80 && tipoMovActual[client] == 1) || (ELANGULO > 1.32 && tipoMovActual[client] == 4)  ){ //83 ° aprox.
      CounterSoltar[client] ++;
      clientEstaWarpeado[client] = TIEMPO_ESTAR_WARPEADO_POR_IR_ATRAS ;
      ballAgarrable = 1;
      new Float:promediando[3];
      //PrintHintText(client, "EstAs perdiendo la bola");
      Command_attractBall(client, 0);
      AddVectors(OLD6VectorDifference, OLD5VectorDifference, promediando);
      AddVectors(OLD4VectorDifference, promediando, promediando);
      AddVectors(OLD3VectorDifference, promediando, promediando);
      //AddVectors(OLD2VectorDifference, promediando, promediando);
      //AddVectors(OLDVectorDifference, promediando, promediando);

      ScaleVector(promediando, 0.25);

      //if (CounterSoltar<2) TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, OLD6VectorDifference);
      if (CounterSoltar[client]==1) TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, OLD6VectorDifference); //una sola vez
      //PrintHintText(client, "YOU LOST THE BALL, GO CLOSE TO GRAB IT AGAIN %d" , CounterSoltar[client] );
      return;
    }else{
      if (CounterSoltar[client] > 2){
        acabaDeSalir[client] = 1;
        //PrintHintText(client, "YOU GOT THE BALL AGAIN %d" , CounterSoltar[client] );
      }
      CounterSoltar[client] = 0;
    }
    if (CounterSoltar[client] > 0){
      ballAgarrable = 1
    }
    new Float:longitud = GetVectorLength(VectorDifference);

    VectorDifference[0] /= longitud;
    VectorDifference[1] /= longitud;
    VectorDifference[2] /= longitud;


    VectorDifference[0] *= VARIABLE_ATTRACTBALL_MULTIPLIER[client] * NUM_TEMP;
    VectorDifference[1] *= VARIABLE_ATTRACTBALL_MULTIPLIER[client] * NUM_TEMP;
    VectorDifference[2] *= VARIABLE_ATTRACTBALL_MULTIPLIER[client] * NUM_TEMP;

    OLD6VectorDifference[0] = OLD5VectorDifference[0];
    OLD6VectorDifference[1] = OLD5VectorDifference[1];
    OLD6VectorDifference[2] = OLD5VectorDifference[2];

    OLD5VectorDifference[0] = OLD4VectorDifference[0];
    OLD5VectorDifference[1] = OLD4VectorDifference[1];
    OLD5VectorDifference[2] = OLD4VectorDifference[2];

    OLD4VectorDifference[0] = OLD3VectorDifference[0];
    OLD4VectorDifference[1] = OLD3VectorDifference[1];
    OLD4VectorDifference[2] = OLD3VectorDifference[2];

    OLD3VectorDifference[0] = OLD2VectorDifference[0];
    OLD3VectorDifference[1] = OLD2VectorDifference[1];
    OLD3VectorDifference[2] = OLD2VectorDifference[2];

    OLD2VectorDifference[0] = OLDVectorDifference[0];
    OLD2VectorDifference[1] = OLDVectorDifference[1];
    OLD2VectorDifference[2] = OLDVectorDifference[2];

    OLDVectorDifference[0] = VectorDifference[0];
    OLDVectorDifference[1] = VectorDifference[1];
    OLDVectorDifference[2] = VectorDifference[2];

    ScaleVector(OLDVectorDifference, 1.2);
    //PrintHintTextToAll("VectorDifference: %f  %f  %f" , VectorDifference[0], VectorDifference[1], VectorDifference[2]);

    if(tipoMovActual[client] == 1 || tipoMovActual[client] == 4){
      //WASD ó DIAGONALWASD , si distPlayerBall es < 60 y recién salió
      if(distPlayerBall[client] > 266.0){
              //demasiado lejos para todos los estándares
              Soltar_Bola(1, client);
              ballAgarrable = 1;
              return;
      }
      if(distPlayerBall[client] > 70.0 ){
          clientEstaWarpeado[client] = TIEMPO_ESTAR_WARPEADO_POR_IR_COSTADO ;
          //internal_apagarVelocidad(client);
          //Command_attractBall(client,0);
          //PrintHintTextToAll("Costado. \n Distancia del cliente a la pelota: %f" , distPlayerBall[client] );
      }
      if ((distPlayerBall[client] < 80.0 && acabaDeSalir[client] == 1) || (CounterSoltar[client] == 0 && acabaDeSalir[client] == 0)  ){
        //PrintHintText(client, "grab -" );
        TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, VectorDifference);
        ballAgarrable = 0;
        acabaDeSalir[client] = 0;
        CounterSoltar[client] = 0;
      }
    }
    if (tipoMovActual[client] == 0){
      //STILL

      if(distPlayerBall[client] > 160.0){
              //demasiado lejos para todos los estándares
              Soltar_Bola(1, client);
              ballAgarrable = 1;
              return;
      }
      //PrintHintText(client, "grab ; dist: %f" , LongPelotaObjetivo );
      if (LongPelotaObjetivo < 8.0){
        if (LongPelotaObjetivo < 7.6){
          //dormir la bola de alguna forma
          //AcceptEntityInput(Enty, "Disable");
          //AcceptEntityInput(Enty, "DisableMotion");
          TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, NULL_VELOCITY);
          TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, NULL_VELOCITY);
          ballAgarrable = 0;
          AcceptEntityInput(Enty, "Sleep");
          //PrintHintText(client, "grab dormido" );
        }else{
          TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, NULL_VELOCITY);
          ballAgarrable = 0;
        }
      }
      else{
        TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, VectorDifference);
        ballAgarrable = 0;
      }
    }
    if (tipoMovActual[client] == 2){
      //MAXWASD
      if(distPlayerBall[client] > 300.0){
                    //demasiado lejos para todos los estándares
                    Soltar_Bola(1, client);
                    ballAgarrable = 1;
                    return;
      }
      if(distPlayerBall[client] > 55.0 && clientTieneBarra[client] == 1 && clientGRABBING == client){
          //clientEstaWarpeado[client] = TIEMPO_ESTAR_WARPEADO_POR_PEGANDO_A_BOLA ;
          //client tiene barra, está conduciendo, está en velocidad, está pateando la bola
          internal_atraerBolaANTIGBUG(client);
          PrintToChatAll("v2: antibug G PATEAR CONDUCIENDO" );
          return;
      }
      //PrintHintText(client, "grab mv" );
      TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, VectorDifference);  
      ballAgarrable = 0;
    }

    if (tipoMovActual[client] == 3){
            //ATRASWASD
            if(distPlayerBall[client] > 65.0){
                    //muy lejos, warpear al tipo
                    //PrintHintTextToAll("warpeo al cliente   %d   por ir para atrAs" , client);
                    //Command_attractBall(client,0);
                    clientEstaWarpeado[client] = TIEMPO_ESTAR_WARPEADO_POR_IR_ATRAS ;
                    //return;
            }
            if(distPlayerBall[client] > 70.0){
                    //muy lejos, ya warpearon al tipo, pero además atraer a la bola
                    Command_attractBall(client,0);
                    //PrintHintText(client, "attractBall para no perder la bola" );
                    //return;
            }
            if(distPlayerBall[client] > 80.0){
                    //demasiado lejos para todos los estándares
                    Soltar_Bola(1, client);
                    ballAgarrable = 1;
                    return;
            }
            //PrintHintText(client, "grab" );
            TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, VectorDifference);  
            ballAgarrable = 0;
    }

}


public FuncionSLOWBALL(){ //rebote pelota, etc. NO requiere client.
    timeOnAir +=15;
    if (cancelarPorJugador > 0 ) cancelarPorJugador--;
    GetEntPropVector(Enty, Prop_Send, "m_vecOrigin", ballPos);
    if (ballPos[2] > maxBallPosAlcanzado) maxBallPosAlcanzado = ballPos[2];
    if (timeOnAir > 250 && maxBallPosAlcanzado > 250.0 && timeOnAir > maxBallPosAlcanzado){
                    maxBallPosAlcanzado = 0.0;
                    timeOnAir = 0;
    }
}

public FuncionSTATS1(x){ //te dice quién tocó qué y en base a eso va actualizando una matriz.
  if (goalScored==1) return;
  if ( (!IsClientInGame(x)) || (!IsPlayerAlive(x)) )
          return;
  if (clientEjecutaAttack[x] || clientEjecutaPATADA[x] || clientApretaR[x] || clientApretaRELAST[x] || clientApretaSTOP[x] || clientLaAgarra[x] || clientLaQuita[x]){
    //PrintHintTextToAll("Este jugador la estA agarrando");
    cancelarPorJugador = 1;//cancela que rebote mucho en el suelo.
    if (x != clientQueLaCurvo) numCurvaIter = 99;
    Accum_PUNTOS[x]++;
    
    //analizo si existe un "QUITE"
    //definición de quite: la tenía el rival, ahora la tenés vos.
    if (historia_jugadas[0] != 0 && (IsClientInGame(historia_jugadas[0])) && IsPlayerAlive(historia_jugadas[0])     ){
      if (GetClientTeam(historia_jugadas[0] ) != GetClientTeam(x) ){
        //PrintToChatAll("Detectado quite para %d", x);
        clientLaQuita[x]++;
        Accum_PUNTOS[x]++;
      }
    }
    

    //actualizo matriz.
    historia_jugadas[5] = historia_jugadas[4];
    historia_jugadas[4] = historia_jugadas[3];
    historia_jugadas[3] = historia_jugadas[2];
    historia_jugadas[2] = historia_jugadas[1];
    historia_jugadas[1] = historia_jugadas[0];
    historia_jugadas[0] = x ;


    if (clientLaAgarra[x] && esArquero[x]){
      //la agarrO y es arquero. contEmosle como doble acciOn sobre la bola para evitar bug arquero en contra.
      historia_jugadas[5] = historia_jugadas[4];
      historia_jugadas[4] = historia_jugadas[3];
      historia_jugadas[3] = historia_jugadas[2];
      historia_jugadas[2] = historia_jugadas[1];
      historia_jugadas[1] = historia_jugadas[0];
      historia_jugadas[0] = x ;
    }

    if (clientLaQuita[x]){
      if (esArquero[x] && permitidoSerArquero[x]){
        clienteAtajadasTotales[x]++;
        Accum_PUNTOS[x]++;
        new String:bufn[256];
        GetClientName(x, bufn, sizeof(bufn) );
        PrintToChatAll("GK %s saves the ball." , bufn);
        }
      else{
        clienteQuitesTotales[x]++;
        Accum_PUNTOS[x]++;
        new String:bufn[256];
        GetClientName(x, bufn, sizeof(bufn) );
        PrintToChatAll("Player %s saves the ball." , bufn);
      }
    }
    CS_SetClientContributionScore(x, Accum_PUNTOS[x]);
  }
  else{
    //PrintHintTextToAll("NO LA AGARRA %d" , temporal123);
  }

  clientEjecutaAttack[x] = 0;
  clientEjecutaPATADA[x] = 0;
  clientApretaR[x] = 0;
  clientApretaRELAST[x] = 0;
  clientApretaSTOP[x] = 0;
  clientLaQuita[x] = 0;
  clientLaAgarra[x] = 0;

  //PrintHintTextToAll("%d %d %d %d %d %d ", historia_jugadas[0], historia_jugadas[1], historia_jugadas[2], historia_jugadas[3], historia_jugadas[4], historia_jugadas[5]);
}


public FindBola(){
    new index = -1;
    while ((index = FindEntityByClassname(index, "prop_physics")) != -1)
    {
          decl String:strName[50];
          GetEntPropString(index, Prop_Data, "m_iName", strName, sizeof(strName));

          if(strcmp(strName, "pelota0") == 0)
          {
               // found
               Enty = index;
               GetEntPropString(Enty, Prop_Data, "m_ModelName", physball_model_name, 128);
               PrecacheModel(physball_model_name, true);
               GetEntPropVector(index, Prop_Send, "m_vecOrigin", PosicBallInit);
               canchaZ = PosicBallInit[2];
               break;
          }
    }
    FindBallRound = 0;
}

public OnMapStart(){
    determinarTipoMapa();
    PrecacheModel("models/props/cs_office/vending_machine.mdl", true); //REEMPLAZAR CON UN dummy_cube_model
    FindBola();
    //poniendoIMGLOGO = 160;
    new index = -1;
    new ContadorEvitaCrash = 0;
    while ((index = FindEntityByClassname(index, "info_target")) != -1)
    {
          ContadorEvitaCrash++;
          decl String:strName[50];
          GetEntPropString(index, Prop_Data, "m_iName", strName, sizeof(strName));

          if(strcmp(strName, "midarcott") == 0)
          {
               // found
               PrintToChatAll("found mid.");
               GetEntPropVector(index, Prop_Send, "m_vecOrigin", PosMidArcoTT);
               //PrintToChatAll("%f %f", PosMidArcoTT[2], PosBallInicial[2]);
               PosMidArcoTT[2] = canchaZ;
               //break;
          }
          if(strcmp(strName, "leftarcott") == 0)
          {
               // found
               PrintToChatAll("found left.");
               GetEntPropVector(index, Prop_Send, "m_vecOrigin", PosLeftArcoTT);
               //PrintToChatAll("%f %f", PosLeftArcoTT[2], PosBallInicial[2]);
               PosLeftArcoTT[2] = canchaZ;
               //break;
          }
          if(strcmp(strName, "rightarcott") == 0)
          {
               // found
               PrintToChatAll("found right.");
               GetEntPropVector(index, Prop_Send, "m_vecOrigin", PosRightArcoTT);
               //PrintToChatAll("%f %f", PosRightArcoTT[2], PosBallInicial[2]);
               PosRightArcoTT[2] = canchaZ;
               //break;
          }


          if(strcmp(strName, "midarcoct") == 0)
          {
               // found
               PrintToChatAll("found mid.");
               GetEntPropVector(index, Prop_Send, "m_vecOrigin", PosMidArcoCT);
               //PrintToChatAll("%f %f", PosMidArcoTT[2], PosBallInicial[2]);
               PosMidArcoCT[2] = canchaZ;
               //break;
          }
          if(strcmp(strName, "leftarcoct") == 0)
          {
               // found
               PrintToChatAll("found left.");
               GetEntPropVector(index, Prop_Send, "m_vecOrigin", PosLeftArcoCT);
               //PrintToChatAll("%f %f", PosLeftArcoTT[2], PosBallInicial[2]);
               PosLeftArcoCT[2] = canchaZ;
               //break;
          }
          if(strcmp(strName, "rightarcoct") == 0)
          {
               // found
               PrintToChatAll("found right.");
               GetEntPropVector(index, Prop_Send, "m_vecOrigin", PosRightArcoCT);
               //PrintToChatAll("%f %f", PosRightArcoTT[2], PosBallInicial[2]);
               PosRightArcoCT[2] = canchaZ;
               //break;
          }

          if (ContadorEvitaCrash> 5000){
            break;
          }
    }
    //AddFileToDownloadsTable( FULL_SOUND_PATH );
    //FakePrecacheSound( RELATIVE_SOUND_PATH );
    PrecacheModel(MODELO_JUGCT, true);
    PrecacheModel(MODELO_JUGTT, true);
    g_iWorldModel = PrecacheModel("models/weapons/w_fire_rapier_arb.mdl", true);
    //PrintToChatAll("arbolEEE: found ball.");
    g_strStat = CreateConVar("smp_golstr", "0");
    for (new i = 0; i< MAXPLAYERS; i++){
      jugadorPreparado[i] = 0;
      acumularKicks[i] = 0;
      mostradoAdvertencia[i] = 0;
    }
    resetStatsToZero();
    removerBotMSG = CreateConVar("smp_removttbot", "0");
    ganoAntesCT = 0;
    ganoAntesTT = 0;
    UnlockConsoleCommandAndConvar("r_screenoverlay");
    PrepareOverlays();

}

public determinarTipoMapa(){
      PrintToChatAll("Determinando...");

      new String:file_to_read[32];
      decl String:path[PLATFORM_MAX_PATH],String:line[128];

      new a = 0;
      file_to_read = "/configs/smp_primermodelo.txt";
      BuildPath(Path_SM,path,PLATFORM_MAX_PATH, file_to_read);
      new Handle:fileHandle=OpenFile(path,"r"); // Opens addons/sourcemod/smp_maps.txt to read from (and only reading)
      while(!IsEndOfFile(fileHandle)&&ReadFileLine(fileHandle,line,sizeof(line)))
      {
        TrimString(line);
        PrintToChatAll("line %s",line);
        //MODELO_JUGTT = line;
        if (a == 0){
          strcopy(MODELO_JUGTT, sizeof(MODELO_JUGTT), line);  
        }
        if (a == 1){
          strcopy(MODELO_JUGCT, sizeof(MODELO_JUGCT), line);
          break;
        }
        a++;
      }
}

// stock FakePrecacheSound( const String:szPath[] )
// {
//   AddToStringTable( FindStringTable( "soundprecache" ), szPath );
// }

public ActionClickButton(client){
  
  if (client == clientGRABBING){
                Soltar_Bola(92, client);
                frameSkippedCounter[client]=0;
                fuerzaClick[client] = FUERZA_INICIAL_BOLA;

  }
  else{
    //client no es clientGRABBING ; robásela
    if (distPlayerBall[client] < RADIUS_ATTACK_CLICK && clientGRABBING != -1 && (!esArquero[clientGRABBING] || (esArquero[clientGRABBING] && permitidoSerArquero[clientGRABBING] == 0))  ){
      //se la tengo que robar, el otro pierde el control
      new String:bufn[256];
      GetClientName(client, bufn, sizeof(bufn) );
      new String:bufn2[256];
      GetClientName(clientGRABBING, bufn2, sizeof(bufn2) );
      PrintToChatAll("%s steals the ball from %s", bufn , bufn2);
      rCounter[clientGRABBING] = RCOUNTER_RELOAD * 2;
      rELASTCounter[clientGRABBING] = RELASTCOUNTER_RELOAD * 2;
      Soltar_Bola(94, clientGRABBING);
      ClientCommand( client, "play *customsounds/bloqueo_arb.mp3" );
      //clientLaQuita[client] = 1; //No haría falta, es redundante.
    }
  }
  
  destroyBARRAahora(client);
  Soltar_Bola(99, client);
  if (distPlayerBall[client] < RADIUS_ATTACK_CLICK){
    if (counterClickIzquierdo[client] == 0){
      clientEjecutaAttack[client] = 1;
      AcceptEntityInput(Enty, "Wake"); //DESPERTARLA A LA BOLA
    }
    counterClickIzquierdo[client] = 3;
    //TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, NULL_VELOCITY);
  }
    
}

public Event_PlayerHurt(Handle: event, const String: name[], bool: dontBroadcast){
  //PrintToChatAll("SOCCERMODPRO. Damage detected"); 
  new victim = GetClientOfUserId(GetEventInt(event, "userid"));
  new attacker   = GetClientOfUserId(GetEventInt(event, "attacker"));
  //PrintToChatAll("SOCCERMODPRO. Victim: %d", victim); 
  //PrintToChatAll("SOCCERMODPRO. Victim %d hurt", victim);
  if (IsClientInGame(victim) && IsPlayerAlive(victim)){
    //rCounter[victim] = RCOUNTER_DAMAGE_PENALTY;
  }
  if (victim == clientGRABBING && !esArquero[clientGRABBING]){
    if (attacker > 0){
          new String:xclienteattacker[64];
          GetClientName(attacker, xclienteattacker, sizeof(xclienteattacker)); 
          new String:xclientevictim[64];
          GetClientName(victim, xclientevictim, sizeof(xclientevictim)); 
          PrintToChatAll(" \x01\x0B\x05 SOCCERMODPRO. \x01\x0B\x03 %s \x01\x0B\x05 took the ball from \x01\x0B\x03 %s", xclienteattacker, xclientevictim);
          //PrintToChatAll("SOCCERMODPRO. Victim %s hurt by %s and lost the ball", xclientevictim, xclienteattacker);
    }
    else{
      new String:xclientevictim[64];
      GetClientName(victim, xclientevictim, sizeof(xclientevictim)); 
      PrintToChatAll(" \x01\x0B\x05 SOCCERMODPRO. \x01\x0B\x03 %s \x01\x0B\x05 was hurt and lost the ball.", xclientevictim);
    }
    Soltar_Bola( 93, victim );
  }

  
}



//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_





public Action:Command_Speed_Manual(client, args)
{ //cambia la velocidad manualmente, requiere permisos de admin..
  //PrintToChatAll("SMP Command_Speed_Manual: init");
  new String:argument[192];
  GetCmdArgString(argument, sizeof(argument));
  new Float:speed;
  if (strlen(argument) > 0){
    new argInteg = StringToInt(argument);
    PrintToChatAll("SMP Command_Speed_Manual: args: %d" , argInteg ) ;
    speed = 1.0 * argInteg * 0.02;
  }else{
    speed = 1.0;
  }

  PrintToChatAll("SMP Command_Speed_Manual: speed: %f" , speed ) ;
  SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", speed);
  //PrintToChatAll("SMP Command_Speed_Manual: end");
}



public Action:EstablecerSpeed(client, argInt)
{
  //PrintToChatAll("SMP EstablecerSpeed: init");
  new Float:speed;
  if (argInt> 0){
    //PrintToChatAll("SMP EstablecerSpeed: args: %d" , argInt ) ;
    speed = 1.0 * argInt * 0.02;
  }else{
    speed = 1.0;
  }

  //PrintToChatAll("SMP EstablecerSpeed: speed: %f" , speed ) ;
  SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", speed);
  speedJugadorActual[client] = argInt; //se guarda esta variable para no hacer un getSpeed luego..
  //PrintToChatAll("SMP EstablecerSpeed: end");
}


public Action:Command_barrida(client){
  //PrintToChat(client, "Haciendo barrida");
  ForzarAgache[client] = 1;
  ClientCommand( client, "play *customsounds/barrida2_arb.mp3" );
  Command_TestCrouch2(client, 0);
  CreateTimer(1.5, TerminarBarrida, client);
}

public Action:TerminarBarrida(Handle:timer, any:client)
{
  //esta función es para el timer, por eso llama a
  internal_terminarBarrida(client);
}

public internal_terminarBarrida(client){
  //if (!IsValidEntity(client) || !IsClientInGame(client)) return;
  ForzarAgache[client] = 0;
  //PrintToChat(client, "Slide tackle ends."); TERMINA BARRIDA
}

public Action:Command_testCurveBall(client, args)
{     //comando CRUDO funcional pero testing que empuja a la bola en la dirección del usuario, con cierto speed prefijado.
      //PrintToChatAll("test_curveBall: about to perform.z1");
      PrintToChatAll("test_curveBall: ball index: %d" , Enty);
      //CreateTimer(0.1, pushBallIteratively);
      //CreateTimer(0.10, pushBallIteratively, _, TIMER_REPEAT);
      //PrintToChatAll("test_curveBall: Finished for: Player: %i ..", client);

      PrintToChatAll("test_curveBall::start_brush");
      //start brush creation
      new Float:playerpos[3];
      GetEntPropVector(client, Prop_Send, "m_vecOrigin", playerpos);

      new Float:AngUser[3];
      GetClientEyeAngles(client, AngUser);

      new entindex = CreateEntityByName("trigger_push");
      if (entindex != -1)
      {
          //DispatchKeyValue(entindex, "pushdir", "0 0 0");
          DispatchKeyValue(entindex, "speed", "1000");
          //DispatchKeyValue(entindex, "spawnflags", "64");
          DispatchKeyValue(entindex, "spawnflags", "8"); //afectar solo a physics no humanos (creo)
      }

      DispatchSpawn(entindex);
      ActivateEntity(entindex);

      TeleportEntity(entindex, playerpos, AngUser, NULL_VECTOR); //pos ang vel

      SetEntityModel(entindex, "models/props/cs_office/vending_machine.mdl");

      new Float:minbounds[3] = {-300.0, -300.0, 0.0};
      new Float:maxbounds[3] = {300.0, 300.0, 600.0};

      SetEntPropVector(entindex, Prop_Send, "m_vecMins", minbounds);
      SetEntPropVector(entindex, Prop_Send, "m_vecMaxs", maxbounds);
          
      SetEntProp(entindex, Prop_Send, "m_nSolidType", 2);

      new enteffects = GetEntProp(entindex, Prop_Send, "m_fEffects");
      enteffects |= 32;
      //enteffects |= 128; //once only?
      SetEntProp(entindex, Prop_Send, "m_fEffects", enteffects);  

      PrintToChatAll("test_curveBall::end_brush");
      CreateTimer(0.8, destroyPushCreated, entindex);
}

public Action:Command_slightPush(client)
{     //comando para pushear la bola un poco , para DESPERTARLA
      //PrintToChatAll("test_curveBall: about to perform.z1");
      //PrintToChatAll("test_curveBall: ball index: %d" , Enty);
      //CreateTimer(0.1, pushBallIteratively);
      //CreateTimer(0.10, pushBallIteratively, _, TIMER_REPEAT);
      //PrintToChatAll("test_curveBall: Finished for: Player: %i ..", client);

      //PrintToChatAll("test_curveBall::start_brush");
      //start brush creation
      new Float:playerpos[3];
      GetEntPropVector(Enty, Prop_Send, "m_vecOrigin", playerpos);

      new Float:AngUser[3];
      GetClientEyeAngles(client, AngUser);

      new entindex = CreateEntityByName("trigger_push");
      if (entindex != -1)
      {
          //DispatchKeyValue(entindex, "pushdir", "0 0 0");
          DispatchKeyValue(entindex, "speed", "1"); //de poca fuerza
          //DispatchKeyValue(entindex, "spawnflags", "64");
          DispatchKeyValue(entindex, "spawnflags", "8"); //afectar solo a physics no humanos (creo)
      }

      DispatchSpawn(entindex);
      ActivateEntity(entindex);

      TeleportEntity(entindex, playerpos, AngUser, NULL_VECTOR); //pos ang vel

      SetEntityModel(entindex, "models/props/cs_office/vending_machine.mdl");

      new Float:minbounds[3] = {-300.0, -300.0, 0.0};
      new Float:maxbounds[3] = {300.0, 300.0, 600.0};

      SetEntPropVector(entindex, Prop_Send, "m_vecMins", minbounds);
      SetEntPropVector(entindex, Prop_Send, "m_vecMaxs", maxbounds);
          
      SetEntProp(entindex, Prop_Send, "m_nSolidType", 2);

      new enteffects = GetEntProp(entindex, Prop_Send, "m_fEffects");
      enteffects |= 32;
      //enteffects |= 128; //once only?
      SetEntProp(entindex, Prop_Send, "m_fEffects", enteffects);  

      //PrintToChatAll("test_curveBall::end_brush");
      CreateTimer(0.2, destroyPushCreated, entindex);
}

public Action:destroyPushCreated(Handle:timer, any:entindex)
{
  RemoveParticleNow(entindex);
  //PrintToChatAll("test_curveBall::entindex destroyed.");
  return Plugin_Stop;
}

/*
 * REMOVE PARTICLE ENT NOW
 * 
 * @param particle        Ent to remove.
 */
stock RemoveParticleNow(any:particle)
{
    if(IsValidEdict(particle))
    {
        AcceptEntityInput(particle, "Deactivate");
        AcceptEntityInput(particle, "Kill");
    }
}



public Action:pushBallIteratively(Handle:timer)
{ //iterative command. Handles curving the ball trajectory.

  if (numCurvaIter >= 16) 
  {
      numCurvaIter = 0;
      CurvaQueLeDio = 0;
      clientQueLaCurvo = -1;
      //PrintToChatAll("pushBallIteratively::end");
      
      
      return Plugin_Stop;
      //return;
  }
  //AGREGAR MODIFIER PARA LA POTENCIA DEL PUSH EN BASE AL numCurvaIter PARA QUE TRAYECTORIA=CURVA SENOIDAL
  // if (numCurvaIter >= 10) {
  //   if (ballCurve ==2){
  //         PrintToChatAll("test_curveBall::left::Print number : %d" , numCurvaIter  );
  //         createBrushLeft();
  //   }
  //   if (ballCurve ==1){
  //         createBrushRight();
  //         PrintToChatAll("test_curveBall::right::Print number : %d" , numCurvaIter );
  //   }



  // }
  // else{
  //   if (ballCurve ==2){
  //         PrintToChatAll("test_curveBall::right::Print number : %d" , numCurvaIter  );
  //         createBrushRight();
  //   }
  //   if (ballCurve ==1){
  //         createBrushLeft();
  //         PrintToChatAll("test_curveBall::left::Print number : %d" , numCurvaIter );
  //   }
  // }
  new Float: PosPelota[3];
  GetEntPropVector(Enty, Prop_Send, "m_vecOrigin", PosPelota);
  if (PosPelota[2] < canchaZ +300)
  {
    //está a una altura razonable, sino ocurre el efecto "teledirigido"
      if (CurvaQueLeDio ==2)
	  {
          //PrintToChatAll("pushBallIteratively::right::Print number : %d" , numCurvaIter  );
          createBrushRight();
      }
      if (CurvaQueLeDio ==1)
	  {
              createBrushLeft();
              //PrintToChatAll("pushBallIteratively::left::Print number : %d" , numCurvaIter );
      }
  }else
  {
    PrintHintTextToAll("No creo nada porque estA muy alto %d " , numCurvaIter );
  }

 
  
  numCurvaIter++;
 
  return Plugin_Continue;
}


public Action:OnUNTouchingTrigger(entity, other)
{//se llama cuando se deja de tocar un trigger_multiple
        new String:classNombre[32];
        GetEdictClassname(other, classNombre, 32);
        new String:strName[128];
        GetEntPropString(entity, Prop_Data, "m_iName", strName, sizeof(strName));
        new jugador_ejecuto_trigger = 0;

        if ( StrEqual(strName , "terro_But", true) ) {
          
          if (other == Enty){
            //PrintToChatAll("SALEentra bola a arco tt.");
            //PrintHintTextToAll("terror arco.\n %s %d %d", classNombre, other, Enty);
            if (goalScored==0) GanarCT();
          }
            
        }
        if ( StrEqual(strName , "ct_But", true) ) {
          
          if (other == Enty){
            //PrintToChatAll("SALEentra bola a arco ct.");
            //PrintHintTextToAll("CT arco.\n %s %d %d", classNombre, other, Enty);
            if (goalScored==0)GanarTT();
          }
            
        }


        if ( StrEqual(strName , "terro_but", true) ) {
          
          if (other == Enty){
            //PrintToChatAll("SALEentra bola a arco tt.");
            //PrintHintTextToAll("terror arco.\n %s %d %d", classNombre, other, Enty);
            if (goalScored==0) GanarCT();
          }
            
        }
        if ( StrEqual(strName , "ct_but", true) ) {
          
          if (other == Enty){
            //PrintToChatAll("SALEentra bola a arco ct.");
            //PrintHintTextToAll("CT arco.\n %s %d %d", classNombre, other, Enty);
            if (goalScored==0) GanarTT();
          }
            
        }



        //ARCOS
        if ( StrEqual(classNombre , "player", true) ){
            jugador_ejecuto_trigger = 1;
            if ( StrEqual(strName , "areatt", true) && (GetClientTeam(other) == 2 ) ) { //EL NOMBRE ESTÁ AL REVÉS, CORREGIR MAPA !
              //PrintToChat(other, "Leaving TT area");
              if (esArquero[other]) Soltar_Bola(99, other);
              if (GetClientTeam(other) == 2){
                //PrintToChat(other, "Supuestamente soy TT");
              }
              permitidoSerArquero[other] = 0;
            }
            if ( StrEqual(strName , "areact", true) && (GetClientTeam(other) == 3 ) ) { //EL NOMBRE ESTÁ AL REVÉS, CORREGIR MAPA !
              //PrintToChat(other, "Leaving CT area");
              if (esArquero[other]) Soltar_Bola(99, other);
              if (GetClientTeam(other) == 3){
                //PrintToChat(other, "Supuestamente soy CT");
              }
              permitidoSerArquero[other] = 0;
            }
        }
        //PELOTA_REBOTE
        if ( jugador_ejecuto_trigger == 1){
            if ( StrEqual(strName , "prender", true) ) {
              playerTouchingFloor[other] = 0;
            }
            return Plugin_Continue;//the player just jumped..
        }
        
        //PrintHintTextToAll("Touching.. %s" , strName);
        if ( StrEqual(strName , "prender", true) ) {
            BallTouchingFloor = 0;
            //PrintHintTextToAll("NOT Touching floor \n %s" , classNombre );
        }
        return Plugin_Continue;
}

public Action:TouchingTheFloor(entity, other)
{ //esta función actualmente se usa sólo para detectar el piso.. para otro uso ver el tema de return ...



    new String:classNombre[32];
    GetEdictClassname(other, classNombre, 32);
    new String:strName[128];
    GetEntPropString(entity, Prop_Data, "m_iName", strName, sizeof(strName));

    //entity: el trigger_multiple ; other: la otra cosa que lo está tocando.

    //línea de gol.

    if ( StrEqual(classNombre , "player", true) ){
        if ( StrEqual(strName , "prender", true) ) playerTouchingFloor[other] = 1;
        return Plugin_Continue;
    }
    
    //     //PrintHintTextToAll("Touching.. %s" , strName);
    if ( StrEqual(strName , "prender", true) ) { //supuestamente solo la pelota, pero si alguien pone un prop_physics????
        BallTouchingFloor = 1;
        if (numCurvaIter >1 ) numCurvaIter = 99;
        timeOnAir=0;
        maxBallPosAlcanzado = 0.0;
    }
    return Plugin_Continue;
}



public Action:OnTouchingTrigger(entity, other)
{//se llama cuando se entra a tocar un trigger_multiple
        new String:classNombre[32];
        GetEdictClassname(other, classNombre, 32);


        new String:strName[128];
        GetEntPropString(entity, Prop_Data, "m_iName", strName, sizeof(strName));
        new jugador_ejecuto_trigger = 0;

        
        if ( StrEqual(strName , "terro_But", true) ) {
          
          if (other == Enty){
            //PrintToChatAll("entra bola a arco tt.");
            //PrintHintTextToAll("terror arco.\n %s %d %d", classNombre, other, Enty);
            if (goalScored==0) GanarCT();
          }
            
        }
        if ( StrEqual(strName , "ct_But", true) ) {
          
          if (other == Enty){
            //PrintToChatAll("entra bola a arco ct.");
            //PrintHintTextToAll("CT arco.\n %s %d %d", classNombre, other, Enty);
            if (goalScored==0)GanarTT();
          }
            
        }


        if ( StrEqual(strName , "terro_but", true) ) {
          
          if (other == Enty){
            //PrintToChatAll("entra bola a arco tt.");
            //PrintHintTextToAll("terror arco.\n %s %d %d", classNombre, other, Enty);
            if (goalScored==0) GanarCT();
          }
            
        }
        if ( StrEqual(strName , "ct_but", true) ) {
          
          if (other == Enty){
            //PrintToChatAll("entra bola a arco ct.");
            //PrintHintTextToAll("CT arco.\n %s %d %d", classNombre, other, Enty);
            if (goalScored==0) GanarTT();
          }
            
        }

        //ARCOS
        if ( StrEqual(classNombre , "player", true) ){
            jugador_ejecuto_trigger = 1;
            if ( StrEqual(strName , "areatt", true) && (GetClientTeam(other) == 2 ) ) { //EL NOMBRE ESTÁ AL REVÉS, CORREGIR MAPA !
              //PrintToChat(other, "Enter TT area");
              permitidoSerArquero[other] = 1;
              if (esArquero[other] ) PrintHintText(other, "");
            }
            if ( StrEqual(strName , "areact", true) && (GetClientTeam(other) == 3 ) ) { //EL NOMBRE ESTÁ AL REVÉS, CORREGIR MAPA !
              //PrintToChat(other, "Enter CT area");
              permitidoSerArquero[other] = 1;
              if (esArquero[other]) PrintHintText(other, "");
            }
        }
        //PELOTA_REBOTE
        //PrintHintTextToAll("Touching.. %s" , strName);
        if (jugador_ejecuto_trigger == 1){
          return Plugin_Continue;//the player just jumped..
        }
        if ( StrEqual(strName , "prender", true) ) {
            BallTouchingFloor = 1;
            if (numCurvaIter > 1) numCurvaIter = 99; //cancelar curva.
            //PrintHintTextToAll("Touching floor _ %d", timeOnAir );
            if (timeOnAir > 60){
                //PONER PUSH SOBRE BOLA PARA ARRIBA
                if (timeOnAir > 1100){
                    return Plugin_Continue;//too high, it's impossible.
                }

                if (cancelarPorJugador == 0){
                    createBrushUp();
                    //TocandoSuelo();
                    //PrintToChatAll("Time on air: %d \n max pos ball alcanzado: %f" , timeOnAir, maxBallPosAlcanzado)
                }
                else{
                  //PrintToChatAll("Un jugador la baja de primera");
                  cancelarPorJugador = 0;
                  //TocandoSuelo();
                }
            }
            timeOnAir=0;
        }
        return Plugin_Continue;
}


public TocandoSuelo(){
  //función que se ejecuta cuando se detecta que tocó Suelo
  numCurvaIter = 99;
}



////////////////////STATS START

public GanarCT(){
  if (goalAllowed == 0) return;
  numCurvaIter = 99;
  PrintHintTextToAll( "CT Team Wins");
  for (new x = 1; x < MAXPLAYERS; x++)
  {
      if (IsClientInGame(x) && IsPlayerAlive(x))
      {
        //ClientCommand( x, "play *customsounds/sifflet_but_arb.mp3" );
      }
  }
  //g_strStat = CreateConVar("smp_golstr", "chola123");
  winningTeam = 3;
  losingTeam = 2;
  internal_putStrings()
  internal_punishOwnGoal();
  //PrintToChatAll("Seteado convar.");
  internal_makeCTWin();
}

public GanarTT(){
  if (goalAllowed == 0) return;
  numCurvaIter = 99;
  PrintHintTextToAll("TT Team Wins");
  for (new x = 1; x < MAXPLAYERS; x++)
  {
      if (IsClientInGame(x) && IsPlayerAlive(x))
      {
        //ClientCommand( x, "play *customsounds/sifflet_but_arb.mp3" );
      }
  }
  winningTeam = 2;
  losingTeam = 3;
  internal_putStrings();
  internal_punishOwnGoal();
  //PrintToChatAll("Creado convar.");
  internal_makeTTWin();
}

public internal_putStrings(){

  new String:estadist_a_poner[128];
  for (new i = 0; i < 126; i++)
  {
    estadist_a_poner[i] = '!';
  }
  estadist_a_poner[123] = '\0';
  estadist_a_poner[124] = '\0';
  estadist_a_poner[125] = '\0';
  estadist_a_poner[126] = '\0';
  estadist_a_poner[127] = '\0';
  if ( winningTeam ==3 ) estadist_a_poner[0] = 'c';
  if ( winningTeam == 2) estadist_a_poner[0] = 't';
  if ( winningTeam < 1 ) estadist_a_poner[0] = 'd';
  //buscamos quién hizo el gol 
  new elquemetiogol = -1;
  new eldelgolencontra = -1;
  new elasistidor = -1;
  new hayasistencia = 0;
  //PrintToChatAll("Pregol");
  for (new i =0; i<6; i++){
    if (historia_jugadas[i] == 0)
      continue;
    if ( (!IsClientInGame(historia_jugadas[i])) || (!IsPlayerAlive(historia_jugadas[i])) )
          continue;

    if (GetClientTeam( historia_jugadas[i] ) == winningTeam){
      //ESTE FUE EL ÚLTIMO JUGADOR EN TOCARLA
      new String:bufn[127];
      GetClientName(historia_jugadas[i], bufn, sizeof(bufn) );
      //PrintToChatAll("%d %s", i, bufn);
      PrintToChatAll("Goal scored by %s !", bufn);

      estadist_a_poner[1] = '!' + historia_jugadas[i];
      elquemetiogol = historia_jugadas[i];
      Accum_GOLES[elquemetiogol]++;
      break;
    }else{
      //PrintToChatAll("Nadie mete gol.");
      if (eldelgolencontra == -1) eldelgolencontra = historia_jugadas[i];
    }
  }
  //PrintToChatAll("Postgol %d", elquemetiogol);
  if (elquemetiogol == -1){
    new String:bufn[127];
    GetClientName(eldelgolencontra, bufn, sizeof(bufn) );
    PrintToChatAll("Self goal by %s" , bufn);
    estadist_a_poner[1] = '!' + eldelgolencontra;
    ganoAntesCT = 0;
    ganoAntesTT = 0;
  }else{
      //buscamos de quién la asistencia.
      if (GetClientTeam(elquemetiogol)  == 2){
          ganoAntesCT = 0;
          ganoAntesTT = 1;
      }
      if (GetClientTeam(elquemetiogol)  == 3){
          ganoAntesCT = 1;
          ganoAntesTT = 0;
      }

      //PrintToChatAll("Calculo assist.");
      for (new i=0; i<6; i++){
        //PrintToChatAll("%d , %d", i , historia_jugadas[i]);
        if ( (historia_jugadas[i] == 0) || (!IsClientInGame(historia_jugadas[i])) || (!IsPlayerAlive(historia_jugadas[i])) ){
              //PrintToChatAll("Precontinue. %d", i);
              continue;      
        }
        //PrintToChatAll("Post. %d", i);
        if (GetClientTeam( historia_jugadas[i] ) == winningTeam && historia_jugadas[i] != elquemetiogol ){
          new String:bufn[127];
          GetClientName(historia_jugadas[i], bufn, sizeof(bufn) );
          PrintToChatAll("Assist from player %s", bufn);
          estadist_a_poner[2] = '!' + historia_jugadas[i];
          hayasistencia = 1;

          elasistidor = historia_jugadas[i];
          Accum_ASSIST[elasistidor]++;
          break;
        }
      }
      if (!hayasistencia){
        PrintToChatAll("There was no assist for this goal."); 
      }
  }

  //empezamos a pasar los quites y atajadas
  //índice hjk es quites
  //índice hjk+1 es atajadas
  //(hjk-1) / 2 es el jugador que estoy iterando
  //PrintToChatAll("Poniendo quites/ark");
  for (new hjk = 3; hjk<123; hjk+=2){
    new indicecliente = (hjk-1) / 2;
    if ( (!IsClientInGame(indicecliente)) || (!IsPlayerAlive(indicecliente)) )
      continue;
    //es un cliente válido, sumar los quites totales y resetearle el counter.
    //PrintToChatAll("pre: %s", estadist_a_poner);
    estadist_a_poner[hjk] = '!' + clienteQuitesTotales[indicecliente];
    //PrintToChatAll("post: %s", estadist_a_poner);
    clienteQuitesTotales[indicecliente]=0;
    estadist_a_poner[hjk+1] = '!' + clienteAtajadasTotales[indicecliente];
    clienteAtajadasTotales[indicecliente]=0;
  }
  //PrintToChatAll("mod: %s", estadist_a_poner);
  SetConVarString(g_strStat, estadist_a_poner, true, false);

  //AHORA LAS STATS DEL TAB
  //GOLES PRIMERO
  if (eldelgolencontra == -1 && elquemetiogol != -1) //sino, fue gol en contra
    SetEntProp(elquemetiogol, Prop_Data, "m_iFrags", Accum_GOLES[elquemetiogol] ) ;

  if (hayasistencia && elasistidor != -1){
    CS_SetClientAssists(elasistidor, Accum_ASSIST[elasistidor]);  
  }

  for (new i = 1 ; i<MAXPLAYERS; i++){
    if ( (!IsClientInGame(i)) || (!IsPlayerAlive(i)) )
          continue;

    if (GetClientTeam( i ) == winningTeam){
      Accum_WIN[i]++;
      CS_SetMVPCount( i, Accum_WIN[i] );
    }
    if (GetClientTeam( i ) == losingTeam){
      Accum_LOSE[i]++;
      SetEntProp(i, Prop_Data, "m_iDeaths", Accum_LOSE[i] );
    }
  }
  
}

public internal_punishOwnGoal(){
  new advertirle = 0;
  if ( (!IsClientInGame( historia_jugadas[0] )) || (!IsPlayerAlive( historia_jugadas[0] )) )
    return; //no se puede castigar si se desconecta..

  
  if (GetClientTeam(historia_jugadas[0]) == losingTeam ){  
    //el último en tocar la bola fue el del mismo equipo. Si NO es GK, advertirle.
    if (esArquero[historia_jugadas[0]]){
      if (historia_jugadas[1] == historia_jugadas[0]){
        //este tipo es arquero, y fue el último en tocarla , dos veces, antes del gol. Advertirle.
        advertirle++;
      }
    }else{
      //no es arquero y fue el último en tocarla, y es del equipo perdedor. Gol en contra. Advertirle.
      advertirle++;
    }
  }
  if (advertirle){
    acumularKicks[ historia_jugadas[0] ]++;
  }
  if (acumularKicks[ historia_jugadas[0] ] > 2 ){
    //Removido dIa 02/08/2015 porque supuestamente kickea y banea gente inocente (falso positivo)
    //decl String:mensaje[128];
    //Format(mensaje, sizeof( mensaje )  ,  "Own goal is not allowed on SMPro - banned for %d minutes ", acumularKicks[ historia_jugadas[0] ] );
    //BanClient(historia_jugadas[0], acumularKicks[ historia_jugadas[0] ], BANFLAG_AUTO, mensaje, mensaje);
    return;
  }
  if (acumularKicks[ historia_jugadas[0] ] > 1 ){
    //Removido dIa 02/08/2015 porque supuestamente kickea y banea gente inocente (falso positivo)
    //KickClient(historia_jugadas[0], "Own goal is not allowed on SMPro");
    return;
  }
  if (acumularKicks[ historia_jugadas[0] ] == 1){
    if (mostradoAdvertencia[ historia_jugadas[0]  ] == 0){
          //Removido dIa 02/08/2015 porque supuestamente kickea y banea gente inocente (falso positivo)
          //new String:bufn[127];
          //GetClientName(historia_jugadas[0], bufn, sizeof(bufn) );
          //PrintToChatAll("The player %s is warned because of self-goal. Next time will be kicked.", bufn);
          //mostradoAdvertencia[ historia_jugadas[0]  ] = 1;
    }

  }

}

public exeRoundDraw()
{
        CS_SetTeamScore(CS_TEAM_CT, golesCT);
        SetTeamScore(CS_TEAM_CT, golesCT);
        CS_SetTeamScore(CS_TEAM_T, golesTT);
        SetTeamScore(CS_TEAM_T, golesTT);
        //PrintToChatAll("SMP roundDraw: Forced a Round End.");
        new Handle:event = CreateEvent("cs_win_panel_round") 
        SetEventBool(event, "show_timer_defend", true)
        SetEventBool(event, "show_timer_attack", true)
        SetEventInt(event, "timer_time", 10)

        SetEventInt(event, "final_event", _:CSRoundEnd_Draw)

        CS_TerminateRound(6.1,  CSRoundEnd_Draw, false);
        PrintToChatAll("Forced a Round End.");
        CS_SetTeamScore(CS_TEAM_CT, golesCT);
        SetTeamScore(CS_TEAM_CT, golesCT);
        CS_SetTeamScore(CS_TEAM_T, golesTT);
        SetTeamScore(CS_TEAM_T, golesTT);
        goalAllowed = 0;
}


public resetStatsToZero(){
  for (new i = 1; i< MAXPLAYERS; i++){
      Accum_PUNTOS[i] = 0;
      Accum_GOLES[i] = 0;
      Accum_ASSIST[i] = 0;
      Accum_LOSE[i] = 0;
      Accum_WIN[i] = 0;
      if (IsClientInGame(i) )
	  {
            CS_SetMVPCount(i, Accum_WIN[i]);
            CS_SetClientAssists(i, Accum_ASSIST[i]);
            SetEntProp(i, Prop_Data, "m_iDeaths", Accum_LOSE[i] );
            SetEntProp(i, Prop_Data, "m_iFrags", Accum_GOLES[i] ) ;
            CS_SetClientContributionScore(i, Accum_PUNTOS[i]);
      }

  }
  golesTT = 0;
  golesCT = 0;
  CS_SetTeamScore(CS_TEAM_CT, golesCT);
  SetTeamScore(CS_TEAM_CT, golesCT);
  CS_SetTeamScore(CS_TEAM_T, golesTT);
  SetTeamScore(CS_TEAM_T, golesTT);
}


public internal_makeCTWin(){
  //this function makes CT team win the match...

  //CS_TerminateRound(5.1, CSRoundEnd_CTWin, false);
  //CS_SetTeamScore(CS_TEAM_T, CS_GetTeamScore(CS_TEAM_T)+0);
  //SetTeamScore(CS_TEAM_T, CS_GetTeamScore(CS_TEAM_T)+0);
  //golesCT = golesCT+1 ;
  //CS_SetTeamScore(CS_TEAM_CT, golesCT);
  //SetTeamScore(CS_TEAM_CT, golesCT);

  //golesCT = CS_GetTeamScore(CS_TEAM_CT) + 1 ;
  golesCT = golesCT + 1 ;
  CS_SetTeamScore(CS_TEAM_CT, golesCT);
  SetTeamScore(CS_TEAM_CT, golesCT);

  if (golesCT > 30){
    golesCT = 1;
  }

  new Handle:event = CreateEvent("cs_win_panel_round") 
  SetEventBool(event, "show_timer_defend", true)
  SetEventBool(event, "show_timer_attack", true)
  SetEventInt(event, "timer_time", 10)

  SetEventInt(event, "final_event", _:CSRoundEnd_CTWin)

  CS_TerminateRound(6.1,  CSRoundEnd_TargetSaved, false);
  
  goalScored = 1;
  //CS_SetTeamScore(3,CS_GetTeamScore(3)+1)

  //CS_TerminateRound(5.1,  CSRoundEnd_TargetSaved, false);
}

public internal_makeTTWin(){
  //CS_TerminateRound(5.1, CSRoundEnd_TerroristWin, false);
  //CS_TerminateRound(5.1,  CSRoundEnd_TargetBombed, false);
  //CS_TerminateRound(5.1,  CSRoundEnd_TargetBombed, false);
  //CS_SetTeamScore(CS_TEAM_T, CS_GetTeamScore(CS_TEAM_T)+1);
  
  golesTT = golesTT+1 ;
  CS_SetTeamScore(CS_TEAM_T, golesTT);
  SetTeamScore(CS_TEAM_T, golesTT);
  
  //CS_SetTeamScore(CS_TEAM_CT, CS_GetTeamScore(CS_TEAM_CT)+0);
  //SetTeamScore(CS_TEAM_CT, CS_GetTeamScore(CS_TEAM_CT)+0);

  //golesTT = CS_GetTeamScore(CS_TEAM_T) + 1 ;

  if (golesTT > 30){
    golesTT = 1;
  }

  //CS_SetTeamScore(CS_TEAM_T, golesTT);
  //SetTeamScore(CS_TEAM_T, golesTT);

  new Handle:event = CreateEvent("cs_win_panel_round") 
  SetEventBool(event, "show_timer_defend", true)
  SetEventBool(event, "show_timer_attack", true)
  SetEventInt(event, "timer_time", 10)
  
  SetEventInt(event, "final_event", _:CSRoundEnd_TerroristWin)
  CS_TerminateRound(6.1,  CSRoundEnd_TargetBombed, false);

  goalScored = 1;
  //CS_SetTeamScore(2,CS_GetTeamScore(2)+1)
}

public Action:Command_Model(client,args)
{
  if (esArquero[client]){
    PrintToChat(client,"GK is not allowed to change model.");
    CreateTimer(0.3, RemoverMenuArk, client);
    return Plugin_Stop;
  }

  return Plugin_Continue;
}
public Action:RemoverMenuArk(Handle:timer, any:client){
    new Handle:panel = CreatePanel();
    DrawPanelItem(panel, "");
    //}
    SendPanelToClient(panel, client, StatsMeHandler, 2);
    CloseHandle(panel);
}

public StatsMeHandler(Handle:menu, MenuAction:action, param1, param2)
{
}
////////////////////STATS END

public internal_atraerBolaORIGINAL(client){
    new Float:postemp[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", postemp);


    new Float:tempCompare = postemp[2] * 100.0 ;
    new Float:tempCompare2 = (canchaZ + HEIGHT_ATTRACTBALL) * 100;

    new tempIntCompare =  RoundFloat(tempCompare);
    new tempIntCompare2 =  RoundFloat(tempCompare2);

    if (tempIntCompare > tempIntCompare2){
      //PrintToChat(client, "SOCCERMODPRO: ANTIBUG. R canceled" );
      return;
    }

    new Float:PosBall[3];
    new Float:PosUser[3];
    new Float:VectorDifference[3];
    GetEntPropVector(Enty, Prop_Send, "m_vecOrigin", PosBall);
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);

    ///
    //PrintToChat(client, "SOCCERMODPRO. Ball attracted  0.");
    new Float:destOrigin[3];
    decl Float:clientOrigin[3];
    decl Float:clientEyeAngles[3];
    GetClientAbsOrigin(client, clientOrigin);
    GetClientEyeAngles(client, clientEyeAngles);
    new Float:cos = Cosine(DegToRad(clientEyeAngles[1]));
    new Float:sin = Sine(DegToRad(clientEyeAngles[1]));
        
    destOrigin[0] = clientOrigin[0] + cos * (SHR_DISTANCE_BETWEEN_PLAYER_AND_BALL + 30);
    destOrigin[1] = clientOrigin[1] + sin * (SHR_DISTANCE_BETWEEN_PLAYER_AND_BALL + 30);
    destOrigin[2] = clientOrigin[2] + SHR_BALL_HOLD_HEIGHT ;

    //PrintToChat(client, "SOCCERMODPRO. Ball attracted  1.");
    //TeleportEntity(enty, orig_ball, NULL_VECTOR, NULL_VECTOR); 
    //TeleportEntity(enty, destOrigin, clientEyeAngles, NULL_VECTOR); //changed.
    ///


    VectorDifference[0] = (destOrigin[0] - PosBall[0]) * SHR_ATTRACTBALL_MULTIPLIER ;
    VectorDifference[1] = (destOrigin[1] - PosBall[1]) * SHR_ATTRACTBALL_MULTIPLIER ;
    VectorDifference[2] = (destOrigin[2] - PosBall[2]) * SHR_ATTRACTBALL_MULTIPLIER ;
    TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, VectorDifference);
}

public internal_atraerBolaANTIGBUG(client){
    //exactamente igual al original pero con menos rango y más fuerza, para cuando corrés rápido + le estás cargando barra a la bola
    new Float:postemp[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", postemp);


    new Float:tempCompare = postemp[2] * 100.0 ;
    new Float:tempCompare2 = (canchaZ + HEIGHT_ATTRACTBALL) * 100;

    new tempIntCompare =  RoundFloat(tempCompare);
    new tempIntCompare2 =  RoundFloat(tempCompare2);

    if (tempIntCompare > tempIntCompare2){
      //PrintToChat(client, "SOCCERMODPRO: ANTIBUG. R canceled" );
      return;
    }

    new Float:PosBall[3];
    new Float:PosUser[3];
    new Float:VectorDifference[3];
    GetEntPropVector(Enty, Prop_Send, "m_vecOrigin", PosBall);
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);

    ///
    //PrintToChat(client, "SOCCERMODPRO. Ball attracted  0.");
    new Float:destOrigin[3];
    decl Float:clientOrigin[3];
    decl Float:clientEyeAngles[3];
    GetClientAbsOrigin(client, clientOrigin);
    GetClientEyeAngles(client, clientEyeAngles);
    new Float:cos = Cosine(DegToRad(clientEyeAngles[1]));
    new Float:sin = Sine(DegToRad(clientEyeAngles[1]));
        
    destOrigin[0] = clientOrigin[0] + cos * (SHRANTIBUGG_DISTANCE_BETWEEN_PLAYER_AND_BALL + 30);
    destOrigin[1] = clientOrigin[1] + sin * (SHRANTIBUGG_DISTANCE_BETWEEN_PLAYER_AND_BALL + 30);
    destOrigin[2] = clientOrigin[2] + SHR_BALL_HOLD_HEIGHT ;

    //PrintToChat(client, "SOCCERMODPRO. Ball attracted  1.");
    //TeleportEntity(enty, orig_ball, NULL_VECTOR, NULL_VECTOR); 
    //TeleportEntity(enty, destOrigin, clientEyeAngles, NULL_VECTOR); //changed.
    ///


    VectorDifference[0] = (destOrigin[0] - PosBall[0]) * SHRANTIBUGG_ATTRACTBALL_MULTIPLIER ;
    VectorDifference[1] = (destOrigin[1] - PosBall[1]) * SHRANTIBUGG_ATTRACTBALL_MULTIPLIER ;
    VectorDifference[2] = (destOrigin[2] - PosBall[2]) * SHRANTIBUGG_ATTRACTBALL_MULTIPLIER ;
    TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, VectorDifference);
}

public Action:Command_attractBall(client, args){
  if ( !esArquero[client] && playerTouchingFloor[client] == 0){
    //no es arquero, no toca el suelo, entonces no tiene derecho a usar R
    return;
  }

  if ( distPlayerBall[client] < (RADIUS_ATTRACTBALL ) && (AnguloUsuarioBola[client] < 2.09) ){
    internal_atraerBolaORIGINAL(client);
    //PrintToChatAll("SOCCERMODPRO. Ball attracted");
    //update_player_index(client);
    //PrintToChat(client, " \x01\x0B\x05 SOCCERMODPRO. Ball attracted.");
    //PrintToChat(client, " \x01\x0B\x05 SOCCERMODPRO. Ball attracted v3.");
    animate_player(client, 0);
    clientApretaR[client] = 1;
    PrintToChat(client, " \x01\x0B\x05 SOCCERMODPRO. Ball attracted.");
  }
  else{
    //PrintToChatAll("SOCCERMODPRO. attractBall: Too far.");
  }
}

public Action:Command_attractBallRaise(client, args){
  if (playerTouchingFloor[client] || (playerTouchingFloor[client] == 0 && BallTouchingFloor == 0) ){
    //se puede hacer la elástica
  }else{
      return;
  }


  if ( distPlayerBall[client] < (RADIUS_ATTRACTBALL ) && (AnguloUsuarioBola[client] < 1.79) ){

    new Float:postemp[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", postemp);

    

    new Float:tempCompare = postemp[2] * 100;
    new Float:tempCompare2 = (canchaZ + HEIGHT_ATTRACTBALLRAISE) * 100;

    new tempIntCompare =  RoundFloat(tempCompare);
    new tempIntCompare2 =  RoundFloat(tempCompare2);

    if (tempIntCompare > tempIntCompare2){
      //PrintToChat(client, "SOCCERMODPRO: ANTIBUG. R el. canceled" );
      return;
    }

    //if (postemp[2] > (canchaZ + HEIGHT_ATTRACTBALLRAISE) ){ 

    //}

    //PrintToChatAll("SOCCERMODPRO. Appropiate distance");
    new Float:PosBall[3];
    new Float:PosUser[3];
    new Float:VectorDifference[3];
    GetEntPropVector(Enty, Prop_Send, "m_vecOrigin", PosBall);
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);

    ///
    //PrintToChat(client, "SOCCERMODPRO. Ball attracted  0.");
    new Float:destOrigin[3];
    decl Float:clientOrigin[3];
    decl Float:clientEyeAngles[3];
    GetClientAbsOrigin(client, clientOrigin);
    GetClientEyeAngles(client, clientEyeAngles);
    new Float:cos = Cosine(DegToRad(clientEyeAngles[1]));
    new Float:sin = Sine(DegToRad(clientEyeAngles[1]));
        
    destOrigin[0] = clientOrigin[0] + cos * (SHR_DISTANCE_BETWEEN_PLAYER_AND_BALL + 20);
    destOrigin[1] = clientOrigin[1] + sin * (SHR_DISTANCE_BETWEEN_PLAYER_AND_BALL + 20);
    destOrigin[2] = clientOrigin[2] + SHR_BALL_HOLD_HEIGHT ;

    //PrintToChat(client, "SOCCERMODPRO. Ball attracted  1.");
    //TeleportEntity(enty, orig_ball, NULL_VECTOR, NULL_VECTOR); 
    //TeleportEntity(enty, destOrigin, clientEyeAngles, NULL_VECTOR); //changed.
    ///


    VectorDifference[0] = destOrigin[0] - PosBall[0];
    VectorDifference[1] = destOrigin[1] - PosBall[1];
    VectorDifference[2] = destOrigin[2] - PosBall[2];
    VectorDifference[2] += 270;
    TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, VectorDifference);
    //PrintToChatAll("SOCCERMODPRO. Ball attracted ELASTICA");
    //update_player_index(client);
    //PrintToChat(client, " \x01\x0B\x05 SOCCERMODPRO. Ball attracted ELASTICA");
    animate_player(client, 1);
    clientApretaRELAST[client] = 1;
    PrintToChat(client, " \x01\x0B\x05 SOCCERMODPRO. Ball attracted ELASTICA");
    //PrintToChat(client, " \x01\x0B\x05 SOCCERMODPRO. Ball attracted ELASTICA v3");
  }
}

public internal_detenerBolaPorCompleto(){
      TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, NULL_VELOCITY);
      TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, NULL_VELOCITY);
      AcceptEntityInput(Enty, "Sleep");
}

public Action:Command_stopBall(client, args){
  if(counterSHIFT[client] != 0) return;
  if ( distPlayerBall[client] < RADIUS_STOPBALL && (client != clientGRABBING) && (AnguloUsuarioBola[client] < 1.79) && BallTouchingFloor ){
      //PrintToChatAll("SOCCERMODPRO. Appropiate distance");
      internal_detenerBolaPorCompleto();
      clientApretaSTOP[client] = 1;
      animate_player(client, 0);
      counterSHIFT[client] = SHIFT_COUNTER ;
      PrintToChat(client, " \x01\x0B\x05 SOCCERMODPRO. Ball Stopped");
  }
  else{
    //PrintToChatAll("SOCCERMODPRO. stopBall: Too far.");
  }
}


//-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_-_

public Action:createBrushLeft()
{
      //create brush trigger_push to left to push the ball
      new Float: PosPelota[3];
      GetEntPropVector(Enty, Prop_Send, "m_vecOrigin", PosPelota);

      new Float:AngUserLeft[3];
      AngUserLeft[0] = OriginalAngShooter [0];
      AngUserLeft[1] = OriginalAngShooter [1] + 90.0;
      if ( AngUserLeft[1] > 180.0 ){
        AngUserLeft[1] -= 360.0;
      }
      AngUserLeft[2] = OriginalAngShooter [2];


      new entindex = CreateEntityByName("trigger_push");
      if (entindex != -1)
      {
          //DispatchKeyValue(entindex, "pushdir", "0 0 0");
          DispatchKeyValue(entindex, "speed", "70");
          //DispatchKeyValue(entindex, "spawnflags", "64");
          DispatchKeyValue(entindex, "spawnflags", "8"); //afectar solo a physics no humanos (creo)
      }

      DispatchSpawn(entindex);
      ActivateEntity(entindex);

      TeleportEntity(entindex, PosPelota, AngUserLeft, NULL_VECTOR); //pos ang vel

      SetEntityModel(entindex, "models/props/cs_office/vending_machine.mdl");

      new Float:minbounds[3] = {-300.0, -300.0, 0.0};
      new Float:maxbounds[3] = {300.0, 300.0, 600.0};
      SetEntPropVector(entindex, Prop_Send, "m_vecMins", minbounds);
      SetEntPropVector(entindex, Prop_Send, "m_vecMaxs", maxbounds);
          
      SetEntProp(entindex, Prop_Send, "m_nSolidType", 2);

      new enteffects = GetEntProp(entindex, Prop_Send, "m_fEffects");
      enteffects |= 32;
      //enteffects |= 128; //once only?
      SetEntProp(entindex, Prop_Send, "m_fEffects", enteffects);  

      CreateTimer(0.3, destroyPushCreated, entindex);
}



public Action:createBrushRight(){
      //create brush trigger_push to right to push the ball
      new Float: PosPelota[3];
      GetEntPropVector(Enty, Prop_Send, "m_vecOrigin", PosPelota);

      new Float:AngUserLeft[3];
      AngUserLeft[0] = OriginalAngShooter [0];
      AngUserLeft[1] = OriginalAngShooter [1] - 90.0;
      if ( AngUserLeft[1] < -180.0 ){
        AngUserLeft[1] += 360.0;
      }
      AngUserLeft[2] = OriginalAngShooter [2];


      new entindex = CreateEntityByName("trigger_push");
      if (entindex != -1)
      {
          //DispatchKeyValue(entindex, "pushdir", "0 0 0");
          DispatchKeyValue(entindex, "speed", "70");
          //DispatchKeyValue(entindex, "spawnflags", "64");
          DispatchKeyValue(entindex, "spawnflags", "8"); //afectar solo a physics no humanos (creo)
      }

      DispatchSpawn(entindex);
      ActivateEntity(entindex);

      TeleportEntity(entindex, PosPelota, AngUserLeft, NULL_VECTOR); //pos ang vel

      SetEntityModel(entindex, "models/props/cs_office/vending_machine.mdl");

      new Float:minbounds[3] = {-300.0, -300.0, 0.0};
      new Float:maxbounds[3] = {300.0, 300.0, 600.0};
      SetEntPropVector(entindex, Prop_Send, "m_vecMins", minbounds);
      SetEntPropVector(entindex, Prop_Send, "m_vecMaxs", maxbounds);
          
      SetEntProp(entindex, Prop_Send, "m_nSolidType", 2);

      new enteffects = GetEntProp(entindex, Prop_Send, "m_fEffects");
      enteffects |= 32;
      //enteffects |= 128; //once only?
      SetEntProp(entindex, Prop_Send, "m_fEffects", enteffects);  

      CreateTimer(0.3, destroyPushCreated, entindex);
}

public Action:createBrushUp(){
      //create brush trigger_push to UP to push the ball
      new Float: PosPelota[3];
      GetEntPropVector(Enty, Prop_Send, "m_vecOrigin", PosPelota);

      new Float:AngArriba[3];
      //GetClientEyeAngles(client, AngUser);
      AngArriba[0] = -90.0
      AngArriba[1] = 0.0
      AngArriba[2] = 0.0
      new String:tempst[32];
      new veloc_push_from_altitude = RoundFloat ( maxBallPosAlcanzado ) ;
      new old_vec = veloc_push_from_altitude;
      if (veloc_push_from_altitude > 1100) veloc_push_from_altitude=RoundFloat ( maxBallPosAlcanzado * 0.6 ) ;
      if (old_vec > 1600) veloc_push_from_altitude=RoundFloat ( maxBallPosAlcanzado * 0.8 ) ;
      new entindex = CreateEntityByName("trigger_push");
      if (entindex != -1)
      {
           //time on Air but in string
          IntToString(veloc_push_from_altitude*2, tempst, 32);
          //DispatchKeyValue(entindex, "pushdir", "0 0 0");
          DispatchKeyValue(entindex, "speed", tempst);
          //DispatchKeyValue(entindex, "spawnflags", "64");
          DispatchKeyValue(entindex, "spawnflags", "8"); //afectar solo a physics no humanos (creo)
      }

      DispatchSpawn(entindex);
      ActivateEntity(entindex);

      TeleportEntity(entindex, PosPelota, AngArriba, NULL_VECTOR); //pos ang vel

      SetEntityModel(entindex, "models/props/cs_office/vending_machine.mdl");

      new Float:minbounds[3] = {-300.0, -300.0, 0.0};
      new Float:maxbounds[3] = {300.0, 300.0, 600.0};
      SetEntPropVector(entindex, Prop_Send, "m_vecMins", minbounds);
      SetEntPropVector(entindex, Prop_Send, "m_vecMaxs", maxbounds);
          
      SetEntProp(entindex, Prop_Send, "m_nSolidType", 2);

      new enteffects = GetEntProp(entindex, Prop_Send, "m_fEffects");
      enteffects |= 32;
      //enteffects |= 128; //once only?
      SetEntProp(entindex, Prop_Send, "m_fEffects", enteffects);  
      //PrintToChatAll("Created brush UP %s" , tempst);


      CreateTimer(0.1, destroyPushCreated, entindex);
}



public Action:executeBallPush(client)
{     //executes a ball push in player direction(creating a BRUSH), with the bar associated force (speed actually..)
      //first calculate velocity to set on ball
      new velocityToBall = RoundFloat(  FUERZA_INICIAL_BOLA + ((timeBarraActivated[client] /  DURACION_BARRA) * (FUERZA_MAXIMA_BOLA - FUERZA_INICIAL_BOLA))  );
      
      //PrintToChatAll("timeBarraActivated::  %f" , timeBarraActivated[client] );
      //PrintToChatAll("velocityToBall: %d" , velocityToBall );
      //PrintToChatAll("__");
      if (esArquero[client] && client != clientGRABBING){
        velocityToBall = RoundFloat(6000.0*0.6700);//ex 6000
      }

      //PrintToChatAll("test_curveBall::start_brush ball vel: %d" , velocityToBall );
      
      if (ballCurve[client]){
        //PrintToChatAll("EL JUGADOR TIENE ACTIVADO ballCurve" );
        velocityToBall= RoundFloat(0.88000*velocityToBall);
        //PrintToChatAll("ball force: %d" , velocityToBall );
      }
      else{
        //PrintToChatAll("ball force: %d" , velocityToBall );
      }
      //antes de brush creation, ver si es volea, cnormal o cmordido

      new Float:minbounds[3];
      new Float:maxbounds[3];
      //elTiroEsVolea=4 significa despeje de arquero sin agarrarla en su Area.
      if (elTiroEsVolea >= 1){ //cm cv o volea..
        minbounds[0]= - EQUISVOLEA_PUSH_MITAD;
        minbounds[1]= - YGRIEGAVOLEA_PUSH_MITAD;
        minbounds[2]= 0.0;

        maxbounds[0]= EQUISVOLEA_PUSH_MITAD;
        maxbounds[1]= YGRIEGAVOLEA_PUSH_MITAD;
        maxbounds[2]= ZETAVOLEA_PUSH_MITAD;

        if (elTiroEsVolea == 2){ //cabezazo mordido
          velocityToBall= RoundFloat(1.050*velocityToBall);
          minbounds[0]= - EQUISCABEZAZO_PUSH_MITAD;
          minbounds[1]= - YGRIEGACABEZAZO_PUSH_MITAD;
          minbounds[2]= 0.0;

          maxbounds[0]= EQUISCABEZAZO_PUSH_MITAD;
          maxbounds[1]= YGRIEGACABEZAZO_PUSH_MITAD;
          maxbounds[2]= ZETACABEZAZO_PUSH_MITAD;
        }
        if (elTiroEsVolea == 3){ //cabezazo verdadero
          velocityToBall= RoundFloat(1.150*velocityToBall);
          minbounds[0]= - EQUISCABEZAZO_PUSH_MITAD;
          minbounds[1]= - YGRIEGACABEZAZO_PUSH_MITAD;
          minbounds[2]= 0.0;

          maxbounds[0]= EQUISCABEZAZO_PUSH_MITAD;
          maxbounds[1]= YGRIEGACABEZAZO_PUSH_MITAD;
          maxbounds[2]= ZETACABEZAZO_PUSH_MITAD;
        }
        elTiroEsVolea = 0;
        

        //PrintToChatAll("este push creado es para VOLEA o cabezazo");

      }else{
        minbounds[0]= - EQUIS_PUSH_MITAD;
        minbounds[1]= - YGRIEGA_PUSH_MITAD;
        minbounds[2]= 0.0;

        maxbounds[0]= EQUIS_PUSH_MITAD;
        maxbounds[1]= YGRIEGA_PUSH_MITAD;
        maxbounds[2]= ZETA_PUSH_MITAD;
      }

      //start brush creation
      new Float:playerpos[3];
      GetEntPropVector(client, Prop_Send, "m_vecOrigin", playerpos);

      new Float:AngUser[3];
      GetClientEyeAngles(client, AngUser);

      new entindex = CreateEntityByName("trigger_push");
      if (entindex != -1)
      {
          new String:tempst[32]; //velocity to ball but in string
          IntToString(velocityToBall, tempst, 32);
          //DispatchKeyValue(entindex, "pushdir", "0 0 0");
          DispatchKeyValue(entindex, "speed", tempst);
          //DispatchKeyValue(entindex, "spawnflags", "64");
          DispatchKeyValue(entindex, "spawnflags", "8"); //afectar solo a physics no humanos (creo)
      }

      DispatchSpawn(entindex);
      ActivateEntity(entindex);

      TeleportEntity(entindex, playerpos, AngUser, NULL_VECTOR); //pos ang vel

      SetEntityModel(entindex, "models/props/cs_office/vending_machine.mdl");


      

      SetEntPropVector(entindex, Prop_Send, "m_vecMins", minbounds);
      SetEntPropVector(entindex, Prop_Send, "m_vecMaxs", maxbounds);
          
      SetEntProp(entindex, Prop_Send, "m_nSolidType", 2);

      new enteffects = GetEntProp(entindex, Prop_Send, "m_fEffects");
      enteffects |= 32;
      //enteffects |= 128; //once only?
      SetEntProp(entindex, Prop_Send, "m_fEffects", enteffects);  

      //PrintToChat(client, "test_curveBall::end_brush; vel: %d" , velocityToBall);
      new Float:tiempodur
      if (esArquero[client] == 1 && permitidoSerArquero[client]){
                      tiempodur = 0.20 ; //especial para arqueros
                      //PrintToChat(client, "Arquero la patea del arco, agarrAndola.");
      }
      CreateTimer(tiempodur, destroyPushCreated, entindex);
}





public Action:executeBallPushSOLOARQUERO(client)
{     //executes a ball push in player direction(creating a BRUSH), with the bar associated force (speed actually..)
      //first calculate velocity to set on ball
      //esto corresponde al DESPEJE DE ARQUERO AGARRÁNDOLA
      new velocityToBall = RoundFloat(  FUERZA_INICIAL_BOLA + ((timeBarraActivated[client] /  DURACION_BARRA) * (FUERZA_MAXIMA_BOLA - FUERZA_INICIAL_BOLA))  );
      if (esArquero[client] && client != clientGRABBING){
        velocityToBall = RoundFloat(6000.0*0.6700);//ex 6000
      }

      if (ballCurve[client]){
        //PrintToChatAll("EL JUGADOR TIENE ACTIVADO ballCurve" );
        velocityToBall= RoundFloat(0.77000*velocityToBall);
        //PrintToChatAll("ball force: %d" , velocityToBall );
      }
      else{
        //PrintToChatAll("ball force: %d" , velocityToBall );
      }

      //PrintToChatAll("test_curveBall::start_brush ball vel: %d" , velocityToBall );
      //start brush creation
      new Float:playerpos[3];
      GetEntPropVector(client, Prop_Send, "m_vecOrigin", playerpos);

      new Float:AngUser[3];
      GetClientEyeAngles(client, AngUser);




      new Float:minbounds[3];
      new Float:maxbounds[3];
      if (elTiroEsVolea >= 1){ //cm cv o volea..
        minbounds[0]= - EQUISVOLEA_PUSH_MITAD;
        minbounds[1]= - YGRIEGAVOLEA_PUSH_MITAD;
        minbounds[2]= 0.0;

        maxbounds[0]= EQUISVOLEA_PUSH_MITAD;
        maxbounds[1]= YGRIEGAVOLEA_PUSH_MITAD;
        maxbounds[2]= ZETAVOLEA_PUSH_MITAD;

        elTiroEsVolea = 0;
        
        //PrintToChatAll("este push creado es para VOLEA o cabezazo");
      }else{
        minbounds[0]= - EQUIS_PUSH_MITAD;
        minbounds[1]= - YGRIEGA_PUSH_MITAD;
        minbounds[2]= 0.0;

        maxbounds[0]= EQUIS_PUSH_MITAD;
        maxbounds[1]= YGRIEGA_PUSH_MITAD;
        maxbounds[2]= ZETA_PUSH_MITAD;
      }

      new entindex = CreateEntityByName("trigger_push");
      if (entindex != -1)
      {
          new String:tempst[32]; //velocity to ball but in string
          IntToString(velocityToBall, tempst, 32);
          //DispatchKeyValue(entindex, "pushdir", "0 0 0");
          DispatchKeyValue(entindex, "speed", tempst);
          //DispatchKeyValue(entindex, "spawnflags", "64");
          DispatchKeyValue(entindex, "spawnflags", "8"); //afectar solo a physics no humanos (creo)
      }

      DispatchSpawn(entindex);
      ActivateEntity(entindex);

      TeleportEntity(entindex, playerpos, AngUser, NULL_VECTOR); //pos ang vel

      SetEntityModel(entindex, "models/props/cs_office/vending_machine.mdl");


      

      SetEntPropVector(entindex, Prop_Send, "m_vecMins", minbounds);
      SetEntPropVector(entindex, Prop_Send, "m_vecMaxs", maxbounds);
          
      SetEntProp(entindex, Prop_Send, "m_nSolidType", 2);

      new enteffects = GetEntProp(entindex, Prop_Send, "m_fEffects");
      enteffects |= 32;
      //enteffects |= 128; //once only?
      SetEntProp(entindex, Prop_Send, "m_fEffects", enteffects);  

      //PrintToChat(client, "test_curveBall::end_brush; vel: %d" , velocityToBall);
      new Float:tiempodur
      if (esArquero[client] == 1 && permitidoSerArquero[client]){
                      tiempodur = 0.20 ; //especial para arqueros
                      //PrintToChat(client, "Arquero la patea del arco, agarrAndola.");
      }
      CreateTimer(tiempodur, destroyPushCreated, entindex);
}


//=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_=_

public Action:animate_player(client, number){
  if ( (!IsClientInGame(client)) || (!IsPlayerAlive(client)) ) {
    return;
  }
  if (number == 0){
        //ball attracted.
        //PrintToChatAll("SMP: Anim event. %i --- %i", client, allPlayersAnim[client]);
        TE_Start("PlayerAnimEvent");
        if (animCounter[client] == 0){
          TE_WriteNum("m_hPlayer", allPlayersAnim[client]);
          TE_WriteNum("m_iEvent", 0);
          TE_WriteNum("m_nData", 0);
          
          TE_SendToAll();
          animCounter[client] = PLAYER_ANIM_COUNTER;
        }
  }

  if (number == 1){
        //ball attracted.
        //PrintToChatAll("SMP: Anim event. %i --- %i", client, allPlayersAnim[client]);
        TE_Start("PlayerAnimEvent");
        if (animCounter[client] == 0){
          TE_WriteNum("m_hPlayer", allPlayersAnim[client]);
          TE_WriteNum("m_iEvent", 5);
          TE_WriteNum("m_nData", 0);
          
          TE_SendToAll();
          animCounter[client] = PLAYER_ANIM_COUNTER;
        }
  }
}

public Action:OnPlayerAnimEvent(const String:te_name[], const Players[], numClients, Float:delay)
{
    new client = TE_ReadNum("m_hPlayer");
    //new entityIndex = MakeCompatEntRef(client | ~0x7FFF);  
    new clId = MakeCompatEntRef(client); 
    if (allPlayersAnim[clId] == 0){
      //PrintToChatAll("SMP: Adding. Player: %i clientId: %i", client, clId);
      allPlayersAnim[clId] = client;
    }
}



//-.-.-.-.-. Animación .-.-.-.-.-.-

public Action:Command_Invisible(client, args)
{
    SetEntityRenderMode(client, RENDER_NONE); 
    //PrintToChatAll("render end");
}


public Action:Command_Visible(client, args)
{
    SetEntityRenderMode(client, RENDER_NORMAL); 
    //PrintToChatAll("rendernormal end");
}

//las animaciones propiamente:

public Action:Command_TestCrouch2(client, args)
{    //test BARRIDA.
    //PrintToChatAll("Starting anim- barrida");
    SetEntityRenderMode(client, RENDER_NONE); 
    //PrintToChatAll("render end");
    //get eye angle
    new Float:AngUser[3];
    GetClientEyeAngles(client, AngUser);
    // Get Position
    new Float:pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    //get velocity of user
    new Float:vec[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
    if (IsValidEdict(entidadesanim[client]))
      RemoveParticleNow(entidadesanim[client]); //por si ya estaba ejecutando alguna animación
    entidadesanim[client] = CreateEntityByName("prop_dynamic_override");
    //playerRagdollTest = CreateEntityByName("prop_dynamic_override");
    new String:name[128];
    GetClientModel(client, name, sizeof(name));
    PrecacheModel(name, true);
    //PrintToChatAll("model: %s" , name);


    //CORRECCIÓN PARA QUE SE VEA ARRASTRANDO POR EL SUELO
    //PrintToChatAll("Anguser0: %f", AngUser[0]);
    AngUser[0] = -73.0;
    pos[2]+=2;


    SetEntityModel(entidadesanim[client] , name);
    DispatchSpawn(entidadesanim[client] );
    SetVariantString("deathpose_crouch_back");
    AcceptEntityInput(entidadesanim[client] , "SetAnimation", -1, -1, 0);  
    TeleportEntity(entidadesanim[client], pos, AngUser, vec);  
    //PrintToChatAll("end.- %d", client);
    CreateTimer(0.1, pushPlayerRagdollBARRIDA, client, TIMER_REPEAT);
}

public Action:pushPlayerRagdollBARRIDA(Handle:timer, any:client){
    static numPrinted = 0;
    if (numPrinted >= 13 || ForzarAgache[client] == 0 ) {
      numPrinted = 0;
      SetEntityRenderMode(client, RENDER_NORMAL); 
      //PrintToChatAll("rendernormal end");
      //RemoveParticleNow(playerRagdollTest);
      if (IsValidEdict(entidadesanim[client]))
        RemoveParticleNow(entidadesanim[client]);
      entidadesanim[client] = -1;
      //PrintToChatAll("pushPlayerRagdoll::end");
      return Plugin_Stop;
      //return;
    }
    numPrinted++;
    new Float:pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    new Float:AngUser[3];
    GetClientEyeAngles(client, AngUser);

    if (numPrinted < 10){
        AngUser[0] = -63.0 + (-20 * ( 1.0 - ((10.0 - numPrinted) / 10.0)) ) ;
        //pos[2]+=2;
    }else{
            AngUser[0] = -63.0 * ((16.0-numPrinted) / 7.0) ;
            //pos[2]+=1;
    }


    new Float:vec[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
    //TeleportEntity(playerRagdollTest, pos, AngUser, vec);
    if (IsValidEdict(entidadesanim[client]))
      TeleportEntity(entidadesanim[client], pos, AngUser, vec);
    return Plugin_Continue;
}


public Action:Command_TestCrouch5(client, args)
{   //testing brazada arquero ragdollbrazada3

    //PrintToChatAll("Starting");
    SetEntityRenderMode(client, RENDER_NONE); 
    //PrintToChatAll("render end");
    //get eye angle
    new Float:AngUser[3];
    GetClientEyeAngles(client, AngUser);
    // Get Position
    new Float:pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    //get velocity of user
    new Float:vec[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
    //playerRagdollTest = CreateEntityByName("prop_dynamic_override");
    if (IsValidEdict(entidadesanim[client]))
      RemoveParticleNow(entidadesanim[client]); //por si ya estaba ejecutando alguna animación
    entidadesanim[client] = CreateEntityByName("prop_dynamic_override");
    new String:name[128];
    GetClientModel(client, name, sizeof(name));
    PrecacheModel(name, true);
    //PrintToChatAll("model: %s" , name);

    AngUser[0] = 0.0;

    SetEntityModel(entidadesanim[client] , name);
    DispatchSpawn(entidadesanim[client] );
    SetVariantString("ragdollbrazada3");
    AcceptEntityInput(entidadesanim[client] , "SetAnimation", -1, -1, 0);  
    TeleportEntity(entidadesanim[client], pos, AngUser, vec);  
    //PrintToChatAll("end.-");
    CreateTimer(0.10, pushPlayerRagdollBRAZADA, client, TIMER_REPEAT);
}

public Action:pushPlayerRagdollBRAZADA(Handle:timer, any:client){
    static numPrinted = 0;
    if (numPrinted >= 4) {
      numPrinted = 0;
      SetEntityRenderMode(client, RENDER_NORMAL); 
      //PrintToChatAll("rendernormal end");
      //RemoveParticleNow(playerRagdollTest);
      if (IsValidEdict(entidadesanim[client]))
        RemoveParticleNow(entidadesanim[client]);
      entidadesanim[client] = -1;
      //PrintToChatAll("pushPlayerRagdoll::end");
      return Plugin_Stop;
      //return;
    }
    numPrinted++;
    new Float:pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    new Float:AngUser[3];
    GetClientEyeAngles(client, AngUser);

    AngUser[0] = 0.0;

    new Float:vec[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
    TeleportEntity(entidadesanim[client], pos, AngUser, vec);
    return Plugin_Continue;
}


public Action:Command_TestCrouch7(client, args)
{   //testing playanim3 (brazada izq)
    //PrintToChatAll("Starting playanim2");
    SetEntityRenderMode(client, RENDER_NONE); 
    //PrintToChatAll("render end");
    //get eye angle
    new Float:AngUser[3];
    GetClientEyeAngles(client, AngUser);
    // Get Position
    new Float:pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    //get velocity of user
    new Float:vec[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
    //playerRagdollTest = CreateEntityByName("prop_dynamic_override");
    if (IsValidEdict(entidadesanim[client]))
      RemoveParticleNow(entidadesanim[client]); //por si ya estaba ejecutando alguna animación
    entidadesanim[client] = CreateEntityByName("prop_dynamic_override");
    new String:name[128];
    GetClientModel(client, name, sizeof(name));
    PrecacheModel(name, true);
    //PrintToChatAll("model: %s" , name);

    AngUser[0] = 0.0;

    SetEntityModel(entidadesanim[client] , name);
    DispatchSpawn(entidadesanim[client] );
    SetVariantString("playanim2arb");
    AcceptEntityInput(entidadesanim[client] , "SetAnimation", -1, -1, 0);  
    TeleportEntity(entidadesanim[client], pos, AngUser, vec);  
    //PrintToChatAll("end. playanim2-");
    CreateTimer(0.10, pushPlayerRagdollATAJAIZQ, client, TIMER_REPEAT);
}


public Action:Command_PiernitasDer(client, args)
{   //testing playanim1 ( patada )
    //PrintToChatAll("Starting playanim1");
    SetEntityRenderMode(client, RENDER_NONE); 
    //PrintToChatAll("render end");
    //get eye angle
    new Float:AngUser[3];
    GetClientEyeAngles(client, AngUser);
    // Get Position
    new Float:pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    //get velocity of user
    new Float:vec[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
    //playerRagdollTest = CreateEntityByName("prop_dynamic_override");
    if (IsValidEdict(entidadesanim[client]))
      RemoveParticleNow(entidadesanim[client]); //por si ya estaba ejecutando alguna animación
    entidadesanim[client] = CreateEntityByName("prop_dynamic_override");
    new String:name[128];
    GetClientModel(client, name, sizeof(name));
    PrecacheModel(name, true);
    //PrintToChatAll("model: %s" , name);



    /////////////////////////
    new Float:orig_ball[3];
    GetClientAbsOrigin(client,orig_ball);
    
    new Float:PosUser[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);
    

    new Float:destOrigin[3];
    decl Float:clientOrigin[3];
    GetClientAbsOrigin(client, clientOrigin);
    decl Float:clientEyeAngles[3];
    GetClientEyeAngles(client, clientEyeAngles);
    new Float:cos = Cosine(DegToRad(clientEyeAngles[1]));
    new Float:sin = Sine(DegToRad(clientEyeAngles[1]));
    
    destOrigin[0] = clientOrigin[0] + cos * (-25.0) ;
    destOrigin[1] = clientOrigin[1] + sin * (-25.0) ;
    destOrigin[2] = clientOrigin[2] ;
    /////////////////////////


    esAnimPatada[client] = 1;
    //new Float:posABS[3];
    //GetClientAbsAngles(client, posABS);

    //PrintToChatAll("%f %f %f" , posABS[0], posABS[1], posABS[2]);

    AngUser[0] = 0.0;

    SetEntityModel(entidadesanim[client] , name);
    DispatchSpawn(entidadesanim[client] );
    SetVariantString("playanim4arb");
    AcceptEntityInput(entidadesanim[client] , "SetAnimation", -1, -1, 0);  
    TeleportEntity(entidadesanim[client], destOrigin, AngUser, NULL_VECTOR);  
    //PrintToChatAll("end. playanim1-");
    CreateTimer(0.30, pushPlayerRagdollPATADA, client, TIMER_REPEAT);
}

public Action:Command_PiernitasIzq(client, args)
{   //testing playanim1 ( patada )
    //PrintToChatAll("Starting playanim1");
    SetEntityRenderMode(client, RENDER_NONE); 
    //PrintToChatAll("render end");
    //get eye angle
    new Float:AngUser[3];
    GetClientEyeAngles(client, AngUser);
    // Get Position
    new Float:pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    //get velocity of user
    new Float:vec[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
    //playerRagdollTest = CreateEntityByName("prop_dynamic_override");
    if (IsValidEdict(entidadesanim[client]))
      RemoveParticleNow(entidadesanim[client]); //por si ya estaba ejecutando alguna animación
    entidadesanim[client] = CreateEntityByName("prop_dynamic_override");
    new String:name[128];
    GetClientModel(client, name, sizeof(name));
    PrecacheModel(name, true);
    //PrintToChatAll("model: %s" , name);



    /////////////////////////
    new Float:orig_ball[3];
    GetClientAbsOrigin(client,orig_ball);
    
    new Float:PosUser[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);
    

    new Float:destOrigin[3];
    decl Float:clientOrigin[3];
    GetClientAbsOrigin(client, clientOrigin);
    decl Float:clientEyeAngles[3];
    GetClientEyeAngles(client, clientEyeAngles);
    new Float:cos = Cosine(DegToRad(clientEyeAngles[1]));
    new Float:sin = Sine(DegToRad(clientEyeAngles[1]));
    
    destOrigin[0] = clientOrigin[0] + cos * (-25.0) ;
    destOrigin[1] = clientOrigin[1] + sin * (-25.0) ;
    destOrigin[2] = clientOrigin[2] ;
    /////////////////////////


    esAnimPatada[client] = 1;
    //new Float:posABS[3];
    //GetClientAbsAngles(client, posABS);

    //PrintToChatAll("%f %f %f" , posABS[0], posABS[1], posABS[2]);

    AngUser[0] = 0.0;

    SetEntityModel(entidadesanim[client] , name);
    DispatchSpawn(entidadesanim[client] );
    SetVariantString("playanim5arb");
    AcceptEntityInput(entidadesanim[client] , "SetAnimation", -1, -1, 0);  
    TeleportEntity(entidadesanim[client], destOrigin, AngUser, NULL_VECTOR);  
    //PrintToChatAll("end. playanim1-");
    CreateTimer(0.30, pushPlayerRagdollPATADA, client, TIMER_REPEAT);
}

public Action:Command_TestCrouch8(client, args)
{   //testing playanim4 (brazada der)
    //PrintToChatAll("Starting playanim3");
    SetEntityRenderMode(client, RENDER_NONE); 
    //PrintToChatAll("render end");
    //get eye angle
    new Float:AngUser[3];
    GetClientEyeAngles(client, AngUser);
    // Get Position
    new Float:pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    //get velocity of user
    new Float:vec[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
    //playerRagdollTest = CreateEntityByName("prop_dynamic_override");
    if (IsValidEdict(entidadesanim[client]))
      RemoveParticleNow(entidadesanim[client]); //por si ya estaba ejecutando alguna animación
    entidadesanim[client] = CreateEntityByName("prop_dynamic_override");
    new String:name[128];
    GetClientModel(client, name, sizeof(name));
    PrecacheModel(name, true);
    //PrintToChatAll("model: %s" , name);

    AngUser[0] = 0.0;

    SetEntityModel(entidadesanim[client] , name);
    DispatchSpawn(entidadesanim[client] );
    SetVariantString("playanim3arb");
    AcceptEntityInput(entidadesanim[client] , "SetAnimation", -1, -1, 0);  
    TeleportEntity(entidadesanim[client], pos, AngUser, vec);  
    //PrintToChatAll("end. playanim3-");
    CreateTimer(0.10, pushPlayerRagdollATAJADER, client, TIMER_REPEAT);
}


public Action:pushPlayerRagdollATAJAIZQ(Handle:timer, any:client){
    static numPrinted = 0;
    if (numPrinted >= 8) {
      numPrinted = 0;
      SetEntityRenderMode(client, RENDER_NORMAL); 
      //PrintToChatAll("rendernormal end");
      if (IsValidEdict(entidadesanim[client]))
        RemoveParticleNow(entidadesanim[client]);
      entidadesanim[client] = -1;
      //PrintToChatAll("pushPlayerRagdoll::end");
      return Plugin_Stop;
      //return;
    }
    numPrinted++;
    new Float:pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    new Float:AngUser[3];
    GetClientEyeAngles(client, AngUser);

    AngUser[0] = 0.0;

    new Float:vec[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
    TeleportEntity(entidadesanim[client], pos, AngUser, vec);
    return Plugin_Continue;
}

public Action:pushPlayerRagdollATAJADER(Handle:timer, any:client){
    static numPrinted = 0;
    if (numPrinted >= 8) {
      numPrinted = 0;
      SetEntityRenderMode(client, RENDER_NORMAL); 
      //PrintToChatAll("rendernormal end");
      if (IsValidEdict(entidadesanim[client]))
        RemoveParticleNow(entidadesanim[client]);
      entidadesanim[client] = -1;
      //PrintToChatAll("pushPlayerRagdoll::end");
      return Plugin_Stop;
      //return;
    }
    numPrinted++;
    new Float:pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    new Float:AngUser[3];
    GetClientEyeAngles(client, AngUser);

    AngUser[0] = 0.0;

    new Float:vec[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
    TeleportEntity(entidadesanim[client], pos, AngUser, vec);
    return Plugin_Continue;
}


public Action:Command_TestCrouch9(client, args)
{   //testing Flinch_HeadBack
    //PrintToChatAll("Starting Flinch Head Back");
    SetEntityRenderMode(client, RENDER_NONE); 
    //PrintToChatAll("render end");
    //get eye angle
    new Float:AngUser[3];
    GetClientEyeAngles(client, AngUser);
    // Get Position
    new Float:pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    //get velocity of user
    new Float:vec[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
    //playerRagdollTest = CreateEntityByName("prop_dynamic_override");
    if (IsValidEdict(entidadesanim[client]))
      RemoveParticleNow(entidadesanim[client]); //por si ya estaba ejecutando alguna animación
    entidadesanim[client] = CreateEntityByName("prop_dynamic_override");
    new String:name[128];
    GetClientModel(client, name, sizeof(name));
    PrecacheModel(name, true);
    //PrintToChatAll("model: %s" , name);

    //PrintHintTextToAll("%f %f \n      %f", AngUser[0], AngUser[1], AngUser[2])

    //anguser 0 sería , en GetClientEyeAngles , cielo-infierno , pero en TeleportEntity es rotación cuerpo lateralmente
    //AngUser[1]+=90.0; //esta anim está torcida 90° en el sentido arcos-ulreth-puerta
    //AngUser[2] = 0.0; //AngUser[0];
    AngUser[0] = 0.0;
    AngUser[1] +=90.0;

    //AngUser[0] *= -1.0;
    //AngUser[0] = DegToRad(AngUser[0]);
    //AngUser[1] = DegToRad(AngUser[1] + 90.0); 


    SetEntityModel(entidadesanim[client] , name);
    DispatchSpawn(entidadesanim[client] );
    SetVariantString("Flinch_HeadBack");
    AcceptEntityInput(entidadesanim[client] , "SetAnimation", -1, -1, 0);  
    TeleportEntity(entidadesanim[client], pos, AngUser, vec);  
    //PrintToChatAll("end. Flinch_HeadBack-");
    CreateTimer(0.10, pushPlayerRagdollCABEZAZO, client, TIMER_REPEAT);
}



public Action:pushPlayerRagdollCABEZAZO(Handle:timer, any:client){
    static numPrinted = 0;
    if (numPrinted >= 2) {
      numPrinted = 0;
      SetEntityRenderMode(client, RENDER_NORMAL); 
      //PrintToChatAll("rendernormal end");
      if (IsValidEdict(entidadesanim[client]))
        RemoveParticleNow(entidadesanim[client]);
      entidadesanim[client] = -1;
      //PrintToChatAll("pushPlayerRagdollCABEZAZO::end");
      return Plugin_Stop;
      //return;
    }
    numPrinted++;
    new Float:pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    new Float:AngUser[3];
    GetClientEyeAngles(client, AngUser);

    //AngUser[1]+=90.0; //esta anim está torcida 90° en el sentido arcos-ulreth-puerta
    //AngUser[2] = 0.0; //AngUser[0];
    AngUser[0] = 0.0;
    AngUser[1] +=90.0;
    //if (AngUser[1] > 0 )

    //AngUser[0] *= -1.0;
    //AngUser[1] = AngUser[1] + 90.0;

    new Float:vec[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
    TeleportEntity(entidadesanim[client], pos, AngUser, vec);
    return Plugin_Continue;
}



public Action:Command_TestCrouch6(client, args)
{   //testing playanim1 ( patada )
    //PrintToChatAll("Starting playanim1");
    SetEntityRenderMode(client, RENDER_NONE); 
    //PrintToChatAll("render end");
    //get eye angle
    new Float:AngUser[3];
    GetClientEyeAngles(client, AngUser);
    // Get Position
    new Float:pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    //get velocity of user
    new Float:vec[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
    //playerRagdollTest = CreateEntityByName("prop_dynamic_override");
    if (IsValidEdict(entidadesanim[client]))
      RemoveParticleNow(entidadesanim[client]); //por si ya estaba ejecutando alguna animación
    entidadesanim[client] = CreateEntityByName("prop_dynamic_override");
    new String:name[128];
    GetClientModel(client, name, sizeof(name));
    PrecacheModel(name, true);
    //PrintToChatAll("model: %s" , name);



    /////////////////////////
    new Float:orig_ball[3];
    GetClientAbsOrigin(client,orig_ball);
    
    new Float:PosUser[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);
    

    new Float:destOrigin[3];
    decl Float:clientOrigin[3];
    GetClientAbsOrigin(client, clientOrigin);
    decl Float:clientEyeAngles[3];
    GetClientEyeAngles(client, clientEyeAngles);
    new Float:cos = Cosine(DegToRad(clientEyeAngles[1]));
    new Float:sin = Sine(DegToRad(clientEyeAngles[1]));
    
    destOrigin[0] = clientOrigin[0] + cos * (-25.0) ;
    destOrigin[1] = clientOrigin[1] + sin * (-25.0) ;
    destOrigin[2] = clientOrigin[2] ;
    /////////////////////////


    esAnimPatada[client] = 1;
    //new Float:posABS[3];
    //GetClientAbsAngles(client, posABS);

    //PrintToChatAll("%f %f %f" , posABS[0], posABS[1], posABS[2]);

    AngUser[0] = 0.0;

    SetEntityModel(entidadesanim[client] , name);
    DispatchSpawn(entidadesanim[client] );
    SetVariantString("playanim1arb");
    AcceptEntityInput(entidadesanim[client] , "SetAnimation", -1, -1, 0);  
    TeleportEntity(entidadesanim[client], destOrigin, AngUser, NULL_VECTOR);  
    //PrintToChatAll("end. playanim1-");
    CreateTimer(0.10, pushPlayerRagdollPATADA, client, TIMER_REPEAT);
}

public Action:pushPlayerRagdollPATADA(Handle:timer, any:client){
    static numPrinted = 0;
    if (numPrinted >= 3) {
      numPrinted = 0;
      SetEntityRenderMode(client, RENDER_NORMAL); 
      //PrintToChatAll("rendernormal end");
      if (IsValidEdict(entidadesanim[client]))
        RemoveParticleNow(entidadesanim[client]);
      entidadesanim[client] = -1;
      //PrintToChatAll("pushPlayerRagdoll::end");
      esAnimPatada[client] = 0;
      return Plugin_Stop;
      //return;
    }
    esAnimPatada[client] = 1;
    numPrinted++;
    new Float:pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    new Float:AngUser[3];
    GetClientEyeAngles(client, AngUser);

    AngUser[0] = 0.0;

    /////////////////////////
    new Float:orig_ball[3];
    GetClientAbsOrigin(client,orig_ball);
    
    new Float:PosUser[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", PosUser);
    

    new Float:destOrigin[3];
    decl Float:clientOrigin[3];
    GetClientAbsOrigin(client, clientOrigin);
    decl Float:clientEyeAngles[3];
    GetClientEyeAngles(client, clientEyeAngles);
    new Float:cos = Cosine(DegToRad(clientEyeAngles[1]));
    new Float:sin = Sine(DegToRad(clientEyeAngles[1]));
    
    destOrigin[0] = clientOrigin[0] + cos * (-25.0) ;
    destOrigin[1] = clientOrigin[1] + sin * (-25.0) ;
    destOrigin[2] = clientOrigin[2] ;
    /////////////////////////

    new Float:vec[3];
    GetEntPropVector(client, Prop_Data, "m_vecVelocity", vec);
    if (entidadesanim[client] != 0){
          TeleportEntity(entidadesanim[client], destOrigin, AngUser, NULL_VECTOR);
    }
    return Plugin_Continue;
}


//cuchillo y afines

        
public Action:ChangeModelIndex(Handle:Timer, any:Client)
{
  if (IsValidEdict(Client) && IsClientInGame(Client)){
    new ActiveWeapon = GetEntPropEnt(Client, Prop_Data, "m_hActiveWeapon");
    decl String:sWeapon[64];
    GetEdictClassname(ActiveWeapon, sWeapon, sizeof(sWeapon));
    //PrintToChatAll("test_knife3: changing weapon.");
    if(StrEqual(sWeapon, "weapon_knife"))
    {
      //PrintToChatAll("test_knife3: set weapon.");
      SetEntProp(ActiveWeapon, Prop_Send, "m_iWorldModelIndex", g_iWorldModel);
    }
    //PrintToChatAll("test_knife3: done weapon.");
  }

}



public Action:Command_RemoveKnife3p(client, args)
{
  //PrintToChatAll("test_knife2: about to perform.");
  CreateTimer(0.8, ChangeModelIndex, client);
} 


public Action:Event_PlayerTeam(Handle:event, const String:name[], bool:dontBroadcast){
      //Round End
      new client = GetClientOfUserId(GetEventInt(event, "userid"));
      if (IsValidEdict(client) && IsClientInGame(client)){
              if (jugadorPreparado[client])
                 return Plugin_Continue;
              Soltar_Bola(99,client);
              Command_DEF(client,0);
              //PrintToChat(client, " \x01\x0B\x05 SOCCERMODPRO. Changed Team.");
              PrintToChat(client, " \x01\x0B\x05 SOCCERMODPRO. Changed Team.");
              Command_RemoveKnife3p(client,0);
              CreateTimer(1.0, TIMERCommand_DEF, client);
              CreateTimer(1.0, ponerModelo, client);
      }
      return Plugin_Continue;
}


public Action:Command_JoinTeam(client, const String:command[], argc) 
{
      if (jugadorPreparado[client])
        return Plugin_Continue;
      //new client = GetClientOfUserId(GetEventInt(event, "userid"));
      Soltar_Bola(99,client);
      Command_DEF(client,0);
      //PrintToChat(client, " \x01\x0B\x05 SOCCERMODPRO. Changed Team.");
      PrintToChat(client, " \x01\x0B\x05 SOCCERMODPRO. Changed Team.");
      Command_RemoveKnife3p(client,0);
      CreateTimer(1.0, TIMERCommand_DEF, client);
      CreateTimer(1.0, ponerModelo, client);

      return Plugin_Continue;
}

public OnClientPutInServer(client){
  //SDKHook(client, SDKHook_PreThinkPost, PreThinkPostHook); //ANTIBUG PODRIA DESCOMENTARSE
  CreateTimer(15.0, ponerModelo, client); // You could also use GetClientUserId(client)
}

public OnClientDisconnect(client){
      Command_Limpiarimg(client,0);
      new i = client;
      VARIABLE_DISTANCE_BETWEEN_PLAYER_AND_BALL[i] = 0.0;
      VARIABLE_ATTRACTBALL_MULTIPLIER[i] = 0.0;
      VARIABLE_BALL_HOLD_HEIGHT[i] = 0.0;
      debeSoltarBola[i] = 0;
      grabbingBall[i] = 0;
      CounterSoltar[i] = 0;
      acabaDeSalir[i] = 0;
      tipoMovActual[i] = 0;
      contadorLento[i] = -1;


      esArquero[i] = 0;
      esDefensor[i] = 0;
      esMidfielder[i] = 0;
      esForward[i] = 0;


      G_key_pressed[i] = 0;
      G_counter_enlentecer[i] = 0;
      G_time_to_use_again[i] = 0;
      latencia_en_uso[i] = 0;
      latencia_en_shift[i] = 0;
      apretaIZQ[i] = 0;
      apretaDER[i] = 0;

      esAnimPatada[i] = 0;


      fuerzaClick[i] = FUERZA_INICIAL_BOLA;
      frameSkippedCounter[i] = 0;
      ballCurve[i] = 0;
      timeBarraCreated[i] = 0.0;
      timeBarraActivated[i] = 0.0;

      clientTieneBarra[i] = 0;

      AnguloUsuarioBola[i] = 0.0;
      distPlayerBall[i] = 0.0;

      playerTouchingFloor[i] = 0;
      animCounter[i] = 0;
      allPlayersAnim[i] = 0;
      rCounter[i] = 0;
      rELASTCounter[i] = 0;
      controlBTNCounter[i] = 0;
      //esArquero[i] = 0;
      permitidoSerArquero[i] = 0;
      counterVanishGK[i] = 600;
      numPrintedParaArquero[i] = 0;
      moviendoHaciaAtras[i] = 0;
      moviendoHaciaAdelante[i] = 0;
      clientEjecutaAttack[i] = 0;
      clientEjecutaPATADA[i] = 0;
      clientApretaR[i] = 0;
      clientApretaRELAST[i] = 0;
      clientApretaSTOP[i] = 0;
      clientLaQuita[i] = 0;
      ForzarAgache[i] = 0;
      latencia_DUCK[i] = 0;

      CounterSoltar[i] = 0;
      debeSoltarBola[i] = 1; //stop grab ball
      acabaDeSalir[i] = 0;

      jugadorPreparado[i] = 0;

      G_internalcounter[i] = 0;

      clienteAtajadasTotales[i] = 0;
      clienteQuitesTotales[i] = 0;

      counterClickIzquierdo[i] = 0;

}

public Action:ponerModelo(Handle:timer, any:client){
  if (IsValidEdict(client) && IsClientInGame(client)){
    Command_DEF(client,0);
    PrintToChat(client,"Choose a position (!gk, !df, !mf, !fw) to play.");  
    jugadorPreparado[client] = 1;
  }
  
}

public Action:finish_Game_ev(Handle:event, const String:name[], bool:dontBroadcast)
{
      for(new i = 1; i < MAXPLAYERS; i++)
      {
        new client = i;
        if(client > 0 && IsClientInGame(client) )
        {
          PrintToChat(client, "SMP: Map end. Thanks for playing.");
          PrintToConsole(client, "SMP: Map end. Thanks for playing.");
          ReplyToCommand(client, "SMP: Map end. Thanks for playing.");
          Command_Ponerimg(client,0);
          poniendoIMGLOGO=160;
        }
      }
}

public Action:Command_PonerArbHub1(client, num)
{
    ClearScreen(client);
    if (num == 1)
      ClientCommand(client, "r_screenoverlay \"overlays/smp/iconost1.vtf\"");
    if (num == 2)
      ClientCommand(client, "r_screenoverlay \"overlays/smp/iconost2.vtf\"");
    if (num == 3)
      ClientCommand(client, "r_screenoverlay \"overlays/smp/iconost3.vtf\"");
    if (num == 4)
      ClientCommand(client, "r_screenoverlay \"overlays/smp/iconost4.vtf\"");
    if (num == 5)
      ClientCommand(client, "r_screenoverlay \"overlays/smp/iconost5.vtf\"");
    if (num == 6)
      ClientCommand(client, "r_screenoverlay \"overlays/smp/iconost6.vtf\"");
    //PrintToChat(client, "%d" , num);
}

public Action:Command_Ponerimg(client, args)
{
    ClearScreen(client);
    poniendoIMGLOGO=30;
    ShowKillMessage(client);
}

public Action:Command_Limpiarimg(client, args)
{
    ClearScreen(client);
}

public ShowKillMessage(client)
{
    ClientCommand(client, "r_screenoverlay \"overlays/smp/barra99.vtf\"");
}

public ClearScreen(client)
{
    ClientCommand(client, "r_screenoverlay \"\"");
}

public PrepareOverlays()
{
    new String:overlays_file[64];

    Format(overlays_file,sizeof(overlays_file),"overlays/smp/barra99.vtf");
    PrecacheDecal(overlays_file,true);
    AddFileToDownloadsTable("materials/overlays/smp/barra99.vtf");

    Format(overlays_file,sizeof(overlays_file),"overlays/smp/barra99.vmt");
    PrecacheDecal(overlays_file,true);
    AddFileToDownloadsTable("materials/overlays/smp/barra99.vmt");

    Format(overlays_file,sizeof(overlays_file),"overlays/smp/iconost1.vtf");
    PrecacheDecal(overlays_file,true);
    AddFileToDownloadsTable("materials/overlays/smp/iconost1.vtf");

    Format(overlays_file,sizeof(overlays_file),"overlays/smp/iconost1.vmt");
    PrecacheDecal(overlays_file,true);
    AddFileToDownloadsTable("materials/overlays/smp/iconost1.vmt");

    Format(overlays_file,sizeof(overlays_file),"overlays/smp/iconost2.vtf");
    PrecacheDecal(overlays_file,true);
    AddFileToDownloadsTable("materials/overlays/smp/iconost2.vtf");

    Format(overlays_file,sizeof(overlays_file),"overlays/smp/iconost2.vmt");
    PrecacheDecal(overlays_file,true);
    AddFileToDownloadsTable("materials/overlays/smp/iconost2.vmt");

    Format(overlays_file,sizeof(overlays_file),"overlays/smp/iconost3.vtf");
    PrecacheDecal(overlays_file,true);
    AddFileToDownloadsTable("materials/overlays/smp/iconost3.vtf");

    Format(overlays_file,sizeof(overlays_file),"overlays/smp/iconost3.vmt");
    PrecacheDecal(overlays_file,true);
    AddFileToDownloadsTable("materials/overlays/smp/iconost3.vmt");

    Format(overlays_file,sizeof(overlays_file),"overlays/smp/iconost4.vtf");
    PrecacheDecal(overlays_file,true);
    AddFileToDownloadsTable("materials/overlays/smp/iconost4.vtf");

    Format(overlays_file,sizeof(overlays_file),"overlays/smp/iconost4.vmt");
    PrecacheDecal(overlays_file,true);
    AddFileToDownloadsTable("materials/overlays/smp/iconost4.vmt");

    Format(overlays_file,sizeof(overlays_file),"overlays/smp/iconost5.vtf");
    PrecacheDecal(overlays_file,true);
    AddFileToDownloadsTable("materials/overlays/smp/iconost5.vtf");

    Format(overlays_file,sizeof(overlays_file),"overlays/smp/iconost5.vmt");
    PrecacheDecal(overlays_file,true);
    AddFileToDownloadsTable("materials/overlays/smp/iconost5.vmt");

    Format(overlays_file,sizeof(overlays_file),"overlays/smp/iconost6.vtf");
    PrecacheDecal(overlays_file,true);
    AddFileToDownloadsTable("materials/overlays/smp/iconost6.vtf");

    Format(overlays_file,sizeof(overlays_file),"overlays/smp/iconost6.vmt");
    PrecacheDecal(overlays_file,true);
    AddFileToDownloadsTable("materials/overlays/smp/iconost6.vmt");
}  

//UnlockConsoleCommandAndConvar by AtomicStryker, http://forums.alliedmods.net/showpost.php?p=1318884&postcount=7
UnlockConsoleCommandAndConvar(const String:command[])
{
    new flags = GetCommandFlags(command);
    if (flags != INVALID_FCVAR_FLAGS)
    {
        SetCommandFlags(command, flags & ~FCVAR_CHEAT);
    }
    
    new Handle:cvar = FindConVar(command);
    if (cvar != INVALID_HANDLE)
    {
        flags = GetConVarFlags(cvar);
        SetConVarFlags(cvar, flags & ~FCVAR_CHEAT);
    }
}  


public Action:Command_Freezeall(client, args)
{
  for (new i=1 ; i < MAXPLAYERS ; i++)
  {
    if (i != client && IsClientInGame(i) ) FreezePlayer(i);
  }
  TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, NULL_VELOCITY);
  TeleportEntity(Enty, NULL_VECTOR, NULL_VECTOR, NULL_VELOCITY);
  AcceptEntityInput(Enty, "Sleep");
}


public Action:Command_FreezeTT10SEC(client, args)
{
  for (new i=1 ; i < MAXPLAYERS ; i++){
    if (IsClientInGame(i) && GetClientTeam(i)==2 ) FreezePlayer(i);
  }
  PrintToChatAll("TT are Frozen for 10sec.");
  CreateTimer(10.0, UnfreezeTimer);
}

public Action:Command_FreezeCT10SEC(client, args)
{
  for (new i=1 ; i < MAXPLAYERS ; i++){
    if (IsClientInGame(i) && GetClientTeam(i)==3 ) FreezePlayer(i);
  }
  PrintToChatAll("CT are Frozen for 10sec.");
  CreateTimer(10.0, UnfreezeTimer);
}

public Action:UnfreezeTimer(Handle:timer){
  Command_UNFreezeall(1,0);
  //PrintToChatAll("All players unfreezed.");
  return Plugin_Stop;
}


public Action:Command_UNFreezeall(client, args)
{
  for (new i=1 ; i < MAXPLAYERS ; i++){
    if (IsClientInGame(i) ) UnFreezePlayer(i);
  }
  PrintToChatAll("All players unfreezed.");
  AcceptEntityInput(Enty, "Wake");
}



public FreezePlayer(client)
{
    SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 0.0);
    SetEntityRenderColor(client, 255, 0, 170, 174);
}

public UnFreezePlayer(client)
{
    SetEntPropFloat(client, Prop_Data, "m_flLaggedMovementValue", 1.0);
    SetEntityRenderColor(client, 255, 255, 255, 255);
}  


public Action:Command_SpawnBallSMP(client, args)
{
    FindBallRound = 1;
    new EntA;
    new Float:pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    pos[2] += 100;
    EntA = CreateEntityByName("prop_physics");
    PrecacheModel(physball_model_name);
    DispatchKeyValue(EntA, "model", physball_model_name);
    PrintToChatAll(" \x01\x0B\x05 SOCCERMODPRO. Ball spawned.");
    //DispatchKeyValue(Enty, "targetname", "ball_createdy");
    DispatchSpawn(EntA);
    TeleportEntity(EntA, pos, NULL_VECTOR, NULL_VECTOR);
    if (IsValidEntity(EntA)){
      Enty = EntA;
    }
}

public Action:Command_Spawncanion(client, args)
{
    FindBallRound = 1;
    new EntA;
    new Float:pos[3];
    GetEntPropVector(client, Prop_Send, "m_vecOrigin", pos);
    pos[2] += 100;
    EntA = CreateEntityByName("prop_physics");
    PrecacheModel("models/player/soccermod/canion/canion.mdl");
    DispatchKeyValue(EntA, "model", "models/player/soccermod/canion/canion.mdl");
    PrintToChatAll(" \x01\x0B\x05 SOCCERMODPRO. Cannon spawned.");
    //DispatchKeyValue(Enty, "targetname", "ball_createdy");
    DispatchSpawn(EntA);
    TeleportEntity(EntA, pos, NULL_VECTOR, NULL_VECTOR);
}


public OnGameFrame(){

  for (new x = 1; x < MAXPLAYERS; x++)
  {
    if (IsValidEntity(x))
      if (IsClientInGame(x) && IsPlayerAlive(x))
      {
      if (IsValidEdict(entidadesanim[x]) ){
        //su animación del x, hay que teleportearlo a su posición para que se vea más suave.
        new Float:pos[3];
        GetEntPropVector(x, Prop_Send, "m_vecOrigin", pos);
        if (esAnimPatada[x]){

          /////////////////////////
          new Float:orig_ball[3];
          GetClientAbsOrigin(x,orig_ball);
          
          new Float:destOrigin[3];
          decl Float:clientOrigin[3];
          GetClientAbsOrigin(x, clientOrigin);
          decl Float:clientEyeAngles[3];
          GetClientEyeAngles(x, clientEyeAngles);
          new Float:cos = Cosine(DegToRad(clientEyeAngles[1]));
          new Float:sin = Sine(DegToRad(clientEyeAngles[1]));
          
          destOrigin[0] = clientOrigin[0] + cos * (-25.0) ;
          destOrigin[1] = clientOrigin[1] + sin * (-25.0) ;
          destOrigin[2] = clientOrigin[2] ;
          /////////////////////////


          TeleportEntity(entidadesanim[x], destOrigin, NULL_VECTOR, NULL_VECTOR);
        }
        else{
          TeleportEntity(entidadesanim[x], pos, NULL_VECTOR, NULL_VECTOR);
        }
      }
      FuncionControles(x);
      }
  }
}


