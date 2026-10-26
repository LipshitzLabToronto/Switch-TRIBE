-- Extracted edit-identification SQL only; source: the project BRAT_call_edit.sql.
-- Omits legacy calls, commented database cleanup, and ad hoc target-site inspection blocks.
# 2025 editing site calling (BULK)
  # BRAT
CREATE TABLE BRAT_BULK_REP_1_AtoG SELECT * FROM BRAT_BULK_REP_1 WHERE (0.35 * totalcount) >= Acount AND Acount > (0.3 * totalcount) AND Gcount > 0  AND totalcount >9; 
CREATE TABLE BRAT_BULK_REP_1_TtoC SELECT * FROM BRAT_BULK_REP_1 WHERE (0.35 * totalcount) >= Tcount AND Tcount > (0.3 * totalcount) AND Ccount > 0  AND totalcount >9; 
CREATE TABLE BRAT_BULK_REP_2_AtoG SELECT * FROM BRAT_BULK_REP_2 WHERE (0.35 * totalcount) >= Acount AND Acount > (0.3 * totalcount) AND Gcount > 0  AND totalcount >9; 
CREATE TABLE BRAT_BULK_REP_2_TtoC SELECT * FROM BRAT_BULK_REP_2 WHERE (0.35 * totalcount) >= Tcount AND Tcount > (0.3 * totalcount) AND Ccount > 0  AND totalcount >9; 
CREATE TABLE BRAT_BULK_REP_3_AtoG SELECT * FROM BRAT_BULK_REP_3 WHERE (0.35 * totalcount) >= Acount AND Acount > (0.3 * totalcount) AND Gcount > 0  AND totalcount >9; 
CREATE TABLE BRAT_BULK_REP_3_TtoC SELECT * FROM BRAT_BULK_REP_3 WHERE (0.35 * totalcount) >= Tcount AND Tcount > (0.3 * totalcount) AND Ccount > 0  AND totalcount >9; 
/* delete table for storage space
DROP TABLE CTRL_EX4O_REP_1_Tref,CTRL_EX4O_REP_2_Tref,CTRL_EX4O_REP_3_Tref,CTRL_EX4O_REP_1_Cref,CTRL_EX4O_REP_2_Cref,CTRL_EX4O_REP_3_Cref; 
*/

CREATE TABLE CTRL_INSC_REP_1_Aref SELECT * FROM CTRL_INSC_REP_1 WHERE Acount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_INSC_REP_2_Aref SELECT * FROM CTRL_INSC_REP_2 WHERE Acount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_INSC_REP_3_Aref SELECT * FROM CTRL_INSC_REP_3 WHERE Acount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_YH98_REP_1_Aref SELECT * FROM CTRL_YH98_REP_1 WHERE Acount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_YH98_REP_2_Aref SELECT * FROM CTRL_YH98_REP_2 WHERE Acount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_YH98_REP_3_Aref SELECT * FROM CTRL_YH98_REP_3 WHERE Acount > (0.4 * totalcount) AND totalcount >9; 

CREATE TABLE CTRL_EX4O_REP_1_Aref SELECT * FROM MEIP26_EX4O_REP1 WHERE Acount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_EX4O_REP_2_Aref SELECT * FROM MEIP26_EX4O_REP2 WHERE Acount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_EX4O_REP_3_Aref SELECT * FROM MEIP26_EX4O_REP3 WHERE Acount > (0.4 * totalcount) AND totalcount >9; 

CREATE TABLE CTRL_INSC_REP_1_Gref SELECT * FROM CTRL_INSC_REP_1 WHERE Gcount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_INSC_REP_2_Gref SELECT * FROM CTRL_INSC_REP_2 WHERE Gcount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_INSC_REP_3_Gref SELECT * FROM CTRL_INSC_REP_3 WHERE Gcount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_YH98_REP_1_Gref SELECT * FROM CTRL_YH98_REP_1 WHERE Gcount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_YH98_REP_2_Gref SELECT * FROM CTRL_YH98_REP_2 WHERE Gcount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_YH98_REP_3_Gref SELECT * FROM CTRL_YH98_REP_3 WHERE Gcount > (0.4 * totalcount) AND totalcount >9; 

