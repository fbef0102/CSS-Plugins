#pragma semicolon 1
#pragma newdecls required
#include <sourcemod>
#include <regex>
#define PLUGIN_VERSION			"1.0-2024/4/7"
#define DEBUG 0

public Plugin myinfo =
{
	name = "[CSS/CSGO] auto restart",
	author = "Harry Potter, HatsuneImagin",
	description = "Make server restart (Force crash) when the last player disconnects from the server",
	version = PLUGIN_VERSION,
	url	= "https://steamcommunity.com/profiles/76561198026784913"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion test = GetEngineVersion();

	if( test != Engine_CSS && test != Engine_CSGO )
	{
		strcopy(error, err_max, "Plugin only supports CSS & CSGO.");
		return APLRes_SilentFailure;
	}

	return APLRes_Success;
}

#define CVAR_FLAGS			FCVAR_NOTIFY

Handle COLD_DOWN_Timer;

bool 
	g_bNoOneInServer, 
	g_bFirstMap, 
	g_bAnyoneConnectedBefore;

char
	g_sPath[256];

public void OnPluginStart()
{
	HookEvent("player_disconnect", Event_PlayerDisconnect, EventHookMode_Pre);	

	RegAdminCmd("sm_crash", Cmd_RestartServer, ADMFLAG_ROOT, "sm_crash - manually force the server to crash");

	g_bFirstMap = true;

	BuildPath(Path_SM, g_sPath, sizeof(g_sPath), "logs/empty_server_restart.log");
}

public void OnPluginEnd()
{
	delete COLD_DOWN_Timer;
}

public void OnMapStart()
{	
    #if DEBUG
		LogMessage("OnMapStart()");
    #endif
}

public void OnMapEnd()
{
	delete COLD_DOWN_Timer;
}

public void OnConfigsExecuted()
{
	#if DEBUG
		LogMessage("OnConfigsExecuted");
	#endif 

	if(g_bNoOneInServer || ( !g_bFirstMap &&  g_bAnyoneConnectedBefore ))
	{
		if(CheckPlayerInGame(0) == false) //沒有玩家在伺服器中
		{
			delete COLD_DOWN_Timer;
			COLD_DOWN_Timer = CreateTimer(20.0, COLD_DOWN);
		}
	}

	g_bFirstMap = false;
}

public void OnClientConnected(int client)
{
	if(IsFakeClient(client)) return;

	#if DEBUG
		LogMessage("OnClientConnected: %N", client);
	#endif 

	g_bAnyoneConnectedBefore = true;
}

Action Cmd_RestartServer(int client, int args)
{
	if(client > 0 && !IsFakeClient(client))
	{
		static char steamid[32];
		GetClientAuthId(client, AuthId_SteamID64, steamid, sizeof(steamid), true);

		LogToFileEx(g_sPath, "Manually restarting server... by %N [%s]", client, steamid);
		PrintToServer("Manually restarting server in 5 seconds later... by %N", client);
		PrintToChatAll("Manually restarting server in 5 seconds later... by %N", client);
	}
	else
	{
		LogToFileEx(g_sPath, "Manually restarting server by server console...");
		PrintToServer("Manually restarting server in 5 seconds later...");
		PrintToChatAll("Manually restarting server in 5 seconds later...");
	}

	CreateTimer(5.0, Timer_Cmd_RestartServer);

	return Plugin_Continue;
}

void Event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if(!client || IsFakeClient(client) /*|| (IsClientConnected(client) && !IsClientInGame(client))*/) return;

	if(!CheckPlayerInGame(client)) //檢查是否還有玩家以外的人還在伺服器
	{
		g_bNoOneInServer = true;

		delete COLD_DOWN_Timer;
		COLD_DOWN_Timer = CreateTimer(15.0, COLD_DOWN);
	}
}

Action COLD_DOWN(Handle timer, any client)
{
	if(CheckPlayerInGame(0)) //有玩家在伺服器中
	{
		g_bNoOneInServer = false;
		COLD_DOWN_Timer = null;
		return Plugin_Continue;
	}
	
	if(CheckPlayerConnectingSV()) //沒有玩家在伺服器但是有玩家正在連線
	{
		COLD_DOWN_Timer = CreateTimer(20.0, COLD_DOWN); //重新計時
		return Plugin_Continue;
	}
	
	LogToFileEx(g_sPath, "Last one player left the server, Restart server now");
	PrintToServer("Last one player left the server, Restart server now");

	UnloadAccelerator();

	CreateTimer(0.1, Timer_RestartServer);

	COLD_DOWN_Timer = null;
	return Plugin_Continue;
}

Action Timer_RestartServer(Handle timer)
{
	ServerCommand("_restart");


	//SetCommandFlags("sv_crash", GetCommandFlags("sv_crash") &~ FCVAR_CHEAT);
	//ServerCommand("sv_crash");//crash server, make linux auto restart server

	return Plugin_Continue;
}

Action Timer_Cmd_RestartServer(Handle timer)
{
	for(int i = 1; i <= MaxClients; i++)
	{
		if(!IsClientInGame(i)) continue;
		if(IsFakeClient(i)) continue;

		KickClient(i, "Server is restarting");
	}
	UnloadAccelerator();
	CreateTimer(0.2, Timer_RestartServer);

	return Plugin_Continue;
}

void UnloadAccelerator()
{
	/*if( g_iCvarUnloadExtNum )
	{
		ServerCommand("sm exts unload %i 0", g_iCvarUnloadExtNum);
	}*/

	char responseBuffer[4096];
	
	// fetch a list of sourcemod extensions
	ServerCommandEx(responseBuffer, sizeof(responseBuffer), "%s", "sm exts list");
	
	// matching ext name only should sufiice
	Regex regex = new Regex("\\[([0-9]+)\\] Accelerator");
	
	// actually matched?
	// CapcureCount == 2? (see @note of "Regex.GetSubString" in regex.inc)
	if (regex.Match(responseBuffer) > 0 && regex.CaptureCount() == 2)
	{
		char sAcceleratorExtNum[4];
		
		// 0 is the full string "[?] Accelerator"
		// 1 is the matched extension number
		regex.GetSubString(1, sAcceleratorExtNum, sizeof(sAcceleratorExtNum));
		
		// unload it
		ServerCommand("sm exts unload %s 0", sAcceleratorExtNum);
		ServerExecute();
	}
	
	delete regex;
}

bool CheckPlayerInGame(int client)
{
	for (int i = 1; i <= MaxClients; i++)
		if(IsClientInGame(i) && !IsFakeClient(i) && i!=client)
			return true;

	return false;
}

bool CheckPlayerConnectingSV()
{
	for (int i = 1; i <= MaxClients; i++)
		if(IsClientConnected(i) && !IsClientInGame(i) && !IsFakeClient(i))
			return true;

	return false;
}