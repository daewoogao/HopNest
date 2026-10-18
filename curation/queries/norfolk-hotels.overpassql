[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](36.84,-76.30,36.87,-76.26);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,36.8946,-76.2012);
);
out center;
