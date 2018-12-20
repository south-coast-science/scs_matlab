clearvars;

filename = 'gases.csv'; % Specify file name after adding to path.
reader_cmd = 'csv_reader.py %s | node.py -a';
[~, out] = system(sprintf(reader_cmd, filename));
json_decode = jsondecode(out);

% Define parameters extracted from decoded data:
for n=1:length(json_decode)
data.datetime{n, 1} = json_decode(n).rec;
data.CO(n, 1) = json_decode(n).val.CO.cnc;
data.NO2(n, 1) = json_decode(n).val.NO2.cnc;
data.SO2(n, 1) = json_decode(n).val.SO2.cnc;
data.H2S(n, 1) = json_decode(n).val.H2S.cnc;
data.tmp(n, 1) = json_decode(n).val.sht.tmp;
data.hmd(n, 1) = json_decode(n).val.sht.hmd;
end

data.t = cellfun(@all_functions.datenum8601, cellstr(data.datetime));
figure();
plot(data.t, data.CO); % Specify parameters to plot.
datetick('x', 'dd-mmm-yy HH:MM','keepticks','keeplimits');
xlabel({'Date-Time'; '(dd-mmm-yy HH:MM)'})
legend('CO')
