%% QoE-CAC com Dataset RACA - 
% Santos et al. - IEEE Access
% Correcoes:
%   - Bounds de DL ajustados para valores reais do RACA
%   - BEP_max ajustado para cobrir range real do SNR
%   - Latencia: usar CQI como indicador de qualidade quando PING indisponivel

clc; clear; close all;

%% ============================================================
%% PARTE 1: Calcular fator de renderizacao medio (UOAL)
%% ============================================================
fprintf('=== PARTE 1: Fator de renderizacao medio (UOAL) ===\n');

A1 = readmatrix("gd50.txt");
A2 = readmatrix("predall50.txt");
A3 = readmatrix("experiment50.txt");

PthR = 15;
render_factors = zeros(50, 1);

for u = 1:50
    row     = A3(u, :);
    indices = row(row > 0);
    indices = indices(indices <= size(A1, 2));
    if isempty(indices), continue; end

    uoal    = A1(u, indices);
    uoalpre = A2(u, indices);
    numO    = length(indices);
    PkR     = numO * 20;

    uxing = sum(uoalpre) / PkR;
    PnkR  = uoalpre ./ uxing;

    j = 1; t1 = []; t2 = [];
    while min(PnkR) < PthR && j < numO
        [~, pos] = min(PnkR);
        t1(j) = pos; t2(j) = uoalpre(pos);
        uxing = (sum(uoalpre) - sum(t2)) / (PkR - PthR * j);
        PnkR  = uoalpre ./ uxing;
        for q = 1:j, PnkR(t1(q)) = PthR; end
        j = j + 1;
    end
    render_factors(u) = sum(uoal .* log(PnkR ./ PthR));
end

avg_render = mean(render_factors(render_factors > 0));
fprintf('Fator de renderizacao medio: %.4f\n', avg_render);
fprintf('Usuarios processados: %d\n\n', sum(render_factors > 0));

%% ============================================================
%% PARTE 2: Configuracao dos bounds (ajustados para RACA)
%% ============================================================

% Bounds ajustados para valores reais do dataset RACA
% (baseados na analise dos dados: DL varia de ~0.5 a ~130 Mbps)
DL_min  = 0.5;    % Mbit/s — minimo real do RACA
DL_max  = 130.0;  % Mbit/s — maximo real do RACA

% Latencia: PINGAVG indisponivel na maioria dos traces
% Usar valores tipicos reportados no paper RACA:
% Static avg = 75ms, Driving avg = 90ms
Lat_min = 10;     % ms
Lat_max = 200;    % ms

% BEP: SNR medio = 6.16 dB => BEP ~ 4.6e-2
% Ajustar range para cobrir valores reais
BEP_min = 1e-8;
BEP_max = 0.5;    % aumentado para cobrir BEP real do RACA

% Constantes de impairment de latencia
a_lat = 0.5;
b_lat = 5;

%% ============================================================
%% PARTE 3: Processar Dataset RACA
%% ============================================================
fprintf('=== PARTE 2: Processando Dataset RACA ===\n');

root_path = './5Gdataset';
all_csvs  = dir(fullfile(root_path, '**', '*.csv'));
fprintf('Total de arquivos CSV: %d\n\n', length(all_csvs));

col_names = {'Timestamp','Longitude','Latitude','Speed','Operatorname',...
             'CellID','NetworkMode','RSRP','RSRQ','SNR','CQI','RSSI',...
             'DL_bitrate','UL_bitrate','State','PINGAVG','PINGMIN',...
             'PINGMAX','PINGSTDEV','PINGLOSS','CELLHEX','NODEHEX',...
             'LACHEX','RAWCELLID','NRxRSRP','NRxRSRQ'};

results         = [];
categories_list = {};
scenarios_list  = {};
filenames_list  = {};
user_id = 0;

