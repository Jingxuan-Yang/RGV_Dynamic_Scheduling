%   脚本功能：
%   智能RGV动态调度（两道工序，不考虑机器故障）
%
%   具体描述：
%   RGV动态调度的第二个模型主要用于解决不考虑机器故障情况下的两道工序物料作业
%   加工情况。该模型基于贪婪法在每次RGV要执行下一动作时求得对每个设备执行的
%   时间长短并以此来作出选择。由于不同的CNC分成了两组，因此通过更改总时间矩阵
%   某些项的大小可以达到先进行第一道工序再进行第二道工序的效果。根据第一道工序
%   和第二道工序加工所需时间长短可对8台机器进行智能分组，选择最优分组。分组
%   完毕后，根据对总时间矩阵某些项在不同情况下的修改，根据RGV是否需要移动，
%   是否需要立即操作，是否需要等待来对时间进行推移，直到8小时结束时循环结束，
%   结束时需人工对最后几项加工不完的物料进行处理。
%
%   嵌套函数：无
%
%   作者：罗彧宁
%
%   版本：1.1
%
%   上次修改时间：2018.9.16
%
%   上次修改历史：增加注释和具体描述

%   MATLAB初始化
clear
clc

%   由于第二个模型加工物料需要两道工序，因此需要考虑CNC如何进行分组，每组
%   分配多少个CNC的问题。在这里先进行按照（4,4）、（3,5）、（5,3）的分组结构
%   进行循环遍历，发现（4,4）分组的某一种方式得到的物料最多，因此给出（4,4）
%   分组如何遍历，以及遍历完毕后输出最优解。而（3,5）分组和（5,3）分组遍历
%   在程序结束后的注释给出。

%   通过计算得到，第一道工序CNC序号为1,3,5,7；第二道工序CNC序号为2,4,6，8
%   （最优解不唯一）

%   数据初始化
load('firstgroup4.mat');
all = [1, 2, 3, 4, 5, 6, 7, 8];
groupcount = zeros(70, 1);
secondgroup = zeros(70, 4);

