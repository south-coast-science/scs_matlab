% Created on 10 February 2019
%
% @author: Milton Logothetis (milton.logothetis@southcoastscience.com)
%
% DESCRIPTION
% Combines two csv files using csv_reader.py and collates them based on
% absolute humidity values using csv_collator.py.
%
% RESOURCES
% https://github.com/south-coast-science/scs_analysis/wiki/csv_reader.
% https://github.com/south-coast-science/scs_analysis/wiki/csv_collator.

clearvars;
curr_dir = pwd; % starting directory

% Inputs
rep_name = 'test.csv';
ref_path = '..\alphasense shed gases';
ref_name = 'ref_2018-08_2018-09_iso_5min.csv';
joined_out_name = 'alphasense_303_2018-08_2018-09_joined.csv';
collated_out_name = 'test_joined_aH';
data_root = 'g:\My Drive\Data Interpretation\Humidity\Regression_data';

cd(data_root);
g_drive = pwd;
csv_join_cmd = 'csv_join.py -i -v -l praxis rec %s -r ref rec "%s"\\ref\\%s | csv_writer.py %s';
[~,joined_out] = system(sprintf(csv_join_cmd, rep_name, ref_path, ref_name, joined_out_name));

[~,aH_min] = system(sprintf('csv_reader.py test_joined.csv | sample_min.py praxis.val.sht.hmd.aH');
aH_min = jsondecode(aH_min);
aH_min = aH_min.praxis.val.sht.hmd.aH;
[~,aH_max] = system('csv_reader.py test_joined.csv | sample_max.py praxis.val.sht.hmd.aH');
aH_max = jsondecode(aH_max);
aH_max = aH_max.praxis.val.sht.hmd.aH;
[~,collated_out] = system(sprintf('csv_reader.py test_joined.csv | csv_collator.py -v -l %s -u %s -d 1 -f collated/%s praxis.val.sht.hmd.aH', aH_min, aH_max, collated_out_name));
cd(curr_dir);
