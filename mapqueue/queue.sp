/*======================== Utility ========================*/

void InitBufferHandlers()
{
    BufferHandlerStoreMaps = new DataPack();
    BufferHandlerStoreMaps.WriteFunction(storeMapJsonData);
    BufferHandlerMapMaps = new DataPack();
    BufferHandlerMapMaps.WriteFunction(mapMapJsonData);
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

// from nominations_extended.sp
void HTTPRequestCompleted_Maps(Handle request, bool failure, bool requestSuccess, EHTTPStatusCode status, any data)
{
    if (!failure && requestSuccess && status == k_EHTTPStatusCode200OK)
    {
        int size;
        if (SteamWorks_GetHTTPResponseBodySize(request, size))
        {
            static char buffer[512000]; // :)
            if ((size < sizeof(buffer)) && SteamWorks_GetHTTPResponseBodyData(request, buffer, size))
            {
                if(BufferHandler == int(storeMaps))
                {
                    BufferHandlerStoreMaps.Reset();
                    Call_StartFunction(INVALID_HANDLE, BufferHandlerStoreMaps.ReadFunction());
                }
                else
                {
                    BufferHandlerMapMaps.Reset();
                    Call_StartFunction(INVALID_HANDLE, BufferHandlerMapMaps.ReadFunction());
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
        MapsPerTier[i] = CreateArray(ByteCountToCells(PLATFORM_MAX_PATH));
    }
    
    // from nominations_extended.sp
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
                    MapsPerTier[tier_0].PushArray(map, sizeof(map));
                }
                delete jsonMap;
            }
        }
        delete array;
        printMapsToServer();
    }
}

/*======================== Queueing ========================*/

char gameModeStrsForAPI[3][16] =
{
    "kz_timer",
    "kz_simple",
    "kz_vanilla"
};

void queueFilters(int client)
{
    char sURL[512];
    getFilterRequestURL(client, sURL, sizeof(sURL));
    PrintToServer("%s", sURL);
    
    /*
    special cases:
        completion status: Not completed or any completion
    */
    
    BufferHandler = int(mapMaps);
    createRequest(sURL);
}

void getFilterRequestURL(int client, char[] requestBuffer, int requestBufferSize)
{
    Format(requestBuffer, sizeof(requestBufferSize), "https://kztimerglobal.com/api/v2/records/top?");
    
    char steamId[32];
    GetClientAuthId(client, AuthId_Steam2, steamId, sizeof(steamId));
    ReplaceString(steamId, sizeof(steamId), ":", "%");
    StrCat(requestBuffer, requestBufferSize, "steam_id=");
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
    
    // limit for debugging
    StrCat(requestBuffer, requestBufferSize, "&limit=15");
}

void mapMapJsonData()
{
}