[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](43.583,-79.473,43.723,-79.293);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,43.678,-79.625);
);
out center;
