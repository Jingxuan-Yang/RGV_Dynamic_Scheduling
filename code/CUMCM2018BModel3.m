%   脚本功能：
%   智能RGV动态调度（一道工序,1%概率机器故障）
%
%   具体描述：
%
%
%   嵌套函数：无
%
%   作者：罗彧宁
%
%   版本：1.0
%
%   上次修改时间：
%
%   上次修改历史：

%   初始化MATLAB
clear
clc

%   数据初始化
tm1 = 20;                       %   RGV移动1个单位时间
tm2 = 33;                       %   RGV移动2个单位时间
tm3 = 46;                       %   RGV移动3个单位时间
tcnc = 560;                     %   CNC加工完成一道工序时间
trwo = 28;                      %   RGV为奇数CNC上下料时间
trwe = 31;                      %   RGV为偶数CNC上下料时间
tclr = 25;                      %   RGV清洗熟料时间
Twork = 28800;                  %   总工作时间
CNCnum = 8;                     %   CNC机器数
t = 0;                          %   时间初始化
Pos = 1;                        %   位置初始化
CNCw = zeros(1, CNCnum);        %   CNC工作状态标志
Trgvm = zeros(1, CNCnum);       %   RGV移动时间矩阵
Trgvw = zeros(1, CNCnum);       %   RGV工作时间矩阵
Tcncw = zeros(1, CNCnum);       %   CNC工作时间矩阵
Ttotal = zeros(1, CNCnum);      %   总时间矩阵
paw = 0;                        %   机械爪上是否有熟料
Tclear = 100000;                %   清洗剩余时间
tmin = 10000;                   %   循环变量，表示当前步骤进行的最短时间
minPos = -1;                    %   循环变量，表示当前对哪台机器操作
count = zeros(1, CNCnum);       %   计算每台机器所上料的数目
starttime = zeros(100, CNCnum); %   每台机器上料所对应的时间
endtime = zeros(100, CNCnum);   %   每台机器下料对应时间
sortTtotal = zeros(1, CNCnum);  %   模拟退火算法所需的排序矩阵
sortix = zeros(1, CNCnum);      %   模拟退火算法所需的位置矩阵
rannum1 = 1;
rannum2 = 1;


while t < Twork
    %   根据RGV当前位置计算对应的RGV移动时间矩阵
    switch Pos
        case 1
            Trgvm(1) = 0;
          	Trgvm(2) = 0;
            Trgvm(3) = tm1;
           	Trgvm(4) = tm1;
         	Trgvm(5) = tm2;
           	Trgvm(6) = tm2;
          	Trgvm(7) = tm3;
           	Trgvm(8) = tm3;
       	case 2
           	Trgvm(1) = tm1;
           	Trgvm(2) = tm1;
         	Trgvm(3) = 0;
          	Trgvm(4) = 0;
           	Trgvm(5) = tm1;
          	Trgvm(6) = tm1;
           	Trgvm(7) = tm2;
           	Trgvm(8) = tm2;
        case 3
           	Trgvm(1) = tm2;
          	Trgvm(2) = tm2;
          	Trgvm(3) = tm1;
         	Trgvm(4) = tm1;
          	Trgvm(5) = 0;
           	Trgvm(6) = 0;
          	Trgvm(7) = tm1;
           	Trgvm(8) = tm1;
     	case 4
         	Trgvm(1) = tm3;
          	Trgvm(2) = tm3;
           	Trgvm(3) = tm2;
          	Trgvm(4) = tm2;
           	Trgvm(5) = tm1;
          	Trgvm(6) = tm1;
        	Trgvm(7) = 0;
           	Trgvm(8) = 0;
    end
    %   计算RGV工作时间矩阵
	Trgvw(1) = trwo;
	Trgvw(3) = trwo;
    Trgvw(5) = trwo;
	Trgvw(7) = trwo;
	Trgvw(2) = trwe;
	Trgvw(4) = trwe;
	Trgvw(6) = trwe;
	Trgvw(8) = trwe;
    %   计算总时间
    Ttotal = Trgvm + Trgvw + Tcncw;
    %   找出最短路径
    %   基于模拟退火算法生成最短路径位置
    rannum1 = rand(1);
    if rannum1 > 0
        [tmin, minPos] = min(Ttotal);
    else
        [sortTtotal, sortix] = sort(Ttotal);
        tmin = Ttotal(sortix(2));
        minPos = sortix(2);
    end
    %   若机械爪上有熟料，则与最短路径相比较
    if paw == 1
        Tclear = tclr;
    else
        Tclear = 100000;
    end
    %   若最短时间大于清洗时间，则先进行清洗
    if tmin > Tclear
        t = t + tclr;
        Tcncw(CNCw >= 1) = Tcncw(CNCw >= 1) - tclr;
        paw = paw - 1;
    %   若需要操作的设备不在当前位置，则移动
    elseif ceil(minPos/2) ~= Pos
        Pos = ceil(minPos/2);
        t = t + Trgvm(minPos);
        Tcncw(CNCw >= 1) = Tcncw(CNCw >= 1) - Trgvm(minPos);
    %   若需要操作的位置在当前设备
    else
        %   若当前设备未工作，进行上料操作并计数
        if CNCw(minPos) == 0
            t = t + Trgvw(minPos);
            Tcncw(CNCw >= 1) = Tcncw(CNCw >= 1) - Trgvw(minPos);
            Tcncw(Tcncw<0) = 0;

            rannum2 = rand(1);
            if rannum2 > 0.01
                Tcncw(minPos) = Tcncw(minPos) + tcnc;
                CNCw(minPos) = 1;
            else
                CNCw(minPos) = 2;
                Tcncw(minPos) = ceil(rand(1)*560+(10+1000*rannum2)*60);
            end
            count(minPos) = count(minPos) + 1;
            starttime(count(minPos), minPos) = t;
        %   若当前设备正在工作
        else
            %   若设备已工作完毕，进行下料操作并计数
            if Tcncw(minPos) == 0
                if CNCw(minPos) == 1
                    endtime(count(minPos), minPos) = t;
                    t = t + Trgvw(minPos);
                    paw = paw + 1;
                    Tcncw(CNCw >= 1) = Tcncw(CNCw >= 1) - Trgvw(minPos);
                    Tcncw(Tcncw<0) = 0;

                    rannum2 = rand(1);
                    if rannum2 > 0.01
                        Tcncw(minPos) = Tcncw(minPos) + tcnc;
                        CNCw(minPos) = 1;
                    else
                        CNCw(minPos) = 2;
                        Tcncw(minPos) = ceil(rand(1)*560+(10+1000*rannum2)*60);
                    end
                    count(minPos) = count(minPos) + 1;
                    starttime(count(minPos), minPos) = t;
                else
                    t = t + Trgvw(minPos);
                    Tcncw(CNCw >= 1) = Tcncw(CNCw >= 1) - Trgvw(minPos);
                    Tcncw(Tcncw<0) = 0;

                    rannum2 = rand(1);
                    if rannum2 > 0.01
                        Tcncw(minPos) = Tcncw(minPos) + tcnc;
                        CNCw(minPos) = 1;
                    else
                        CNCw(minPos) = 2;
                        Tcncw(minPos) = ceil(rand(1)*560+(10+1000*rannum2)*60);
                    end
                    count(minPos) = count(minPos) + 1;
                    starttime(count(minPos), minPos) = t;
                end
            %   若设备正在工作，等待
            else
                t = t + 1;
                Tcncw(CNCw >= 1) = Tcncw(CNCw >= 1) - 1;
            end
        end
    end
    %   去除小于0的数
    Tcncw(Tcncw<0) = 0;
end

