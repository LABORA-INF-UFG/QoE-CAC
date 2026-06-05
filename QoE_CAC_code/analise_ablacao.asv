% Script: ablation_study.m
% Rodar após main.m (precisa de FINAL_NORM e cores)
figure('Color', [1 1 1], 'Units', 'centimeters', 'Position', [2 2 24 8]);

%% Painel 1 — Comparação das variantes por usuário
subplot(1,3,1);
plot(1:50, FINAL_NORM(:,2), '-', 'Color', cores(1,:), 'LineWidth', 1.5, 'DisplayName', 'QoE-CAC (Full)');
hold on;
plot(1:50, FINAL_NORM(:,3), '--', 'Color', cores(2,:), 'LineWidth', 1.2, 'DisplayName', 'Without Downlink');
plot(1:50, FINAL_NORM(:,4), '--', 'Color', cores(3,:), 'LineWidth', 1.2, 'DisplayName', 'Without Uplink BEP');
plot(1:50, FINAL_NORM(:,5), '--', 'Color', cores(4,:), 'LineWidth', 1.2, 'DisplayName', 'Without Latency');
grid on;
xlim([0 51]);
set(gca, 'XTick', 0:10:50, 'FontName', 'Arial', 'FontSize', 10);
ylim([0.1 1.1]);
xlabel('User', 'FontSize', 9, 'FontName', 'Arial');
ylabel('QoE', 'FontSize', 9, 'FontName', 'Arial');
legend('Location', 'northwest', 'FontSize', 7, 'FontName', 'Arial');
set(gca, 'FontName', 'Arial', 'FontSize', 10);
%% Painel 2 — Boxplot das distribuições
subplot(1,3,2);
boxplot(FINAL_NORM(:,2:5), ...
'Labels', {'Full', 'W/o Downlink', 'W/o Uplink BEP', 'W/o Latency'}, ...
'Colors', cores(1:4,:));
grid on;
ylabel('QoE', 'FontSize', 9, 'FontName', 'Arial');
set(gca, 'FontName', 'Arial', 'FontSize', 10, ...
    'XTickLabelRotation', 15);
%% Painel 3 — Degradação média por fator removido
subplot(1,3,3);
deg_downlink = mean((FINAL_NORM(:,3) - FINAL_NORM(:,2)) ./ FINAL_NORM(:,2)) * 100;
deg_bep      = mean((FINAL_NORM(:,4) - FINAL_NORM(:,2)) ./ FINAL_NORM(:,2)) * 100;
deg_lat      = mean((FINAL_NORM(:,5) - FINAL_NORM(:,2)) ./ FINAL_NORM(:,2)) * 100;
degradacoes = [deg_downlink, deg_bep, deg_lat];
bar_labels  = {'W/o Downlink', 'W/o Uplink BEP', 'W/o Latency'};
b = bar(degradacoes, 'FaceColor', cores(2,:), 'EdgeColor', 'none');
set(gca, 'XTick', 1:3, 'XTickLabel', bar_labels, ...
    'XTickLabelRotation', 15, ...
    'FontName', 'Arial', 'FontSize', 9);
ylabel('Average QoE Change (%)', 'FontSize', 9, 'FontName', 'Arial');
grid on;
for i = 1:3
    text(i, degradacoes(i) + 0.5, sprintf('%.1f%%', degradacoes(i)), ...
'HorizontalAlignment', 'center', 'FontSize', 10, ...
'FontName', 'Arial', 'FontWeight', 'bold');
end
%% Exportar
exportgraphics(gcf, 'graficos_artigo/santr7.pdf', 'ContentType', 'vector');
%santr7.pdf = figure7 = ablation_study
disp('Ablation study figure saved!');