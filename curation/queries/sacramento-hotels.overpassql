[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](38.54,-121.53,38.62,-121.45);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,38.6954,-121.5908);
);
out center;
