function outputs = get3DProperty(img,type)

    [height, width, ~] = size(img);
    grayimg = rgb2gray(img);
    grayimg = double(grayimg);    
    
    if strcmp(type, 'apoptosis')
        nums = sum((grayimg > 0), 1);
        Intensity_total_avg = sum(grayimg, 1);
        Intensity_total_avg(nums>0) = Intensity_total_avg(nums>0) ./ nums(nums>0);
        md_int= Intensity_total_avg;
        %md_int = medfilt1(Intensity_total_avg,5);
        max_intensity = max(md_int);
        [pks,mx] = findpeaks(md_int, 'MINPEAKDISTANCE',floor(width*0.3),'THRESHOLD',0,'NPEAKS',1 );
        if isempty(pks)
            pks = max_intensity;
            mx =find(md_int==pks,1,'first');
        end
        t_hold = pks * 0.85;
    else
        Intensity_total = sum(grayimg,1);
        md_int = medfilt1(Intensity_total,5);
        max_intensity = max(md_int);
        %mx = find(md_int==max_intensity,1,'first');
        %pks = max_intensity;
        [pks,mx] = findpeaks(md_int, 'MINPEAKDISTANCE',floor(width*0.3),'THRESHOLD',0,'NPEAKS',1 );
        if isempty(pks)
            pks = max_intensity;
            mx =find(md_int==pks,1,'first');
        end
        t_hold = pks * 0.3;
    end
    
    
    mx_s = find(md_int>t_hold,1,'first');    
    h_rad = mx - mx_s;    
    rad = h_rad;
    my = floor(height/2);

    
    x = [1:width]; y = [1:height]';
    x = repmat(x, height, 1);
    y = repmat(y, 1, width);
% %     
%          figure;
%          surf(x,y, grayimg);
% %           
%      figure;
%      surf(x,y, LL.*100);


    outputs = {mx, ...
        my, ...
        rad ...
        };

end
