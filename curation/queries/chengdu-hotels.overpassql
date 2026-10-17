[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](30.510,103.915,30.810,104.215);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,30.578,103.947);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,30.312,104.441);
);
out center;
