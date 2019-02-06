% P(z)=P(sea level)*exp(-z/H) 
function aH = abs_humidity(type)

Rw = 461.52; % Specific gas constant for water vapour (J/kg*K)
Pc = 22.064*10^6; % Critical Pressure (Pa)
Tc = 647.096; % Critical Temperature (K)
a1 = -7.85951783;
a2 = 1.84408259;
a3 = -11.7866497;
a4 = 22.6807411;
a5 = -15.9618719;
a6 = 1.80122502;

for n=1:length(type.data.tmp)
    
    T(n,1) = type.data.tmp(n,1); % Ambient Temperature(degrees C)
    RH(n,1) = type.data.hmd(n,1); % Relative Humidity (%)
    th(n,1) = 1-((T(n)+273.15)/Tc);

    Pws(n,1) = Pc*exp((Tc/(T(n)+273.15))*(a1*th(n)+a2*th(n)^1.5+a3*th(n)^3+a4*th(n)^3.5+a5*th(n)^4+a6*th(n)^7.5)); % (kPa)
    Pw(n,1) = RH(n)*Pws(n)/100; % (kPa)
    aH(n,1) = Pw(n)*1000/(Rw*(T(n)+273.15)); % (g/m^3)
    
end
% P = 101325; % Ambient pressure (Pa)
% W = 621.97*Pw*(P-Pw); % Mixing Ratio (g/kg)
% h = (T+273.15)*(1.01+0.00189*W)+2.5*W; % enthalpy (kJ/kg)

end









