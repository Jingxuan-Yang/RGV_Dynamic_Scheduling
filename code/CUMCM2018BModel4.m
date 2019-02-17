%   脚本功能：
%   智能RGV动态调度（两道工序，1%机器故障）
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

%   MATLAB初始化
clear
clc

%   数据初始化
tm1 = 20;                       %   RGV移动1个单位时间
tm2 = 33;                       %   RGV移动2个单位时间
tm3 = 46;                       %   RGV移动3个单位时间
tcnc1 = 400;                    %   CNC完成第一道工序所需时间
tcnc2 = 378;                    %   CNC完成第二道工序所需时间
trwo = 28;                      %   RGV为奇数CNC上下料时间
trwe = 31;                      %   RGV为偶数CNC上下料时间
tclr = 25;                      %   RGV清洗熟料时间
Twork = 28800;                  %   总工作时间
CNCnum = 8;                     %   CNC机器数
t = 0;                          %   时间初始化
Pos = 1;                        %   位置初始化
CNCw = zeros(1, CNCnum);        %   CNC工作状态标志
Trgvm = zeros(1, CNCnum);      	%   RGV移动时间矩阵
Trgvw = zeros(1, CNCnum);       %   RGV工作时间矩阵
Tcncw = zeros(1, CNCnum);       %   CNC工作时间矩阵
Ttotal = zeros(1, CNCnum);      %   总时间矩阵
pawsecond = 0;                  %   需要进行第二道工序的物料
pawclear = 0;                   %   需要清洗的物料
Tclear = 100000;                %   清洗剩余时间
count1 = zeros(1, CNCnum);      %   计算每台机器第一道工序上料数目
count2 = zeros(1, CNCnum);      %   计算每台机器第二道工序上料数目
starttime1 = zeros(100, CNCnum);%   每台机器第一道工序上料所对应时间
starttime2 = zeros(100, CNCnum);%   每台机器第二道工序上料所对应时间
endtime1 = zeros(100, CNCnum);  %   每台机器第一道工序下料所对应时间
endtime2 = zeros(100, CNCnum);  %   每台机器第二道工序下料所对应时间
sortTtotal = zeros(1, CNCnum);  %   模拟退火算法所需的排序矩阵
sortix = zeros(1, CNCnum);      %   模拟退火算法所需的位置矩阵
rannum1 = 1;
rannum2 = 1;

