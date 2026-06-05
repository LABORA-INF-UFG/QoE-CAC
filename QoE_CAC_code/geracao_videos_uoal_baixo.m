%% CONFIGURAÇÕES — QUALIDADE BAIXA
images_dir = 'd:\uoal\images';       % pasta com todas as imagens
output_dir = 'd:\uoal\videos_poor';  % pasta de saída dos vídeos
fps        = 8;                       % FPS muito baixo (era 15)
resolution = '640x360';              % resolução baixa (era 1280x720)
crf        = 51;                      % pior qualidade possível do H.264 (era 45)

% Tabela: usuário → ObjectIDs (em ordem)
users = {
    1, [42, 17, 83,  5, 61, 29, 74, 38, 13, 55, 90];
    2, [22, 47,  9, 68, 31, 85, 14, 53, 77,  3, 40];
    3, [58, 26, 71, 44,  8, 93, 19, 62, 35, 80    ];
    4, [11, 49, 87, 23, 66, 34, 78, 51             ];
    5, [37, 72, 16, 88, 43,  6, 59, 25             ];
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
    tmp_dir = fullfile(tempdir, sprintf('user%d_frames_poor', user_id));
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

        for rep = 1:fps
            dst = fullfile(tmp_dir, sprintf('%06d.jpg', frame_index));
            copyfile(src, dst);
            frame_index = frame_index + 1;
        end
        fprintf('  %d.jpg -> %d frames (1 segundo)\n', obj_id, fps);
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
        info    = dir(output_video);
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