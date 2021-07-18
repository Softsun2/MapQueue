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
bool minValueNotPicked;

int pickingStatus;
int pointStep;


// Enums

enum pickingStatuses
{
    notPicking,
    pickingTiers,
    pickingPoints
}

enum mapAttributeKeys
{
    id = 0,
    name,
    difficulty,
    created_on,
}

enum gameModesInts
{
    Kzt,
    Skz,
    Vnl
}