#==========================================================================
# *** Catalogue/Item Book
#--------------------------------------------------------------------------
#  This plugin provides a list of items, weapons, and armors retrieved 
#  in-game. The list describes the type, effects, and the value per item.
#
# * Version 0.5.0
#
# * Initial release: 2017-11-24
#
# * Initial commit: 2017-11-24
#
# * Updated: 2018-01-31
#
# * Coded by: boaromayo/Quesada's Swan
#
# NOTE: If you are using this plugin for your projects (commercial or non-commercial), 
# be sure to leave this comment visible or credit me (boaromayo or Quesada's Swan) 
# somewhere in your projects.
#
# * Changelog:
#   -- Updated other information - 2018-01-31
#   -- Small update - 2017-11-25
# 	-- Initial commit and release - 2017-11-24
#   -- Started script - 2017-11-23
#==========================================================================

$imported ||= {}
$imported["Catalogue-arprinz"] = true

#==========================================================================
# ** Game_Party
#--------------------------------------------------------------------------
#  This class handles parties. Information such as gold and items is included.
# Instances of this class are referenced by $game_party.
#==============================================================================

class Game_Party < Game_Unit
  #--------------------------------------------------------------------------
  # * Public Instance Variables
  #--------------------------------------------------------------------------
  attr_accessor :items_collected			# Items collected for catalogue
  attr_accessor :weapons_collected			# Weapons collected for catalogue
  attr_accessor :armors_collected			# Armors collected for catalogue
  attr_accessor :total_items				# Number of items, weapons, armors collected
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
  	@items_collected = []
  	@weapons_collected = []
  	@armors_collected = []
  	@total_items = 0
  end
  #--------------------------------------------------------------------------
  # * new method: Add Item To Collection
  #--------------------------------------------------------------------------
  def add_item_collect(item, item_class)
  	if has_item?(item)
  	  @items_collected[item.id] = true if item_class == RPG::Item
  	  @weapons_collected[item.id] = true if item_class == RPG::Weapon
  	  @armors_collected[item.id] = true if item_class == RPG::Armor
  	  @total_items = @total_items + 1
  	end
  end
end

#==============================================================================
# ** Window_CatalogProgress
#------------------------------------------------------------------------------
#  This window records the progress of items collected.
#==============================================================================
class Window_CatalogProgress < Window_Help
  #----------------------------------------------------------------------------
  # * Object Initialization
  #----------------------------------------------------------------------------
  def initialize
  	super(1)
  	draw_progress
  end
  #----------------------------------------------------------------------------
  # * Draw Progress
  #----------------------------------------------------------------------------
  def draw_progress
  	draw_progress_text
  	draw_percentage_text
  end
  #----------------------------------------------------------------------------
  # * Get Progress
  #----------------------------------------------------------------------------
  def progress
  	current_items.to_s + "/" + max_items.to_s
  end
  #----------------------------------------------------------------------------
  # * Draw Progress Text
  #----------------------------------------------------------------------------
  def draw_progress_text
  	set_text(progress)
  end 
  #----------------------------------------------------------------------------
  # * Draw Percentage Text
  #----------------------------------------------------------------------------
  def draw_percentage_text
  	pct = current_items / max_items
  	pct_i = pct.to_i
  	pct_text = pct_i.to_s + "%"
  	draw_text(x, y, pct_text, 2)
  end
  #----------------------------------------------------------------------------
  # * Items Collected
  #----------------------------------------------------------------------------
  def current_items
  	$game_party.total_items
  end
  #----------------------------------------------------------------------------
  # * Max Number of Items
  #----------------------------------------------------------------------------
  def max_items
  	$data_items.size + $data_weapons.size + $data_armors.size
  end
end

