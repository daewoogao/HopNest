[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](48.067,11.485,48.207,11.665);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,48.354,11.786);
);
out center;
