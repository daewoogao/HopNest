[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](37.714,-122.498,37.854,-122.318);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,37.621,-122.379);
);
out center;
