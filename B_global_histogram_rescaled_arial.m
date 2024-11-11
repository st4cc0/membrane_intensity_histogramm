clearvars
close all
clc

root_dir = '02_count_hist_output/';
sample_list = dir(root_dir);
sample_list = sample_list(3:end);

time = 2:1:200;
n = 1;
hist_bins_n = 2^16;
counts_tot = zeros(numel(time),hist_bins_n);
modes = nan(numel(time),2);
five_point_sum = zeros(numel(time),5);
color = cool(numel(time));

for i=time

    counts = zeros(hist_bins_n,1);
    counts_smooth = zeros(hist_bins_n,1);

    %sample loop
    for j=1:numel(sample_list)
        read_file_id = readtable([root_dir,sample_list(j).name,...
                                sprintf('/t_%03d.csv',i)]);
    
        bins = read_file_id.bins;
        counts = counts + read_file_id.counts;
        counts_smooth = counts_smooth + read_file_id.smooth_counts;

    end

    bg_filtered_norm = counts_smooth./sum(counts_smooth);

    %find Q1 Q2 Q3 quantiles
    cdf = cumsum(bg_filtered_norm);
    q_1_idx = cdf<0.25;
    q_2_idx = cdf<0.50;
    q_3_idx = cdf<0.75;

    q_1 = max(bins(q_1_idx));
    q_2 = max(bins(q_2_idx));
    q_3 = max(bins(q_3_idx));

    idr = q_3 - q_1;

    lower_bound_idx = bins < q_1 - 1.5*idr;
    upper_bound_idx = bins < q_3 + 1.5*idr;
    lower_bound = max(bins(lower_bound_idx+1));
    upper_bound = max(bins(upper_bound_idx));

    five_point_sum(n,:) = [lower_bound,q_1,q_2,q_3,upper_bound];

    %find modes
    [~,modes_idx] = findpeaks(bg_filtered_norm, ...
        'NPeaks',2, ...
        'MinPeakWidth', 10*(bins(2)-bins(1)), ...
        'MinPeakProminence',2E-5);
    if numel(modes_idx) == 1
        modes(n,1) = bins(modes_idx);
    elseif numel(modes_idx) == 2
        modes(n,:) = bins(modes_idx);
    end

    counts_tot(n,:) = bg_filtered_norm;


    figure(1)
%     counts_smooth

    bins = bins/412;
    plot(log2(bins),bg_filtered_norm,'color',color(n,:),'LineWidth',1.1)
%     plot(log2(bins),100*bg_filtered_norm,'color',color(n,:))
%     xlim([0,16])
%     xlim(10.^[2,4])
    xlim([-1,3.5])
%     ylim([0,0.21])
    hold on

    n = n + 1;

end

xticks(-1:3)
xticklabels({'0.5','1','2','4','8'})
% xlabel('$\log_2(\bar{\mu})$','Interpreter','latex')
xlabel('normalized intensity')
ylabel('frequency')
style_plot(22)


% figure(1)
xline(log2(1),':','LineWidth',1.2,'Color',0.3*[1,1,1])
xline(log2(2),':','LineWidth',1.2,'Color',0.3*[1,1,1])
box off
% set(gca,'fontname','arial')
pbaspect([1 1 1])
saveas(gca,'histogram_rescaled.png')


function style_plot(font_size)
    set(gca,'Color','w','XColor',[0 0 0],'YColor',[0 0 0])
    set(gcf,'Color','w')
%     set(gca,'TickLabelInterpreter','arial');
    set(gcf, 'InvertHardcopy', 'off')
    set(gca,'FontSize',font_size)
%     set(gca,'XScale','log')
%     set(gca,'YScale','log')
end

