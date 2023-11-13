1. All the files have been sorted. Please put those files into corresponding dictory.
2. Set 3 types of latency in "pseudo_DRAM.sv" equal to "1"
3. The file with "_assertion_X" suffix means that it violates Xth assertion.
4. The file with "_wrong" suffix means that it is the wrong design.
5. There will be some errors after encrypting CHECKER. So we cannot provide the whole encrypted file.
   However, since the coverage part is very similar, we decide to provide the unencrypted version of this part, you can use it directly.

========================================

Coverage: (TA’s corrent DESIGN + TA’s CHECKER + Your PATTERN)
1. Use your own dram.dat
2. run "./02_run_conv". There should be Coverage 1~5 Pass shown on the terminal. "Wrong Answer" should not be shown on the terminal.
3. run "python assertion_6.py", out.txt will be generated. You can not have "fail" inside out.txt.
4. Replace TA’s correct DESIGN with wrong design. Your PATTERN should show "Wrong Answer" on the terminal.

wrong_1 : When successfully use bracer, the effect will not disappear in any situations. 
wrong_2 : 1. When successfully buy evolutionary stone, the status of bag doesn't update. 
          2. When successfully sell evolutionary stone, the status of bag is wrong.

========================================

Assertion: (TA’s DESIGN + TA’s PATTERN+ Your CHECKER)
1. Use TA's dram.dat
2. Replace the original file with the one has "_assertion_X" suffix, and then run "./01_run". 
   Your CHECKER should show "Assertion X is violated" on the terminal.



21 C0 5E 00 中等 草

12 77 40 00 low fire

24 BB 59 00 中等 水

28 B6 61 00 中等 電

42 E1 7F 00 