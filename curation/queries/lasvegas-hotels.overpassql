[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](36.090,-115.200,36.170,-115.140);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,36.084,-115.154);
);
out center;