#==============================================================================
# ** Window_CatalogCategory
#------------------------------------------------------------------------------
#  This command is for selecting a category of items and equipment to be shown
# on the catalog screen. The window's behavior is similar to the item category
# window in the main menu.
#==============================================================================
class Window_CatalogCategory < Window_HorzCommand
  #----------------------------------------------------------------------------
  # * Object Initialization
  #----------------------------------------------------------------------------
  def initialize
  	super(0,0)
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
  	Graphics.width
  end
  #------------------------------------------------------------------------
  # * Get Column Count
  #------------------------------------------------------------------------
  def col_max
    return 4
  end
  #------------------------------------------------------------------------
  # * Frame Update
  #------------------------------------------------------------------------
  def update
    super
  end
  #--------------------------------------------------------------------------
  # * Create Command List
  #--------------------------------------------------------------------------
  def make_command_list
    add_command(Vocab::item,     :item)
    add_command(Vocab::weapon,   :weapon)
    add_command(Vocab::armor,    :armor)
    add_command("All Items",	 :all)
  end
end

#==============================================================================
# ** Window_CatalogList
#------------------------------------------------------------------------------
#  This window lists the items collected.
#==============================================================================
class Window_CatalogList < Window_Selectable
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize
    super(0, fitting_height(2), window_width, window_height)
    @data = []
  end
  #------------------------------------------------------------------------
  # * Get Window Width
  #------------------------------------------------------------------------
  def window_width
    Graphics.width
  end
  #------------------------------------------------------------------------
  # * Get Window Height
  #------------------------------------------------------------------------
  def window_height
    Graphics.height - fitting_height(2)
  end
  #------------------------------------------------------------------------
  # * Get Column Count
  #------------------------------------------------------------------------
  def col_max
  	return 2
  end
  #--------------------------------------------------------------------------
  # * override method: Get Activation State of Selection Item
  #--------------------------------------------------------------------------
  def current_item_enabled?
    collected?(index)
  end
  #--------------------------------------------------------------------------
  # * Check If Item Collected
  #--------------------------------------------------------------------------
  def collected?(index)
    @data[index] != nil
  end
  #------------------------------------------------------------------------
  # * Get Number of Items
  #------------------------------------------------------------------------
  def item_max
    @data ? @data.size : 1
  end
  #------------------------------------------------------------------------
  # * Get Unknown Text
  #------------------------------------------------------------------------
  def unknown
    "????????"
  end
  #------------------------------------------------------------------------
  # * Check If Item Collected
  #------------------------------------------------------------------------
  def collected?(item)
    item != nil
  end
  #------------------------------------------------------------------------
  # * Include In Item List
  #------------------------------------------------------------------------
  def include?(item)
  	case @category
  	when :item
  		item.is_a?(RPG::Item) && !item.key_item? && $game_party.items_collected[item.id] == true
  	when :weapon
  		item.is_a?(RPG::Weapon) && $game_party.weapons_collected[item.id] == true
  	when :armor
  		item.is_a?(RPG::Armor) && $game_party.armors_collected[item.id] == true
  	when :all
  		item.is_a?(RPG::Item) || item.is_a(RPG::Weapon) || item.is_a?(RPG::Armor)
  	else
  		false
  	end
  end
  #------------------------------------------------------------------------
  # * Create Item List
  #------------------------------------------------------------------------
  def make_item_list
  	@data.push($game_party.items_collected)
  	@data.push($game_party.weapons_collected) 
  	@data.push($game_party.armors_collected)
  end
  #------------------------------------------------------------------------
  # * Draw Item To List
  #------------------------------------------------------------------------
  def draw_item(index)
  	item = @data[index]
  	if item
  	  rect = item_rect_for_text(index)
  	  collected?(item) ? draw_text(item, rect.x, rect.y, false) : 
  	    draw_text(rect, unknown, 0)
  	end
  end
  #------------------------------------------------------------------------
  # * Refresh
  #------------------------------------------------------------------------
  def refresh
  	make_item_list
  	draw_all_items
  end
end

#==============================================================================
# ** Window_Catalog
#------------------------------------------------------------------------------
#  This window displays the item details.
#==============================================================================
class Window_Catalog < Window_Selectable
end

