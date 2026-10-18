[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](39.095,-84.53,39.12,-84.50);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,39.0488,-84.6678);
);
out center;
