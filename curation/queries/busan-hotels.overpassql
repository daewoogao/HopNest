[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](35.088,128.970,35.228,129.150);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,35.179,128.938);
);
out center;
