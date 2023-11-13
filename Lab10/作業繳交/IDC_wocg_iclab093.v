module IDC(
           // Input signals
           clk,
           rst_n,
           in_valid,
           in_data,
           op,
           // Output signals
           out_valid,
           out_data
       );


// INPUT AND OUTPUT DECLARATION
input		clk;
input		rst_n;
input		in_valid;
input signed [6:0] in_data;
input [3:0] op;

output reg 		  out_valid;//
output reg  signed [6:0] out_data;


//================================================================
//  FSM parameter
//================================================================
parameter S_IDLE       = 5'd0 ;
parameter S_INPUT      = 5'd1 ;
parameter S_HOME       = 5'd2 ;
parameter S_CALC       = 5'd3 ;
parameter S_OUTPUT     = 5'd4 ;

reg [6:0]  c_s , n_s;


//================================================================
// Wire & Reg Declaration
//================================================================
//store input
reg [3:0] operation [0:14];
reg signed [6:0] Map [0:7] [0:7];
// reg [1:0] shift[0:7];
// reg [2:0] Xaxis,Yaxis;

// temp
// reg signed [6:0] temp_map[0:3];

reg signed [6:0] a1,b1;
reg signed [6:0] a2,b2;
reg signed [7:0] sum_2;
reg signed [8:0] sum_4;
reg signed [6:0] aver_2;
reg signed [6:0] aver_4;


reg  signed [6:0] dataOUT;
// cnt
reg [6:0] cnt_1;// cnt for in_valid
reg [3:0] cnt_2;
// reg [9:0] cnt_3;//counter
reg [4:0] cnt_op;
reg [2:0] cnt_X;
reg [2:0] cnt_Y;
reg [4:0] cnt_action;
// pin
reg [2:0] pinX,pinY;
reg [2:0] pinX_p1,pinY_p1;

//flag
reg flag_1;

//---------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        c_s <= S_IDLE;
    else
        c_s <= n_s;
end

always @(*)
begin
    case (c_s)
        S_IDLE:
        begin
            if (in_valid)
                n_s = S_INPUT;
            else
                n_s = S_IDLE;
        end
        S_INPUT:
        begin
            if (cnt_op==5)
                n_s = S_HOME;
            else
                n_s = S_INPUT;
        end
        S_HOME:
        begin
            if (cnt_action==15 && cnt_1>=63)
                n_s = S_OUTPUT;
            else
                n_s = S_HOME;
        end
        // S_CALC:
        //     if(flag_1)
        //         n_s = S_OUTPUT;
        //     else
        //         n_s = S_CALC;
        S_OUTPUT:
            if(cnt_2==15)
                n_s = S_IDLE;
            else
                n_s = S_OUTPUT;

        default:
            n_s = S_IDLE;
    endcase
end


//---------------------------------------------------------------------
//    Counter
//---------------------------------------------------------------------
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        cnt_op <= 0;
    else if (c_s==S_OUTPUT)
        cnt_op <= 0;
    else
    begin
        if(cnt_op==16)
            cnt_op <= 16;
        else if(in_valid && cnt_1<=63)
            cnt_op <= cnt_op + 1;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        cnt_X <= 0;
    end
    else
    begin
        if(in_valid && cnt_1<=63)
            cnt_X <= cnt_X + 1;
    end
end
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        cnt_Y <= 0;
    end
    else
    begin
        if(in_valid && cnt_1<=63)
        begin
            if (cnt_X==7)
            begin
                cnt_Y <= cnt_Y + 1;
            end
        end
    end
end


always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        cnt_2 <= 0;
    end
    else
    begin
        if(c_s==S_OUTPUT)
            cnt_2 <= cnt_2 + 1;
        else if(c_s==S_IDLE)
            cnt_2 <= 0;
    end
end

always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        cnt_1 <= 0;
    end
    else if(in_valid  && cnt_1<=63)
        cnt_1 <= cnt_1 + 1;
    else if(c_s==S_IDLE)
        cnt_1 <= 0;
