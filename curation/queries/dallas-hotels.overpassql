[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](32.700,-96.900,32.860,-96.700);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,32.899,-97.04);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,32.847,-96.851);
);
out center;
