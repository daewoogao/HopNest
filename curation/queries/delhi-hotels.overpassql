[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](28.562,77.129,28.702,77.309);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,28.556,77.1);
);
out center;
