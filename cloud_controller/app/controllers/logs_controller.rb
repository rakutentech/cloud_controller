class LogsController < ApplicationController
  before_filter :require_user

  # GET /logs(/:name(/:date(/:instance_index(/:file))))
  def files
    host = AppConfig[:app_logs_file_viewer][:primary][:host]
    port = AppConfig[:app_logs_file_viewer][:primary][:port]
    secondary_host = AppConfig[:app_logs_file_viewer][:secondary][:host]
    secondary_port = AppConfig[:app_logs_file_viewer][:secondary][:port]

    # Build the path for the log
    path = build_log_path(params)

    if params[:secondary]
      url = "http://#{secondary_host}:#{secondary_port}/#{path}"
    else
      url = "http://#{host}:#{port}/#{path}"
    end

    # Proxy the request to the Nginx in cf_apps_logserver
    http = http_aget(url, nil)

    if (http.response_header.status != 200 and
        http.response_header.status != 404)
      raise CloudError.new(CloudError::APP_FILE_ERROR, params[:path] || '/')
    end

    # Inherit the content type from the nginx response
    response.headers['Content-Type'] = http.response_header['CONTENT_TYPE']
    self.response_body = http.response
  end

  private

  def build_log_path(params)
    path = ''
    path << "#{params[:name]}/" unless params[:name].nil?
    path << "#{params[:date]}/" unless params[:date].nil?
    path << "#{params[:instance_index]}/" unless params[:instance_index].nil?
    path << "#{params[:file]}.#{params[:extension]}" unless params[:file].nil?
    path << ".#{params[:format]}" unless params[:format].nil?

    [user.email, path].join('/')
  end
end
