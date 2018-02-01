#==============================================================================
# *** Playtime Window
#------------------------------------------------------------------------------
# This plugin adds a playtime window in the menu.
#
# * Version: 1.0.0
#
# * Initial release: 2017-10-24
#
# * Initial commit: 2018-01-31
#
# * Updated: 2018-01-31
#
# * Coded by: boaromayo/Quesada's Swan
#
# NOTE: If you are using this plugin for your projects (commercial or non-commercial), 
# be sure to leave this comment visible or credit me (boaromayo or Quesada's Swan) 
# in your projects.
#
# NOTE: This works only if the default menu is used. Custom menu plugins and 
# other modifications have not been tested for this plugin yet.
#
# * Changelog:
#    -- Initial commit - 2018-01-31
#    -- Added terms of use and extra information - 2018-01-31
#    -- Initial release - 2017-10-24
#    -- Finished script - 2015-03-23
#    -- Started script - 2015-03-23
#==============================================================================
#==============================================================================
# ** Window_Playtime
#------------------------------------------------------------------------------
#  This window shows the total playthrough time.
#==============================================================================

class Window_Playtime < Window_Base
  #---------------------------------------------------------------------------
  # * Object Initialization
  #---------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, fitting_height(1))
    refresh
  end
  #---------------------------------------------------------------------------
  # * Get Window Width
  #---------------------------------------------------------------------------
  def window_width
    return 160
  end
  #---------------------------------------------------------------------------
  # * Refresh
  #---------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_playtime(time, 4, 0, contents.width - 8)
  end
  #---------------------------------------------------------------------------
  # * Draw Playtime
  #---------------------------------------------------------------------------
  def draw_playtime(time, x, y, width)
    draw_icon(hourglass, x, y, true) # Draw hourglass icon
    change_color(normal_color)
    draw_text(x, y, width, line_height, time, 2) # Draw playtime
  end
  #---------------------------------------------------------------------------
  # * Get Time Icon (Hourglass Icon)
  #---------------------------------------------------------------------------
  def hourglass
    return 188
  end
  #---------------------------------------------------------------------------
  # * Get Time
  #---------------------------------------------------------------------------
  def time
    $game_system.playtime_s
  end
  #---------------------------------------------------------------------------
  # * Update
  #---------------------------------------------------------------------------
  def update
    super
    cur_time = $game_system.playtime
    if cur_time != time
      refresh
    end
  end
end

#==============================================================================
# ** Scene_Menu
#------------------------------------------------------------------------------
#  This class performs the menu screen processing.
#==============================================================================
class Scene_Menu < Scene_MenuBase
  #--------------------------------------------------------------------------
  # * alias method: Start Processing
  #--------------------------------------------------------------------------
  alias playtime_start start
  def start
    playtime_start
    create_playtime_window
  end
  #--------------------------------------------------------------------------
  # * new method: Create Playtime Window
  #--------------------------------------------------------------------------
  def create_playtime_window
    @playtime_window = Window_Playtime.new
    @playtime_window.x = 0
    @playtime_window.y = Graphics.height - @playtime_window.height - @gold_window.height
  end
end