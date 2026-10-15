[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
nwr["tourism"~"^(hotel|hostel)$"](37.42,126.40,37.70,127.20);
out center;