%   对（4,4）分组的每种情况进行遍历
for divgroup = 1: 70
    %   得到第二道工序的CNC序号
    secondgroup(divgroup,:) = setdiff(all, firstgroup(divgroup,:));
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
    
    %   总时间不超过8小时
    while t < Twork
        %   根据RGV所在位置计算RGV移动时间矩阵
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
        %   根据RGV要对设备进行的操作计算RGV工作时间矩阵
        Trgvw(1) = trwo;
        Trgvw(3) = trwo;
        Trgvw(5) = trwo;
        Trgvw(7) = trwo;
        Trgvw(2) = trwe;
        Trgvw(4) = trwe;
        Trgvw(6) = trwe;
        Trgvw(8) = trwe;
        %   若暂时没有第一道工序加工完成的半成品，则第二道工序对应机器暂停
        if pawsecond == 0
            Trgvw(secondgroup(divgroup, 1)) = ...
                Trgvw(secondgroup(divgroup, 1)) + 100000;
            Trgvw(secondgroup(divgroup, 2)) = ...
                Trgvw(secondgroup(divgroup, 2)) + 100000;
            Trgvw(secondgroup(divgroup, 3)) = ...
                Trgvw(secondgroup(divgroup, 3)) + 100000;
            Trgvw(secondgroup(divgroup, 4)) = ...
                Trgvw(secondgroup(divgroup, 4)) + 100000;
        else
            Trgvw(firstgroup(divgroup, 1)) = ...
                Trgvw(firstgroup(divgroup, 1)) + 100000;
            Trgvw(firstgroup(divgroup, 2)) = ...
                Trgvw(firstgroup(divgroup, 2)) + 100000;
            Trgvw(firstgroup(divgroup, 3)) = ...
                Trgvw(firstgroup(divgroup, 3)) + 100000;
            Trgvw(firstgroup(divgroup, 4)) = ...
                Trgvw(firstgroup(divgroup, 4)) + 100000;
        end
        %   计算总时间矩阵
        Ttotal = Trgvm + Trgvw + Tcncw;
        %   计算下一步最短时间及路径
        [tmin, minPos] = min(Ttotal);
        %   若机械爪上有待清洗的熟料，计算清洗时间
        if pawclear > 0
            Tclear = tclr;
        else
            Tclear = 100000;
        end
        %   若下一步最短路径所对应时间大于清洗时间，先进行清洗操作
        if tmin > Tclear
            t = t + tclr;
            Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - tclr;
            pawclear = pawclear - 1;
        %   若下一步要操作的对象不在此处，则移动RGV
        elseif ceil(minPos/2) ~= Pos
            Pos = ceil(minPos/2);
            t = t + Trgvm(minPos);
            Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvm(minPos);
        %   若下一步要操作的对向在此处
        else
            switch minPos
                %   若操作对象为第一道工序CNC
                case {firstgroup(divgroup, 1), firstgroup(divgroup, 2), ...
                        firstgroup(divgroup, 3), firstgroup(divgroup, 4)}
                    %   若操作对象未开始工作，进行上料处理并计数
                    if CNCw(minPos) == 0
                        t = t + Trgvw(minPos);
                        Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
                        Tcncw(Tcncw<0) = 0;
                        Tcncw(minPos) = Tcncw(minPos) + tcnc1;
                        CNCw(minPos) = 1;
                        count1(minPos) = count1(minPos) + 1;
                        starttime1(count1(minPos), minPos) = t;
                    %   若操作对象的工作状态标记为1
                    else
                        %   若操作对象已工作完毕，则先下料再上料并计数
                        if Tcncw(minPos) == 0
                            endtime1(count1(minPos), minPos) = t;
                            t = t + Trgvw(minPos);
                            pawsecond = pawsecond + 1;
                            Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
                            Tcncw(Tcncw<0) = 0;
                            Tcncw(minPos) = Tcncw(minPos) + tcnc1;
                            CNCw(minPos) = 1;
                            count1(minPos) = count1(minPos) + 1;
                            starttime1(count1(minPos), minPos) = t;
                        %   若操作对象未工作完毕，则等待
                        else
                            t = t + 1;
                            Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - 1;
                        end
                    end
                %   若操作对象为第二道工序CNC
                case {secondgroup(divgroup, 1), secondgroup(divgroup, 2), ...
                        secondgroup(divgroup, 3), secondgroup(divgroup, 4)}
                    %   若操作对象未开始工作，上料并计数
                    if CNCw(minPos) == 0
                        t = t + Trgvw(minPos);
                        Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
                        Tcncw(Tcncw<0) = 0;
                        Tcncw(minPos) = Tcncw(minPos) + tcnc2;
                        CNCw(minPos) = 1;
                        count2(minPos) = count2(minPos) + 1;
                        starttime2(count2(minPos), minPos) = t;
                        pawsecond = pawsecond - 1;
                    %   若操作对象工作状态标记为1
                    else
                        %   若操作对象已工作完毕，则先下料再上料并计数
                        if Tcncw(minPos) == 0
                            endtime2(count2(minPos), minPos) = t;
                            t = t + Trgvw(minPos);
                            pawclear = pawclear + 1;
                            Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
                            Tcncw(Tcncw<0) = 0;
                            Tcncw(minPos) = Tcncw(minPos) + tcnc2;
                            CNCw(minPos) = 1;
                            count2(minPos) = count2(minPos) + 1;
                            starttime2(count2(minPos), minPos) = t;
                            pawsecond = pawsecond - 1;
                        %   若操作对象未工作完毕，则等待
                        else
                            t = t + 1;
                            Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - 1;
                        end
                    end
            end
        end
        Tcncw(Tcncw<0) = 0;
    end
    %   计算每种情况所生产的物料数
    logiccount = endtime2 > 0;
    groupcount(divgroup) = sum(logiccount(:));
end

%   找出能生产出最大物料的组合方式
[Totalcount, divgroup] = max(groupcount);
%   重新计算每个物料的第一道和第二道工序的上料和下料时间
%   得到第二道工序的CNC序号
secondgroup(divgroup,:) = setdiff(all, firstgroup(divgroup,:));
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

