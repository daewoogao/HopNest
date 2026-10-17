[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](55.913,-3.289,55.993,-3.089);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,55.95,-3.363);
);
out center;
