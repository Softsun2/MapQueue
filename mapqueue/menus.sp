/*======================== Menu Handlers ========================*/

public int filterMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            char info[32];
            menu.GetItem(param2, info, sizeof(info));
            delete menu;

            if(StrEqual(info, "GameMode"))
            {
                GameMode = (GameMode + 1) % 4;
                BuildFilterMenu(param1);
            }
            else if(StrEqual(info, "CompType"))
            {
                MapCompletionType = (MapCompletionType + 1) % 3;
                BuildFilterMenu(param1);
            }
            else if(StrEqual(info, "CompStatus"))
            {
                MapCompletionStatus = (MapCompletionStatus + 1) % 3;
                BuildFilterMenu(param1);
            }
            else if(StrEqual(info, "Tiers"))
            {
                BuildTiersMenu(param1);
            }
            else if(StrEqual(info, "Points"))
            {
                BuildGetStepMenu(param1);
            }
        }

        case MenuAction_DrawItem:
        {
            int style;
            char info[32];
            menu.GetItem(param2, info, sizeof(info), style);

            if(StrEqual(info, "Points") && 
               ((MapCompletionStatus == int(AnyCompletion)) ||
                (MapCompletionStatus == int(NotCompleted))))
            {
                return ITEMDRAW_DISABLED;
            }
            return style;
        }

        case MenuAction_DisplayItem:
        {
            char info[32];
            menu.GetItem(param2, info, sizeof(info));

            char display[64];

            if(StrEqual(info, "GameMode"))
            {
                Format(display, sizeof(display), "Game Mode: %s",
                       gameModesStrs[GameMode]);
                return RedrawMenuItem(display);
            }
            else if(StrEqual(info, "CompType"))
            {
                Format(display, sizeof(display), "Completion Type: %s",
                       completionTypes[MapCompletionType]);
                return RedrawMenuItem(display);
            }
            else if(StrEqual(info, "CompStatus"))
            {
                Format(display, sizeof(display), "Completion Status: %s",
                       completionStatuses[MapCompletionStatus]);
                return RedrawMenuItem(display);
            }
            else if(StrEqual(info, "Tiers"))
            {
                if(MinTier == MaxTier)
                {
                    Format(display, sizeof(display), "Tier: %d", MinTier);
                }
                else
                {
                    Format(display, sizeof(display), "Tiers: [%d, %d]", MinTier, MaxTier);
                }
                return RedrawMenuItem(display);
            }
            else if(StrEqual(info, "Points"))
            {
                if(MapCompletionStatus == int(AnyCompletion) ||
				   MapCompletionStatus == int(NotCompleted))
                {
                    Format(display, sizeof(display), "Points: n/a");
                }
                else if(MinPoints == MaxPoints)
                {
                    Format(display, sizeof(display), "Points: %d", MinPoints);
                }
                else
                {
                    Format(display, sizeof(display), "Points: [%d, %d]", MinPoints, MaxPoints);
                }
                return RedrawMenuItem(display);
            }
        }
    }
    return 0;
}

public int RangeSelectionHandler(Menu menu, MenuAction action, int param1, int param2)
{
    switch(action)
    {
        case MenuAction_Select:
        {
            char info[32];
            menu.GetItem(param2, info, sizeof(info));
            delete menu;
            int value = StringToInt(info);

            if(minValueNotPicked)
            {
                minValueNotPicked = false;

                if(pickingStatus == int(pickingTiers))
                {
                    MinTier = value;
                    BuildTiersMenu(param1);
                }
                else if(pickingStatus == int(pickingPoints))
                {
                    if(value == 1000)
                    {
                        minValueNotPicked = true;
                        pickingStatus = notPicking;
                        MinPoints = value;
                        MaxPoints = value;
                        BuildFilterMenu(param1);
                    }
                    else
                    {
                        MinPoints = value;
                        BuildPointsMenu(param1);
                    }
                }
            }
            else
            {
                if(pickingStatus == int(pickingTiers))
                {
                    MaxTier = value;
                }
                else if(pickingStatus == int(pickingPoints))
                {
                    MaxPoints = value;
                }

                minValueNotPicked = true;
                pickingStatus = notPicking;
                BuildFilterMenu(param1);
            }
        }
        
        case MenuAction_DrawItem:
        {
            int style;
            char info[32];
            menu.GetItem(param2, info, sizeof(info), style);

            if(!minValueNotPicked)
            {
                if(pickingStatus == int(pickingTiers))
                {
                    int tier = StringToInt(info);
                    if(tier < MinTier)
                    {
                        return ITEMDRAW_DISABLED;
                    }
                }
                else if(pickingStatus == int(pickingPoints)){
                    int points = StringToInt(info);
                    if(points <= MinPoints)
                    {
                        return ITEMDRAW_DISABLED;
                    }
                }
            }
            return style;
        }
    }
    return 0;
}

