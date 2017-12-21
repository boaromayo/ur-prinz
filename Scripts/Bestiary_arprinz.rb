#==========================================================================
# *** Bestiary/Monster Book
#--------------------------------------------------------------------------
#  This plugin provides a list of enemies defeated in-game. The bestiary
# shows the quantity of enemies slain, along with other stats, from health
# to treasures to weaknesses and strengths.
#
# * Version: 0.8.1
#
# * Initial release: 2016-04-25
#
# * Initial commit: 2017-10-16
#
# * Updated: 2017-12-21
#
# * Coded by: boaromayo/Quesada's Swan
#
# Optional prerequisites:
#  * Expanded iconset for elements
#
# NOTE: If you are using this plugin for your projects (commercial or non-commercial), 
# be sure to leave this comment visible or credit me (boaromayo or Quesada's Swan) 
# somewhere in your projects.
#
# * Changelog:
#    -- Initial v0.8.1 alpha release - 2017-12-20
#    -- Added enemy name and number slain - 2017-11-20
#    -- Fixed bug that prevents leaving bestiary menu - 2017-11-17
#    -- Fixed additional crashing bugs - 2017-11-16
#    -- Modified game objects and fixed bugs - 2017-11-15
#    -- Fixed additional bugs - 2017-11-14
#    -- Fixed error bug in Game_System - 2017-11-14
#    -- Added Scene_Menu override methods - 2017-11-14
#    -- Added Game_Enemy new and override methods - 2017-11-14
#    -- Added $imported global variable - 2017-11-06
#    -- Unknown text method re-added - 2017-11-06
#    -- Unknown text method removed - 2017-11-05
#    -- Edited draw_item method - 2017-11-04
#    -- Added sparam_count method - 2017-11-04
#    -- Removed explicit condition in loading data - 2017-11-02
#    -- Displayed enemy slain in list window - 2017-10-26
#    -- Added more features and fixed bugs - 2017-10-25
#    -- Added more features - 2017-10-18
#    -- Initial commit - 2017-10-16
#==========================================================================

$imported ||= {}
$imported["Bestiary_arprinz"] = true

#==========================================================================
# ** Game_System
#--------------------------------------------------------------------------
#  This class handles system data. It saves the disable state of saving and 
# menus. Instances of this class are referenced by $game_system.
#==========================================================================

class Game_System
  #------------------------------------------------------------------------
  # * Add new public instance variables
  #------------------------------------------------------------------------
  attr_accessor :enemy_encounter			# Checks if enemy encountered?
  attr_accessor :enemy_slain			    # Quantity of enemy types slain
  attr_accessor :enemy_list           # List of enemies slain
  attr_accessor :total_enemy_slain		# Number of enemies slain
  #------------------------------------------------------------------------
  # * alias method: Object Initialization
  #------------------------------------------------------------------------
  alias bestiary_initialize initialize
  def initialize
    bestiary_initialize
    @enemy_encounter = []
    @enemy_slain = []
    @enemy_list = []
	  @total_enemy_slain = 0
    $data_enemies.each_index do |enemy|
      @enemy_encounter[enemy] = false
	    @enemy_slain[enemy] = 0
      @enemy_list[enemy] = nil
    end
  end
  #------------------------------------------------------------------------
  # * new method: Get Quantity of Certain Enemy Slain
  #------------------------------------------------------------------------
  def enemies_slain(enemy_id)
    @enemy_slain[enemy_id].to_i
  end
  #------------------------------------------------------------------------
  # * new method: Add Enemies Slain
  #------------------------------------------------------------------------
  def add_enemies_slain(enemy)
    unless @enemy_slain[enemy.id] > 0
      @total_enemy_slain = @total_enemy_slain + 1
    end
    @enemy_slain[enemy.id] = @enemy_slain[enemy.id] + 1
  end
end

