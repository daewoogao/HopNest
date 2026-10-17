[out:csv(::lat,::lon,name,"name:en",tourism,stars;true;"\t")][timeout:600];
nwr["tourism"~"^(hotel|hostel)$"]["name"](-23.019,-43.380,-22.794,-43.148);
out center;
