[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](23.059,113.174,23.199,113.354);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,23.392,113.299);
);
out center;
