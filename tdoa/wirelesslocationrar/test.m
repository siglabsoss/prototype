% test_Taylor_SS ±¾º¯ÊýÓÃÓÚÊµÏÖ³¡Ç¿¶¨Î»Ëã·¨¡£ 
%               - BSN  Îª»ùÕ¾¸öÊý£¬3 < BSN <= 7£» 
%               - MSP  ÎªÒÆ¶¯Ì¨µÄ³õÊ¼Î»ÖÃ, MSx, MSy¾ùÎª[0,1]Ö®¼äµÄÊý£» 
%                      ÌØ±ðÒª×¢Òâ·þÎñÐ¡ÇøÓëMSÖ®¼äµÄ¹ØÏµ£¬MSµÄÎ»ÖÃ²»ÄÜÔ½½ç¡£ 
%               - ACP  Îª¶¨Î»Õ¾µÄ³õÊ¼Î»ÖÃ, ACx, ACy¾ùÒÑÖª£¬²¢×÷ÎªÒÆ¶¯Ì¨µÄ³õÊ¼¹À¼ÆÎ»ÖÃ 
%               - R    ÎªÐ¡Çø°ë¾¶£¬µ¥Î»(meter)£» 
%               - X    ÒÆ¶¯Ì¨µÄ¹À¼ÆÎ»ÖÃ£» 
%               - zone ÌÖÂÛÐ¡Çø»·¾³ 
% See also: test_Taylor_SS.m 
 
BSN  = 7; 
%Noise = [10^2, 20^2, 30^2, 50^2, 100^2, 200^2, 300^2]; 
% Noise = [30, 50, 100, 120, 150, 180, 210]; 
Noise = [30, 60, 90, 150, 210, 300]; 
R = 3000; 
%R = 1000; 
Cal_Num = 1000; 
 
% ¼Ó½Ç¶ÈÐÅÏ¢£º 
for i = 1: 6, 
    for m = 1: Cal_Num, 
%         MSP = [i*sqrt(3)/12,i/12]; 
%         ACP1 = [0.2,0.3]; 
        MSP = [0.5, 0.5]; 
        ACP = [0,0]; 
        MS = MSP*R; 
        MSr(m, 1) = MS(1); 
        MSr(m, 2) = MS(2); 
 
        MSe1 = ChanAlgorithm(BSN, MSP, R, Noise(i)); 
        MSer1(m, 1) = MSe1(1); 
        MSer1(m, 2) = MSe1(2); 
         
%         MSe2 = ChanAlgorithm_A(BSN, MSP, ACP, R, Noise(i), 0.1); 
%         MSer2(m, 1) = MSe2(1); 
%         MSer2(m, 2) = MSe2(2); 
        MSe2 = TaylorAlgorithm(BSN, MSP, R, Noise(i)); 
        MSer2(m, 1) = MSe2(1); 
        MSer2(m, 2) = MSe2(2); 
    end 
    RMSE1(i) = TDOA_RMSE(MSr, MSer1); 
    RMSE2(i) = TDOA_RMSE(MSr, MSer2); 
%     RMSE3(i) = TDOA_RMSE(MSr, MSer3); 
%     RMSE4(i) = TDOA_RMSE(MSr, MSer4); 
%     RMSE5(i) = TDOA_RMSE(MSr, MSer5); 
%     RMSE3(i) = TDOA_RMSE(MSr, MSer3); 
end