CREATE TABLE CTRL_EX4O_REP_1_Gref SELECT * FROM MEIP26_EX4O_REP1 WHERE Gcount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_EX4O_REP_2_Gref SELECT * FROM MEIP26_EX4O_REP2 WHERE Gcount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_EX4O_REP_3_Gref SELECT * FROM MEIP26_EX4O_REP3 WHERE Gcount > (0.4 * totalcount) AND totalcount >9; 

CREATE TABLE CTRL_INSC_REP_1_Tref SELECT * FROM CTRL_INSC_REP_1 WHERE Tcount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_INSC_REP_2_Tref SELECT * FROM CTRL_INSC_REP_2 WHERE Tcount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_INSC_REP_3_Tref SELECT * FROM CTRL_INSC_REP_3 WHERE Tcount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_YH98_REP_1_Tref SELECT * FROM CTRL_YH98_REP_1 WHERE Tcount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_YH98_REP_2_Tref SELECT * FROM CTRL_YH98_REP_2 WHERE Tcount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_YH98_REP_3_Tref SELECT * FROM CTRL_YH98_REP_3 WHERE Tcount > (0.4 * totalcount) AND totalcount >9; 

CREATE TABLE CTRL_EX4O_REP_1_Tref SELECT * FROM MEIP26_EX4O_REP1 WHERE Tcount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_EX4O_REP_2_Tref SELECT * FROM MEIP26_EX4O_REP2 WHERE Tcount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_EX4O_REP_3_Tref SELECT * FROM MEIP26_EX4O_REP3 WHERE Tcount > (0.4 * totalcount) AND totalcount >9; 

CREATE TABLE CTRL_INSC_REP_1_Cref SELECT * FROM CTRL_INSC_REP_1 WHERE Ccount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_INSC_REP_2_Cref SELECT * FROM CTRL_INSC_REP_2 WHERE Ccount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_INSC_REP_3_Cref SELECT * FROM CTRL_INSC_REP_3 WHERE Ccount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_YH98_REP_1_Cref SELECT * FROM CTRL_YH98_REP_1 WHERE Ccount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_YH98_REP_2_Cref SELECT * FROM CTRL_YH98_REP_2 WHERE Ccount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_YH98_REP_3_Cref SELECT * FROM CTRL_YH98_REP_3 WHERE Ccount > (0.4 * totalcount) AND totalcount >9; 

CREATE TABLE CTRL_EX4O_REP_1_Cref SELECT * FROM MEIP26_EX4O_REP1 WHERE Ccount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_EX4O_REP_2_Cref SELECT * FROM MEIP26_EX4O_REP2 WHERE Ccount > (0.4 * totalcount) AND totalcount >9; 
CREATE TABLE CTRL_EX4O_REP_3_Cref SELECT * FROM MEIP26_EX4O_REP3 WHERE Ccount > (0.4 * totalcount) AND totalcount >9; 


/* delete table for storage space
DROP TABLE MEIP26_BULK_REP_3_TtoC;
CTRL_YH98_REP_3_Cref; 
*/

  # MEI-P26
CREATE TABLE MEIP26_BULK_REP_1_AtoG SELECT * FROM MEIP26_BULK_REP_1 WHERE (0.35 * totalcount) >= Acount AND Acount > (0.3 * totalcount) AND Gcount > 0  AND totalcount >9; 
CREATE TABLE MEIP26_BULK_REP_1_TtoC SELECT * FROM MEIP26_BULK_REP_1 WHERE (0.35 * totalcount) >= Tcount AND Tcount > (0.3 * totalcount) AND Ccount > 0  AND totalcount >9; 
CREATE TABLE MEIP26_BULK_REP_2_AtoG SELECT * FROM MEIP26_BULK_REP_2 WHERE (0.35 * totalcount) >= Acount AND Acount > (0.3 * totalcount) AND Gcount > 0  AND totalcount >9; 
CREATE TABLE MEIP26_BULK_REP_2_TtoC SELECT * FROM MEIP26_BULK_REP_2 WHERE (0.35 * totalcount) >= Tcount AND Tcount > (0.3 * totalcount) AND Ccount > 0  AND totalcount >9; 
CREATE TABLE MEIP26_BULK_REP_3_AtoG SELECT * FROM MEIP26_BULK_REP_3 WHERE (0.35 * totalcount) >= Acount AND Acount > (0.3 * totalcount) AND Gcount > 0  AND totalcount >9; 
CREATE TABLE MEIP26_BULK_REP_3_TtoC SELECT * FROM MEIP26_BULK_REP_3 WHERE (0.35 * totalcount) >= Tcount AND Tcount > (0.3 * totalcount) AND Ccount > 0  AND totalcount >9; 
# 2025 editing site calling (single cell)
  # BRAT

