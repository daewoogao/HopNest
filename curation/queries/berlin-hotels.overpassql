[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
nwr["tourism"~"^(hotel|hostel)$"](52.36,13.25,52.56,13.56);
out center;
