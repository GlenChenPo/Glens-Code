Lab2 的內容是要打出以前上課很喜歡跟同學玩的遊戲 Bulls and Cows 就是幾A幾B  
但條件當然沒有這麼簡單，數字不只四個每個數字也不像原本只有0~9  
Input會給keyboard八個數字 anwser五個數字 weight五個數字 match target兩個數字  
我們要從keyboard中取五個數字來達到 match target 所表示的幾A幾B情況  
收回前言這次lab好難，能感受到lab1跟lab2難度有大幅落差  
遊戲本身不算難，但難在依 spec 設定正解是5-digit而每一格的數字範圍是 5 bits  
數字越多條件式要打越多挺煩，又有特殊情況corner case要照助教提供的方法來取   
而且後來又再新發現更多corner case，所以助教的Exercise.pdf最後出到了ver3  
打一打以為打完了又出現corner case真的超絕望，判斷式越來越多  
我的作法是先從八個數字裡面判斷哪五個是正確的數字哪三個是錯的數字  
照SPEC五個Anwser都會出現在keyboard中，所以八取五最多只有可能到2A0B或0A2B不會有1A以下的情況  
而5A、4A都比較好做判斷，但3A、2A的情況實在太多種了，當時我們就開始討論覺得根本就打不完  
但後來我們想到了解法，有點算窮舉吧，我們直接將所有排列組合都輸入進去  
當那組數字符合match target，將他乘上weight後跟前一筆存下來的數字比大小  
而大的就留著，等於最後會將所有排列組合都刷過一遍留下確定為anwer的答案  
這樣的打法雖然行數蠻多的，但用python直接產生也不用我自己手打  
而且這個方法簡單又完善，因為把所有的組合都拿來做比較了所以不會有corner case的問題  
唯一的缺點就是latency較大，但是當時真的打得出來1demo就覺得很感動了  

![image](https://github.com/GlenChenPo/Pictures/blob/main/Lab02.png)
