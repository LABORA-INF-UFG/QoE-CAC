%% CONFIGURAÇÕES
images_dir = 'd:\uoal\images';   % pasta com todas as imagens
output_dir = 'd:\uoal\videos';   % pasta de saída dos vídeos
fps        = 60;                  % frames por segundo
resolution = '3840x2160';        % resolução 4K
crf        = 25;                  % qualidade (menor = melhor)

% Tabela: usuário → ObjectIDs (em ordem)
users = {
    1, [66, 35, 11, 10,  1, 12,  2, 14,  3, 16, 29];
    2, [ 0, 35,  1,  3, 10, 11,  5, 68,  8, 19, 64];
    3, [ 2, 35, 11, 18, 10,  8,  5, 72, 64, 29    ];
    4, [ 3,  5, 37, 30, 82, 54, 88, 90             ];
    5, [ 2, 35, 11, 18, 10,  8, 15, 23             ];
};

%% CRIA PASTA DE SAÍDA
if ~exist(output_dir, 'dir')
    mkdir(output_dir);
end

%% GERA OS VÍDEOS
for i = 1:size(users, 1)
    user_id    = users{i, 1};
    object_ids = users{i, 2};

    fprintf('\n==================================================\n');
    fprintf('  Gerando vídeo para Usuário %d\n', user_id);
    fprintf('  ObjectIDs: %s\n', num2str(object_ids));
    fprintf('==================================================\n');

    % Pasta temporária para frames renumerados
    tmp_dir = fullfile(tempdir, sprintf('user%d_frames', user_id));
    if exist(tmp_dir, 'dir')
        rmdir(tmp_dir, 's');
    end
    mkdir(tmp_dir);

    % Copia e renumera os frames em sequência
    frame_index = 1;
    missing     = [];

    for j = 1:length(object_ids)
        obj_id = object_ids(j);
        src    = fullfile(images_dir, sprintf('%d.jpg', obj_id));

        if ~isfile(src)
            fprintf('  [AVISO] Imagem não encontrada: %s\n', src);
            missing(end+1) = obj_id; %#ok<AGROW>
            continue;
        end

        dst = fullfile(tmp_dir, sprintf('%06d.jpg', frame_index));
        copyfile(src, dst);
        fprintf('  [%03d] %d.jpg -> %s\n', frame_index, obj_id, sprintf('%06d.jpg', frame_index));
        frame_index = frame_index + 1;
    end

    if frame_index == 1
        fprintf('  [ERRO] Nenhuma imagem encontrada para usuário %d. Pulando.\n', user_id);
        rmdir(tmp_dir, 's');
        continue;
    end

    if ~isempty(missing)
        fprintf('  [AVISO] ObjectIDs ausentes: %s\n', num2str(missing));
    end

    % Saída do vídeo
    output_video = fullfile(output_dir, sprintf('video_user%d.mp4', user_id));

    % Monta e executa o comando FFmpeg
    input_pattern = fullfile(tmp_dir, '%06d.jpg');
    cmd = sprintf('ffmpeg -y -r %d -f image2 -s %s -i "%s" -vcodec libx264 -crf %d -pix_fmt yuv420p "%s"', ...
        fps, resolution, input_pattern, crf, output_video);

    fprintf('\n  Executando FFmpeg...\n');
    fprintf('  Comando: %s\n\n', cmd);

    status = system(cmd);

    if status == 0
        info   = dir(output_video);
        size_mb = info.bytes / (1024 * 1024);
        fprintf('  OK  Vídeo gerado: %s (%.2f MB)\n', output_video, size_mb);
    else
        fprintf('  ERRO no FFmpeg para usuário %d\n', user_id);
    end

    % Remove pasta temporária
    rmdir(tmp_dir, 's');
end

fprintf('\n==================================================\n');
fprintf('  Concluído!\n');
fprintf('==================================================\n');