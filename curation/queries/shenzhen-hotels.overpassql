[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](22.473,113.968,22.613,114.148);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,22.639,113.811);
);
out center;
