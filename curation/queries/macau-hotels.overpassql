[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](22.130,113.525,22.210,113.605);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,22.149,113.592);
);
out center;
