% --- fetch_meteo.m ---
% Scarica previsioni meteo reali per la simulazione Simulink
clear weather_data; 

%% 1. CONFIGURAZIONE (Trento)
lat = 46.07;
lon = 11.12;
giorni = 3; % Quanti giorni di previsione vuoi

% Costruiamo l'URL per l'API Open-Meteo
url = sprintf('https://api.open-meteo.com/v1/forecast?latitude=%.2f&longitude=%.2f&hourly=temperature_2m,shortwave_radiation&forecast_days=%d', lat, lon, giorni);

disp('Scaricamento dati meteo da Open-Meteo...');
try
    raw_data = webread(url);
catch
    error('Impossibile scaricare i dati. Controlla la connessione internet.');
end

%% 2. ESTRAZIONE E PULIZIA DATI
time_str = raw_data.hourly.time;
temp_values = raw_data.hourly.temperature_2m;       % Gradi Celsius
solar_values = raw_data.hourly.shortwave_radiation; % Watt/m^2

% Conversione del Tempo per Simulink (Secondi progressivi da t=0)
t_start = datetime(time_str{1}, 'InputFormat', 'yyyy-MM-dd''T''HH:mm');
time_vector = zeros(length(time_str), 1);

for i = 1:length(time_str)
    t_curr = datetime(time_str{i}, 'InputFormat', 'yyyy-MM-dd''T''HH:mm');
    time_vector(i) = seconds(t_curr - t_start);
end

% Calcolo Potenza Solare su Finestra (Watt)
Area_Finestra = 2.0; 
SHGC = 0.7; 
Potenza_Sole_Watt = solar_values * Area_Finestra * SHGC;

%% 3. CREAZIONE VARIABILI "REALI" (LA VERITÀ FISICA)
% Queste guidano la fisica delle stanze (Muri e Aria)

% A. Temperatura Reale
Meteo_Reale_Temp = timeseries(temp_values, time_vector);

% B. Sole Reale (ECCO LA RIGA CHE MANCAVA!)
Meteo_Reale_Sole = timeseries(Potenza_Sole_Watt, time_vector);

%% 4. CREAZIONE PREVISIONI (IL CERVELLO)
% Simuliamo l'aggiornamento delle previsioni per il cervello

% Previsione Giorno 1 (Errata per il 3° giorno: prevede molto più freddo)
Fake_Temp = temp_values;
% Troviamo l'indice dove inizia il 3° giorno (dopo 48 ore)
idx_day3 = find(time_vector > 172800);
if ~isempty(idx_day3)
    Fake_Temp(idx_day3) = Fake_Temp(idx_day3) - 5.0; % Toglie 5 gradi (finto gelo)
end

Forecast_Day1_Temp = timeseries(Fake_Temp, time_vector);

% Previsione Giorno 2 (Corretta)
Forecast_Day2_Temp = timeseries(temp_values, time_vector);

%% 5. SETUP INIZIALE E PULIZIA
% Aggiorniamo la durata della simulazione
assignin('base', 'T_sim', time_vector(end)); 

% Cattura la temperatura del primo istante (t=0) per inizializzare gli Integratori
T_start_real = temp_values(1);

disp('--------------------------------------------------');
disp('DATI METEO CARICATI CORRETTAMENTE:');
disp(['- Meteo_Reale_Temp  (Gradi): ', num2str(temp_values(1)), '°C iniziali']);
disp(['- Meteo_Reale_Sole  (Watt):  ', num2str(Potenza_Sole_Watt(1)), 'W iniziali']);
disp('- Forecast_Day1_Temp (Previsione errata)');
disp('- Forecast_Day2_Temp (Previsione corretta)');
disp(['- T_start_real:      ', num2str(T_start_real)]);
disp(['Durata simulazione:  ', num2str(time_vector(end)), ' secondi']);
disp('--------------------------------------------------');