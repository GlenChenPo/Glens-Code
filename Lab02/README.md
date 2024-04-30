收回前言這次lab好難，能感受到lab1跟lab2難度有大幅落差  
遊戲本身不算難，但難在依 spec 設定正解是5-digit而每一格的數字範圍是 5 bits  
數字越多條件式要打越多挺煩，又有特殊情況corner case要照助教提供的方法來取   
而且後來又再新發現更多corner case，所以助教的Exercise.pdf最後出到了ver3    
我的作法是先從八個數字裡面判斷哪五個是正確的數字哪三個是錯的數字  
照SPEC五個Anwser都會出現在keyboard中，這樣keyboard中只有三個多出來的數字，所以A+B >= 2  
而 A+B=5 , A+B=4 的情況比較好做判斷，但A+B=3 A+B=2的情況實在太多種了，當時我們就開始討論覺得根本就打不完  
但後來我們想到了解法，有點算窮舉吧，我們直接將所有排列組合都輸入進去  
當那組數字符合match target，將他乘上weight後跟前一筆存下來的數字比大小  
而大的就留著，等於最後會將所有排列組合都刷過一遍留下確定為anwer的答案  
這樣的打法雖然行數蠻多的，但用python直接產生也不用我自己手打  
而且這個方法簡單又完善，因為把所有的組合都拿來做比較了所以不會有corner case的問題  
唯一的缺點就是latency較大，但至少當時打出來趕上1demo  

![image](https://github.com/GlenChenPo/Pictures/blob/main/Lab02.png)