CREATE TABLE BRAT_SC_NBT1_G_ALL SELECT * FROM BRAT_SC_NBT1 WHERE Gcount > 0;
CREATE TABLE BRAT_SC_NBT2_G_ALL SELECT * FROM BRAT_SC_NBT2 WHERE Gcount > 0; 

CREATE TABLE BRAT_SC_NBT1_C_ALL SELECT * FROM BRAT_SC_NBT1 WHERE Ccount > 0; 
CREATE TABLE BRAT_SC_NBT2_C_ALL SELECT * FROM BRAT_SC_NBT2 WHERE Ccount > 0; 

CREATE TABLE BRAT_SC_GMCT1_G_ALL SELECT * FROM BRAT_SC_GMCT1 WHERE Gcount > 0;
CREATE TABLE BRAT_SC_GMCT1_C_ALL SELECT * FROM BRAT_SC_GMCT1 WHERE Ccount > 0; 

CREATE TABLE BRAT_SC_GMCT2_G_ALL SELECT * FROM BRAT_SC_GMCT2 WHERE Gcount > 0;
CREATE TABLE BRAT_SC_GMCT2_C_ALL SELECT * FROM BRAT_SC_GMCT2 WHERE Ccount > 0; 

CREATE TABLE BRAT_SC_INP_G_ALL SELECT * FROM BRAT_SC_INP WHERE Gcount > 0;
CREATE TABLE BRAT_SC_INP_C_ALL SELECT * FROM BRAT_SC_INP WHERE Ccount > 0; 

CREATE TABLE BRAT_SC_Neuron_G_ALL SELECT * FROM BRAT_SC_Neuron WHERE Gcount > 0;
CREATE TABLE BRAT_SC_Neuron_C_ALL SELECT * FROM BRAT_SC_Neuron WHERE Ccount > 0; 

/*
SELECT * FROM BRAT_SC_Neuron WHERE Tcount > 0 AND Ccount > 0 LIMIT 10;
*/

# P < 0.05 : A(A+G+1)/(A+G)(G+1) > 3.841
# bonferronic correction for n = 6: p < 0.083 (0.5/6)
# P < 0.0083 : A(A+G+1)/(A+G)(G+1) > 6.656


     # call edits: chi-square (A,G)/(0,1) < 0.05 equals to: A(A+G+1)/(A+G)(G+1) > 3.841 , minimum A = 3
     

CREATE TABLE SC_CTRL_INSC_REP_1_Aref SELECT * FROM CTRL_INSC_REP_1 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 3.841 ; 
CREATE TABLE SC_CTRL_INSC_REP_2_Aref SELECT * FROM CTRL_INSC_REP_2 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 3.841 ;
CREATE TABLE SC_CTRL_INSC_REP_3_Aref SELECT * FROM CTRL_INSC_REP_3 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 3.841 ;

CREATE TABLE SC_CTRL_YH98_REP_1_Aref SELECT * FROM CTRL_YH98_REP_1 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 3.841 ; 
CREATE TABLE SC_CTRL_YH98_REP_2_Aref SELECT * FROM CTRL_YH98_REP_2 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 3.841 ;
CREATE TABLE SC_CTRL_YH98_REP_3_Aref SELECT * FROM CTRL_YH98_REP_3 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 3.841 ;



