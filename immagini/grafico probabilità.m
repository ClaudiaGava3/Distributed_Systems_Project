% Pulizia workspace
clc; clear; close all;

% --- DEFINIZIONE DATI ---

% Vettore temporale simulazione (0 a 86400 secondi)
t_sim = linspace(0, 86400, 4000);

% 1. CUCINA (14 punti)
y_cucina = [0, 0.1, 0.7, 0.5, 0, 0.3, 0.9, 0.7, 0.05, 0.4, 0.95, 0.8, 0, 0];
x_cucina = [0, 24000, 25200, 27000, 28800, 41500, 43200, 47000, 48600, 65000, 68400, 73000, 73800, 86400];

% 2. SALOTTO (11 punti)
y_salotto = [0, 0, 0.1, 0.1, 0.4, 0.5, 0.2, 0.9, 0.95, 0.5, 0];
x_salotto = [0, 25000, 32000, 45000, 54000, 64000, 68000, 72000, 81000, 84000, 86400];

% 3. BAGNO (10 punti)
y_bagno = [0, 0, 0.95, 0.95, 0, 0, 0.95, 0.95, 0, 0];
x_bagno = [0, 25140, 25200, 26400, 26460, 75540, 75600, 76800, 76860, 86400];

% 4. CAMERA (11 punti)
y_camera = [1, 1, 0.8, 0.5, 0.1, 0.05, 0.05, 0.2, 0.7, 0.95, 1];
x_camera = [0, 23400, 25200, 27000, 30600, 43200, 64800, 75600, 79200, 82800, 86400];

% 5. CORRIDOIO (10 punti)
y_corridoio = [0, 0, 0.6, 0.4, 0.5, 0.2, 0.6, 0.7, 0.3, 0];
x_corridoio = [0, 21600, 25200, 28800, 43200, 50400, 64800, 72000, 79200, 86400];

% --- CONFIGURAZIONE GRAFICA ---

% Creazione della figura
figure('Color', 'w', 'Position', [100, 50, 800, 1000]);

% Colori (RGB Normalizzati simile a Python Matplotlib)
c_blue   = [0.1216, 0.4667, 0.7059];
c_orange = [1.0000, 0.4980, 0.0549];
c_green  = [0.1725, 0.6275, 0.1725];
c_red    = [0.8392, 0.1529, 0.1569];
c_purple = [0.5804, 0.4039, 0.7412];

% Array di strutture per ciclare
rooms = {
    'Probability Kitchen',     x_cucina,    y_cucina,    c_blue;
    'Probability Living Room', x_salotto,   y_salotto,   c_orange;
    'Probability Bathroom',    x_bagno,     y_bagno,     c_green;
    'Probability Bedroom',     x_camera,    y_camera,    c_red;
    'Probability Hallway',     x_corridoio, y_corridoio, c_purple
};

% Loop per generare i 5 subplot
for i = 1:5
    % Seleziona subplot
    subplot(5, 1, i);
    hold on;
    
    % Estrai dati
    title_str = rooms{i, 1};
    x_data = rooms{i, 2};
    y_data = rooms{i, 3};
    color_val = rooms{i, 4};
    
    % Interpolazione Lineare (Simula Lookup Table)
    p_trend = interp1(x_data, y_data, t_sim, 'linear');
    
    % 1. Disegna l'area riempita (trasparente)
    % Per fill() dobbiamo creare un poligono chiuso
    x_fill = [t_sim, fliplr(t_sim)];
    y_fill = [p_trend, zeros(size(p_trend))];
    fill_obj = fill(x_fill, y_fill, color_val);
    set(fill_obj, 'FaceAlpha', 0.1, 'EdgeColor', 'none'); % Trasparenza 10%
    
    % 2. Disegna la linea solida sopra
    plot(t_sim, p_trend, 'Color', color_val, 'LineWidth', 2.5);
    
    % Formattazione Assi
    title(title_str, 'FontSize', 12, 'FontWeight', 'bold');
    ylabel('Probability', 'FontSize', 10);
    ylim([-0.05 1.1]);
    xlim([0 86400]);
    
    % Griglia tratteggiata
    grid on;
    ax = gca;
    ax.GridLineStyle = '--';
    ax.GridAlpha = 0.7;
    
    % Imposta i tick dell'asse X ogni 4 ore (14400 secondi)
    xticks(0:14400:86400);
    % Etichette in ore (0h, 4h, etc.)
    xticklabels({'0h', '4h', '8h', '12h', '16h', '20h', '24h'});
    
    % Rimuovi etichette X per tutti tranne l'ultimo grafico
    if i < 5
        xticklabels({});
    else
        xlabel('Times [s]', 'FontSize', 12);
    end
end

% Salva l'immagine (opzionale)
% saveas(gcf, 'matlab_gaussian_trends.jpg');