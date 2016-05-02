-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- Institut REDS
--
-- Fichier :  Open_Collector.vhd
-- Auteur  :  H. Truong
-- Date    :  19.12.2012
--
-- Utilise dans   :  Projet touch control pad
------------------------------------------------------------------------------------
-- Outward view:
--   This is an open collector port.
--   The output enabled drives the io port to '0', 'Z' otherwise.
--   Table:
--    OE_s   |  InOut_io 
--  -------+-----------
--    '0'  |    'Z'
--    '1'  |    '0'  
-- 
--  
--
------------------------------------------------------------------------------------
-- Ver  Date        Who  Comments
-- 0.0  See header  HTG  Initial version
-- 
--

------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity Open_Collector is
  port(
    In_o        : out   std_logic;
    nOE_i       : in    std_logic;
    InOut_io    : inout std_logic
  );
end Open_Collector;

architecture Struct of Open_Collector is
  signal OE_s : std_logic;
begin
  OE_s <= not nOE_i;
  
  InOut_io <= '0' when OE_s='1' else 'Z';

  --Use To_X01 function to converte state H to '1' and L to '0'
  In_o <= To_X01(InOut_io);

end architecture Struct;