CREATE TABLE SC_CTRL_INSC_REP_1_Tref SELECT * FROM CTRL_INSC_REP_1 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 3.841 ; 
CREATE TABLE SC_CTRL_INSC_REP_2_Tref SELECT * FROM CTRL_INSC_REP_2 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 3.841 ;
CREATE TABLE SC_CTRL_INSC_REP_3_Tref SELECT * FROM CTRL_INSC_REP_3 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 3.841 ;

CREATE TABLE SC_CTRL_YH98_REP_1_Tref SELECT * FROM CTRL_YH98_REP_1 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 3.841 ; 
CREATE TABLE SC_CTRL_YH98_REP_2_Tref SELECT * FROM CTRL_YH98_REP_2 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 3.841 ;
CREATE TABLE SC_CTRL_YH98_REP_3_Tref SELECT * FROM CTRL_YH98_REP_3 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 3.841 ;



  # MEIP26

/*
DROP TABLE SCREF_CTRL_EX4O_REP_1_Aref,SCREF_CTRL_EX4O_REP_1_Tref,SCREF_CTRL_EX4O_REP_2_Aref,SCREF_CTRL_EX4O_REP_2_Tref,SCREF_CTRL_EX4O_REP_3_Aref,SCREF_CTRL_EX4O_REP_3_Tref;
DROP TABLE SCREF_MEIP26_REP_1_AtoG,SCREF_MEIP26_REP_1_TtoC,SCREF_MEIP26_REP_2_AtoG,SCREF_MEIP26_REP_2_TtoC,SCREF_MEIP26_REP_3_AtoG,SCREF_MEIP26_REP_3_TtoC;
*/

CREATE TABLE MEIP26_SC_NB_G_ALL SELECT * FROM MEIP26_SC_NB WHERE Gcount > 0;
CREATE TABLE MEIP26_SC_NB_C_ALL SELECT * FROM MEIP26_SC_NB WHERE Ccount > 0; 

CREATE TABLE MEIP26_SC_Glia_G_ALL SELECT * FROM MEIP26_SC_Glia WHERE Gcount > 0;
CREATE TABLE MEIP26_SC_Glia_C_ALL SELECT * FROM MEIP26_SC_Glia WHERE Ccount > 0; 

CREATE TABLE MEIP26_SC_INP_G_ALL SELECT * FROM MEIP26_SC_INP WHERE Gcount > 0;
CREATE TABLE MEIP26_SC_INP_C_ALL SELECT * FROM MEIP26_SC_INP WHERE Ccount > 0; 

CREATE TABLE MEIP26_SC_GMCT1_G_ALL SELECT * FROM MEIP26_SC_GMCT1 WHERE Gcount > 0;
CREATE TABLE MEIP26_SC_GMCT1_C_ALL SELECT * FROM MEIP26_SC_GMCT1 WHERE Ccount > 0; 

CREATE TABLE MEIP26_SC_GMCT2_G_ALL SELECT * FROM MEIP26_SC_GMCT2 WHERE Gcount > 0;
CREATE TABLE MEIP26_SC_GMCT2_C_ALL SELECT * FROM MEIP26_SC_GMCT2 WHERE Ccount > 0; 


 # Neuron is too large

SET innodb_lock_wait_timeout = 360;

CREATE TABLE MEIP26_SC_Neuron_G_ALL SELECT * FROM MEIP26_SC_Neuron WHERE Gcount > 0;
CREATE TABLE MEIP26_SC_Neuron_C_ALL SELECT * FROM MEIP26_SC_Neuron WHERE Ccount > 0; 




/*
SELECT * FROM BRAT_SC_Neuron LIMIT 10; WHERE Tcount > 0 AND Ccount > 0 
*/




     # call edits: chi-square (A,G)/(0,1) < 0.05 equals to: A(A+G+1)/(A+G)(G+1) > 3.841 , minimum A = 3

CREATE TABLE SC_CTRL_EX4O_REP_1_Aref SELECT * FROM MEIP26_EX4O_REP1 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 3.841 ; 
CREATE TABLE SC_CTRL_EX4O_REP_2_Aref SELECT * FROM MEIP26_EX4O_REP2 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 3.841 ;
CREATE TABLE SC_CTRL_EX4O_REP_3_Aref SELECT * FROM MEIP26_EX4O_REP3 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 3.841 ;

