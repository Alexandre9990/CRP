/*******************************************************************************
* FILENAME :        modules/data/player.pwn
*
* DESCRIPTION :
*       Saves and Loads all player data
*
* NOTES :
*       This file should only contain information about player's data.
*       This is not intended to handle player actions and such.
*
*       Copyright Paradise Devs 2015.  All rights reserved.
*
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

#define         START_X         1449.01
#define         START_Y         -2287.10
#define         START_Z         13.54
#define         START_A         96.36
#define         START_INT       0
#define         START_VW        0

//------------------------------------------------------------------------------

forward OnPlayerLevelUp(playerid, oldlevel, newlevel);

//------------------------------------------------------------------------------

enum e_player_adata
{
    e_player_database_id,
    e_player_password[MAX_PLAYER_PASSWORD],
    e_player_regdate,
    e_player_ip[16],
    e_player_lastlogin,
    e_player_playedtime,
    e_player_login_expire
}
static gPlayerAccountData[MAX_PLAYERS][e_player_adata];

//------------------------------------------------------------------------------

enum e_player_pdata
{
    Float:e_player_x,
    Float:e_player_y,
    Float:e_player_z,
    Float:e_player_a,
    e_player_int,
    e_player_vw,
    e_player_spawn
}
static gPlayerPositionData[MAX_PLAYERS][e_player_pdata];

//------------------------------------------------------------------------------

enum e_player_cdata
{
    e_player_skin,
    e_player_gender,
    e_player_money,
    e_player_bank,
    e_player_baccount,
    e_player_faction,
    e_player_frank,
    e_player_ticket,
    Job:e_player_jobid,
    e_player_jobxp,
    e_player_joblv,
    e_player_level,
    e_player_xp,
    e_player_fstyle,
    Float:e_player_health,
    Float:e_player_armour,
    Float:e_player_hunger,
	Float:e_player_thirst,
	Float:e_player_sleep,
	Float:e_player_addiction
}
static gPlayerCharacterData[MAX_PLAYERS][e_player_cdata];

//------------------------------------------------------------------------------

enum e_player_phdata
{
    e_player_phone_number,
    e_player_phone_network,
    e_player_phone_credits,
    e_player_phone_state
}

static gPlayerPhoneData[MAX_PLAYERS][e_player_phdata];

//------------------------------------------------------------------------------

enum e_player_ldata
{
    e_player_car_license,
    e_player_bike_license,
    e_player_truck_license,
    e_player_heli_license,
    e_player_plane_license,
    e_player_boat_license
}

static gPlayerLicenseData[MAX_PLAYERS][e_player_ldata];

//------------------------------------------------------------------------------

enum e_player_wdata
{
    e_player_weapon[13],
    e_player_ammo[13],
    e_player_weapon_skill[11]
}
static gPlayerWeaponData[MAX_PLAYERS][e_player_wdata];

//------------------------------------------------------------------------------

enum e_player_idata
{
    e_player_agenda,
    e_player_gps,
    e_player_lighter,
    e_player_cigaretts,
    e_player_walkietalkie
}
static gPlayerItemData[MAX_PLAYERS][e_player_idata];
//------------------------------------------------------------------------------

static bool:gIsPlayerLogged[MAX_PLAYERS];
static bool:gIsPlayerRegistered[MAX_PLAYERS];

//------------------------------------------------------------------------------

forward OnBanCheck(playerid);
forward OnWeaponsLoad(playerid);
forward OnAccountLoad(playerid);
forward OnAccountCheck(playerid);
forward OnAccountRegister(playerid);
forward OnChangeNameRequest(playerid, name[]);

//------------------------------------------------------------------------------

// Registering temporary vars
static gPlayerAge[MAX_PLAYERS][11];
static gPlayerName[MAX_PLAYERS][64];
static gPlayerEmail[MAX_PLAYERS][128];
static gPlayerGender[MAX_PLAYERS];

//------------------------------------------------------------------------------

LoadPlayerAccount(playerid)
{
    new query[57 + MAX_PLAYER_NAME + 1], playerName[MAX_PLAYER_NAME + 1];
    GetPlayerName(playerid, playerName, sizeof(playerName));
    mysql_format(mysql, query, sizeof(query),"SELECT * FROM `players` WHERE `user_id` = %d LIMIT 1", gPlayerAccountData[playerid][e_player_database_id]);
    mysql_tquery(mysql, query, "OnAccountLoad", "i", playerid);
}

//------------------------------------------------------------------------------

LoadPlayerWeapons(playerid)
{
    new query[66];
    mysql_format(mysql, query, sizeof(query), "SELECT weaponid, ammo FROM player_weapons WHERE userid = %d;", gPlayerAccountData[playerid][e_player_database_id]);
    mysql_tquery(mysql, query, "OnWeaponsLoad", "i", playerid);
}

//------------------------------------------------------------------------------

ResetPlayerData(playerid)
{
    // Current Time
    new ct = gettime();

    // Reset all player status
    gIsPlayerLogged[playerid] = false;
    gIsPlayerRegistered[playerid] = false;

    gPlayerAccountData[playerid][e_player_database_id]  = 0;
    gPlayerAccountData[playerid][e_player_regdate]      = ct;
    gPlayerAccountData[playerid][e_player_lastlogin]    = ct;
    gPlayerAccountData[playerid][e_player_playedtime]   = 0;
    gPlayerAccountData[playerid][e_player_login_expire] = 0;

    gPlayerPositionData[playerid][e_player_x]           = 1449.01;
    gPlayerPositionData[playerid][e_player_y]           = -2287.10;
    gPlayerPositionData[playerid][e_player_z]           = 13.54;
    gPlayerPositionData[playerid][e_player_a]           = 96.36;
    gPlayerPositionData[playerid][e_player_int]         = 0;
    gPlayerPositionData[playerid][e_player_vw]          = 0;
    gPlayerPositionData[playerid][e_player_spawn]       = LAST_POSITION;

    gPlayerCharacterData[playerid][e_player_gender]     = 0;
    gPlayerCharacterData[playerid][e_player_money]      = 350;
    gPlayerCharacterData[playerid][e_player_bank]       = 0;
    gPlayerCharacterData[playerid][e_player_baccount]   = 0;
    gPlayerCharacterData[playerid][e_player_skin]       = 299;
    gPlayerCharacterData[playerid][e_player_faction]    = 0;
    gPlayerCharacterData[playerid][e_player_frank]      = 0;
    gPlayerCharacterData[playerid][e_player_ticket]     = 0;
    gPlayerCharacterData[playerid][e_player_jobid]      = INVALID_JOB_ID;
    gPlayerCharacterData[playerid][e_player_jobxp]      = 0;
    gPlayerCharacterData[playerid][e_player_joblv]      = 1;
    gPlayerCharacterData[playerid][e_player_xp]         = 0;
    gPlayerCharacterData[playerid][e_player_fstyle]     = FIGHT_STYLE_NORMAL;
    gPlayerCharacterData[playerid][e_player_health]     = 100.0;
    gPlayerCharacterData[playerid][e_player_armour]     = 0.0;
    gPlayerCharacterData[playerid][e_player_hunger]     = 50.0;
    gPlayerCharacterData[playerid][e_player_thirst]     = 50.0;
    gPlayerCharacterData[playerid][e_player_sleep]      = 50.0;
    gPlayerCharacterData[playerid][e_player_addiction]  = 0.0;

    gPlayerPhoneData[playerid][e_player_phone_number]   = 0;
    gPlayerPhoneData[playerid][e_player_phone_network]  = -1;
    gPlayerPhoneData[playerid][e_player_phone_credits]  = 0;
    gPlayerPhoneData[playerid][e_player_phone_state]    = 0;

    gPlayerLicenseData[playerid][e_player_car_license]  = 0;
    gPlayerLicenseData[playerid][e_player_bike_license]  = 0;
    gPlayerLicenseData[playerid][e_player_truck_license]  = 0;
    gPlayerLicenseData[playerid][e_player_heli_license]  = 0;
    gPlayerLicenseData[playerid][e_player_plane_license]  = 0;
    gPlayerLicenseData[playerid][e_player_boat_license]  = 0;

    for (new i = 0; i < sizeof(gPlayerWeaponData[][]); i++)
        gPlayerWeaponData[playerid][e_player_weapon][i] = 0;

    for(new i = 0; i < sizeof(gPlayerWeaponData[][]); i++)
    	gPlayerWeaponData[playerid][e_player_weapon_skill][i] = 0;

    gPlayerItemData[playerid][e_player_agenda]          = 0;
    gPlayerItemData[playerid][e_player_gps]             = 0;
    gPlayerItemData[playerid][e_player_lighter]         = 0;
    gPlayerItemData[playerid][e_player_cigaretts]       = 0;
    gPlayerItemData[playerid][e_player_walkietalkie]    = 0;

    SetPlayerLevel(playerid, 1);
    SetPlayerRank(playerid, PLAYER_RANK_PLAYER);
    SetPlayerHouseID(playerid, INVALID_HOUSE_ID);
    SetPlayerBusinessID(playerid, INVALID_BUSINESS_ID);
    SetPlayerApartmentKey(playerid, INVALID_APARTMENT_ID);
}

//------------------------------------------------------------------------------

GetPlayerFactionID(playerid)
{
    return gPlayerCharacterData[playerid][e_player_faction];
}

SetPlayerFactionID(playerid, fid)
{
    gPlayerCharacterData[playerid][e_player_faction] = fid;
}

GetPlayerFactionRankID(playerid)
{
    return gPlayerCharacterData[playerid][e_player_frank];
}

SetPlayerFactionRankID(playerid, frank)
{
    gPlayerCharacterData[playerid][e_player_frank] = frank;
}

//------------------------------------------------------------------------------

GetPlayerSpawnPosition(playerid)
{
    return gPlayerPositionData[playerid][e_player_spawn];
}

//------------------------------------------------------------------------------

SetPlayerSpawnPosition(playerid, pos)
{
    gPlayerPositionData[playerid][e_player_spawn] = pos;
}

//------------------------------------------------------------------------------

GetPlayerCash(playerid)
{
    return gPlayerCharacterData[playerid][e_player_money];
}

GetPlayerBankAccount(playerid)
{
    return gPlayerCharacterData[playerid][e_player_baccount];
}

SetPlayerBankAccount(playerid, val)
{
    gPlayerCharacterData[playerid][e_player_baccount] = val;
}

GetPlayerBankCash(playerid)
{
    return gPlayerCharacterData[playerid][e_player_bank];
}

SetPlayerBankCash(playerid, val)
{
    gPlayerCharacterData[playerid][e_player_bank] = val;
}

GivePlayerCash(playerid, money)
{
    ResetPlayerMoney(playerid);
    gPlayerCharacterData[playerid][e_player_money] += money;
    GivePlayerMoney(playerid, gPlayerCharacterData[playerid][e_player_money]);
}

SetPlayerCash(playerid, money)
{
    ResetPlayerMoney(playerid);
    gPlayerCharacterData[playerid][e_player_money] = money;
    GivePlayerMoney(playerid, money);
}

//------------------------------------------------------------------------------

IsPlayerLogged(playerid)
{
    if(!IsPlayerConnected(playerid))
        return false;

    if(gIsPlayerLogged[playerid])
        return true;

    return false;
}

IsPlayerRegistered(playerid)
{
    if(!IsPlayerConnected(playerid))
        return false;

    if(gIsPlayerRegistered[playerid])
        return true;

    return false;
}

//------------------------------------------------------------------------------

SetPlayerLogged(playerid, bool:set)
{
    gIsPlayerLogged[playerid] = set;

    new query[56];
	mysql_format(mysql, query, sizeof(query), "UPDATE `players` SET `isOnline`=%d WHERE `user_id`=%d", set, GetPlayerDatabaseID(playerid));
	mysql_tquery(mysql, query);
}

SetPlayerRegistered(playerid, bool:set)
{
    gIsPlayerRegistered[playerid] = set;
}

//------------------------------------------------------------------------------

GetPlayerIPf(playerid)
{
    new ip[16];
    GetPlayerIp(playerid, ip, 16);
    return ip;
}

GetPlayerRegDataUnix(playerid)
{
    return gPlayerAccountData[playerid][e_player_regdate];
}

GetPlayerLastLoginUnix(playerid)
{
    return gPlayerAccountData[playerid][e_player_lastlogin];
}

GetPlayerLoginExpire(playerid)
{
    return gPlayerAccountData[playerid][e_player_login_expire];
}

GetPlayerPlayedTimeStamp(playerid)
{
	new playedTime[32];
	if(GetPlayerPlayedTime(playerid) < 86400)
		format(playedTime, sizeof(playedTime), "%02dh %02dm %02ds", (GetPlayerPlayedTime(playerid) / 3600), (GetPlayerPlayedTime(playerid) - (3600 * (GetPlayerPlayedTime(playerid) / 3600))) / 60, (GetPlayerPlayedTime(playerid) % 60));
	else
		 format(playedTime, sizeof(playedTime), "%02dd %02dh %02dm %02ds", GetPlayerPlayedTime(playerid) / 86400, (GetPlayerPlayedTime(playerid) - (86400 * (GetPlayerPlayedTime(playerid) / 86400))) / 3600, (GetPlayerPlayedTime(playerid) - (3600 * (GetPlayerPlayedTime(playerid) / 3600))) / 60, (GetPlayerPlayedTime(playerid) % 60));
	return playedTime;
}

GetPlayerPlayedTime(playerid)
{
    return gPlayerAccountData[playerid][e_player_playedtime];
}

SetPlayerPlayedTime(playerid, time)
{
    gPlayerAccountData[playerid][e_player_playedtime] = time;
}

//------------------------------------------------------------------------------

GetPlayerLotteryTicket(playerid)
{
    return gPlayerCharacterData[playerid][e_player_ticket];
}

SetPlayerLotteryTicket(playerid, value)
{
    gPlayerCharacterData[playerid][e_player_ticket] = value;
}

//------------------------------------------------------------------------------

Float:GetPlayerHunger(playerid)
{
    return gPlayerCharacterData[playerid][e_player_hunger];
}

SetPlayerHunger(playerid, Float:value)
{
    if(value < 0.0) value = 0.0;
	else if(value > 100.0) value = 100.0;
    gPlayerCharacterData[playerid][e_player_hunger] = value;
}

Float:GetPlayerThirst(playerid)
{
    return gPlayerCharacterData[playerid][e_player_thirst];
}

SetPlayerThirst(playerid, Float:value)
{
    if(value < 0.0) value = 0.0;
	else if(value > 100.0) value = 100.0;
    gPlayerCharacterData[playerid][e_player_thirst] = value;
}

Float:GetPlayerSleep(playerid)
{
    return gPlayerCharacterData[playerid][e_player_sleep];
}

SetPlayerSleep(playerid, Float:value)
{
    if(value < 0.0) value = 0.0;
    else if(value > 100.0) value = 100.0;
    gPlayerCharacterData[playerid][e_player_sleep] = value;
}

Float:GetPlayerAddiction(playerid)
{
    return gPlayerCharacterData[playerid][e_player_addiction];
}

SetPlayerAddiction(playerid, Float:value)
{
    if(value < 0.0) value = 0.0;
    else if(value > 100.0) value = 100.0;
    gPlayerCharacterData[playerid][e_player_addiction] = value;
}

//------------------------------------------------------------------------------

Job:GetPlayerJobID(playerid)
{
    return gPlayerCharacterData[playerid][e_player_jobid];
}

SetPlayerJobID(playerid, Job:id)
{
    gPlayerCharacterData[playerid][e_player_jobid] = id;
    gPlayerCharacterData[playerid][e_player_joblv] = 1;
    gPlayerCharacterData[playerid][e_player_jobxp] = 0;
}

GetPlayerJobLV(playerid)
{
    return gPlayerCharacterData[playerid][e_player_joblv];
}

SetPlayerJobLV(playerid, val)
{
    gPlayerCharacterData[playerid][e_player_joblv] = val;
}

GetPlayerJobRequiredXP(playerid)
{
    switch(gPlayerCharacterData[playerid][e_player_jobid])
    {
        case TRUCKER_JOB_ID:
            return 90 * gPlayerCharacterData[playerid][e_player_joblv];
        case PILOT_JOB_ID, LUMBERJACK_JOB_ID, NAVIGATOR_JOB_ID, PARAMEDIC_JOB_ID, GARBAGE_JOB_ID, FISHER_JOB_ID, TECHNICAL_JOB_ID:
            return 125 * gPlayerCharacterData[playerid][e_player_joblv];
    }
    return 125;
}

GetPlayerJobXP(playerid)
{
    return gPlayerCharacterData[playerid][e_player_jobxp];
}

SetPlayerJobXP(playerid, val)
{
    gPlayerCharacterData[playerid][e_player_jobxp] = val;
}

//------------------------------------------------------------------------------

GetPlayerLevel(playerid)
{
    return gPlayerCharacterData[playerid][e_player_level];
}

SetPlayerLevel(playerid, val)
{
    SetPlayerScore(playerid, val);
    gPlayerCharacterData[playerid][e_player_level] = val;
    UpdatePlayerBar(playerid);
}

GetPlayerXP(playerid)
{
    return gPlayerCharacterData[playerid][e_player_xp];
}

SetPlayerXP(playerid, val)
{
    if((gPlayerCharacterData[playerid][e_player_xp] + val) >= GetPlayerRequiredXP(playerid) && GetPlayerLevel(playerid) == MAX_LEVEL)
    {
        SetPlayerXP(playerid, GetPlayerRequiredXP(playerid));
    }
    else
    {
        gPlayerCharacterData[playerid][e_player_xp] = val;
        if(GetPlayerXP(playerid) >= GetPlayerRequiredXP(playerid))
        {
            OnPlayerLevelUp(playerid, GetPlayerLevel(playerid), GetPlayerLevel(playerid) + 1);
        }
        UpdatePlayerBar(playerid);
    }
}

stock GetPlayerRequiredXP(playerid)
{
    return gPlayerCharacterData[playerid][e_player_level] * 150;
}

//------------------------------------------------------------------------------

GetPlayerCarLicense(playerid)
{
    return gPlayerLicenseData[playerid][e_player_car_license];
}

SetPlayerCarLicense(playerid, value)
{
    gPlayerLicenseData[playerid][e_player_car_license] = value;
}

GetPlayerBikeLicense(playerid)
{
    return gPlayerLicenseData[playerid][e_player_bike_license];
}

SetPlayerBikeLicense(playerid, value)
{
    gPlayerLicenseData[playerid][e_player_bike_license] = value;
}

GetPlayerTruckLicense(playerid)
{
    return gPlayerLicenseData[playerid][e_player_truck_license];
}

GetPlayerHeliLicense(playerid)
{
    return gPlayerLicenseData[playerid][e_player_heli_license];
}

GetPlayerPlaneLicense(playerid)
{
    return gPlayerLicenseData[playerid][e_player_plane_license];
}

GetPlayerBoatLicense(playerid)
{
    return gPlayerLicenseData[playerid][e_player_boat_license];
}

//------------------------------------------------------------------------------

GetPlayerPhoneNumber(playerid)
{
    return gPlayerPhoneData[playerid][e_player_phone_number];
}

SetPlayerPhoneNumber(playerid, val)
{
    gPlayerPhoneData[playerid][e_player_phone_number] = val;
}

SetPlayerPhoneNetwork(playerid, val)
{
    gPlayerPhoneData[playerid][e_player_phone_network] = val;
}

GetPlayerPhoneNetwork(playerid)
{
    return gPlayerPhoneData[playerid][e_player_phone_network];
}

GetPlayerPhoneState(playerid)
{
    return gPlayerPhoneData[playerid][e_player_phone_state];
}

SetPlayerPhoneState(playerid, val)
{
    gPlayerPhoneData[playerid][e_player_phone_state] = val;
}

GetPlayerPhoneCredit(playerid)
{
    return gPlayerPhoneData[playerid][e_player_phone_credits];
}

SetPlayerPhoneCredit(playerid, val)
{
    gPlayerPhoneData[playerid][e_player_phone_credits] = val;
}

//------------------------------------------------------------------------------

SetPlayerAgenda(playerid, value)
{
    gPlayerItemData[playerid][e_player_agenda] = value;
}

GetPlayerAgenda(playerid)
{
    return gPlayerItemData[playerid][e_player_agenda];
}

SetPlayerGPS(playerid, value)
{
    gPlayerItemData[playerid][e_player_gps] = value;
}

GetPlayerGPS(playerid)
{
    return gPlayerItemData[playerid][e_player_gps];
}

SetPlayerLighter(playerid, value)
{
    gPlayerItemData[playerid][e_player_lighter] = value;
}

GetPlayerLighter(playerid)
{
    return gPlayerItemData[playerid][e_player_lighter];
}

SetPlayerCigaretts(playerid, value)
{
    gPlayerItemData[playerid][e_player_cigaretts] = value;
}

GetPlayerCigaretts(playerid)
{
    return gPlayerItemData[playerid][e_player_cigaretts];
}

SetPlayerWalkieTalkieFrequency(playerid, value)
{
    gPlayerItemData[playerid][e_player_walkietalkie] = value;
}

GetPlayerWalkieTalkieFrequency(playerid)
{
    return gPlayerItemData[playerid][e_player_walkietalkie];
}

//------------------------------------------------------------------------------

stock My_SetPlayerSkin(playerid, skin, bool:save_skin = false)
{
    if(save_skin) gPlayerCharacterData[playerid][e_player_skin] = skin;
    return SetPlayerSkin(playerid, skin);
}

#if defined _ALS_SetPlayerSkin
    #undef SetPlayerSkin
#else
    #define _ALS_SetPlayerSkin
#endif
#define SetPlayerSkin My_SetPlayerSkin

GetPlayerSavedSkin(playerid)
{
    return gPlayerCharacterData[playerid][e_player_skin];
}

GetPlayerGender(playerid)
{
    return gPlayerCharacterData[playerid][e_player_gender];
}

GetPlayerGenderName(playerid)
{
	new genderName[10];
	if(!GetPlayerGender(playerid))
		genderName = "Masculino";
	else
		genderName = "Feminino";
	return genderName;
}

//------------------------------------------------------------------------------

GetPlayerDatabaseID(playerid)
{
    return gPlayerAccountData[playerid][e_player_database_id];
}

//------------------------------------------------------------------------------

StorePlayerHealth(playerid)
{
    GetPlayerHealth(playerid, gPlayerCharacterData[playerid][e_player_health]);
}

Float:playerHealth(playerid)
{
    return gPlayerCharacterData[playerid][e_player_health];
}

//------------------------------------------------------------------------------

public OnPlayerLevelUp(playerid, oldlevel, newlevel)
{
    new extra_xp = GetPlayerXP(playerid) - GetPlayerRequiredXP(playerid);
	SetPlayerXP(playerid, extra_xp);
    SetPlayerLevel(playerid, newlevel);
    PlayerPlaySound(playerid, 5203, 0.0, 0.0, 0.0);
    GameTextForPlayer(playerid, "Level up", 5000, 1);
    SendClientMessagef(playerid, COLOR_SUCCESS, "* Voc?? acabou de subir para o level %d.", newlevel);

    if(newlevel == MAX_LEVEL)
    {
        SendClientMessage(playerid, 0xCCFF00FF, "* Parab??ns! Voc?? atingiu o n??vel m??xima atual do servidor.");
    }
    return 1;
}

//------------------------------------------------------------------------------

SavePlayerAccount(playerid)
{
    if(!IsPlayerLogged(playerid))
        return 0;

    new Float:x, Float:y, Float:z, Float:a, interior, world;
    if(IsPlayerInDriveSchool(playerid))
    {
        x = -2029.8218;
        y = -119.1891;
        z = 1035.1719;
        a = 0.0;
        world = 0;
        interior = 3;
    }
    if(IsPlayerBrowsingDealership(playerid))
    {
        world = 0;
        interior = 0;
        x = 559.9263;
        y = -1289.6732;
        z = 17.2482;
        a = 7.5971;
    }
    else if(IsPlayerIn8Track(playerid) || IsPlayerInMotocross(playerid))
    {
        world = 0;
        interior = 0;
        x = 2692.3247;
        y = -1703.2693;
        z = 11.1649;
        a = 38.1979;
    }
    else if(IsPlayerInPaintball(playerid))
    {
        world = 0;
        interior = 0;
        x = 557.2642;
        y = -1506.5464;
        z = 14.5510;
        a = 88.4013;
    }
    else if(IsPlayerInCityHallMission(playerid))
    {
        world = 0;
        interior = 0;
        x = 1480.9612;
        y = -1767.6107;
        z = 18.7958;
        a = 178.9622;
    }
    else if(GetPlayerSpawnPosition(playerid) == HOUSE_POSITION)
    {
        world = 0;
        interior = 0;
        GetApartmentEntrance(GetPlayerApartmentKey(playerid), x, y, z, a);
    }
    else
    {
        world = GetPlayerVirtualWorld(playerid);
        interior = GetPlayerInterior(playerid);
        GetPlayerPos(playerid, x, y, z);
        GetPlayerFacingAngle(playerid, a);
    }

    new Float:health, Float:armour;
    GetPlayerHealth(playerid, health);
    GetPlayerArmour(playerid, armour);

    new rankname[32];
    if(GetPlayerRank(playerid) > PLAYER_RANK_PLAYER)
        rankname = GetPlayerRankName(playerid, true);
    else
        rankname = GetJobName(GetPlayerJobID(playerid), true);

    // Account saving
    new query[1310];
	mysql_format(mysql, query, sizeof(query),
	"UPDATE `players` SET \
    `x`=%.2f, `y`=%.2f, `z`=%.2f, `a`=%.2f, `interior`=%d, `virtual_world`=%d, `spawn`=%d, \
    `rank`=%d, `rankname`='%s', `skin`=%d, `faction`=%d, `faction_rank`=%d, \
    `gender`=%d, `money`=%d, `bank`=%d, `baccount`=%d, \
    `hospital`=%d, `health`=%.2f, `armour`=%.2f, \
    `ip`='%s', `last_login`=%d, `played_time`=%d, \
    `achievements`=%d, `ticket`=%d, \
    `jobid`=%d, `jobxp`=%d, `joblv`=%d, \
    `XP`=%d, `level`=%d, \
    `ftime`=%d, \
    `phone_number`=%d, `phone_network`=%d, `phone_credits`=%d, `phone_state`=%d, \
    `hunger`=%.3f, `thirst`=%.3f, `sleep`=%.3f, `addiction`=%.3f, `apartkey`=%d, `housekey`=%d, `businesskey`=%d, \
    `WeaponSkillPistol`=%d, `WeaponSkillSilenced`=%d, `WeaponSkillDeagle`=%d, `WeaponSkillShotgun`=%d, `WeaponSkillSawnoff`=%d, \
    `WeaponSkillSpas12`=%d, `WeaponSkillUzi`=%d, `WeaponSkillMP5`=%d, `WeaponSkillAK47`=%d, `WeaponSkillM4`=%d, `WeaponSkillSniper`=%d, \
    `agenda`=%d, `gps`=%d, `lighter`=%d, `cigaretts`=%d, `walkietalkie`=%d, \
    `carlic`=%d, `bikelic`=%d, `trucklic`=%d, `helilic`=%d, `planelic`=%d, `boatlic`=%d, \
    `fstyle`=%d, `prision_time`=%d, `cartheft_time`=%d \
    WHERE `user_id`=%d",
    x, y, z, a, interior, world, GetPlayerSpawnPosition(playerid),
    GetPlayerRank(playerid), rankname, gPlayerCharacterData[playerid][e_player_skin], gPlayerCharacterData[playerid][e_player_faction], gPlayerCharacterData[playerid][e_player_frank],
    GetPlayerGender(playerid), GetPlayerCash(playerid), gPlayerCharacterData[playerid][e_player_bank], gPlayerCharacterData[playerid][e_player_baccount],
    GetPlayerHospitalTime(playerid), health, armour,
    GetPlayerIPf(playerid), gettime(), gPlayerAccountData[playerid][e_player_playedtime],
    GetPlayerAchievements(playerid), gPlayerCharacterData[playerid][e_player_ticket],
    _:gPlayerCharacterData[playerid][e_player_jobid], gPlayerCharacterData[playerid][e_player_jobxp], gPlayerCharacterData[playerid][e_player_joblv],
    GetPlayerXP(playerid), GetPlayerLevel(playerid),
    GetPlayerFirstTimeVar(playerid),
    gPlayerPhoneData[playerid][e_player_phone_number], gPlayerPhoneData[playerid][e_player_phone_network], gPlayerPhoneData[playerid][e_player_phone_credits], gPlayerPhoneData[playerid][e_player_phone_state],
    gPlayerCharacterData[playerid][e_player_hunger], gPlayerCharacterData[playerid][e_player_thirst], gPlayerCharacterData[playerid][e_player_sleep], gPlayerCharacterData[playerid][e_player_addiction], GetPlayerApartmentKey(playerid),
    GetPlayerHouseID(playerid), GetPlayerBusinessID(playerid),
    gPlayerWeaponData[playerid][e_player_weapon_skill][0], gPlayerWeaponData[playerid][e_player_weapon_skill][1], gPlayerWeaponData[playerid][e_player_weapon_skill][2],
    gPlayerWeaponData[playerid][e_player_weapon_skill][3], gPlayerWeaponData[playerid][e_player_weapon_skill][4], gPlayerWeaponData[playerid][e_player_weapon_skill][5],
    gPlayerWeaponData[playerid][e_player_weapon_skill][6], gPlayerWeaponData[playerid][e_player_weapon_skill][7], gPlayerWeaponData[playerid][e_player_weapon_skill][8],
    gPlayerWeaponData[playerid][e_player_weapon_skill][9], gPlayerWeaponData[playerid][e_player_weapon_skill][10],
    gPlayerItemData[playerid][e_player_agenda], gPlayerItemData[playerid][e_player_gps], gPlayerItemData[playerid][e_player_cigaretts], gPlayerItemData[playerid][e_player_lighter], gPlayerItemData[playerid][e_player_walkietalkie],
    gPlayerLicenseData[playerid][e_player_car_license], gPlayerLicenseData[playerid][e_player_bike_license], gPlayerLicenseData[playerid][e_player_truck_license],
    gPlayerLicenseData[playerid][e_player_heli_license], gPlayerLicenseData[playerid][e_player_plane_license], gPlayerLicenseData[playerid][e_player_boat_license],
    GetPlayerFightingStyle(playerid), GetPlayerPrisionTime(playerid), GetPlayerCarTheftTimer(playerid),
    gPlayerAccountData[playerid][e_player_database_id]);
	mysql_pquery(mysql, query);

    if(!IsPlayerInPaintball(playerid))
    {
        // Weapon saving
        new weaponid, ammo;
        for(new i; i < 13; i++)
        {
        	GetPlayerWeaponData(playerid, i, weaponid, ammo);

        	if(!weaponid)
                continue;

        	mysql_format(mysql, query, sizeof(query), "INSERT INTO player_weapons VALUES (%d, %d, %d) ON DUPLICATE KEY UPDATE ammo = %d;", gPlayerAccountData[playerid][e_player_database_id], weaponid, ammo, ammo);
        	mysql_pquery(mysql, query);
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

public OnAccountRegister(playerid)
{
    gPlayerAccountData[playerid][e_player_database_id] = cache_insert_id();

    SetPlayerColor(playerid, 0xFFFFFFFF);
    SetPlayerInterior(playerid, START_INT);
    SetPlayerVirtualWorld(playerid, START_VW);
    SetSpawnInfo(playerid, 255, (!gPlayerGender[playerid]) ? 299 : 298, START_X, START_Y, START_Z, START_A, 0, 0, 0, 0, 0, 0);
    ShowTutorialForPlayer(playerid);
    gPlayerCharacterData[playerid][e_player_gender] = gPlayerGender[playerid];

    new query[250];
    mysql_format(mysql, query, sizeof(query), "INSERT INTO players (user_id, x, y, z, a, gender, skin) VALUES (%d, %.2f, %.2f, %.2f, %.2f, %d, %d)", gPlayerAccountData[playerid][e_player_database_id], START_X, START_Y, START_Z, START_A, (!gPlayerCharacterData[playerid][e_player_gender]) ? 299 : 298, gPlayerCharacterData[playerid][e_player_gender]);
    mysql_tquery(mysql, query);

    new playerName[MAX_PLAYER_NAME];
    GetPlayerName(playerid, playerName, sizeof(playerName));
    SendAdminMessage(PLAYER_RANK_MODERATOR, 0x3A9BF4FF, "%s{FFFFFF} registrou-se no servidor.", GetPlayerFirstName(playerid));
	printf("[mysql] new account registered on database. ID: %d, Username: %s", gPlayerAccountData[playerid][e_player_database_id], playerName);
	return 1;
}

//------------------------------------------------------------------------------

public OnWeaponsLoad(playerid)
{
	new weaponid, ammo;
	for(new i, j = cache_get_row_count(mysql); i < j; i++)
	{
	    weaponid 	= cache_get_row_int(i, 0, mysql);
	    ammo    	= cache_get_row_int(i, 1, mysql);

		if(!(0 <= weaponid <= 46))
		{
			printf("[info] Warning: OnWeaponsLoad - Unknown weaponid '%d'. Skipping.", weaponid);
			continue;
		}

        if(ammo < 1)
            continue;

		GivePlayerWeapon(playerid, weaponid, ammo);
	}
	return;
}

//------------------------------------------------------------------------------

GivePlayerWeapons(playerid)
{
    for(new j = 0; j < 13; j++)
        if(gPlayerWeaponData[playerid][e_player_weapon][j] != 0)
            GivePlayerWeapon(playerid, gPlayerWeaponData[playerid][e_player_weapon][j], gPlayerWeaponData[playerid][e_player_ammo][j]);
}

GetPlayerWeaponsData(playerid)
{
    for(new i = 0; i < 13; i++)
        GetPlayerWeaponData(playerid, i, gPlayerWeaponData[playerid][e_player_weapon][i], gPlayerWeaponData[playerid][e_player_ammo][i]);
}

SetPlayerWeaponSkill(playerid, id, val)
{
    if(id < 0 || id > sizeof(gPlayerWeaponData[][]))
        return 0;

    gPlayerWeaponData[playerid][e_player_weapon_skill][id] = val;
    return 1;
}

GetPlayerWeaponSkill(playerid, id)
{
    if(id < 0 || id > sizeof(gPlayerWeaponData[][]))
        return 0;

    return gPlayerWeaponData[playerid][e_player_weapon_skill][id];
}

//------------------------------------------------------------------------------

public OnAccountLoad(playerid)
{
	new rows, fields;
	cache_get_data(rows, fields, mysql);
	if(rows > 0)
	{
        GetPlayerIp(playerid, gPlayerAccountData[playerid][e_player_ip], 16);
        gPlayerAccountData[playerid][e_player_lastlogin]            = cache_get_field_content_int(0, "last_login", mysql);
        gPlayerAccountData[playerid][e_player_playedtime]           = cache_get_field_content_int(0, "played_time", mysql);

        gPlayerPositionData[playerid][e_player_x]                   = cache_get_field_content_float(0, "x", mysql);
        gPlayerPositionData[playerid][e_player_y]                   = cache_get_field_content_float(0, "y", mysql);
        gPlayerPositionData[playerid][e_player_z]                   = cache_get_field_content_float(0, "z", mysql);
        gPlayerPositionData[playerid][e_player_a]                   = cache_get_field_content_float(0, "a", mysql);
        gPlayerPositionData[playerid][e_player_int]                 = cache_get_field_content_int(0, "interior", mysql);
        gPlayerPositionData[playerid][e_player_vw]                  = cache_get_field_content_int(0, "virtual_world", mysql);
        gPlayerPositionData[playerid][e_player_spawn]               = cache_get_field_content_int(0, "spawn", mysql);

        gPlayerCharacterData[playerid][e_player_skin]               = cache_get_field_content_int(0, "skin", mysql);
        gPlayerCharacterData[playerid][e_player_health]             = cache_get_field_content_int(0, "health", mysql);
        gPlayerCharacterData[playerid][e_player_armour]             = cache_get_field_content_int(0, "armour", mysql);
        gPlayerCharacterData[playerid][e_player_faction]            = cache_get_field_content_int(0, "faction", mysql);
        gPlayerCharacterData[playerid][e_player_frank]              = cache_get_field_content_int(0, "faction_rank", mysql);
        gPlayerCharacterData[playerid][e_player_gender]             = cache_get_field_content_int(0, "gender", mysql);
        gPlayerCharacterData[playerid][e_player_money]              = cache_get_field_content_int(0, "money", mysql);
        gPlayerCharacterData[playerid][e_player_bank]               = cache_get_field_content_int(0, "bank", mysql);
        gPlayerCharacterData[playerid][e_player_baccount]           = cache_get_field_content_int(0, "baccount", mysql);
        gPlayerCharacterData[playerid][e_player_ticket]             = cache_get_field_content_int(0, "ticket", mysql);
        gPlayerCharacterData[playerid][e_player_jobid]              = Job:cache_get_field_content_int(0, "jobid", mysql);
        gPlayerCharacterData[playerid][e_player_joblv]              = cache_get_field_content_int(0, "joblv", mysql);
        gPlayerCharacterData[playerid][e_player_jobxp]              = cache_get_field_content_int(0, "jobxp", mysql);
        gPlayerCharacterData[playerid][e_player_level]              = cache_get_field_content_int(0, "level", mysql);
        gPlayerCharacterData[playerid][e_player_xp]                 = cache_get_field_content_int(0, "xp", mysql);
        gPlayerCharacterData[playerid][e_player_fstyle]             = cache_get_field_content_int(0, "fstyle", mysql);
        gPlayerCharacterData[playerid][e_player_hunger]             = cache_get_field_content_float(0, "hunger", mysql);
        gPlayerCharacterData[playerid][e_player_thirst]             = cache_get_field_content_float(0, "thirst", mysql);
        gPlayerCharacterData[playerid][e_player_sleep]              = cache_get_field_content_float(0, "sleep", mysql);
        gPlayerCharacterData[playerid][e_player_addiction]          = cache_get_field_content_float(0, "addiction", mysql);

        gPlayerPhoneData[playerid][e_player_phone_number]           = cache_get_field_content_int(0, "phone_number", mysql);
        gPlayerPhoneData[playerid][e_player_phone_network]          = cache_get_field_content_int(0, "phone_network", mysql);
        gPlayerPhoneData[playerid][e_player_phone_credits]          = cache_get_field_content_int(0, "phone_credits", mysql);
        gPlayerPhoneData[playerid][e_player_phone_state]            = cache_get_field_content_int(0, "phone_state", mysql);

        gPlayerLicenseData[playerid][e_player_car_license]          = cache_get_field_content_int(0, "carlic", mysql);
        gPlayerLicenseData[playerid][e_player_bike_license]         = cache_get_field_content_int(0, "bikelic", mysql);
        gPlayerLicenseData[playerid][e_player_truck_license]        = cache_get_field_content_int(0, "trucklic", mysql);
        gPlayerLicenseData[playerid][e_player_heli_license]         = cache_get_field_content_int(0, "helilic", mysql);
        gPlayerLicenseData[playerid][e_player_plane_license]        = cache_get_field_content_int(0, "planelic", mysql);
        gPlayerLicenseData[playerid][e_player_boat_license]         = cache_get_field_content_int(0, "boatlic", mysql);

        gPlayerItemData[playerid][e_player_agenda]                  = cache_get_field_content_int(0, "agenda", mysql);
        gPlayerItemData[playerid][e_player_gps]                     = cache_get_field_content_int(0, "gps", mysql);
        gPlayerItemData[playerid][e_player_lighter]                 = cache_get_field_content_int(0, "lighter", mysql);
        gPlayerItemData[playerid][e_player_cigaretts]               = cache_get_field_content_int(0, "cigaretts", mysql);
        gPlayerItemData[playerid][e_player_walkietalkie]            = cache_get_field_content_int(0, "walkietalkie", mysql);

        gPlayerWeaponData[playerid][e_player_weapon_skill][0]      = cache_get_field_content_int(0, "WeaponSkillPistol");
    	gPlayerWeaponData[playerid][e_player_weapon_skill][1]      = cache_get_field_content_int(0, "WeaponSkillSilenced");
    	gPlayerWeaponData[playerid][e_player_weapon_skill][2]      = cache_get_field_content_int(0, "WeaponSkillDeagle");
    	gPlayerWeaponData[playerid][e_player_weapon_skill][3]      = cache_get_field_content_int(0, "WeaponSkillShotgun");
    	gPlayerWeaponData[playerid][e_player_weapon_skill][4]      = cache_get_field_content_int(0, "WeaponSkillSawnoff");
    	gPlayerWeaponData[playerid][e_player_weapon_skill][5]      = cache_get_field_content_int(0, "WeaponSkillSpas12");
    	gPlayerWeaponData[playerid][e_player_weapon_skill][6]      = cache_get_field_content_int(0, "WeaponSkillUzi");
    	gPlayerWeaponData[playerid][e_player_weapon_skill][7]      = cache_get_field_content_int(0, "WeaponSkillMP5");
    	gPlayerWeaponData[playerid][e_player_weapon_skill][8]      = cache_get_field_content_int(0, "WeaponSkillAK47");
    	gPlayerWeaponData[playerid][e_player_weapon_skill][9]      = cache_get_field_content_int(0, "WeaponSkillM4");
    	gPlayerWeaponData[playerid][e_player_weapon_skill][10]     = cache_get_field_content_int(0, "WeaponSkillSniper");

        SetSpawnInfo(playerid, 255, gPlayerCharacterData[playerid][e_player_skin], gPlayerPositionData[playerid][e_player_x], gPlayerPositionData[playerid][e_player_y], gPlayerPositionData[playerid][e_player_z], gPlayerPositionData[playerid][e_player_a], 0, 0, 0, 0, 0, 0);
        TogglePlayerSpectating(playerid, false);

        SetPlayerInterior(playerid,     gPlayerPositionData[playerid][e_player_int]);
        SetPlayerVirtualWorld(playerid, gPlayerPositionData[playerid][e_player_vw]);

        if(GetPlayerGPS(playerid) > gettime()) ShowPlayerGPS(playerid); else HidePlayerGPS(playerid);
        ShowPlayerLogo(playerid);

        SetPlayerLevel(playerid,        cache_get_field_content_int(0, "level", mysql));
        SetPlayerHealth(playerid,       gPlayerCharacterData[playerid][e_player_health]);
        SetPlayerArmour(playerid,       gPlayerCharacterData[playerid][e_player_armour]);
        SetPlayerCash(playerid,         gPlayerCharacterData[playerid][e_player_money]);
        SetPlayerApartmentKey(playerid, cache_get_field_content_int(0, "apartkey", mysql));

        SetPlayerHospitalTime(playerid, cache_get_field_content_int(0, "hospital", mysql));
        SetPlayerAchievements(playerid, cache_get_field_content_int(0, "achievements", mysql));
        SetPlayerRank(playerid,         cache_get_field_content_int(0, "rank", mysql));
        SetPlayerFirstTimeVar(playerid, cache_get_field_content_int(0, "ftime", mysql));
        SetPlayerPrisionTime(playerid,  cache_get_field_content_int(0, "prision_time", mysql));
        SetPlayerCarTheftTimer(playerid, cache_get_field_content_int(0, "cartheft_time", mysql));

        SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL,			gPlayerWeaponData[playerid][e_player_weapon_skill][0]);
    	SetPlayerSkillLevel(playerid, WEAPONSKILL_PISTOL_SILENCED,	gPlayerWeaponData[playerid][e_player_weapon_skill][1]);
    	SetPlayerSkillLevel(playerid, WEAPONSKILL_DESERT_EAGLE,		gPlayerWeaponData[playerid][e_player_weapon_skill][2]);
    	SetPlayerSkillLevel(playerid, WEAPONSKILL_SHOTGUN,			gPlayerWeaponData[playerid][e_player_weapon_skill][3]);
    	SetPlayerSkillLevel(playerid, WEAPONSKILL_SAWNOFF_SHOTGUN,	gPlayerWeaponData[playerid][e_player_weapon_skill][4]);
    	SetPlayerSkillLevel(playerid, WEAPONSKILL_SPAS12_SHOTGUN,	gPlayerWeaponData[playerid][e_player_weapon_skill][5]);
    	SetPlayerSkillLevel(playerid, WEAPONSKILL_MICRO_UZI,		gPlayerWeaponData[playerid][e_player_weapon_skill][6]);
    	SetPlayerSkillLevel(playerid, WEAPONSKILL_MP5,				gPlayerWeaponData[playerid][e_player_weapon_skill][7]);
    	SetPlayerSkillLevel(playerid, WEAPONSKILL_AK47,				gPlayerWeaponData[playerid][e_player_weapon_skill][8]);
    	SetPlayerSkillLevel(playerid, WEAPONSKILL_M4,				gPlayerWeaponData[playerid][e_player_weapon_skill][9]);
    	SetPlayerSkillLevel(playerid, WEAPONSKILL_SNIPERRIFLE,		gPlayerWeaponData[playerid][e_player_weapon_skill][10]);

        SetPlayerFightingStyle(playerid, gPlayerCharacterData[playerid][e_player_fstyle]);

        LoadPlayerWeapons(playerid);
        LoadPlayerPets(playerid);
        // LoadPlayerVehicles(playerid);

        ShowPlayerXPBar(playerid);

        SetPlayerColor(playerid, 0xFFFFFFFF);
        SetPlayerLogged(playerid, true);

        SendAdminMessage(PLAYER_RANK_PARADISER, 0x3A9BF4FF, "%s{FFFFFF} conectou-se ao servidor.", GetPlayerFirstName(playerid));
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
    switch(dialogid)
    {
        case DIALOG_LOGIN:
        {
            if(!response)
                return Kick(playerid);

            new tmpstr[MAX_PLAYER_PASSWORD];
            SHA256_PassHash(inputtext, "pcacc", tmpstr, MAX_PLAYER_PASSWORD);

            if(!strcmp(gPlayerAccountData[playerid][e_player_password], tmpstr) && !isnull(gPlayerAccountData[playerid][e_player_password]) && !isnull(inputtext))
            {
                ClearPlayerScreen(playerid);
                SendClientMessage(playerid, COLOR_SUCCESS, "Conectado com sucesso!");
                PlayConfirmSound(playerid);
                LoadPlayerAccount(playerid);
            }
            else
            {
                ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_INPUT, "Conta Registrada->Senha Incorreta", "Senha incorreta!\nTente novamente:", "Conectar", "Sair"),
                PlayErrorSound(playerid);
            }
            return -2;
        }
        case DIALOG_REGISTER_EMAIL:
        {
            if(!response)
            {
                Kick(playerid);
            }
            else if(strlen(inputtext) < 6 || strlen(inputtext) > 128 || strfind(inputtext, "@") == -1 || strfind(inputtext, ".") == -1)
            {
                PlayErrorSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_REGISTER_EMAIL, DIALOG_STYLE_INPUT, "Registrando Conta->Email", "{ff0000}E-mail inv??lido!\n\n{ffffff}Insira seu endere??o de e-mail.\nTente novamente:", "Confirmar", "Sair");
            }
            else
            {
                PlayConfirmSound(playerid);
                format(gPlayerEmail[playerid], 128, inputtext);
                for(new i = 0; i < strlen(gPlayerEmail[playerid]); i++)
                {
                    gPlayerEmail[playerid][i] = tolower(gPlayerEmail[playerid][i]);
                }
                SendClientMessagef(playerid, COLOR_SUCCESS, "* E-mail cadastrado: %s", gPlayerEmail[playerid]);
                ShowPlayerDialog(playerid, DIALOG_REGISTER_NAME, DIALOG_STYLE_INPUT, "Registrando Conta->Nome", "{ffffff}Insira seu nome ou como gostaria de ser chamado para a exibi????o no painel de usu??rio:", "Confirmar", "Sair");
            }
            return -2;
        }
        case DIALOG_REGISTER_NAME:
        {
            if(!response)
            {
                Kick(playerid);
            }
            else
            {
                PlayConfirmSound(playerid);
                format(gPlayerName[playerid], 64, inputtext);
                SendClientMessagef(playerid, COLOR_SUCCESS, "* Nome cadastrado: %s", gPlayerName[playerid]);
                ShowPlayerDialog(playerid, DIALOG_REGISTER_GENDER, DIALOG_STYLE_MSGBOX, "Registrando Conta->Sexo", "{ffffff}Informe seu sexo:", "Masculino", "Feminino");
            }
            return -2;
        }
        case DIALOG_REGISTER_GENDER:
        {
            if(response)
            {
                gPlayerGender[playerid] = 0;
                SendClientMessage(playerid, COLOR_SUCCESS, "* Sexo cadastrado: Masculino");
            }
            else
            {
                gPlayerGender[playerid] = 1;
                SendClientMessage(playerid, COLOR_SUCCESS, "* Sexo cadastrado: Feminino");
            }
            ShowPlayerDialog(playerid, DIALOG_REGISTER_AGE, DIALOG_STYLE_INPUT, "Registrando Conta->Idade", "{ffffff}Insira sua data de nascimento no formato dd/mm/aaaa:", "Confirmar", "Sair");
            return -2;
        }
        case DIALOG_REGISTER_AGE:
        {
            new dd, mm, yy, cyy;
            getdate(cyy, mm, dd);
            if(!response)
            {
                Kick(playerid);
            }
            else if(sscanf(inputtext, "p</>iii", dd, mm, yy))
            {
                PlayErrorSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_REGISTER_AGE, DIALOG_STYLE_INPUT, "Registrando Conta->Idade", "{ff0000}Data inv??lida!\n\n{ffffff}Insira sua data de nascimento no formato dd/mm/aaaa.\nTente novamente:", "Confirmar", "Sair");
            }
            else if(dd < 1 || dd > 31 || mm < 1 || mm > 12 || yy < 1900 || yy > cyy)
            {
                PlayErrorSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_REGISTER_AGE, DIALOG_STYLE_INPUT, "Registrando Conta->Idade", "{ff0000}Data inv??lida!\n\n{ffffff}Insira sua data de nascimento no formato dd/mm/aaaa.\nTente novamente:", "Confirmar", "Sair");
            }
            else
            {
                PlayConfirmSound(playerid);
                format(gPlayerAge[playerid], 11, inputtext);
                SendClientMessagef(playerid, COLOR_SUCCESS, "* Data de nasc. cadastrada: %s", gPlayerAge[playerid]);
                ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Registrando Conta->Senha", "{ffffff}Insira sua senha:", "Cadastrar", "Sair");
            }
            return -2;
        }
        case DIALOG_REGISTER:
        {
            if(!response)
                Kick(playerid);
            else if(strlen(inputtext) < 6)
                ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Registrando Conta->Senha muito curta", "Senha muito curta!\n\nSua senha precisa de pelo menos 6 characteres.\nTente novamente:", "Registrar", "Sair"),
                PlayErrorSound(playerid);
            else if(strlen(inputtext) > MAX_PLAYER_PASSWORD-1)
                ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Registrando Conta->Senha muito longa", "Senha muito longa!\n\nSua senha pode no m??ximo ter 30 characteres.\nTente novamente:", "Registrar", "Sair"),
                PlayErrorSound(playerid);
            else
            {
                PlayConfirmSound(playerid);
                SetPlayerLogged(playerid, true);
                SendClientMessage(playerid, COLOR_SUCCESS, "* Registrado com sucesso!");

                new playerName[MAX_PLAYER_NAME];
                GetPlayerName(playerid, playerName, sizeof(playerName));

                new query[524], hashstring[MAX_PLAYER_PASSWORD];
                SHA256_PassHash(inputtext, "pcacc", hashstring, MAX_PLAYER_PASSWORD);
                mysql_format(mysql, query, sizeof(query), "INSERT INTO `users` (`name`, `username`, `password`, `email`, `birthdate`, `created_at`) VALUES ('%e', '%e', '%e', '%e', STR_TO_DATE('%e', '%%d/%%m/%%Y'), now())", gPlayerName[playerid], playerName, hashstring, gPlayerEmail[playerid], gPlayerAge[playerid]);
            	mysql_tquery(mysql, query, "OnAccountRegister", "i", playerid);
            }
            return -2;
        }
        case DIALOG_CHANGE_NAME:
        {
            if(!response)
            {
                Kick(playerid);
            }
            else if(strlen(inputtext) < 5)
            {
                PlayErrorSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_CHANGE_NAME, DIALOG_STYLE_INPUT, "Nome de usu??rio inv??lido!", "{ff0000}Nome muito curto!\n{ffffff}Seu nome de usu??rio est?? incoreto!\nVoc?? deve utilizar o padr??o Nome.Sobrenome, digite no campo abaixo seu nome desejado:", "Alterar", "Sair");
            }
            else if(strlen(inputtext) > 24)
            {
                PlayErrorSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_CHANGE_NAME, DIALOG_STYLE_INPUT, "Nome de usu??rio inv??lido!", "{ff0000}Nome muito longo!\n{ffffff}Seu nome de usu??rio est?? incoreto!\nVoc?? deve utilizar o padr??o Nome.Sobrenome, digite no campo abaixo seu nome desejado:", "Alterar", "Sair");
            }
            else if(IsAValidName(inputtext) != 1)
            {
                PlayErrorSound(playerid);
                ShowPlayerDialog(playerid, DIALOG_CHANGE_NAME, DIALOG_STYLE_INPUT, "Nome de usu??rio inv??lido!", "{ff0000}Seu nome de usu??rio est?? incoreto!\n{ffffff}Voc?? deve utilizar o padr??o Nome.Sobrenome, digite no campo abaixo seu nome desejado:", "Alterar", "Sair");
            }
            else
            {
                new username[MAX_PLAYER_NAME], bool:found = false;
                foreach(new i: Player)
                {
                    GetPlayerName(i, username, sizeof(username));
                    if(!strcmp(username, inputtext))
                    {
                        found = true;
                        break;
                    }
                }

                if(found)
                {
                    PlayErrorSound(playerid);
                    ShowPlayerDialog(playerid, DIALOG_CHANGE_NAME, DIALOG_STYLE_INPUT, "Nome de usu??rio inv??lido!", "{ff0000}Este nome j?? est?? em uso!\n{ffffff}Voc?? deve utilizar o padr??o Nome.Sobrenome, digite no campo abaixo seu nome desejado:", "Alterar", "Sair");
                }
                else
                {
                    new query[67];
                    mysql_format(mysql, query, sizeof(query), "SELECT id FROM users WHERE username = '%e'", inputtext);
                    mysql_tquery(mysql, query, "OnChangeNameRequest", "is", playerid, inputtext);
                }
            }
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

public OnBanCheck(playerid)
{
    new rows, fields;
	cache_get_data(rows, fields, mysql);
    if(rows > 0)
    {
        new tempCheck = cache_get_field_content_int(0, "final_unix", mysql);
        new adminName[32];
        cache_get_field_content(0, "admin", adminName, mysql, MAX_PLAYER_NAME);

        if(tempCheck != -255) {
            if(tempCheck < gettime()) {
                new hourLeft = (gettime() - tempCheck) / 3600;

                SendClientMessagef(playerid, COLOR_INFO, "Voc?? ainda tem %d hora(s) de banimento. ", hourLeft);
                SendClientMessagef(playerid, COLOR_INFO, "Administrador Respons??vel: %s", adminName);
                return SetTimerEx("KickPlayer", 800, false, "i", playerid);
            }
        } else {
            SendClientMessage(playerid, COLOR_INFO, "Voc?? est?? banido permanentemente do servidor.");
            SendClientMessagef(playerid, COLOR_INFO, "Administrador Respons??vel: %s", adminName);
            return SetTimerEx("KickPlayer", 800, false, "i", playerid);
        }
    }
    return 1;
}

//------------------------------------------------------------------------------

public OnAccountCheck(playerid)
{
	new rows, fields;
	cache_get_data(rows, fields, mysql);
	if(rows > 0)
	{
        cache_get_field_content(0, "password", gPlayerAccountData[playerid][e_player_password], mysql, MAX_PLAYER_PASSWORD);
        gPlayerAccountData[playerid][e_player_database_id]          = cache_get_field_content_int(0, "user_id", mysql);
        gPlayerAccountData[playerid][e_player_login_expire]         = cache_get_field_content_int(0, "login_expire", mysql);

        gPlayerCharacterData[playerid][e_player_skin]               = cache_get_field_content_int(0, "skin", mysql);
        gPlayerCharacterData[playerid][e_player_faction]            = cache_get_field_content_int(0, "faction", mysql);
        gPlayerCharacterData[playerid][e_player_frank]              = cache_get_field_content_int(0, "faction_rank", mysql);
        gPlayerCharacterData[playerid][e_player_jobid]              = Job:cache_get_field_content_int(0, "jobid", mysql);
        gPlayerCharacterData[playerid][e_player_level]              = cache_get_field_content_int(0, "level", mysql);
        gPlayerCharacterData[playerid][e_player_xp]                 = cache_get_field_content_int(0, "xp", mysql);
        gPlayerPhoneData[playerid][e_player_phone_number]           = cache_get_field_content_int(0, "phone_number", mysql);

        gPlayerLicenseData[playerid][e_player_car_license]          = cache_get_field_content_int(0, "carlic", mysql);
        gPlayerLicenseData[playerid][e_player_bike_license]         = cache_get_field_content_int(0, "bikelic", mysql);
        gPlayerLicenseData[playerid][e_player_truck_license]        = cache_get_field_content_int(0, "trucklic", mysql);
        gPlayerLicenseData[playerid][e_player_heli_license]         = cache_get_field_content_int(0, "helilic", mysql);
        gPlayerLicenseData[playerid][e_player_plane_license]        = cache_get_field_content_int(0, "planelic", mysql);
        gPlayerLicenseData[playerid][e_player_boat_license]         = cache_get_field_content_int(0, "boatlic", mysql);

        SetPlayerRank(playerid,         cache_get_field_content_int(0, "rank", mysql));
        SetPlayerHouseID(playerid,      cache_get_field_content_int(0, "housekey", mysql));
        SetPlayerBusinessID(playerid,   cache_get_field_content_int(0, "businesskey", mysql));
        SetPlayerApartmentKey(playerid, cache_get_field_content_int(0, "apartkey", mysql));

        SetPlayerRegistered(playerid, true);
        LoadPlayerVehicles(playerid);
        // VSL_ShowPlayerTextdraw(playerid); ^

        /*new info[130];
        format(info, sizeof(info), "Bem-vindo de volta %s!\n\nSua conta j?? est?? registrada em nosso banco de dados.\nDigite sua senha para se conectar.", GetPlayerFirstName(playerid));
        ShowPlayerDialog(playerid, DIALOG_LOGIN, DIALOG_STYLE_PASSWORD, "Conta Registrada", info, "Conectar", "Sair");
        PlaySelectSound(playerid);*/
	}
    else
    {
        /*new info[130];
        format(info, sizeof(info), "Bem-vindo %s!\n\nSua conta n??o est?? registrada em nosso banco de dados.\nDigite sua senha para se registrar.", GetPlayerFirstName(playerid));
        ShowPlayerDialog(playerid, DIALOG_REGISTER, DIALOG_STYLE_INPUT, "Conta Registrada", info, "Registrar", "Sair");
        PlaySelectSound(playerid);*/

        SetPlayerRegistered(playerid, false);
        VSL_ShowPlayerTextdraw(playerid);
    }
	SendClientMessage(playerid, COLOR_SUCCESS, "Conectado.");
    ClearPlayerScreen(playerid, 20);
    return 1;
}

