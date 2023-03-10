/*******************************************************************************
* FILENAME :        modules/gameplay/handshake.pwn
*
* DESCRIPTION :
*       Adds commands to offer handshake to other players.
*
* NOTES :
*       -
*
*       Copyright Paradise Devs 2015.  All rights reserved.
*
*/

//------------------------------------------------------------------------------

#include <YSI\y_hooks>

// ID of the players who is giving/getting handshake
static g_p_hshake[MAX_PLAYERS] = { INVALID_PLAYER_ID, ... };

// The style of handshake
static g_p_hshakestyle[MAX_PLAYERS] = 0;

/***
 *    ######## ##     ## ##    ##  ######  ######## ####  #######  ##    ##  ######
 *    ##       ##     ## ###   ## ##    ##    ##     ##  ##     ## ###   ## ##    ##
 *    ##       ##     ## ####  ## ##          ##     ##  ##     ## ####  ## ##
 *    ######   ##     ## ## ## ## ##          ##     ##  ##     ## ## ## ##  ######
 *    ##       ##     ## ##  #### ##          ##     ##  ##     ## ##  ####       ##
 *    ##       ##     ## ##   ### ##    ##    ##     ##  ##     ## ##   ### ##    ##
 *    ##        #######  ##    ##  ######     ##    ####  #######  ##    ##  ######
 ***/

/*
	IsPlayerOfferingHandshake
		Checks if a player offering handshake to another player
	playerid
		The ID of the player
	return
		true or false
*/
IsPlayerOfferingHandshake(playerid)
{
	foreach(new i: Player)
		if(g_p_hshake[playerid] != INVALID_PLAYER_ID)
			return true;
	return false;
}


/*
	GetPlayerHandshakeOfferer
		Gets the ID of the player who is offering handshake to a player
	playerid
		The ID of the player who is getting the offer
	return
		The ID of the player who is offering the handshake INVALID_PLAYER_ID
		if nobody is offering a handshake
*/
GetPlayerHandshakeOfferer(playerid)
{
	foreach(new i: Player)
		if(g_p_hshake[i] == playerid)
			return i;
	return INVALID_PLAYER_ID;
}

/***
 *     ######     ###    ##       ##       ########     ###     ######  ##    ##
 *    ##    ##   ## ##   ##       ##       ##     ##   ## ##   ##    ## ##   ##
 *    ##        ##   ##  ##       ##       ##     ##  ##   ##  ##       ##  ##
 *    ##       ##     ## ##       ##       ########  ##     ## ##       #####
 *    ##       ######### ##       ##       ##     ## ######### ##       ##  ##
 *    ##    ## ##     ## ##       ##       ##     ## ##     ## ##    ## ##   ##
 *     ######  ##     ## ######## ######## ########  ##     ##  ######  ##    ##
 ***/

