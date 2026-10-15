[out:csv(::type,::id,name,"name:en",iata,::lat,::lon,railway,aeroway;true;"\t")][timeout:300];
(
 nwr["aeroway"="aerodrome"]["iata"~"^(TPE|TSA|BKK|DMK|PEK|PKX|MAD|FCO|CIA)$"];
 nwr["railway"="station"]["name:en"~"^(Taipei Main Station|Taipei)$"](25.0,121.4,25.1,121.6);
 nwr["railway"="station"]["name:en"~"Krung Thep Aphiwat|Hua Lamphong|Bangkok"](13.7,100.45,13.85,100.6);
 nwr["railway"="station"]["name:en"~"^Beijing( South| West| North)?( Railway)?( Station)?$|^Beijing(nan|xi|bei)?$|Beijing Chaoyang|Beijing Fengtai"](39.8,116.25,40.0,116.55);
 nwr["railway"="station"]["name"~"Atocha|Chamart"](40.39,-3.70,40.48,-3.67);
 nwr["railway"="station"]["name"~"Termini|Tiburtina"](41.89,12.49,41.92,12.54);
);
out center;
