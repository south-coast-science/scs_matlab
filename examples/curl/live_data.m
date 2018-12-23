clearvars;

%User-defined variables:
var.Topic_ID = 'unep/ethiopia/loc/1/climate';
var.url = 'https://aws.southcoastscience.com/topicMessages?topic=%s&startTime=%s';
sampling_rate = 60;
%---------------------------------------------------------------------------------
%Initialization
json_decode = cell(1000,1);
var.i = 0;
while (1)
    var.i = var.i + 1;
    
    if var.i==1
        var.start_time = all_functions.time_init();
    elseif var.i > 1
        var.start_time = data.datetime{end};
    end
    pause(sampling_rate);
    json_decode{var.i,1} = all_functions.curl_decode(var);
    %Parameters to plot:   
    data.datetime{var.i,1}= json_decode{var.i}.Items.payload.rec;
    data.tmp(var.i,1)= json_decode{var.i}.Items.payload.val.tmp;
    data.hmd(var.i,1)= json_decode{var.i}.Items.payload.val.hmd;
    
    Y_data = [data.tmp, data.hmd];
    [data.t, chart] = all_functions.twoD_plot(var, Y_data, data);
    legend('tmp', 'hmd');
end




