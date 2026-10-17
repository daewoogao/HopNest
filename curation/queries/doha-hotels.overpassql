[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](25.136,51.406,25.436,51.656);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,25.273,51.608);
);
out center;
