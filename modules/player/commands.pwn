/*******************************************************************************
* FILENAME :        modules/data/commands.pwn
*
* DESCRIPTION :
*       Adds players general commands to the server.
*
* NOTES :
*       This file should only contain player general commands.
*       Faction, job, admin, etc, commands should be in their respective modules
*
*       Copyright Paradise Devs 2015.  All rights reserved.
*
*/

#include <YSI\y_hooks>

static Timer:gSuicideTimer[MAX_PLAYERS] = {Timer:-1, ...};

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
	Command_AddAltNamed("kill",			"suicidio");
	Command_AddAltNamed("janela",		"j");
	Command_AddAltNamed("gritar",		"g");
	Command_AddAltNamed("sussurrar",	"s");
	Command_AddAltNamed("comandos",		"cmds");
	Command_AddAltNamed("anuncio",		"an");
	Command_AddAltNamed("radio",		"r");
	Command_AddAltNamed("departamento",	"d");
	Command_AddAltNamed("stats",		"rg");
	Command_AddAltNamed("ooc",			"o");
	return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerDisconnect(playerid, reason)
{
	if(gSuicideTimer[playerid] != Timer:-1)
	{
		stop gSuicideTimer[playerid];
		gSuicideTimer[playerid] = Timer:-1;
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:do(playerid, params[], help)
{
	if(isnull(params))
		return SendClientMessage(playerid, COLOR_INFO, "* /do [mensagem]");

	SendActionMessage(playerid, 20.0, params);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:eu(playerid, params[], help)
{
	if(isnull(params))
		return SendClientMessage(playerid, COLOR_INFO, "* /eu [mensagem]");

	SendClientActionMessage(playerid, 20.0, params);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:b(playerid, params[], help)
{
	if(isnull(params))
		return SendClientMessage(playerid, COLOR_INFO, "* /b [mensagem]");

    new message[156];
	format(message, sizeof(message), "%s: (( %s ))", GetPlayerNamef(playerid), params);
	SendClientLocalMessage(playerid, 0xe3e3e3ff, 20.0, message);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:id(playerid, params[], help)
{
	new targetid;
	if(sscanf(params, "k<u>", targetid))
	{
		SendClientMessage(playerid, COLOR_INFO, "* /id [jogador]");
	}
	else if(!IsPlayerLogged(targetid))
	{
		SendClientMessagef(playerid, COLOR_ERROR, "* Jogador n??o conectado. (%i)", targetid);
	}
	else
	{
		new output[40];
		format(output, sizeof(output), "* %s(ID: %i)", GetPlayerNamef(targetid), targetid);
		SendClientMessage(playerid, COLOR_INFO, output);
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:comandos(playerid, params[], help)
{
	SendClientMessage(playerid, COLOR_TITLE, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Comandos ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* /(g)ritar - /(s)ussurar - /eu - /do - /b - /admins - /id - /(j)anela - /motor - /farol - /ajuda - /apertarmao - /oferecerboquete");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* /beijar - /fumar - /gps - /relatorio - /reportar - /ejetar - /mostrarlicenca - /abrirconta - /pagar - /desafiar - /suicidio");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* /dormir - /acordar - /roubar - /animes - /sairdoemprego");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* /ajudapet - /ajudaveiculo - /ajudaapartamento - /ajudacasa - /ajudaempresa - /ajudawalkie - /ajudafaccao");
	SendClientMessage(playerid, COLOR_TITLE, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Comandos ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:pagar(playerid, params[], help)
{
	new	targetid, value;
	if(sscanf(params, "k<u>i", targetid, value))
		return SendClientMessage(playerid, COLOR_INFO, "* /pagar [playerid] [valor]");

	else if(!IsPlayerLogged(targetid))
		return SendClientMessage(playerid, COLOR_ERROR, "* Jogador n??o conectado.");

	else if(GetPlayerDistanceFromPlayer(playerid, targetid) > 5.0)
		return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o est?? pr??ximo do jogador.");

	else if(GetPlayerCash(playerid) < value)
		return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o tem essa quantia de dinheiro.");

	SendClientMessagef(playerid, COLOR_SPECIAL, "* Voc?? deu $%s para %s.", formatnumber(value), GetPlayerNamef(targetid));
	SendClientMessagef(targetid, COLOR_SPECIAL, "* %s deu $%s para voc??.", GetPlayerNamef(playerid), formatnumber(value));

	new message[38 + MAX_PLAYER_NAME];
	format(message, sizeof(message), "deu uma quantia de dinheiro para %s.", GetPlayerNamef(targetid));
	SendClientActionMessage(playerid, 20.0, message);

	GivePlayerCash(playerid, -value);
	GivePlayerCash(targetid, value);

	new log[80];
	format(log, sizeof(log), "%s gave $%s to %s.", GetPlayerNamef(playerid), GetPlayerNamef(targetid), formatnumber(value));
	WriteLog("logs/money_log.txt", log);
	return 1;
}


//------------------------------------------------------------------------------

YCMD:abrirconta(playerid, params[], help)
{
	if(IsPlayerInRangeOfPoint(playerid, 15.0, 1598.7216, -1034.4863, 23.9140) && GetPlayerInterior(playerid) == 1 && GetPlayerVirtualWorld(playerid) == 17)
	{
		if(GetPlayerBankAccount(playerid) != 0)
			return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? j?? possui uma conta banc??ria.");

		new baccount = 1000 + GetPlayerDatabaseID(playerid);
		SendClientMessagef(playerid, 0x87ff00ff, "* Sua conta banc??ria foi aberta! Conta: {4aff00}%s{87ff00}.", formatnumber(baccount));
		SetPlayerBankAccount(playerid, baccount);
	}
	else
		SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o est?? no banco.");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:mostrarlicenca(playerid, params[], help)
{
	new
		item,
		targetid;

	if(sscanf(params, "k<u>i", targetid, item))
	{
		SendClientMessage(playerid, COLOR_INFO, "* /mostrarlicenca [playerid] [item]");
		SendClientMessage(playerid, COLOR_INFO, "(1)Carro - (2)Moto - (3)Caminh??o - (4)Helicoptero - (5)Aviao - (6)Barco");
		return 1;
	}

	else if(!IsPlayerLogged(targetid))
		return SendClientMessage(playerid, COLOR_ERROR, "* Jogador n??o conectado.");

	else if(GetPlayerDistanceFromPlayer(playerid, targetid) > 5.0)
		return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o est?? pr??ximo do jogador.");

	else if(GetPVarInt(targetid, "isLicenseVisible"))
		return SendClientMessage(playerid, COLOR_ERROR, "* O jogador j?? est?? vendo uma licen??a.");

	switch(item)
	{
		case 1:
		{
			if(GetPlayerCarLicense(playerid) == 0)
				return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o possui essa licen??a.");

			ShowPlayerLicense(playerid, targetid, LICENSE_CAR);

			if(playerid != targetid)
			{
				SendClientMessagef(playerid, COLOR_INFO, "* Voc?? mostrou sua licen??a para %s.", GetPlayerNamef(targetid));
				foreach(new i: Player)
				{
					if(GetPlayerDistanceFromPlayer(playerid, i) < 15.0 && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))
						SendClientMessagef(i, 0xDA70D6FF, "* %s mostrou a carteira de motorista para %s.", GetPlayerNamef(playerid), GetPlayerNamef(targetid));
				}
			}
		}
		case 2:
		{
			if(GetPlayerBikeLicense(playerid) == 0)
				return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o possui essa licen??a.");

			ShowPlayerLicense(playerid, targetid, LICENSE_BIKE);
			SendClientMessagef(playerid, COLOR_INFO, "* Voc?? mostrou sua licen??a para %s.", GetPlayerNamef(targetid));

			if(playerid != targetid)
			{
				foreach(new i: Player)
				{
					if(GetPlayerDistanceFromPlayer(playerid, i) < 15.0 && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))
						SendClientMessagef(i, 0xDA70D6FF, "* %s mostrou a carteira de motorista para %s.", GetPlayerNamef(playerid), GetPlayerNamef(targetid));
				}
			}
		}
		case 3:
		{
			if(GetPlayerTruckLicense(playerid) == 0)
				return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o possui essa licen??a.");

			ShowPlayerLicense(playerid, targetid, LICENSE_TRUCK);

			if(playerid != targetid)
			{
				SendClientMessagef(playerid, COLOR_INFO, "* Voc?? mostrou sua licen??a para %s.", GetPlayerNamef(targetid));
				foreach(new i: Player)
				{
					if(GetPlayerDistanceFromPlayer(playerid, i) < 15.0 && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))
						SendClientMessagef(i, 0xDA70D6FF, "* %s mostrou a carteira de motorista para %s.", GetPlayerNamef(playerid), GetPlayerNamef(targetid));
				}
			}
		}
		case 4:
		{
			if(GetPlayerHeliLicense(playerid) == 0)
				return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o possui essa licen??a.");

			ShowPlayerLicense(playerid, targetid, LICENSE_HELI);

			if(playerid != targetid)
			{
				SendClientMessagef(playerid, COLOR_INFO, "* Voc?? mostrou sua licen??a para %s.", GetPlayerNamef(targetid));
				foreach(new i: Player)
				{
					if(GetPlayerDistanceFromPlayer(playerid, i) < 15.0 && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))
						SendClientMessagef(i, 0xDA70D6FF, "* %s mostrou a carteira de motorista para %s.", GetPlayerNamef(playerid), GetPlayerNamef(targetid));
				}
			}
		}
		case 5:
		{
			if(GetPlayerPlaneLicense(playerid) == 0)
				return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o possui essa licen??a.");

			ShowPlayerLicense(playerid, targetid, LICENSE_PLANE);

			if(playerid != targetid)
			{
				SendClientMessagef(playerid, COLOR_INFO, "* Voc?? mostrou sua licen??a para %s.", GetPlayerNamef(targetid));
				foreach(new i: Player)
				{
					if(GetPlayerDistanceFromPlayer(playerid, i) < 15.0 && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))
						SendClientMessagef(i, 0xDA70D6FF, "* %s mostrou a carteira de motorista para %s.", GetPlayerNamef(playerid), GetPlayerNamef(targetid));
				}
			}
		}
		case 6:
		{
			if(GetPlayerBoatLicense(playerid) == 0)
				return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o possui essa licen??a.");

			ShowPlayerLicense(playerid, targetid, LICENSE_BOAT);

			if(playerid != targetid)
			{
				SendClientMessagef(playerid, COLOR_INFO, "* Voc?? mostrou sua licen??a para %s.", GetPlayerNamef(targetid));
				foreach(new i: Player)
				{
					if(GetPlayerDistanceFromPlayer(playerid, i) < 15.0 && GetPlayerVirtualWorld(i) == GetPlayerVirtualWorld(playerid))
						SendClientMessagef(i, 0xDA70D6FF, "* %s mostrou a carteira de motorista para %s.", GetPlayerNamef(playerid), GetPlayerNamef(targetid));
				}
			}
		}
		default:
		{
			SendClientMessage(playerid, COLOR_INFO, "* /mostrarlicenca [playerid] [item]");
			SendClientMessage(playerid, COLOR_INFO, "(1)Carro - (2)Moto - (3)Caminh??o - (4)Helicoptero - (5)Aviao - (6)Barco");
		}
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:ejetar(playerid, params[], help)
{
	if(!IsPlayerInAnyVehicle(playerid))
		return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o est?? em um ve??culo.");

	else if(GetPlayerState(playerid) != PLAYER_STATE_DRIVER)
		return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o ?? o motorista.");

	new targetid;
	if(sscanf(params, "k<u>", targetid))
		return SendClientMessage(playerid, COLOR_INFO, "* /ejetar [playerid]");

	else if(!IsPlayerInVehicle(targetid, GetPlayerVehicleID(playerid)))
		return SendClientMessage(playerid, COLOR_ERROR, "* O jogador n??o est?? em seu ve??culo.");

	else if(playerid == targetid)
		return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o pode ejetar voc?? mesmo.");

	SendClientMessagef(playerid, 0xFFFFFFFF, "* Voc?? ejetou {00ACE6}%s{FFFFFF} do ve??culo.", GetPlayerNamef(targetid));
	SendClientMessagef(targetid, 0xFFFFFFFF, "* Voc?? foi ejetado do ve??culo por {00ACE6}%s{FFFFFF}.", GetPlayerNamef(playerid));
	RemovePlayerFromVehicle(targetid);
	return true;
}

//------------------------------------------------------------------------------

YCMD:relatorio(playerid, params[], help)
{
	if(isnull(params))
		return SendClientMessage(playerid, COLOR_INFO, "* /relatorio [mensagem]");

	foreach(new i: Player)
	{
		if(GetPlayerRank(i) < PLAYER_RANK_PARADISER)
			continue;

		new message[150 + MAX_PLAYER_NAME];
		format(message, 150 + MAX_PLAYER_NAME, "* Relat??rio de %s(ID: %i): %s", GetPlayerNamef(playerid), playerid, params);
		SendMultiMessage(i, 0xff8a00ff, message);
	}
	SendClientMessage(playerid, 0xff8a00ff, "* Relat??rio enviado com sucesso.");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:reportar(playerid, params[], help)
{
	new targetid, reason[128];
	if(sscanf(params, "k<u>s", targetid, reason))
		return SendClientMessage(playerid, COLOR_INFO, "* /reportar [playerid] [motivo]");

	if(playerid == targetid)
		return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o pode reportar voc?? mesmo.");

	if(IsPlayerNPC(targetid) || !IsPlayerLogged(targetid))
		return SendClientMessage(playerid, COLOR_ERROR, "* Jogador n??o conectado.");

	if(GetPlayerRank(targetid) > PLAYER_RANK_PARADISER)
		return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o pode reportar administradores, use o forum.");

	foreach(new i: Player)
	{
		if(GetPlayerRank(i) < PLAYER_RANK_PARADISER)
			continue;

		new message[150 + MAX_PLAYER_NAME];
		format(message, 150 + MAX_PLAYER_NAME, "* %s reportou %s. Motivo: %s", GetPlayerNamef(playerid), GetPlayerNamef(targetid), reason);
		SendMultiMessage(i, 0x750b0bff, message);
	}
	SendClientMessage(playerid, 0x750b0bff, "* Jogador reportado com sucesso.");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:ajudawalkie(playerid, params[], help)
{
	SendClientMessage(playerid, COLOR_TITLE, "~~~~~~~~~~~~~~~~~~~~ Comandos Walkie Talkie ~~~~~~~~~~~~~~~~~~~~");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* /w - /mudarfreq");
	SendClientMessage(playerid, COLOR_SUB_TITLE, "* Voc?? pode falar no IRC do servidor atrav??s da frequ??ncia 1337Mhz.");
	SendClientMessage(playerid, COLOR_TITLE, "~~~~~~~~~~~~~~~~~~~~ Comandos Walkie Talkie ~~~~~~~~~~~~~~~~~~~~");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:mudarfreq(playerid, params[], help)
{
	if(GetPlayerWalkieTalkieFrequency(playerid) == 0)
		return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o possui um Walkie Talkie.");

	new freq;
	if(sscanf(params, "i", freq))
		return SendClientMessage(playerid, COLOR_INFO, "* /mudarfreq [freq]");

	if(freq < 1000 || freq > 9999)
		return SendClientMessage(playerid, COLOR_ERROR, "* Apenas frequ??ncias entre 1000Mhz e 9999Mhz.");

	SetPlayerWalkieTalkieFrequency(playerid, freq);
	SendClientMessagef(playerid, COLOR_SUCCESS, "* Voc?? alterou a frequ??ncia de seu Walkie Talkie para %iMhz.", freq);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:w(playerid, params[], help)
{
	if(GetPlayerWalkieTalkieFrequency(playerid) == 0)
		return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o possui um Walkie Talkie.");

	new message[128];
	if(sscanf(params, "s", message))
		return SendClientMessage(playerid, COLOR_INFO, "* /w [mensagem]");

	new Float:playerPos[3];
	GetPlayerPos(playerid, playerPos[0], playerPos[1], playerPos[2]);

	foreach(new i: Player)
	{
		if(!IsPlayerLogged(i) || i == playerid || GetPlayerWalkieTalkieFrequency(i) == GetPlayerWalkieTalkieFrequency(playerid))
			continue;

		new Float:dist = GetPlayerDistanceFromPoint(i, playerPos[0], playerPos[1], playerPos[2]);

		if(IsPlayerInVehicle(i, GetPlayerVehicleID(playerid)) || dist <= 5) {
			SendClientMessagef(i, 0xC6C6C6FF, "(Walkie Talkie) %s diz: %s", GetPlayerNamef(playerid), message);
		}

		else if(dist >= 6 && dist <= 10) {
			SendClientMessagef(i, 0xB6B6B6FF, "(Walkie Talkie) %s diz: %s", GetPlayerNamef(playerid), message);
		}

		else if(dist >= 11 && dist <= 20) {
			SendClientMessagef(i, 0x8B8B8BFF, "(Walkie Talkie) %s diz: %s", GetPlayerNamef(playerid), message);
		}
	}

	SetPlayerChatBubble(playerid, message, COLOR_WHITE, 20.0, 5000);
	SendWalkieTalkieMessage(GetPlayerWalkieTalkieFrequency(playerid), GetPlayerNamef(playerid), message);

	/*
	if(GetPlayerWalkieTalkieFrequency(playerid) == 1337) {
		new name[MAX_PLAYER_NAME], ircMsg[256];
		GetPlayerName(playerid, name, sizeof(name));
		format(ircMsg, sizeof(ircMsg), "02[%d] 07%s: %s", playerid, name, message);
		IRC_GroupSay(groupID, IRC_CHANNEL, ircMsg);
	}
	*/
	return 1;
}

//------------------------------------------------------------------------------

YCMD:fumar(playerid, params[], help)
{
	if(IsPlayerCuffed(playerid))
		return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o pode fumar enquanto est?? algemado.");

	else if(GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_SMOKE_CIGGY)
		return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? j?? est?? fumando um cigarro.");

	else if(GetPlayerCigaretts(playerid) < 1)
		return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o possui um cigarro.");

	else if(GetPlayerLighter(playerid) < 1)
		return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o possui um isqueiro.");

	else if(GetPlayerLighter(playerid) == 1)
		return SendClientMessage(playerid, COLOR_ERROR, "* O g??s do seu isqueiro acabou.");

	SendClientActionMessage(playerid, 20.0, "acendeu um cigarro.");
	SetPlayerSpecialAction(playerid, SPECIAL_ACTION_SMOKE_CIGGY);

	SetPlayerLighter(playerid, GetPlayerLighter(playerid) - 1);
	SetPlayerCigaretts(playerid, GetPlayerCigaretts(playerid) - 1);
	return 1;
}

//------------------------------------------------------------------------------

static g_pLastCiggy[MAX_PLAYERS];
hook OnPlayerKeyStateChange(playerid, newkeys, oldkeys)
{
	if((newkeys & KEY_FIRE) && g_pLastCiggy[playerid] < GetTickCount() && (GetPlayerSpecialAction(playerid) == SPECIAL_ACTION_SMOKE_CIGGY))
	{
		g_pLastCiggy[playerid] = GetTickCount() + 2350;
		if(GetPlayerAddiction(playerid) == 0.0)
		{
			SetPlayerAddiction(playerid, GetPlayerAddiction(playerid) + 10.0);
			SendClientMessage(playerid, COLOR_WARNING, "* Voc?? agora est?? viciado, voc?? precisar?? manter o uso constante deste item para n??o morrer.");
		}
		else
		{
			SetPlayerAddiction(playerid, GetPlayerAddiction(playerid) + 1.0);
		}
	}
	return 1;
}

//------------------------------------------------------------------------------

YCMD:admins(playerid, params[], help)
{
	new count = 0, string[74];
	SendClientMessage(playerid, COLOR_TITLE, "- Membros da modera????o online -");

	foreach(new i: Player)
	{
		if(GetPlayerRank(i) >= PLAYER_RANK_PARADISER)
		{
			format(string, sizeof string, "* {FFFFFF}[{%06x}%s{FFFFFF}] %s {A6A6A6}(ID: %i)", GetPlayerRankColor(i) >>> 8, GetPlayerRankName(i, true), GetPlayerNamef(i), i);
			SendClientMessage(playerid, COLOR_INFO, string);
			count++;
		}
	}

	if(count == 0)
		SendClientMessage(playerid, COLOR_ERROR, "* Nenhum membro da modera????o online.");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:ajuda(playerid, params[], help)
{
	SendClientMessage(playerid, COLOR_TITLE, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Ajuda ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
	SendClientMessage(playerid, COLOR_WHITE, "* Para uma lista com os comandos dispon??veis digite {a5f413}/comandos{ffffff} ou {a5f413}/cmds{ffffff}.");
	SendClientMessage(playerid, COLOR_WHITE, "* Grande parte dos {a5f413}itens{ffffff} a venda se encontram em {a5f413}lojas 24-7{ffffff}.");
	SendClientMessage(playerid, COLOR_WHITE, "* Um {a5f413}GPS{ffffff} ir?? te ajudar a localizar os locais importantes atrav??s do comando {a5f413}/gps{ffffff}.");
	SendClientMessage(playerid, COLOR_WHITE, "* {a5f413}Telefones{ffffff} s??o vendidos nas operadoras de celular apresentadas por um {a5f413}T{ffffff} em seu radar.");
	SendClientMessage(playerid, COLOR_WHITE, "* {a5f413}An??ncios{ffffff} enviados por empresas de publicidade {a5f413}s??o 50%% mais baratos{ffffff}.");
	SendClientMessage(playerid, COLOR_WHITE, "* Para mais informa????es visite nosso site e f??rum em {a5f413}www.pc-rpg.com{ffffff}.");
	SendClientMessage(playerid, COLOR_WHITE, "* Caso ainda tenha d??vidas chame um {a5f413}administrador{ffffff} com {a5f413}/relatorio{ffffff}.");
	SendClientMessage(playerid, COLOR_TITLE, "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ Ajuda ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:sussurrar(playerid, params[], help)
{
	new targetid, message[128];
	if(sscanf(params, "k<u>s[128]", targetid, message))
		return SendClientMessage(playerid, COLOR_INFO, "* /(s)ussurrar [playerid] [mensagem]");

	if(!IsPlayerLogged(targetid))
		return SendClientMessage(playerid, COLOR_ERROR, "* O jogador n??o est?? conectado.");

	if(targetid == playerid)
		return SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o pode sussurar para voc?? mesmo.");

	new Float:fDist[3];
	GetPlayerPos(playerid, fDist[0], fDist[1], fDist[2]);
	if(GetPlayerDistanceFromPoint(targetid, fDist[0], fDist[1], fDist[2]) < 3.0 && GetPlayerVirtualWorld(targetid) == GetPlayerVirtualWorld(playerid))
	{
        new output[145];
        format(output, sizeof(output), "* Sussuro para %s(ID: %d): %s", GetPlayerNamef(targetid), targetid, message);
		SendClientMessage(playerid, 0x26b4cdff, output);
        format(output, sizeof(output), "* Sussuro de %s(ID: %d): %s", GetPlayerNamef(playerid), playerid, message);
		SendClientMessage(targetid, 0x26b4cdff, output);
        format(output, sizeof(output), "sussurou algo para %s.", GetPlayerNamef(targetid));
        SendClientActionMessage(playerid, 15.0, output);
	}
	else SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o est?? pr??ximo do jogador.");
	return 1;
}

//------------------------------------------------------------------------------

YCMD:gritar(playerid, params[], help)
{
	if(isnull(params))
		return SendClientMessage(playerid, COLOR_INFO, "* /(g)ritar [mensagem]");

	for(new i, l = strlen( params ); i != l; i++)
	{
		if(params[i] >= 'a' && params[i] <= 'z')
		{
			params[i] = toupper(params[i]);
		}
	}

	new message[156];
	format(message, sizeof(message), "%s grita: %s!!", GetPlayerNamef(playerid), params);
	SendClientLocalMessage(playerid, COLOR_WHITE, 40.0, message);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:ooc(playerid, params[], help)
{
	if(isnull(params))
		return SendClientMessage(playerid, COLOR_INFO, "* /(o)oc [mensagem]");

	new message[156];
	format(message, sizeof(message), "(( [OOC] %s diz: %s ))", GetPlayerNamef(playerid), params);
	SendClientMessageToAll(0x87CEEBFF, message);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:stats(playerid, params[], help)
{
	ShowPlayerDataHud(playerid);
	return 1;
}

//------------------------------------------------------------------------------

YCMD:kill(playerid, params[], help)
{
	ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.1, 0, 1, 1, 1, 0, 1);
	SendClientActionMessage(playerid, 15.0, "est?? cometendo suic??dio.");
	GameTextForPlayer(playerid, "~r~suicidando-se", 125, 3);
//gSuicideTimer[playerid] = repeat SuicideTimer(playerid); <- infinite loop bug
	SetPlayerHealth(playerid, 0.0);
	return 1;
}

YCMD:ncomandos(playerid, params[], help)
{
	
}
/*
timer SuicideTimer[250](playerid)
{
	if(GetPlayerAnimationIndex(playerid) != 1537)
	{
		ClearAnimations(playerid);
		ApplyAnimation(playerid, "SWEET", "Sweet_injuredloop", 4.1, 0, 1, 1, 1, 0, 1);
	}

	new Float:health;
	GetPlayerHealth(playerid, health);
	GameTextForPlayer(playerid, "~r~suicidando-se", 125, 3);
	if((health - 1.0) > 1.0)
	{
		SetPlayerHealth(playerid, health - 1.0);
	}
	else
	{
		SetPlayerHealth(playerid, 0.0);
		stop gSuicideTimer[playerid];
		gSuicideTimer[playerid] = Timer:-1;
	}
}*/

//------------------------------------------------------------------------------

/*
        Error & Return type

    COMMAND_ZERO_RET      = 0 , // The command returned 0.
    COMMAND_OK            = 1 , // Called corectly.
    COMMAND_UNDEFINED     = 2 , // Command doesn't exist.
    COMMAND_DENIED        = 3 , // Can't use the command.
    COMMAND_HIDDEN        = 4 , // Can't use the command don't let them know it exists.
    COMMAND_NO_PLAYER     = 6 , // Used by a player who shouldn't exist.
    COMMAND_DISABLED      = 7 , // All commands are disabled for this player.
    COMMAND_BAD_PREFIX    = 8 , // Used "/" instead of "#", or something similar.
    COMMAND_INVALID_INPUT = 10, // Didn't type "/something".
*/

public e_COMMAND_ERRORS:OnPlayerCommandReceived(playerid, cmdtext[], e_COMMAND_ERRORS:success)
{
	if(!IsPlayerLogged(playerid))
	{
		SendClientMessage(playerid, COLOR_ERROR, "* Voc?? precisa estar logado para usar algum comando.");
		return COMMAND_DENIED;
	}
	else if(GetPlayerHospitalTime(playerid) > 0 && GetPlayerRank(playerid) < PLAYER_RANK_MODERATOR)
	{
		SendClientMessage(playerid, COLOR_ERROR, "* Voc?? est?? em coma.");
		return COMMAND_DENIED;
	}
	else if(success != COMMAND_OK)
		SendClientMessage(playerid, COLOR_ERROR, "* Este comando n??o existe. Utilize /cmds ou /comandos para uma lista com todos os comandos.");
    return COMMAND_OK;
}
