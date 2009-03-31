# prepends body with "hello from middleware ..."
class ExampleMiddleware
  def initialize app
    @app = app
  end
  def call env
    status, headers, each_able = @app.call env
    body = ''
    each_able.each {|string| body << string }
    [ status, headers, "hello from middleware ... inner app body: #{ body }" ]
  end
end

# prepends body with "1"
class UpdateBodyWith1
  def initialize app
    @app = app
  end
  def call env
    status, headers, each_able = @app.call env
    body = ''
    each_able.each {|string| body << string }
    [ status, headers, "1#{ body }" ]
  end
end

# prepends body with "1"
class UpdateBodyWith2
  def initialize app
    @app = app
  end
  def call env
    status, headers, each_able = @app.call env
    body = ''
    each_able.each {|string| body << string }
    [ status, headers, "2#{ body }" ]
  end
end
