% Pulizia workspace
clc; clear; close all;

% --- DEFINIZIONE DATI ---
% Vettore temporale simulazione (0 a 86400 secondi)
t_sim = linspace(0, 86400, 4000);

% 1. CUCINA
y_cucina = [0, 0.1, 0.7, 0.5, 0, 0.3, 0.9, 0.7, 0.05, 0.4, 0.95, 0.8, 0, 0];
x_cucina = [0, 24000, 25200, 27000, 28800, 41500, 43200, 47000, 48600, 65000, 68400, 73000, 73800, 86400];

% 2. SALOTTO
y_salotto = [0, 0, 0.1, 0.1, 0.4, 0.5, 0.2, 0.9, 0.95, 0.5, 0];
x_salotto = [0, 25000, 32000, 45000, 54000, 64000, 68000, 72000, 81000, 84000, 86400];

% 3. BAGNO (Due curve distinte)
% Caso A: Picchi specifici
y_bagno1 = [0, 0, 0.95, 0.95, 0, 0, 0.95, 0.95, 0, 0];
x_bagno1 = [0, 25140, 25200, 26400, 26460, 75540, 75600, 76800, 76860, 86400];
% Caso B: Routine generale
y_bagno2 = [0, 0, 0.8, 0.4, 0.5, 0.2, 0.6, 0.8, 0];
x_bagno2 = [0, 21600, 25200, 28800, 43200, 50400, 64800, 79200, 86400];

% 4. CAMERA
y_camera = [1, 1, 0.8, 0.5, 0.1, 0.05, 0.05, 0.2, 0.7, 0.95, 1];
x_camera = [0, 23400, 25200, 27000, 30600, 43200, 64800, 75600, 79200, 82800, 86400];

% 5. CORRIDOIO
y_corridoio = [0, 0, 0.6, 0.4, 0.5, 0.2, 0.6, 0.7, 0.3, 0];
x_corridoio = [0, 21600, 25200, 28800, 43200, 50400, 64800, 72000, 79200, 86400];

% --- CONFIGURAZIONE GRAFICA ---
figure('Color', 'w', 'Position', [100, 50, 800, 1000]);

c_blue   = [0.1216, 0.4667, 0.7059];
c_orange = [1.0000, 0.4980, 0.0549];
c_green  = [0.1725, 0.6275, 0.1725];
c_red    = [0.8392, 0.1529, 0.1569];
c_purple = [0.5804, 0.4039, 0.7412];

% Array di strutture (Ho rimosso la seconda riga del bagno qui per gestirla nel loop)
rooms = {
    'Kitchen',     x_cucina,    y_cucina,    c_blue;
    'Living Room', x_salotto,   y_salotto,   c_orange;
    'Bathroom',    x_bagno1,    y_bagno1,    c_green;   % Metto qui il dataset principale
    'Bedroom',     x_camera,    y_camera,    c_red;
    'Hallway',     x_corridoio, y_corridoio, c_purple
};

% Loop per generare i 5 subplot (Stanze Fisiche)
for i = 1:5
    subplot(5, 1, i);
    hold on;
    
    title_str = "Probability " + rooms{i, 1};
    x_data = rooms{i, 2};
    y_data = rooms{i, 3};
    color_val = rooms{i, 4};
    
    % --- PLOT PRINCIPALE ---
    p_trend = interp1(x_data, y_data, t_sim, 'linear');
    
    % Area riempita
    fill([t_sim, fliplr(t_sim)], [p_trend, zeros(size(p_trend))], ...
         color_val, 'FaceAlpha', 0.1, 'EdgeColor', 'none');
    
    % Linea
    h1 = plot(t_sim, p_trend, 'Color', color_val, 'LineWidth', 2.5);
    
    % --- GESTIONE SPECIALE PER IL BAGNO (Index 3) ---
    if i == 3
        % Calcolo la seconda curva (Routine generale)
        p_trend2 = interp1(x_bagno2, y_bagno2, t_sim, 'linear');
        
        % La disegno con una linea diversa (tratteggiata) o un'area leggermente diversa
        % Non uso fill per non appesantire troppo, o uso un fill molto leggero
        fill([t_sim, fliplr(t_sim)], [p_trend2, zeros(size(p_trend2))], ...
             color_val, 'FaceAlpha', 0.05, 'EdgeColor', 'none');
         
        h2 = plot(t_sim, p_trend2, '--', 'Color', [0.1, 0.4, 0.1], 'LineWidth', 2); % Verde più scuro, tratteggiato
        
        % Aggiungo legenda specifica solo per il bagno
        legend([h1, h2], {'Only Shower', 'Presence'}, ...
               'Location', 'northeast', 'FontSize', 8);
        ylim([-0.05 1.1]); % Tengo fisso a 1.1 anche se la somma sarebbe >1
    end

    % Formattazione Assi
    title(title_str, 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Prob.', 'FontSize', 10);
    
    % Limiti standard per le altre stanze
    if i ~= 3
        ylim([-0.05 1.1]);
    end
    xlim([0 86400]);
    
    grid on;
    ax = gca;
    ax.GridLineStyle = '--';
    ax.GridAlpha = 0.7;
    
    xticks(0:14400:86400);
    xticklabels({'0h', '4h', '8h', '12h', '16h', '20h', '24h'});
    
    if i < 5
        xticklabels({});
    else
        xlabel('Time [s]', 'FontSize', 12);
    end
end