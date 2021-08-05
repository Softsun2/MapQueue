/*======================== Map Data Utilities ========================*/

bool jsonToMap(Map map, Handle jsonMap)
{
    bool noNullObj = false;
    Handle nameObj = json_object_get(jsonMap, "name");
    Handle difficultyObj = json_object_get(jsonMap, "difficulty");
    Handle created_onObj = json_object_get(jsonMap, "created_on");
    
    if(nameObj != null && difficultyObj != null && created_onObj != null)
    {
        json_string_value(nameObj, map.name, sizeof(map.name));
        map.difficulty = json_integer_value(difficultyObj);
        json_string_value(created_onObj, map.created_on, sizeof(map.created_on));
        
        noNullObj = true;
    }
    
    delete nameObj;
    delete difficultyObj;
    delete created_onObj;
    
    return noNullObj;
}

bool jsonToRecord(Record record, Handle jsonRecord)
{
    bool noNullObj = false;
    Handle idObj = json_object_get(jsonRecord, "id");
    Handle map_nameObj = json_object_get(jsonRecord, "map_name");
    Handle timeObj = json_object_get(jsonRecord, "time");
    Handle pointsObj = json_object_get(jsonRecord, "points");
    
    if(idObj != null && map_nameObj != null &&
       timeObj != null && pointsObj != null)
    {
        record.id = json_integer_value(idObj);
        json_string_value(map_nameObj, record.map_name, sizeof(record.map_name));
        record.time = json_real_value(timeObj);
        record.points = json_integer_value(pointsObj);
        
        noNullObj = true; 
    }
    
    delete idObj;
    delete map_nameObj;
    delete timeObj;
    delete pointsObj;
    
    return noNullObj;
}

void printGlobalKzMapsToConsole()
{
    int mapsAdded = 0;
    for(int tier = 0; tier < GLOBAL_MAX_TIER; tier++)
    {
        int tierLength = GlobalMaps[tier].Length;
        for(int i = 0; i < tierLength; i++)
        {
            Map map;
            GlobalMaps[tier].GetArray(i, map, sizeof(map));
            PrintToConsole(myClient,
                           "%-4dName: %25s, Tier: %d, Created_on: %s",
                           mapsAdded,
                           map.name,
                           map.difficulty,
                           map.created_on);
            mapsAdded++;
        }
    }
}