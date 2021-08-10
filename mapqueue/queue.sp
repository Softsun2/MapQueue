/*======================== Variables ========================*/
static char gameModeStrsForAPI[3][16] =
{
    "kz_timer",
    "kz_simple",
    "kz_vanilla"
};

/*======================== Utilities ========================*/

void InitRequestHandlers()
{
    RequestHandlerStoreMaps = new DataPack();
    RequestHandlerStoreMaps.WriteFunction(storeMapJsonData);
    RequestHandlerMapRecords = new DataPack();
    RequestHandlerMapRecords.WriteFunction(mapRecordJsonData);
}

void createRequest(const char[] requestURL)
{
    Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, requestURL); 
    if(request != INVALID_HANDLE)
    {
        if (!SteamWorks_SetHTTPCallbacks(request, HTTPRequestCompleted_Maps) || !SteamWorks_SendHTTPRequest(request))
        {
            delete request;
        }
    }
}

void HTTPRequestCompleted_Maps(Handle request, bool failure, bool requestSuccess, EHTTPStatusCode status, any data)
{
    if(!failure && requestSuccess && status == k_EHTTPStatusCode200OK)
    {
        int size;
        if(SteamWorks_GetHTTPResponseBodySize(request, size))
        {
            static char buffer[512000];
            if((size < sizeof(buffer)) && SteamWorks_GetHTTPResponseBodyData(request, buffer, size))
            {
                Format(buffer[size], sizeof(buffer)-size, "");  // NOTE(Softsun2): temp fix for weird "ghost buffer" issue
                if(RequestHandler == int(storeMaps))
                {
                    RequestHandlerStoreMaps.Reset();
                    Call_StartFunction(INVALID_HANDLE, RequestHandlerStoreMaps.ReadFunction());
                    Call_PushString(buffer);
                    Call_Finish();
                }
                else
                {
                    RequestHandlerMapRecords.Reset();
                    Call_StartFunction(INVALID_HANDLE, RequestHandlerMapRecords.ReadFunction());
                    Call_PushString(buffer);
                    Call_Finish();
                    compareToRecords();
                }
            }
        }
        delete request;
    }
}

void gotoNextInQueue(int client)
{
    if(MapQueue.Length > 0)
    {
        char mapName[PLATFORM_MAX_PATH];
        MapQueue.GetString(0, mapName, PLATFORM_MAX_PATH);
        FakeClientCommand(client, "sm_map %s", mapName); 
    }
    else
    {
        PrintToConsole(client, "No maps in queue.");
    }
}

/*======================== Storing All Global Maps ========================*/

void InitMaps()
{
    for(int i = 0; i < GLOBAL_MAX_TIER; i++)
    {
        GlobalMaps[i] = CreateArray(sizeof(Map));
    }
    
    //char requestURL[] = "https://kztimerglobal.com/api/v2/maps?is_validated=true&limit=15";
    char requestURL[128];
    Format(requestURL, sizeof(requestURL), "https://kztimerglobal.com/api/v2/maps?is_validated=true&limit=%d",
           REQUEST_LIMIT);
    RequestHandler = int(storeMaps);
    createRequest(requestURL);
}

void storeMapJsonData(const char[] buffer)
{
    Handle array = json_load(buffer);
    if(array != null)
    {
        int arraySize = json_array_size(array);
        for(int i = 0; i < arraySize; i++)
        {
            Handle jsonMap = json_array_get(array, i);
            if(jsonMap != null)
            {
                Map map;
                if(jsonToMap(map, jsonMap))
                {
                    int tier_0 = map.difficulty - 1;
                    GlobalMaps[tier_0].PushArray(map, sizeof(Map));
                }
            }
            delete jsonMap;
        }
    }
    delete array;
    printGlobalKzMapsToConsole();
}

/*======================== Queueing ========================*/

void queueFilters(int client)
{
    MapQueue.Clear();
    if(MapCompletionStatus == int(AnyCompletion))
    {
        PrintToConsole(client, "In case 0");
        for(int tier = MinTier-1; tier < MaxTier; tier++)
        {
            int tierLength = GlobalMaps[tier].Length;
            for(int i = 0; i < tierLength; i++)
            {
                Map map;
                GlobalMaps[tier].GetArray(i, map, sizeof(Map));
                MapQueue.PushString(map.name);
            }
        }
    }
    
    else
    {
        char requestURL[512];
        getFilterRequestURL(client, requestURL, sizeof(requestURL));
        RequestHandler = int(storeRecords);
        createRequest(requestURL);
    }
}