#==========================================================================
# ** Game_Enemy
#--------------------------------------------------------------------------
#  This class handles enemies. It used within the Game_Troop class 
# ($game_troop).
#==========================================================================
class Game_Enemy < Game_Battler
  #------------------------------------------------------------------------
  # * new method: Check Enemies Encountered
  #------------------------------------------------------------------------
  def add_encountered_enemy(enemy_id)
    @enemy_id = enemy_id
    unless $game_system.enemy_encounter.include?(@enemy_id)
      $game_system.enemy_encounter[@enemy_id] = true
      # Add enemy name to list if encountered
      $game_system.enemy_list[@enemy_id] = enemy
    end
  end
  #------------------------------------------------------------------------
  # * override method: Die
  #------------------------------------------------------------------------
  def die
	  super
    $game_system.add_enemies_slain(enemy) unless $game_system.enemy_slain.include?(enemy)
  end
end

#==============================================================================
# ** Game_Troop
#------------------------------------------------------------------------------
#  This class handles enemy groups and battle-related data. Also performs
# battle events. The instance of this class is referenced by $game_troop.
#==============================================================================
class Game_Troop < Game_Unit
  #--------------------------------------------------------------------------
  # * alias method: Setup
  #  troop_id : troop_id
  #--------------------------------------------------------------------------
  alias bestiary_setup setup
  def setup(troop_id)
    bestiary_setup(troop_id)
    troop.members.each do |member|
      next unless $data_enemies[member.enemy_id]
      enemy = Game_Enemy.new(@enemies.size, member.enemy_id)
	  enemy.add_encountered_enemy(member.enemy_id)
    end
  end
end

#==========================================================================
# ** Window_BestiaryStatus
#--------------------------------------------------------------------------
#  This window displays bestiary progress.
#==========================================================================
class Window_BestiaryStatus < Window_Help
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize
    super(1)
    refresh
  end
  #------------------------------------------------------------------------
  # * Draw Progress
  #------------------------------------------------------------------------
  def draw_progress
    prog_text = "Progress: " + enemy_now.to_s + "/" + enemy_max.to_s
    pct_text = enemy_pct.to_s + "%"
    draw_text_ex(4, 0, prog_text)
    draw_text(4, 0, contents.width - 8, calc_line_height(pct_text), pct_text, 2)
  end
  #------------------------------------------------------------------------
  # * Get Number of Enemies Slain
  #------------------------------------------------------------------------
  def enemy_now
    $game_system.total_enemy_slain
  end
  #------------------------------------------------------------------------
  # * Get Maximum Number of Enemies In Bestiary
  #------------------------------------------------------------------------
  def enemy_max
    $data_enemies.size
  end
  #------------------------------------------------------------------------
  # * Get Percentage of Enemies in Bestiary
  #------------------------------------------------------------------------
  def enemy_pct
    ((enemy_now.to_f / enemy_max) * 100).to_i
  end
  #------------------------------------------------------------------------
  # * Refresh
  #------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_progress
  end
end

#==========================================================================
# ** Window_BestiaryList
#--------------------------------------------------------------------------
#  This window displays the list of monsters.
#==========================================================================
class Window_BestiaryList < Window_Selectable
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize
    super(0, fitting_height(1), Graphics.width, Graphics.height - fitting_height(1))
    @unknown = "????????"
    refresh
    select(0)
    activate
  end
  #------------------------------------------------------------------------
  # * Get Column Count
  #------------------------------------------------------------------------
  def col_max
    return 2
  end
  #------------------------------------------------------------------------
  # * Get Enemies Possible
  #------------------------------------------------------------------------
  def item_max
    $game_system.enemy_list.size
  end
  #--------------------------------------------------------------------------
  # * override method: Get Activation State of Selection Item
  #--------------------------------------------------------------------------
  def current_item_enabled?
    recorded?(index)
  end
  #------------------------------------------------------------------------
  # * Determine Enemy Recorded
  #    id : Enemy ID
  #------------------------------------------------------------------------
  def recorded?(id)
    $game_system.enemies_slain(id) > 0
  end
  #------------------------------------------------------------------------
  # * Get Unknown Text
  #------------------------------------------------------------------------
  def unknown
    @unknown
  end
  #------------------------------------------------------------------------
  # * Draw Enemy Data
  #   index  : Enemy ID
  #------------------------------------------------------------------------
  def draw_item(index)
    enemy = $game_system.enemy_list[index]
    name = $game_system.enemy_encounter[index] != nil ? enemy.name : unknown
    slain = $game_system.enemies_slain(index)
    change_color(normal_color, recorded?(index))
    draw_text(item_rect_for_text(index), name, 0)
    draw_text(item_rect_for_text(index), slain, 2)
  end
  #------------------------------------------------------------------------
  # * Refresh
  #------------------------------------------------------------------------
  def refresh
    create_contents
    draw_all_items
  end
