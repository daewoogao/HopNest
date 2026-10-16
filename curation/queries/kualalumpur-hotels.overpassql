[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](3.078,101.610,3.218,101.790);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,2.745,101.71);
);
out center;
