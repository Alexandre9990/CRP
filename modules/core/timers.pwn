/* *************************************************************************** *
*  Description: Timers module file.
*
*  Assignment: A script to handle global timers.
*
*           Copyright Paradise Devs 2015.  All rights reserved.
* *************************************************************************** */

#if defined _MODULE_timers
	#endinput
#endif
#define _MODULE_timers

#include <YSI\y_hooks>

ptask UpdatePlayerData[1000](playerid)
{
	if(!IsPlayerLogged(playerid))
		return 1;

    if(GetPVarInt(playerid, "PickupDelay") > 0)
        SetPVarInt(playerid, "PickupDelay", GetPVarInt(playerid, "PickupDelay") - 1);

	// If the player is seeing /stats textdraw, update time played text color
	if(GetPVarInt(playerid, "isDataHudVisible"))
	{
		new stats_color[12] = "~b~~h~";
		if(GetPlayerStatsColor(playerid) == PLAYER_STATS_COLOR_YELLOW)
			format(stats_color, sizeof(stats_color), "~y~");
		else if(GetPlayerStatsColor(playerid) == PLAYER_STATS_COLOR_GREEN)
			format(stats_color, sizeof(stats_color), "~g~");
		else if(GetPlayerStatsColor(playerid) == PLAYER_STATS_COLOR_RED)
			format(stats_color, sizeof(stats_color), "~r~");
		else if(GetPlayerStatsColor(playerid) == PLAYER_STATS_COLOR_PURPLE)
			format(stats_color, sizeof(stats_color), "~p~");

		new time_played_str[40];
		format(time_played_str, sizeof(time_played_str), "Tempo Jogado: %s%s", stats_color, GetPlayerPlayedTimeStamp(playerid));
		PlayerTextDrawSetString(playerid, gpt_data_hud[24][playerid], time_played_str);
	}

	if(GetPlayerMoney(playerid) != GetPlayerCash(playerid))
	{
		if(GetPlayerCash(playerid) > GetPlayerMoney(playerid) && GetPlayerCash(playerid) < (GetPlayerMoney(playerid) + 500))
			SetPlayerCash(playerid, GetPlayerMoney(playerid));
		else
		{
			ResetPlayerMoney(playerid);
			GivePlayerMoney(playerid, GetPlayerCash(playerid));
		}
	}

	// If the player is a cop and is near LSPD garage barrier, open it
	else if(IsPlayerInRangeOfPoint(playerid, 7.5, 1544.71570, -1630.83972, 13.21490) && GetFactionType(GetPlayerFactionID(playerid)) == FACTION_TYPE_POLICE && IsPlayerInAnyVehicle(playerid)) {
		if(!GetLSPDBarrierGateState())
			OpenLSPDBarrierGate();
	}
	// If the player is a cop and is near LSPD garage gate, open it
	else if(IsPlayerInRangeOfPoint(playerid, 7.5, 1589.67029, -1638.29895, 14.25740) && GetFactionType(GetPlayerFactionID(playerid)) == FACTION_TYPE_POLICE && IsPlayerInAnyVehicle(playerid)) {
		if(!GetPoliceGarageGateState())
			OpenPoliceGarageGate();
	}
	// If the player is a cop and is near LSPD garage door, open it
	else if(IsPlayerInRangeOfPoint(playerid, 5.0, 1584.12744, -1637.90173, 12.38100) && GetFactionType(GetPlayerFactionID(playerid)) == FACTION_TYPE_POLICE && !IsPlayerInAnyVehicle(playerid)) {
		if(!GetPoliceGarageDoorState())
			OpenPoliceGarageDoor();
	}

	// Pizza-boy job
	if(GetPlayerPizzaTime(playerid) > 0)
	{
		if(GetPlayerPizzaOnfootTime(playerid) > 1)
		{
			SetPlayerPizzaOnfootTime(playerid, GetPlayerPizzaOnfootTime(playerid) - 1);
		}
		else if(GetPlayerPizzaOnfootTime(playerid) == 1)
		{
			SendClientMessage(playerid, COLOR_ERROR, "* Voc?? perdeu a encomenda por abandonar o ve??culo da empresa.");
			DisablePlayerRaceCheckpoint(playerid);
			SetPlayerPizzaTime(playerid, 0);
			SetPlayerPizzaOnfootTime(playerid, 0);
			DestroyServiceVehicle(playerid);
		}
		else
		{
			SetPlayerPizzaTime(playerid, GetPlayerPizzaTime(playerid) - 1);

			new sTimeText[90];
			format(sTimeText, sizeof sTimeText, "~n~~n~~n~~n~~n~                                           ~y~~h~%i", GetPlayerPizzaTime(playerid));
			GameTextForPlayer(playerid, sTimeText, 2500, 3);
			if(GetPlayerPizzaTime(playerid) == 0)
			{
				SendClientMessage(playerid, COLOR_ERROR, "* A pizza esfriou e voc?? n??o conseguiu entrega-la.");
				SetPlayerCPID(playerid, CHECKPOINT_NONE);
				DisablePlayerRaceCheckpoint(playerid);
			}
		}
	}

	SetPlayerPlayedTime(playerid, GetPlayerPlayedTime(playerid) + 1);
	UpdatePlayerGPS(playerid);
    return 1;
}

task OnServerUpdate[30000]()
{
	mysql_tquery(mysql, "UPDATE players SET login_expire = login_expire-1 WHERE login_expire > 0");
}

//------------------------------------------------------------------------------

timer FadeInTimer[5000](playerid)
{
	FadeIn(playerid, 255);
}