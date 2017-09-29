%m * n * 3 ����� �ҽ��� width, height ������ �޾Ƽ� �Ѱ��� output_arr�� ����� ���ִ� �Լ�
function Intensity_arr = getIntensity( img )

    %green�� intensity�� 10 �̻��̸� cell�� �Ը�
    grayimg = img(:,:,2);
    grayimg = double(grayimg) .* (grayimg>10);
    
    nums = sum((grayimg > 0), 1)';
    Intensity_arr = sum(grayimg, 1)';
    Intensity_arr(nums>0) = Intensity_arr(nums>0) ./ nums(nums>0);
    
%     md_int = medfilt1(Intensity_arr,5);
%     x = [1:width];
%     [pks,locs] = findpeaks(md_int, 'MINPEAKDISTANCE',floor(width*0.2),'NPEAKS',1 );
%     figure;
%     plot(x,md_int);hold on;
%     plot(x(locs),pks+0.05,'k^','markerfacecolor',[1 0 0]);
    Intensity_arr = Intensity_arr/1000;
    
end

