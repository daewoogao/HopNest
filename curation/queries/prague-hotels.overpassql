[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
nwr["tourism"~"^(hotel|hostel)$"](50.02,14.25,50.12,14.52);
out center;
