/*======================== Map Data Utilities ========================*/

bool jsonMapsToString(char[] buffer, int maxBufferSize, Handle jsonMap)
{
    bool noNullObj = false;
    Handle idObj = json_object_get(jsonMap, "id");
    Handle nameObj = json_object_get(jsonMap, "name");
    Handle difficultyObj = json_object_get(jsonMap, "difficulty");
    Handle created_onObj = json_object_get(jsonMap, "created_on");

    if(idObj != null && nameObj != null && 
       difficultyObj != null && created_onObj != null)
    {
        int mapId = json_integer_value(idObj);

        char mapName[64];
        json_string_value(nameObj, mapName, sizeof(mapName));

        int mapDifficulty = json_integer_value(difficultyObj);

        char mapCreated_on[64];
        json_string_value(created_onObj, mapCreated_on, sizeof(mapCreated_on));

        Format(buffer, maxBufferSize, 
               "%d, %s, %d, %s",
               mapId, mapName, mapDifficulty, mapCreated_on);
        noNullObj = true; 
    }

    delete idObj;
    delete nameObj;
    delete difficultyObj;
    delete created_onObj;
    return noNullObj;
}

void splitMapString(char[][] buffers, char[] mapString)
{
    ExplodeString(mapString, ",", buffers, 4, 64);
}

void printMapsToServer()
{
    int mapsAdded = 0;
    for(int tier = 0; tier < GLOBAL_MAX_TIER; tier++)
    {
        int tierLength = MapsPerTier[tier].Length;
        for(int i = 0; i < tierLength; i++)
        {
            char mapString[512];
            MapsPerTier[tier].GetString(i, mapString, sizeof(mapString));
            PrintToServer("Tier: %d, Map: %d, MapString: %s",
                          tier,
                          mapsAdded,
                          mapString);
            mapsAdded++;
        }
    }
}