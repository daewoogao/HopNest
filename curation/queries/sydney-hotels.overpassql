[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](-33.995,151.057,-33.745,151.357);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,-33.94,151.175);
);
out center;