%   总时间不超过8小时
while t < Twork
    %   根据RGV所在位置计算RGV移动时间矩阵
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
    %   根据RGV要对设备进行的操作计算RGV工作时间矩阵
    Trgvw(1) = trwo;
    Trgvw(3) = trwo;
    Trgvw(5) = trwo;
    Trgvw(7) = trwo;
    Trgvw(2) = trwe;
    Trgvw(4) = trwe;
    Trgvw(6) = trwe;
    Trgvw(8) = trwe;
    %   若暂时没有第一道工序加工完成的半成品，则第二道工序对应机器暂停
    if pawsecond == 0
        Trgvw(secondgroup(divgroup, 1)) = Trgvw(secondgroup(divgroup, 1)) + 100000;
        Trgvw(secondgroup(divgroup, 2)) = Trgvw(secondgroup(divgroup, 2)) + 100000;
        Trgvw(secondgroup(divgroup, 3)) = Trgvw(secondgroup(divgroup, 3)) + 100000;
        Trgvw(secondgroup(divgroup, 4)) = Trgvw(secondgroup(divgroup, 4)) + 100000;
    else
        Trgvw(firstgroup(divgroup, 1)) = Trgvw(firstgroup(divgroup, 1)) + 100000;
        Trgvw(firstgroup(divgroup, 2)) = Trgvw(firstgroup(divgroup, 2)) + 100000;
        Trgvw(firstgroup(divgroup, 3)) = Trgvw(firstgroup(divgroup, 3)) + 100000;
        Trgvw(firstgroup(divgroup, 4)) = Trgvw(firstgroup(divgroup, 4)) + 100000;
    end
    %   计算总时间矩阵
    Ttotal = Trgvm + Trgvw + Tcncw;
    %   计算下一步最短时间及路径
    [tmin, minPos] = min(Ttotal);
    %   若机械爪上有待清洗的熟料，计算清洗时间
    if pawclear > 0
        Tclear = tclr;
    else
        Tclear = 100000;
    end
    %   若下一步最短路径所对应时间大于清洗时间，先进行清洗操作
    if tmin > Tclear
        t = t + tclr;
        Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - tclr;
        pawclear = pawclear - 1;
    %   若下一步要操作的对象不在此处，则移动RGV
    elseif ceil(minPos/2) ~= Pos
        Pos = ceil(minPos/2);
        t = t + Trgvm(minPos);
        Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvm(minPos);
    %   若下一步要操作的对向在此处
    else
        switch minPos
            %   若操作对象为第一道工序CNC
            case {firstgroup(divgroup, 1), firstgroup(divgroup, 2), ...
                    firstgroup(divgroup, 3), firstgroup(divgroup, 4)}
                %   若操作对象未开始工作，进行上料处理并计数
                if CNCw(minPos) == 0
                    t = t + Trgvw(minPos);
                    Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
                    Tcncw(Tcncw<0) = 0;
                    Tcncw(minPos) = Tcncw(minPos) + tcnc1;
                    CNCw(minPos) = 1;
                    count1(minPos) = count1(minPos) + 1;
                    starttime1(count1(minPos), minPos) = t;
                %   若操作对象的工作状态标记为1
                else
                    %   若操作对象已工作完毕，则先下料再上料并计数
                    if Tcncw(minPos) == 0
                        endtime1(count1(minPos), minPos) = t;
                        t = t + Trgvw(minPos);
                        pawsecond = pawsecond + 1;
                        Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
                        Tcncw(Tcncw<0) = 0;
                        Tcncw(minPos) = Tcncw(minPos) + tcnc1;
                        CNCw(minPos) = 1;
                        count1(minPos) = count1(minPos) + 1;
                        starttime1(count1(minPos), minPos) = t;
                    %   若操作对象未工作完毕，则等待
                    else
                        t = t + 1;
                        Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - 1;
                    end
                end
            %   若操作对象为第二道工序CNC
            case {secondgroup(divgroup, 1), secondgroup(divgroup, 2), ...
                    secondgroup(divgroup, 3), secondgroup(divgroup, 4)}
                %   若操作对象未开始工作，上料并计数
                if CNCw(minPos) == 0
                    t = t + Trgvw(minPos);
                    Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
                    Tcncw(Tcncw<0) = 0;
                    Tcncw(minPos) = Tcncw(minPos) + tcnc2;
                    CNCw(minPos) = 1;
                    count2(minPos) = count2(minPos) + 1;
                    starttime2(count2(minPos), minPos) = t;
                    pawsecond = pawsecond - 1;
                %   若操作对象工作状态标记为1
                else
                    %   若操作对象已工作完毕，则先下料再上料并计数
                    if Tcncw(minPos) == 0
                        endtime2(count2(minPos), minPos) = t;
                        t = t + Trgvw(minPos);
                        pawclear = pawclear + 1;
                        Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
                        Tcncw(Tcncw<0) = 0;
                        Tcncw(minPos) = Tcncw(minPos) + tcnc2;
                        CNCw(minPos) = 1;
                        count2(minPos) = count2(minPos) + 1;
                        starttime2(count2(minPos), minPos) = t;
                        pawsecond = pawsecond - 1;
                    %   若操作对象未工作完毕，则等待
                    else
                        t = t + 1;
                        Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - 1;
                    end
                end
        end
    end
    Tcncw(Tcncw<0) = 0;
