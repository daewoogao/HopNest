[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](59.260,17.978,59.400,18.158);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,59.65,17.93);
);
out center;
