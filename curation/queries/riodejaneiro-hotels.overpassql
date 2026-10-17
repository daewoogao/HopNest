[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](-22.990,-43.355,-22.870,-43.105);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,-22.81,-43.25);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,-22.91,-43.163);
);
out center;