/*
	Called when a player clicks on a dialog
		playerid - ID of the player
		dialogid - ID of the dialog
		response - If clicked button 0 or button 1
		listitem - If used DIALOG_STYLE_INPUT_LIST
		inputtext - If used DIALOG_STYLE_INPUT_TEXT
*/

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	switch(dialogid)
	{
		case DIALOG_HANDSHAKE_OFFER:
		{
			// ID of the player who was receiving the proposal of handshake
			new targetid = g_p_hshake[playerid];

			SendClientMessage(playerid, 0xBFBEBEFF, "* Voc?? cancelou a oferta de aperto de m??o.");
			SendClientMessage(targetid, 0xBFBEBEFF, "* O jogador cancelou a oferta de aperto de m??o.");
			SendClientActionMessage(playerid, 15.0, "abaixou a m??o.");

			// Closes the player dialog
			ShowPlayerDialog(targetid, -1, 0, " ", " ", " ", " ");
			g_p_hshake[playerid] = INVALID_PLAYER_ID;
			return -2;
		}
		case DIALOG_HANDSHAKE_ACCEPT:
		{
			// ID of the player who was giving the proposal of handshake
			new targetid = GetPlayerHandshakeOfferer(playerid);

			// Closes the player dialog
			ShowPlayerDialog(targetid, -1, 0, " ", " ", " ", " ");
			if(!response)
			{
				SendClientMessage(playerid, 0xBFBEBEFF, "* Voc?? cancelou a oferta de aperto de m??o.");
				SendClientMessage(targetid, 0xBFBEBEFF, "* O jogador cancelou a oferta de aperto de m??o.");

				new message[31 + MAX_PLAYER_NAME];
				format(message, sizeof(message), "recusou o aperto de m??o de %s.", GetPlayerNamef(targetid));
				SendClientActionMessage(playerid, 15.0, message);

				g_p_hshake[targetid] = INVALID_PLAYER_ID;
			}
			else
			{
				if(GetPlayerDistanceFromPlayer(playerid, targetid) > 1.0)
				{
					SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o est?? pr??ximo ao jogador.");
					SendClientMessage(targetid, COLOR_ERROR, "* Voc?? n??o est?? pr??ximo ao jogador.");
					g_p_hshake[targetid] = INVALID_PLAYER_ID;
					return -2;
				}

				new Float:a;
				GetPlayerFacingAngle(playerid, a);

				a += 180.0;
				if(a > 359.0)
					a -= 359.0;

				SetPlayerFacingAngle(targetid, a);

				new message[20 + MAX_PLAYER_NAME];
				format(message, sizeof(message), "aperta a m??o de %s.", GetPlayerNamef(targetid));
				SendClientActionMessage(playerid, 15.0, message);

				switch(g_p_hshakestyle[targetid])
				{
					case 1:
					{
						ApplyAnimation(playerid, "GANGS", "hndshkaa", 4.1, 0, 1, 1, 0, 0, 1);
						ApplyAnimation(targetid, "GANGS", "hndshkaa", 4.1, 0, 1, 1, 0, 0, 1);
					}
					case 2:
					{
						ApplyAnimation(playerid, "GANGS", "hndshkba", 4.1, 0, 1, 1, 0, 0, 1);
						ApplyAnimation(targetid, "GANGS", "hndshkba", 4.1, 0, 1, 1, 0, 0, 1);
					}
					case 3:
					{
						ApplyAnimation(playerid, "GANGS", "hndshkca", 4.1, 0, 1, 1, 0, 0, 1);
						ApplyAnimation(targetid, "GANGS", "hndshkca", 4.1, 0, 1, 1, 0, 0, 1);
					}
					case 4:
					{
						ApplyAnimation(playerid, "GANGS", "hndshkcb", 4.1, 0, 1, 1, 0, 0, 1);
						ApplyAnimation(targetid, "GANGS", "hndshkcb", 4.1, 0, 1, 1, 0, 0, 1);
					}
					case 5:
					{
						ApplyAnimation(playerid, "GANGS", "hndshkda", 4.1, 0, 1, 1, 0, 0, 1);
						ApplyAnimation(targetid, "GANGS", "hndshkda", 4.1, 0, 1, 1, 0, 0, 1);
					}
					case 6:
					{
						ApplyAnimation(playerid, "GANGS", "hndshkea", 4.1, 0, 1, 1, 0, 0, 1);
						ApplyAnimation(targetid, "GANGS", "hndshkea", 4.1, 0, 1, 1, 0, 0, 1);
					}
					case 7:
					{
						ApplyAnimation(playerid, "GANGS", "hndshkfa", 4.1, 0, 1, 1, 0, 0, 1);
						ApplyAnimation(targetid, "GANGS", "hndshkfa", 4.1, 0, 1, 1, 0, 0, 1);
					}
					case 8:
					{
						ApplyAnimation(playerid, "GANGS", "hndshkfa_swt", 4.1, 0, 1, 1, 0, 0, 1);
						ApplyAnimation(targetid, "GANGS", "hndshkfa_swt", 4.1, 0, 1, 1, 0, 0, 1);
					}
				}
				g_p_hshake[targetid] = INVALID_PLAYER_ID;
			}
			return -2;
		}
	}
	return 1;
}

