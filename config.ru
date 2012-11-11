# This file is used by Rack-based servers to start the application.

require ::File.expand_path('../config/environment',  __FILE__)

# config.ru
require 'faye'
require File.expand_path('../app', __FILE__)

use Faye::RackAdapter, :mount => '/faye',
    :timeout => 25,
    :engine  => {
        :port  => 7777
    }

run Preview::Application
