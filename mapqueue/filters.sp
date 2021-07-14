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

void InitFilters()
{
    MinTier = 1;
    MaxTier = 7;
    MinPoints = 0;
    MaxPoints = 1000;
    MapCompletionType = 0;
    MapCompletionStatus = 0;
}