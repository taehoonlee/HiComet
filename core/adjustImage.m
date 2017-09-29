function [out, msg] = adjustImage(in, opt)

    [height, width, ~] = size(in);
    
    out = in;
    msg = [];
    
    % 하얀색은 버림 (scale bar 때문에)
    tmp2 = find(rgb2gray(in) > 200);
    tmph = mod(tmp2, height) + 1;
    tmpw = floor(tmp2 / height) + 1;
    tmp2(~(tmph > height*0.75 & tmpw > width*0.55)) = [];
    out(tmp2) = 0; out(tmp2 + width*height) = 0; out(tmp2 + 2*width*height) = 0;

    if opt.MedianFilter
        %fil = vision.MedianFilter([opt.MedianFilterSize opt.MedianFilterSize]);
        %out(:,:,1) = step(fil, out(:,:,1));
        %out(:,:,2) = step(fil, out(:,:,2));
        %out(:,:,3) = step(fil, out(:,:,3));
        out(:,:,1) = medfilt2(out(:,:,1), [opt.MedianFilterSize opt.MedianFilterSize]);
        out(:,:,2) = medfilt2(out(:,:,2), [opt.MedianFilterSize opt.MedianFilterSize]);
        out(:,:,3) = medfilt2(out(:,:,3), [opt.MedianFilterSize opt.MedianFilterSize]);
    end
    
end