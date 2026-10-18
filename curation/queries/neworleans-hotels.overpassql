[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](29.891,-90.151,30.011,-89.991);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,29.993,-90.258);
);
out center;
