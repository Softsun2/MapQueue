#include <mapqueue>

#include "mapqueue/filters.sp"
#include "mapqueue/menus.sp"
#include "mapqueue/mapdata.sp"
#include "mapqueue/queue.sp"

public Plugin myinfo =
{
	name = "Map Queue",
	author = "Softsun2",
	description = "Provides Map Queueing",
	version = MQ_VERSION,
	url = "wip"
};


/*
TODO:
    Initialize maps √
    Queueing:
        command not a menu √
        queue on filters X
    Menu Filters √ (for now)
        add filter by date in the future possibly

    KNOWN BUGS:
        none atm
*/


public void OnPluginStart()
{
    InitBufferHandlers();
    InitFilters();
    // InitMaps();
    
    RegConsoleCmd("sm_filters", Command_SetFilters);
    RegConsoleCmd("sm_queue", Command_QueueMaps);
    RegConsoleCmd("sm_loadMaps", Command_LoadMaps);
    
    // RegConsoleCmd("sm_inqueue", Command_PrintMapsInQueue);
    // RegConsoleCmd("sm_frontmap", Command_GoToFrontMap);
    
    CreateConVar("mq_version", MQ_VERSION, "Map Queue Plugin version", FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
}

/*======================== Commands ========================*/

public Action Command_SetFilters(int client, int args)
{
    BuildFilterMenu(client);
    return Plugin_Handled;
}

public Action Command_QueueMaps(int client, int args)
{
    queueFilters(client);
    return Plugin_Handled;
}

public Action Command_LoadMaps(int client, int args)
{
    InitMaps();
    return Plugin_Handled;
}

// public Action Command_PrintMapsInQueue(int client, int args)
// {
//     return Plugin_Handled;
// }

// public Action Command_GoToFrontMap(int client, int args)
// {
//     return Plugin_Handled;
// }