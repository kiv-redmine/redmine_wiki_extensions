# Wiki Extensions plugin for Redmine
# Copyright (C) 2011  Haruyuki Iida
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
class WikiExtensionsMenu < ActiveRecord::Base
  include Redmine::SafeAttributes
  unloadable
  belongs_to :project
  validates_presence_of :project_id
  validates_presence_of :menu_no

  safe_attributes 'enabled', 'menu_no', 'title', 'page_name'

  def self.find_or_create(pj_id, no)
    # If no is range create & load it once
    if no.is_a?(Range)
      # Find all menus
      menu = WikiExtensionsMenu.where(:project_id => pj_id).where(:menu_no => no)

      # Iterate over range and create menus
      (no.to_a - menu.map(&:menu_no)).each do |num|
        # Create new menu
        menu << self.create_menu(pj_id, num)
      end
    else
      # Find one menu
      menu = WikiExtensionsMenu.where(:project_id => pj_id).where(:menu_no => no).first

      # Create menu
      unless menu
        menu = self.create_menu(pj_id, no)
      end
    end

    menu
  end

  def self.create_menu(pj_id, no)
    WikiExtensionsMenu.create(:project_id => pj_id, :menu_no => no, :enabled => false)
  end

  def self.enabled?(pj_id, no)
    begin
      menu = find_or_create(pj_id, no)
      return false if menu.page_name.blank?
      menu.enabled
    rescue
      return false
    end
  end

  def self.title(pj_id, no)
    begin
      menu = find_or_create(pj_id, no)
      return menu.title unless menu.title.blank?
      return menu.page_name unless menu.page_name.blank?
      return nil
    rescue
      return nil
    end
  end

  def validate
    return true unless enabled
    #errors.add("title", "is empty") unless attribute_present?("title")
    #errors.add("page_name", "is empty") unless attribute_present?("page_name")
  end
end
