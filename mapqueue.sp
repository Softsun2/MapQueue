#include <mapqueue>

#include "mapqueue/filters.sp"
#include "mapqueue/menus.sp"

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
    FIXME:
        replace pickingTiers and pickingPoints with a picking status or enum?
    Setup Repo:
        uhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
    Determine Procedure for queueing maps:

    Menu Filters:
        Game Mode X
        Completion Type √
        Completion Status
            if status is not completed can't pick points.
        Tiers √
        Points √
        Map Age X
    Queueing:
        uhhhhhhhhhhhhhhhhhhhhhhhhhhhhh
*/


public void OnPluginStart()
{
    InitFilters();
    
    RegConsoleCmd("sm_queue_maps", Command_QueueMaps);
    RegConsoleCmd("sm_set_filters", Command_SetFilters);

    CreateConVar("mq_version", MQ_VERSION, "Map Queue Plugin version", FCVAR_NOTIFY|FCVAR_DONTRECORD|FCVAR_SPONLY);
}

/*======================== COMMANDS ========================*/

public Action Command_QueueMaps(int client, int args)
{
    ReplyToCommand(client, "%smq_MinTier: %d, mq_MaxTier: %d.", ChatPrefix, MinTier, MaxTier);
    return Plugin_Handled;
}

public Action Command_SetFilters(int client, int args)
{
    BuildFilterMenu(client);
    return Plugin_Handled;
}