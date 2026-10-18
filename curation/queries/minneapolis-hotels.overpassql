[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](44.907,-93.385,45.047,-93.145);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,44.882,-93.208);
);
out center;
