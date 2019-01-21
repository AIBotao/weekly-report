clear
%1. initialize paramters
%. wireless sensor network region
xm=100;
ym=100;
%(1)sink node coordinate
sink.x=0.5*xm;
sink.y=0.5*ym;
%the number if sensor nodes
n=100
%head proportion
p=0.1;
%energy model
%initialize energy model
Eo=0.5;
%Eelec=Etx=Erx
ETX=50*0.000000001;
ERX=50*0.000000001;
%Transmit Amplifier types
Efs=10*0.000000000001;
Emp=0.0013*0.000000000001;
%Data Aggregation Energy
EDA=5*0.000000001;
%maximum loop times
rmax=5000
% do
do=sqrt(Efs/Emp);
%2.generate wsn model
%distribute 100 points randomly
for i=1:1:n
    S(i).xd=rand(1,1)*xm;
    XR(i)=S(i).xd;
    S(i).yd=rand(1,1)*ym;
    YR(i)=S(i).yd;
    S(i).G=0;
    S(i).E=Eo;
    %initially there are no cluster heads only nodes
    S(i).type='N';
end

S(n+1).xd=sink.x;
S(n+1).yd=sink.y;
%cluster head number
countCHs=0;
cluster=1;%The purpose of this definition is simply to give a subscript parameter starting with 1, and the true number of cluster heads should be subtracted by 1.
flag_first_dead=0;
flag_teenth_dead=0;
flag_all_dead=0;
%the number of dead nodes
dead=0;
first_dead=0;
teenth_dead=0;
all_dead=0;
%the number of alive nodes
allive=n;
%counter for bit transmitted to Bases Station and to Cluster Heads
packets_TO_BS=0;
packets_TO_CH=0;
%(1)Circulation mode setting
for r=0:1:rmax 
    r
  %Each rotation cycle (10 times in this program) restores the S(i). G parameter of each node (which is used for subsequent cluster elections, 
  %and nodes that have been elected cluster heads cannot be re-elected) to zero.
  if(mod(r, round(1/p) )==0)
    for i=1:1:n
        S(i).G=0;
        S(i).cl=0;
    end
  end
%(2)Dead node checking
dead=0;
for i=1:1:n
    %Check for dead nodes
    if (S(i).E<=0)
        dead=dead+1; 
        %The first node's death time
        if (dead==1)
           if(flag_first_dead==0)
              first_dead=r;
              flag_first_dead=1;
           end
        end
        %10% node death time
        if(dead==0.1*n)
           if(flag_teenth_dead==0)
              teenth_dead=r;
              flag_teenth_dead=1;
           end
        end
        if(dead==n)
           if(flag_all_dead==0)
              all_dead=r;
              flag_all_dead=1;
           end
        end
    end
    if S(i).E>0
        S(i).type='N';
    end
end
STATISTICS.DEAD(r+1)=dead;
STATISTICS.ALLIVE(r+1)=allive-dead;
%(4)Cluster Head Election Module
countCHs=0;
cluster=1;
for i=1:1:n
 if(S(i).E>0)
   temp_rand=rand;     
   if ( (S(i).G)<=0) 
       %The cluster head stores all kinds of related information in the variables given by the following program
        if(temp_rand<= (p/(1-p*mod(r,round(1/p)))))
            countCHs=countCHs+1;
            packets_TO_BS=packets_TO_BS+1;
            PACKETS_TO_BS(r+1)=packets_TO_BS;
             S(i).type='C';
            S(i).G=round(1/p)-1;
            C(cluster).xd=S(i).xd;
            C(cluster).yd=S(i).yd;
           distance=sqrt( (S(i).xd-(S(n+1).xd) )^2 + (S(i).yd-(S(n+1).yd) )^2 );
            C(cluster).distance=distance;
            C(cluster).id=i;
            X(cluster)=S(i).xd;
            Y(cluster)=S(i).yd;
            cluster=cluster+1;
           %Calculate the energy consumption of sending 4000bit data from cluster head to base station 
           %(in this case, all nodes including cluster head send 4000bit data in each round)
           distance;
            if (distance>do)
                S(i).E=S(i).E- ( (ETX+EDA)*(4000) + Emp*4000*( distance*distance*distance*distance )); 
            end
            if (distance<=do)
                S(i).E=S(i).E- ( (ETX+EDA)*(4000)  + Efs*4000*( distance * distance )); 
            end
        end     
    
    end
    % S(i).G=S(i).G-1;  
   
 end 
end
STATISTICS.COUNTCHS(r+1)=countCHs;
%cluster members choose cluster head
for c=1:1:cluster-1
    x(c)=0;
end
y=0;
z=0;
for i=1:1:n
   if ( S(i).type=='N' && S(i).E>0 )
     if(cluster-1>=1)
       min_dis=Inf;
       min_dis_cluster=0;
       for c=1:1:cluster-1
           temp=min(min_dis,sqrt( (S(i).xd-C(c).xd)^2 + (S(i).yd-C(c).yd)^2 ) );
           if ( temp<min_dis )
               min_dis=temp;
               min_dis_cluster=c;
               x(c)=x(c)+1;
           end
       end
       %Energy consumption of cluster nodes (sending 4000bit data)
            min_dis;
            if (min_dis>do)
                S(i).E=S(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis)); 
            end
            if (min_dis<=do)
                S(i).E=S(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
            end
        %Energy Consumption of Cluster Head (Accepting and fusing 4000bit data of cluster nodes)
            S(C(min_dis_cluster).id).E = S(C(min_dis_cluster).id).E- ( (ERX + EDA)*4000 ); 
            packets_TO_CH=packets_TO_CH+1;

       S(i).min_dis=min_dis;
       S(i).min_dis_cluster=min_dis_cluster;
   else
         y=y+1;
          min_dis=sqrt( (S(i).xd-S(n+1).xd)^2 + (S(i).yd-S(n+1).yd)^2 );
            if (min_dis>do)
                S(i).E=S(i).E- ( ETX*(4000) + Emp*4000*( min_dis * min_dis * min_dis * min_dis)); 
            end
            if (min_dis<=do)
                S(i).E=S(i).E- ( ETX*(4000) + Efs*4000*( min_dis * min_dis)); 
            end
            packets_TO_BS=packets_TO_BS+1;
    end
  end
end
if countCHs~=0
   u=(n-y)/countCHs;
for c=1:1:cluster-1
    z=(x(c)-u)*(x(c)-u)+z;
end
LBF(r+1)=countCHs/z;
else  LBF(r+1)=0;
end
STATISTICS.PACKETS_TO_CH(r+1)=packets_TO_CH;
STATISTICS.PACKETS_TO_BS(r+1)=packets_TO_BS;
end
first_dead
teenth_dead
all_dead
STATISTICS.DEAD(r+1)
STATISTICS.ALLIVE(r+1)
STATISTICS.PACKETS_TO_CH(r+1)
STATISTICS.PACKETS_TO_BS(r+1)
STATISTICS.COUNTCHS(r+1)
r=0:5000;
plot(r,STATISTICS.DEAD);
xlabel('$run\quad times$', 'Interpreter', 'latex', 'FontSize', 16)
ylabel('$number\quad of\quad dead\quad node$', 'Interpreter', 'latex', 'FontSize', 16)
