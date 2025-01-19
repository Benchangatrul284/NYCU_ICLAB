# NYCU_ICLAB

## 概述
- 課程名稱：積體電路設計實驗
- 選修年度：113上


## 個人成績資訊
- 原始分數：96.37
- 等第：A+
- 結算名次：27 / 173
  
|      | Lab01  | Lab02 | Lab03 | Lab04 | Lab05 | Lab06 |OT |    MIDTERM PROJECT | MID EXAM |
| ------------|:------:|:-----:|:-----:|:-----:|:-----:|:-----:|:--------------:|:-----:|:-------:|
| Score       |78.38|95.91|97.93|91.91|86.45|86.36|100|99.15|100|
-------------------------
|     | Lab07  | Lab08 | Lab09 | Lab10 | Lab11 | Lab12 | Bonus|   FINAL PROJECT  | FINAL EXAM |
| ------------|:------:|:-----:|:-----:|:-----:|:-----:|:-----:|:--------------:|:-----:|:-------:|
| Score       |97.17|90.85|82.22|90.22|56.56|100|100|97.54|100|


## 背景
我在大四上學期的時候在同學的慫恿下修了這堂課，在修 ICLAB 前有修了邏設、數電、計組，並和 ICLAB 同一個學期修了 VLSI。我和身邊周遭朋友不太一樣的點在於我在大二的時候原先是要做類比的，但後來因緣際會下找了數位教授。因此，數電、計組和 VLSI 都晚別人一年修。我在大三下才修數電，計組甚至是大三升大四的暑假時修課的。我認為 ICLAB 不太需要甚麼先修課程或先備知識。如果硬要說，我認為這堂課最重要的先修課應該是數電，但數電也只能幫你快速上手 verilog 等等基本語法。其他數位課 (尤其 VLSI) 重要性沒有那麼高，但修課前一定要確保這學期沒有其他很花時間的課程不然會天天熬夜。

## 會學到甚麼
我修課前爬了很多文說修完這堂課會學到數位 IC 基本的 design flow，但說來慚愧，我修完後發現我只會打 RTL code，02 合成和之後的 APR 等等基本上助教都幫我們包好了，因此對於一些指令的細節不是很了解，會是未來需要精進的地方。

## 修課前應該知道的事情
*  Verilog 是硬體描述語言  
    這段話我相信各位已經聽到爛掉了，但是我從數電到計組再到 ICLAB 每次的修課都對這句話有所體悟。在數電，我到期中才知道要把 combinational circuit 和 sequential circuit 分開寫。曾經還寫過這個語法:
    ```verilog
    always_comb begin
        a = a;
    end
    ```
    然後自以為可以把 data 存下來，結果室友拿了一條充電線然後把兩端皆在一起然後問我: 你覺得這樣有意義嗎? 我才恍然大悟如果要存資料，就會需要 sequential circuit。所以之後都會先問自己要存那些資料，然後再開始打扣。
    ```verilog
    always_ff @(posedge clk) begin
        a <= a_next;
    end
    always_comb begin
        a_next = ...
    end
    ```
    修完數電後，我在升大四的暑假修了資工系的計組，計組後面的作業要打 verilog 做 pipeline CPU，因為助教已經幫我們把一部分的模板打好了，我們要做的事就是去完成一些 submodule 像是 ALU、program counter 等等，然後將這些 submodule 接線接起來。雖然沒有跑合成，但因為確確實實有把各個 submodule 接線接起來，因此對於用了多少硬體會比只打 behavior code 會更有概念。

    修完計組後就是 ICLAB 了，ICLAB 前面的幾個 lab 就是照著 spec 去刻 RTL，Lab4 和 Lab5 比較複雜會花蠻多時間去排哪個 cycle 要做甚麼事。但我在 Lab 4 、Lab5 和朋友討論完架構和演算法後各自回去打扣發現我合成出來的面積都比他大兩到三倍。後來才發現 coding style 會嚴重影響到 performance。最後在期末總結出了下面幾個結論: 
    1. 要把 always block 拆掉。不能在打完後再拆，而是在打扣得當下就要用拆掉的思維去想。這樣做的好處是每個訊號會獨立不會受到其他訊號的影響，就不需要寫一堆額外的條件增加面積。
    2. 避免太多層的 if-else 或是 case statement:  
    這個可以舉一個很簡單的例子:
    ```verilog
    always_comb begin
        case (current_state)
        IDLE: begin
            ...
        end
        COMPUTE: begin
            if (cnt == 8) begin
                a_next = a + 1;
            end
        end
        endcase
    end
    ```
    如果在 IDLE state 且 cnt == 8 時 a 這個 register 值的改變不會影響答案，那就可以把 ```a_next = a + 1;``` 拉出來。
    ```verilog
    always_comb begin
        if (cnt == 8) begin
            a_next = a + 1;
        end
    end
    ```
    這樣可以讓 path 更短 (因為少經過一個 mux)，電路更快，如果這條剛好是 critical path 也許還能讓電路面積更小。再加上前面把每個 always block 拆掉，做這樣的改動會非常迅速。

    但改成這樣的打法後已經為時已晚，只剩下 Lab9 和期中期末專題而已，而 Lab 9 我又比其他人多開了一個除法器，performance 直接爆掉，所以樣本數偏少。但不論如何這樣的打法對於 design compiler 也比較友善。

* 1 DE 才是重點  
    這堂課的 Lab 會在禮拜三公布，然後禮拜一 1de，禮拜三 2de，時間挺趕的。如果不幸 2de 的話成績會直接打 7 折非常難受 (像是我的Lab 11)。如果只為了成績的話，推薦不要太追 performance 穩穩抓 1de 即可，早早打完拿更多 edge case 去驗證 design 的正確性，早早休息準備下次 Lab。另外，有些比較複雜的 Lab 只能打一版的扣，所以打之前要先想好架構和評估一下面積也要評估一下 design 會不會太複雜導致來不及完成，一個 bit 的 register 面積大概是 50 左右，可以用這個去推算是否值得用 SRAM。(SRAM 一次只能讀寫一個 address，面積大概是 register 的一半)
