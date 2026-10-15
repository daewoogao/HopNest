[out:csv(::type,::id,name,"name:en","name:ko-Latn","official_name:en",::lat,::lon,railway,public_transport;true;"\t")][timeout:200];
(
 node["railway"="station"](37.2,126.6,37.8,127.3);
 node["public_transport"="stop_position"]["subway"="yes"](37.2,126.6,37.8,127.3);
 node["public_transport"="stop_position"]["train"="yes"](37.2,126.6,37.8,127.3);
);
out;
