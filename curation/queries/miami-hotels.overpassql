[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](25.650,-80.275,25.900,-80.125);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,25.795,-80.287);
);
out center;
