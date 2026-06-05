
%plotando parametros

figure;
i = 1:size(T, 1);

% Separando os dados

% Criando o gráfico

plot(i, Rd, '-o', 'Color', 'b',  'DisplayName', 'R_d(u)');
hold on;
plot(i, Eu, '-x', 'Color', 'r', 'DisplayName', 'E_u(u)');
plot(i, Lat, '-s', 'Color', 'g', 'DisplayName', 'Lat(u)');
% %plot(i, cone, '-d',  'DisplayName', 'cone(u)');


% Personalização do gráfico
xlabel('Usuários');
ylabel('Valor');
title('Valores dos parâmetros de Recursos de Rede');
legend('Location', 'best');
hold off;