#==============================================================================
# ** Window_MenuCommand
#------------------------------------------------------------------------------
#  This command window appears on the menu screen.
#==============================================================================

class Window_MenuCommand < Window_Command
  #--------------------------------------------------------------------------
  # * alias method: For Adding Original Commands
  #--------------------------------------------------------------------------
  alias catalog_cmd add_original_commands
  def add_original_commands
    catalog_cmd
	add_catalog_command
  end
  #--------------------------------------------------------------------------
  # * new method: Add Catalogue to Command List
  #--------------------------------------------------------------------------
  def add_catalog_command
    add_command("Catalogue", :catalogue, catalog_enabled)
  end
  #--------------------------------------------------------------------------
  # * new method: Get Activation State of Catalogue
  #--------------------------------------------------------------------------
  def catalog_enabled
    $game_party.total_items > 0
  end
end

#==========================================================================
# ** Scene_Menu
#--------------------------------------------------------------------------
#  This class performs the menu scene processing.
#==========================================================================
class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * alias method: Create Command Window
  #--------------------------------------------------------------------------
  alias create_catalogue_command create_command_window
  def create_command_window
  	create_catalogue_command
  	@command_window.set_handler(:catalogue,	method(:command_catalog))
  end
  #--------------------------------------------------------------------------
  # * new method: [Catalogue] Window
  #--------------------------------------------------------------------------
  def command_catalog
  	SceneManager.call(Scene_Catalogue)
  end
end

#==========================================================================
# ** Scene_Catalogue
#--------------------------------------------------------------------------
#  This class performs the catalogue scene processing.
#==========================================================================
class Scene_Catalogue < Scene_Base
  #------------------------------------------------------------------------
  # * Start Processing
  #------------------------------------------------------------------------
  def start
    super
    @index = -1
    create_catalogue_list_windows
    create_catalogue_windows(@index)
  end
  #------------------------------------------------------------------------
  # * Create Catalogue List Windows
  #------------------------------------------------------------------------
  def create_catalogue_list_windows
  	create_progress_window
  	create_category_window
  	create_list_window
  end
  #------------------------------------------------------------------------
  # * Create Catalogue Window
  #------------------------------------------------------------------------
  def create_catalogue_window
  	@catalog_window = Window_Catalog.new
  end
  #------------------------------------------------------------------------
  # * Create Progress Window
  #------------------------------------------------------------------------
  def create_progress_window
  	@progress_window = Window_CatalogProgress.new
  	@progress_window.viewport = @viewport
  end
  #------------------------------------------------------------------------
  # * Create Category Window
  #------------------------------------------------------------------------
  def create_category_window
  	@category_window = Window_CatalogCategory.new
  	@category_window.viewport = @viewport
  	@category_window.set_handler(:ok,	  method(:on_category_ok))
  	@category_window.set_handler(:cancel, method(:return_scene))
  end
  #------------------------------------------------------------------------
  # * Create List Window
  #------------------------------------------------------------------------
  def create_list_window
  	@list_window = Window_CatalogList.new
  	@list_window.viewport = @viewport
  	@list_window.set_handler(:ok,	  method(:on_list_ok))
  	@list_window.set_handler(:cancel, method(:on_list_cancel))
  end
  #------------------------------------------------------------------------
  # * Category [OK]
  #------------------------------------------------------------------------
  def on_category_ok
  	@list_window.activate
  end
  #------------------------------------------------------------------------
  # * List [OK]
  #------------------------------------------------------------------------
  def on_list_ok
  end
  #------------------------------------------------------------------------
  # * List [Cancel]
  #------------------------------------------------------------------------
  def on_list_cancel
  	@list_window.unselect
  	@category_window.activate
  end
  #------------------------------------------------------------------------
  # * Switch to Next Item
  #------------------------------------------------------------------------
  def next_item
  end
  #------------------------------------------------------------------------
  # * Switch to Previous Item
  #------------------------------------------------------------------------
  def prev_item
  end
end
