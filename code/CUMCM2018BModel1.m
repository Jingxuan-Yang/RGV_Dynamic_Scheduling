%   ½Å±¾¹¦ÄÜ£º
%   ÖÇÄÜRGV¶¯Ì¬µ÷¶È£¨Ò»µÀ¹¤Ðò£¬²»¿¼ÂÇ»úÆ÷¹ÊÕÏ£©
%
%   ¾ßÌåÃèÊö£º
%
%
%   Ç¶Ì×º¯Êý£ºÎÞ
%
%   ×÷Õß£ºÂÞ?ªÄþ
%
%   °æ±¾£º1.1
%
%   ÉÏ´ÎÐÞ¸ÄÊ±¼ä£º2018.9.15
%
%   ÉÏ´ÎÐÞ¸ÄÀúÊ·£ºÔö¼Ó×¢ÊÍ£¬Ôö¼ÓÄ£ÄâÍË»ðËã·¨

%   ³õÊ¼»¯MATLAB
clear
clc

%   Êý¾Ý³õÊ¼»¯
tm1 = 20;                       %   RGVÒÆ¶¯1¸öµ¥Î»Ê±¼ä
tm2 = 33;                       %   RGVÒÆ¶¯2¸öµ¥Î»Ê±¼ä
tm3 = 46;                       %   RGVÒÆ¶¯3¸öµ¥Î»Ê±¼ä
tcnc = 545;                     %   CNC¼Ó¹¤Íê³ÉÒ»µÀ¹¤ÐòÊ±¼ä
trwo = 28;                      %   RGVÎªÆæÊýCNCÉÏÏÂÁÏÊ±¼ä
trwe = 31;                      %   RGVÎªÅ¼ÊýCNCÉÏÏÂÁÏÊ±¼ä
tclr = 25;                      %   RGVÇåÏ´ÊìÁÏÊ±¼ä
Twork = 28800;                  %   ×Ü¹¤×÷Ê±¼ä
CNCnum = 8;                     %   CNC»úÆ÷Êý
t = 0;                          %   Ê±¼ä³õÊ¼»¯
Pos = 1;                        %   Î»ÖÃ³õÊ¼»¯
CNCw = zeros(1, CNCnum);        %   CNC¹¤×÷×´Ì¬±êÖ¾
Trgvm = zeros(1, CNCnum);       %   RGVÒÆ¶¯Ê±¼ä¾ØÕó
Trgvw = zeros(1, CNCnum);       %   RGV¹¤×÷Ê±¼ä¾ØÕó
Tcncw = zeros(1, CNCnum);       %   CNC¹¤×÷Ê±¼ä¾ØÕó
Ttotal = zeros(1, CNCnum);      %   ×ÜÊ±¼ä¾ØÕó
paw = 0;                        %   »úÐµ×¦ÉÏÊÇ·ñÓÐÊìÁÏ
Tclear = 100000;                %   ÇåÏ´Ê£ÓàÊ±¼ä
tmin = 10000;                   %   Ñ­»·±äÁ¿£¬±íÊ¾µ±Ç°²½Öè½øÐÐµÄ×î¶ÌÊ±¼ä
minPos = -1;                    %   Ñ­»·±äÁ¿£¬±íÊ¾µ±Ç°¶ÔÄÄÌ¨»úÆ÷²Ù×÷
count = zeros(1, CNCnum);       %   ¼ÆËãÃ¿Ì¨»úÆ÷ËùÉÏÁÏµÄÊýÄ¿
starttime = zeros(100, CNCnum); %   Ã¿Ì¨»úÆ÷ÉÏÁÏËù¶ÔÓ¦µÄÊ±¼ä
endtime = zeros(100, CNCnum);   %   Ã¿Ì¨»úÆ÷ÏÂÁÏ¶ÔÓ¦Ê±¼ä
sortTtotal = zeros(1, CNCnum);  %   Ä£ÄâÍË»ðËã·¨ËùÐèµÄÅÅÐò¾ØÕó
sortix = zeros(1, CNCnum);      %   Ä£ÄâÍË»ðËã·¨ËùÐèµÄÎ»ÖÃ¾ØÕó

