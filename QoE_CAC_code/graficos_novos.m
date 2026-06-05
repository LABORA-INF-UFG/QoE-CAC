% criar_boxplot.m
% =========================================

clear; clc;

% Dados de exemplo (substitua pelos seus dados reais)
static_qoe = [18.2, 19.5, 17.8, 20.1, 18.9, 19.3, 18.5, 19.8, ...
              18.7, 19.1, 18.4, 19.6, 18.8, 19.4, 18.6, 19.2, ...
              18.3, 19.7, 18.9, 19.0];

driving_qoe = [12.1, 13.4, 11.8, 14.2, 10.5, 9.8, 13.1, 12.7, ...
               11.3, 13.8, 12.4, 11.9, 13.5, 5.2, 12.9, 11.7, ...
               13.2, 12.6, 11.4, 13.0];

% Criar box plot
figure('Position', [100, 100, 600, 500]);

boxplot([static_qoe, driving_qoe], ...
        [ones(1, length(static_qoe)), 2*ones(1, length(driving_qoe))], ...
        'Labels', {'Static', 'Driving'}, ...
        'Colors', [0.2 0.6 0.8; 0.8 0.4 0.2], ...
        'Widths', 0.5);

% Personalizar
ylabel('QoE-CAC', 'FontSize', 14);
title('QoE-CAC Distribution: Static vs Driving', 'FontSize', 16);
grid on;
set(gca, 'FontSize', 12);

% Salvar
saveas(gcf, 'boxplot_static_vs_driving.png');
saveas(gcf, 'boxplot_static_vs_driving.pdf');

fprintf('✅ Gráfico salvo!\n');

% Mostrar estatísticas
fprintf('\nEstatísticas:\n');
fprintf('Static:  Mediana = %.2f, IQR = %.2f\n', ...
        median(static_qoe), iqr(static_qoe));
fprintf('Driving: Mediana = %.2f, IQR = %.2f\n', ...
        median(driving_qoe), iqr(driving_qoe));