#==============================================================================
# *** GoldIcon Window
#------------------------------------------------------------------------------
#  This plugin replaces the currency value with a currency icon (a coin) 
# in the menu.
#
# * Version: 1.0.0
# 
# * Initial release: 2017-10-25
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
#     -- Added terms of use and other information. - 2018-01-31
#     -- Initial release - 2017-10-25
#     -- Initial commit; finished script - 2017-10-24
#==============================================================================
#==============================================================================
# ** Window_Base
#------------------------------------------------------------------------------
#  This is a super class of all windows within the game.
#==============================================================================

class Window_Base < Window
  #--------------------------------------------------------------------------
  # * Get Currency Icon (Coin Icon)
  #--------------------------------------------------------------------------
  def coin
    return 205 # Number for coin icon
  end
  #--------------------------------------------------------------------------
  # * new method: Draw Currency (Gold Etc.) with Currency Icon
  #--------------------------------------------------------------------------
  def draw_currency(value, x, y, width)
    draw_icon(coin, x, y, true) 
    change_color(normal_color)
    draw_text(x, y, width, line_height, value, 2)
  end
  #--------------------------------------------------------------------------
  # * new method: Draw Currency Value (Gold Etc.) with Currency Icon
  #--------------------------------------------------------------------------
  def draw_currency_value_icon(value, x, y, width)
    change_color(normal_color)
    draw_text(x, y, width - 2, line_height, value, 2)
    draw_icon(coin, x, y, true)
  end
end

#==============================================================================
# ** Window_GoldIcon
#------------------------------------------------------------------------------
#  This window displays the party's gold. Replaces unit name with gold icon.
#==============================================================================

class Window_GoldIcon < Window_Base
  #--------------------------------------------------------------------------
  # * Object Initialization
  #--------------------------------------------------------------------------
  def initialize
    super(0, 0, window_width, fitting_height(1))
    refresh
  end
  #--------------------------------------------------------------------------
  # * Get Window Width
  #--------------------------------------------------------------------------
  def window_width
    return 160
  end
  #--------------------------------------------------------------------------
  # * Refresh
  #--------------------------------------------------------------------------
  def refresh
    contents.clear
    draw_currency(value, 4, 0, contents.width - 8)
  end
  #--------------------------------------------------------------------------
  # * Get Party Gold
  #--------------------------------------------------------------------------
  def value
    $game_party.gold
  end
  #--------------------------------------------------------------------------
  # * Open Window
  #--------------------------------------------------------------------------
  def open
    refresh
    super
  end
end
