[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](50.777,4.262,50.917,4.442);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,50.901,4.484);
);
out center;
