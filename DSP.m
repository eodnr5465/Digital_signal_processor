function DSP = DSP(n,SNR)

%---------------------bit generation----------------------------

bit = rand(1,n);  
%uniform distribution function으로 0~1사이에 random으로 수를 generation 
    
for(i = 1: n)
    if(bit(1,i) > 0.5)
        b(i) = 0;
    else
        b(i) = 1;
    end 
end
% 생성한 난수의 크기를 0.5를 기준으로 나누면서 random한 0과 1을 생성하는 것과 같음

a = n/2;
if((a - round(a)) < 0)
    for(i = 1: n-1)
        bn(i) = b(i);        
    end
    n = n-1;
else
    bn = b;
end
% 홀수개수의 bit를 generation할 시 마지막 한개 무시하도록 round function 사용






%-------------------Constellation mapping---------------------------------

s1 = 0; s2 = 0; s3 = 0; s4 = 0;
%4QAM의 symbol의 개수를 담기 위한 변수
    
for (i = 1:2:n)
    fac = round(i/2); 
    if(bn(i) == 0)
        if(bn(i+1) == 0)
            s(fac) = sqrt(1/2) + sqrt(-1/2);
            s1 = s1+1;
        elseif(bn(i+1) == 1)
            s(fac) = -sqrt(1/2) + sqrt(-1/2);
            s2 = s2+1;
        end       
    elseif(bn(i) == 1)
        if(bn(i+1) == 1)
            s(fac) = -sqrt(1/2) - sqrt(-1/2);
            s3 = s3+1;
        elseif(bn(i+1) == 0)
            s(fac) = sqrt(1/2) - sqrt(-1/2);
            s4 = s4+1;
        end
    end
end
% 연속된 2bit가 00->s1, 01->s2 ,11->s3, 10->s4

sr = real(s);    si = imag(s);      snum = length(s);
DataR = 1;       DT = 1/DataR;      total_t = snum*DT;





%-------------------------transmit filter------------------------

for(i = 1:snum)
    for(p = 1:50000)
        t = (p-1)*total_t/50000;
        gtx = ((4/(pi*sqrt(DT))) .*  ( cos( (t-(i.*DT)).*((1+1)*pi/DT) ) ) ./ ((1 - ((4.*(t-(i.*DT))./DT).^2))) );
        % squre-root raised cosine (alpha = 1) 
        xsr(i,p) = sr(i).*gtx;
        xsi(i,p) = si(i).*gtx;
        if(abs(xsr(i,p))==Inf)
            xsr(i,p) = xsr(i,p-1);
        end
        if(abs(xsi(i,p))==Inf)
            xsi(i,p) = xsi(i,p-1);
        end
    end
end
%500개의 sample data를 continuous time domain에서 handling하기 쉽게
%continuous time을 50000으로 oversampling을 취함.
  t = linspace(0,total_t,50000);
  xpr = sum(xsr,1);
  xpi = sum(xsi,1);
  
  
  
  
  
%----------------------up conversion--------------------------------
  fc= 10;
  xcr = xpr.*cos(2.*pi.*fc.*t);
  xci = -xpi.*sin(2.*pi.*fc.*t);
 

  
  
  
%----------------------AWGN----------------------------------------------
  AWGNadd1 = AWGNadd(xcr,SNR);
  srout = AWGNadd1;
  AWGNadd2 = AWGNadd(xci,SNR);
  siout = AWGNadd2;
  sout = siout+srout;

  
  
  
%----------------------down conversion--------------------------------
  xdr = (sout.*cos(2.*pi.*fc.*t));      %inphase
  xdi = -(sout.*sin(2.*pi.*fc.*t));     %quadrature
  
  
  
  
  
  
  
%----------------------eq_channel, Filter---------------------------------
  
  W = 1;
  bpf = W*sinc(W.*t).*2.*cos((2*pi*fc).*t);
  xrecr = conv(xdr,bpf);
  xreci = conv(xdi,bpf);
  max_valr = max(abs(xrecr));
  max_vali = max(abs(xreci));
  for(i = 1:50000)
    ef_sr(i) = xrecr(i)/max_valr;
    ef_si(i) = xreci(i)/max_vali;
  end
  
  
 
  
  
  
%----------------------pulseshaping reciever----------------------------
 grx = ((4/(pi*sqrt(DT))) .*  ( cos( (-t).*((1+1)*pi/DT) ) ) ./ ((1 - ((4.*(-t)./DT).^2))) );
