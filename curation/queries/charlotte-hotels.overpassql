[out:csv(::type,::id,name,"name:en",::lat,::lon,tourism,stars,brand,operator,website;true;"	")][timeout:300];
(
 nwr["tourism"~"^(hotel|hostel)$"](35.157,-80.923,35.297,-80.763);
 nwr["tourism"~"^(hotel|hostel)$"](around:3000,35.214,-80.947);
);
out center;
