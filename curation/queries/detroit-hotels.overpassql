[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](42.32,-83.07,42.37,-83.03);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,42.2124,-83.3534);
);
out center;