public int GetStepMenuHandler(Menu menu, MenuAction action, int param1, int param2)
{
    if(action == MenuAction_Select)
    {
        char info[32];
        menu.GetItem(param2, info, sizeof(info));
        delete menu;
        pointStep = StringToInt(info);

        BuildPointsMenu(param1);
    }
    return 0;
}

/*======================== Menu Builders ========================*/

void BuildFilterMenu(int client)
{
    minValueNotPicked = true;

    filterMenu = new Menu(filterMenuHandler, MENU_ACTIONS_ALL);
    filterMenu.SetTitle("Map Queue Filters");
    filterMenu.AddItem("GameMode", "Game Mode: ");
    filterMenu.AddItem("CompType", "Completion Type: ");
    filterMenu.AddItem("CompStatus", "Completion Status: ");
    filterMenu.AddItem("Tiers", "Tier(s):");
    filterMenu.AddItem("Points", "Points: ");
    filterMenu.AddItem("MapAge", "Map Age: ", ITEMDRAW_DISABLED);
    filterMenu.ExitButton = true;
    filterMenu.Display(client, MENU_TIME_FOREVER);
}

void BuildTiersMenu(int client)
{
    pickingStatus = pickingTiers;

    tiersMenu = new Menu(RangeSelectionHandler, MENU_ACTIONS_ALL);
    if(minValueNotPicked)
    {
        tiersMenu.SetTitle("Choose Minimum Tier:");
    }
    else
    {
        tiersMenu.SetTitle("Choose Maximum Tier:");
    }

    char tierBuffer[4];
    char display[8];

    for(int i = 1; i <= 7; i++)
    {
        IntToString(i, tierBuffer, sizeof(tierBuffer));
        Format(display, sizeof(display), "Tier %d", i);
        tiersMenu.AddItem(tierBuffer, display);
    }
    tiersMenu.ExitButton = false;
    tiersMenu.Display(client, MENU_TIME_FOREVER);
}

void BuildPointsMenu(int client)
{
    pickingStatus = pickingPoints;

    pointsMenu = new Menu(RangeSelectionHandler, MENU_ACTIONS_ALL);
    if(minValueNotPicked)
    {
        pointsMenu.SetTitle("Choose Minimum Points:");
    }
    else
    {
        pointsMenu.SetTitle("Choose Maximum Points:");
    }

    char pointsBuffer[8];
    char display[8];

    for(int points = 1000; points >= 0; points -= pointStep)
    {
        IntToString(points, pointsBuffer, sizeof(pointsBuffer));
        Format(display, sizeof(display), "%d", points);
        pointsMenu.AddItem(pointsBuffer, display);
    }
    pointsMenu.ExitButton = false;
    pointsMenu.Display(client, MENU_TIME_FOREVER);
}

void BuildGetStepMenu(int client)
{
    getStepMenu = new Menu(GetStepMenuHandler, MENU_ACTIONS_ALL);
    getStepMenu.SetTitle("Choose Points Step:");

    char stepBuffer[8];
    char display[16];

    for(int i = 0; i < 3; i++)
    {
        IntToString(pointSteps[i], stepBuffer, sizeof(stepBuffer));
        Format(display, sizeof(display), "%s points", stepBuffer);
        getStepMenu.AddItem(stepBuffer, display);
    }
    getStepMenu.ExitButton = false;
    getStepMenu.Display(client, MENU_TIME_FOREVER);
}