while t < Twork
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
    Trgvw(1) = trwo;
	Trgvw(3) = trwo;
    Trgvw(5) = trwo;
	Trgvw(7) = trwo;
	Trgvw(2) = trwe;
	Trgvw(4) = trwe;
	Trgvw(6) = trwe;
	Trgvw(8) = trwe;
    if pawsecond == 0
        Trgvw(2) = Trgvw(2) + 100000;
        Trgvw(4) = Trgvw(4) + 100000;
        Trgvw(6) = Trgvw(6) + 100000;
        Trgvw(8) = Trgvw(8) + 100000;
    else
        Trgvw(1) = Trgvw(1) + 100000;
        Trgvw(3) = Trgvw(3) + 100000;
        Trgvw(5) = Trgvw(5) + 100000;
        Trgvw(7) = Trgvw(7) + 100000;
    end
    Ttotal = Trgvm + Trgvw + Tcncw;
    rannum1 = rand(1);
    if rannum1 > 0
        [tmin, minPos] = min(Ttotal);
    else
        [sortTtotal, sortix] = sort(Ttotal);
        tmin = Ttotal(sortix(2));
        minPos = sortix(2);
    end
    if pawclear > 0
        Tclear = tclr;
    else
        Tclear = 100000;
    end
    if tmin > Tclear
        t = t + tclr;
        Tcncw(CNCw >= 1) = Tcncw(CNCw >= 1) - tclr;
        pawclear = pawclear - 1;
    elseif ceil(minPos/2) ~= Pos
        Pos = ceil(minPos/2);
        t = t + Trgvm(minPos);
        Tcncw(CNCw >= 1) = Tcncw(CNCw >= 1) - Trgvm(minPos);
    else
        switch minPos
            case {1, 3, 5, 7}
                if CNCw(minPos) == 0
                    t = t + Trgvw(minPos);
                    Tcncw(CNCw >= 1) = Tcncw(CNCw >= 1) - Trgvw(minPos);
                    Tcncw(Tcncw<0) = 0;

                    rannum2 = rand(1);
                    if rannum2 > 0.01
                        Tcncw(minPos) = Tcncw(minPos) + tcnc1;
                        CNCw(minPos) = 1;
                    else
                        CNCw(minPos) = 2;
                        Tcncw(minPos) = ceil(rand(1)*560+(10+1000*rannum2)*60);
                    end
                    count1(minPos) = count1(minPos) + 1;
                    starttime1(count1(minPos), minPos) = t;
                else
                    if Tcncw(minPos) == 0
                        if CNCw(minPos) == 1
                            endtime1(count1(minPos), minPos) = t;
                            t = t + Trgvw(minPos);
                            pawsecond = pawsecond + 1;
                            Tcncw(CNCw >= 1) = Tcncw(CNCw >= 1) - Trgvw(minPos);
                            Tcncw(Tcncw<0) = 0;

                            rannum2 = rand(1);
                            if rannum2 > 0.01
                                Tcncw(minPos) = Tcncw(minPos) + tcnc1;
                                CNCw(minPos) = 1;
                            else
                                CNCw(minPos) = 2;
                                Tcncw(minPos) = ceil(rand(1)*560+(10+1000*rannum2)*60);
                            end
                            count1(minPos) = count1(minPos) + 1;
                            starttime1(count1(minPos), minPos) = t;
                        else
                            t = t + Trgvw(minPos);
                            Tcncw(CNCw >= 1) = Tcncw(CNCw >= 1) - Trgvw(minPos);
                            Tcncw(Tcncw<0) = 0;

                            rannum2 = rand(1);
                            if rannum2 > 0.01
                                Tcncw(minPos) = Tcncw(minPos) + tcnc1;
                                CNCw(minPos) = 1;
                            else
                                CNCw(minPos) = 2;
                                Tcncw(minPos) = ceil(rand(1)*560+(10+1000*rannum2)*60);
                            end
                            count1(minPos) = count1(minPos) + 1;
                            starttime1(count1(minPos), minPos) = t;
                        end

                    else
                        t = t + 1;
                        Tcncw(CNCw >= 1) = Tcncw(CNCw >= 1) - 1;
                    end
                end
            case {2, 4, 6, 8}
                if CNCw(minPos) == 0
                    t = t + Trgvw(minPos);
                    Tcncw(CNCw >= 1) = Tcncw(CNCw >= 1) - Trgvw(minPos);
                    Tcncw(Tcncw<0) = 0;

                    rannum2 = rand(1);
                    if rannum2 > 0.01
                        Tcncw(minPos) = Tcncw(minPos) + tcnc2;
                        CNCw(minPos) = 1;
                    else
                        CNCw(minPos) = 2;
                        Tcncw(minPos) = ceil(rand(1)*560+(10+1000*rannum2)*60);
                    end
                    count2(minPos) = count2(minPos) + 1;
                    starttime2(count2(minPos), minPos) = t;
                    pawsecond = pawsecond - 1;
                else
                    if Tcncw(minPos) == 0
                        if CNCw(minPos) == 1
                            endtime2(count2(minPos), minPos) = t;
                            t = t + Trgvw(minPos);
                            pawclear = pawclear + 1;
                            Tcncw(CNCw >= 1) = Tcncw(CNCw >= 1) - Trgvw(minPos);
                            Tcncw(Tcncw<0) = 0;

                            rannum2 = rand(1);
                            if rannum2 > 0.01
                                Tcncw(minPos) = Tcncw(minPos) + tcnc2;
                                CNCw(minPos) = 1;
                            else
                                CNCw(minPos) = 2;
                                Tcncw(minPos) = ceil(rand(1)*560+(10+1000*rannum2)*60);
                            end
                            count2(minPos) = count2(minPos) + 1;
                            starttime2(count2(minPos), minPos) = t;
                            pawsecond = pawsecond - 1;
                        else
                            t = t + Trgvw(minPos);
                            Tcncw(CNCw >= 1) = Tcncw(CNCw >= 1) - Trgvw(minPos);
                            Tcncw(Tcncw<0) = 0;

                            rannum2 = rand(1);
                            if rannum2 > 0.01
                                Tcncw(minPos) = Tcncw(minPos) + tcnc2;
                                CNCw(minPos) = 1;
                            else
                                CNCw(minPos) = 2;
                                Tcncw(minPos) = ceil(rand(1)*560+(10+1000*rannum2)*60);
                            end
                            count2(minPos) = count2(minPos) + 1;
                            starttime2(count2(minPos), minPos) = t;
                            pawsecond = pawsecond - 1;
                        end
                    else
                        t = t + 1;
                        Tcncw(CNCw >= 1) = Tcncw(CNCw >= 1) - 1;
                    end
                end
        end
    end
    Tcncw(Tcncw<0) = 0;
end




