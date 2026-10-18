[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](47.512,-122.455,47.712,-122.215);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,47.449,-122.309);
);
out center;