void compareToRecords()
{
    if(MapCompletionStatus == int(NotCompleted))
    {
        for(int tier = MinTier-1; tier < MaxTier; tier++)
        {
            int tierLength = GlobalMaps[tier].Length;
            for(int i = 0; i < tierLength; i++)
            {
                Map map;
                Record record;
                GlobalMaps[tier].GetArray(i, map, sizeof(Map));
                if(!RelatedRecordsMap.GetArray(map.name, record, sizeof(Record)))
                {
                    MapQueue.PushString(map.name);
                }
            }
        }
    }
    
    else
    {
        for(int tier = MinTier-1; tier < MaxTier; tier++)
        {
            int tierLength = GlobalMaps[tier].Length;
            for(int i = 0; i < tierLength; i++)
            {
                Map map;
                Record record;
                GlobalMaps[tier].GetArray(i, map, sizeof(Map));
                if(RelatedRecordsMap.GetArray(map.name, record, sizeof(Record)))
                {
                    if(MinPoints <= record.points && record.points <= MaxPoints)
                    {
                        MapQueue.PushString(map.name);
                    }
                }
            }
        }
    }
    
    RelatedRecordsMap.Clear();
}

void getFilterRequestURL(int client, char[] requestBuffer, int requestBufferSize)
{
    Format(requestBuffer, requestBufferSize,
           "https://kztimerglobal.com/api/v2/records/top?");
    
    char steamId[32];
    GetClientAuthId(client, AuthId_SteamID64, steamId, sizeof(steamId));
    StrCat(requestBuffer, requestBufferSize, "steamid64=");
    StrCat(requestBuffer, requestBufferSize, steamId);
    
    char tickrate[16];
    IntToString(RoundToFloor(1.0 / GetTickInterval()), tickrate, sizeof(tickrate));
    StrCat(requestBuffer, requestBufferSize, "&tickrate=");
    StrCat(requestBuffer, requestBufferSize, tickrate);
    
    // TODO(Softsun2): make this a filter in the future as of now stage defaults to 0
    char stage[16];
    Format(stage, sizeof(stage), "&stage=0");
    StrCat(requestBuffer, requestBufferSize, stage);
    
    if(GameMode != int(AnyGameMode))
    {
        StrCat(requestBuffer, requestBufferSize, "&modes_list=");
        StrCat(requestBuffer, requestBufferSize, gameModeStrsForAPI[GameMode-1]);
    }
    
    if(MapCompletionType != int(NUB))
    {
        StrCat(requestBuffer, requestBufferSize, "&has_teleports=");
        
        char has_teleports[8];
        if(MapCompletionType == int(Pro))
        {
            Format(has_teleports, requestBufferSize, "false");
        }
        else
        {
            Format(has_teleports, requestBufferSize, "true");
        }
        StrCat(requestBuffer, requestBufferSize, has_teleports);
    }
    
    char limit[16];
    Format(limit, sizeof(limit), "&limit=%d", REQUEST_LIMIT);
    StrCat(requestBuffer, requestBufferSize, limit);
    
    PrintToServer("%s", requestBuffer);
}

void mapRecordJsonData(const char[] buffer)
{
    Handle array = json_load(buffer);
    if(array != null)
    {
        int arraySize = json_array_size(array);
        for(int i = 0; i < arraySize; i++)
        {
            Handle jsonRecord = json_array_get(array, i);
            if(jsonRecord != null)
            {
                Record record;
                if(jsonToRecord(record, jsonRecord))
                {
                    PrintToServer("%-4dId: %9d, Map_name: %25s, Time: %7.2f, Points: %d",
                                  i,
                                  record.id,
                                  record.map_name,
                                  record.time,
                                  record.points);
                    RelatedRecordsMap.SetArray(record.map_name, record, sizeof(Record));
                }
            }
            delete jsonRecord;
        }
    }
    delete array;
    //printRelatedRecordsMapToConsole();
}