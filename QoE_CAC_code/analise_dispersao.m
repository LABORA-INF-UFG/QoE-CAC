% Script: analise_dispersao.m
figure('Color', [1 1 1], 'Name', 'Dispersão');
scatter(FINAL_NORM(:,1), FINAL_NORM(:,2), 80, 'filled', 'MarkerFaceAlpha', 0.5);
hold on; plot([0 1], [0 1], '--k', 'LineWidth', 1.5);
xlabel('QoE Optimal (Sem Rede)'); ylabel('QoE-CAC (Rede Real)');
title('Degradação da Experiência: Potencial vs Realidade');
grid on; legend('Usuários Reais', 'Cenário Ideal', 'Location', 'northwest');
set(gca, 'FontName', 'Times New Roman', 'FontSize', 12);
