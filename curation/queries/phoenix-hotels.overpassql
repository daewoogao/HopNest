[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](33.380,-112.190,33.540,-111.910);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,33.434,-112.008);
);
out center;
