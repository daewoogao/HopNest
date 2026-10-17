[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](18.926,72.777,19.226,72.977);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,19.09,72.866);
);
out center;
