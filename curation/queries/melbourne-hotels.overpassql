[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](-37.864,144.903,-37.764,145.023);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,-37.669,144.841);
);
out center;