while t < Twork
    %   ¸ù¾ÝRGVµ±Ç°Î»ÖÃ¼ÆËã¶ÔÓ¦µÄRGVÒÆ¶¯Ê±¼ä¾ØÕó
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
    %   ¼ÆËãRGV¹¤×÷Ê±¼ä¾ØÕó
	Trgvw(1) = trwo;
	Trgvw(3) = trwo;
    Trgvw(5) = trwo;
	Trgvw(7) = trwo;
	Trgvw(2) = trwe;
	Trgvw(4) = trwe;
	Trgvw(6) = trwe;
	Trgvw(8) = trwe;
    %   ¼ÆËã×ÜÊ±¼ä
    Ttotal = Trgvm + Trgvw + Tcncw;
    %   ÕÒ³ö×î¶ÌÂ·¾¶
    %   »ùÓÚÄ£ÄâÍË»ðËã·¨Éú³É×î¶ÌÂ·¾¶Î»ÖÃ
    rannum = rand(1);
    if rannum > 0
        [tmin, minPos] = min(Ttotal);
    else
        [sortTtotal, sortix] = sort(Ttotal);
        tmin = Ttotal(sortix(2));
        minPos = sortix(2);
    end
    %   Èô»úÐµ×¦ÉÏÓÐÊìÁÏ£¬ÔòÓë×î¶ÌÂ·¾¶Ïà±È½Ï
    if paw == 1
        Tclear = tclr;
    else
        Tclear = 100000;
    end
    %   Èô×î¶ÌÊ±¼ä´óÓÚÇåÏ´Ê±¼ä£¬ÔòÏÈ½øÐÔÇåÏ´
    if tmin > Tclear
        t = t + tclr;
        Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - tclr;
        paw = paw - 1;
    %   ÈôÐèÒª²Ù×÷µÄÉè±¸²»ÔÚµ±Ç°Î»ÖÃ£¬ÔòÒÆ¶¯
    elseif ceil(minPos/2) ~= Pos
        Pos = ceil(minPos/2);
        t = t + Trgvm(minPos);
        Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvm(minPos);
    %   ÈôÐèÒª²Ù×÷µÄÎ»ÖÃÔÚµ±Ç°Éè±¸
    else
        %   Èôµ±Ç°Éè±¸Î´¹¤×÷£¬½øÐÐÉÏÁÏ²Ù×÷²¢¼ÆÊý
        if CNCw(minPos) == 0
            t = t + Trgvw(minPos);
            Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
            Tcncw(Tcncw<0) = 0;
            Tcncw(minPos) = Tcncw(minPos) + tcnc;
            CNCw(minPos) = 1;
            count(minPos) = count(minPos) + 1;
            starttime(count(minPos), minPos) = t;
        %   Èôµ±Ç°Éè±¸ÕýÔÚ¹¤×÷
        else
            %   ÈôÉè±¸ÒÑ¹¤×÷Íê±Ï£¬½øÐÐÏÂÁÏ²Ù×÷²¢¼ÆÊý
            if Tcncw(minPos) == 0
                endtime(count(minPos), minPos) = t;
                t = t + Trgvw(minPos);
                paw = paw + 1;
                Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - Trgvw(minPos);
                Tcncw(Tcncw<0) = 0;
                Tcncw(minPos) = Tcncw(minPos) + tcnc;
                CNCw(minPos) = 1;
                count(minPos) = count(minPos) + 1;
                starttime(count(minPos), minPos) = t;
            %   ÈôÉè±¸Î´¹¤×÷£¬µÈ´ý
            else
                t = t + 1;
                Tcncw(CNCw == 1) = Tcncw(CNCw == 1) - 1;
            end
        end
    end
    %   È¥³ýÐ¡ÓÚ0µÄÊý
    Tcncw(Tcncw<0) = 0;
end

sum(sum(endtime~=0))
