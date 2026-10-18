[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](42.87,-78.89,42.91,-78.86);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,42.9405,-78.7322);
);
out center;
