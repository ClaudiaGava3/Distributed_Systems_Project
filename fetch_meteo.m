% --- fetch_meteo.m ---
% SCRIPT UNIFICATO METEO: REALE + SINTETICO + PREVISIONI
% Scarica dati reali da Open-Meteo. Se fallisce, genera dati sintetici.
% Output: Irradianza (W/m^2) e Temperatura (°C)
clear weather_data; 

%% 1. CONFIGURAZIONE
lat = 46.07;  % Trento
lon = 11.12;
giorni = 3;   % Durata previsione
use_synthetic = false; % Metti 'true' per forzare dati finti (debug)

disp('--------------------------------------------------');
disp('AVVIO FETCH METEO...');

%% 2. TENTATIVO SCARICAMENTO DATI REALI (Open-Meteo)
try
    if use_synthetic
        error('Simulazione mod. sintetico richiesta.');
    end
    
    % URL API: Richiede Temperatura e Radiazione Solare (W/m^2) oraria
    url = sprintf('https://api.open-meteo.com/v1/forecast?latitude=%.2f&longitude=%.2f&hourly=temperature_2m,shortwave_radiation&forecast_days=%d', lat, lon, giorni);
    
    disp(['Tentativo scaricamento dati per: Lat ' num2str(lat) ', Lon ' num2str(lon)]);
    raw_data = webread(url);
    
    % -- Elaborazione Dati Reali --
    time_str = raw_data.hourly.time;
    temp_values = raw_data.hourly.temperature_2m;       % °C
    solar_values_Wm2 = raw_data.hourly.shortwave_radiation; % W/m^2 (IMPORTANTE!)
    
    % Conversione Tempo (ISO String -> Secondi da t=0)
    t_start = datetime(time_str{1}, 'InputFormat', 'yyyy-MM-dd''T''HH:mm');
    time_vector = zeros(length(time_str), 1);
    for i = 1:length(time_str)
        t_curr = datetime(time_str{i}, 'InputFormat', 'yyyy-MM-dd''T''HH:mm');
        time_vector(i) = seconds(t_curr - t_start);
    end
    
    mode_msg = 'MODALITÀ: DATI REALI (Open-Meteo)';

catch
    %% 3. FALLBACK: GENERAZIONE DATI SINTETICI (Se manca internet)
    disp('⚠️ API non raggiungibile o disabilitata. Generazione dati SINTETICI...');
    
    % Parametri temporali
    dt_gen = 3600; % Generiamo dati orari per coerenza
    T_sim_gen = giorni * 86400;
    time_vector = (0:dt_gen:T_sim_gen)';
    N_samples = length(time_vector);
    
    % A. Temperatura Sintetica
    T_media = 10; Delta_T = 8; Freq = 1/(24*3600);
    Sfasamento_T = -14 * 3600; 
    temp_values = T_media + Delta_T * cos(2*pi*Freq*(time_vector + Sfasamento_T));
    temp_values = temp_values + 0.5 * randn(N_samples, 1); % Rumore
    
    % B. Sole Sintetico (W/m^2)
    Max_Irradianza = 900; 
    solar_values_Wm2 = zeros(N_samples, 1);
    for i = 1:N_samples
        ora_giorno = mod(time_vector(i), 86400) / 3600;
        if ora_giorno > 6 && ora_giorno < 19 % Giorno
            x = (ora_giorno - 6) / 13 * pi; % 13 ore di luce
            base = sin(x) * Max_Irradianza;
            nuvola = 1; if rand > 0.9, nuvola = 0.4; end % Nuvole random
            solar_values_Wm2(i) = base * nuvola;
        end
    end
    solar_values_Wm2 = solar_values_Wm2 + 5 * rand(N_samples, 1); % Rumore fondo
    solar_values_Wm2(solar_values_Wm2 < 0) = 0;
    
    mode_msg = 'MODALITÀ: DATI SINTETICI (Matematici)';
end

%% 4. CREAZIONE PREVISIONI (IL "CERVELLO")
% Creiamo le previsioni "Falsate" per testare la robustezza del sistema
% Previsione Giorno 1 (Errata per il futuro: prevede gelo improvviso)
Fake_Temp = temp_values;
t_soglia_day3 = 2 * 86400; % Inizio terzo giorno
idx_day3 = find(time_vector > t_soglia_day3);

if ~isempty(idx_day3)
    Fake_Temp(idx_day3) = Fake_Temp(idx_day3) - 5.0; % Errore di previsione (-5°C)
end

Forecast_Day1_Temp = timeseries(Fake_Temp, time_vector);
Forecast_Day2_Temp = timeseries(temp_values, time_vector); % Previsione perfetta

%% 5. OUTPUT PER SIMULINK
% A. Temperatura Reale
Meteo_Reale_Temp = timeseries(temp_values, time_vector);

% B. Sole Reale (Irradianza W/m^2)
% Questo segnale entra nei GAIN delle stanze (es. Gain_Salotto = 1.5 m^2)
Meteo_Reale_Sole = timeseries(solar_values_Wm2, time_vector);

% C. Variabili di Supporto e Assegnazione Workspace
assignin('base', 'T_sim', time_vector(end)); 

% --- MODIFICA RICHIESTA: DEFINIZIONE ESPLICITA T_START_REAL ---
T_start_real = temp_values(1); % Prende la prima temperatura del vettore
assignin('base', 'T_start_real', T_start_real); % Forza la scrittura nel workspace base
% --------------------------------------------------------------

%% 6. RIEPILOGO
disp(mode_msg);
disp(['- Durata Dati:       ' num2str(time_vector(end)/3600) ' ore (' num2str(giorni) ' giorni)']);
disp(['- Temp. Iniziale:    ' num2str(T_start_real) ' °C']);
disp(['- Sole Iniziale:     ' num2str(solar_values_Wm2(1)) ' W/m^2']);
disp('- Variabili create: Meteo_Reale_Temp, Meteo_Reale_Sole, Forecast_Day1_Temp, T_start_real');
disp('--------------------------------------------------');