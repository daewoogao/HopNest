[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](31.740,35.165,31.820,35.265);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,32.009,34.877);
);
out center;
