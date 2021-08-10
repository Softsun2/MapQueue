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
add date-created/map-release filter
add map stage filter

#DEFINE char length constants
need to unique map names to be able to map records to map names

remove unnecessary globals

*itemdraw_disabled Game Mode when CompStatus is Any
*display: n/a for all itemdraw_diabled items
*check cmds don't cause exceptions when called in unlikely orders
*allow selection of CompType when CompStatus is NotCompleted

KNOWN BUGS:
*PrintMapsInQueue only displays ~112 maps (probably a console print limit)
*Very rarely causes a timeout exception (stumped on this one)
*SteamWorks_GetHTTPResponseBodyData uses a Weird ghost buffer to write to the intended buffer
(this has been temporarily fixed for now)
*Filtering with CompStatus Completed results in an innacurate MapQueue, GlobalAPI doesn't respond
 with the all of a player records with the given request url (API is kinda broken going to
 have to make many requests instead of one to get all records)
*/

public void OnPluginStart()
{
    InitRequestHandlers();
    InitFilters();
    InitMaps();
    
    MapQueue = CreateArray(ByteCountToCells(PLATFORM_MAX_PATH));
    RelatedRecordsMap = new StringMap();
    
    RegConsoleCmd("sm_filters", Command_SetFilters);
    RegConsoleCmd("sm_queue", Command_QueueMaps);
    RegConsoleCmd("sm_nextinq", Command_GoToNextMapInQueue);
    RegConsoleCmd("sm_printq", Command_PrintMapsInQueue);
    RegConsoleCmd("sm_testrequest", Command_TestRequest);
    
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
    myClient = client;
    queueFilters(client);
    return Plugin_Handled;
}

public Action Command_TestRequest(int client, int args)
{
    // queueFilters(client);
    // testing requesting RelatedRecordsMap
    myClient = client;
    char sURL[512];
    getFilterRequestURL(client, sURL, sizeof(sURL));
    PrintToConsole(client, "%s", sURL);
    RequestHandler = int(storeRecords);
    createRequest(sURL);
    
    RelatedRecordsMap.Clear();
    
    return Plugin_Handled;
}

public Action Command_PrintMapsInQueue(int client, int args)
{
    PrintToChat(client, "See console for maps in queue.");
    
    int mapQueueLength = MapQueue.Length;
    PrintToConsole(client, "Map Queue length: %d", mapQueueLength);
    for(int i = 0; i < mapQueueLength; i++)
    {
        char mapName[PLATFORM_MAX_PATH];
        MapQueue.GetString(i, mapName, PLATFORM_MAX_PATH);
        PrintToConsole(client,
                       "Place: %3d, Map: %s",
                       i+1,
                       mapName);
    }
    return Plugin_Handled;
}


public Action Command_GoToNextMapInQueue(int client, int args)
{
    gotoNextInQueue(client);
    return Plugin_Handled;
}