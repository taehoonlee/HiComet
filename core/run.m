function run(filename, outname)

foldername = '../input/';

%print('-dpng', '-r300', ['../output/' outname ' ' datestr(datevec(now),1) ' ' datestr(datevec(now),'HH-MM-SS') '.png']);

% parameters
opt.MedianFilter = true;
opt.MedianFilterSize = 5;

% 결과 화면 설정
showRuntime = false;
showFigProcess = false;
showFigSummary = false; saveFigSummary = false;
showFigEach = false;
showTable = false;
showHistogram = false;

% 이미지 불러오기
rawdata = imread([foldername filename]);
[height, width, ~] = size(rawdata);

aaa = fopen(['../output/' outname '.txt'], 'w');
if length(find(mean(mean(rawdata,1),2)>20)) > 1
    fprintf(aaa, '{filename:''fail'',reason:''The image is not a comet assay image''}');
    fclose(aaa);
    return;
end
% Pre-processing (적절한 밝기 변화)
[datafiltered, msg] = adjustImage(rawdata, opt); if ~isempty(msg), fprintf('%s : %s\n', filename, msg); end

% Clustering (신호픽셀(True)와 배경픽셀(False)의 분리)
[signals, msg1] = getSignal(datafiltered);

% Segmentation (인접픽셀들을 묶은 뒤 labeling)
object = bwlabel(signals, 8);

% Filtering objects (overlap 제거, small chunk 제거(또는 large chunk로 편입))
[each_object, large_object, ismerged_object] = adjustObject(datafiltered, object);
n = max(max(each_object,[],1));

% Profiling objects
cometinfo = getCometInfo(rawdata, each_object, ismerged_object);

t_data = zeros(n,7);
for i = 1:n
	for j = 1:7
		t_data(i,j) = cometinfo{i}.property{j+3};
	end
end

if 0

	for i = 1:n
        plot(cometinfo{i}.intensity);
        axis([0 cometinfo{i}.position(3) 0 max(cometinfo{i}.intensity)]);
	    print('-dpng', '-loose', '-r600', ['../output/' outname '-comet' num2str(i) '.png']);
    end
    
end



    colorType = containers.Map({'normal', 'apoptosis', 'necrosis', ...
                                'hedgehog', 'fail'}, ...
                               {[0 0.8 0.3], [0.8 0 0.6], [0.8 0.6 0], ...
                                [0.5 0 0.8], [0.7 0.7 0.7]});
    
    figure; image(rawdata); axis off; hold on;
    fprintf(aaa, '{filename:''%s'', width:%d, height:%d, scale:2, n:%d, cometinfo:[', outname, width, height, n);
    bbb = fopen(['../output/' outname '.csv'], 'w');
    fprintf(bbb, 'no, x, y, width, height, type, Head per DNA, Tail per DNA, Tail Extent Moment, Olive Tail Moment, Tail Inertia, Tail Length, Tail Distance\n');

    for i = 1:n
        
        text(cometinfo{i}.center(2)-20, cometinfo{i}.center(1), ...
            [ num2str(i) ], ...%'(' num2str(cometinfo{i}.objs) ')' ], ...
            'FontSize', 12, ...
            'Color', [1 1 1]);
        
        fprintf(aaa, '{x:%d, y:%d, w:%d, h:%d, type:''%s'', p1:%.3f, p2:%.3f, p3:%.3f, p4:%.3f, p5:%.3f, p6:%.3f, p7:%.3f},', cometinfo{i}.position(1), cometinfo{i}.position(2), cometinfo{i}.position(3), cometinfo{i}.position(4), cometinfo{i}.type, cometinfo{i}.property{4}, cometinfo{i}.property{5}, cometinfo{i}.property{6}, cometinfo{i}.property{7}, cometinfo{i}.property{8}, cometinfo{i}.property{9}, cometinfo{i}.property{10});
	fprintf(bbb, '%d, %d, %d, %d, %d, %s, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f, %.3f\n', i, cometinfo{i}.position(1), cometinfo{i}.position(2), cometinfo{i}.position(3), cometinfo{i}.position(4), cometinfo{i}.type, cometinfo{i}.property{4}, cometinfo{i}.property{5}, cometinfo{i}.property{6}, cometinfo{i}.property{7}, cometinfo{i}.property{8}, cometinfo{i}.property{9}, cometinfo{i}.property{10});
        
        if strcmp(cometinfo{i}.type, 'apop')
            plot(cometinfo{i}.position(1)+cometinfo{i}.circle{1,1}-1,...
                cometinfo{i}.position(2)+cometinfo{i}.circle{1,2}-1,...
                'ro','MarkerSize',8,'MarkerEdgeColor',colorType(cometinfo{i}.type));
        end
        
    end

    fprintf(aaa, '0]}');
    fclose(aaa);
    fclose(bbb);
    
    print('-dpng', '-loose', '-r600', ['../output/' outname '-1.png']);



