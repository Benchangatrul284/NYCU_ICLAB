wvSetPosition -win $_nWave1 {("G1" 0)}
wvOpenFile -win $_nWave1 \
           {/RAID2/COURSE/iclab/iclab085/Lab08/EXERCISE/01_RTL/SA.fsdb}
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/GATED_OR"
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/GATED_OR"
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvSetPosition -win $_nWave1 {("G1" 130)}
wvSetPosition -win $_nWave1 {("G1" 130)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/I_SA/K_matrix\[0:63\]} \
{/TESTBED/I_SA/K_matrix_next\[0:63\]} \
{/TESTBED/I_SA/QKT\[0:63\]} \
{/TESTBED/I_SA/QKT_next\[0:63\]} \
{/TESTBED/I_SA/Q_matrix\[0:63\]} \
{/TESTBED/I_SA/Q_matrix_next\[0:63\]} \
{/TESTBED/I_SA/T\[3:0\]} \
{/TESTBED/I_SA/T_comb\[3:0\]} \
{/TESTBED/I_SA/T_reg\[3:0\]} \
{/TESTBED/I_SA/V_matrix\[0:63\]} \
{/TESTBED/I_SA/V_matrix_next\[0:63\]} \
{/TESTBED/I_SA/add0_a\[63:0\]} \
{/TESTBED/I_SA/add0_b\[63:0\]} \
{/TESTBED/I_SA/add0_out\[63:0\]} \
{/TESTBED/I_SA/add1_a\[63:0\]} \
{/TESTBED/I_SA/add1_b\[63:0\]} \
{/TESTBED/I_SA/add1_out\[63:0\]} \
{/TESTBED/I_SA/add2_a\[63:0\]} \
{/TESTBED/I_SA/add2_b\[63:0\]} \
{/TESTBED/I_SA/add2_out\[63:0\]} \
{/TESTBED/I_SA/add3_a\[63:0\]} \
{/TESTBED/I_SA/add3_b\[63:0\]} \
{/TESTBED/I_SA/add3_out\[63:0\]} \
{/TESTBED/I_SA/add4_a\[63:0\]} \
{/TESTBED/I_SA/add4_b\[63:0\]} \
{/TESTBED/I_SA/add4_out\[63:0\]} \
{/TESTBED/I_SA/add5_a\[63:0\]} \
{/TESTBED/I_SA/add5_b\[63:0\]} \
{/TESTBED/I_SA/add5_out\[63:0\]} \
{/TESTBED/I_SA/add6_a\[63:0\]} \
{/TESTBED/I_SA/add6_b\[63:0\]} \
{/TESTBED/I_SA/add6_out\[63:0\]} \
{/TESTBED/I_SA/add7_a\[63:0\]} \
{/TESTBED/I_SA/add7_b\[63:0\]} \
{/TESTBED/I_SA/add7_out\[63:0\]} \
{/TESTBED/I_SA/add8_a\[63:0\]} \
{/TESTBED/I_SA/add8_b\[63:0\]} \
{/TESTBED/I_SA/add8_out\[63:0\]} \
{/TESTBED/I_SA/add9_a\[63:0\]} \
{/TESTBED/I_SA/add9_b\[63:0\]} \
{/TESTBED/I_SA/add9_out\[63:0\]} \
{/TESTBED/I_SA/add10_a\[63:0\]} \
{/TESTBED/I_SA/add10_b\[63:0\]} \
{/TESTBED/I_SA/add10_out\[63:0\]} \
{/TESTBED/I_SA/add11_a\[63:0\]} \
{/TESTBED/I_SA/add11_b\[63:0\]} \
{/TESTBED/I_SA/add11_out\[63:0\]} \
{/TESTBED/I_SA/add12_a\[63:0\]} \
{/TESTBED/I_SA/add12_b\[63:0\]} \
{/TESTBED/I_SA/add12_out\[63:0\]} \
{/TESTBED/I_SA/add13_a\[63:0\]} \
{/TESTBED/I_SA/add13_b\[63:0\]} \
{/TESTBED/I_SA/add13_out\[63:0\]} \
{/TESTBED/I_SA/add14_a\[63:0\]} \
{/TESTBED/I_SA/add14_b\[63:0\]} \
{/TESTBED/I_SA/add14_out\[63:0\]} \
{/TESTBED/I_SA/add15_a\[63:0\]} \
{/TESTBED/I_SA/add15_b\[63:0\]} \
{/TESTBED/I_SA/add15_out\[63:0\]} \
{/TESTBED/I_SA/cg_en} \
{/TESTBED/I_SA/clk} \
{/TESTBED/I_SA/cnt\[9:0\]} \
{/TESTBED/I_SA/cnt_next\[9:0\]} \
{/TESTBED/I_SA/current_state\[2:0\]} \
{/TESTBED/I_SA/div0_a\[40:0\]} \
{/TESTBED/I_SA/div0_out\[40:0\]} \
{/TESTBED/I_SA/in_data\[7:0\]} \
{/TESTBED/I_SA/in_data_comb\[7:0\]} \
{/TESTBED/I_SA/in_data_matrix\[0:63\]} \
{/TESTBED/I_SA/in_data_matrix_next\[0:63\]} \
{/TESTBED/I_SA/in_valid} \
{/TESTBED/I_SA/multi0_a\[39:0\]} \
{/TESTBED/I_SA/multi0_b\[18:0\]} \
{/TESTBED/I_SA/multi0_out\[58:0\]} \
{/TESTBED/I_SA/multi1_a\[39:0\]} \
{/TESTBED/I_SA/multi1_b\[18:0\]} \
{/TESTBED/I_SA/multi1_out\[58:0\]} \
{/TESTBED/I_SA/multi2_a\[39:0\]} \
{/TESTBED/I_SA/multi2_b\[18:0\]} \
{/TESTBED/I_SA/multi2_out\[58:0\]} \
{/TESTBED/I_SA/multi3_a\[39:0\]} \
{/TESTBED/I_SA/multi3_b\[18:0\]} \
{/TESTBED/I_SA/multi3_out\[58:0\]} \
{/TESTBED/I_SA/multi4_a\[39:0\]} \
{/TESTBED/I_SA/multi4_b\[18:0\]} \
{/TESTBED/I_SA/multi4_out\[58:0\]} \
{/TESTBED/I_SA/multi5_a\[39:0\]} \
{/TESTBED/I_SA/multi5_b\[18:0\]} \
{/TESTBED/I_SA/multi5_out\[58:0\]} \
{/TESTBED/I_SA/multi6_a\[39:0\]} \
{/TESTBED/I_SA/multi6_b\[18:0\]} \
{/TESTBED/I_SA/multi6_out\[58:0\]} \
{/TESTBED/I_SA/multi7_a\[39:0\]} \
{/TESTBED/I_SA/multi7_b\[18:0\]} \
{/TESTBED/I_SA/multi7_out\[58:0\]} \
{/TESTBED/I_SA/multi8_a\[39:0\]} \
{/TESTBED/I_SA/multi8_b\[18:0\]} \
{/TESTBED/I_SA/multi8_out\[58:0\]} \
{/TESTBED/I_SA/multi9_a\[39:0\]} \
{/TESTBED/I_SA/multi9_b\[18:0\]} \
{/TESTBED/I_SA/multi9_out\[58:0\]} \
{/TESTBED/I_SA/multi10_a\[39:0\]} \
{/TESTBED/I_SA/multi10_b\[18:0\]} \
{/TESTBED/I_SA/multi10_out\[58:0\]} \
{/TESTBED/I_SA/multi11_a\[39:0\]} \
{/TESTBED/I_SA/multi11_b\[18:0\]} \
{/TESTBED/I_SA/multi11_out\[58:0\]} \
{/TESTBED/I_SA/multi12_a\[39:0\]} \
{/TESTBED/I_SA/multi12_b\[18:0\]} \
{/TESTBED/I_SA/multi12_out\[58:0\]} \
{/TESTBED/I_SA/multi13_a\[39:0\]} \
{/TESTBED/I_SA/multi13_b\[18:0\]} \
{/TESTBED/I_SA/multi13_out\[58:0\]} \
{/TESTBED/I_SA/multi14_a\[39:0\]} \
{/TESTBED/I_SA/multi14_b\[18:0\]} \
{/TESTBED/I_SA/multi14_out\[58:0\]} \
{/TESTBED/I_SA/multi15_a\[39:0\]} \
{/TESTBED/I_SA/multi15_b\[18:0\]} \
{/TESTBED/I_SA/multi15_out\[58:0\]} \
{/TESTBED/I_SA/next_state\[2:0\]} \
{/TESTBED/I_SA/out_data\[63:0\]} \
{/TESTBED/I_SA/out_data_next\[63:0\]} \
{/TESTBED/I_SA/out_valid} \
{/TESTBED/I_SA/out_valid_next} \
{/TESTBED/I_SA/rst_n} \
{/TESTBED/I_SA/w_K\[7:0\]} \
{/TESTBED/I_SA/w_Q\[7:0\]} \
{/TESTBED/I_SA/w_Q_matrix\[0:63\]} \
{/TESTBED/I_SA/w_Q_matrix_next\[0:63\]} \
{/TESTBED/I_SA/w_V\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 \
           40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 \
           62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 \
           84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 \
           105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 \
           122 123 124 125 126 127 128 129 130 )} 
