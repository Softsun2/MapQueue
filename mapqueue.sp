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

**filter by map stage
need to unique map names to be able to map records to map names

remove unnecessary global variables (not sure why I made like everything global ??)
clean up things

KNOWN BUGS:
        the api has ambigous maximum response lengths so need to fix how to get all the maps...
going to take multiple requests. maybe have a while loop whose condition mods on the max response length?
*/

public void OnPluginStart()
{
    InitRequestHandlers();
    InitFilters();
    InitMaps();
    
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
    queueFilters(client);
    return Plugin_Handled;
}

public Action Command_TestRequest(int client, int args)
{
    // queueFilters(client);
    // testing requesting RelatedRecordsMap
    storeRecordsToMap = true;
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