// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import {Turbo} from "@hotwired/turbo-rails"
import Rails from "@rails/ujs"

import "controllers"

Rails.start()

// It works
Turbo.setProgressBarDelay(100);