end




//================================================================
//     Input
//================================================================
integer i,j,k;


always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        for ( j=0 ;j<=7;j=j+1 )
        begin
            for ( k=0 ;k<=7 ;k=k+1 )
            begin
                Map[j][k] <= 0;
            end
        end
    end
    else if (in_valid && cnt_action<15)
    begin
        if (pinY_p1<cnt_Y)
        begin
            if (operation[cnt_action]==0)
            begin
                Map[cnt_Y][cnt_X]     <= in_data;
                Map[pinY][pinX]       <= aver_2;
                Map[pinY][pinX_p1]    <= aver_2;
                Map[pinY_p1][pinX]    <= aver_2;
                Map[pinY_p1][pinX_p1] <= aver_2;

            end
            else if (operation[cnt_action]==1)
            begin
                Map[cnt_Y][cnt_X]     <= in_data;
                Map[pinY][pinX]       <= aver_4;
                Map[pinY][pinX_p1]    <= aver_4;
                Map[pinY_p1][pinX]    <= aver_4;
                Map[pinY_p1][pinX_p1] <= aver_4;
            end
            else if (operation[cnt_action]==2) // rotate c.clkwise
            begin
                Map[cnt_Y][cnt_X]     <= in_data;
                Map[pinY][pinX]       <= Map[pinY][pinX_p1];
                Map[pinY][pinX_p1]    <= Map[pinY_p1][pinX_p1];
                Map[pinY_p1][pinX]    <= Map[pinY][pinX];
                Map[pinY_p1][pinX_p1] <= Map[pinY_p1][pinX];
            end
            else if (operation[cnt_action]==3) // rotate clkwise
            begin
                Map[cnt_Y][cnt_X]     <= in_data;
                Map[pinY][pinX]       <= Map[pinY_p1][pinX];
                Map[pinY][pinX_p1]    <= Map[pinY][pinX];
                Map[pinY_p1][pinX]    <= Map[pinY_p1][pinX_p1];
                Map[pinY_p1][pinX_p1] <= Map[pinY][pinX_p1];
            end
            else if (operation[cnt_action]==4) // Flip *-1
            begin
                Map[cnt_Y][cnt_X]     <= in_data;
                Map[pinY][pinX]       <= (-1)*Map[pinY][pinX];
                Map[pinY][pinX_p1]    <= (-1)*Map[pinY][pinX_p1];
                Map[pinY_p1][pinX]    <= (-1)*Map[pinY_p1][pinX];
                Map[pinY_p1][pinX_p1] <= (-1)*Map[pinY_p1][pinX_p1];
            end
            else
            begin
                Map[cnt_Y][cnt_X]     <= in_data;
            end
        end
        else if (pinY_p1==cnt_Y && pinX_p1<cnt_X)
        begin
            if (operation[cnt_action]==0)
            begin
                Map[cnt_Y][cnt_X]     <= in_data;
                Map[pinY][pinX]       <= aver_2;
                Map[pinY][pinX_p1]    <= aver_2;
                Map[pinY_p1][pinX]    <= aver_2;
                Map[pinY_p1][pinX_p1] <= aver_2;

            end
            else if (operation[cnt_action]==1)
            begin
                Map[cnt_Y][cnt_X]     <= in_data;
                Map[pinY][pinX]       <= aver_4;
                Map[pinY][pinX_p1]    <= aver_4;
                Map[pinY_p1][pinX]    <= aver_4;
                Map[pinY_p1][pinX_p1] <= aver_4;
            end
            else if (operation[cnt_action]==2) // rotate c.clkwise
            begin
                Map[cnt_Y][cnt_X]     <= in_data;
                Map[pinY][pinX]       <= Map[pinY][pinX_p1];
                Map[pinY][pinX_p1]    <= Map[pinY_p1][pinX_p1];
                Map[pinY_p1][pinX]    <= Map[pinY][pinX];
                Map[pinY_p1][pinX_p1] <= Map[pinY_p1][pinX];
            end
            else if (operation[cnt_action]==3) // rotate clkwise
            begin
                Map[cnt_Y][cnt_X]     <= in_data;
                Map[pinY][pinX]       <= Map[pinY_p1][pinX];
                Map[pinY][pinX_p1]    <= Map[pinY][pinX];
                Map[pinY_p1][pinX]    <= Map[pinY_p1][pinX_p1];
                Map[pinY_p1][pinX_p1] <= Map[pinY][pinX_p1];
            end
            else if (operation[cnt_action]==4) // Flip *-1
            begin
                Map[cnt_Y][cnt_X]     <= in_data;
                Map[pinY][pinX]       <= (-1)*Map[pinY][pinX];
                Map[pinY][pinX_p1]    <= (-1)*Map[pinY][pinX_p1];
                Map[pinY_p1][pinX]    <= (-1)*Map[pinY_p1][pinX];
                Map[pinY_p1][pinX_p1] <= (-1)*Map[pinY_p1][pinX_p1];
            end
            else
            begin
                Map[cnt_Y][cnt_X]     <= in_data;
            end
        end
        else
        begin
            Map[cnt_Y][cnt_X] <= in_data;
        end
    end
    else if (in_valid && cnt_1<=63)
    begin
        Map[cnt_Y][cnt_X] <= in_data;
    end
    else if (cnt_1>63 && cnt_action<15)
    begin
        if (operation[cnt_action]==0)
        begin
            Map[pinY][pinX]       <= aver_2;
            Map[pinY][pinX_p1]    <= aver_2;
            Map[pinY_p1][pinX]    <= aver_2;
            Map[pinY_p1][pinX_p1] <= aver_2;

        end
        else if (operation[cnt_action]==1)
        begin
            Map[pinY][pinX]       <= aver_4;
            Map[pinY][pinX_p1]    <= aver_4;
            Map[pinY_p1][pinX]    <= aver_4;
            Map[pinY_p1][pinX_p1] <= aver_4;
        end
        else if (operation[cnt_action]==2) // rotate c.clkwise
        begin
            Map[pinY][pinX]       <= Map[pinY][pinX_p1];
            Map[pinY][pinX_p1]    <= Map[pinY_p1][pinX_p1];
            Map[pinY_p1][pinX]    <= Map[pinY][pinX];
            Map[pinY_p1][pinX_p1] <= Map[pinY_p1][pinX];
        end
        else if (operation[cnt_action]==3) // rotate clkwise
        begin
            Map[pinY][pinX]       <= Map[pinY_p1][pinX];
            Map[pinY][pinX_p1]    <= Map[pinY][pinX];
            Map[pinY_p1][pinX]    <= Map[pinY_p1][pinX_p1];
            Map[pinY_p1][pinX_p1] <= Map[pinY][pinX_p1];
        end
        else if (operation[cnt_action]==4) // Flip *-1
        begin
            Map[pinY][pinX]       <= (-1)*Map[pinY][pinX];
            Map[pinY][pinX_p1]    <= (-1)*Map[pinY][pinX_p1];
            Map[pinY_p1][pinX]    <= (-1)*Map[pinY_p1][pinX];
            Map[pinY_p1][pinX_p1] <= (-1)*Map[pinY_p1][pinX_p1];
        end
    end
    else if (c_s==S_IDLE)
    begin
        for ( j=0 ;j<=7;j=j+1 )
        begin
            for ( k=0 ;k<=7 ;k=k+1 )
            begin
                Map[j][k] <= 0;
            end
        end
    end
