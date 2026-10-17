[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](34.943,135.705,35.063,135.825);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,34.432,135.23);
);
out center;
