%m * n * 3 행렬의 소스와 width, height 정보를 받아서 한개의 output_arr로 출력을 해주는 함수
%Head%DNA = (Head.OptInten/(Head.OptInten + Tail.OptInten))*100
%Tail%DNA = 100 - Head%DNA
%Tail Length
%Tail/Head = Tail Length/Head Length
%Olive Tail Moment = (Tail.mean - Head.mean)*Tail%DNA/100
%Extent Tail Moment = Tail Length *Tail%DNA/100

function [outputs] = getProperty(grayimg, head_cent, hei_cent, circle_rad)
       
       [height, width, ~] = size(grayimg);
       Intensity_head_avg   = zeros(1, width);
       Intensity_tail_avg   = zeros(1, width);
   
       %average intensity
       grayimg = double(grayimg);
       nums = sum((grayimg > 0), 1);
       Intensity_total_avg = sum(grayimg, 1);
       Intensity_total_avg(nums>0) = Intensity_total_avg(nums>0) ./ nums(nums>0);
       
       
     
      
       %3Dproperty에서 가지고 온 중심점, radius를 저장
       % 즉 head의 중심좌표는 head_cent이다.
       
       rad = floor(circle_rad);
       head_start = head_cent - rad;
       head_end = head_cent+rad;
       if (head_end>width) 
           head_end = width;
           rad = floor((head_end-head_start+1)/2);
           head_cent = head_start+rad;
       end
       
       %Comet parameter
       comet_Length = width;
       X_MAX = width;
       comet_Height = height;
       Intensity_total = sum(grayimg, 1); %total
      
       cometArea = sum(nums);
       TotalcometIntensity = sum(Intensity_total);
       
       %Head
       Head_Diameter =  head_end-head_start+1;
       
       %Head Area
       HA_buff = zeros(height,width);
       HA_buff(hei_cent,head_cent) = 1;
       D = double(bwdist(HA_buff));
       HeadArea = ((D<rad).*grayimg)>0;
       Intensity_head = sum(HeadArea.*grayimg,1);
       TotalHeadIntensity = sum(Intensity_head);
       nums = sum((HeadArea > 0), 1);
       nu_HeadArea = sum(nums);
       Intensity_head_avg(nums>0) = Intensity_head(nums>0) ./ nums(nums>0);
     
       %Tail
       %TailArea = zeros(height,width);
       TailArea = ~HeadArea;
       TailArea(:,1:head_cent-1) = 0;
       TailArea=((TailArea.*grayimg)>0);
       Intensity_tail = sum(TailArea.*grayimg,1);
       TotalTailIntensity = sum(Intensity_tail);
       nums = sum((TailArea > 0), 1);
       nu_TailArea = sum(nums);
       Intensity_tail_avg(nums>0) = Intensity_tail(nums>0) ./ nums(nums>0);
       
      
       %Tail_mean = zeros(1,width-head_end+1);        
       Tail_mean = Intensity_tail(head_cent:X_MAX);
       
       
       %Head/DNA, Tail/DNA
       Head_PerDNA = (TotalHeadIntensity / (TotalHeadIntensity+TotalTailIntensity));
       Tail_PerDNA = 1 - Head_PerDNA;
       
       %Max_Intensity
       Max_Intensity = grayimg(hei_cent,head_cent);
       
       %tail_length
       if Head_PerDNA == 1
           Tail_length = 0;
       else
           Tail_length = X_MAX - head_end;
       end
       

       %Tail/Head
       %TperH = Tail_length/Head_Diameter;
       
       %Tail(Olive) Moment = (Tail.mean - Head.mean)*Tail%DNA/100
       if Tail_length == 0
           OTail = 0;
           Tail_Distance = 0;
       else
            centofTail = 0;
            distx = 1:X_MAX-head_cent+1;
            buff = Tail_mean .* distx;
            centofTail = sum(buff)/sum(Tail_mean);
            Tail_Distance = floor(centofTail);
            OTail = (Tail_Distance) * Tail_PerDNA;
       end
       Tail_Moment = Tail_length * Tail_PerDNA;
       
     
       %Extent Tail Moment = Tail Length *Tail%DNA
       %Tail inertia
       DTL = zeros(1, X_MAX);
       DTL(head_cent:X_MAX) = [head_cent:X_MAX];
       arr_cph = zeros(1,X_MAX);
       arr_cph(head_cent:X_MAX) = head_cent;
       DTL = DTL-arr_cph;
       DTL = DTL.*DTL;
       DTL = repmat(DTL, height, 1);
       inertia = DTL.*(TailArea.*grayimg);
       Tail_inertia = (sum(sum(inertia))/(TotalHeadIntensity+TotalTailIntensity))*100;
       
       totalbuff = zeros(1, width);
       totalbuff(1:head_start) = Intensity_total_avg(1:head_start);


        Intensity_head = medfilt1(Intensity_head,5);
         Intensity_tail = medfilt1(Intensity_tail,5);
          Intensity_total = medfilt1(Intensity_total,5);
       
       outputs = { ...
           Intensity_head / 1000, ... % 1. head
           Intensity_tail / 1000, ... % 2. tail
           Intensity_total/ 1000, ... % 3. output_total
           Head_PerDNA*100, ... % 4. head%DNA
           Tail_PerDNA*100, ... % 5. tail%DNA
           Tail_Moment, ... % 6.Extent tail moment
           OTail, ... % 7. Olive tail moment
           Tail_inertia, ...        %8 Tail_inertia
           Tail_length, ... % 9. tail length
           Tail_Distance, ... % 10. tail Distance   
           nu_TailArea, ...            %11 Tail Area
           head_cent, ... %12. center of head
           rad, ...        %13. radius of head
           Head_Diameter, ...    %14 Head_Diameter
           nu_HeadArea, ...            %15 Head Area
           X_MAX, ...            %16 comet_width
           height, ...      %17 comet_height
           comet_Length, ...        %18 comet_length
           comet_Height, ...        %19 comet_height
           cometArea, ...           %20 comet Area 
           TotalcometIntensity, ... %21 total comet inensity          
           TotalHeadIntensity, ... %22 total head intensity
           TotalTailIntensity, ... %23 total tail intensity
        };
       
end



% update note 20130109
% delete type
% delete tail migration
% add tail Distance
% add tail inertia
% add Head_Diameter
% add comet_length
% add comet_height
% add comet Area
% add Head Area
% add Tail Area