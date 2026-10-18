[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](30.25,-97.76,30.29,-97.72);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,30.1975,-97.6664);
);
out center;
