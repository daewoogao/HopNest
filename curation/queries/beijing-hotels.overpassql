[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"\t")][timeout:300];
(nwr["tourism"~"^(hotel|hostel)$"](39.82,116.28,39.98,116.50);nwr["tourism"~"^(hotel|hostel)$"](40.04,116.55,40.10,116.64);nwr["tourism"~"^(hotel|hostel)$"](39.48,116.36,39.53,116.45););
out center;
