function [bias_ef, unbiased_pf] = interval_bias_fix(data)

voltages = unique(data(:,2));

% Calculate p correct separately for intervals with flash in interval 1 vs 2 
for i=1:length(voltages)
    ind = data(:,2)==voltages(i);
    biased_pf(i) = mean(data(ind,3)==data(ind,4)-48);
    pcorr_1(i) = sum(data(ind,4)==49&data(ind,3)==1)/sum(data(ind,3)==1);
    pcorr_2(i) = sum(data(ind,4)==50&data(ind,3)==2)/sum(data(ind,3)==2);  
end

% Tweak p correct = 1 values slightly for d prime calculations
pcorr_1(pcorr_1==1) = (length(data)/length(voltages)-0.5)/(length(data)/length(voltages));
pcorr_2(pcorr_2==1) = (length(data)/length(voltages)-0.5)/(length(data)/length(voltages));

% Normal, but wrong way of calulating 2AFC d prime
biased_d = sqrt(2)*norminv((pcorr_1+pcorr_2)/2);
% Way suggested by Green & Swets, 1966
 d_prime = sqrt(2)* ((norminv(pcorr_1) + norminv(pcorr_2))/2);

% Back to p correct
 unbiased_pf = normcdf( d_prime / sqrt(2) );
 
 bias_ef = d_prime./biased_d;

figure;hold;
plot_v = voltages; plot_v(1)=plot_v(2)*0.5;
plot(log10(plot_v),biased_pf,'k')
plot(log10(plot_v),pcorr_1,'r--')
plot(log10(plot_v),pcorr_2,'g--')
plot(log10(plot_v),unbiased_pf,'m')
end

