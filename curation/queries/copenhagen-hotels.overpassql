[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](55.606,12.478,55.746,12.658);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,55.618,12.65);
);
out center;
