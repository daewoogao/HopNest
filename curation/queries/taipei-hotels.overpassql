[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
nwr["tourism"~"^(hotel|hostel)$"](24.98,121.20,25.10,121.60);
out center;
