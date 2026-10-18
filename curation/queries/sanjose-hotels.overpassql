[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](37.31,-121.92,37.36,-121.86);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,37.3626,-121.929);
);
out center;