% squre-root raised cosine (alpha = 1) 
 eff_sr = conv(ef_sr, grx);
 eff_si = conv(ef_si, grx);
 max_efr = max(abs(eff_sr));
 max_efi = max(abs(eff_si));
 for(i = 1:50000)
    eff_srr(i) = eff_sr(i)/max_efr;
    eff_sii(i) = eff_si(i)/max_efi;
 end

 
 
 
 
 
 
%-------------------sampling---------------------------------------------
sample_t = total_t/(50000);
factor = round(DT/sample_t);
for(i = 1:snum)
    receive_sr(i) = eff_srr((i)*factor);
    receive_si(i) = eff_sii((i)*factor);
end








%----------------------detection------------------------------------------

for(i = 1:length(receive_sr))
    
    distance1(i) = ((sqrt(1/2)-receive_sr(i)).^2) + ((sqrt(1/2)-receive_si(i)).^2);
    
    distance2(i) = ((-sqrt(1/2)-receive_sr(i)).^2) + ((sqrt(1/2)-receive_si(i)).^2);
    
    distance3(i) = ((-sqrt(1/2)-receive_sr(i)).^2) + ((-sqrt(1/2)-receive_si(i)).^2);
    
    distance4(i) = ((sqrt(1/2)-receive_sr(i)).^2) + ((-sqrt(1/2)-receive_si(i)).^2);
    
    if(distance1(i)<distance2(i))
        
        if(distance1(i)<distance3(i))
            
            if(distance1(i)<distance4(i))
                receive_s(i) = sqrt(1/2) + sqrt(-1/2);
            else
                receive_s(i) = sqrt(1/2) - sqrt(-1/2);
            end
            
        else
            if(distance3(i)<distance4(i))
                receive_s(i) = -sqrt(1/2) - sqrt(-1/2);
            else
                receive_s(i) = sqrt(1/2) - sqrt(-1/2);
            end 
        end
        
    else
        if(distance2(i)<distance3(i))
            
            if(distance2(i)<distance4(i))
                receive_s(i) = -sqrt(1/2) + sqrt(-1/2);
            else
                receive_s(i) = sqrt(1/2) - sqrt(-1/2);
            end
            
        else
            if(distance3(i)<distance4(i))
                receive_s(i) = -sqrt(1/2) - sqrt(-1/2);
            else
                receive_s(i) = sqrt(1/2) - sqrt(-1/2);
            end
        end
        
    end
end

%---------------------SER-------------------------------------
ok = 0;
er = 0;
for(i = 1:snum)
    if (s(i) == receive_s(i))
        ok = ok+1;
    else
        er = er+1;
    end

end



%----------------------------result--------------------------
ok
er

subplot(3,3,1)
scatter(si,sr)
title('constellation mapping')

subplot(3,3,2)
plot(t, xpr ,'b' , t, xpi, 'r')
title('transmit filter(real term(blue) imag term(red))')

subplot(3,3,3)
plot(t, xcr ,'b' , t, xci, 'r')
title('up conversion(env_freq x10)(real term(blue) imag term(red))')

subplot(3,3,4)
plot( t, srout, 'b', t, siout ,'r' )
title('add noise by channel(real term(blue) imag term(red))')

subplot(3,3,5)
plot( t, ef_sr, 'b',t, ef_si ,'r')
title('downcoversion + ideal eq_channel(real term(blue) imag term(red))')

subplot(3,3,6)
plot( t, eff_srr, 'b',t, eff_sii ,'r' )
title('recevier pulseshaping (real term(blue) imag term(red))')

subplot(3,3,7)
scatter(receive_si,receive_sr)
title('detection & receive data')



%===========================print fft==============================
N = 50000; T = total_t; Ts = T/N; fs = 1/Ts; df = 1/T;
f = 0:df:fs-df;

x_com = xpr + xpi.*i;
xu_com = xcr + xci.*i; 

Pxu = fft(xu_com,N)/N;
Px = fft(x_com,N)/N;


subplot(3,3,8)
plot(f-50,fftshift(abs(Px)),f-50,fftshift(abs(Pxu)))
xlim([-25,25]);
ylim([-1,40.3]);
title('freq-domain (tr_sig(blue) up_tr_sig(red))')