/***
 *     ######   #######  ##     ## ##     ##    ###    ##    ## ########   ######
 *    ##    ## ##     ## ###   ### ###   ###   ## ##   ###   ## ##     ## ##    ##
 *    ##       ##     ## #### #### #### ####  ##   ##  ####  ## ##     ## ##
 *    ##       ##     ## ## ### ## ## ### ## ##     ## ## ## ## ##     ##  ######
 *    ##       ##     ## ##     ## ##     ## ######### ##  #### ##     ##       ##
 *    ##    ## ##     ## ##     ## ##     ## ##     ## ##   ### ##     ## ##    ##
 *     ######   #######  ##     ## ##     ## ##     ## ##    ## ########   ######
 ***/

/*
	offers a handshake to a player
*/

YCMD:apertarmao(playerid, params[], help)
{
	new
		targetid,
		style
	;
	if(IsPlayerOfferingHandshake(playerid))
		SendClientMessage(playerid, COLOR_ERROR, "* Voc?? j?? ofereceu um aperto de m??o.");
	else if(GetPlayerHandshakeOfferer(playerid) != INVALID_PLAYER_ID)
		SendClientMessage(playerid, COLOR_ERROR, "* Voc?? precisa responder o aperto de m??o pendente primeiro.");
	else if(IsPlayerInAnyVehicle(playerid))
		SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o pode estar em um ve??culo.");
	else if(sscanf(params, "k<u>i", targetid, style))
		SendClientMessage(playerid, COLOR_INFO, "* /apertarmao [playerid] [estilo <1-8>]");
	else if(style < 1 || style > 8)
		SendClientMessage(playerid, COLOR_ERROR, "* Apenas estilos entre 1 e 8.");
	else if(playerid == targetid)
		SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o pode apertar sua m??o.");
	else if(GetPlayerDistanceFromPlayer(playerid, targetid) > 1.0)
		SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o est?? pr??ximo ao jogador.");
	else if(IsPlayerInAnyVehicle(targetid))
		SendClientMessage(playerid, COLOR_ERROR, "* O jogador n??o pode estar em um ve??culo.");
	else if(IsPlayerOfferingHandshake(targetid))
		SendClientMessage(playerid, COLOR_ERROR, "* O jogador est?? aguardando uma oferta de aperto de m??o.");
	else if(GetPlayerHandshakeOfferer(targetid) != INVALID_PLAYER_ID)
		SendClientMessage(playerid, COLOR_ERROR, "* O jogador est?? decidindo um aperto de m??o pendente.");
	else
	{
		new info[93 + MAX_PLAYER_NAME];
		format(info, sizeof(info), "{ffffff}Voc?? ofereceu um aperto de m??o ?? {CEE6ED}%s{ffffff}, aguarde ele aceitar ou recusar.", GetPlayerNamef(targetid));
		ShowPlayerDialog(playerid, DIALOG_HANDSHAKE_OFFER, DIALOG_STYLE_MSGBOX, "Aperto de m??o", info, "Cancelar", "");

		format(info, sizeof(info), "{CEE6ED}%s{ffffff} est?? te oferecendo um aperto de m??o.", GetPlayerNamef(playerid));
		ShowPlayerDialog(targetid, DIALOG_HANDSHAKE_ACCEPT, DIALOG_STYLE_MSGBOX, "Aperto de m??o", info, "Aceitar", "Recusar");

		g_p_hshake[playerid] = targetid;
		g_p_hshakestyle[playerid] = style;

		new message[50 + MAX_PLAYER_NAME];
		format(message, sizeof(message), "estende a m??o para %s e oferece um aperto de m??o.", GetPlayerNamef(targetid));
		SendClientActionMessage(playerid, 15.0, message);
	}
	return 1;
}
