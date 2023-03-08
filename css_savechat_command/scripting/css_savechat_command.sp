#pragma semicolon 1
#pragma newdecls required //強制1.7以後的新語法

#include <sourcemod>
#include <sdktools>
#include <geoip>
#include <string>
#include <cstrike>
#define PLUGIN_VERSION			"1.1"
#define PLUGIN_NAME			    "css_savechat_command"
#define DEBUG 0

public Plugin myinfo = 
{
	name = "[CSS] SaveChat/SaveCommand",
	author = "Harry Potter",
	description = "Records player chat messages and commands to a file",
	version = PLUGIN_VERSION,
	url = "https://steamcommunity.com/profiles/76561198026784913/"
}

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
    EngineVersion test = GetEngineVersion();

    if( test != Engine_CSS )
    {
        strcopy(error, err_max, "Plugin only supports CSS.");
        return APLRes_SilentFailure;
    }

    return APLRes_Success;
}

#define CVAR_FLAGS                    FCVAR_NOTIFY
#define CVAR_FLAGS_PLUGIN_VERSION     FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY

ConVar hostport;
char sHostport[10];

char chatFile[128];
Handle fileHandle       = null;
ConVar g_hCvarEnable, g_hCvarConsole;
bool g_bCvarEnable, g_bCvarConsole;

public void OnPluginStart()
{
	hostport = FindConVar("hostport");

	g_hCvarEnable = 	CreateConVar( PLUGIN_NAME ... "_enable", 			"1", "0=Plugin off, 1=Plugin on.", CVAR_FLAGS, true, 0.0, true, 1.0); 
	g_hCvarConsole = 	CreateConVar( PLUGIN_NAME ... "_cosole_command", 	"1", "If 1, Record and save console commands.", CVAR_FLAGS, true, 0.0, true, 1.0); 
	CreateConVar(                     PLUGIN_NAME ... "_version",       	PLUGIN_VERSION, PLUGIN_NAME ... " Plugin Version", CVAR_FLAGS_PLUGIN_VERSION);
	AutoExecConfig(true, PLUGIN_NAME);
	
	GetCvars();
	hostport.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarEnable.AddChangeHook(ConVarChanged_Cvars);
	g_hCvarConsole.AddChangeHook(ConVarChanged_Cvars);

	HookEvent("player_disconnect", 	event_PlayerDisconnect);

	/* Say commands */
	RegConsoleCmd("say", Command_Say);
	RegConsoleCmd("say_team", Command_SayTeam);

	char date[21];
	char logFile[100];
	/* Format date for log filename */
	FormatTime(date, sizeof(date), "%d%m%y", -1);

	/* Create name of logfile to use */
	Format(logFile, sizeof(logFile), "/logs/chat%s.log", date);
	BuildPath(Path_SM, chatFile, PLATFORM_MAX_PATH, logFile);
}

public void ConVarChanged_Cvars(ConVar convar, const char[] oldValue, const char[] newValue)
{
	GetCvars();
}

void GetCvars()
{
	g_bCvarEnable = g_hCvarEnable.BoolValue;
	g_bCvarConsole = g_hCvarConsole.BoolValue;
	hostport.GetString(sHostport, sizeof(sHostport));
}

public Action Command_Say(int client, int args)
{
	if(g_bCvarEnable == false)
		return Plugin_Continue;

	if(client < 0 || client > MaxClients)
		return Plugin_Continue;

	LogChat(client, args, false);
	return Plugin_Continue;
}

public Action Command_SayTeam(int client, int args)
{
	if(g_bCvarEnable == false)
		return Plugin_Continue;

	if(client < 0 || client > MaxClients)
		return Plugin_Continue;

	LogChat(client, args, true);
	return Plugin_Continue;
}

public Action OnClientCommand(int client, int args) 
{
	if(g_bCvarEnable == false || g_bCvarConsole == false)
		return Plugin_Continue;

	if(client < 0 || client > MaxClients)
		return Plugin_Continue;

	LogCommand(client, args);
	return Plugin_Continue;
}

public void OnMapStart(){
	if(g_bCvarEnable == false)
		return;

	char map[128];
	char msg[1024];
	char date[21];
	char time[21];
	char logFile[100];

	GetCurrentMap(map, sizeof(map));

	/* The date may have rolled over, so update the logfile name here */
	FormatTime(date, sizeof(date), "%y_%m_%d", -1);
	Format(logFile, sizeof(logFile), "/logs/chat/server_%s_chat_%s.log", sHostport, date);
	BuildPath(Path_SM, chatFile, PLATFORM_MAX_PATH, logFile);

	FormatTime(time, sizeof(time), "%d/%m/%Y %H:%M:%S", -1);
	Format(msg, sizeof(msg), "[%s] --- Map: %s ---", time, map);

	SaveMessage("--=================================================================--");
	SaveMessage(msg);
	SaveMessage("--=================================================================--");
}


public void OnClientPostAdminCheck(int client)
{
	if(g_bCvarEnable == false)
		return;

	if(IsFakeClient(client)) 
		return;

	static char msg[2048];
	static char time[21];
	static char country[3];
	static char steamID[128];
	static char playerIP[50];
	
	GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
	
	if(GetClientIP(client, playerIP, sizeof(playerIP), true) == false) {
		//country   = "  "
	} else {
		if(GeoipCode2(playerIP, country) == false) {
			//country = "  ";
		}
	}
	
	FormatTime(time, sizeof(time), "%H:%M:%S", -1);
	FormatEx(msg, sizeof(msg), "[%s] (%-20s | %-15s) %-25N has joined.",
		time,
		steamID,
		playerIP,
		client);

	SaveMessage(msg);
}

