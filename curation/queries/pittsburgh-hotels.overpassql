[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](40.381,-80.080,40.501,-79.920);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,40.491,-80.233);
);
out center;