end

//================================================================
//     MAIN CIRCUIT
//================================================================
// pin
always @(*)
begin
    pinX_p1 = pinX + 1;
    pinY_p1 = pinY + 1;
end
always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
    begin
        pinX <= 0;
        pinY <= 0;
    end
    else if (cnt_op==5)
    begin
        pinX <= 3;
        pinY <= 3;
    end
    else if (c_s==S_HOME)
    begin
        if (cnt_1>63)
        begin
            if (operation[cnt_action]==5)     //shift up
            begin
                if (pinY==0)
                    pinY <= pinY;
                else
                    pinY <= pinY - 1;
            end
            else if (operation[cnt_action]==6)//shift left
            begin
                if (pinX==0)
                    pinX <= pinX;
                else
                    pinX <= pinX - 1;
            end
            else if (operation[cnt_action]==7)//shift down
            begin
                if (pinY==6)
                    pinY <= pinY;
                else
                    pinY <= pinY + 1;
            end
            else if (operation[cnt_action]==8)//shift right
            begin
                if (pinX==6)
                    pinX <= pinX;
                else
                    pinX <= pinX + 1;
            end
        end
        else if (pinY_p1<cnt_Y)
        begin
            if (operation[cnt_action]==5)     //shift up
            begin
                if (pinY==0)
                    pinY <= pinY;
                else
                    pinY <= pinY - 1;
            end
            else if (operation[cnt_action]==6)//shift left
            begin
                if (pinX==0)
                    pinX <= pinX;
                else
                    pinX <= pinX - 1;
            end
            else if (operation[cnt_action]==7)//shift down
            begin
                if (pinY==6)
                    pinY <= pinY;
                else
                    pinY <= pinY + 1;
            end
            else if (operation[cnt_action]==8)//shift right
            begin
                if (pinX==6)
                    pinX <= pinX;
                else
                    pinX <= pinX + 1;
            end
        end
        else if (pinY_p1==cnt_Y && pinX_p1<cnt_X)
        begin
            if (operation[cnt_action]==5)     //shift up
            begin
                if (pinY==0)
                    pinY <= pinY;
                else
                    pinY <= pinY - 1;
            end
            else if (operation[cnt_action]==6)//shift left
            begin
                if (pinX==0)
                    pinX <= pinX;
                else
                    pinX <= pinX - 1;
            end
            else if (operation[cnt_action]==7)//shift down
            begin
                if (pinY==6)
                    pinY <= pinY;
                else
                    pinY <= pinY + 1;
            end
            else if (operation[cnt_action]==8)//shift right
            begin
                if (pinX==6)
                    pinX <= pinX;
                else
                    pinX <= pinX + 1;
            end
        end
    end
    else if (c_s==S_IDLE)
    begin
        pinX <= 0;
        pinY <= 0;
    end
