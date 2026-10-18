[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](39.07,-94.60,39.11,-94.57);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,39.2976,-94.7139);
);
out center;
