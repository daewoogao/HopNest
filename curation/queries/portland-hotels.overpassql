[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](45.450,-122.770,45.590,-122.590);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,45.588,-122.593);
);
out center;
