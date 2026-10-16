[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](33.980,-118.390,34.120,-118.210);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,33.942,-118.408);
);
out center;
