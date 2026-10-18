[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](29.677,-95.450,29.837,-95.290);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,29.99,-95.337);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,29.645,-95.279);
);
out center;
