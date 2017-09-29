function out = getCometInfo(rawdata, each_object, ismerged_object)

    [height, ~] = size(each_object);
    
    n = max(max(each_object, [], 1));
    
    out = cell(n, 1);

    circle = strel('ball',25,3).getnhood;
    
    template{1} = load('classification/apop2');
    template{2} = load('classification/apop3');
    template{3} = load('classification/normal');
    template{4} = load('classification/normal2');

    for i = 1:n

        isObject = (each_object == i);
        is_merge = (ismerged_object == i);
        coordObjectRaw = find(isObject) - 1;
        coordObjectX = floor(coordObjectRaw/height) + 1;
        coordObjectY = mod(coordObjectRaw,height) + 1;
        
        rangeWidth = min(coordObjectX) : max(coordObjectX);
        rangeHeight = min(coordObjectY) : max(coordObjectY);
        
        % box 안의 i번째 object만 취하기 위함 (다른 object가 i번째 box 안에 들어올 수 있음)
        isObjectInBox = repmat(uint8(isObject(rangeHeight, rangeWidth)), [1 1 3]);
        isSmallInBox = isObject(rangeHeight, rangeWidth);
        rawdataInBox = rawdata(rangeHeight, rangeWidth, :);
        smalldataInBox = is_merge(rangeHeight, rangeWidth, :);
        
        img = isObjectInBox .* rawdataInBox;
        s_img = isSmallInBox .* smalldataInBox;
        grayImg = rgb2gray(img);
        [sheight, swidth] = size(grayImg);
        
        out{i}.boxRatio = swidth / sheight;
        
        if out{i}.boxRatio > 1.1
            tmpwidth = floor(sheight*1.1);
            currentCircle = imresize(circle, 'OutputSize', [sheight, tmpwidth]);
            tmpcorr1 = corrcoef(double(grayImg(:,1:tmpwidth)), double(currentCircle));
            tmpcorr2 = corrcoef(double(grayImg(:,(end-tmpwidth+1):end)), double(currentCircle));
            out{i}.degreeCircle = max(tmpcorr1(1,2), tmpcorr2(1,2));
        else
            currentCircle = imresize(circle, 'OutputSize', size(grayImg));
            tmpcorr = corrcoef(double(grayImg), double(currentCircle));
            out{i}.degreeCircle = tmpcorr(1,2);
        end
        tmpcorr = corrcoef([coordObjectX coordObjectY]);
        out{i}.degreeNonCircle = sqrt(abs(tmpcorr(1,2)));
        out{i}.abnormalScore = out{i}.degreeNonCircle * out{i}.degreeNonCircle / out{i}.boxRatio / out{i}.degreeCircle;
        
        out{i}.tmp2 = sum(grayImg, 1);
        out{i}.tmp3 = sum( (grayImg>10), 1);
        
        centerRow = floor(sheight/2);
        centerRowRange = (centerRow-3) : (centerRow+3);
        centerColRange = 1 : swidth;%floor(swidth*0.4);
        centerImg = grayImg(centerRowRange,centerColRange);
        out{i}.tmp41 = sum(centerImg, 1);
        
        maxIntensity = max(reshape(grayImg(:,1:floor(swidth/2)),[],1));
        maxIntensityCoord = find(grayImg > (maxIntensity-6));
        maxIntensityCoord = maxIntensityCoord - 1;
        maxIntensityCoordX = floor(maxIntensityCoord / sheight) + 1;
        maxIntensityCoordY = mod(maxIntensityCoord, sheight) + 1;
        if length(maxIntensityCoord) > 1
            [~,ttmp5] = min( abs(maxIntensityCoordY - floor(sheight*0.5)) + abs(maxIntensityCoordX - floor(swidth*0.1)) );
            maxIntensityCoordX = maxIntensityCoordX(ttmp5);
            maxIntensityCoordY = maxIntensityCoordY(ttmp5);
        end
        out{i}.headX = maxIntensityCoordX;
        out{i}.headY = maxIntensityCoordY;
        
        centerRowRange = (maxIntensityCoordY-3) : (maxIntensityCoordY+3);
        centerRowRange(centerRowRange<1) = [];
        centerRowRange(centerRowRange>sheight) = [];
        centerRowImg = grayImg(centerRowRange,:);
        out{i}.centerRowVec = sum(centerRowImg, 1);
        centerColRange = (maxIntensityCoordX-1) : (maxIntensityCoordX+5);
        centerColRange(centerColRange<1) = [];
        centerColRange(centerColRange>swidth) = [];
        centerColImg = grayImg(:,centerColRange);
        out{i}.centerColVec = sum(centerColImg, 2)';
        
        
        %fprintf('%2d %.3f\n',i,out{i}.abnormalScore);
        
        
        
        
        
        %[out{i}.type, out{i}.tmp] = getType(grayImg, getCometSample);
        rowRange = 1:(sheight);
        colRange = 1:(swidth);
        for j = 1:length(template)
            template{j}.centerRowVec = sum(imresize(template{j}.centerRowImg, 'OutputSize', [7 swidth]), 1);
            template{j}.centerColVec = sum(imresize(template{j}.centerColImg, 'OutputSize', [sheight 7]), 2)';
        end
        
        %c = max(out{i}.centerRowVec);
        %[out{i}.centerRowVecPeak2,out{i}.centerRowVecPeak] = findpeaks(out{i}.centerRowVec, 'MinPeakDistance', floor(swidth*0.2), 'MinPeakHeight', c*0.8);
        centerColVecMaxIntensity = max(out{i}.centerColVec);
        [out{i}.centerColVecPeakIntensity, ...
         out{i}.centerColVecPeakLocation] = findpeaks(out{i}.centerColVec, ...
                                                    'MinPeakDistance', floor(sheight*0.2), ...
                                                    'MinPeakHeight', centerColVecMaxIntensity*0.8);
        
        out{i}.corrRowVec = -1 * ones(1, length(template));
        out{i}.corrColVec = -1 * ones(1, length(template));
        
        if out{i}.boxRatio < 0.85
            out{i}.type = 'fail';
        elseif out{i}.boxRatio < 1.3
            if out{i}.degreeCircle < 0.6
                out{i}.type = 'fail';
            else
                for j = 1:length(template)
                    tmpcorr = corrcoef(out{i}.centerRowVec(colRange), template{j}.centerRowVec(colRange)); out{i}.corrRowVec(j) = tmpcorr(1,2);
                    tmpcorr = corrcoef(out{i}.centerColVec(rowRange), template{j}.centerColVec(rowRange)); out{i}.corrColVec(j) = tmpcorr(1,2);
                    %[out{i}.corrRowVec(j),~,c,~] = dtw(template{j}.centerRowVec(colRange), out{i}.centerRowVec(colRange));
                    %[out{i}.corrColVec(j),~,c,~] = dtw(template{j}.centerColVec(rowRange), out{i}.centerColVec(rowRange));
                end

                [~, rowBestClass] = max(out{i}.corrRowVec);
                [~, colBestClass] = max(out{i}.corrColVec);
                
                [~, cen] = min(abs(out{i}.centerColVecPeakLocation - floor(swidth/2)));
                cen = out{i}.centerColVecPeakLocation(cen);
                a = floor(swidth/15);b = floor(swidth/9);
                peri1 = (cen-b):(cen-a);
                peri1(peri1<1) = [];
                peri2 = (cen+a):(cen+b);
                peri2(peri2>sheight) = [];
                nc1 = abs((out{i}.centerColVec(cen) - mean(out{i}.centerColVec(peri1))) / out{i}.centerColVec(cen));
                nc2 = abs((out{i}.centerColVec(cen) - mean(out{i}.centerColVec(peri2))) / out{i}.centerColVec(cen));
                nc = min(nc1, nc2);
                out{i}.peakHeight = nc;
                %fprintf('%d %.3f %.3f %.3f %.3f %.3f %.3f %.3f\n',i,nc,nc1,nc2,out{i}.corrColVec(1),out{i}.corrColVec(2),out{i}.corrColVec(3),out{i}.corrColVec(4));
                if ( colBestClass == 3 || colBestClass == 4 ) && ( out{i}.corrColVec(3) > 0.6 && out{i}.corrColVec(4) > 0.6 )
                    out{i}.type = 'normal';
                elseif ( nc > 0.12 ) && ( out{i}.corrColVec(1) > 0.88 || out{i}.corrColVec(2) > 0.88 )
                    %out{i}.type = 'apoptosis';
		    out{i}.type = 'normal';
                elseif nc < 0.12 || rowBestClass == 3 || rowBestClass == 4
                    out{i}.type = 'normal';
                elseif max(out{i}.corrColVec(1), out{i}.corrColVec(2)) > max(out{i}.corrColVec(3), out{i}.corrColVec(4))
                    %out{i}.type = 'apoptosis';
		    out{i}.type = 'normal';
                else
                    out{i}.type = 'normal';
                end
            end
        elseif out{i}.boxRatio < 4.5
            if out{i}.abnormalScore > 0.12
                out{i}.type = 'fail';
            else
                %out{i}.type = 'necrosis';
		out{i}.type = 'normal';
            end
        else
            out{i}.type = 'fail';
        end
        
        
        
        
        
        
        
        
        
        out{i}.img = img;
        out{i}.intensity = getIntensity(img);
        out{i}.circle = get3DProperty(img, out{i}.type);
        out{i}.property = getProperty(grayImg, out{i}.circle{1}, out{i}.circle{2}, out{i}.circle{3});
        out{i}.center = [ ( rangeHeight(1) + rangeHeight(end) ) / 2, ( rangeWidth(1) + rangeWidth(end) ) / 2 ];
        out{i}.position = [ rangeWidth(1), ...
                            rangeHeight(1), ...
                            ( rangeWidth(end) - rangeWidth(1) ), ...
                            ( rangeHeight(end) - rangeHeight(1) ) ];
        
        
    end

end