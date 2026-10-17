[out:csv(::lat,::lon,name,"name:en",tourism,stars;true;"\t")][timeout:600];
nwr["tourism"~"^(hotel|hostel)$"]["name"](-37.926,144.826,-37.657,145.190);
out center;
