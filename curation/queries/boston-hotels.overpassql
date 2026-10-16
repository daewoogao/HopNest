[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](42.286,-71.150,42.426,-70.970);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,42.366,-71.01);
);
out center;
