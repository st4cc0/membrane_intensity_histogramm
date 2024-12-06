clearvars
close all
clc

root_dir = '02_count_hist_output/';
sample_list = dir(root_dir);
sample_list = sample_list(3:end);

j = 1;
n = 1;
smooth_n = 35;
time = 2:smooth_n:200;

hist_bins_n = 2^16;
counts_tot = zeros(numel(time),hist_bins_n);
modes = nan(numel(time),2);
five_point_sum = zeros(numel(time),5);
color = cool(numel(time));

for i=time

    bg_filtered_norm = zeros(hist_bins_n,1);

    while j<=smooth_n

        counts = zeros(hist_bins_n,1);
        counts_smooth = zeros(hist_bins_n,1);

        read_file_id = readtable([root_dir,sample_list(1).name,...
            sprintf('/t_%03d.csv',i+(j-1))]);

        bins = read_file_id.bins;
        counts = counts + read_file_id.counts;
        counts_smooth = counts_smooth + read_file_id.smooth_counts;

        bg_filtered_norm = bg_filtered_norm + counts_smooth./sum(counts_smooth);

        j = j + 1;
    end

bg_filtered_norm = bg_filtered_norm./smooth_n;
bins = bins/412;
plot(log2(bins),bg_filtered_norm*10^3,'color',color(n,:),'LineWidth',1.2)

xlim([-1,3.5])
hold on

j = 1;
n = n + 1;

end

xticks(-1:3)
xticklabels({'0.5','1','2','4','8'})
% xlabel('$\log_2(\bar{\mu})$','Interpreter','latex')
xlabel('Normalized Intensity')
ylabel('Frequency (\times 10^{-3})')
style_plot(22)
set(gca,'linewidth',1.2)


% figure(1)
xline(log2(1),':','LineWidth',1.2,'Color',0.3*[1,1,1])
xline(log2(2),':','LineWidth',1.2,'Color',0.3*[1,1,1])
box off
% set(gca,'fontname','arial')
pbaspect([1 1 1])
saveas(gca,'invitro_histogram_rescaled_smooth.png')
saveas(gca,'invitro_histogram_rescaled_smooth.pdf')


function style_plot(font_size)
    set(gca,'Color','w','XColor',[0 0 0],'YColor',[0 0 0])
    set(gcf,'Color','w')
%     set(gca,'TickLabelInterpreter','arial');
    set(gcf, 'InvertHardcopy', 'off')
    set(gca,'FontSize',font_size)
%     set(gca,'XScale','log')
%     set(gca,'YScale','log')
end