for f = 1:length(all_csvs)

    filepath   = fullfile(all_csvs(f).folder, all_csvs(f).name);
    path_parts = strsplit(all_csvs(f).folder, filesep);

    category = ''; scenario = '';
    for p = 1:length(path_parts)
        if any(strcmp(path_parts{p}, {'Amazon_Prime','Netflix','Download'}))
            category = path_parts{p};
        end
        if any(strcmp(path_parts{p}, {'Static','Driving'}))
            scenario = path_parts{p};
        end
    end
    %if isempty(category) || isempty(scenario), continue; end
    %teste atual
    if isempty(category) || isempty(scenario), continue; end
    if ~strcmp(category, 'Download'), continue; end
    try
        opts = detectImportOptions(filepath, 'Delimiter', ',', ...
            'VariableNamesLine', 1, 'VariableNamingRule', 'preserve');
        data = readtable(filepath, opts);

        if width(data) == length(col_names)
            data.Properties.VariableNames = col_names;
        end

        % Filtrar linhas ativas
        if ismember('State', data.Properties.VariableNames)
            sc = data.State;
            if iscell(sc)
                data = data(strcmp(sc,'D'), :);
            else
                data = data(sc == 'D', :);
            end
        end
        if height(data) == 0, continue; end

        %% --- DL (kbps -> Mbit/s) ---
        dl_raw = extract_num(data, 'DL_bitrate');
        dl_raw(dl_raw <= 0) = NaN;
        DL_mbps = nanmean(dl_raw) / 1000;
        if isnan(DL_mbps) || DL_mbps <= 0, continue; end

        %% --- Latencia ---
        % PINGAVG e '-' na maioria dos traces — usar valores do paper RACA
        lat_raw = extract_num(data, 'PINGAVG');
        lat_raw(lat_raw <= 0) = NaN;
        Lat_ms = nanmean(lat_raw);

        if isnan(Lat_ms)
            % Valores medios reportados em Raca et al. 2020
            if strcmp(scenario, 'Static')
                Lat_ms = 75;   % avg static
            else
                Lat_ms = 90;   % avg driving
            end
        end

        %% --- BEP via SNR (QPSK) ---
        snr_raw = extract_num(data, 'SNR');
        snr_raw(isnan(snr_raw)) = [];

        if ~isempty(snr_raw)
            snr_lin = 10.^(snr_raw / 10);
            BEP = mean(qfunc(sqrt(2 * snr_lin)));
            % Clamp ao range definido
            BEP = max(BEP_min, min(BEP_max, BEP));
        else
            % Fallback: usar CQI medio para estimar qualidade
            cqi_raw = extract_num(data, 'CQI');
            cqi_raw(isnan(cqi_raw)) = [];
            if ~isempty(cqi_raw)
                % CQI 0-15: mapear para BEP inversamente
                cqi_mean = mean(cqi_raw);
                % CQI=15 -> BEP~1e-6; CQI=0 -> BEP~0.5
                BEP = 0.5 * exp(-0.8 * cqi_mean);
                BEP = max(BEP_min, min(BEP_max, BEP));
            else
                BEP = 1e-3; % fallback generico
            end
        end

        %% --- Normalizar KPIs ---
        tau_DL  = max(0, min(1, (DL_mbps - DL_min)  / (DL_max  - DL_min)));
        tau_Lat = max(0, min(1, (Lat_ms  - Lat_min)  / (Lat_max - Lat_min)));
        tau_BEP = max(0, min(1, (BEP     - BEP_min)  / (BEP_max - BEP_min)));

        %% --- Impairment de Latencia ---
        t_norm = Lat_ms / 1000;
        I_Lat  = (1 + exp(-b_lat)) / (1 + exp(b_lat * (t_norm - a_lat) / a_lat));

        %% --- QoE-CAC ---
        QoE_CAC = (1 - tau_Lat) * tau_DL * (1 - tau_BEP) * avg_render;
        QoE_CAC = max(0, QoE_CAC);  % sem clampar o maximo ainda

        %% Armazenar
        user_id = user_id + 1;
        results(end+1,:) = [user_id, DL_mbps, Lat_ms, BEP, ...
                            tau_DL, tau_Lat, tau_BEP, I_Lat, QoE_CAC]; %#ok<AGROW>
        categories_list{end+1} = category; %#ok<AGROW>
        scenarios_list{end+1}  = scenario; %#ok<AGROW>
        filenames_list{end+1}  = all_csvs(f).name; %#ok<AGROW>

        fprintf('[%02d] %-14s | %-8s | DL=%7.2f Mbps | Lat=%5.1f ms | BEP=%.2e | QoE-CAC=%.4f\n', ...
            user_id, category, scenario, DL_mbps, Lat_ms, BEP, QoE_CAC);

    catch e
        fprintf('ERRO em %s: %s\n', all_csvs(f).name, e.message);
    end
