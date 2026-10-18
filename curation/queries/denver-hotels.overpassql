[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](39.665,-105.090,39.825,-104.890);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,39.849,-104.674);
);
out center;
