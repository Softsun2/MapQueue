/*======================== Variables ========================*/

static char gameModeStrsForAPI[3][16] =
{
    "kz_timer",
    "kz_simple",
    "kz_vanilla"
};
static bool storeRecordsToMap;

/*======================== Utilities ========================*/

void InitBufferHandlers()
{
    BufferHandlerStoreMaps = new DataPack();
    BufferHandlerStoreMaps.WriteFunction(storeMapJsonData);
    BufferHandlerMapRecords = new DataPack();
    BufferHandlerMapRecords.WriteFunction(mapRecordJsonData);
}

void createRequest(const char[] sURL)
{
    Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET, sURL); 
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
                Format(buffer[size], sizeof(buffer)-size, "");  // temp fix for weird "ghost buffer" issue
                if(BufferHandler == int(storeMaps))
                {
                    BufferHandlerStoreMaps.Reset();
                    Call_StartFunction(INVALID_HANDLE, BufferHandlerStoreMaps.ReadFunction());
                }
                else
                {
                    BufferHandlerMapRecords.Reset();
                    Call_StartFunction(INVALID_HANDLE, BufferHandlerMapRecords.ReadFunction());
                }
                Call_PushString(buffer);
                Call_Finish();
            }
        }
        delete request;
    }
}

/*======================== Storing All Global Maps ========================*/

void InitMaps()
{
    for(int i = 0; i < GLOBAL_MAX_TIER; i++)
    {
        GlobalMaps[i] = CreateArray(ByteCountToCells(PLATFORM_MAX_PATH));
    }
    char sURL[] = "https://kztimerglobal.com/api/v2/maps?is_validated=true&limit=15";
    BufferHandler = int(storeMaps);
    createRequest(sURL);
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
                    GlobalMaps[tier_0].PushArray(map, sizeof(map));
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
    // Make and delete string map on the start and end of this function if needed
    if(MapQueue == INVALID_HANDLE)
    {
        MapQueue = CreateArray(ByteCountToCells(PLATFORM_MAX_PATH));
    }
    else
    {
        MapQueue.Clear();
    }
    
    // case 0: queue from GlobalMaps
    if(MapCompletionStatus == int(AnyCompletion))
    {
        for(int tier = MinTier-1; tier < MaxTier; tier++)
        {
            int tierLength = GlobalKzMaps[tier].Length;
            for(int i = 0; i < tierLength; i++)
            {
                Map map;
                GlobalKzMaps[tier].GetArray(i, map, sizeof(map));
                MapQueue.PushArray(map, sizeof(map));
            }
        }
    }
    
    // case 1: queue from RelatedRecordsList
    else if(MapCompletionStatus == int(Completed) &&
            MaxTier == GLOBAL_MAX_TIER &&
            MinTier == GLOBAL_MIN_TIER)
    {
        storeRecordsToMap = false;
        
        RelatedRecordsList.Clear();
    }
    
    // case 2: queue from GloablMaps(RelatedRecordsMap)
    else
    {
        //     subcase 0:
        //         compare GlobalMaps against RelatedRecordsMap
        if(MapCompletionStatus == int(NotCompleted))
        {
            
        }
        
        //     subcase 1:
        //         compare GlobalMaps with RelatedRecordsMap
        else
        {
            
        }
        
        RelatedRecordsMap.Clear();
    }
    
    /*char sURL[512];
    getFilterRequestURL(client, sURL, sizeof(sURL));
    PrintToServer("%s", sURL);*/
    
    
    BufferHandler = int(mapMaps);
    createRequest(sURL);
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
    
    // temp limit while debugging
    StrCat(requestBuffer, requestBufferSize, "&limit=15");
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
                    PrintToConsole(myClient,
                                   "%-4dId: %9d, Map_name: %25s, Time: %7.2f, Points: %d",
                                   i,
                                   record.id,
                                   record.map_name,
                                   record.time,
                                   record.points);
                    if(storeRecordsToMap)
                    {
                        RelatedRecordsMap.SetArray(record.map_name, record, sizeof(record));
                    }
                    else
                    {
                        RelatedRecordsList.PushArray(record, sizeof(record));
                    }
                }
            }
            delete jsonRecord;
        }
    }
    delete array;
}