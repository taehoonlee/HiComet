function [me, med] = getIntensityMean(in)

    grayimg = rgb2gray(in);
    grayimg1D = reshape(grayimg,1,[]);
    
    % grayimg 의 median 값은 background 에 가까움
    % (대부분의 경우 background 가 차지하는 픽셀 수가 더 많으므로)
    med = median(double(grayimg1D(grayimg1D>1)));
    %cnt = hist(grayimg1D,0:255); [~,med] = max(cnt); med = med - 1;
    
    % median 보다 큰 픽셀, 즉 signal 들의 평균
    if med > 50
        me = mean(grayimg1D(grayimg1D>med));
    else
        me = mean(grayimg1D(grayimg1D>(4*med)));
    end
    
end