[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](41.48,-81.72,41.52,-81.66);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,41.4117,-81.8498);
);
out center;
