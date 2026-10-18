[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](39.230,-76.692,39.350,-76.532);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,39.177,-76.668);
);
out center;