end

#==========================================================================
# ** Window_BestiaryLeft
#--------------------------------------------------------------------------
#  This window (the left window) displays the enemy's sprite & background.
#==========================================================================
class Window_BestiaryLeft < Window_Base
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize(enemy = nil)
    super(0, 0, window_width, Graphics.height)
    @enemy = enemy
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width / 2
  end
  #--------------------------------------------------------------------------
  # * Get Window Height
  #--------------------------------------------------------------------------
  def window_height
    return Graphics.height / 2
  end
  #------------------------------------------------------------------------
  # * Set Enemy
  #------------------------------------------------------------------------
  def enemy=(enemy)
    return if @enemy == enemy
    @enemy = enemy
    refresh(enemy)
  end
  #------------------------------------------------------------------------
  # * Get Enemy Bitmap
  #------------------------------------------------------------------------
  def enemy_bitmap(enemy)
    sprite = Cache.battler(enemy.battler_name, enemy.battler_hue)
	  sprite
  end
  #------------------------------------------------------------------------
  # * Get Battle Background
  #------------------------------------------------------------------------
  def enemy_battleback(enemy)
    #sprite1 = Cache.battleback1()
    #sprite2 = Cache.battleback2()
  end
  #------------------------------------------------------------------------
  # * Draw Enemy Bitmap
  #------------------------------------------------------------------------
  def draw_enemy_graphic(enemy, x, y)
    bitmap = enemy_bitmap(enemy)
    bw = bitmap.width
    bh = bitmap.height
    src_rect = Rect.new(0, 0, bw, bh)
    contents.blt(x - bw / 2, y - bh, bitmap, src_rect)
  end
  #------------------------------------------------------------------------
  # * Refresh
  #------------------------------------------------------------------------
  def refresh(enemy)
    if enemy != nil
      draw_enemy_graphic(enemy, window_width / 2, window_height - window_height / 4)
    end
  end
end

#==========================================================================
# ** Window_BestiaryRight
#--------------------------------------------------------------------------
#  This window (the right window) displays enemy stats (HP, MP, etc).
#==========================================================================
class Window_BestiaryRight < Window_Selectable
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize(enemy = nil)
    super(window_width, 0, window_width, Graphics.height)
    @enemy = enemy
    self.visible = false
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return Graphics.width / 2
  end
  #------------------------------------------------------------------------
  # * Set Enemy
  #------------------------------------------------------------------------
  def enemy=(enemy)
    return if @enemy == enemy
    @enemy = enemy
    refresh(enemy)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Name
  #--------------------------------------------------------------------------
  def draw_enemy_name(enemy, x, y, width = 144)
    name = enemy.name
    draw_text(x, y, width, line_height, name)
  end
  #--------------------------------------------------------------------------
  # * Draw Horizontal Line
  #--------------------------------------------------------------------------
  def draw_horz_line(y)
    line_y = y + line_height / 4 - 1
    contents.fill_rect(0, line_y, contents_width, 2, line_color)
  end
  #--------------------------------------------------------------------------
  # * Get Color of Horizontal Line
  #--------------------------------------------------------------------------
  def line_color
    color = system_color
    color.alpha = 160
    color
  end
