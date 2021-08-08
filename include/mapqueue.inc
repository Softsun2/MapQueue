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

// Map Constainers 
ArrayList GlobalMaps[GLOBAL_MAX_TIER];
StringMap RelatedRecordsMap;
ArrayList RelatedRecordsList;
ArrayList MapQueue; // slow but only rearranging array on a map change

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
int myClient;
int RequestHandler;
DataPack RequestHandlerStoreMaps;
DataPack RequestHandlerMapRecords;
bool minValueNotPicked;

// Enums

enum struct Map
{
    char name[PLATFORM_MAX_PATH];
    int difficulty;
    char created_on[32];
}

enum struct Record
{
    int id;
    char map_name[PLATFORM_MAX_PATH];
    float time;
    int points;
}

enum RequestHandlers
{
    storeMaps,
    storeRecords
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