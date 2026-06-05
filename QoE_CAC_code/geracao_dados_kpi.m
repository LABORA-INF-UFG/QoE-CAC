%Rosana - parte do RDk e EUk
Rd = [];  %vetorde taxa de downlink
Eu = [];  %vetor de taxa de BEP de uplink 
Lat= [];
cone = [];  %vetor do coeficiente de conexao (KPIs objetivos)

Rd = zeros(1,30);
Eu = zeros(1,30);
Lat = zeros(1,30);
Latmacro = zeros(1,30);
cone = zeros(1,30);
conemacro = zeros(1,30);

for k = 1:30
    Rd(k) = randi([10, 42]);
    Lat(k) = [10^-2]+ ([2*10^-2] - [10^-2])* rand; %Lat(k) = randi([10, 20]);
     %Eu(k)= rand([1e-8,1e-2]);    
    Latmacro(k) = 0.08 + (0.09 - 0.08) * rand;
    Eu(k)= [10^-8]+ ([10^-2] - [10^-8])*rand
    
    %Eu(k)= rand(1)/10;  
end

for i = 1:30
 %normatizando os valores de Rd 
    Rd(i) =  (Rd(i)  - min (Rd)) / (max(Rd)  - min (Rd));  
    Eu(i) =  (Eu(i)  - min (Eu)) / (max(Eu)  - min (Eu)); 
    Lat(i) =  (Lat(i)  - min (Lat)) / (max(Lat)  - min (Lat));
    Latmacro(i) =  (Latmacro(i)  - min (Latmacro)) / (max(Latmacro)  - min (Latmacro));
    
%%%%%%teste
  % cone(i)= Rd(i) * (1-Eu(i)) * Lat(i);  %% com latencia
    cone(i)= Rd(i) * (1-Eu(i)) *Lat(i);  %% com latencia
   conemacro(i)= Rd(i) * (1-Eu(i)) *Latmacro(i);  %% co

  %%%% se for voltar ...
%    cone(i)= Rd(i) * (1-Eu(i)) *(1-Lat(i));  %% com latencia
%    conemacro(i)= Rd(i) * (1-Eu(i)) *(1-Latmacro(i));  %% com latencia
  

%% gerando dados de Downlink
fid = fopen('dados_Rd.csv', 'w');
fprintf(fid, 'Rd(i)\n');
for i = 1:30
    fprintf(fid, '%f\n', Rd(i));
end
fclose(fid);

%% gerando dados de Uplink
fid = fopen('dados_Eu.csv', 'w');
fprintf(fid, 'Eu(i)\n');
for i = 1:30
    fprintf(fid, '%f\n', Eu(i));
end
fclose(fid);

%% gerando dados de Latencia
fid = fopen('dados_Lat_low.csv', 'w');
fprintf(fid, 'Lat(i)\n');
for i = 1:30
    fprintf(fid, '%f\n', Lat(i));
end
fclose(fid);

%% gerando dados de Latencia macro
fid = fopen('dados_Lat_macro.csv', 'w');
fprintf(fid, 'Latmacro(i)\n');
for i = 1:30
    fprintf(fid, '%f\n', Latmacro(i));
end
fclose(fid);

%% gerando dados de conexao
fid = fopen('dados_cone.csv', 'w');
fprintf(fid, 'cone(i)\n');
for i = 1:30
    fprintf(fid, '%f\n', cone(i));
end
fclose(fid);

%% gerando dados de conexao macro
fid = fopen('dados_conemacro.csv', 'w');
fprintf(fid, 'conemacro(i)\n');
for i = 1:30
    fprintf(fid, '%f\n', conemacro(i));
end
fclose(fid);


%% gerando dados de prejuizo da latencia

% Definindo as constantes alpha e beta
alpha = 0.05; % Exemplo de valor para alpha, ajuste conforme necessário
beta = 15;   % Exemplo de valor para beta, ajuste conforme necessário

% Calculando o índice de prejuízo de latência
Plat = alpha * (Lat - beta);
% Exibindo os valores de prejuízo de latência

fid = fopen('dados_Plat.csv', 'w');
fprintf(fid, 'Plat(i)\n');
for i = 1:30
    fprintf(fid, '%f\n',Plat(i));
end
fclose(fid);



end;

