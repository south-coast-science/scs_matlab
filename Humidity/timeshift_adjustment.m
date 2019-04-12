clearvars
joined_filename = 'praxis_ref_joined_climate_rpoly1_short.csv';
T = readtable(joined_filename);

rcorr_error = T.rcorrError;
hmd = T.climate_val_hmd;
tmp = T.climate_val_tmp;
rec = datenum(T.rec, 'yyyy-mm-ddTHH:MM:SSZ');

figure();
plot(rec, hmd, 'Color', 'b')
dcm_obj = datacursormode(gcf);
dcm_obj.UpdateFcn = @utilities.data_cursor;
figure();
plot(rec, tmp, 'Color', 'r')
dcm_obj = datacursormode(gcf);
dcm_obj.UpdateFcn = @utilities.data_cursor;
figure();
plot(rec, rcorr_error, 'Color', 'g')
dcm_obj = datacursormode(gcf);
dcm_obj.UpdateFcn = @utilities.data_cursor;

