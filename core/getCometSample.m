function out = getCometSample(~)
    
    %이미지 흑백처리
    out{1} = rgb2gray(imread('classification/apop.png'));
    out{2} = rgb2gray(imread('classification/hedgehog.png'));
    out{3} = rgb2gray(imread('classification/necro.png'));
    out{4} = rgb2gray(imread('classification/control.png'));
    
    %tmp1 = getSignal(out{1});
    %tmp2 = getSignal(out{2});
    %tmp3 = getSignal(out{3});
    %tmp4 = getSignal(out{4});
    
%      figure;
%      subplot(2,2,1);imshow(out{1});
%      subplot(2,2,2);imshow(out{2});
%      subplot(2,2,3);imshow(out{3});
%      subplot(2,2,4);imshow(out{4});
end