//------------------------------------------------------------------------------

public OnChangeNameRequest(playerid, name[])
{
	new rows, fields;
	cache_get_data(rows, fields, mysql);
	if(rows > 0)
	{
        PlayErrorSound(playerid);
        ShowPlayerDialog(playerid, DIALOG_CHANGE_NAME, DIALOG_STYLE_INPUT, "Nome de usu??rio inv??lido!", "{ff0000}Este nome j?? est?? cadastrado!\nVoc?? deve utilizar o padr??o Nome.Sobrenome, digite no campo abaixo seu nome desejado:", "Alterar", "Sair");
	}
    else
    {
        new tempname[24];
        format(tempname, sizeof(tempname), "pc%s", gettime());
        SetPlayerName(playerid, tempname);
        SetPlayerName(playerid, name);

        // Checks if the player account is registered
        new query[100 + MAX_PLAYER_NAME], playerName[MAX_PLAYER_NAME + 1];
        GetPlayerName(playerid, playerName, sizeof(playerName));
        mysql_format(mysql, query, sizeof(query),"SELECT * FROM users LEFT JOIN players ON users.id=players.user_id WHERE `username` = '%e' LIMIT 1", playerName);
        mysql_tquery(mysql, query, "OnAccountCheck", "i", playerid);
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerRequestClass(playerid, classid)
{
    if(IsPlayerNPC(playerid))
        return 1;

    TogglePlayerSpectating(playerid, true);
    if(IsAValidName(GetPlayerNamef(playerid, false)) == 1)
    {
        // Checks if the player account is registered
        new query[100 + MAX_PLAYER_NAME], playerName[MAX_PLAYER_NAME + 1];
        GetPlayerName(playerid, playerName, sizeof(playerName));
        mysql_format(mysql, query, sizeof(query),"SELECT * FROM users LEFT JOIN players ON users.id=players.user_id WHERE `username` = '%e' LIMIT 1", playerName);
        mysql_tquery(mysql, query, "OnAccountCheck", "i", playerid);
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerSpawn(playerid)
{
    if(IsPlayerNPC(playerid))
        return 1;

    SetPlayerCash(playerid, GetPlayerCash(playerid));

    new hour, minute;
    GetServerClock(hour, minute);
    SetPlayerTime(playerid, hour, minute);
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerRequestSpawn(playerid)
{
    if(IsPlayerNPC(playerid))
        return 1;

    if(!IsPlayerLogged(playerid))
    {
        SendClientMessage(playerid, COLOR_ERROR, "* Voc?? n??o est?? conectado em sua conta.");
        return -1;
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerConnect(playerid)
{
    if(IsPlayerNPC(playerid))
        return 1;

    // Reseting player data
    ResetPlayerData(playerid);
    ClearPlayerScreen(playerid);
    SetPlayerColor(playerid, 0xacacacff);
    SendClientMessage(playerid, COLOR_INFO, "Conectando ao banco de dados, por favor aguarde...");

    // Checks if the player account is invalid, if not if is banned
    if(IsAValidName(GetPlayerNamef(playerid, false)) != 1)
    {
        ShowPlayerDialog(playerid, DIALOG_CHANGE_NAME, DIALOG_STYLE_INPUT, "Nome de usu??rio inv??lido!", "{ffffff}Seu nome de usu??rio est?? incoreto!\nVoc?? deve utilizar o padr??o Nome.Sobrenome, digite no campo abaixo seu nome desejado:", "Alterar", "Sair");
    }
    else
    {
        new query[57 + MAX_PLAYER_NAME + 1];
        mysql_format(mysql, query, sizeof(query),"SELECT * FROM `bans` WHERE `username` = '%e' LIMIT 1", GetPlayerNamef(playerid));
        mysql_tquery(mysql, query, "OnBanCheck", "i", playerid);
    }
    return 1;
}

//------------------------------------------------------------------------------

hook OnPlayerDisconnect(playerid, reason)
{
    SavePlayerAccount(playerid);
    SetPlayerLogged(playerid, false);
    return 1;
}

//------------------------------------------------------------------------------

ptask OnPlayerSaveAccount[600000](playerid)
{
    SavePlayerAccount(playerid);
    return 1;
}

//------------------------------------------------------------------------------

ptask CheckPlayerProgression[180000](playerid)
{
    if(!IsPlayerLogged(playerid))
    	return 1;

	if(!IsPlayerPaused(playerid))
    {
        SetPlayerXP(playerid, GetPlayerXP(playerid) + (GetPlayerLevel(playerid) + 1));
    }
    return 1;
}
