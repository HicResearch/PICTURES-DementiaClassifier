#############################################
# File:   Step0.m
#
# 
# Purpose:
# To set ranges for the prameters
#
# Author: PS Reel

min_p_Thres = 0.00001; max_p_Thres = 0.01; % changed from 0.8 [0.002 0.01]
min_C_value = 1; max_C_value = 600;


p_range = max_p_Thres - min_p_Thres;
C_range = max_C_value - min_C_value;


save_seed = Rseed;


% Get best values from last loop
if Rseed > 1
	table_last_run = readtable(strcat('/home/ubuntu/Desktop/New_ML_Code/job-out/',num2str(save_seed-1),'/Final_summary.csv'));
	
	[max_acc,max_acc_index] = max(table_last_run.ACC);
	
	mean_p = table_last_run.p_Thres(max_acc_index);
	mean_C = table_last_run.C_value(max_acc_index);

	min_p = mean(table_last_run.min_p); max_p = mean(table_last_run.max_p)
	min_C = mean(table_last_run.min_C); max_C = mean(table_last_run.max_C)

	new_range_p = p_range/(1.2^(Rseed-1));
        new_range_C = C_range/(1.2^(Rseed-1));

%if not within 10 percent of previous range values, reduce the size of range for next run
    if ((min_p/mean_p) < 0.9) || ((mean_p/max_p) < 0.9)
	new_range_p = p_range/(1.2^(Rseed-2));
	end 
	if ((min_C/mean_C) < 0.9) || ((mean_C/max_C) < 0.9)
	new_range_C = C_range/(1.2^(Rseed-2));
	end
	

	min_p = mean_p - (new_range_p/2); max_p = mean_p + (new_range_p/2);

	if min_p <= 0
		min_p = 0.000001
	end

	min_C = mean_C - (new_range_C/2); max_C = mean_C + (new_range_C/2);
      
        if min_C < 1
           	min_C = 1
        end




else
	min_p = min_p_Thres; max_p = max_p_Thres;
	min_C = min_C_value; max_C = max_C_value;

end

Rseed = save_seed;

append('P range = ', num2str(min_p), ' - ', num2str(max_p))
append('C range = ', num2str(min_C), ' - ', num2str(max_C))


