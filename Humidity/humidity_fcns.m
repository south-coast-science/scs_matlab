classdef humidity_fcns
    methods(Static)
        
        % Absolute humidity calculator
        function [aH,RH] = abs_humidity(type)
            
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
            % W = 621.97*Pw*(P-Pw); % Mixing Ratio (g/kg)
            % h = (T+273.15)*(1.01+0.00189*W)+2.5*W; % enthalpy (kJ/kg)
        end
        
        % Ambient pressure depending on height calculator (below h=11km)
        function P = P_atm(T,h)
            
            p0 = 101325; % Pressure at sea level (Pa)
            L = 0.0065; % Standard temperature lapse rate (K/m)
            
            g = 9.80665; % Acceleration due to gravity (m/s2)
            M = 0.0289644; % Molar mass of earth's air (kg/mol)
            R = 8.3144598; % Gas constant (J/(mol*K))
            
            A = (g*M)/(R*L);
            P = p0*(1-(L*h/(T+L*h+273.15)))^A; % Atmospheric Pressure (Pa)
        end
        
        % Ambient pressure at sea level (below h=11km)
        function p0 = P_sea(P,h,T)
            L = 0.0065; % Standard temperature lapse rate (K/m)
            
            g = 9.80665; % Acceleration due to gravity (m/s2)
            M = 0.0289644; % Molar mass of earth's air (kg/mol)
            R = 8.3144598; % Gas constant (J/(mol*K))
            
            A = (g*M)/(R*L);
            p0 = P/((1-(L*h/(T+L*h+273.15)))^A); % Sea-level pressure (Pa)
        end
        
        % Create csv spreadsheet
        function create_spreadsheet(type, filename)
            [aH,~] = humidity_fcns.abs_humidity(type);
            data.datetime = type.data.datetime;
            data.NO2 = type.data.NO2;
            data.NO2_weC = type.data.NO2_wec;
            data.NO = type.data.NO;
            data.NO_weC = type.data.NO_wec;
            data.CO = type.data.CO;
            data.CO_weC = type.data.CO_wec;
            data.tmp = type.data.tmp;
            data.hmd = type.data.hmd;
            data.aH = aH;
            utilities.csv_write(filename,data);
        end
        
        % Linear correlation
        function R_squared = R_squared(data1, data2)
            y_bar = mean(data2); % mean of observed data
            SStot = sum((data2-y_bar).^2); % total sum of squares
            SSreg = sum((data1-y_bar).^2); % regression sum of squares
            SSres = sum(data2-data1).^2; % sum of squares of residuals
            R_squared = 1-(SSres/SStot); % coefficient of determination
        end
        
        function out = rgb_assign(data, doc_len, rgb)
            out = zeros(doc_len,3);
            
            for i = 1:doc_len
                d = data.rec(i,1) - data.rec(1,1);
                frac = d/(data.rec(end,1)-data.rec(1,1));
                if (0<=frac)&&(frac<0.1)
                    out(i,1) = rgb{1,1};
                    out(i,2) = rgb{1,2};
                    out(i,3) = rgb{1,3};
                elseif (0.1<=frac)&&(frac<0.2)
                    out(i,1) = rgb{2,1};
                    out(i,2) = rgb{2,2};
                    out(i,3) = rgb{2,3};
                elseif (0.2<=frac)&&(frac<0.3)
                    out(i,1) = rgb{3,1};
                    out(i,2) = rgb{3,2};
                    out(i,3) = rgb{3,3};
                elseif (0.3<=frac)&&(frac<0.4)
                    out(i,1) = rgb{4,1};
                    out(i,2) = rgb{4,2};
                    out(i,3) = rgb{4,3};
                elseif (0.4<=frac)&&(frac<0.5)
                    out(i,1) = rgb{5,1};
                    out(i,2) = rgb{5,2};
                    out(i,3) = rgb{5,3};
                elseif (0.5<=frac)&&(frac<0.5)
                    out(i,1) = rgb{6,1};
                    out(i,2) = rgb{6,2};
                    out(i,3) = rgb{6,3};
                elseif (0.6<=frac)&&(frac<0.7)
                    out(i,1) = rgb{7,1};
                    out(i,2) = rgb{7,2};
                    out(i,3) = rgb{7,3};
                elseif (0.7<=frac)&&(frac<0.8)
                    out(i,1) = rgb{8,1};
                    out(i,2) = rgb{8,2};
                    out(i,3) = rgb{8,3};
                elseif (0.8<=frac)&&(frac<0.9)
                    out(i,1) = rgb{9,1};
                    out(i,2) = rgb{9,2};
                    out(i,3) = rgb{9,3};
                elseif frac>=0.9
                    out(i,1) = rgb{10,1};
                    out(i,2) = rgb{10,2};
                    out(i,3) = rgb{10,3};
                end
            end
        end
    end
end