[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](40.690,-111.980,40.830,-111.800);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,40.789,-111.979);
);
out center;
