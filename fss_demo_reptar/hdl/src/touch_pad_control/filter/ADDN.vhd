-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenierie et de Gestion du canton de Vaud
-- Institut REDS, Reconfigurable & Embedded Digital Systems
--
-- Fichier      : AddN.vhd
-- Description  : Additionneur N bits avec retenue
--
-- Auteur       : H. Truong
-- Date         : 31.07.12
-- Version      : 0.0
--
-- Utilise      : Exercice formation VHDL
--
--| Modifications |-----------------------------------------------------------
-- Version   Auteur Date               Description
-- 
-- 
------------------------------------------------------------------------------

library IEEE;
  use IEEE.Std_Logic_1164.all;
  use IEEE.Numeric_Std.all;

entity ADDN is
  generic(
     N_g : positive range 1 to 32);
  port (Nbr_A_i    : in  Std_Logic_Vector(N_g-1 downto 0);
        Nbr_B_i    : in  Std_Logic_Vector(N_g-1 downto 0);
        Cin_i      : in  Std_Logic;
        Somme_o    : out Std_Logic_Vector(N_g-1 downto 0);
        Cout_o     : out Std_Logic);
end ADDN;

architecture Comport of ADDN is

signal Nbr_A_s, Nbr_B_s, Somme_s : Unsigned( Somme_o'length downto 0);
--signal Cin: Integer  --Integer peu recommande
signal Cin_s: Unsigned(Somme_o'length-1 downto 0);

begin
	
    --Cin <= 1 when Cin_i ='1' else 0; avec declaration Integer
    
    Cin_s <= (0 => Cin_i, others =>'0');   -- avec concatenation "0000" & Cin_i;
    
    Nbr_A_s <= Unsigned('0'&Nbr_A_i);
    Nbr_B_s <= Unsigned('0'&Nbr_B_i);

    Somme_s <= Nbr_A_s + Nbr_B_s + Cin_s;

    Somme_o <= std_logic_vector(Somme_s(Somme_o'length -1 downto 0));
    Cout_o <= Somme_s(Somme_o'length);
    
end Comport;
