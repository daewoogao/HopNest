[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](21.240,-157.920,21.340,-157.760);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,21.318,-157.922);
);
out center;
