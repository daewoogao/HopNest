[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](28.150,112.920,28.240,113.060);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,28.189,113.22);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,28.149,113.065);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,28.196,113.012);
);
out center;
