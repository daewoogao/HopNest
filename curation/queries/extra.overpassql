[out:csv(::type,::id,name,"name:en",railway,station,network,tourism,::lat,::lon;true;"\t")][timeout:300];
(
 nwr["railway"="station"](13.68,100.46,13.76,100.56);
 nwr["tourism"~"^(hotel|guest_house)$"](around:2500,41.786,-87.752);
 nwr["tourism"~"^(hotel|guest_house|apartment)$"](around:2500,41.799,12.594);
);
out center;
