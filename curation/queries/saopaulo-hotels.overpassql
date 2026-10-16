[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](-23.630,-46.740,-23.490,-46.560);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,-23.432,-46.469);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,-23.626,-46.656);
);
out center;
