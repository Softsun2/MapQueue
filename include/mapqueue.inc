#define MQ_VERSION "0.0"

#include <sourcemod>
#include <SteamWorks>
#include <smjansson>

#pragma semicolon 1
#pragma newdecls required

char ChatPrefix[] = "[SS2] ";

// Map Filters
int MinTier;
int MaxTier;
int MinPoints;
int MaxPoints;

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