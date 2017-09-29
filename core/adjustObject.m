function [each_object, large_object, ismerged_object] = adjustObject(rawdata, object)

    [wholeheight, wholewidth] = size(object);
    
    % object���� ����
    n = max(max(object,[],1));
    
    % object���� ����
    object_area = hist(reshape(object,1,wholewidth*wholeheight), 0:n); object_area(1) = [];
    
    % object���� ũ�⿡ ���� ���� large �Ǵ� small �� labeling
    large_object = zeros(size(object)); n1 = 0;
    small_object = zeros(size(object)); n2 = 0;
    
    for i = 1:n
        
        isObject = (object == i); %coordObject = data_coord(isObject, :);
        coordObjectRaw = find(isObject) - 1;
        coordObjectX = floor(coordObjectRaw/wholeheight) + 1;
        coordObjectY = mod(coordObjectRaw,wholeheight) + 1;
        
        % object�� �̹����� ��迡 �����ϴ��� üũ
        if ( length(find(coordObjectX == wholewidth)) > 30 ) || ( length(find(coordObjectX == 1)) > 30 ) || ...
            ( length(find(coordObjectY == wholeheight)) > 30 ) || ( length(find(coordObjectY == 1)) > 30 )
            isOnBoundary = true;
        else
            isOnBoundary = false;
        end
        
        % object�� ��迡 ���� �ʾƾ� large �Ǵ� small object �� ����
        if ~isOnBoundary
            if ( object_area(i) > wholeheight*wholewidth*0.000646 ) % ���̰� 900�ȼ��� �Ѿ�� large object �� ����
                n1 = n1 + 1;
                large_object(isObject) = n1;
            elseif ( object_area(i) > 10 ) % ���̰� 10�ȼ��� �Ѿ�� small object �� ���� (10�ȼ� �̸��̸� ������� ������)
                n2 = n2 + 1;
                small_object(isObject) = n2;
            end
        end
        
    end
    
    
    
    % overlap check
    if ( getIntensityMean(rawdata) > 255 * 0.2 )
        
        filterForEdge = [
            0   0	1   1   1   1   1   0   0;
            0   1	1   1   1   1   1   1   0;
            1   1   1   1   1   1   1   1   1;
            1   1   1   1   1   1   1   1   1;
            1   1   1   1   1   1   1   1   1;
            1   1   1   1   1   1   1   1   1;
            1	1   1   1   1   1   1   1   1;
            0	1   1   1   1   1   1   1   0;
            0   0	1   1   1   1   1   0   0];
        
        circle = strel('ball',25,3).getnhood;
        degreeCircle = zeros(n1, 1);            % object�� circle�� ����
        degreeNonCircle = zeros(n1, 1);         % object�� circle�� �ƴ� ����
        large_object_pos.left = zeros(n1, 1);   % object�� box�� ������� �� ���� x��ǥ
        large_object_pos.right = zeros(n1, 1);  % object�� box�� ������� �� ������ x��ǥ
        large_object_pos.top = zeros(n1, 1);    % object�� box�� ������� �� ���� y��ǥ
        large_object_pos.bottom = zeros(n1, 1); % object�� box�� ������� �� �Ʒ��� y��ǥ
        boxWidth = zeros(n1, 1);                % object�� box�� ������� �� �� �ʺ�
        boxHeight = zeros(n1, 1);               % object�� box�� ������� �� �� ����
        large_object_center = zeros(n1, 2);     % box�� �߽� ��ǥ
        
        % check ����
        for i = 1:n1

            % large object�� �Ķ���� ����
            isObject = (large_object == i);
            coordObjectRaw = find(isObject) - 1;
            coordObjectX = floor(coordObjectRaw/wholeheight) + 1;
            coordObjectY = mod(coordObjectRaw,wholeheight) + 1;
            
            large_object_pos.left(i) = min(coordObjectX);
            large_object_pos.right(i) = max(coordObjectX);
            large_object_pos.top(i) = min(coordObjectY);
            large_object_pos.bottom(i) = max(coordObjectY);
            
            boxWidth(i) = large_object_pos.right(i) - large_object_pos.left(i) + 1;
            boxHeight(i) = large_object_pos.bottom(i) - large_object_pos.top(i) + 1;
            large_object_center(i,:) = [ (large_object_pos.right(i) + large_object_pos.left(i)) / 2, ...
                                (large_object_pos.top(i) + large_object_pos.bottom(i)) / 2 ];

            rangeWidth = large_object_pos.left(i) : large_object_pos.right(i);
            rangeHeight = large_object_pos.top(i) : large_object_pos.bottom(i);

            % box ���� i��° object�� ���ϱ� ���� (�ٸ� object�� i��° box �ȿ� ���� �� ����)
            isObjectInBox = repmat(uint8(isObject(rangeHeight, rangeWidth)), [1 1 3]);
            rawdataInBox = rawdata(rangeHeight, rangeWidth, :);
            Img = isObjectInBox .* rawdataInBox;
            grayImg = rgb2gray(Img);
            
            boxRatio = boxWidth(i)/boxHeight(i);
            
            % ���� ����� ���� ����
            if boxRatio > 1.1
                tmpwidth = floor(boxHeight(i)*1.1);
                currentCircle = imresize(circle, 'OutputSize', [boxHeight(i), tmpwidth]);
                tmpcorr1 = corrcoef(double(grayImg(:,1:tmpwidth)), double(currentCircle));
                tmpcorr2 = corrcoef(double(grayImg(:,(end-tmpwidth+1):end)), double(currentCircle));
                degreeCircle(i) = max(tmpcorr1(1,2), tmpcorr2(1,2));
            else
                currentCircle = imresize(circle, 'OutputSize', size(grayImg));
                tmpcorr = corrcoef(double(grayImg), double(currentCircle));
                degreeCircle(i) = tmpcorr(1,2);
            end
            
            tmpcorr = corrcoef([coordObjectX coordObjectY]);
            degreeNonCircle(i) = sqrt(abs(tmpcorr(1,2)));
            
            if ( boxRatio < 1 )
                thresholdNonCircle = 0.5;
                thresholdCircle = 0.6;
            elseif ( boxRatio < 1.5 )
                thresholdNonCircle = 0.6;
                thresholdCircle = 0.55;
            elseif ( boxRatio < 2 )
                thresholdNonCircle = 0.5;
                thresholdCircle = 0.4;
            else
                thresholdNonCircle = 0.55;
                thresholdCircle = 0.3;
            end
            
            abnormalScore = degreeNonCircle(i)/boxRatio/degreeCircle(i);
            fprintf('%2d %.3f(%3d/%3d) %.3f %.3f %.3f %d %d\n',i,boxRatio,boxWidth(i),boxHeight(i),degreeNonCircle(i),degreeCircle(i),abnormalScore,( degreeNonCircle(i) > thresholdNonCircle ),( degreeCircle(i) < thresholdCircle ));
            % object�� ������ ���� �ʹ� �ƴѰ� ���ų�, height�� �ʹ� ũ�� overlap�� �ǽ��� �� ����
            %if ( degreeNonCircle(i) > thresholdNonCircle ) || ( degreeCircle(i) < thresholdCircle ) %|| ( boxHeight(i) > averageHeight*1.2 ) || ( boxWidth(i)*1.1 < boxHeight(i) )
            if abnormalScore > 0.5
                suspicious = true;
            else
                suspicious = false;
            end
            
            % object�� ������ ���� �ʹ� �ƴѰ� ���ų�, height�� �ʹ� ũ�� overlap�� �ǽ��� �� ����
            if suspicious
                
                width = boxWidth(i);
                height = boxHeight(i);

                % edge�� �츰�� (filterForEdge�� �β��� �ϴ� ����)
                edgeimg = imdilate(edge(grayImg, 'canny'), filterForEdge);
                gee = edge(grayImg, 'canny');gee(grayImg < 5) = 1;
                % background�� �츰��
                edgeimg(grayImg < 5) = 1;

                % edge�� background�� �ƴ϶�� object�� ���̴�
                % ��, ~edgeimg�� segmentation�ϸ� edge�� ���� �����ִ� object���� labeling�� �� ����
                tmp_object = ~edgeimg;
                tmp_object = imdilate(tmp_object, strel('disk',2));
                tmp_object = bwlabel(tmp_object, 8);gee2 = tmp_object;

                %tmp_object = imfill(tmp_object, 'holes');
                tmp_object = imdilate(tmp_object, [0 1 1 1 0; 1 1 1 1 1; 1 1 1 1 1; 1 1 1 1 1; 0 1 1 1 0]);
                % �� ���� �ִ��� �޲��ش�
                tmp_object = imbridge(tmp_object);
                tmp_object = imfill(tmp_object, 'holes');

                n3 = max(max(tmp_object,[],1));
                each_area = hist(reshape(tmp_object, 1, width*height), 0:n3) / ( width * height ); each_area(1) = [];

                scoreCandidate = zeros(1,n3);

                %fprintf('%d(%dx%d) %.3f\n', i, boxWidth(i), boxHeight(i), degreeNonCircle(i));
                for j = 1:n3
                    if ( each_area(j) > 0.08 )

                        coordObjectRaw = find(tmp_object == j) - 1;
                        coordObjectX = floor(coordObjectRaw/height) + 1;
                        coordObjectY = mod(coordObjectRaw,height) + 1;
                        tmpcorr = corrcoef([coordObjectX coordObjectY]);
        
                        areaScore = each_area(j);
                        intensityScore = mean(grayImg(tmp_object == j));
                        intensityScore = intensityScore^2;
                        degreeScore = sqrt(sqrt(abs(tmpcorr(1,2))));

                        scoreCandidate(j) = areaScore * intensityScore / degreeScore;
                        %fprintf('%d - area:%.3f\tinten:%.3f\tdegree:%.3f\ttotal:%.3f\n',j,areaScore,intensityScore,degreeScore,scoreCandidate(j));
                    end
                end

                % ������ �ĺ��� ������ ���� likelihood�� object�� Ž��
                candidates = find(scoreCandidate > 0);
                if ~isempty(candidates)

                    % ������ ���ϰ�
                    RealObject = candidates(scoreCandidate(candidates) == max(scoreCandidate(candidates)));
                    %fprintf('real:%d\n',realobject);

                    % �ε����� ã�� �� ������ ���� ����
                    isRealObject = zeros(height, width);
                    isRealObject(tmp_object == RealObject) = 1;
                    isRealObject = imdilate(isRealObject, strel('octagon',3));
                    isRealObject = bwfill(isRealObject, 'holes');
                    residue = zeros(size(object));
                    residue(rangeHeight, rangeWidth) = i * isRealObject;

                    % ����� �ݿ�
                    large_object(large_object == i) = residue(large_object == i);

                    %figure;
                    %subplot(1,5,1), image(Img); axis off;
                    %subplot(1,5,2), image(gee * 60); colormap('gray'); axis off;
                    %subplot(1,5,3), image(edgeimg * 60); axis off;
                    %subplot(1,5,4), image(gee2 * 20); axis off;
                    %subplot(1,5,5), image(isRealObject * 60); axis off;

                end
                
                if false
                    H = fspecial('unsharp',1);
                    grayimg = imfilter(grayimg,H,'replicate');
                    g_thresh = graythresh(grayimg);
                    black_white = im2bw(grayimg,g_thresh);
                    black_white = bwareaopen(black_white,30);
                    se = strel('disk',2);

                    black_white = imclose(black_white,se);
                    %black_white = edge(black_white,'sobel');
                    black_white = imfill(black_white,'holes');
                    black_white = imerode(black_white, se);
                    [B,L] = bwboundaries(black_white,'noholes');

                    %        figure;                                        %show boundary img
                    %        imshow(label2rgb(L, @jet, [.5 .5 .5]));hold on;
                    %          for k = 1:length(B)
                    %            boundary = [];boundary = B{k};
                    %            plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2);
                    %          end

                    stats = regionprops(L,'Area','Centroid');
                    threshold = 0.4;
                    pix_tmp = zeros(height, width);
                    % Detect object with fully preserved shape
                    for j = 1:length(B)
                        boundary = [];boundary = B{j};
                        delta_sq = diff(boundary).^2;
                        perimeter = sum(sqrt(sum(delta_sq,2)));
                        area = stats(j).Area;
                        metric = 4*pi*area/perimeter^2;metric_string = sprintf('%2.2f',metric);
                        centroid = stats(j).Centroid;
                    % img�� circular ���絵 ���
                    %             text(boundary(1,2),boundary(1,1),metric_string,'Color','y',...
                    %        'FontSize',14,'FontWeight','bold');
                        %Find the most round objects
                        % 900�ȼ� ������ ��� small chunk�� �����Ͽ� threshold �̻��̸� cell comet�� ����
                        % 900�ȼ� �̻��� ��� ���� ������ ����� boundary�� ����
                        if(j == 1)
                            if(area<=900)
                                if(metric>threshold&&metric<=1)
                                    pix_tmp(boundary(:,1),boundary(:,2)) = 1;
                                    temp_me = threshold;
                                    temp_idx = 1;
                                    temp_cent = centroid;
                                else
                                    temp_me = threshold;
                                    temp_idx = 1;
                                    temp_cent = centroid;
                                end
                            else
                                temp_me = metric;
                                temp_idx = 1;
                                temp_cent = centroid;
                            end
                        else
                            if(metric>temp_me&& area>900&&metric<=1)    
                                temp_me = metric;
                                temp_cent = centroid;
                                temp_idx = j;
                            elseif(metric>threshold&& area<=900&&metric<=1)   %900�ȼ� ���ϸ� small chunk�� ����
                                pix_tmp(boundary(:,1),boundary(:,2)) = 1;
                            end
                        end
                    end
                    B = B{temp_idx};

                    for j = 1:length(B(:,1))
                        pix_tmp(B(j,1),B(j,2)) = 1;
                    end
                    pix_tmp = imfill(pix_tmp, 'holes');

                    residue = zeros(size(object));
                    residue(rangeHeight, rangeWidth) = i*pix_tmp;
                    large_object(large_object == i) = residue(large_object == i);
                end

            end
            
        end
        
    end
    
    % large object�� ������ small object�� large object�� ����
    each_object = large_object;
    ismerged_object = zeros(size(object));
    if ( n1 > 0 )
        
        if ~exist('large_object_center', 'var')
            boxWidth = zeros(n1, 1);
            boxHeight = zeros(n1, 1);
            large_object_center = zeros(n1, 2);
            for i = 1:n1
                coordObjectRaw = find(large_object == i) - 1;
                coordObjectX = floor(coordObjectRaw/wholeheight) + 1;
                coordObjectY = mod(coordObjectRaw,wholeheight) + 1;
                boxWidth(i) = max(coordObjectX) - min(coordObjectX) + 1;
                boxHeight(i) = max(coordObjectX) - min(coordObjectX) + 1;
                large_object_center(i,:) = [ (max(coordObjectX) + min(coordObjectX)) / 2, ...
                                    (min(coordObjectY) + max(coordObjectY)) / 2 ];
            end
        end

        for i = 1:n2
            
            isObject = (small_object == i);
            coordObjectRaw = find(isObject) - 1;
            coordObjectX = floor(coordObjectRaw/wholeheight) + 1;
            coordObjectY = mod(coordObjectRaw,wholeheight) + 1;
            
            tmp_center = [ max(coordObjectX) + min(coordObjectX) , max(coordObjectY) + min(coordObjectY) ] / 2;
            tmp_dist = (large_object_center - repmat(tmp_center, n1, 1));

            % x�� ������ �տ� �ִ� large object �� ����
            tmp_dist(tmp_dist(:,1) < 0,1) = tmp_dist(tmp_dist(:,1) < 0,1) * 10;

            % y�� ������ �ָ� �ִ� large object �� ����
            tmp_dist(:,2) = tmp_dist(:,2) * 10;

            % i��° small object �� ��� large object ���� �Ÿ� ���
            tmp_dist = tmp_dist.^2;
            tmp_dist = sqrt(sum(tmp_dist, 2));

            % �� �� ���� ����� large object
            [min_dist, nearest_large_object] = min(tmp_dist);

            % �� large object ���� �Ÿ��� ���� �Ÿ� �ȿ� ������ �� ������
            if ( min_dist < 200 ) && ( min_dist < boxWidth(nearest_large_object) )
                each_object(isObject) = nearest_large_object;
                ismerged_object(isObject) = nearest_large_object;
                %fprintf('%d of small -> %d of large (%.3f, %.3f)\n', i, nearest_large_object, min_dist, boxwidth);
            end
            
        end
        
    end

end