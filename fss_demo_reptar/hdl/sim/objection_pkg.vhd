-------------------------------------------------------------------------------
--	Copyright 2012 HES-SO HEIG-VD REDS
--	All Rights Reserved Worldwide
--
--	Licensed under the Apache License, Version 2.0 (the "License");
--	you may not use this file except in compliance with the License.
--	You may obtain a copy of the License at
--
--		http://www.apache.org/licenses/LICENSE-2.0
--
--	Unless required by applicable law or agreed to in writing, software
--	distributed under the License is distributed on an "AS IS" BASIS,
--	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
--	See the License for the specific language governing permissions and
--	limitations under the License.
-------------------------------------------------------------------------------
--
-- File        : objection_pkg.vhd
-- Description : This package offers the concept of objections, as proposed in
--               SystemVerilog within the UVM methodology.
--               Their purpose is to easily stop a simulation when no more
--               process needs to be executed, and is particularly suitable
--               for multi-process testbenches, where the simulation should
--               stop only when all stimuli and verification processes have
--               finished.
--               Please have a look at objections_example_tb.vhd to see an
--               example of a correct use of objections.
--
-- Author      : Yann Thoma
-- Team        : REDS institute
-- Date        : 22.05.13
--
--
--| Modifications |------------------------------------------------------------
-- Ver  Date      Who   Description
-- 1.0  22.05.13  YTA   First version
-- 
-------------------------------------------------------------------------------

package objection_pkg is

	-- This type corresponds to an objection manager. It offers 4 functions
	-- to raise, drop, and check the objections.
	type objection_type is protected
	
		-- Raises a number of objections (default: 1)
		procedure raise_objection(nb_obj: integer := 1);
		
		-- Drops a number of objections (default: 1)
		procedure drop_objection(nb_obj: integer := 1);
		
		-- Drops all objections
		procedure drop_all_objections;
		
		-- Returns true if there is no more objection raised
		impure function no_objection return boolean;
		
	end protected objection_type;
	
	-- The 4 following subprograms access a single objection object, and so
	-- can be used by the entire testbench, without the need of declaring an
	-- objection object. Basically they are offered for convenience.
	
	-- Raises an objection on the singleton
	procedure raise_objection(nb_obj: integer := 1);
	
	-- Drops an objection on the singleton
	procedure drop_objection(nb_obj: integer := 1);
	
	-- Drops all objections on the singleton
	procedure drop_all_objections;

	-- Indicates if all objections have been dropped on the singleton
	impure function no_objection return boolean;

end objection_pkg;

package body objection_pkg is

	type objection_type is protected body
	
		-- Number of objections raised
		variable nb_objections : integer := 0;

		-- Raises a number of objections (default: 1)
		procedure raise_objection(nb_obj: integer := 1) is
		begin
			nb_objections := nb_objections + nb_obj;
		end raise_objection;
	
		-- Drops a number of objections (default: 1)
		procedure drop_objection(nb_obj: integer := 1) is
		begin
			nb_objections := nb_objections - nb_obj;
		end drop_objection;
	
		-- Drops all objections
		procedure drop_all_objections is
		begin
			if (nb_objections > 0) then
				nb_objections := 0;
			end if;
		end drop_all_objections;

		-- Returns true if there is no more objection raised
		impure function no_objection return boolean is
		begin
			return nb_objections <= 0;
		end no_objection;

	end protected body objection_type;


	-- This private singleton allows to directly use the 3 functions
	-- without the need of declaring a shared objection. This objection
	-- will be shared by the entire simulation
	shared variable single_objection : objection_type;

	
	-- Raises an objection on the singleton
	procedure raise_objection(nb_obj: integer := 1) is
	begin
		single_objection.raise_objection(nb_obj);
	end raise_objection;
	
	-- Drops an objection on the singleton
	procedure drop_objection(nb_obj: integer := 1) is
	begin
		single_objection.drop_objection(nb_obj);
	end drop_objection;
	
	-- Drops all objections on the singleton
	procedure drop_all_objections is
	begin
		single_objection.drop_all_objections;
	end drop_all_objections;

	-- Indicates if all objections have been dropped on the singleton
	impure function no_objection return boolean is
	begin
		return single_objection.no_objection;
	end no_objection;

end objection_pkg;
