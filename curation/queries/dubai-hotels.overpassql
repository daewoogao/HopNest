[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](25.127,55.184,25.267,55.364);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,25.253,55.365);
);
out center;
