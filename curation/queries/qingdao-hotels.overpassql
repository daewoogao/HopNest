[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](36.040,120.300,36.120,120.480);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,36.362,120.088);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,36.064,120.312);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,36.167,120.374);
);
out center;
