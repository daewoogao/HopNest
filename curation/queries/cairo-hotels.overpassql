[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](29.919,31.086,30.169,31.386);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,30.112,31.4);
);
out center;
