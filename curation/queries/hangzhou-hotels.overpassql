[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](30.200,120.080,30.330,120.240);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,30.229,120.434);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,30.291,120.213);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,30.244,120.182);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,30.34,119.977);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,30.175,120.297);
);
out center;
