function [out, msg] = getSignal(in)

    [height, width, d] = size(in);
    
    if d == 3
        grayimg = rgb2gray(in);
    else
        grayimg = in;
    end

    [mymean, mymedian] = getIntensityMean(in);
    
    if d == 3
        data = double(reshape(in, width*height, 3));
    else
        data = double(reshape(in, width*height, 1));
    end
    
    if false
        col_space = [sum(sum(in(:,:,1))),sum(sum(in(:,:,2))),sum(sum(in(:,:,3)))];
        id_col = find(col_space == max(col_space));

        if(id_col==1),matt=[0 0 0;50 0 0];elseif(id_col==2),matt=[0 0 0;0 50 0];else matt = [0 0 0;0 0 50];end
        [label_background, tmp] = kmeans(data, 2, 'Start', matt);
        if mean(tmp(1,:)) < 10, idx_background = (label_background==1); else idx_background = (label_background==2); end
        idx_object = ~idx_background;
        out_kmeans = reshape(idx_object, height, width);
    else
        a = find(grayimg == mymedian);
        a = a(1);
        b = find(grayimg == floor(mymean));
        b = b(1);
        if d == 3
            initpoint1 = reshape(in(mod(a,height)+1,floor(a/height)+1,:), 1, 3);
            initpoint2 = reshape(in(mod(b,height)+1,floor(b/height)+1,:), 1, 3);
        else
            initpoint1 = in(mod(a,height)+1,floor(a/height)+1);
            initpoint2 = in(mod(b,height)+1,floor(b/height)+1);
        end
        [label_background, tmp] = kmeans(data, 2, 'Start', double([initpoint1; initpoint2]));
        if mean(tmp(1,:)) < 10, idx_background = (label_background==1); else idx_background = (label_background==2); end
        idx_object = ~idx_background;
        out_kmeans = reshape(idx_object, height, width);
    end
    
    out_threshold = (grayimg > floor((mymean + mymedian)*0.4));
    
    if ( numel(find(out_kmeans)) < numel(grayimg) * 0.9 ) && ...
       ( numel(find(out_kmeans)) > numel(find(out_threshold)) )
        out = out_kmeans; msg = 'kmeans';
    else
        out = out_threshold; msg = 'threshold';
    end
    %out = out_kmeans; msg = 'kmeans';
    out = logical(imfill(uint8(out)));
    
end