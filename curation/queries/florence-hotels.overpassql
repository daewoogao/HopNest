[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](43.733,11.196,43.813,11.316);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,43.81,11.205);
);
out center;