#--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh(enemy, mode = 0)
    contents.clear
    create_ratings
    draw_horz_line(line_height)
    if enemy != nil
      draw_enemy_name(enemy, 4, 0)
      if mode == 0
        draw_basic_stats(enemy, 4, 0)
        draw_other_stats(enemy, 4, line_height * 3)
      elsif mode == 1
        draw_elem_stats(enemy)
      elsif mode == 2
       draw_enemy_items(enemy, 4, 0)
      end
    end
  end
  #--------------------------------------------------------------------------
  # * Draw Basic Stats
  #--------------------------------------------------------------------------
  def draw_basic_stats(enemy, x, y)
    draw_enemy_hp(enemy, x, y + line_height * 2)
    draw_enemy_mp(enemy, x, y + line_height * 3)
  #draw_enemy_tp(enemy, x, y + line_height * 4)
  end
  #--------------------------------------------------------------------------
  # * Draw Other Stats
  #--------------------------------------------------------------------------
  def draw_other_stats(enemy, x, y)
    param_count.each { |i| draw_enemy_param(enemy, x, y + line_height * i, i) }
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Element Status Rates
  #--------------------------------------------------------------------------
  def draw_elem_stats(enemy)
    # Add the defense ratings starting from weakest => absorbing
    add_ratings
    elements_count.each do |elem|
      draw_enemy_element(enemy, 10, line_height * (elem + 2), elem)
    end
    change_color(normal_color)
  end
  #--------------------------------------------------------------------------
  # * Enemy Parameter Count
  #--------------------------------------------------------------------------
  def param_count
    2..7 # 2 => ATK, 7 => LCK
  end
  #--------------------------------------------------------------------------
  # * Enemy S-Parameter Count
  #--------------------------------------------------------------------------
  def sparam_count
    1..5 # 1 => , 5 =>
  end
  #--------------------------------------------------------------------------
  # * Enemy Element Rate Count
  #     NOTE: Adjust number of elements counted based on elements used.
  #--------------------------------------------------------------------------
  def elements_count
    3..14 # 3 => Fire, 14 => Void/Null
  end
  #--------------------------------------------------------------------------
  # * Enemy States Rate Count
  #   NOTE: Adjust number of states counted based on states used.
  #--------------------------------------------------------------------------
  def states_count
    1..10 # 1 => Death, 10 => Burn?
  end
  #--------------------------------------------------------------------------
  # * Status 
  #--------------------------------------------------------------------------
  def hp(enemy);  enemy.params[0];  end               # Enemy maximum HP
  def mp(enemy);  enemy.params[1];  end               # Enemy maximum MP
  #--------------------------------------------------------------------------
  # * Draw Enemy HP
  #--------------------------------------------------------------------------
  def draw_enemy_hp(enemy, x, y, width = 128)
    change_color(system_color)
    draw_text(x, y, width, line_height, Vocab::hp)
    change_color(normal_color)
    draw_text(x + width - 32, y, width, line_height, hp(enemy), 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy MP
  #--------------------------------------------------------------------------
  def draw_enemy_mp(enemy, x, y, width = 128)
    change_color(system_color)
    draw_text(x, y, width, line_height, Vocab::mp)
    change_color(normal_color)
    draw_text(x + width - 32, y, width, line_height, mp(enemy), 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy TP
  #--------------------------------------------------------------------------
  def draw_enemy_tp(enemy, x, y, width = 128)
    change_color(system_color)
    draw_text(x, y, width, line_height, Vocab::tp)
    change_color(normal_color)
    draw_text(x + width - 32, y, width, line_height, "0", 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Parameters
  #--------------------------------------------------------------------------
  def draw_enemy_param(enemy, x, y, param_id, width = 128)
    change_color(system_color)
    draw_text(x, y, width, line_height, Vocab::param(param_id))
    change_color(normal_color)
    draw_text(x + width - 32, y, width, line_height, enemy.params[param_id], 2)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Ex-Parameters
  #--------------------------------------------------------------------------
  def draw_enemy_xparams(enemy, x, y, width = 128)
    change_color(system_color)
  draw_text(x, y, width, line_height, "EVA")
  change_color(normal_color)
  draw_text(x + width - 32, y, width, line_height, "0", 1)
  draw_text(x + width - 32 + 4, y, 16, line_height, "%", 1)
  end
  #--------------------------------------------------------------------------
  # * Create Enemy Defense Ratings List
  #--------------------------------------------------------------------------
  def create_ratings
	  @rate_list = []
  end
  #--------------------------------------------------------------------------
  # * Add Enemy Defense Rating
  #     name   : rating name
  #     symbol : corresponding symbol
  #--------------------------------------------------------------------------
  def add_rating(name, symbol)
    @rate_list.push({:name=>name, :symbol=>symbol})
  end
  #--------------------------------------------------------------------------
  # * Get Enemy Defense Rating
  #--------------------------------------------------------------------------
  def rating(index)
    @rate_list[index][:name]
  end
  #--------------------------------------------------------------------------
  # * Add Enemy Rating Names
  #--------------------------------------------------------------------------
  def add_ratings
    add_rating("Very Weak", :very_weak)
    add_rating("Weak",      :weak)
    add_rating("---------", :neutral)
    add_rating("Strong",    :strong)
    add_rating("Immune",    :immune)
    add_rating("Absorb",    :absorb)
  end
  #--------------------------------------------------------------------------
  # * Draw Enemy Element Defense Stats
  #--------------------------------------------------------------------------
  def draw_enemy_element(enemy, x, y, param_id, width = 172)
    # Element tag to track enemy's element defense
    element_def = ""
    erate = enemy.element_rate(param_id)
	# Branch rating based on enemy's element defense
    if erate >= 200
	  change_color(text_color(10))
      element_def = rating(0)
    elsif erate > 100
	  change_color(text_color(2))
      element_def = rating(1)
    elsif erate == 100
	  change_color(normal_color, false)
      element_def = rating(2)
    elsif erate > 0
      element_def = rating(3)
    elsif erate == 0
      element_def = rating(4)
    else
	  change_color(text_color(3))
      element_def = rating(5)
    end
	draw_icon(element_icon(param_id), x, y)
    draw_text(x + width - 32, y, width, line_height, element_def, 2)
  end
  #------------------------------------------------------------------------
  # * Draw Enemy State Defense Stats
  #------------------------------------------------------------------------
  def draw_enemy_state(enemy, x, y, param_id, width = 172)
    # State defense tag to track enemy's status defense
    state_def = ""
    srate = enemy.state_rate(param_id)
	# Branch rating based on enemy's state defense
	if srate >= 200
	  change_color(text_color(10))
	  state_def = rating(0)
	elsif srate > 100
	  change_color(text_color(2))
	  state_def = rating(1)
	elsif srate == 100
	  change_color(normal_color, false)
	  state_def = rating(2)
	elsif srate > 0
	  state_def = rating(3)
	elsif srate == 0
	  state_def = rating(4)
	else
	  change_color(text_color(3))
	  state_def = rating(5)
	end
	draw_text(x + width - 32, y, width, line_height, state_def, 2)
  end
  #------------------------------------------------------------------------
  # * Draw Enemy Debuff Defense Stats
  #------------------------------------------------------------------------
  def draw_enemy_debuff(enemy, x, y, param_id, width = 172)
    # Debuff defense tag to track enemy's status defense
    debuff_def = ""
    debuff_rate = enemy.debuff_rate(param_id)
	# Branch rating based on enemy's debuff defense
	if debuff_rate >= 200
	  change_color(text_color(10))
	  debuff_def = rating(0)
	elsif debuff_rate > 100
	  change_color(text_color(2))
	  debuff_def = rating(1)
	elsif debuff_rate == 100
	  change_color(normal_color, false)
	  debuff_def = rating(2)
	elsif debuff_rate > 0
	  debuff_def = rating(3)
	elsif debuff_rate == 0
	  debuff_def = rating(4)
	else
	  change_color(text_color(3))
	  debuff_def = rating(5)
	end
	draw_text(x + width - 32, y, width, line_height, debuff_def, 2)
  end
  #------------------------------------------------------------------------
  # * Draw Enemy Dropped Items
  #------------------------------------------------------------------------
  def draw_enemy_items(enemy, x, y, width = 172)
    items = enemy.drop_items
    change_color(system_color)
    draw_text(x, y, width, line_height, "Drops")
	  draw_horz_line(y + line_height)
    change_color(normal_color)
    items.each do |item|
	    draw_item_name(item, x, y + line_height * 2)
    end
  end
  #------------------------------------------------------------------------
  # * Draw Element Icons
  # 	Note: These numbers are only applicable to the big iconset.
  #------------------------------------------------------------------------
  def element_icon(index)
    # Set icon values based on icon index 
    # (adjust if icon index for each element is different)
    wood_icon = 192
    steel_icon = 146
    heart_icon = 135
    byss_icon = 136

    element_set = { 
      3 => 104, # Fire
      4 => 105, # Ice
      5 => 106, # Thunder
      6 => 107, # Water
      7 => 108, # Earth
      8 => 109, # Wind
      9 => 110, # Light
      10 => 111, # Darkness
      11 => wood_icon, # Wood
      12 => steel_icon, # Steel
      13 => heart_icon, # Heart
      14 => byss_icon, # Null/Void
    }
	
	# Return icon value based on index passed
	#return index + elem_icon if index > 2 && index < 11
	#return 0 if index == 2
	#return wood_icon if index == 11
	#return steel_icon if index == 12
	#return heart_icon if index == 13
	#return byss_icon if index == 14
	#return physical_icon
    return element_set[index]
  end
  #------------------------------------------------------------------------
  # * Draw Element Icons
  #  Note: This method is for the default iconset.
  #------------------------------------------------------------------------
  #def element_icon(index)
    #elem_icon = 93
	#physical_icon = 107
	  #element_set = {
      #3 => 96, # Fire
      #4 => 97, # Ice
      #5 => 98, # Thunder
      #6 => 99, # Water
      #7 => 100, # Earth
      #8 => 101, # Wind
      #9 => 102, # Light
      #10 => 103, # Darkness
      #11 => 331, # Wood
      #12 => 350, # Steel
      #13 => 119, # Heart
      #14 => 120, # Null/Void
    #}
	# Return icon value based on index passed
	#return index + elem_icon if index > 2 && index < 11
	#return 0 if index == 2
	#return physical_icon
  #end
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
  alias bestiary_cmd add_original_commands
  def add_original_commands
    bestiary_cmd
	add_bestiary_command
  end
  #--------------------------------------------------------------------------
  # * new method: Add Bestiary to Command List
  #--------------------------------------------------------------------------
  def add_bestiary_command
    add_command("Bestiary", :bestiary, bestiary_enabled)
  end
  #--------------------------------------------------------------------------
  # * new method: Get Activation State of Bestiary
  #--------------------------------------------------------------------------
  def bestiary_enabled
    return true
  end
end

#==========================================================================
# ** Scene_Menu
#--------------------------------------------------------------------------
#  This class performs the menu scene processing.
#==========================================================================
class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * override method: Create Command Window
  #--------------------------------------------------------------------------
  def create_command_window
    @command_window = Window_MenuCommand.new
    @command_window.set_handler(:item,      method(:command_item))
    @command_window.set_handler(:skill,     method(:command_personal))
    @command_window.set_handler(:equip,     method(:command_personal))
    @command_window.set_handler(:status,    method(:command_personal))
    @command_window.set_handler(:formation, method(:command_formation))
	  @command_window.set_handler(:bestiary,	method(:command_bestiary))
    @command_window.set_handler(:save,      method(:command_save))
    @command_window.set_handler(:game_end,  method(:command_game_end))
    @command_window.set_handler(:cancel,    method(:return_scene))
  end
  #--------------------------------------------------------------------------
  # * new method: [Bestiary] Window
  #--------------------------------------------------------------------------
  def command_bestiary
    SceneManager.call(Scene_Bestiary)
  end
end

#==========================================================================
# ** Scene_Bestiary
#--------------------------------------------------------------------------
#  This class performs the bestiary scene processing.
#==========================================================================
class Scene_Bestiary < Scene_MenuBase
  #------------------------------------------------------------------------
  # * Object Initialization
  #------------------------------------------------------------------------
  def initialize
    @index = -1
    @enemy = enemy(@index)
  end
  #------------------------------------------------------------------------
  # * Start Processing
  #------------------------------------------------------------------------
  def start
    super
    create_bestiary_list_windows
    create_bestiary_windows
  end
  #------------------------------------------------------------------------
  # * Create Bestiary List Windows
  #------------------------------------------------------------------------
  def create_bestiary_list_windows
    create_status_window
    create_list_window
  end
  #------------------------------------------------------------------------
  # * Create Bestiary Windows
  #------------------------------------------------------------------------
  def create_bestiary_windows
    create_left_window
    create_right_window
  end
  #------------------------------------------------------------------------
  # * Create Stat Window
  #------------------------------------------------------------------------
  def create_status_window
    @status_window = Window_BestiaryStatus.new
    @status_window.viewport = @viewport
  end
  #------------------------------------------------------------------------
  # * Create List Window
  #------------------------------------------------------------------------
  def create_list_window
    @list_window = Window_BestiaryList.new
    @list_window.viewport = @viewport
    @list_window.set_handler(:ok,     method(:on_enemy_ok))
    @list_window.set_handler(:cancel, method(:return_scene))
  end
  #------------------------------------------------------------------------
  # * Create Left Window
  #------------------------------------------------------------------------
  def create_left_window
    @left_window = Window_BestiaryLeft.new
  end
  #------------------------------------------------------------------------
  # * Create Right Window
  #------------------------------------------------------------------------
  def create_right_window
    @right_window = Window_BestiaryRight.new
    @right_window.set_handler(:cancel,   method(:on_enemy_cancel))
    @right_window.set_handler(:pagedown, method(:next_enemy))
    @right_window.set_handler(:pageup,   method(:prev_enemy))
    @right_window.set_handler(:up,       method(:cursor_up))
    @right_window.set_handler(:down,     method(:cursor_down))
  end
  #------------------------------------------------------------------------
  # * Enemy [OK] Processing
  #------------------------------------------------------------------------
  def on_enemy_ok
    determine_enemy
  end
  #------------------------------------------------------------------------
  # * Enemy [Cancel]
  #------------------------------------------------------------------------
  def on_enemy_cancel
    hide_bestiary_windows
    show_bestiary_list_windows
  end
  #------------------------------------------------------------------------
  # * Confirm Enemy
  #------------------------------------------------------------------------
  def determine_enemy
    @index = @list_window.index
    @enemy = enemy(@index)
    if @enemy != nil
      @left_window.enemy = @enemy
      @right_window.enemy = @enemy
      hide_bestiary_list_windows
      show_bestiary_windows
    end
  end
  #------------------------------------------------------------------------
  # * Show Bestiary List Windows
  #------------------------------------------------------------------------
  def show_bestiary_list_windows
    show_window(@status_window)
    show_window(@list_window)
  end
  #------------------------------------------------------------------------
  # * Hide Bestiary List Windows
  #------------------------------------------------------------------------
  def hide_bestiary_list_windows
    hide_window(@status_window)
    hide_window(@list_window)
  end
  #------------------------------------------------------------------------
  # * Show Bestiary Windows
  #------------------------------------------------------------------------
  def show_bestiary_windows
    show_window(@left_window)
    show_window(@right_window)
  end
  #------------------------------------------------------------------------
  # * Hide Bestiary Windows
  #------------------------------------------------------------------------
  def hide_bestiary_windows
    hide_window(@left_window)
    hide_window(@right_window)
  end
  #------------------------------------------------------------------------
  # * Show Window
  #------------------------------------------------------------------------
  def show_window(window)
    window.activate
    window.show
  end
  #------------------------------------------------------------------------
  # * Hide Window
  #------------------------------------------------------------------------
  def hide_window(window)
    window.deactivate
    window.hide
  end  
  #------------------------------------------------------------------------
  # * Get Selected Enemy
  #------------------------------------------------------------------------
  def enemy(index)
    $game_system.enemy_list[index]
  end
  #------------------------------------------------------------------------
  # * Switch to Previous Enemy
  #------------------------------------------------------------------------
  def prev_enemy
  end
  #------------------------------------------------------------------------
  # * Switch to Next Enemy
  #------------------------------------------------------------------------
  def next_enemy
  end
end
