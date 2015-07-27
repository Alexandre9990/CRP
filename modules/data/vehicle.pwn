/*******************************************************************************
* FILENAME :        modules/data/vehicle.pwn
*
* DESCRIPTION :
*       Saves and Loads vehicles data.
*
* NOTES :
*       This file should only contain information about vehicles's data.
*       This is not intended to handle player vehicles, factions and such.
*
*       Copyright Paradise Devs 2015.  All rights reserved.
*
*/

#include <YSI\y_hooks>

//------------------------------------------------------------------------------

forward OnVehicleLoad();

//------------------------------------------------------------------------------

// enumaration of vehicle's data
enum e_vehicle_data
{
    // info
    e_vehicle_model,
    e_vehicle_color_1,
    e_vehicle_color_2,
    e_vehicle_siren,

    // position
    Float:e_vehicle_x,
    Float:e_vehicle_y,
    Float:e_vehicle_z,
    Float:e_vehicle_a,

    // values
    Float:e_vehicle_fuel,
    Float:e_vehicle_health,

    // ids
    e_vehicle_factionid,
    e_vehicle_jobid,
    e_vehicle_id
}
static gVehicleData[MAX_VEHICLES][e_vehicle_data];
static gCreatedVehicles;

//------------------------------------------------------------------------------

Float:GetVehicleFuel(vehicleid)
    return gVehicleData[vehicleid][e_vehicle_fuel];

SetVehicleFuel(vehicleid, Float:value)
    gVehicleData[vehicleid][e_vehicle_fuel] = value;

//------------------------------------------------------------------------------

GetVehicleFactionID(vehicleid)
    return gVehicleData[vehicleid][e_vehicle_factionid];

//------------------------------------------------------------------------------

public OnVehicleLoad()
{
    for(new i, j = cache_get_row_count(mysql); i < j; i++)
	{
		gVehicleData[i][e_vehicle_model]     = cache_get_row_int(i, 1, mysql);
		gVehicleData[i][e_vehicle_color_1]   = cache_get_row_int(i, 2, mysql);
		gVehicleData[i][e_vehicle_color_2]   = cache_get_row_int(i, 3, mysql);
		gVehicleData[i][e_vehicle_siren]     = cache_get_row_int(i, 4, mysql);

        gVehicleData[i][e_vehicle_x]         = cache_get_row_float(i, 5, mysql);
		gVehicleData[i][e_vehicle_y]         = cache_get_row_float(i, 6, mysql);
		gVehicleData[i][e_vehicle_z]         = cache_get_row_float(i, 7, mysql);
		gVehicleData[i][e_vehicle_a]         = cache_get_row_float(i, 8, mysql);

        gVehicleData[i][e_vehicle_fuel]      = cache_get_row_float(i, 9, mysql);
		gVehicleData[i][e_vehicle_health]    = cache_get_row_float(i, 10, mysql);

        gVehicleData[i][e_vehicle_factionid]   = cache_get_row_int(i, 11, mysql);
        gVehicleData[i][e_vehicle_jobid]       = cache_get_row_int(i, 12, mysql);

        gVehicleData[i][e_vehicle_id]        = CreateVehicle(gVehicleData[i][e_vehicle_model], gVehicleData[i][e_vehicle_x], gVehicleData[i][e_vehicle_y], gVehicleData[i][e_vehicle_z], gVehicleData[i][e_vehicle_a], gVehicleData[i][e_vehicle_color_1], gVehicleData[i][e_vehicle_color_2], -1, gVehicleData[i][e_vehicle_siren]);
        gCreatedVehicles++;
	}
    printf("Number of vehicles loaded: %d", gCreatedVehicles);
}

//------------------------------------------------------------------------------

hook OnGameModeInit()
{
    mysql_pquery(mysql, "SELECT * FROM `vehicles`", "OnVehicleLoad");
    return 1;
}
