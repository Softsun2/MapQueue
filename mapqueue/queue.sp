/*======================== Storing All Global Maps ========================*/

void InitMaps()
{
    for(int i = 0; i < GLOBAL_MAX_TIER; i++)
    {
        MapsPerTier[i] = CreateArray(ByteCountToCells(PLATFORM_MAX_PATH));
    }

    // from nominations_extended.sp
    char sURL[] = "https://kztimerglobal.com/api/v2/maps?is_validated=true&limit=15";
    Handle request = SteamWorks_CreateHTTPRequest(k_EHTTPMethodGET,sURL); 
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
                StoreMapJsonData(buffer);
            }
        }
    }
    delete request;
}

void StoreMapJsonData(const char[] buffer)
{
    Handle array = json_load(buffer);
    if(array != null)
    {
        int arraySize = json_array_size(array);
        for(int i = 0; i < arraySize; i++){
            Handle jsonMap = json_array_get(array, i);
            if(jsonMap != null)
            {
                char mapString[512];
                if(jsonMapsToString(mapString, sizeof(mapString), jsonMap))
                {
                    char mapAttributes[4][64];
                    splitMapString(mapAttributes, mapString);
                    int tier_0 = StringToInt(mapAttributes[difficulty]) - 1;
                    PushArrayString(MapsPerTier[tier_0], mapString);
                }
           }
            delete jsonMap;
        }
    }
    delete array;
    printMapsToServer();
}