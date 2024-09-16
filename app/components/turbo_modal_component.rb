class TurboModalComponent < ViewComponent::Base
  include Turbo::FramesHelper

  renders_one :body 
  
  def initialize(title:, size: '', frame: 'modal')
    @title = title
    @size = size
    @frame = frame
  end

  attr_reader :title, :size, :frame
end
