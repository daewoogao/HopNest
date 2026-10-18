[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](43.02,-87.93,43.06,-87.89);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,42.9472,-87.8966);
);
out center;
