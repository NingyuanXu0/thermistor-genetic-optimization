function F = tempCompCurve(x, Tdata)
    % Input voltage
    Vin = 1.1;
    % Thermistor Calculations
    % Values in x: R1 R2 R3 R4 RTH1(T_25degc) Beta1 RTH2(T_25degc) Beta2
    T_25 = 298.15;
    T_off = 273.15;
    Beta1 = x(6);
    Beta2 = x(8);
    RTH1 = x(5) ./ exp(Beta1 * ((Tdata + T_off) - T_25) ./ ((Tdata + T_off) * T_25));
    RTH2 = x(7) ./ exp(Beta2 * ((Tdata + T_off) - T_25) ./ ((Tdata + T_off) * T_25));
    % Define equivalent circuits for parallel R's and RTH's
    R1_eq = x(1) .* RTH1 ./ (x(1) + RTH1);
    R3_eq = x(3) .* RTH2 ./ (x(3) + RTH2);
    % Calculate voltages at Point B
    F = Vin * (R3_eq + x(4)) ./ (R1_eq + x(2) + R3_eq + x(4));
end
