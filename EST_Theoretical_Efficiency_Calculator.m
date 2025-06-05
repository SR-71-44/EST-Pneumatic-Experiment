% Flow rate range

Q_l_min = linspace(10, 200, 400);
Q_m3_s = Q_l_min * (1e-3 / 60);

% Parameters

p_0 = 1e5; %Ambient pressure
p_tank = 4.5e5; %Tank pressure
T = 293.15; %Room temperature
T_0 = 273.15; % zero degrees celsius
T_S = 124; %ref temperature for air 
eta_reference = 17.2e-6; %Reference viscosity of air at 0 celsius
eta_experiment = eta_viscosity(T_S, T_0, T, eta_reference); 
L_2 = 0.2; %m length of 1st pipe
L_5 = 0.2; %m length of second pipe
R = 0.004/2; %m radius of the tube 
Kv_ball = 1.6192e-03;
Kv_check =  2.2903e-04;

efficiency_theoretical = zeros(size(Q_m3_s));


for i = 1:length(Q_m3_s)
    Q = Q_m3_s(i);

    %First loss
    dp_1 = (p_tank/p_0)*(T_0/T) * (Q/Kv_check)^2;
    
    %Second loss 
    dp_2 = (8*Q*eta_experiment*L_2)/(pi*R^4);
    
    %Third loss 
    dp_3 = ((p_tank - dp_2 - dp_1)/p_0)*(T_0/T) * (Q/Kv_ball)^2;
    
    %Fourth loss
    dp_4 = ((p_tank - dp_3 - dp_2 - dp_1)/p_0)*(T_0/T) * (Q/Kv_check)^2;
    
    %Fifth loss
    dp_5 = (8*Q*eta_experiment*L_5)/(pi*R^4);

    % Total loss
    dp_total = dp_5 + dp_4 + dp_3 + dp_2 + dp_1;

    %Theoretical efficiency 
    efficiency_theoretical(i) = 1 - (dp_total/p_tank);
end

figure 
plot(Q_m3_s, efficiency_theoretical);
title('Theoretical losses vs flow rate')
xlabel('Flow rate through the system (m^3/s)')
ylabel('Theoretical efficiency')
grid on






function air_viscosity = eta_viscosity(temp_ref, temp_0_celsius, T_room, eta_ref)

    air_viscosity = eta_ref*((1+(temp_ref/temp_0_celsius))/(1+(temp_ref/T_room)))*sqrt(T_room/temp_0_celsius);
end