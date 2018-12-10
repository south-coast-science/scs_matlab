clearvars;

tic

API_key='api-key de92c5ff-b47a-4cc4-a04c-62d684d74a1f';
Topic_ID='south-coast-science-dev/production-test/loc/1/gases';
Time_interval='2018-10-26T09:35:00+01:00/2018-10-26T10:40:00+01:00';
command='curl -s -H "Authorization: %s" https://aws.southcoastscience.com/%s/%s/';
[A,cURL2_out]=system(sprintf(command,API_key,Topic_ID,Time_interval));
json_decode=jsondecode(cURL2_out);

sample_size=size(json_decode.Items);
items_num=sample_size(1,1);

datetime=cell(items_num,1);
NO2=zeros(items_num,1);
H2S=zeros(items_num,1);
CO=zeros(items_num,1);
SO2=zeros(items_num,1);
tmp=zeros(items_num,1);
hmd=zeros(items_num,1);

for n=1:items_num
    
    datetime{n,1}= json_decode.Items(n).payload.rec;
    NO2(n,1)= json_decode.Items(n).payload.val.NO2.cnc;
    H2S(n,1)= json_decode.Items(n).payload.val.H2S.cnc;
    CO(n,1)= json_decode.Items(n).payload.val.CO.cnc;
    SO2(n,1)= json_decode.Items(n).payload.val.SO2.cnc;
    tmp(n,1)= json_decode.Items(n).payload.val.sht.tmp;
    hmd(n,1)= json_decode.Items(n).payload.val.sht.hmd;
    
end

data.names.NO2=NO2;
data.names.CO=CO;
data.names.SO2=SO2;
data.names.H2S=H2S;
data.names.Humidity=hmd;
data.names.Temperature=tmp;

toc

list={'Live data','Historic data'};
[type,tf] = listdlg('ListString',list);

if type==1
    
    list_title={'south-coast-science-test/production/loc/1/gas','south-coast-science-test/production/loc/1/particulates','south-coast-science-test/production/loc/1/climate'};
    [Topic_ID,tf] = listdlg('ListString',list_title);
    
    if 1 >= Topic_ID <= 3
                
        [var_pos,tf] = listdlg('PromptString','Select a variable to plot:','ListString', fieldnames(data.names));
        var_size=size(var_pos);
        
        if var_pos==1
            figure(1)
            t=datenum(datetime,'yyyy-mm-ddTHH:MM:SS.FFF');
            plot(t,NO2)
            datetick('x','dd-mmm-yyyy HH:MM:SS','keepticks','keeplimits');
            xlabel('Time (dd-mmm-yyyy HH:MM:SS)');
            ylabel('NO2 (ppb)');
            title('NO2');
            legend('NO2');
        end
        
        if var_pos==2
            figure(2)
            t=datenum(datetime,'yyyy-mm-ddTHH:MM:SS.FFF');
            plot(t,CO)
            datetick('x','dd-mmm-yyyy HH:MM:SS','keepticks','keeplimits');
            xlabel('Time (dd-mmm-yyyy HH:MM:SS)');
            ylabel('CO (ppb)');
            title('CO');
            legend('CO');
        end
        
        if var_pos==3
            figure(3)
            t=datenum(datetime,'yyyy-mm-ddTHH:MM:SS.FFF');
            plot(t,SO2)
            datetick('x','dd-mmm-yyyy HH:MM:SS','keepticks','keeplimits');
            xlabel('Time (dd-mmm-yyyy HH:MM:SS)');
            ylabel('SO2 (ppb)');
            title('SO2');
            legend('SO2');
        end
        
        if var_pos==4
            figure(4)
            t=datenum(datetime,'yyyy-mm-ddTHH:MM:SS.FFF');
            plot(t,H2S)
            datetick('x','dd-mmm-yyyy HH:MM:SS','keepticks','keeplimits');
            xlabel('Time (dd-mmm-yyyy HH:MM:SS)');
            ylabel('H2S (ppb)');
            title('H2S');
            legend('H2S');
        end
        
        if var_pos==5
            figure(5)
            t=datenum(datetime,'yyyy-mm-ddTHH:MM:SS.FFF');
            plot(t,hmd)
            datetick('x','dd-mmm-yyyy HH:MM:SS','keepticks','keeplimits');
            xlabel('Time (dd-mmm-yyyy HH:MM:SS)');
            ylabel('Humidity (%)');
            title('Relative Humidity');
            legend('Humidity');
        end
        
        if var_pos==6
            figure(6)
            t=datenum(datetime,'yyyy-mm-ddTHH:MM:SS.FFF');
            plot(t,tmp)
            datetick('x','dd-mmm-yyyy HH:MM:SS','keepticks','keeplimits');
            xlabel('Time (dd-mmm-yyyy HH:MM:SS)');
            ylabel('Temperature (°C)');
            title('Temperature');
            legend('Temperature');
        end
        
        if isequal(var_pos,[1,2]) %Plot CO and NO2
            figure(7)
            t=datenum(datetime,'yyyy-mm-ddTHH:MM:SS.FFF');
            plot(t,NO2,t,CO)
            datetick('x','dd-mmm-yyyy HH:MM:SS','keepticks','keeplimits');
            xlabel('Time (dd-mmm-yyyy HH:MM:SS)');
            ylabel('CO & NO2 (ppb)');
            title('CO & NO2');
            legend('NO2','CO');
        end
        
    end
    
    
end




