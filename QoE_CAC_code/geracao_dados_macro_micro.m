%Rosana dados ma
Rd = [];  %vetorde taxa de downlink
Eu = [];  %vetor de taxa de BEP de uplink 
Lat= [];
cone = [];  %vetor do coeficiente de conexao (KPIs objetivos)

Rd = zeros(1,30);
Eu = zeros(1,30);
Latmacro = zeros(1,30);
cone = zeros(1,30);

for k = 1:30
    %Lat(k) = [10^-2]+ ([9*10^-2] - [10^-2])* rand; %Lat(k) = randi([10, 20]);
    Lat(k) = 0.08 + (0.09 - 0.08) * rand;
     %Eu(k)= rand([1e-8,1e-2]);    
   
    
    %Eu(k)= rand(1)/10;  
end

for i = 1:30
 %normatizando os valores de Rd 
    
    Lat(i) =  (Lat(i)  - min (Lat)) / (max(Lat)  - min (Lat));
    

  % cone(i)= Rd(i) * (1-Eu(i)) * Lat(i);  %% com latencia
  
  

%% gerando dados de Latencia
fid = fopen('dados_Lat_macro.csv', 'w');
fprintf(fid, 'Lat(i)\n');
for i = 1:30
    fprintf(fid, '%f\n', Lat(i));
end
fclose(fid);



end;

