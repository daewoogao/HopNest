[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](45.435,-73.657,45.575,-73.477);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,45.47,-73.741);
);
out center;
