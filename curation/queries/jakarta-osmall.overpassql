[out:csv(::lat,::lon,name,"name:en",tourism,stars;true;"\t")][timeout:600];
nwr["tourism"~"^(hotel|hostel)$"]["name"](-6.386,106.638,-6.108,107.037);
out center;
