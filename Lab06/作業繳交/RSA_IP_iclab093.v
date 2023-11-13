//############################################################################
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//   File Name   : RSA_IP.v
//   Module Name : RSA_IP
//++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
//############################################################################

module RSA_IP #(parameter WIDTH = 3) (
           // Input signals
           IN_P, IN_Q, IN_E,
           // Output signals
           OUT_N, OUT_D
       );

// ===============================================================
// Declaration
// ===============================================================
input  [WIDTH-1:0]   IN_P, IN_Q;
input  [WIDTH*2-1:0] IN_E;
output reg [WIDTH*2-1:0] OUT_N, OUT_D;

// ===============================================================
// Soft IP DESIGN
// ===============================================================
reg  [WIDTH*2-1:0] PhiN;
reg  [WIDTH*2-1:0] R[0:7] , Q[0:7] , A[0:7] , B[0:7];
reg signed [WIDTH*2-1:0] T[0:7] , T1[0:7] , T2[0:7];
// reg signed [WIDTH*2-1:0] D;

always @(*)
begin
    PhiN = (IN_P-1) * (IN_Q-1) ;
end

genvar i;
generate
    for ( i=0 ; i<8 ; i=i+1 )
    begin : loop_1
        if (i==0)
        begin
            always @(*)
            begin
                T1[0] = 1'b0 ;
                T2[0] = 1'b1 ;
                A[0] = PhiN ;
                B[0] = IN_E ;
                R[0] = A[0]%B[0] ;
                Q[0] = A[0]/B[0] ;
                T[0] = T1[0]-Q[0]*T2[0] ;
            end
        end
        else
        begin
            always @(*)
            begin
                if (R[i-1]!=0)
                begin
                    A[i] = B[i-1];
                    B[i] = R[i-1];
                    T1[i] = T2[i-1];
                    T2[i] = T[i-1];

                    R[i] = A[i]%B[i] ;
                    Q[i] = A[i]/B[i] ;
                    T[i] = T1[i] - Q[i]*T2[i] ;
                end
                else
                begin
                    A[i] = A[i-1];
                    B[i] = B[i-1];
                    T1[i] = T1[i-1];
                    T2[i] = T2[i-1];

                    R[i] = 0;
                    Q[i] = Q[i-1] ;
                    T[i] = T[i-1] ;
                end
            end
        end
    end
endgenerate
//-------------- output D ---------------------
always @(*)
begin
    if (R[1]==0)
    begin
        if (T2[1][WIDTH*2-1])
            OUT_D = T2[1] + PhiN ;
        else
            OUT_D = T2[1];
    end
    else if (R[2]==0)
    begin
        if (T2[2][WIDTH*2-1])
            OUT_D = T2[2] + PhiN ;
        else
            OUT_D = T2[2];
    end
    else if (R[3]==0)
    begin
        if (T2[3][WIDTH*2-1])
            OUT_D = T2[3] + PhiN ;
        else
            OUT_D = T2[3];
    end
    else if (R[4]==0)
    begin
        if (T2[4][WIDTH*2-1])
            OUT_D = T2[4] + PhiN ;
        else
            OUT_D = T2[4];
    end
    else if (R[5]==0)
    begin
        if (T2[5][WIDTH*2-1])
            OUT_D = T2[5] + PhiN ;
        else
            OUT_D = T2[5];
    end
    else if (R[6]==0)
    begin
        if (T2[6][WIDTH*2-1])
            OUT_D = T2[6] + PhiN ;
        else
            OUT_D = T2[6];
    end
    else if (R[7]==0)
    begin
        if (T2[7][WIDTH*2-1])
            OUT_D = T2[7] + PhiN ;
        else
            OUT_D = T2[7];
    end
    else
    begin
        OUT_D = 0;
    end
end
//-------------- output N ---------------------
always @(*)
begin
    OUT_N = IN_P * IN_Q ;
end

endmodule
