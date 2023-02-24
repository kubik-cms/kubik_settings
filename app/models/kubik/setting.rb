# frozen_string_literal: true

class Kubik::Setting < ApplicationRecord
  if defined?(Kubik::Metatagable)
    include Kubik::Metatagable
    kubik_metatagable
  end

  def self.instance
    first_or_create!(singleton_guard: 1)
  end

  def to_s
    'Settings'
  end
end
