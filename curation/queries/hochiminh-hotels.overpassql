[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](10.701,106.625,10.851,106.775);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,10.818,106.659);
);
out center;
