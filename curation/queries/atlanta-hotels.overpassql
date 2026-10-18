[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](33.635,-84.490,33.875,-84.290);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,33.64,-84.427);
);
out center;
