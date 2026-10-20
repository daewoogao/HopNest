[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](31.260,120.550,31.360,120.750);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,31.494,120.429);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,31.33,120.611);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,31.42,120.641);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,31.33,120.716);
);
out center;
