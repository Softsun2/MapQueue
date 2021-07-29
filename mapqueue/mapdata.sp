/*======================== Map Data Utilities ========================*/

bool jsonToMap(Map map, Handle jsonMap)
{
    bool noNullObj = false;
    Handle idObj = json_object_get(jsonMap, "id");
    Handle nameObj = json_object_get(jsonMap, "name");
    Handle difficultyObj = json_object_get(jsonMap, "difficulty");
    Handle created_onObj = json_object_get(jsonMap, "created_on");
    
    if(idObj != null && nameObj != null && 
       difficultyObj != null && created_onObj != null)
    {
        map.id = json_integer_value(idObj);
        
        json_string_value(nameObj, map.name, sizeof(map.name));
        
        map.difficulty = json_integer_value(difficultyObj);
        
        json_string_value(created_onObj, map.created_on, sizeof(map.created_on));
        
        noNullObj = true; 
    }
    
    delete idObj;
    delete nameObj;
    delete difficultyObj;
    delete created_onObj;
    return noNullObj;
}

void printMapsToServer()
{
    int mapsAdded = 0;
    for(int tier = 0; tier < GLOBAL_MAX_TIER; tier++)
    {
        int tierLength = MapsPerTier[tier].Length;
        for(int i = 0; i < tierLength; i++)
        {
            Map map;
            MapsPerTier[tier].GetArray(i, map, sizeof(map));
            PrintToServer("Id: %d, Name: %s, Tier: %d, Created_on: %s",
                          map.id,
                          map.name,
                          map.difficulty,
                          map.created_on);
            mapsAdded++;
        }
    }
}