wvSetPosition -win $_nWave1 {("G1" 130)}
wvSetPosition -win $_nWave1 {("G1" 130)}
wvSetPosition -win $_nWave1 {("G1" 130)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/I_SA/K_matrix\[0:63\]} \
{/TESTBED/I_SA/K_matrix_next\[0:63\]} \
{/TESTBED/I_SA/QKT\[0:63\]} \
{/TESTBED/I_SA/QKT_next\[0:63\]} \
{/TESTBED/I_SA/Q_matrix\[0:63\]} \
{/TESTBED/I_SA/Q_matrix_next\[0:63\]} \
{/TESTBED/I_SA/T\[3:0\]} \
{/TESTBED/I_SA/T_comb\[3:0\]} \
{/TESTBED/I_SA/T_reg\[3:0\]} \
{/TESTBED/I_SA/V_matrix\[0:63\]} \
{/TESTBED/I_SA/V_matrix_next\[0:63\]} \
{/TESTBED/I_SA/add0_a\[63:0\]} \
{/TESTBED/I_SA/add0_b\[63:0\]} \
{/TESTBED/I_SA/add0_out\[63:0\]} \
{/TESTBED/I_SA/add1_a\[63:0\]} \
{/TESTBED/I_SA/add1_b\[63:0\]} \
{/TESTBED/I_SA/add1_out\[63:0\]} \
{/TESTBED/I_SA/add2_a\[63:0\]} \
{/TESTBED/I_SA/add2_b\[63:0\]} \
{/TESTBED/I_SA/add2_out\[63:0\]} \
{/TESTBED/I_SA/add3_a\[63:0\]} \
{/TESTBED/I_SA/add3_b\[63:0\]} \
{/TESTBED/I_SA/add3_out\[63:0\]} \
{/TESTBED/I_SA/add4_a\[63:0\]} \
{/TESTBED/I_SA/add4_b\[63:0\]} \
{/TESTBED/I_SA/add4_out\[63:0\]} \
{/TESTBED/I_SA/add5_a\[63:0\]} \
{/TESTBED/I_SA/add5_b\[63:0\]} \
{/TESTBED/I_SA/add5_out\[63:0\]} \
{/TESTBED/I_SA/add6_a\[63:0\]} \
{/TESTBED/I_SA/add6_b\[63:0\]} \
{/TESTBED/I_SA/add6_out\[63:0\]} \
{/TESTBED/I_SA/add7_a\[63:0\]} \
{/TESTBED/I_SA/add7_b\[63:0\]} \
{/TESTBED/I_SA/add7_out\[63:0\]} \
{/TESTBED/I_SA/add8_a\[63:0\]} \
{/TESTBED/I_SA/add8_b\[63:0\]} \
{/TESTBED/I_SA/add8_out\[63:0\]} \
{/TESTBED/I_SA/add9_a\[63:0\]} \
{/TESTBED/I_SA/add9_b\[63:0\]} \
{/TESTBED/I_SA/add9_out\[63:0\]} \
{/TESTBED/I_SA/add10_a\[63:0\]} \
{/TESTBED/I_SA/add10_b\[63:0\]} \
{/TESTBED/I_SA/add10_out\[63:0\]} \
{/TESTBED/I_SA/add11_a\[63:0\]} \
{/TESTBED/I_SA/add11_b\[63:0\]} \
{/TESTBED/I_SA/add11_out\[63:0\]} \
{/TESTBED/I_SA/add12_a\[63:0\]} \
{/TESTBED/I_SA/add12_b\[63:0\]} \
{/TESTBED/I_SA/add12_out\[63:0\]} \
{/TESTBED/I_SA/add13_a\[63:0\]} \
{/TESTBED/I_SA/add13_b\[63:0\]} \
{/TESTBED/I_SA/add13_out\[63:0\]} \
{/TESTBED/I_SA/add14_a\[63:0\]} \
{/TESTBED/I_SA/add14_b\[63:0\]} \
{/TESTBED/I_SA/add14_out\[63:0\]} \
{/TESTBED/I_SA/add15_a\[63:0\]} \
{/TESTBED/I_SA/add15_b\[63:0\]} \
{/TESTBED/I_SA/add15_out\[63:0\]} \
{/TESTBED/I_SA/cg_en} \
{/TESTBED/I_SA/clk} \
{/TESTBED/I_SA/cnt\[9:0\]} \
{/TESTBED/I_SA/cnt_next\[9:0\]} \
{/TESTBED/I_SA/current_state\[2:0\]} \
{/TESTBED/I_SA/div0_a\[40:0\]} \
{/TESTBED/I_SA/div0_out\[40:0\]} \
{/TESTBED/I_SA/in_data\[7:0\]} \
{/TESTBED/I_SA/in_data_comb\[7:0\]} \
{/TESTBED/I_SA/in_data_matrix\[0:63\]} \
{/TESTBED/I_SA/in_data_matrix_next\[0:63\]} \
{/TESTBED/I_SA/in_valid} \
{/TESTBED/I_SA/multi0_a\[39:0\]} \
{/TESTBED/I_SA/multi0_b\[18:0\]} \
{/TESTBED/I_SA/multi0_out\[58:0\]} \
{/TESTBED/I_SA/multi1_a\[39:0\]} \
{/TESTBED/I_SA/multi1_b\[18:0\]} \
{/TESTBED/I_SA/multi1_out\[58:0\]} \
{/TESTBED/I_SA/multi2_a\[39:0\]} \
{/TESTBED/I_SA/multi2_b\[18:0\]} \
{/TESTBED/I_SA/multi2_out\[58:0\]} \
{/TESTBED/I_SA/multi3_a\[39:0\]} \
{/TESTBED/I_SA/multi3_b\[18:0\]} \
{/TESTBED/I_SA/multi3_out\[58:0\]} \
{/TESTBED/I_SA/multi4_a\[39:0\]} \
{/TESTBED/I_SA/multi4_b\[18:0\]} \
{/TESTBED/I_SA/multi4_out\[58:0\]} \
{/TESTBED/I_SA/multi5_a\[39:0\]} \
{/TESTBED/I_SA/multi5_b\[18:0\]} \
{/TESTBED/I_SA/multi5_out\[58:0\]} \
{/TESTBED/I_SA/multi6_a\[39:0\]} \
{/TESTBED/I_SA/multi6_b\[18:0\]} \
{/TESTBED/I_SA/multi6_out\[58:0\]} \
{/TESTBED/I_SA/multi7_a\[39:0\]} \
{/TESTBED/I_SA/multi7_b\[18:0\]} \
{/TESTBED/I_SA/multi7_out\[58:0\]} \
{/TESTBED/I_SA/multi8_a\[39:0\]} \
{/TESTBED/I_SA/multi8_b\[18:0\]} \
{/TESTBED/I_SA/multi8_out\[58:0\]} \
{/TESTBED/I_SA/multi9_a\[39:0\]} \
{/TESTBED/I_SA/multi9_b\[18:0\]} \
{/TESTBED/I_SA/multi9_out\[58:0\]} \
{/TESTBED/I_SA/multi10_a\[39:0\]} \
{/TESTBED/I_SA/multi10_b\[18:0\]} \
{/TESTBED/I_SA/multi10_out\[58:0\]} \
{/TESTBED/I_SA/multi11_a\[39:0\]} \
{/TESTBED/I_SA/multi11_b\[18:0\]} \
{/TESTBED/I_SA/multi11_out\[58:0\]} \
{/TESTBED/I_SA/multi12_a\[39:0\]} \
{/TESTBED/I_SA/multi12_b\[18:0\]} \
{/TESTBED/I_SA/multi12_out\[58:0\]} \
{/TESTBED/I_SA/multi13_a\[39:0\]} \
{/TESTBED/I_SA/multi13_b\[18:0\]} \
{/TESTBED/I_SA/multi13_out\[58:0\]} \
{/TESTBED/I_SA/multi14_a\[39:0\]} \
{/TESTBED/I_SA/multi14_b\[18:0\]} \
{/TESTBED/I_SA/multi14_out\[58:0\]} \
{/TESTBED/I_SA/multi15_a\[39:0\]} \
{/TESTBED/I_SA/multi15_b\[18:0\]} \
{/TESTBED/I_SA/multi15_out\[58:0\]} \
{/TESTBED/I_SA/next_state\[2:0\]} \
{/TESTBED/I_SA/out_data\[63:0\]} \
{/TESTBED/I_SA/out_data_next\[63:0\]} \
{/TESTBED/I_SA/out_valid} \
{/TESTBED/I_SA/out_valid_next} \
{/TESTBED/I_SA/rst_n} \
{/TESTBED/I_SA/w_K\[7:0\]} \
{/TESTBED/I_SA/w_Q\[7:0\]} \
{/TESTBED/I_SA/w_Q_matrix\[0:63\]} \
{/TESTBED/I_SA/w_Q_matrix_next\[0:63\]} \
{/TESTBED/I_SA/w_V\[7:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 \
           18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 \
           40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 \
           62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 \
           84 85 86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 \
           105 106 107 108 109 110 111 112 113 114 115 116 117 118 119 120 121 \
           122 123 124 125 126 127 128 129 130 )} 
