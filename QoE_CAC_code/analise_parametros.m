
% Script para plotar os parâmetros de rede de cada um dos 50 usuários
% Certifique-se de rodar o código principal antes de executar este script.
if ~exist('T', 'var')
    error('Os dados dos parâmetros não foram encontrados. Rode o script principal primeiro.');
end

% Configurações de Estilo
usuarios = 1:50;
cor_param = [0.2 0.6 0.8; 0.8 0.2 0.2; 0.2 0.8 0.2];

figure('Name', 'Análise de Parâmetros por Usuário', 'NumberTitle', 'off', 'Color', 'w');

% --- Subplot 1: Rd (Taxa de Dados) ---
subplot(3,1,1);
bar(usuarios, Rd, 'FaceColor', cor_param(1,:), 'EdgeColor', 'none');
ylabel('Rd', 'FontSize', 12);
grid on;
xlim([0 51]);
set(gca, 'FontName', 'Arial', 'FontSize', 10);

% --- Subplot 2: Eu (Taxa de Erro) ---
subplot(3,1,2);
bar(usuarios, Eu, 'FaceColor', cor_param(2,:), 'EdgeColor', 'none');
ylabel('Eu', 'FontSize', 12);
grid on;
xlim([0 51]);
set(gca, 'FontName', 'Arial', 'FontSize', 10);

% --- Subplot 3: Lat (Latência) ---
subplot(3,1,3);
bar(usuarios, Lat, 'FaceColor', cor_param(3,:), 'EdgeColor', 'none');
xlabel('User', 'FontSize', 10);
ylabel('Lat', 'FontSize', 10);
grid on;
xlim([0 51]);
set(gca, 'FontName', 'Arial', 'FontSize', 10);

% Exportar em alta resolução
%exportgraphics(gcf, 'graficos_artigo/parametros_barra.pdf', 'ContentType', 'vector');
exportgraphics(gcf, 'graficos_artigo/santr6.pdf', 'ContentType', 'vector');