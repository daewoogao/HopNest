[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](20.968,105.759,21.088,105.909);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,21.221,105.807);
);
out center;
