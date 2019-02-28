clearvars -except alphasense301201902sensaH1min alphasense303201902sensaH1min
% model.aH = fitlm(alphasense301201902sensaH1min.valshthmdaH, alphasense303201902sensaH1min.valshthmdaH);
model.tmp = fitlm(alphasense301201902sensaH1min.valshttmp, alphasense303201902sensaH1min.valshttmp);
% model.NO = fitlm(alphasense301201902sens1min.valNOweC_sens, alphasense303201902sens1min1.valNOweC_sens);
% model.CO = fitlm(alphasense301201902sens1min.valCOweC_sens, alphasense303201902sens1min1.valCOweC_sens);

fnames = fieldnames(model);
for n = 1:length(fnames)
fig{n} = figure('units','normalized','outerposition',[0 0 1 1]);
plt{n} = plot(model.(fnames{n}));

coeffs = uicontrol(gcf, 'Style', 'text', 'Units', 'normalized', 'Position', [0.77 0.4 0.13 0.07],...
    'HorizontalAlignment', 'left', 'BackgroundColor', 'w');
c = model.(fnames{n}).Coefficients.Estimate(1);
m = model.(fnames{n}).Coefficients.Estimate(2);
R_squared = model.(fnames{n}).Rsquared.Ordinary;
A{1,1} = sprintf('Slope = %f', m);
A{1,2} = sprintf('Intercept = %f', c);
A{1,3} = sprintf('R_squared = %f', R_squared);
coeffs.String = sprintf('%s\n%s\n%s', A{1,1}, A{1,2}, A{1,3});

title(fnames{n})
xlabel('alphasense_301')
ylabel('alphasense_303')
pdf_name = sprintf('alphasense_301x303_baseline_%s_2019-02', fnames{n});
utilities.figuretopdf(pdf_name)
end



