[out:csv(::lat,::lon,name,"name:en",tourism,stars;true;"\t")][timeout:600];
nwr["tourism"~"^(hotel|hostel)$"]["name"](22.119,113.514,22.196,113.592);
out center;
