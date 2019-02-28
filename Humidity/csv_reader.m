clearvars -except ref

var.filename = 'heathrow_field_gases_2019-02_14-1hr_NO2_ref.csv'; % Specify file name after adding to path.
var.Topic_ID = var.filename;
reader_cmd = 'csv_reader.py %s | node.py -a';
[~, out] = system(sprintf(reader_cmd, var.filename));
jsondecode = jsondecode(out);

% Define parameters extracted from decoded data:
for n=1:length(jsondecode)
        data.datetime{n,1} = jsondecode(n).rec;
        data.NO2_based = jsondecode(n).val.NO2.cnc.based;
        data.NO2_ref = jsondecode(n).ref.NO2.cnc;
%         type.data.NO2(n,1) = jsondecode(n).val.NO2.cnc;
%         type.data.NO2_wec(n,1) = jsondecode(n).val.NO2.weC;
%         type.data.NO(n,1)= jsondecode(n).val.NO.cnc;
%         type.data.NO_wec(n,1)= jsondecode(n).val.NO.weC;
%         type.data.CO(n,1)= jsondecode(n).val.CO.cnc;
%         type.data.CO_wec(n,1)= jsondecode(n).val.CO.weC;
%         type.data.tmp(n,1) = jsondecode(n).val.sht.tmp;
%         type.data.hmd(n,1) = jsondecode(n).val.sht.hmd;
%     data.datetime{n,1} = jsondecode(n).datetime;
%     data.NO2(n,1) = jsondecode(n).NO2;
%     data.NO2_wec(n,1) = jsondecode(n).NO2_weC;
%     data.NO(n,1)= jsondecode(n).NO;
%     data.NO_wec(n,1)= jsondecode(n).NO_weC;
%     data.CO(n,1)= jsondecode(n).CO;
%     data.CO_wec(n,1)= jsondecode(n).CO_weC;
%     data.tmp(n,1) = jsondecode(n).tmp;
%     data.hmd(n,1) = jsondecode(n).hmd;
%     data.aH(n,1) = jsondecode(n).aH;
end

hist.data = [];
hist.last_update = [isfield(hist, 'data'); isfield(hist, 'aggr')];

% fig = figure();
% Y_data.SO2 = []; Y_data.tmp=[]; Y_data.hmd=[]; % Specify plotted parameters.
% fig = utilities.multiplot(Y_data, type, hist, var, jsondecode, fig);
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
var.filename_ref = 'heathrow_field_gases_2019-02-11-ref.csv';
reader_cmd = 'csv_reader.py %s | node.py -a';
[~, out_ref] = system(sprintf(reader_cmd, var.filename_ref));
jsondecode_ref = jsondecode(out_ref);

for n=1:length(jsondecode_ref)
    ref.datetime_ref{n,1} = jsondecode_ref(n).rec;
    ref.NO2_ref(n,1) = jsondecode_ref(n).val.NO2.cnc;
end
ref.datetime_ref = datenum(ref.datetime_ref, 'yyyy-mm-ddTHH:MM:SS');