[out:csv(::type,::id,name,"name:en",iata,::lat,::lon,railway,aeroway;true;"\t")][timeout:300];
(
 nwr["aeroway"="aerodrome"]["iata"~"^(CDG|ORY|ICN|GMP|KIX|ITM|HKG|SIN)$"];
 nwr["railway"="station"]["name"~"^(Gare du Nord|Gare de Lyon|Gare Montparnasse|Paris Montparnasse|Gare de l'Est|Paris Gare de Lyon|Paris Nord|Paris Est)$"](48.80,2.25,48.92,2.42);
 nwr["railway"="station"]["name:en"~"^(Seoul Station|Yongsan|Suseo)$"](37.45,126.8,37.6,127.2);
 nwr["railway"="station"]["name:en"~"^(Shin-Osaka|Osaka|Tennoji|Namba|Shin-Ōsaka|Ōsaka)$"](34.6,135.4,34.8,135.6);
 nwr["railway"="station"]["name:en"~"^(Hong Kong West Kowloon|West Kowloon|Hung Hom|Hong Kong)$"](22.2,114.0,22.4,114.3);
 nwr["railway"="station"]["name:en"~"^(Woodlands|Woodlands Train Checkpoint)$"](1.40,103.70,1.47,103.85);
);
out center;
