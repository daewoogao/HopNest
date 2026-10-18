[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](39.872,-75.265,40.032,-75.065);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,39.874,-75.242);
);
out center;
