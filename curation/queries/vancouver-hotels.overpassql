[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](49.175,-123.175,49.325,-122.925);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,49.195,-123.178);
);
out center;