CREATE TABLE SC_CTRL_EX4O_REP_1_Tref SELECT * FROM MEIP26_EX4O_REP1 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 3.841 ; 
CREATE TABLE SC_CTRL_EX4O_REP_2_Tref SELECT * FROM MEIP26_EX4O_REP2 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 3.841 ;
CREATE TABLE SC_CTRL_EX4O_REP_3_Tref SELECT * FROM MEIP26_EX4O_REP3 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 3.841 ;












     # call edits with multiple test correction: chi-square (A,G)/(0,1) < 0.0083 equals to A(A+G+1)/(A+G)(G+1) > 6.656 , minimum A = 3
     

CREATE TABLE SC_COR_CTRL_INSC_REP_1_Aref SELECT * FROM CTRL_INSC_REP_1 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 6.656 ; 
CREATE TABLE SC_COR_CTRL_INSC_REP_2_Aref SELECT * FROM CTRL_INSC_REP_2 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 6.656 ;
CREATE TABLE SC_COR_CTRL_INSC_REP_3_Aref SELECT * FROM CTRL_INSC_REP_3 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 6.656 ;

CREATE TABLE SC_COR_CTRL_YH98_REP_1_Aref SELECT * FROM CTRL_YH98_REP_1 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 6.656 ; 
CREATE TABLE SC_COR_CTRL_YH98_REP_2_Aref SELECT * FROM CTRL_YH98_REP_2 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 6.656 ;
CREATE TABLE SC_COR_CTRL_YH98_REP_3_Aref SELECT * FROM CTRL_YH98_REP_3 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 6.656 ;

CREATE TABLE SC_COR_CTRL_INSC_REP_1_Tref SELECT * FROM CTRL_INSC_REP_1 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 6.656 ; 
CREATE TABLE SC_COR_CTRL_INSC_REP_2_Tref SELECT * FROM CTRL_INSC_REP_2 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 6.656 ;
CREATE TABLE SC_COR_CTRL_INSC_REP_3_Tref SELECT * FROM CTRL_INSC_REP_3 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 6.656 ;

CREATE TABLE SC_COR_CTRL_YH98_REP_1_Tref SELECT * FROM CTRL_YH98_REP_1 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 6.656 ; 
CREATE TABLE SC_COR_CTRL_YH98_REP_2_Tref SELECT * FROM CTRL_YH98_REP_2 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 6.656 ;
CREATE TABLE SC_COR_CTRL_YH98_REP_3_Tref SELECT * FROM CTRL_YH98_REP_3 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 6.656 ;

CREATE TABLE SC_COR_CTRL_EX4O_REP_1_Aref SELECT * FROM MEIP26_EX4O_REP1 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 6.656 ; 
CREATE TABLE SC_COR_CTRL_EX4O_REP_2_Aref SELECT * FROM MEIP26_EX4O_REP2 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 6.656 ;
CREATE TABLE SC_COR_CTRL_EX4O_REP_3_Aref SELECT * FROM MEIP26_EX4O_REP3 WHERE Acount > 2 AND Acount * (Acount + Gcount + 1 ) / (Acount + Gcount) / (1 + Gcount) > 6.656 ;

CREATE TABLE SC_COR_CTRL_EX4O_REP_1_Tref SELECT * FROM MEIP26_EX4O_REP1 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 6.656 ; 
CREATE TABLE SC_COR_CTRL_EX4O_REP_2_Tref SELECT * FROM MEIP26_EX4O_REP2 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 6.656 ;
CREATE TABLE SC_COR_CTRL_EX4O_REP_3_Tref SELECT * FROM MEIP26_EX4O_REP3 WHERE Tcount > 2 AND Tcount * (Tcount + Ccount + 1 ) / (Tcount + Ccount) / (1 + Ccount) > 6.656 ;



# editing site calling 
  # BRAT DIM15 RES1.0 

