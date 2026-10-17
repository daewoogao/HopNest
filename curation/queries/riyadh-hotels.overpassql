[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](24.563,46.500,24.863,46.850);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,24.958,46.699);
);
out center;
