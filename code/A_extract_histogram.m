clearvars
close all
clc

%link in tif files from root dir
root_dir = '01_max_intensity_input/';
dirs = dir([root_dir,'/*.tif']);

%allocate switches and colors and bit intensity
n = 1;
hist_bins_n = 2^16;
% color = cool(numel(evaluation_range));

%loop over files in root folder
for i=1:numel(dirs)

    this_tif_id = dirs(i).name;
    tif_info = imfinfo([root_dir,this_tif_id]);
    stack_mass = numel(tif_info);

    evaluation_range = 1:stack_mass;%251;
    
    counts = zeros(numel(evaluation_range),hist_bins_n);
    modes = nan(numel(evaluation_range),2);

    five_point_sum = zeros(numel(evaluation_range),5);

    %create output folder
    file_path_out = ['02_count_hist_output/',this_tif_id(1:end-4)];
    if ~exist(file_path_out, 'dir')
        mkdir(file_path_out);
    end
    
    %stack loop
    for j=evaluation_range
        %read files
        this_img = imread([root_dir,this_tif_id],j);

        % get image histogram
        [bins, this_counts, bg_filtered] = get_rois_histogram(this_img, ...
            hist_bins_n, 'all');
        
        export_array = table(bins', this_counts', bg_filtered', ...
            'VariableNames',{'bins','counts','smooth_counts'});
        writetable(export_array, ...
            [file_path_out,'/',sprintf('t_%03d.csv',j)])
    end
       
end

%% Functions

function [bins, this_counts, bg_filtered] = get_rois_histogram(img,hist_bins_n, roi_selection_case)

    %binarize/hole fill/region props
    this_img_bin = imbinarize(imadjust(img));
    this_img_bin = imfill(this_img_bin,'holes');
    img_regprops = regionprops(this_img_bin);
        
    %ROI selection
%     roi_selection_case = 'all';
        
    switch roi_selection_case
        case 'all'
            % all ROIs
            all_obj_idx = numel(img_regprops);
            roi_list = 1:all_obj_idx;
        case 'max'
            % largest area ROI
            [~,max_obj_idx] = max([img_regprops.Area]);
            roi_list = max_obj_idx;
    end
    
    %ROI loop
        % allocate global count (this_counts)
        % each ROI loop adds local ROI counts to global count
    this_counts = zeros(1,hist_bins_n);
        
    for this_roi = roi_list
                    
        box_idx = round(img_regprops(this_roi).BoundingBox);
        row_max = min(size(img,1), box_idx(2)+box_idx(4));
        col_max = min(size(img,2), box_idx(1)+box_idx(3));
        this_select_roi = img(box_idx(2):row_max, box_idx(1):col_max);
        
        %roi histogram
        [roi_counts, bin_edges] = histcounts(this_select_roi(:), ...
                                            -0.5:hist_bins_n-0.5, ...
                                            'Normalization','count');
        this_counts = this_counts + roi_counts;
    end
        
    bins = 0.5*(bin_edges(2:end) + bin_edges(1:end-1));
        
    %construct high pass filter for background removal
    order = 16;
    cut_off = 300;
    high_pass = (bins.^order)./(cut_off.^order+bins.^order);
                
    %smooth histgrom with moving average/remove background
    smooth_counts = movmean(this_counts,30);
    bg_filtered = smooth_counts.*high_pass;
        
    %mass of counted pixels (w/o background)
    % d_bins = bins(2)-bins(1);
    % filt_idx = bg_filtered>0;
    % tot_filt = sum(bg_filtered(filt_idx))*d_bins;
%     tot_filt = sum(bg_filtered);
                
    %normalize histogram
%     bg_filtered_norm = bg_filtered./tot_filt;

end
