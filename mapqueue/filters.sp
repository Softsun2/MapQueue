/*======================== Filters ========================*/

char gameModesStrs[4][4] =
{
    "Any",
    "KZT",
    "SKZ",
    "Vnl"
};

char completionTypes[3][16] =
{
    "NUB",
    "Pro",
    "Tp"
};

char completionStatuses[3][16] = 
{
    "Any",
    "Completed",
    "Not completed"
};

int pointSteps[3] =
{
    100,
    50,
    25
};

/*======================== Initializer ========================*/

void InitFilters()
{
    GameMode = AnyGameMode; 
    MinTier = GLOBAL_MIN_TIER;
    MaxTier = GLOBAL_MAX_TIER;
    MinPoints = 0;
    MaxPoints = 1000;
    MapCompletionType = NUB;
    MapCompletionStatus = AnyCompletion;
}