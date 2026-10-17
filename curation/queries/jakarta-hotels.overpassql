[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](-6.300,106.730,-6.100,106.930);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,-6.126,106.656);
);
out center;
