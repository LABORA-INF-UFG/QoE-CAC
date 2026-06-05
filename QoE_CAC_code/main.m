clc; clear; close all;

% --- Carga de Dados ---
A1 = readmatrix("gd50.txt");        
A2 = readmatrix("predall50.txt");   
A3 = readmatrix("experiment50.txt") + 1; 
T  = readmatrix("parametros_1.csv");  

% --- Inicialização ---
FINAL = zeros(50, 5); 
Rd = T(:,1)'; Eu = T(:,2)'; Lat = T(:,3)'; 
PthR = 15; 

% --- diretorio de saida dos graficos---
if ~exist('graficos_artigo', 'dir')
    mkdir('graficos_artigo');
end

% --- Loop de Processamento ---
for u = 1:50
    indices = A3(u, A3(u,:) > 0);
    if isempty(indices), continue; end
    uoal = A1(u, indices); uoalpre = A2(u, indices); 
    numO = length(indices); PkR = numO * 20; 

    % Alocação de Potência (Ciente da Atenção)
    uxing = sum(uoalpre) / PkR;
    PnkR = uoalpre ./ uxing;
    
    j = 1; t1 = []; t2 = [];
    while min(PnkR) < PthR && j < numO
        [~, pos] = min(PnkR); t1(j) = pos; t2(j) = uoalpre(pos); 
        uxing = (sum(uoalpre)-sum(t2))/(PkR - PthR*j); PnkR = uoalpre./uxing; 
        for q = 1:j, PnkR(t1(q)) = PthR; end
        j = j + 1;
    end

    % Cálculo da QoE Normalizada por Objeto
    %render_factor = (sum(uoal .* log(PnkR ./ PthR))) / numO;
     render_factor = sum(uoal .* log(PnkR ./ PthR));   

    % Baselines (Lógica Caso A: 1-Valor para penalidades)
    FINAL(u,1) = render_factor;                              % Optimal (H.Du)
    FINAL(u,2) = Rd(u) * (1-Eu(u)) * (1-Lat(u)) * render_factor; % QoE-CAC (Proposta)
    %%% para a analise de ablacao
    FINAL(u,3) =   (1-Eu(u)) * (1-Lat(u))* render_factor;              % QoE-Rd  %retirando o downlink
    FINAL(u,4) =  Rd(u)  * (1-Lat(u))* render_factor;                  % QoE-Eu   %retirando o uplink bep
    FINAL(u,5) =  Rd(u) * (1-Eu(u))  * render_factor;                  % QoE-Lat  % retirando a latencia
end

% Normalização Global para escala 0 a 1
FINAL_NORM = FINAL ./ max(FINAL(:,1));


labels = {'Optimal QoE', 'QoE-CAC', 'QoE-Rd', 'QoE-Eu', 'QoE-Lat'};
%cores = [0 0.447 0.741; 0.85 0.325 0.098; 0.929 0.694 0.125; 0.494 0.184 0.556; 0.466 0.674 0.188];
cores = [0 0.447 0.741; 0.95 0.60 0.20; 0.929 0.694 0.125; 0.494 0.184 0.556; 0.466 0.674 0.188];

 disp('Processamento concluído. Agora você pode rodar os scripts de análise.');
%%%figure 5: santr5.pdf
 disp('Análise QoE-CAC versus QoE Optimal');
 analise_qoe_cac_vs_optimal;

 %%%figure 6: santr6.pdf
 disp('Análise Influência dos fatores');
 analise_parametros;

%%%figure 7 : santr7.pdf
disp('Ablation study');
analise_ablacao;

%%%figure 8 e 9: : santr8.pdf, santr9.pdf
disp('analise MOS');
analise_MOS;

Analise_dataset_RACA

