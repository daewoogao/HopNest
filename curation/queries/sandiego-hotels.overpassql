[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](32.615,-117.260,32.815,-117.060);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,32.733,-117.19);
);
out center;
