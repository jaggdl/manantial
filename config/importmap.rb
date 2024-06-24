# Pin npm packages by running ./bin/importmap

pin "application", preload: true
pin "@hotwired/turbo-rails", to: "turbo.min.js", preload: true
pin "@hotwired/stimulus", to: "stimulus.min.js", preload: true
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js", preload: true
pin "@rails/ujs", to: "@rails--ujs.js", preload: false # @7.1.3
pin_all_from "app/javascript/controllers", under: "controllers"
pin "chartkick", to: "chartkick.js", preload: false
pin "Chart.bundle", to: "Chart.bundle.js", preload: false
pin "admin", preload: false