end    

%   数据输出

%   由于最后快接近八小时的时候需要停止某些机器和RGV的上下料操作以保证能在八小时
%   内进行设备停止并回到初始位置，因此程序计算结果需经进一步人工处理才能得到
%   真正的值，所以程序生成的数据和导入Excel表格中的数据会有微小误差

%   判断每个产出物料是否有效
logiccount = endtime2 > 0;
%   输出每个物料上料时间，其中矩阵的行为不同的物料，列为在哪个CNC机器上
%   分第一道工序和第二道工序
starttime1
starttime2
%   输出每个物料下料时间，其中矩阵的行为不同的物料。列为在哪个机器上
%   分第一道工序和第二道工序
endtime1
endtime2
%   输出总产量
TotalProduct = sum(logiccount(:))





% %   若为（3,5）分组，遍历代码
% %   MATLAB初始化
% clear
% clc
% 
% %   数据初始化
% load('firstgroup3.mat');
% all = [1, 2, 3, 4, 5, 6, 7, 8];
% groupcount = zeros(70, 1);
% secondgroup = zeros(70, 5);
% 
% 
% for divgroup = 1: 56
%     secondgroup(divgroup,:) = setdiff(all, firstgroup3(divgroup,:));
%     tm1 = 20;                       %   RGV移动1个单位时间
%     tm2 = 33;                       %   RGV移动2个单位时间
%     tm3 = 46;                       %   RGV移动3个单位时间
%     tcnc1 = 400;                    %   CNC完成第一道工序所需时间
%     tcnc2 = 378;                    %   CNC完成第二道工序所需时间
%     trwo = 28;                      %   RGV为奇数CNC上下料时间
%     trwe = 31;                      %   RGV为偶数CNC上下料时间
%     tclr = 25;                      %   RGV清洗熟料时间
%     Twork = 28800;                  %   总工作时间
%     CNCnum = 8;                     %   CNC机器数
%     t = 0;                          %   时间初始化
%     Pos = 1;                        %   位置初始化
%     CNCw = zeros(1, CNCnum);        %   CNC工作状态标志
%     Trgvm = zeros(1, CNCnum);      	%   RGV移动时间矩阵
%     Trgvw = zeros(1, CNCnum);       %   RGV工作时间矩阵
%     Tcncw = zeros(1, CNCnum);       %   CNC工作时间矩阵
%     Ttotal = zeros(1, CNCnum);      %   总时间矩阵
%     pawsecond = 0;                  %   需要进行第二道工序的物料
%     pawclear = 0;                   %   需要清洗的物料
%     Tclear = 100000;                %   清洗剩余时间
%     count1 = zeros(1, CNCnum);      %   计算每台机器第一道工序上料数目
%     count2 = zeros(1, CNCnum);      %   计算每台机器第二道工序上料数目
%     starttime1 = zeros(100, CNCnum);%   每台机器第一道工序上料所对应时间
%     starttime2 = zeros(100, CNCnum);%   每台机器第二道工序上料所对应时间
%     endtime1 = zeros(100, CNCnum);  %   每台机器第一道工序下料所对应时间
%     endtime2 = zeros(100, CNCnum);  %   每台机器第二道工序下料所对应时间
%     %   总时间不超过8小时
%     while t < Twork
%         %   根据RGV所在位置计算RGV移动时间矩阵
%         switch Pos
%             case 1
%                 Trgvm(1) = 0;
%                 Trgvm(2) = 0;
%                 Trgvm(3) = tm1;
%                 Trgvm(4) = tm1;
%                 Trgvm(5) = tm2;
%                 Trgvm(6) = tm2;
%                 Trgvm(7) = tm3;
%                 Trgvm(8) = tm3;
%             case 2
%                 Trgvm(1) = tm1;
%                 Trgvm(2) = tm1;
%                 Trgvm(3) = 0;
%                 Trgvm(4) = 0;
%                 Trgvm(5) = tm1;
%                 Trgvm(6) = tm1;
%                 Trgvm(7) = tm2;
%                 Trgvm(8) = tm2;               
%             case 3
%                 Trgvm(1) = tm2;
%                 Trgvm(2) = tm2;
%                 Trgvm(3) = tm1;
%                 Trgvm(4) = tm1;
%                 Trgvm(5) = 0;
%                 Trgvm(6) = 0;
%                 Trgvm(7) = tm1;
%                 Trgvm(8) = tm1;
%             case 4
%                 Trgvm(1) = tm3;
%                 Trgvm(2) = tm3;
%                 Trgvm(3) = tm2;
%                 Trgvm(4) = tm2;
%                 Trgvm(5) = tm1;
%                 Trgvm(6) = tm1;
%                 Trgvm(7) = 0;
%                 Trgvm(8) = 0;        
%         end
%         %   根据RGV要对设备进行的操作计算RGV工作时间矩阵
%         Trgvw(1) = trwo;
%         Trgvw(3) = trwo;
%         Trgvw(5) = trwo;
%         Trgvw(7) = trwo;
%         Trgvw(2) = trwe;
%         Trgvw(4) = trwe;
%         Trgvw(6) = trwe;
%         Trgvw(8) = trwe;
%         %   若暂时没有第一道工序加工完成的半成品，则第二道工序对应机器暂停
%         if pawsecond == 0
%             Trgvw(secondgroup(divgroup, 1)) = Trgvw(secondgroup(divgroup, 1)) + 100000;
%             Trgvw(secondgroup(divgroup, 2)) = Trgvw(secondgroup(divgroup, 2)) + 100000;
%             Trgvw(secondgroup(divgroup, 3)) = Trgvw(secondgroup(divgroup, 3)) + 100000;
%             Trgvw(secondgroup(divgroup, 4)) = Trgvw(secondgroup(divgroup, 4)) + 100000;
%             Trgvw(secondgroup(divgroup, 5)) = Trgvw(secondgroup(divgroup, 5)) + 100000;
%         else
%             Trgvw(firstgroup3(divgroup, 1)) = Trgvw(firstgroup3(divgroup, 1)) + 100000;
%             Trgvw(firstgroup3(divgroup, 2)) = Trgvw(firstgroup3(divgroup, 2)) + 100000;
%             Trgvw(firstgroup3(divgroup, 3)) = Trgvw(firstgroup3(divgroup, 3)) + 100000;
%         end
%         %   计算总时间矩阵
%         Ttotal = Trgvm + Trgvw + Tcncw;
%         %   计算下一步最短时间及路径
%         rannum1 = rand(1);
%         if rannum1 > 0
%             [tmin, minPos] = min(Ttotal);
%         else
%             [sortTtotal, sortix] = sort(Ttotal);
%             tmin = Ttotal(sortix(2));
%             minPos = sortix(2);
%         end
%         %   若机械爪上有待清洗的熟料，计算清洗时间
%         if pawclear > 0
%             Tclear = tclr;
%         else
%             Tclear = 100000;
%         end
%         %   若下一步最短路径所对应时间大于清洗时间，先进行清洗操作
%         if tmin > Tclear
%             t = t + tclr;
%             Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - tclr;
%             pawclear = pawclear - 1;
%         %   若下一步要操作的对象不在此处，则移动RGV
%         elseif ceil(minPos/2) ~= Pos
%             Pos = ceil(minPos/2);
%             t = t + Trgvm(minPos);
%             Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvm(minPos);
%         %   若下一步要操作的对向在此处
%         else
%             switch minPos
%                 %   若操作对象为第一道工序CNC
%                 case {firstgroup3(divgroup, 1), firstgroup3(divgroup, 2), ...
%                         firstgroup3(divgroup, 3)}
%                     %   若操作对象未开始工作，进行上料处理并计数
%                     if CNCw(minPos) == 0
%                         t = t + Trgvw(minPos);
%                         Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
%                         Tcncw(Tcncw<0) = 0;
%                         Tcncw(minPos) = Tcncw(minPos) + tcnc1;
%                         CNCw(minPos) = 1;
%                         count1(minPos) = count1(minPos) + 1;
%                         starttime1(count1(minPos), minPos) = t;
%                     %   若操作对象的工作状态标记为1
%                     else
%                         %   若操作对象已工作完毕，则先下料再上料并计数
%                         if Tcncw(minPos) == 0
%                             endtime1(count1(minPos), minPos) = t;
%                             t = t + Trgvw(minPos);
%                             pawsecond = pawsecond + 1;
%                             Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
%                             Tcncw(Tcncw<0) = 0;
%                             Tcncw(minPos) = Tcncw(minPos) + tcnc1;
%                             CNCw(minPos) = 1;
%                             count1(minPos) = count1(minPos) + 1;
%                             starttime1(count1(minPos), minPos) = t;
%                         %   若操作对象未工作完毕，则等待
%                         else
%                             t = t + 1;
%                             Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - 1;
%                         end
%                     end
%                 %   若操作对象为第二道工序CNC
%                 case {secondgroup(divgroup, 1), secondgroup(divgroup, 2), ...
%                         secondgroup(divgroup, 3), secondgroup(divgroup, 4), ...
%                         secondgroup(divgroup, 5)}
%                     %   若操作对象未开始工作，上料并计数
%                     if CNCw(minPos) == 0
%                         t = t + Trgvw(minPos);
%                         Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
%                         Tcncw(Tcncw<0) = 0;
%                         Tcncw(minPos) = Tcncw(minPos) + tcnc2;
%                         CNCw(minPos) = 1;
%                         count2(minPos) = count2(minPos) + 1;
%                         starttime2(count2(minPos), minPos) = t;
%                         pawsecond = pawsecond - 1;
%                     %   若操作对象工作状态标记为1
%                     else
%                         %   若操作对象已工作完毕，则先下料再上料并计数
%                         if Tcncw(minPos) == 0
%                             endtime2(count2(minPos), minPos) = t;
%                             t = t + Trgvw(minPos);
%                             pawclear = pawclear + 1;
%                             Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
%                             Tcncw(Tcncw<0) = 0;
%                             Tcncw(minPos) = Tcncw(minPos) + tcnc2;
%                             CNCw(minPos) = 1;
%                             count2(minPos) = count2(minPos) + 1;
%                             starttime2(count2(minPos), minPos) = t;
%                             pawsecond = pawsecond - 1;
%                         %   若操作对象未工作完毕，则等待
%                         else
%                             t = t + 1;
%                             Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - 1;
%                         end
%                     end
%             end
%         end
%         Tcncw(Tcncw<0) = 0;
%     end
%     logiccount = endtime2 > 0;
%     groupcount(divgroup) = sum(logiccount(:));
% end
% %   找出能生产出最大物料的组合方式
% [Totalcount, divgroup] = max(groupcount);
% 
% 
% 
% 
% %   若为（5,3）分组，给出遍历代码
% %   MATLAB初始化
% clear
% clc
% 
% %   数据初始化
% load('firstgroup3.mat');
% all = [1, 2, 3, 4, 5, 6, 7, 8];
% groupcount = zeros(70, 1);
% secondgroup = firstgroup3;
% firstgroup = zeros(70,5);
% 
% 
% for divgroup = 1: 56
%     firstgroup(divgroup,:) = setdiff(all, firstgroup3(divgroup,:));
%     tm1 = 20;                       %   RGV移动1个单位时间
%     tm2 = 33;                       %   RGV移动2个单位时间
%     tm3 = 46;                       %   RGV移动3个单位时间
%     tcnc1 = 400;                    %   CNC完成第一道工序所需时间
%     tcnc2 = 378;                    %   CNC完成第二道工序所需时间
%     trwo = 28;                      %   RGV为奇数CNC上下料时间
%     trwe = 31;                      %   RGV为偶数CNC上下料时间
%     tclr = 25;                      %   RGV清洗熟料时间
%     Twork = 28800;                  %   总工作时间
%     CNCnum = 8;                     %   CNC机器数
%     t = 0;                          %   时间初始化
%     Pos = 1;                        %   位置初始化
%     CNCw = zeros(1, CNCnum);        %   CNC工作状态标志
%     Trgvm = zeros(1, CNCnum);      	%   RGV移动时间矩阵
%     Trgvw = zeros(1, CNCnum);       %   RGV工作时间矩阵
%     Tcncw = zeros(1, CNCnum);       %   CNC工作时间矩阵
%     Ttotal = zeros(1, CNCnum);      %   总时间矩阵
%     pawsecond = 0;                  %   需要进行第二道工序的物料
%     pawclear = 0;                   %   需要清洗的物料
%     Tclear = 100000;                %   清洗剩余时间
%     count1 = zeros(1, CNCnum);      %   计算每台机器第一道工序上料数目
%     count2 = zeros(1, CNCnum);      %   计算每台机器第二道工序上料数目
%     starttime1 = zeros(100, CNCnum);%   每台机器第一道工序上料所对应时间
%     starttime2 = zeros(100, CNCnum);%   每台机器第二道工序上料所对应时间
%     endtime1 = zeros(100, CNCnum);  %   每台机器第一道工序下料所对应时间
%     endtime2 = zeros(100, CNCnum);  %   每台机器第二道工序下料所对应时间
%     %   总时间不超过8小时
%     while t < Twork
%         %   根据RGV所在位置计算RGV移动时间矩阵
%         switch Pos
%             case 1
%                 Trgvm(1) = 0;
%                 Trgvm(2) = 0;
%                 Trgvm(3) = tm1;
%                 Trgvm(4) = tm1;
%                 Trgvm(5) = tm2;
%                 Trgvm(6) = tm2;
%                 Trgvm(7) = tm3;
%                 Trgvm(8) = tm3;
%             case 2
%                 Trgvm(1) = tm1;
%                 Trgvm(2) = tm1;
%                 Trgvm(3) = 0;
%                 Trgvm(4) = 0;
%                 Trgvm(5) = tm1;
%                 Trgvm(6) = tm1;
%                 Trgvm(7) = tm2;
%                 Trgvm(8) = tm2;               
%             case 3
%                 Trgvm(1) = tm2;
%                 Trgvm(2) = tm2;
%                 Trgvm(3) = tm1;
%                 Trgvm(4) = tm1;
%                 Trgvm(5) = 0;
%                 Trgvm(6) = 0;
%                 Trgvm(7) = tm1;
%                 Trgvm(8) = tm1;
%             case 4
%                 Trgvm(1) = tm3;
%                 Trgvm(2) = tm3;
%                 Trgvm(3) = tm2;
%                 Trgvm(4) = tm2;
%                 Trgvm(5) = tm1;
%                 Trgvm(6) = tm1;
%                 Trgvm(7) = 0;
%                 Trgvm(8) = 0;        
%         end
%         %   根据RGV要对设备进行的操作计算RGV工作时间矩阵
%         Trgvw(1) = trwo;
%         Trgvw(3) = trwo;
%         Trgvw(5) = trwo;
%         Trgvw(7) = trwo;
%         Trgvw(2) = trwe;
%         Trgvw(4) = trwe;
%         Trgvw(6) = trwe;
%         Trgvw(8) = trwe;
%         %   若暂时没有第一道工序加工完成的半成品，则第二道工序对应机器暂停
%         if pawsecond == 0
%             Trgvw(secondgroup(divgroup, 1)) = Trgvw(secondgroup(divgroup, 1)) + 100000;
%             Trgvw(secondgroup(divgroup, 2)) = Trgvw(secondgroup(divgroup, 2)) + 100000;
%             Trgvw(secondgroup(divgroup, 3)) = Trgvw(secondgroup(divgroup, 3)) + 100000;
%         else
%             Trgvw(firstgroup(divgroup, 1)) = Trgvw(firstgroup(divgroup, 1)) + 100000;
%             Trgvw(firstgroup(divgroup, 2)) = Trgvw(firstgroup(divgroup, 2)) + 100000;
%             Trgvw(firstgroup(divgroup, 3)) = Trgvw(firstgroup(divgroup, 3)) + 100000;
%             Trgvw(firstgroup(divgroup, 4)) = Trgvw(firstgroup(divgroup, 1)) + 100000;
%             Trgvw(firstgroup(divgroup, 5)) = Trgvw(firstgroup(divgroup, 2)) + 100000;
%         end
%         %   计算总时间矩阵
%         Ttotal = Trgvm + Trgvw + Tcncw;
%         %   计算下一步最短时间及路径
%         rannum1 = rand(1);
%         if rannum1 > 0
%             [tmin, minPos] = min(Ttotal);
%         else
%             [sortTtotal, sortix] = sort(Ttotal);
%             tmin = Ttotal(sortix(2));
%             minPos = sortix(2);
%         end
%         %   若机械爪上有待清洗的熟料，计算清洗时间
%         if pawclear > 0
%             Tclear = tclr;
%         else
%             Tclear = 100000;
%         end
%         %   若下一步最短路径所对应时间大于清洗时间，先进行清洗操作
%         if tmin > Tclear
%             t = t + tclr;
%             Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - tclr;
%             pawclear = pawclear - 1;
%         %   若下一步要操作的对象不在此处，则移动RGV
%         elseif ceil(minPos/2) ~= Pos
%             Pos = ceil(minPos/2);
%             t = t + Trgvm(minPos);
%             Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvm(minPos);
%         %   若下一步要操作的对向在此处
%         else
%             switch minPos
%                 %   若操作对象为第一道工序CNC
%                 case {firstgroup(divgroup, 1), firstgroup(divgroup, 2), ...
%                         firstgroup(divgroup, 3), firstgroup(divgroup, 4), ...
%                         firstgroup(divgroup, 5)}
%                     %   若操作对象未开始工作，进行上料处理并计数
%                     if CNCw(minPos) == 0
%                         t = t + Trgvw(minPos);
%                         Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
%                         Tcncw(Tcncw<0) = 0;
%                         Tcncw(minPos) = Tcncw(minPos) + tcnc1;
%                         CNCw(minPos) = 1;
%                         count1(minPos) = count1(minPos) + 1;
%                         starttime1(count1(minPos), minPos) = t;
%                     %   若操作对象的工作状态标记为1
%                     else
%                         %   若操作对象已工作完毕，则先下料再上料并计数
%                         if Tcncw(minPos) == 0
%                             endtime1(count1(minPos), minPos) = t;
%                             t = t + Trgvw(minPos);
%                             pawsecond = pawsecond + 1;
%                             Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
%                             Tcncw(Tcncw<0) = 0;
%                             Tcncw(minPos) = Tcncw(minPos) + tcnc1;
%                             CNCw(minPos) = 1;
%                             count1(minPos) = count1(minPos) + 1;
%                             starttime1(count1(minPos), minPos) = t;
%                         %   若操作对象未工作完毕，则等待
%                         else
%                             t = t + 1;
%                             Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - 1;
%                         end
%                     end
%                 %   若操作对象为第二道工序CNC
%                 case {secondgroup(divgroup, 1), secondgroup(divgroup, 2), ...
%                         secondgroup(divgroup, 3)}
%                     %   若操作对象未开始工作，上料并计数
%                     if CNCw(minPos) == 0
%                         t = t + Trgvw(minPos);
%                         Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
%                         Tcncw(Tcncw<0) = 0;
%                         Tcncw(minPos) = Tcncw(minPos) + tcnc2;
%                         CNCw(minPos) = 1;
%                         count2(minPos) = count2(minPos) + 1;
%                         starttime2(count2(minPos), minPos) = t;
%                         pawsecond = pawsecond - 1;
%                     %   若操作对象工作状态标记为1
%                     else
%                         %   若操作对象已工作完毕，则先下料再上料并计数
%                         if Tcncw(minPos) == 0
%                             endtime2(count2(minPos), minPos) = t;
%                             t = t + Trgvw(minPos);
%                             pawclear = pawclear + 1;
%                             Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
%                             Tcncw(Tcncw<0) = 0;
%                             Tcncw(minPos) = Tcncw(minPos) + tcnc2;
%                             CNCw(minPos) = 1;
%                             count2(minPos) = count2(minPos) + 1;
%                             starttime2(count2(minPos), minPos) = t;
%                             pawsecond = pawsecond - 1;
%                         %   若操作对象未工作完毕，则等待
%                         else
%                             t = t + 1;
%                             Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - 1;
%                         end
%                     end
%             end
%         end
%         Tcncw(Tcncw<0) = 0;
%     end
%     logiccount = endtime2 > 0;
%     groupcount(divgroup) = sum(logiccount(:));
% end
% %   找出能生产出最大物料的组合方式
% [Totalcount, divgroup] = max(groupcount);