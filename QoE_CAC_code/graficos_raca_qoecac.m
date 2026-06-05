%% Graficos QoE-CAC RACA - Duas opcoes
% Rodar APOS process_raca_qoecac.m (usa variavel T ja carregada)
% Se T nao estiver na workspace, descomente a linha abaixo:
% T = readtable('raca_qoecac_results.csv');

static_qoe  = T.QoE_CAC(strcmp(T.Scenario,'Static'));
driving_qoe = T.QoE_CAC(strcmp(T.Scenario,'Driving'));
n_s = length(static_qoe);
n_d = length(driving_qoe);
avg_s = mean(static_qoe);
avg_d = mean(driving_qoe);

c_driving = [0.2157 0.4706 0.7490];
c_static  = [0.8902 0.4118 0.1725];

%% ============================================================
%% OPCAO 1: Dois subgraficos separados
%% ============================================================
figure('Units','centimeters','Position',[2 2 18 14]);

% Subplot Static
subplot(2,1,1);
bar(1:n_s, static_qoe, 'FaceColor', c_static, 'EdgeColor','none');
hold on;
plot([0.5 n_s+0.5],[avg_s avg_s],'--','Color',c_static,'LineWidth',1.5);
ylabel('QoE-CAC','FontSize',10,'FontName','Times New Roman');
title(sprintf('Static Scenario  (n=%d,  avg=%.2f)', n_s, avg_s), ...
    'FontSize',11,'FontName','Times New Roman');
ylim([0 1.05]); grid on; box on;
set(gca,'FontName','Times New Roman','FontSize',10, ...
    'XTick',1:n_s,'TickDir','out');

% Subplot Driving
subplot(2,1,2);
bar(1:n_d, driving_qoe, 'FaceColor', c_driving, 'EdgeColor','none');
hold on;
plot([0.5 n_d+0.5],[avg_d avg_d],'--','Color',c_driving,'LineWidth',1.5);
xlabel('Trace','FontSize',10,'FontName','Times New Roman');
ylabel('QoE-CAC','FontSize',10,'FontName','Times New Roman');
title(sprintf('Driving Scenario  (n=%d,  avg=%.2f)', n_d, avg_d), ...
    'FontSize',11,'FontName','Times New Roman');
ylim([0 1.05]); grid on; box on;
set(gca,'FontName','Times New Roman','FontSize',10, ...
    'XTick',5:5:n_d,'TickDir','out');

%print('-dpdf','-r300','qoecac_raca_subplots.pdf');
%print('-dpdf','-r300','santr10.pdf');
if ~exist('graficos_artigo', 'dir'), mkdir('graficos_artigo'); end
exportgraphics(gcf, 'graficos_artigo/santr10.pdf', 'ContentType', 'vector');


