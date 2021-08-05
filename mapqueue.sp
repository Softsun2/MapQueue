#include <mapqueue>

#include "mapqueue/filtermenus.sp"
#include "mapqueue/mapdata.sp"
#include "mapqueue/queue.sp"

public Plugin myinfo =
{
	name = "Map Queue",
	author = "Softsun2",
	description = "Provides Map Queueing",
	version = MQ_VERSION,
	url = "https://github.com/Softsun2/MapQueue"
};

/*
TODO:
add map completion time filter
        add date created/ map release filter

#DEFINE char length constants

redraw MapCompletionType white when MapCompletionStatus is Any

    KNOWN BUGS:
        "ghost buffer" in HTTPRequestCompleted_Maps
*/

public void OnPluginStart()
{
    InitBufferHandlers();
    InitFilters();
    InitMaps();
    
    RelatedRecordsMap = new StringMap();
    
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
    // queueFilters(client);
    // testing requesting RelatedRecordsMap
    
    myClient = client;
    char sURL[512];
    getFilterRequestURL(client, sURL, sizeof(sURL));
    PrintToConsole(client, "%s", sURL);
    BufferHandler = int(mapRecords);
    createRequest(sURL);
    
    RelatedRecordsMap.Clear();
    
    return Plugin_Handled;
}

public Action Command_LoadMaps(int client, int args)
{
    printGlobalKzMapsToConsole();
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