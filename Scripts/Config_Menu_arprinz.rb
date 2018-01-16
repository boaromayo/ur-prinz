#==========================================================================
# *** Config Menu
#--------------------------------------------------------------------------
#  This plugin provides a customizable configuration menu. 
#
# * Version: 0.5.0
#
# * Initial release: 2018-01-10
#
# * Initial commit: 2018-01-10
#
# * Updated: 2018-01-15
#
# * Coded by: boaromayo/Quesada's Swan
#
# NOTE: If you are using this plugin for your projects (commercial or non-commercial), 
# be sure to leave this comment visible or credit me (boaromayo or Quesada's Swan) 
# somewhere in your projects.
#
# * Changelog:
#    -- Initial commit - 2018-01-10
#==========================================================================

$imported ||= {}
$imported["Config-Menu_arprinz"] = true

#==========================================================================
# ** Config Terms
#--------------------------------------------------------------------------
#  This module shows the terms used by the configuration menu.
#  For any users customizing their menus, go here to change terms and
#  descriptions.
#==========================================================================
module ConfigTerms
  #------------------------------------------------------------------------
  # * Constants (Terms)
  #------------------------------------------------------------------------
  MESSAGE_SPEED       = "Message Speed"          # Message Speed
  DISABLE_DASH        = "Disable Dashing"        # Disable Dashing
  FONT_CHANGE         = "Change Font"            # Change Font
  MENU_STYLE          = "Change Menu Style"      # Change Menu Style
  BESTIARY            = "Bestiary"               # Bestiary
  CATALOGUE           = "Item Catalogue"         # Catalogue
  COMMENTARY          = "Enable Commentary"      # Enable Commentary
  #------------------------------------------------------------------------
  # * Constants (Descriptions)
  #------------------------------------------------------------------------
  DESC_MSG_SPEED      = "Change the in-game speed of the message displayed."
  DESC_DASH           = "Toggle whether the player can dash."
  DESC_FONT_CHG       = "Change the in-game font displayed."
  DESC_MENU_STYLE     = "Change the style of the menu and windows."
  DESC_BESTIARY       = "Open the " + BESTIARY + "."
  DESC_CATALOGUE      = "Open the " + CATALOGUE + "."
  DESC_COMMENTARY     = "Activate in-game developer commentary."
  #------------------------------------------------------------------------
  # * Constants (Positions)
  #------------------------------------------------------------------------
  POS_MSG_SPEED       = 0
  POS_DASH            = 1
  POS_FONT_CHG        = 2
  POS_MENU_STYLE      = 3
  POS_BESTIARY        = 4
  POS_CATALOGUE       = 5
  POS_COMMENTARY      = 6
end

#==========================================================================
# ** Game_System
#--------------------------------------------------------------------------
#  This class handles system data. It saves the disable state of saving and 
# menus. Instances of this class are referenced by $game_system.
#==========================================================================
class Game_System
  #------------------------------------------------------------------------
  # * new public variables
  #------------------------------------------------------------------------
  attr_accessor :bestiary_ok
  attr_accessor :catalogue_ok
  attr_accessor :commentary_enabled # Scripts will handle this flag
end

#==========================================================================
# ** Window_Config
#--------------------------------------------------------------------------
#  This window displays the configuration menu.
#==========================================================================
class Window_Config < Window_Selectable
  def initialize
  	super(0, line_height(1), window_width, window_height)
  	refresh
  	select(0)
  	activate
  end
  def window_width
  	Graphics.width
  end
  def window_height
  	Graphics.height - line_height(1)
  end
  def current_item_enabled?(index)
    if index == ConfigTerms::POS_BESTIARY; $game_system.bestiary_ok; end;
    if index == ConfigTerms::POS_CATALOGUE; $game_system.catalogue_ok; end;
  end
end

#==========================================================================
# ** Window_ConfigSub
#--------------------------------------------------------------------------
#  This sub window displays configuration choices.
#==========================================================================
class Window_ConfigSub < Window_Selectable
	def initialize(x, y, width, height = line_height(4))
    super(x, y, width, height)
    self.visible = false
  end
  def draw_item(index, mode)
    contents.clear
    case mode
    when :window
      draw_text()
    when :font
      draw_text()
    end
  end
  def refresh
    super
  end
end

#==========================================================================
# ** Scene_Config
#--------------------------------------------------------------------------
#  This scene displays the configuration menu.
#==========================================================================
class Scene_Config < Scene_MenuBase
  def start
    super
    create_config_windows
  end
  def create_config_windows
    create_config_window
    create_config_sub_window  
  end
  def create_config_window
    @config_window = Window_Config.new
    @config_window.viewport = @viewport
    set_config_commands
  end
  def create_config_sub_window
    @sub_window = Window_ConfigSub.new(0,0,128)
    @sub_window.set_handler(:ok,      method(:on_sub_ok))
    @sub_window.set_handler(:cancel,  method(:on_sub_cancel))
  end
  def set_config_commands
    # Set configuration commands here using: @config_window.set_handler(:key, method(:method_here))
    @config_window.set_handler(:msg_speed,    method(:command_msg_speed))
    @config_window.set_handler(:dash,         method(:command_dash))
    @config_window.set_handler(:font,         method(:command_font_change))
    @config_window.set_handler(:window,       method(:command_window_change))
    @config_window.set_handler(:bestiary,     method(:command_bestiary))
    @config_window.set_handler(:catalogue,    method(:command_catalogue))
    @config_window.set_handler(:comment,      method(:command_comment))
    @config_window.set_handler(:cancel,       method(:return_scene))
  end
  def command_msg_speed
    @sub_window.height = line_height(1)
    prep_sub_window
  end
  def command_dash
    prep_sub_window
  end
  def command_font_change
    prep_sub_window
  end
  def command_window_change
    prep_sub_window
  end
  def command_bestiary
    SceneManager.call(Scene_Bestiary)
  end
  def command_catalogue
    SceneManager.call(Scene_Catalogue)
  end
  def command_comment
    prep_sub_window
  end
  def prep_sub_window
    deactivate_config_window
    show_sub_window
  end
  def show_sub_window
    @sub_window.activate
    @sub_window.show
  end
  def hide_sub_window
    @sub_window.deactivate
    @sub_window.hide
  end
  def activate_config_window
    @config_window.activate
  end
  def deactivate_config_window
    @config_window.deactivate
  end
  def on_sub_ok
    case flag
    when :comment
      !$game_system.commentary_enabled
    end
  end
  def on_sub_cancel
    hide_sub_window
    activate_config_window
  end
end
