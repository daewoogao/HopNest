[out:csv(::lat,::lon,name,"name:en",tourism,stars;true;"\t")][timeout:600];
nwr["tourism"~"^(hotel|hostel)$"]["name"](48.109,16.246,48.290,16.578);
out center;
