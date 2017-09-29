function [me, med] = getIntensityMean(in)

    grayimg = rgb2gray(in);
    grayimg1D = reshape(grayimg,1,[]);
    
    % grayimg �� median ���� background �� �����
    % (��κ��� ��� background �� �����ϴ� �ȼ� ���� �� �����Ƿ�)
    med = median(double(grayimg1D(grayimg1D>1)));
    %cnt = hist(grayimg1D,0:255); [~,med] = max(cnt); med = med - 1;
    
    % median ���� ū �ȼ�, �� signal ���� ���
    if med > 50
        me = mean(grayimg1D(grayimg1D>med));
    else
        me = mean(grayimg1D(grayimg1D>(4*med)));
    end
    
end