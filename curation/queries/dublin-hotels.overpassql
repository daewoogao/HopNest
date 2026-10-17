[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](53.289,-6.360,53.409,-6.160);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,53.421,-6.27);
);
out center;