end


always @(posedge clk or negedge rst_n)
begin
    if (!rst_n)
        cnt_action <= 0;
    else// if(n_action)
    begin
        if (c_s==S_IDLE)
            cnt_action <= 0;

        else if (cnt_action==15)
            cnt_action <= cnt_action;

        else if (cnt_1>63)
            cnt_action <= cnt_action + 1;

        else if (c_s==S_HOME)
        begin
            if (pinY_p1<cnt_Y)
            begin
                if (operation[cnt_action]<=8)
                    cnt_action <= cnt_action + 1;
            end
            else if (pinY_p1==cnt_Y && pinX_p1<cnt_X)
            begin
                if (operation[cnt_action]<=8)
                    cnt_action <= cnt_action + 1;
            end
            else
                cnt_action <= cnt_action;
        end
    end
end
//================================================================
//     Combination
//================================================================
always @(*)
begin
    if (Map[pinY][pinX] >= Map[pinY][pinX_p1])
    begin
        if (Map[pinY_p1][pinX] >= Map[pinY_p1][pinX_p1])
        begin
            a1 = Map[pinY][pinX];
            a2 = Map[pinY_p1][pinX];
            b1 = Map[pinY][pinX_p1];
            b2 = Map[pinY_p1][pinX_p1];
        end
        else if(Map[pinY_p1][pinX] < Map[pinY_p1][pinX_p1])
        begin
            a1 = Map[pinY][pinX];
            a2 = Map[pinY_p1][pinX_p1];
            b1 = Map[pinY][pinX_p1];
            b2 = Map[pinY_p1][pinX];
        end
        else
        begin
            a1 = 0;
            a2 = 0;
            b1 = 0;
            b2 = 0;
        end
    end
    else if(Map[pinY][pinX] < Map[pinY][pinX_p1])
    begin
        if (Map[pinY_p1][pinX] >= Map[pinY_p1][pinX_p1])
        begin
            a1 = Map[pinY][pinX_p1];
            a2 = Map[pinY_p1][pinX];
            b1 = Map[pinY][pinX];
            b2 = Map[pinY_p1][pinX_p1];
        end
        else if(Map[pinY_p1][pinX] < Map[pinY_p1][pinX_p1])
        begin
            a1 = Map[pinY][pinX_p1];
            a2 = Map[pinY_p1][pinX_p1];
            b1 = Map[pinY][pinX];
            b2 = Map[pinY_p1][pinX];
        end
        else
        begin
            a1 = 0;
            a2 = 0;
            b1 = 0;
            b2 = 0;
        end
    end
    else
    begin
        a1 = 0;
        a2 = 0;
        b1 = 0;
        b2 = 0;
    end