public void event_PlayerDisconnect(Event event, const char[] name, bool dontBroadcast) 
{
	if(g_bCvarEnable == false)
		return;

	int client = GetClientOfUserId(event.GetInt("userid"));
	
	if( client && !IsFakeClient(client) && !dontBroadcast )
	{
		static char msg[2048];
		static char time[21];
		static char country[3];
		static char steamID[128];
		static char playerIP[50];
		
		GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
		
		if(GetClientIP(client, playerIP, sizeof(playerIP), true) == false) {
			//country   = "  "
		} else {
			if(GeoipCode2(playerIP, country) == false) {
				//country = "  ";
			}
		}
		
		FormatTime(time, sizeof(time), "%H:%M:%S", -1);
		FormatEx(msg, sizeof(msg), "[%s] (%-20s | %-15s) %-25N has left.",
			time,
			steamID,
			playerIP,
			client);

		SaveMessage(msg);
	}
}

/*
 * Extract all relevant information and format 
 */
stock void LogChat(int client, int args, bool teamchat)
{
	static char msg[2048];
	static char time[21];
	static char text[1024];
	static char country[3];
	static char playerIP[50];
	static char teamName[20];
	static char steamID[128];

	GetCmdArgString(text, sizeof(text));
	StripQuotes(text);
	
	if (client == 0 || !IsClientInGame(client)) {
		/* Don't try and obtain client country/team if this is a console message */
		//FormatEx(country, sizeof(country), "  ");
		FormatEx(teamName, sizeof(teamName), "");
	} else {
		/* Get 2 digit country code for current player */
		if(GetClientIP(client, playerIP, sizeof(playerIP), true) == false) {
			//country   = "  ";
		} else {
			if(GeoipCode2(playerIP, country) == false) {
				//country = "  ";
			}
		}
		my_GetTeamName(GetClientTeam(client), teamName, sizeof(teamName));
		GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
	}
	FormatTime(time, sizeof(time), "%H:%M:%S", -1);

	FormatEx(msg, sizeof(msg), "[%s] (%-20s | %-15s) [%s] %-25N : %s%s",
		time,
		steamID,
		playerIP,
		teamName,
		client,
		teamchat == true ? "(TEAM) " : "",
		text);

	SaveMessage(msg);
}

stock void LogCommand(int client, int args)
{
	static char cmd[64];
	static char text[1024];

	GetCmdArg(0, cmd, sizeof(cmd));
	if( strncmp(cmd, "VModEnable", 10, false) == 0 || // join server check
		strncmp(cmd, "vban", 4, false) == 0  || // join server check
		strncmp(cmd, "joingame", 8, false) == 0 || // joingame
		strncmp(cmd, "menuselect", 10, false) == 0 || //menuselect 1~9
		strncmp(cmd, "demo", 4, false) == 0 || // demorestart
		strncmp(cmd, "achievement_", 12, false) == 0 || // achievement_earned x x
		strncmp(cmd, "drop", 4, false) == 0 || // drop weapon
		strncmp(cmd, "buy", 3, false) == 0 || // buy weapon
		strncmp(cmd, "spec_", 5, false) == 0 || // spec_next / spec_prev
		strncmp(cmd, "nightvision", 11, false) == 0 // nightvision
	  ) 
	{
		return;
	}
	GetCmdArgString(text, sizeof(text));
	StripQuotes(text);

	static char country[3];
	static char playerIP[50];
	static char teamName[20];
	static char msg[2048];
	static char time[21];
	static char steamID[128];
	
	if (client == 0 || !IsClientInGame(client)) {
		/* Don't try and obtain client country/team if this is a console message */
		//FormatEx(country, sizeof(country), "  ");
		FormatEx(teamName, sizeof(teamName), "");
	} else {
		/* Get 2 digit country code for current player */
		if(GetClientIP(client, playerIP, sizeof(playerIP), true) == false) {
			//country   = "  ";
		} else {
			if(GeoipCode2(playerIP, country) == false) {
				//country = "  ";
			}
		}
		my_GetTeamName(GetClientTeam(client), teamName, sizeof(teamName));
		GetClientAuthId(client, AuthId_Steam2, steamID, sizeof(steamID));
	}
	FormatTime(time, sizeof(time), "%H:%M:%S", -1);

	FormatEx(msg, sizeof(msg), "[%s] (%-20s | %-15s) [%s] %-25N : (CMD) %s %s",
		time,
		steamID,
		playerIP,
		teamName,
		client,
		cmd,
		text);

	SaveMessage(msg);
}

void SaveMessage(const char[] message)
{
	fileHandle = OpenFile(chatFile, "a");  /* Append */
	if(fileHandle == null)
	{
		CreateDirectory("/addons/sourcemod/logs/chat", 0);
		fileHandle = OpenFile(chatFile, "a"); //open again
	}
	WriteFileLine(fileHandle, message);
	delete fileHandle;
}

void my_GetTeamName(int team, char[] sTeamName, int size)
{
	switch(team)
	{
		case CS_TEAM_SPECTATOR:
		{
			FormatEx(sTeamName, size, "Spe");
		}
		case CS_TEAM_T:
		{
			FormatEx(sTeamName, size, "T");
		}
		case CS_TEAM_CT:
		{
			FormatEx(sTeamName, size, "CT");
		}
		default:
		{
			FormatEx(sTeamName, size, "None");
		}
	}
}

