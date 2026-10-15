[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
nwr["tourism"~"^(hotel|hostel)$"](41.78,12.20,41.95,12.62);
out center;