CREATE TABLE BRAT_SC_DIM15_NB_G_ALL SELECT * FROM BRAT_SC_DIM15_NB WHERE Gcount > 0;
CREATE TABLE BRAT_SC_DIM15_NB_C_ALL SELECT * FROM BRAT_SC_DIM15_NB WHERE Ccount > 0; 

CREATE TABLE BRAT_SC_DIM15_Glia_T1T2_G_ALL SELECT * FROM BRAT_SC_DIM15_Glia_T1T2 WHERE Gcount > 0; 
CREATE TABLE BRAT_SC_DIM15_Glia_T1T2_C_ALL SELECT * FROM BRAT_SC_DIM15_Glia_T1T2 WHERE Ccount > 0; 

CREATE TABLE BRAT_SC_DIM15_Glia_else_G_ALL SELECT * FROM BRAT_SC_DIM15_Glia_else WHERE Gcount > 0; 
CREATE TABLE BRAT_SC_DIM15_Glia_else_C_ALL SELECT * FROM BRAT_SC_DIM15_Glia_else WHERE Ccount > 0; 

CREATE TABLE BRAT_SC_DIM15_GMCT1_G_ALL SELECT * FROM BRAT_SC_DIM15_GMCT1 WHERE Gcount > 0;
CREATE TABLE BRAT_SC_DIM15_GMCT1_C_ALL SELECT * FROM BRAT_SC_DIM15_GMCT1 WHERE Ccount > 0; 

CREATE TABLE BRAT_SC_DIM15_GMCT2_G_ALL SELECT * FROM BRAT_SC_DIM15_GMCT2 WHERE Gcount > 0;
CREATE TABLE BRAT_SC_DIM15_GMCT2_C_ALL SELECT * FROM BRAT_SC_DIM15_GMCT2 WHERE Ccount > 0; 

CREATE TABLE BRAT_SC_DIM15_INP_G_ALL SELECT * FROM BRAT_SC_DIM15_INP WHERE Gcount > 0; 
CREATE TABLE BRAT_SC_DIM15_INP_C_ALL SELECT * FROM BRAT_SC_DIM15_INP WHERE Ccount > 0; 

CREATE TABLE BRAT_SC_DIM15_Neuron_T1T2_G_ALL SELECT * FROM BRAT_SC_DIM15_Neuron_T1T2 WHERE Gcount > 0; 
CREATE TABLE BRAT_SC_DIM15_Neuron_T1T2_C_ALL SELECT * FROM BRAT_SC_DIM15_Neuron_T1T2 WHERE Ccount > 0; 

CREATE TABLE BRAT_SC_DIM15_Neuron_else_1_G_ALL SELECT * FROM BRAT_SC_DIM15_Neuron_else_1 WHERE Gcount > 0; 
CREATE TABLE BRAT_SC_DIM15_Neuron_else_1_C_ALL SELECT * FROM BRAT_SC_DIM15_Neuron_else_1 WHERE Ccount > 0; 

CREATE TABLE BRAT_SC_DIM15_Neuron_else_2_G_ALL SELECT * FROM BRAT_SC_DIM15_Neuron_else_2 WHERE Gcount > 0; 
CREATE TABLE BRAT_SC_DIM15_Neuron_else_2_C_ALL SELECT * FROM BRAT_SC_DIM15_Neuron_else_2 WHERE Ccount > 0; 


  # MEI-P26 neuron T1T2/else 


CREATE TABLE MEIP26_SC_Neuron_T1T2_G_ALL SELECT * FROM MEIP26_SC_Neuron_T1T2 WHERE Gcount > 0;
CREATE TABLE MEIP26_SC_Neuron_T1T2_C_ALL SELECT * FROM MEIP26_SC_Neuron_T1T2 WHERE Ccount > 0; 

CREATE TABLE MEIP26_SC_Neuron_else_G_ALL SELECT * FROM MEIP26_SC_Neuron_else WHERE Gcount > 0;
CREATE TABLE MEIP26_SC_Neuron_else_C_ALL SELECT * FROM MEIP26_SC_Neuron_else WHERE Ccount > 0; 
