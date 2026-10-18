[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](27.93,-82.47,27.97,-82.43);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,27.9755,-82.5332);
);
out center;
