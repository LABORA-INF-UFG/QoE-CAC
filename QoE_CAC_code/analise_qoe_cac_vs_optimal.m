% Script: analise_cac_vs_optimal.m

figure('Color', [1 1 1], 'Units', 'normalized', 'Position', [0.1 0.1 0.8 0.4]);

%grid off; % Remove as linhas de grade

% Seleciona apenas as colunas 1 (Optimal) e 2 (QoE-CAC)
data_plot = FINAL_NORM(:, 1:2);

b = bar(data_plot, 'grouped', 'EdgeColor', 'none');

% Aplica as cores padronizadas
b(1).FaceColor = cores(1,:); % Azul (Optimal)
b(2).FaceColor = cores(2,:); % Terracota (CAC)

% Configurações de Eixos
grid on;
xlabel('User', 'FontSize', 14);
%ylabel('QoE Normalizada (0 - 1)', 'FontSize', 12);
ylabel('QoE', 'FontSize', 14);
%title('Comparativo de Realismo: Optimal QoE (H.Du) vs. QoE-CAC (Proposta)', 'FontSize', 14);

% Legenda e Estética
legend({'Optimal QoE (H.Du)', 'QoE-CAC'}, ...
       'Location', 'best', 'FontName', 'Arial');

set(gca, 'FontName', 'Arial', 'FontSize', 13);
xlim([0 51]); 
ylim([0 1.1]); % Ajustado para focar no topo das barras


%exportgraphics(gcf, 'graficos_artigo/qoe_final_50_users_eng.pdf', 'ContentType', 'vector');
exportgraphics(gcf, 'graficos_artigo/santr5.pdf', 'ContentType', 'vector');

% --- Adição de Linhas de Referência (Média/Mediana) ---
% %% SE QUISER INCLUIR A LINHA DE MÉDIA DESCOMENTAR ABAIXO
% hold on;
% 
% % 1. Mediana da QoE Optimal (H.Du)
% y_med_opt = median(FINAL_NORM(:,1));
% line([0 51], [y_med_opt y_med_opt], 'Color', cores(1,:), 'LineStyle', '--', ...
%      'LineWidth', 1.5, 'DisplayName', 'Average Optimal QoE'); 
% 
% % 2. Mediana da QoE-CAC (Proposta)
% y_med_cac = median(FINAL_NORM(:,2));
% line([0 51], [y_med_cac y_med_cac], 'Color', cores(2,:), 'LineStyle', '--', ...
%      'LineWidth', 1.5, 'DisplayName', 'Average QoE-CAC'); 
% 
% % --- Atualização da Legenda ---
% legend('Location', 'northeastoutside', 'FontName', 'Times New Roman');
