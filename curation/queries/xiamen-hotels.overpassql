[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](24.430,118.060,24.520,118.180);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,24.544,118.128);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,24.627,118.074);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,24.469,118.115);
);
out center;
