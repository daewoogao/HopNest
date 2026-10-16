[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](-34.673,-58.480,-34.533,-58.300);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,-34.822,-58.536);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,-34.558,-58.416);
);
out center;
