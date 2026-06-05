%% =========================================================
%  Avaliação Subjetiva QoE-CAC — IEEE Access 2026
%  Lê CSV com respostas MOS e gera gráficos de correlação
%  Autor: gerado automaticamente
%  Data:  2026-05-31
%% =========================================================
clear; clc; close all;

%% --- Configurações ---
csv_file   = 'mos_respostas.csv'; %% este validado
output_dir = 'graficos_artigo';

% Cria diretório de saída se não existir
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%% --- Leitura do CSV ---
T = readtable(csv_file, 'Delimiter', '\t', 'VariableNamingRule', 'preserve');

% Extrai labels dos vídeos (primeira coluna)
labels_raw = T{:,1};
% Renomeia video_user_XX para vid_XX
labels = regexprep(labels_raw, 'video_user_', 'vid_');
labels = regexprep(labels, 'Video_user_', 'vid_');

% Extrai respostas numéricas (colunas 2 até fim)
respostas = T{:, 2:end};  % matriz 9 x 10

%% --- Scores QoE-CAC (ordem deve coincidir com o CSV) ---
qoe_cac = [0.9481; 0.8575; 0.7595; 0.6555; 0.6072; 0.6030; 0.1524; 0.1607; 0.1607];

%% --- Cálculo do MOS, SD e IC 95% ---
N      = size(respostas, 2);          % número de participantes
mos    = mean(respostas, 2);          % média por vídeo
sd     = std(respostas, 0, 2);        % desvio padrão (ddof=1)
se     = sd / sqrt(N);                % erro padrão
t_crit = tinv(0.975, N - 1);         % t crítico bicaudal 95%
ic     = t_crit * se;                 % semi-largura do IC 95%

fprintf('=== MOS por vídeo ===\n');
fprintf('%-16s | QoE-CAC | MOS    | SD     | IC 95% inf | IC 95% sup\n', 'Video');
fprintf('%s\n', repmat('-',1,72));
for i = 1:length(labels)
    fprintf('%-16s | %.4f  | %.4f | %.4f | %.4f     | %.4f\n', ...
        labels{i}, qoe_cac(i), mos(i), sd(i), mos(i)-ic(i), mos(i)+ic(i));
end

%% --- Correlações ---
[r,   p_pearson]  = corr(qoe_cac, mos, 'Type', 'Pearson');
[rho, p_spearman] = corr(qoe_cac, mos, 'Type', 'Spearman');

fprintf('\n=== Correlações ===\n');
fprintf('Pearson  r   = %.4f,  p = %.6f\n', r,   p_pearson);
fprintf('Spearman rho = %.4f,  p = %.6f\n', rho, p_spearman);

%% --- Grupos e cores ---
grupos = [1 1 1 2 2 2 3 3 3];   % 1=Alto, 2=Médio, 3=Baixo
cores  = [0.094 0.373 0.647;     % azul    — Alto
          0.937 0.624 0.153;     % laranja — Médio
          0.886 0.294 0.290];    % vermelho — Baixo

%% --- Gráfico 1: Dispersão QoE-CAC x MOS ---
figure('Units','centimeters','Position',[2 2 10 8]);
hold on;

for g = 1:3
    idx = grupos == g;
    scatter(qoe_cac(idx), mos(idx), 80, cores(g,:), 'filled', ...
        'MarkerEdgeColor', cores(g,:)*0.7);
end

% Linha de tendência
p_fit  = polyfit(qoe_cac, mos, 1);
x_line = linspace(0, 1, 100);
plot(x_line, polyval(p_fit, x_line), 'k--', 'LineWidth', 1);

% Anotações
% text(0.05, 4.6, sprintf('r = %.4f',     r),          'FontSize', 9);
% text(0.05, 4.3, sprintf('p = %.4f',     p_pearson),  'FontSize', 9);
% text(0.05, 4.0, sprintf('\\rho = %.4f', rho),        'FontSize', 9);

xlabel('QoE-CAC', 'FontSize', 10);
ylabel('MOS',     'FontSize', 10);
xlim([0 1.05]); ylim([1 5]);
legend({'High (>0.7)','Medium (0.45–0.65)','Low (<0.25)'}, ...
    'Location','northwest', 'FontSize', 8);
box on; grid on;
set(gca, 'FontSize', 9);

exportgraphics(gcf, fullfile(output_dir, 'santr8.pdf'), ...
'ContentType','vector');

%santr8.pdf = figure8 = grafico_dispersao_MOS

%% --- Gráfico 2: Barras duplas QoE-CAC vs MOS com IC 95% ---
x = 1:length(labels);

figure('Units','centimeters','Position',[2 2 14 7]);

yyaxis left;
b1 = bar(x - 0.2, mos, 0.35, 'FaceColor', [0.937 0.624 0.153]);
hold on;
% Error bars IC 95% — apenas no eixo MOS (yyaxis left)
errorbar(x - 0.2, mos, ic, ...
    'k.', 'LineWidth', 1, 'CapSize', 4);
ylabel('MOS (1–5)', 'FontSize', 10);
ylim([0 5]);

yyaxis right;
b2 = bar(x + 0.2, qoe_cac, 0.35, 'FaceColor', [0.094 0.373 0.647]);
ylabel('QoE-CAC (0–1)', 'FontSize', 10);
ylim([0 1]);

set(gca, 'XTick', x, 'XTickLabel', labels, 'FontSize', 9);
legend([b1 b2], {'MOS','QoE-CAC'}, 'Location','northeast', 'FontSize', 8);
box on; grid on;

exportgraphics(gcf, fullfile(output_dir, 'santr9.pdf'), ...
    'ContentType','vector');

%santr9.pdf = figure9 = grafico_barra_MOS
fprintf('\nGráficos salvos em: %s\n', output_dir);
