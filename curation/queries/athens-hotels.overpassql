[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](37.909,23.638,38.049,23.818);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,37.936,23.947);
);
out center;
