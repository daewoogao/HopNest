[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](32.21,-110.99,32.24,-110.94);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,32.1161,-110.941);
);
out center;