end
always @(*)
begin
    if (a1>=a2)
    begin
        if (b1>=b2)
        begin
            sum_2 = a2 + b1;
        end
        else if (b1<b2)
        begin
            sum_2 = a2 + b2;
        end
        else
            sum_2 = 0;
    end
    else if (a1<a2)
    begin
        if (b1>=b2)
        begin
            sum_2 = a1 + b1;
        end
        else if (b1<b2)
        begin
            sum_2 = a1 + b2;
        end
        else
            sum_2 = 0;
    end
    else
        sum_2 = 0;
end

always @(*)
begin
    sum_4 = Map[pinY][pinX] + Map[pinY_p1][pinX] + Map[pinY][pinX_p1] + Map[pinY_p1][pinX_p1];
end
always @(*)
begin
    aver_2 = sum_2 / 2;
    aver_4 = sum_4 / 4;
end

//================================================================
//     Output
//================================================================
always @(*)
begin
    if(out_valid)
        out_data = dataOUT;
    else
        out_data = 0;
end

always @(posedge clk or negedge rst_n)
begin
    if (~rst_n)
    begin
        out_valid <= 0;
        dataOUT <= 0;
    end
    else if(c_s==S_OUTPUT)
    begin
        if (pinX<4 && pinY<4)
        begin
            case (cnt_2)
                0:
                begin
                    out_valid <= 1;
                    dataOUT <= Map[pinY_p1][pinX_p1];
                end
                1:
                    dataOUT <= Map[pinY_p1][pinX_p1+cnt_2];
                2:
                    dataOUT <= Map[pinY_p1][pinX_p1+cnt_2];
                3:
                    dataOUT <= Map[pinY_p1][pinX_p1+cnt_2];
                4:
                    dataOUT <= Map[pinY_p1+1][pinX_p1];
                5:
                    dataOUT <= Map[pinY_p1+1][pinX_p1+1];
                6:
                    dataOUT <= Map[pinY_p1+1][pinX_p1+2];
                7:
                    dataOUT <= Map[pinY_p1+1][pinX_p1+3];
                8:
                    dataOUT <= Map[pinY_p1+2][pinX_p1];
                9:
                    dataOUT <= Map[pinY_p1+2][pinX_p1+1];
                10:
                    dataOUT <= Map[pinY_p1+2][pinX_p1+2];
                11:
                    dataOUT <= Map[pinY_p1+2][pinX_p1+3];
                12:
                    dataOUT <= Map[pinY_p1+3][pinX_p1];
                13:
                    dataOUT <= Map[pinY_p1+3][pinX_p1+1];
                14:
                    dataOUT <= Map[pinY_p1+3][pinX_p1+2];
                15:
                    dataOUT <= Map[pinY_p1+3][pinX_p1+3];
            endcase
        end
        else
        begin
            case (cnt_2)
                0:
                begin
                    out_valid <= 1;
                    dataOUT <= Map[0][0];
                end
                1:
                    dataOUT <= Map[0][2];
                2:
                    dataOUT <= Map[0][4];
                3:
                    dataOUT <= Map[0][6];
                4:
                    dataOUT <= Map[2][0];
                5:
                    dataOUT <= Map[2][2];
                6:
                    dataOUT <= Map[2][4];
                7:
                    dataOUT <= Map[2][6];
                8:
                    dataOUT <= Map[4][0];
                9:
                    dataOUT <= Map[4][2];
                10:
                    dataOUT <= Map[4][4];
                11:
                    dataOUT <= Map[4][6];
                12:
                    dataOUT <= Map[6][0];
                13:
                    dataOUT <= Map[6][2];
                14:
                    dataOUT <= Map[6][4];
                15:
                    dataOUT <= Map[6][6];
            endcase
        end
    end
    else if (c_s==S_IDLE)
    begin
        out_valid <= 0;
        dataOUT <= 0;
    end
