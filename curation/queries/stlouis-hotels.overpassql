[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](38.557,-90.299,38.697,-90.099);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,38.748,-90.37);
);
out center;
