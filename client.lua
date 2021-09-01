addEventHandler("onClientMarkerHit", resourceRoot, function (hitPlayer)
    if (hitPlayer == localPlayer) then
        if (isPedInVehicle(hitPlayer)) then
            return
        end
        local isInteriorMarker = getElementData(source, "interiorMarker")
        if (isInteriorMarker) then
            setTimer(function ()
                playSFX("genrl", 44, 1, false)
            end, 1000, 1)
        end
    end
end)