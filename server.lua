
-- connection
local connection = nil

-- This method allows to check if the DB schema exists, and in case it doesn't,
-- create the necessary tables.
function checkDBSchema()
    local query = dbPrepareString(connection, "CREATE TABLE IF NOT EXISTS properties(ID INTEGER PRIMARY KEY AUTOINCREMENT, INTERIOR INTEGER NOT NULL, ICON INTEGER DEFAULT NULL, X REAL NOT NULL, Y REAL NOT NULL, Z REAL NOT NULL, INT_X REAL NOT NULL, INT_Y REAL NOT NULL, INT_Z REAL NOT NULL, INT_A REAL NOT NULL, EXIT_X REAL NOT NULL, EXIT_Y REAL NOT NULL, EXIT_Z REAL NOT NULL, OUT_X REAL NOT NULL, OUT_Y REAL NOT NULL, OUT_Z REAL NOT NULL, OUT_A REAL NOT NULL, EXTRA BLOB DEFAULT NULL)")
    local handle = dbQuery(connection, query)
    dbFree(handle)

    outputServerLog("Database table loaded. Loading all properties...")
    handle = dbQuery(loadProperties, {}, connection, "SELECT * FROM properties")
end

-- This method allows to warp players easily between interiors, single-player style.
function warpPlayerInterior(player, interior, x, y, z, angle)
    if (isPedInVehicle(player)) then
        return
    end
    fadeCamera(player, false, 1.0)
    toggleAllControls(player, false, true, false)
    setTimer(function ()
        setElementInterior(player, interior)
        setElementPosition(player, x, y, z)
        setElementRotation(player, 0.0, 0.0, angle)
        fadeCamera(player, true, 1.0)
        toggleAllControls(player, true, true, false)
        setCameraTarget(player, player)
    end, 2000, 1)
end

-- This method allows to load all the database houses.
function loadProperties(handler)
    local results = dbPoll(handler, 0)
    if (type(results) ~= "table") then
        outputServerLog("No properties loaded.")
        return
    end

    outputServerLog("Loading " .. #results .. " properties...")
    for _, row in ipairs(results) do
        local markerEnter = createMarker(row["X"], row["Y"], row["Z"] + 0.5, "arrow", 1.0, 255, 255, 55)
        -- handle player entering interior marker.
        addEventHandler("onMarkerHit", markerEnter, function (hitElement)
            warpPlayerInterior(hitElement, row["INTERIOR"], row["INT_X"], row["INT_Y"], row["INT_Z"], row["INT_A"])
        end)

        if (row["ICON"] ~= nil) then
            createBlipAttachedTo(markerEnter, row["ICON"], 1, 255, 255, 255, 255, 0, 350.0)
        end

        local markerExit = createMarker(row["EXIT_X"], row["EXIT_Y"], row["EXIT_Z"] + 0.5, "arrow", 1.0, 255, 255, 55)
        setElementInterior(markerExit, row["INTERIOR"])
        -- handle player entering exit marker.
        addEventHandler("onMarkerHit", markerExit, function (hitElement)
            warpPlayerInterior(hitElement, 0, row["OUT_X"], row["OUT_Y"], row["OUT_Z"], row["OUT_A"])
        end)

        -- add some data to indicate that it is a property.
        setElementData(markerEnter, "interiorMarker", true)
        setElementData(markerExit, "interiorMarker", true)

        -- send created property signal
        triggerEvent("serverCreatedProperty", resourceRoot, row, markerEnter, markerExit)
    end
    outputServerLog("Done.")
end

addEventHandler("onResourceStart", resourceRoot, function ()
    connection = dbConnect("sqlite", "properties.db")
    if (connection) then
        checkDBSchema()
    end
end)

addEvent("serverCreatedProperty")
