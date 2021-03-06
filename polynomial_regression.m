clc;
clear;
%Transmitting power
tx=2*10^-3; % given in dbm(from the XBee data sheet)
eta=2; %for free space eta=2(path loss exponent)

dd=0;
f=2.4*10^9;
gt=1;
gr=1;
c=3*10^8;

%data from excel
a=xlsread('summa.xlsx');
x=a(:,2);
y=a(:,3);
%To know the number of nodes
n=numel(x);

p1=0;%the numerator of probability
p2=(n*2)-2;%the denominator of probability

z1=randperm(n);
z=z1(1:2);

subplot(2,1,1)
plot(x,y,'o',...
    'LineWidth',2,...
    'MarkerEdgeColor','k',...
    'MarkerFaceColor','g',...
    'MarkerSize',10)
legend('SN')

%distance
for i=1:n
    for k=1:n
            d(i,k)=sqrt(((x(i)-x(k))^2)+((y(i)-y(k))^2));
            
    end
end
disp('Distance:')
disp(d);

%to find received power
for i=1:n
    for k=1:n
        pr(i,k)=((tx*gt*gr*(c^2))/((4*pi*d(i,k)*f)^2));
       
         if(pr(i,k)== inf)
             pr(i,k)=0;
         end
   
    end
end
 disp('Received Power:');
 disp(pr);
   
   for i=1:n
    for k=1:n
        RSSI(i,k)=10*log(pr(i,k)/(1*10^-3));
         if(RSSI(i,k)== -inf)
             RSSI(i,k)=0;
         end
   
    end
   end
   
   disp('faulty nodes');
   disp(z);
   
   %inducing faults
for i=1:2     
   for k=1:n 
     
    if(z(i)~=k)
       RSSI(z(i),k)=-160.00; 
    end    
   end   
   for k=1:n 
     
    if(z(i)~=k)
       RSSI(k,z(i))=-160.00; 
    end    
   end 
    
end    
 disp('RSSI:');
 disp(RSSI);
   
    
disp('Error array'); 

for i=1:n
    p1=0;
    for k=1:n
     if(RSSI(i,k)<=-159.0554&&i~=k)
        p1=p1+1; 
     end   
    end
    for k=1:n
        if(RSSI(k,i)<=-159.0554&&i~=k)
          p1=p1+1;
        end    
    end
   
    fp(i)=round(p1/p2,4);
    if(fp(i)>0.5)
     draw_circle1(x(i),y(i),2,'r'); 
    end    
end


disp(fp);
fp1=transpose(fp);
xlswrite('C:\Users\Ajay Kumar\Desktop\faulty node.xlsx',fp1,1,'D1:D10');

%Polynomial Regression
subplot(2,1,2)
ppoly=polyfit(d,RSSI,2);
poly1=polyval(ppoly,d);
plot(d,poly1,'r')
hold on
plot(d,RSSI,'x')