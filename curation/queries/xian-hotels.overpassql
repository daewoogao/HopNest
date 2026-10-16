[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](34.195,108.857,34.335,109.037);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,34.447,108.752);
);
out center;
