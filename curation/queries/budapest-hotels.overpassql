[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](47.428,18.950,47.568,19.130);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,47.437,19.256);
);
out center;