end
//==============================================================
//    Operation
//==============================================================
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        operation[0] <= 0;
    else if(in_valid && cnt_op==0)
        operation[0] <= op;
    else if(c_s==S_IDLE)
        operation[0] <= 0;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        operation[1] <= 0;
    else if(in_valid && cnt_op==1)
        operation[1] <= op;
    else if(c_s==S_IDLE)
        operation[1] <= 0;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        operation[2] <= 0;
    else if(in_valid && cnt_op==2)
        operation[2] <= op;
    else if(c_s==S_IDLE)
        operation[2] <= 0;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        operation[3] <= 0;
    else if(in_valid && cnt_op==3)
        operation[3] <= op;
    else if(c_s==S_IDLE)
        operation[3] <= 0;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        operation[4] <= 0;
    else if(in_valid && cnt_op==4)
        operation[4] <= op;
    else if(c_s==S_IDLE)
        operation[4] <= 0;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        operation[5] <= 0;
    else if(in_valid && cnt_op==5)
        operation[5] <= op;
    else if(c_s==S_IDLE)
        operation[5] <= 0;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        operation[6] <= 0;
    else if(in_valid && cnt_op==6)
        operation[6] <= op;
    else if(c_s==S_IDLE)
        operation[6] <= 0;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        operation[7] <= 0;
    else if(in_valid && cnt_op==7)
        operation[7] <= op;
    else if(c_s==S_IDLE)
        operation[7] <= 0;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        operation[8] <= 0;
    else if(in_valid && cnt_op==8)
        operation[8] <= op;
    else if(c_s==S_IDLE)
        operation[8] <= 0;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        operation[9] <= 0;
    else if(in_valid && cnt_op==9)
        operation[9] <= op;
    else if(c_s==S_IDLE)
        operation[9] <= 0;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        operation[10] <= 0;
    else if(in_valid && cnt_op==10)
        operation[10] <= op;
    else if(c_s==S_IDLE)
        operation[10] <= 0;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        operation[11] <= 0;
    else if(in_valid && cnt_op==11)
        operation[11] <= op;
    else if(c_s==S_IDLE)
        operation[11] <= 0;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        operation[12] <= 0;
    else if(in_valid && cnt_op==12)
        operation[12] <= op;
    else if(c_s==S_IDLE)
        operation[12] <= 0;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        operation[13] <= 0;
    else if(in_valid && cnt_op==13)
        operation[13] <= op;
    else if(c_s==S_IDLE)
        operation[13] <= 0;
end
always @(posedge clk or negedge rst_n)
begin
    if(!rst_n)
        operation[14] <= 0;
    else if(in_valid && cnt_op==14)
        operation[14] <= op;
    else if(c_s==S_IDLE)
        operation[14] <= 0;
end

endmodule
