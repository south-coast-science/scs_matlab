clearvars;

%User-defined variables:
var.Topic_ID = 'unep/ethiopia/loc/1/particulates';
var.url = 'https://aws.southcoastscience.com/topicMessages?topic=%s&startTime=%s';
sampling_rate = 10;
%---------------------------------------------------------------------------------
%Initialization
json_decode = cell(1000,1);
var.i = 0;
while (1)
    var.i = var.i + 1;
    
    if var.i==1 && isfield(json_decode{1,1}, 'message')==0
        var.start_time = all_functions.time_init();
        pause(sampling_rate+25);
        json_decode{var.i,2} = all_functions.curl_decode(var);
        var.start_time = json_decode{var.i,2}.Items(end).payload.rec;
    elseif var.i > 1
        var.start_time = data.datetime{end};
    end
    pause(sampling_rate+25);
    json_decode{var.i,1} = all_functions.curl_decode(var);
    
    if isfield(json_decode{1,1}, 'message')==1
        var.i = 0;
        continue
    end
    if isfield(json_decode{var.i,1}, 'Items')==1
        if isempty(json_decode{var.i,1}.Items)==1 && var.i==1
            var.i = 0;
            var.j = 0;
            continue
        end
    end
    var.z = var.i;
    item_len = length(json_decode{var.z}.Items);
    if item_len>1
        for n = 2:item_len
            json_decode{var.i+n-1}.Items = json_decode{var.z}.Items(2);
            json_decode{var.z}.Items(2) = [];
        end
    end
    var.i = var.i+n-1;
    for x = var.z : (var.z+item_len-1)
        %Parameters to plot:
        data.datetime{x,1}= json_decode{x}.Items.payload.rec;
        data.pm1(x,1) = json_decode{x}.Items.payload.val.pm1;
        data.pm2_5(x,1) = json_decode{x}.Items.payload.val.pm2p5;
        data.pm10(x,1) = json_decode{x}.Items.payload.val.pm10;
    end
    Y_data = [data.pm1, data.pm2_5, data.pm10];
    [data.t, chart] = all_functions.twoD_plot(var, Y_data, data);
    legend('pm1', 'pm2.5', 'pm10');
end