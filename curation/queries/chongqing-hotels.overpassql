[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](29.500,106.450,29.640,106.620);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,29.719,106.642);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,29.609,106.551);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,29.497,106.427);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,29.557,106.454);
);
out center;
