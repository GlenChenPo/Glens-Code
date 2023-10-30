module CC(in_n0,in_n1,in_n2,in_n3,in_n4,in_n5,opt,equ,out_n);

input signed[3:0]in_n0,in_n1,in_n2,in_n3,in_n4,in_n5;
input [2:0] opt;
input equ;
output [9:0] out_n;


reg signed[4:0] n0,n1,n2,n3,n4,n5;
reg signed[4:0] ab0,ab1,ab2,ab3,ab4,ab5;
reg signed[4:0] bc0,bc1,bc2,bc3,bc4,bc5;
reg signed[4:0] cd0,cd1,cd2,cd3;
reg signed[4:0] de0,de1;

reg signed[4:0] n10,n11,n12,n13,n14,n15;
reg signed[4:0] n20,n21,n22,n23,n24,n25;
reg signed[9:0] n30,n31,n32,n33,n34,n35;
reg signed[9:0] out;
reg signed[9:0] out_n;
//==================================================================


always@(*)
begin
    if (opt[0]==0)
    begin
        n0={1'b0,in_n0[3:0]};
        n1={1'b0,in_n1[3:0]};
        n2={1'b0,in_n2[3:0]};
        n3={1'b0,in_n3[3:0]};
        n4={1'b0,in_n4[3:0]};
        n5={1'b0,in_n5[3:0]};
    end
    else
    begin
        if (in_n0[3]==0)
        begin
            n0={1'b0,in_n0[3:0]};
        end
        else
        begin
            n0={1'b1,in_n0[3:0]};
        end

        if (in_n1[3]==0)
        begin
            n1={1'b0,in_n1[3:0]};
        end
        else
        begin
            n1={1'b1,in_n1[3:0]};
        end
        if (in_n2[3]==0)
        begin
            n2={1'b0,in_n2[3:0]};
        end
        else
        begin
            n2={1'b1,in_n2[3:0]};
        end
        if (in_n3[3]==0)
        begin
            n3={1'b0,in_n3[3:0]};
        end
        else
        begin
            n3={1'b1,in_n3[3:0]};
        end
        if (in_n4[3]==0)
        begin
            n4={1'b0,in_n4[3:0]};
        end
        else
        begin
            n4={1'b1,in_n4[3:0]};
        end
        if (in_n5[3]==0)
        begin
            n5={1'b0,in_n5[3:0]};
        end
        else
        begin
            n5={1'b1,in_n5[3:0]};
        end


    end


    //==========partA======================================================================================
    if (n0<=n1)
    begin
        ab0=n0;
        ab1=n1;
    end
    else
    begin
        ab0=n1;
        ab1=n0;
    end
    if (n2<=n3)
    begin
        ab2=n2;
        ab3=n3;
    end
    else
    begin
        ab2=n3;
        ab3=n2;
    end
    if (n4<=n5)
    begin
        ab4=n4;
        ab5=n5;
    end
    else
    begin
        ab4=n5;
        ab5=n4;
    end

    //==========partB======================================================================================
    if (ab0<=ab2)
    begin
        bc0=ab0;
        bc1=ab2;
    end
    else
    begin
        bc0=ab2;
        bc1=ab0;
    end
    if (ab1<=ab4)
    begin
        bc2=ab1;
        bc3=ab4;
    end
    else
    begin
        bc2=ab4;
        bc3=ab1;
    end
    if (ab3<=ab5)
    begin
        bc4=ab3;
        bc5=ab5;
    end
    else
    begin
        bc4=ab5;
        bc5=ab3;
    end
    //==========partC======================================================================================
    if (bc0<=bc2)
    begin
        n10=bc0;
        cd0=bc2;
    end
    else
    begin
        n10=bc2; //n10
        cd0=bc0;
    end
    if (bc1<=bc4)
    begin
        cd1=bc1;
        cd2=bc4;
    end
    else
    begin
        cd1=bc4;
        cd2=bc1;
    end
    if (bc3<=bc5) //n15
    begin
        cd3=bc3;
        n15=bc5;
    end
    else
    begin
        cd3=bc5;
        n15=bc3;
    end
    //==========partD======================================================================================
    if (cd0<=cd1) //n11
    begin
        n11=cd0;
        de0=cd1;
    end
    else
    begin
        n11=cd1;
        de0=cd0;
    end
    if (cd2<=cd3) //n14
    begin
        de1=cd2;
        n14=cd3;
    end
    else
    begin
        de1=cd3;
        n14=cd2;
    end
    //==========partE======================================================================================
    if (de0<=de1) //n12 n13
    begin
        n12=de0;
        n13=de1;
    end
    else
    begin
        n12=de1;
        n13=de0;
    end



end

always @(*)
begin
    //-------------opt[1]---------------------
    if (opt[1]==1) //large to small
    begin
        n20=n15;
        n21=n14;
        n22=n13;
        n23=n12;
        n24=n11;
        n25=n10;
    end
    else
    begin//small to large
        n20=n10;
        n21=n11;
        n22=n12;
        n23=n13;
        n24=n14;
        n25=n15;
    end
    //------------opt[2]----------------------
    if(opt[2]==1)
    begin
        n30=n20;
        n31=(n30*2+n21)/3;
        n32=(n31*2+n22)/3;
        n33=(n32*2+n23)/3;
        n34=(n33*2+n24)/3;
        n35=(n34*2+n25)/3;

    end
    else
    begin//(opt[2]==0)
        n30=0;
        n31=n21-n20;
        n32=n22-n20;
        n33=n23-n20;
        n34=n24-n20;
        n35=n25-n20;
    end
end
//------------------------eq0 & eq1---------
always @(*)
begin
    if (equ==0)//eq0=((n3+n4*4)*n5)/3
    begin
        out_n=((n33+n34*4)*n35)/3;
    end

    else       //eq1=|n5*(n1-n0)|
    begin
        out=n35*(n31-n30);
        if (out[9]==0)//n5*(n1-n0) is positive
        begin
            out_n=out;
        end

        else //n5*(n1-n0) is negative
        begin
            out_n=~out+1;
        end
    end
end




endmodule