end

if user_id == 0
    fprintf('Nenhum trace processado!\n'); return;
end

%% ============================================================
%% PARTE 4: Normalizar globalmente e salvar
%% ============================================================
max_qoe = max(results(:,9));
fprintf('\nQoE-CAC maximo bruto: %.4f\n', max_qoe);

if max_qoe > 0
    results(:,9) = results(:,9) / max_qoe;
end

T = table((1:user_id)', categories_list', scenarios_list', filenames_list', ...
    results(:,2), results(:,3), results(:,4), ...
    results(:,5), results(:,6), results(:,7), ...
    results(:,8), results(:,9), ...
    'VariableNames', {'UserID','Category','Scenario','Filename', ...
                      'DL_Mbps','Lat_ms','BEP', ...
                      'tau_DL','tau_Lat','tau_BEP', ...
                      'I_Lat','QoE_CAC'});

writetable(T, 'raca_qoecac_results.csv');
fprintf('CSV salvo: raca_qoecac_results.csv\n');
fprintf('Total traces: %d\n', user_id);


%% Remover outlier (criterio IQR)
Q1_all  = quantile(T.QoE_CAC, 0.25);
Q3_all  = quantile(T.QoE_CAC, 0.75);
IQR_all = Q3_all - Q1_all;
upper   = Q3_all + 1.5 * IQR_all;

n_antes = height(T);
T = T(T.QoE_CAC <= upper, :);
fprintf('Outliers removidos: %d (limite=%.4f)\n', n_antes - height(T), upper);

% Renumerar UserID
T.UserID = (1:height(T))';


% ============================================================
% PARTE 5: Resumo e Grafico
% ============================================================
fprintf('\n--- Resumo por Cenario ---\n');
for s = {'Static','Driving'}
    idx = strcmp(T.Scenario, s{1});
    if any(idx)
        fprintf('%s: n=%d | QoE-CAC medio=%.4f | DL medio=%.2f Mbps | Lat=%.1f ms | BEP medio=%.2e\n', ...
            s{1}, sum(idx), mean(T.QoE_CAC(idx)), ...
            mean(T.DL_Mbps(idx)), mean(T.Lat_ms(idx)), mean(T.BEP(idx)));
    end
end

fprintf('\n--- Resumo por Categoria ---\n');
for c = {'Amazon_Prime','Netflix','Download'}
    idx = strcmp(T.Category, c{1});
    if any(idx)
        fprintf('%s: n=%d | QoE-CAC medio=%.4f | DL medio=%.2f Mbps\n', ...
            c{1}, sum(idx), mean(T.QoE_CAC(idx)), mean(T.DL_Mbps(idx)));
    end
end


% PARTE  Grafico

graficos_raca_qoecac()

%% Helper
function vals = extract_num(data, col_name)
    if ~ismember(col_name, data.Properties.VariableNames)
        vals = NaN(height(data),1); return;
    end
    raw = data.(col_name);
    if iscell(raw)
        vals = cellfun(@(x) str2double(x), raw, 'UniformOutput', true);
    elseif isnumeric(raw)
        vals = double(raw);
    else
        vals = double(raw);
    end
end
