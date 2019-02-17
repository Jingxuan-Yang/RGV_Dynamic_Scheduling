%   ½Å±¾¹¦ÄÜ£º
%   ÖÇÄÜRGV¶¯Ì¬µ÷¶È£¨Á½µÀ¹¤Ðò£¬²»¿¼ÂÇ»úÆ÷¹ÊÕÏ£©
%
%   ¾ßÌåÃèÊö£º
%
%
%   Ç¶Ì×º¯Êý£ºÎÞ
%
%   ×÷Õß£ºÂÞ?ªÄþ
%
%   °æ±¾£º1.0
%
%   ÉÏ´ÎÐÞ¸ÄÊ±¼ä£º
%
%   ÉÏ´ÎÐÞ¸ÄÀúÊ·£º

%   MATLAB³õÊ¼»¯
clear
clc

%   Êý¾Ý³õÊ¼»¯
tm1 = 20;                       %   RGVÒÆ¶¯1¸öµ¥Î»Ê±¼ä
tm2 = 33;                       %   RGVÒÆ¶¯2¸öµ¥Î»Ê±¼ä
tm3 = 46;                       %   RGVÒÆ¶¯3¸öµ¥Î»Ê±¼ä
tcnc1 = 400;                    %   CNCÍê³ÉµÚÒ»µÀ¹¤ÐòËùÐèÊ±¼ä
tcnc2 = 378;                    %   CNCÍê³ÉµÚ¶þµÀ¹¤ÐòËùÐèÊ±¼ä
trwo = 28;                      %   RGVÎªÆæÊýCNCÉÏÏÂÁÏÊ±¼ä
trwe = 31;                      %   RGVÎªÅ¼ÊýCNCÉÏÏÂÁÏÊ±¼ä
tclr = 25;                      %   RGVÇåÏ´ÊìÁÏÊ±¼ä
Twork = 28800;                  %   ×Ü¹¤×÷Ê±¼ä
CNCnum = 8;                     %   CNC»úÆ÷Êý
t = 0;                          %   Ê±¼ä³õÊ¼»¯
Pos = 1;                        %   Î»ÖÃ³õÊ¼»¯
CNCw = zeros(1, CNCnum);        %   CNC¹¤×÷×´Ì¬±êÖ¾
Trgvm = zeros(1, CNCnum);      	%   RGVÒÆ¶¯Ê±¼ä¾ØÕó
Trgvw = zeros(1, CNCnum);       %   RGV¹¤×÷Ê±¼ä¾ØÕó
Tcncw = zeros(1, CNCnum);       %   CNC¹¤×÷Ê±¼ä¾ØÕó
Ttotal = zeros(1, CNCnum);      %   ×ÜÊ±¼ä¾ØÕó
pawsecond = 0;                  %   ÐèÒª½øÐÐµÚ¶þµÀ¹¤ÐòµÄÎïÁÏ
pawclear = 0;                   %   ÐèÒªÇåÏ´µÄÎïÁÏ
Tclear = 100000;                %   ÇåÏ´Ê£ÓàÊ±¼ä
count1 = zeros(1, CNCnum);      %   ¼ÆËãÃ¿Ì¨»úÆ÷µÚÒ»µÀ¹¤ÐòÉÏÁÏÊýÄ¿
count2 = zeros(1, CNCnum);      %   ¼ÆËãÃ¿Ì¨»úÆ÷µÚ¶þµÀ¹¤ÐòÉÏÁÏÊýÄ¿
starttime1 = zeros(100, CNCnum);%   Ã¿Ì¨»úÆ÷µÚÒ»µÀ¹¤ÐòÉÏÁÏËù¶ÔÓ¦Ê±¼ä
starttime2 = zeros(100, CNCnum);%   Ã¿Ì¨»úÆ÷µÚ¶þµÀ¹¤ÐòÉÏÁÏËù¶ÔÓ¦Ê±¼ä
endtime1 = zeros(100, CNCnum);  %   Ã¿Ì¨»úÆ÷µÚÒ»µÀ¹¤ÐòÏÂÁÏËù¶ÔÓ¦Ê±¼ä
endtime2 = zeros(100, CNCnum);  %   Ã¿Ì¨»úÆ÷µÚ¶þµÀ¹¤ÐòÏÂÁÏËù¶ÔÓ¦Ê±¼ä
sortTtotal = zeros(1, CNCnum);  %   Ä£ÄâÍË»ðËã·¨ËùÐèµÄÅÅÐò¾ØÕó
sortix = zeros(1, CNCnum);      %   Ä£ÄâÍË»ðËã·¨ËùÐèµÄÎ»ÖÃ¾ØÕó

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
    rannum = rand(1);
    if rannum > 0.05
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
        Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - tclr;
        pawclear = pawclear - 1;
    elseif ceil(minPos/2) ~= Pos
        Pos = ceil(minPos/2);
        t = t + Trgvm(minPos);
        Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvm(minPos);
    else
        switch minPos
            case {1, 3, 5, 7}
                if CNCw(minPos) == 0
                    t = t + Trgvw(minPos);
                    Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
                    Tcncw(Tcncw<0) = 0;
                    Tcncw(minPos) = Tcncw(minPos) + tcnc1;
                    CNCw(minPos) = 1;
                    count1(minPos) = count1(minPos) + 1;
                    starttime1(count1(minPos), minPos) = t;
                else
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
                    else
                        t = t + 1;
                        Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - 1;
                    end
                end
            case {2, 4, 6, 8}
                if CNCw(minPos) == 0
                    t = t + Trgvw(minPos);
                    Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
                    Tcncw(Tcncw<0) = 0;
                    Tcncw(minPos) = Tcncw(minPos) + tcnc2;
                    CNCw(minPos) = 1;
                    count2(minPos) = count2(minPos) + 1;
                    starttime2(count2(minPos), minPos) = t;
                    pawsecond = pawsecond - 1;
                else
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
                    else
                        t = t + 1;
                        Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - 1;
                    end
                end
        end
    end
    Tcncw(Tcncw<0) = 0;
end

sum(sum(endtime2~=0))
