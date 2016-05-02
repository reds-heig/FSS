-----------------------------------------------------------------------
-- HEIG-VD, Haute Ecole d'Ingenerie et de Gestion du Canton de Vaud
-- Institut REDS
--
-- Fichier :  LOG_pkg.vhd
-- Auteur  :  E. Messerli
-- Date    :  10.03.2008
--
-- Utilise dans   : 
--                 
-----------------------------------------------------------------------
-- Fonctionnement vu de l'exterieur : 
--   Paquetage des projets: 
--
-----------------------------------------------------------------------
-- Ver  Date     Qui  Commentaires
-- 0.0  11.12.12 HTG  Version initiale pour le projet REPTAR,  
--                    touch control pad repris de la version original
--                    pour le projet Master_I2C
-----------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package LOG_pkg is

  -- Integer logarithm (rounded up) [MR version]
  function ilogup (x : natural; base : natural := 2) return natural;

  -- Integer logarithm (rounded down) [MR version]
  function ilog (x : natural; base : natural := 2) return natural;

end LOG_pkg;

package body LOG_pkg is

  -- Integer logarithm (rounded up) [MR version]
  function ilogup (x : natural; base : natural := 2) return natural is
    variable y : natural := 1;
  begin
    while x > base ** y loop
      y := y + 1;
    end loop;
    return y;
  end ilogup;

  -- Integer logarithm (rounded down) [MR version]
  function ilog (x : natural; base : natural := 2) return natural is
    variable y : natural := 1;
  begin
    while x > base ** y loop
      y := y + 1;
    end loop;
    if x<base**y then
      y := y - 1;
    end if;
    return y;
  end ilog;

end LOG_pkg;





