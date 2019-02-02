clearvars;

[~, out] = system('socket_receiver.py');
jsondecode = jsondecode(out);
type.data.datetime = jsondecode.rec;
type.data.tmp = jsondecode.val.tmp;
Y_data.tmp = [];
multiplot(Y_data, type, var, jsondecode, fig);


    