wvSetPosition -win $_nWave1 {("G1" 130)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 120 )} 
wvSelectSignal -win $_nWave1 {( "G1" 120 )} 
wvSelectSignal -win $_nWave1 {( "G1" 119 )} 
wvScrollUp -win $_nWave1 40
wvSelectSignal -win $_nWave1 {( "G1" 72 73 74 75 76 77 78 79 80 81 82 83 84 85 \
           86 87 88 89 90 91 92 93 94 95 96 97 98 99 100 101 102 103 104 105 \
           106 107 108 109 110 111 112 113 114 115 116 117 118 119 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 82)}
wvSelectSignal -win $_nWave1 {( "G1" 59 )} 
wvScrollUp -win $_nWave1 46
wvSelectSignal -win $_nWave1 {( "G1" 12 13 14 15 16 17 18 19 20 21 22 23 24 25 \
           26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 \
           48 49 50 51 52 53 54 55 56 57 58 59 )} 
wvCut -win $_nWave1
wvSetPosition -win $_nWave1 {("G1" 34)}
wvSelectSignal -win $_nWave1 {( "G1" 19 )} 
wvSelectSignal -win $_nWave1 {( "G1" 20 )} 
wvSelectSignal -win $_nWave1 {( "G1" 21 )} 
wvSelectSignal -win $_nWave1 {( "G1" 23 )} 
wvSelectSignal -win $_nWave1 {( "G1" 25 )} 
wvSelectSignal -win $_nWave1 {( "G1" 27 )} 
wvSelectSignal -win $_nWave1 {( "G1" 29 )} 
wvSelectSignal -win $_nWave1 {( "G1" 30 )} 
wvSelectSignal -win $_nWave1 {( "G1" 30 )} 
wvSetRadix -win $_nWave1 -format Bin
wvSelectSignal -win $_nWave1 {( "G1" 30 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSetRadix -win $_nWave1 -2Com
wvSelectSignal -win $_nWave1 {( "G1" 30 )} 
wvSearchNext -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 32 )} 
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/GATED_OR"
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/I_SA"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/I_SA"
wvSetPosition -win $_nWave1 {("G1" 35)}
wvSetPosition -win $_nWave1 {("G1" 35)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/I_SA/K_matrix\[0:63\]} \
{/TESTBED/I_SA/K_matrix_next\[0:63\]} \
{/TESTBED/I_SA/QKT\[0:63\]} \
{/TESTBED/I_SA/QKT_next\[0:63\]} \
{/TESTBED/I_SA/Q_matrix\[0:63\]} \
{/TESTBED/I_SA/Q_matrix_next\[0:63\]} \
{/TESTBED/I_SA/T\[3:0\]} \
{/TESTBED/I_SA/T_comb\[3:0\]} \
{/TESTBED/I_SA/T_reg\[3:0\]} \
{/TESTBED/I_SA/V_matrix\[0:63\]} \
{/TESTBED/I_SA/V_matrix_next\[0:63\]} \
{/TESTBED/I_SA/cg_en} \
{/TESTBED/I_SA/clk} \
{/TESTBED/I_SA/cnt\[9:0\]} \
{/TESTBED/I_SA/cnt_next\[9:0\]} \
{/TESTBED/I_SA/current_state\[2:0\]} \
{/TESTBED/I_SA/div0_a\[40:0\]} \
{/TESTBED/I_SA/div0_out\[40:0\]} \
{/TESTBED/I_SA/in_data\[7:0\]} \
{/TESTBED/I_SA/in_data_comb\[7:0\]} \
{/TESTBED/I_SA/in_data_matrix\[0:63\]} \
{/TESTBED/I_SA/in_data_matrix_next\[0:63\]} \
{/TESTBED/I_SA/in_valid} \
{/TESTBED/I_SA/next_state\[2:0\]} \
{/TESTBED/I_SA/out_data\[63:0\]} \
{/TESTBED/I_SA/out_data_next\[63:0\]} \
{/TESTBED/I_SA/out_valid} \
{/TESTBED/I_SA/out_valid_next} \
{/TESTBED/I_SA/rst_n} \
{/TESTBED/I_SA/w_K\[7:0\]} \
{/TESTBED/I_SA/w_Q\[7:0\]} \
{/TESTBED/I_SA/w_Q_matrix\[0:63\]} \
{/TESTBED/I_SA/w_Q_matrix_next\[0:63\]} \
{/TESTBED/I_SA/w_V\[7:0\]} \
{/TESTBED/I_SA/multi0_a\[39:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 35 )} 
wvSetPosition -win $_nWave1 {("G1" 35)}
wvSetPosition -win $_nWave1 {("G1" 35)}
wvSetPosition -win $_nWave1 {("G1" 35)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/I_SA/K_matrix\[0:63\]} \
{/TESTBED/I_SA/K_matrix_next\[0:63\]} \
{/TESTBED/I_SA/QKT\[0:63\]} \
{/TESTBED/I_SA/QKT_next\[0:63\]} \
{/TESTBED/I_SA/Q_matrix\[0:63\]} \
{/TESTBED/I_SA/Q_matrix_next\[0:63\]} \
{/TESTBED/I_SA/T\[3:0\]} \
{/TESTBED/I_SA/T_comb\[3:0\]} \
{/TESTBED/I_SA/T_reg\[3:0\]} \
{/TESTBED/I_SA/V_matrix\[0:63\]} \
{/TESTBED/I_SA/V_matrix_next\[0:63\]} \
{/TESTBED/I_SA/cg_en} \
{/TESTBED/I_SA/clk} \
{/TESTBED/I_SA/cnt\[9:0\]} \
{/TESTBED/I_SA/cnt_next\[9:0\]} \
{/TESTBED/I_SA/current_state\[2:0\]} \
{/TESTBED/I_SA/div0_a\[40:0\]} \
{/TESTBED/I_SA/div0_out\[40:0\]} \
{/TESTBED/I_SA/in_data\[7:0\]} \
{/TESTBED/I_SA/in_data_comb\[7:0\]} \
{/TESTBED/I_SA/in_data_matrix\[0:63\]} \
{/TESTBED/I_SA/in_data_matrix_next\[0:63\]} \
{/TESTBED/I_SA/in_valid} \
{/TESTBED/I_SA/next_state\[2:0\]} \
{/TESTBED/I_SA/out_data\[63:0\]} \
{/TESTBED/I_SA/out_data_next\[63:0\]} \
{/TESTBED/I_SA/out_valid} \
{/TESTBED/I_SA/out_valid_next} \
{/TESTBED/I_SA/rst_n} \
{/TESTBED/I_SA/w_K\[7:0\]} \
{/TESTBED/I_SA/w_Q\[7:0\]} \
{/TESTBED/I_SA/w_Q_matrix\[0:63\]} \
{/TESTBED/I_SA/w_Q_matrix_next\[0:63\]} \
{/TESTBED/I_SA/w_V\[7:0\]} \
{/TESTBED/I_SA/multi0_a\[39:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 35 )} 
wvSetPosition -win $_nWave1 {("G1" 35)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 35 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSetRadix -win $_nWave1 -2Com
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/GATED_OR"
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/I_SA"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/I_SA"
wvSetPosition -win $_nWave1 {("G1" 37)}
wvSetPosition -win $_nWave1 {("G1" 37)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/I_SA/K_matrix\[0:63\]} \
{/TESTBED/I_SA/K_matrix_next\[0:63\]} \
{/TESTBED/I_SA/QKT\[0:63\]} \
{/TESTBED/I_SA/QKT_next\[0:63\]} \
{/TESTBED/I_SA/Q_matrix\[0:63\]} \
{/TESTBED/I_SA/Q_matrix_next\[0:63\]} \
{/TESTBED/I_SA/T\[3:0\]} \
{/TESTBED/I_SA/T_comb\[3:0\]} \
{/TESTBED/I_SA/T_reg\[3:0\]} \
{/TESTBED/I_SA/V_matrix\[0:63\]} \
{/TESTBED/I_SA/V_matrix_next\[0:63\]} \
{/TESTBED/I_SA/cg_en} \
{/TESTBED/I_SA/clk} \
{/TESTBED/I_SA/cnt\[9:0\]} \
{/TESTBED/I_SA/cnt_next\[9:0\]} \
{/TESTBED/I_SA/current_state\[2:0\]} \
{/TESTBED/I_SA/div0_a\[40:0\]} \
{/TESTBED/I_SA/div0_out\[40:0\]} \
{/TESTBED/I_SA/in_data\[7:0\]} \
{/TESTBED/I_SA/in_data_comb\[7:0\]} \
{/TESTBED/I_SA/in_data_matrix\[0:63\]} \
{/TESTBED/I_SA/in_data_matrix_next\[0:63\]} \
{/TESTBED/I_SA/in_valid} \
{/TESTBED/I_SA/next_state\[2:0\]} \
{/TESTBED/I_SA/out_data\[63:0\]} \
{/TESTBED/I_SA/out_data_next\[63:0\]} \
{/TESTBED/I_SA/out_valid} \
{/TESTBED/I_SA/out_valid_next} \
{/TESTBED/I_SA/rst_n} \
{/TESTBED/I_SA/w_K\[7:0\]} \
{/TESTBED/I_SA/w_Q\[7:0\]} \
{/TESTBED/I_SA/w_Q_matrix\[0:63\]} \
{/TESTBED/I_SA/w_Q_matrix_next\[0:63\]} \
{/TESTBED/I_SA/w_V\[7:0\]} \
{/TESTBED/I_SA/multi0_a\[39:0\]} \
{/TESTBED/I_SA/multi0_b\[18:0\]} \
{/TESTBED/I_SA/multi0_out\[58:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 36 37 )} 
wvSetPosition -win $_nWave1 {("G1" 37)}
wvSetPosition -win $_nWave1 {("G1" 37)}
wvSetPosition -win $_nWave1 {("G1" 37)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/I_SA/K_matrix\[0:63\]} \
{/TESTBED/I_SA/K_matrix_next\[0:63\]} \
{/TESTBED/I_SA/QKT\[0:63\]} \
{/TESTBED/I_SA/QKT_next\[0:63\]} \
{/TESTBED/I_SA/Q_matrix\[0:63\]} \
{/TESTBED/I_SA/Q_matrix_next\[0:63\]} \
{/TESTBED/I_SA/T\[3:0\]} \
{/TESTBED/I_SA/T_comb\[3:0\]} \
{/TESTBED/I_SA/T_reg\[3:0\]} \
{/TESTBED/I_SA/V_matrix\[0:63\]} \
{/TESTBED/I_SA/V_matrix_next\[0:63\]} \
{/TESTBED/I_SA/cg_en} \
{/TESTBED/I_SA/clk} \
{/TESTBED/I_SA/cnt\[9:0\]} \
{/TESTBED/I_SA/cnt_next\[9:0\]} \
{/TESTBED/I_SA/current_state\[2:0\]} \
{/TESTBED/I_SA/div0_a\[40:0\]} \
{/TESTBED/I_SA/div0_out\[40:0\]} \
{/TESTBED/I_SA/in_data\[7:0\]} \
{/TESTBED/I_SA/in_data_comb\[7:0\]} \
{/TESTBED/I_SA/in_data_matrix\[0:63\]} \
{/TESTBED/I_SA/in_data_matrix_next\[0:63\]} \
{/TESTBED/I_SA/in_valid} \
{/TESTBED/I_SA/next_state\[2:0\]} \
{/TESTBED/I_SA/out_data\[63:0\]} \
{/TESTBED/I_SA/out_data_next\[63:0\]} \
{/TESTBED/I_SA/out_valid} \
{/TESTBED/I_SA/out_valid_next} \
{/TESTBED/I_SA/rst_n} \
{/TESTBED/I_SA/w_K\[7:0\]} \
{/TESTBED/I_SA/w_Q\[7:0\]} \
{/TESTBED/I_SA/w_Q_matrix\[0:63\]} \
{/TESTBED/I_SA/w_Q_matrix_next\[0:63\]} \
{/TESTBED/I_SA/w_V\[7:0\]} \
{/TESTBED/I_SA/multi0_a\[39:0\]} \
{/TESTBED/I_SA/multi0_b\[18:0\]} \
{/TESTBED/I_SA/multi0_out\[58:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 36 37 )} 
wvSetPosition -win $_nWave1 {("G1" 37)}
wvGetSignalClose -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 36 37 )} 
wvSetRadix -win $_nWave1 -format UDec
wvSetRadix -win $_nWave1 -2Com
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvGetSignalOpen -win $_nWave1
wvGetSignalSetScope -win $_nWave1 "/GATED_OR"
wvGetSignalSetScope -win $_nWave1 "/TESTBED"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/I_SA"
wvGetSignalSetScope -win $_nWave1 "/TESTBED/I_SA"
wvSetPosition -win $_nWave1 {("G1" 40)}
wvSetPosition -win $_nWave1 {("G1" 40)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/I_SA/K_matrix\[0:63\]} \
{/TESTBED/I_SA/K_matrix_next\[0:63\]} \
{/TESTBED/I_SA/QKT\[0:63\]} \
{/TESTBED/I_SA/QKT_next\[0:63\]} \
{/TESTBED/I_SA/Q_matrix\[0:63\]} \
{/TESTBED/I_SA/Q_matrix_next\[0:63\]} \
{/TESTBED/I_SA/T\[3:0\]} \
{/TESTBED/I_SA/T_comb\[3:0\]} \
{/TESTBED/I_SA/T_reg\[3:0\]} \
{/TESTBED/I_SA/V_matrix\[0:63\]} \
{/TESTBED/I_SA/V_matrix_next\[0:63\]} \
{/TESTBED/I_SA/cg_en} \
{/TESTBED/I_SA/clk} \
{/TESTBED/I_SA/cnt\[9:0\]} \
{/TESTBED/I_SA/cnt_next\[9:0\]} \
{/TESTBED/I_SA/current_state\[2:0\]} \
{/TESTBED/I_SA/div0_a\[40:0\]} \
{/TESTBED/I_SA/div0_out\[40:0\]} \
{/TESTBED/I_SA/in_data\[7:0\]} \
{/TESTBED/I_SA/in_data_comb\[7:0\]} \
{/TESTBED/I_SA/in_data_matrix\[0:63\]} \
{/TESTBED/I_SA/in_data_matrix_next\[0:63\]} \
{/TESTBED/I_SA/in_valid} \
{/TESTBED/I_SA/next_state\[2:0\]} \
{/TESTBED/I_SA/out_data\[63:0\]} \
{/TESTBED/I_SA/out_data_next\[63:0\]} \
{/TESTBED/I_SA/out_valid} \
{/TESTBED/I_SA/out_valid_next} \
{/TESTBED/I_SA/rst_n} \
{/TESTBED/I_SA/w_K\[7:0\]} \
{/TESTBED/I_SA/w_Q\[7:0\]} \
{/TESTBED/I_SA/w_Q_matrix\[0:63\]} \
{/TESTBED/I_SA/w_Q_matrix_next\[0:63\]} \
{/TESTBED/I_SA/w_V\[7:0\]} \
{/TESTBED/I_SA/multi0_a\[39:0\]} \
{/TESTBED/I_SA/multi0_b\[18:0\]} \
{/TESTBED/I_SA/multi0_out\[58:0\]} \
{/TESTBED/I_SA/add0_a\[63:0\]} \
{/TESTBED/I_SA/add0_b\[63:0\]} \
{/TESTBED/I_SA/add0_out\[63:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 38 39 40 )} 
wvSetPosition -win $_nWave1 {("G1" 40)}
wvSetPosition -win $_nWave1 {("G1" 40)}
wvSetPosition -win $_nWave1 {("G1" 40)}
wvAddSignal -win $_nWave1 -clear
wvAddSignal -win $_nWave1 -group {"G1" \
{/TESTBED/I_SA/K_matrix\[0:63\]} \
{/TESTBED/I_SA/K_matrix_next\[0:63\]} \
{/TESTBED/I_SA/QKT\[0:63\]} \
{/TESTBED/I_SA/QKT_next\[0:63\]} \
{/TESTBED/I_SA/Q_matrix\[0:63\]} \
{/TESTBED/I_SA/Q_matrix_next\[0:63\]} \
{/TESTBED/I_SA/T\[3:0\]} \
{/TESTBED/I_SA/T_comb\[3:0\]} \
{/TESTBED/I_SA/T_reg\[3:0\]} \
{/TESTBED/I_SA/V_matrix\[0:63\]} \
{/TESTBED/I_SA/V_matrix_next\[0:63\]} \
{/TESTBED/I_SA/cg_en} \
{/TESTBED/I_SA/clk} \
{/TESTBED/I_SA/cnt\[9:0\]} \
{/TESTBED/I_SA/cnt_next\[9:0\]} \
{/TESTBED/I_SA/current_state\[2:0\]} \
{/TESTBED/I_SA/div0_a\[40:0\]} \
{/TESTBED/I_SA/div0_out\[40:0\]} \
{/TESTBED/I_SA/in_data\[7:0\]} \
{/TESTBED/I_SA/in_data_comb\[7:0\]} \
{/TESTBED/I_SA/in_data_matrix\[0:63\]} \
{/TESTBED/I_SA/in_data_matrix_next\[0:63\]} \
{/TESTBED/I_SA/in_valid} \
{/TESTBED/I_SA/next_state\[2:0\]} \
{/TESTBED/I_SA/out_data\[63:0\]} \
{/TESTBED/I_SA/out_data_next\[63:0\]} \
{/TESTBED/I_SA/out_valid} \
{/TESTBED/I_SA/out_valid_next} \
{/TESTBED/I_SA/rst_n} \
{/TESTBED/I_SA/w_K\[7:0\]} \
{/TESTBED/I_SA/w_Q\[7:0\]} \
{/TESTBED/I_SA/w_Q_matrix\[0:63\]} \
{/TESTBED/I_SA/w_Q_matrix_next\[0:63\]} \
{/TESTBED/I_SA/w_V\[7:0\]} \
{/TESTBED/I_SA/multi0_a\[39:0\]} \
{/TESTBED/I_SA/multi0_b\[18:0\]} \
{/TESTBED/I_SA/multi0_out\[58:0\]} \
{/TESTBED/I_SA/add0_a\[63:0\]} \
{/TESTBED/I_SA/add0_b\[63:0\]} \
{/TESTBED/I_SA/add0_out\[63:0\]} \
}
wvAddSignal -win $_nWave1 -group {"G2" \
}
wvSelectSignal -win $_nWave1 {( "G1" 38 39 40 )} 
wvSetPosition -win $_nWave1 {("G1" 40)}
wvGetSignalClose -win $_nWave1
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 39 )} 
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvSelectSignal -win $_nWave1 {( "G1" 5 )} 
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 6 )} 
wvDisplayGridCount -win $_nWave1 -off
wvGetSignalClose -win $_nWave1
wvReloadFile -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 18 )} 
wvScrollDown -win $_nWave1 0
wvSelectSignal -win $_nWave1 {( "G1" 23 )} 
wvSelectSignal -win $_nWave1 {( "G1" 29 )} 
wvSelectSignal -win $_nWave1 {( "G1" 27 )} 
wvSelectSignal -win $_nWave1 {( "G1" 25 )} 
wvSelectSignal -win $_nWave1 {( "G1" 22 )} 
wvSelectSignal -win $_nWave1 {( "G1" 23 )} 
wvSearchNext -win $_nWave1
wvSelectSignal -win $_nWave1 {( "G1" 24 )} 
wvSelectSignal -win $_nWave1 {( "G1" 23 )} 
wvSelectSignal -win $_nWave1 {( "G1" 25 )} 
