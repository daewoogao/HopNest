[out:csv(::type,::id,name,"name:en",iata,::lat,::lon,railway,aeroway;true;"\t")][timeout:300];
(
 nwr["aeroway"="aerodrome"]["iata"~"^(BER|AMS|VIE|PRG|IST|SAW|LIS|MXP|LIN|BGY|DCA|IAD|ORD|MDW|MEX|NLU)$"];
 nwr["railway"="station"]["name"~"^(Berlin Hauptbahnhof|Amsterdam Centraal|Wien Hauptbahnhof|Praha hlavní nádraží|Lisboa - Santa Apolónia|Lisboa - Oriente|Milano Centrale|Union Station|Chicago Union Station|Sirkeci|Halkalı|Söğütlüçeşme)"];
);
out center;