if 1
    
    figure;
    subplot(2,3,1), image(rawdata); axis off;
    subplot(2,3,2), image(datafiltered); axis off;
    subplot(2,3,3), image(signals * 60); colormap(bone); axis off;
    subplot(2,3,4), image(object); title(max(max(object,[],1))); axis off;
    subplot(2,3,5), image(each_object * 2); title(n); axis off;
    subplot(2,3,6), image(each_object * 2); title(n); axis off;

	set(gcf,'PaperPositionMode','auto');
	set(gca, 'LooseInset', get(gca,'TightInset'));
    print('-dpng', '-r600', ['../output/' outname '-2.png']);
    
end



% 개별 그림 확인
if 1

    rootn = floor(sqrt(n))+1;
    figure;
    for i = 1:n
        subplot(rootn,rootn,i), image(cometinfo{i}.img); title(num2str(i)); axis off; axis equal;
    end
    figure;
    for i = 1:n
        subplot(rootn,rootn,i), plot(cometinfo{i}.intensity);
        axis([0 cometinfo{i}.position(3) 0 max(cometinfo{i}.intensity)]);
        title(num2str(i));
    end

    set(gcf,'PaperPositionMode','auto');
	set(gca, 'LooseInset', get(gca,'TightInset'));
    print('-dpng', '-r600', ['../output/' outname '-3.png']);

end



% 히스토그램 확인
if 1
    
    figure;
    subplot(3,1,1), hist(t_data(:,3));
    xlabel('Extent Tail Moment');
    ylabel('Frequency');
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r','EdgeColor','w');

    subplot(3,1,2), hist(t_data(:,4));
    xlabel('Olive Tail Moment');
    ylabel('Frequency');
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r','EdgeColor','w');

    subplot(3,1,3), hist(t_data(:,5));
    xlabel('Tail Inertia');
    ylabel('Frequency');
    h = findobj(gca,'Type','patch');
    set(h,'FaceColor','r','EdgeColor','w');

    print('-dpng', '-r600', ['../output/' outname '-4.png']);

end



% 표 확인
if 1
    
    %output{1:head ,2:tail,3,total , 4:Head%DNA, 5:Tail%DNA, 6: Tailmoment 7: Olive Tail 8: Tail length 9: Tail Migration 10 : Tail/Head}
    comet_property_names = {'Head%DNA','Tail%DNA','Tail Extent Moment','Olive_Tail Moment','Tail Length','Tail Migration','Tail/Head'};
    
    rootn = floor(sqrt(n))+1;
    figure;
    for i = 1:n
        subplot(rootn,rootn,i);
        plot(cometinfo{i}.property{3},'Color','k');
        hold on;
        plot(cometinfo{i}.property{1},'Color','r');
        hold on;
        plot(cometinfo{i}.property{2},'Color','b');
        axis([0 cometinfo{i}.position(3) 0 max(max(cometinfo{i}.property{1}),max(cometinfo{i}.property{2}))]);
        title(num2str(i));
    end

    figure;
    t = uitable(...
        'Data', t_data , ...
        'ColumnName', comet_property_names, ...
        'RowName', 1:n, ...
        'ColumnWidth', 'auto', ...
        'Position', [0 0 600 550]);

    print('-dpng', '-r300', ['../output/' outname '-5.png']);
    
end


