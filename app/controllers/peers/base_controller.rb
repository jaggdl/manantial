module Peers
  class BaseController < ApplicationController
    private

    def normalized_hostname
      Connection.normalize_hostname(params[:hostname])
    end
  end
end
