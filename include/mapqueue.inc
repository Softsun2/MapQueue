#define MQ_VERSION "0.0"

#include <sourcemod>
#include <SteamWorks>
#include <smjansson>

#pragma semicolon 1
#pragma newdecls required

#define GLOBAL_MIN_TIER 1
#define GLOBAL_MAX_TIER 7

#define int(%1)     view_as<int>(%1)

// char ChatPrefix[] = "[SS2] ";

// Lists 
ArrayList MapsPerTier[GLOBAL_MAX_TIER];

// Map Filters
int MinTier;
int MaxTier;
int MinPoints;
int MaxPoints;

int GameMode;
int MapCompletionType;
int MapCompletionStatus;

// Menus
Menu filterMenu;
Menu tiersMenu;
Menu pointsMenu;
Menu getStepMenu;

// Variables
int BufferHandler;
DataPack BufferHandlerStoreMaps;
DataPack BufferHandlerMapMaps;

bool minValueNotPicked;

int pickingStatus;
int pointStep;


// Enums

enum struct Map
{
    int id;
    char name[32];
    int difficulty;
    char created_on[32];
}

enum BufferHandlers
{
    storeMaps,
    mapMaps
}

enum pickingStatuses
{
    notPicking,
    pickingTiers,
    pickingPoints
}

enum mapAttributeKeys
{
    id,
    name,
    difficulty,
    created_on,
}

enum gameModesInts
{
    AnyGameMode,
    Kzt,
    Skz,
    Vnl
}

enum completionTypesInts
{
    NUB,
    Pro,
    Tp
}

enum completionStatusesInts
{
    AnyCompletion,
    Completed,
    NotCompleted
}