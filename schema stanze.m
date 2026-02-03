% Pulizia
clc; clear; close all;

% Creazione Figura
figure('Color', 'w', 'Position', [100, 100, 1000, 900]);
axis equal;
axis off;
hold on;

% --- CONFIGURAZIONE ---
% Coordinate (X, Y) - Basate sul layout richiesto
pos.Hallway     = [0, 0];
pos.LivingRoom  = [-1.5, 1.5];
pos.Bedroom     = [1.5, 1.5];
pos.Kitchen     = [-1.5, -1.5];
pos.Bathroom    = [1.5, -1.5];
pos.PowerGrid   = [0, 2.6];

% Colori (RGB normalizzato 0-1)
colors.Hallway    = [0.5804, 0.4039, 0.7412]; % Viola
colors.LivingRoom = [1.0000, 0.4980, 0.0549]; % Arancione
colors.Bedroom    = [0.8392, 0.1529, 0.1569]; % Rosso
colors.Kitchen    = [0.1216, 0.4667, 0.7059]; % Blu
colors.Bathroom   = [0.1725, 0.6275, 0.1725]; % Verde
colors.PowerGrid  = [0.9000, 0.9000, 0.9000]; % Grigio chiaro sfondo

% Raggio dei cerchi
r = 0.55; 

% --- 1. DISEGNO CONNESSIONI (Linee) ---
% Devono essere disegnate PRIMA dei nodi per stare "sotto"

% A) Connessioni Fisiche (Linee Solide Grigie) - Coupling Termico
% Il corridoio si collega a tutti
rooms = fieldnames(pos);
center = pos.Hallway;
for i = 1:length(rooms)
    name = rooms{i};
    if ~strcmp(name, 'Hallway') && ~strcmp(name, 'PowerGrid')
        p = pos.(name);
        line([center(1), p(1)], [center(2), p(2)], ...
             'Color', [0.7, 0.7, 0.7], 'LineWidth', 3, 'LineStyle', '-');
    end
end
% Connessioni extra tra vicini (es. Cucina-Salotto)
p1 = pos.LivingRoom; p2 = pos.Kitchen;
line([p1(1), p2(1)], [p1(2), p2(2)], 'Color', [0.8, 0.8, 0.8], 'LineWidth', 2);
p1 = pos.Bedroom; p2 = pos.Bathroom;
line([p1(1), p2(1)], [p1(2), p2(2)], 'Color', [0.8, 0.8, 0.8], 'LineWidth', 2);

% B) Connessioni Logiche (Linee Tratteggiate Scure) - Negoziazione
p_grid = pos.PowerGrid;
for i = 1:length(rooms)
    name = rooms{i};
    if ~strcmp(name, 'PowerGrid')
        p = pos.(name);
        % Linea tratteggiata verso il Power Grid
        line([p(1), p_grid(1)], [p(2), p_grid(2)], ...
             'Color', [0.2, 0.2, 0.2], 'LineWidth', 1.5, 'LineStyle', '--');
    end
end

% --- 2. DISEGNO NODI (Stanze) ---
% Funzione helper locale per disegnare cerchi
draw_agent(pos.Hallway, r, colors.Hallway, 'Hallway');
draw_agent(pos.LivingRoom, r, colors.LivingRoom, 'Living Room');
draw_agent(pos.Bedroom, r, colors.Bedroom, 'Bedroom');
draw_agent(pos.Kitchen, r, colors.Kitchen, 'Kitchen');
draw_agent(pos.Bathroom, r, colors.Bathroom, 'Bathroom');

% --- 3. DISEGNO NODO POWER GRID ---
% Rettangolo arrotondato in alto
w_rect = 2.2; h_rect = 0.7;
rectangle('Position', [pos.PowerGrid(1)-w_rect/2, pos.PowerGrid(2)-h_rect/2, w_rect, h_rect], ...
          'Curvature', [0.5, 0.5], 'FaceColor', colors.PowerGrid, 'LineWidth', 2);

text(pos.PowerGrid(1), pos.PowerGrid(2)+0.15, 'Power Constraint & Consensus', ...
     'HorizontalAlignment', 'center', 'FontWeight', 'bold', 'FontSize', 11, 'Color', [0.3,0.3,0.3]);
text(pos.PowerGrid(1), pos.PowerGrid(2)-0.15, '(Shared Resource Manager)', ...
     'HorizontalAlignment', 'center', 'FontAngle', 'italic', 'FontSize', 9, 'Color', [0.3 0.3 0.3]);

% --- 4. LEGENDA TESTUALE ---
text(0, -2.5, 'Network Topology: Interconnected Multi-Agent System', ...
     'HorizontalAlignment', 'center', 'FontSize', 14, 'FontWeight', 'bold', 'Color', [0.2 0.2 0.2]);

% Annotazioni sulle linee (opzionale)
text(-0.8, 0.5, {'Physical Coupling', '(Heat Exchange)'}, 'Color', [0.5 0.5 0.5], ...
     'HorizontalAlignment', 'center', 'FontSize', 8, 'Rotation', 45);
text(0.25, 1.1, {'Negotiation Link', '(Data Bus)'}, 'Color', 'k', ...
     'HorizontalAlignment', 'center', 'FontSize', 8, 'Rotation', 78, 'BackgroundColor', 'w');

% Impostazione limiti assi per vedere tutto
xlim([-2.5 2.5]);
ylim([-3 3.5]);

% --- FUNZIONE LOCALE PER DISEGNARE AGENTI ---
function draw_agent(xy, r, col, name)
    % Rettangolo con Curvature [1 1] diventa un cerchio
    % Position è [left bottom width height]
    rectangle('Position', [xy(1)-r, xy(2)-r, 2*r, 2*r], ...
              'Curvature', [1, 1], ...
              'FaceColor', col, 'EdgeColor', 'k', 'LineWidth', 2);
    
    % Testo "AGENT"
    text(xy(1), xy(2)+0.15, 'AGENT', ...
         'HorizontalAlignment', 'center', 'Color', 'w', 'FontSize', 9, 'FontWeight', 'bold');
    
    % Testo Nome Stanza
    text(xy(1), xy(2)-0.15, name, ...
         'HorizontalAlignment', 'center', 'Color', 'w', 'FontSize', 11, 'FontWeight', 'bold');
end