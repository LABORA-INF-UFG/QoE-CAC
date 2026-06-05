% Script: analise_barras.m
figure('Color', [1 1 1], 'Position', [100 100 1000 400]);
b = bar(FINAL_NORM, 'grouped');
for i=1:5, b(i).FaceColor = cores(i,:); end
grid on; xlabel('ID do Usuário'); ylabel('QoE Normalizada');
title('Comparativo de Baselines por Usuário (Normalizado por Objeto)');
legend(labels, 'Location', 'northeastoutside');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 11);
xlim([0 51]); ylim([0 1.2]);

